#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-08-24 13:14:16 +0100 (Mon, 24 Aug 2020)
#
#  https://github.com/HariSekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/HariSekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
. "$srcdir/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Lists the Teamcity agents and their states via the Teamcity API

Output format:

<agent_id>  <connected>     <authorized>      <enabled>    <up_to_date>    <name>

Specify \$NO_HEADER to omit the header line

See adjacent teamcity_api.sh for authentication details
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="[<curl_options>]"

help_usage "$@"

{
if [ -z "${NO_HEADER:-}" ]; then
    printf 'Agent_ID\tConnected\tAuthorized\tEnabled\tUp_to_Date\tName\n'
fi
"$srcdir/teamcity_api.sh" /agents |
jq -r '.agent[].id' |
while read -r id; do
    "$srcdir/teamcity_api.sh" "/agents/id:$id" |
    jq -r '[.id, .connected, .authorized, .enabled, .uptodate, .name] | @tsv'
done
} |
column -t
