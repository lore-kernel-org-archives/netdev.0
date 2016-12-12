From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2 v2 net-next 0/8] Add support for vrf helper
Date: Mon, 12 Dec 2016 15:43:43 -0800
Message-ID: <20161212154343.451032a7@xeon-e3>
References: <1481401934-4026-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36240 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932164AbcLLXnw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 18:43:52 -0500
Received: by mail-pf0-f179.google.com with SMTP id 189so14896299pfz.3
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2016 15:43:51 -0800 (PST)
In-Reply-To: <1481401934-4026-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 10 Dec 2016 12:32:06 -0800
David Ahern <dsa@cumulusnetworks.com> wrote:

> This series adds support to iproute2 to run a command against a specific
> VRF. The user semnatics are similar to 'ip netns'.
> 
> The 'ip vrf' subcommand supports 3 usages:
> 
> 1. Run a command against a given vrf:
>        ip vrf exec NAME CMD
> 
>    Uses the recently committed cgroup/sock BPF option. vrf directory
>    is added to cgroup2 mount. Individual vrfs are created under it. BPF
>    filter is attached to vrf/NAME cgroup2 to set sk_bound_dev_if to the
>    device index of the VRF. From there the current process (ip's pid) is
>    addded to the cgroups.proc file and the given command is exected. In
>    doing so all AF_INET/AF_INET6 (ipv4/ipv6) sockets are automatically
>    bound to the VRF domain.
> 
>    The association is inherited parent to child allowing the command to
>    be a shell from which other commands are run relative to the VRF.
> 
> 2. Show the VRF a process is bound to:
>        ip vrf id
>    This command essentially looks at /proc/pid/cgroup for a "::/vrf/"
>    entry.
> 
> 3. Show process ids bound to a VRF
>        ip vrf pids NAME
>    This command dumps the file MNT/vrf/NAME/cgroup.procs since that file
>    shows the process ids in the particular vrf cgroup.
> 
> v2
> - updated suject of patch 3 to avoid spam filters on vger
> 
> David Ahern (8):
>   lib bpf: Add support for BPF_PROG_ATTACH and BPF_PROG_DETACH
>   bpf: export bpf_prog_load
>   Add libbpf.h header with BPF_ macros
>   move cmd_exec to lib utils
>   Add filesystem APIs to lib
>   change name_is_vrf to return index
>   libnetlink: Add variant of rtnl_talk that does not display RTNETLINK
>     answers error
>   Introduce ip vrf command
> 
>  include/bpf_util.h   |   6 ++
>  include/libbpf.h     | 184 ++++++++++++++++++++++++++++++++
>  include/libnetlink.h |   3 +
>  include/utils.h      |   4 +
>  ip/Makefile          |   3 +-
>  ip/ip.c              |   4 +-
>  ip/ip_common.h       |   4 +-
>  ip/iplink_vrf.c      |  29 ++++--
>  ip/ipnetns.c         |  34 ------
>  ip/ipvrf.c           | 289 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  lib/Makefile         |   2 +-
>  lib/bpf.c            |  71 ++++++++-----
>  lib/exec.c           |  41 ++++++++
>  lib/fs.c             | 143 +++++++++++++++++++++++++
>  lib/libnetlink.c     |  20 +++-
>  man/man8/ip-vrf.8    |  88 ++++++++++++++++
>  16 files changed, 850 insertions(+), 75 deletions(-)
>  create mode 100644 include/libbpf.h
>  create mode 100644 ip/ipvrf.c
>  create mode 100644 lib/exec.c
>  create mode 100644 lib/fs.c
>  create mode 100644 man/man8/ip-vrf.8
> 

Please use tooling that puts v2 on all the updated patches.
It makes it easier to spot them in patchwork
