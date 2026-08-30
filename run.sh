#!/usr/bin/env bash
set -euo pipefail

: "${API_URL:?}"
: "${DATA_REPO:?}"
: "${DATA_SSH_KEY:?}"
: "${JOB:?}"

export QUIET=1
export API_URL
export DATA_ROOT="${RUNNER_TEMP:-/tmp}/work"
export WORKFLOW_FILE="${WORKFLOW_FILE:-ci.yml}"

mkdir -p "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"
ssh-keyscan -t ed25519,rsa github.com >> "${HOME}/.ssh/known_hosts" 2>/dev/null

eval "$(ssh-agent -s)" >/dev/null
KEYFILE="${RUNNER_TEMP:-/tmp}/k"
umask 077
printf '%s\n' "${DATA_SSH_KEY}" > "${KEYFILE}"
ssh-add "${KEYFILE}" >/dev/null
rm -f "${KEYFILE}"

git clone --depth 1 --single-branch --branch "${DATA_BRANCH:-main}" \
  "git@github.com:${DATA_REPO}.git" "${DATA_ROOT}"
cd "${DATA_ROOT}"
git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

exec bash "${JOB}"
