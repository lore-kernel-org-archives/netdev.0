From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH 00/51] Fix potential issues detected by Coverity
 tool
Date: Tue, 15 Aug 2017 08:07:25 -0700
Message-ID: <20170815080725.1dbb42a0@xeon-e3>
References: <20170812120510.28750-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:38077 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750936AbdHOPH2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 11:07:28 -0400
Received: by mail-pg0-f43.google.com with SMTP id l64so7173453pge.5
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 08:07:28 -0700 (PDT)
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Aug 2017 14:04:19 +0200
Phil Sutter <phil@nwl.cc> wrote:

> Covscan really wasn't amused (indicated by the number of patches in this
> series). Try to make it happy.
> 
> Phil Sutter (51):
>   devlink: Check return code of strslashrsplit()
>   devlink: No need for this self-assignment
>   ipaddress: Make buffer for filter.flushb static
>   ipaddress: Avoid accessing uninitialized variable lcl
>   iplink_can: Prevent overstepping array bounds
>   iplink_vrf: Complain if main table is not found
>   ipmaddr: Avoid accessing uninitialized data
>   ipntable: No need to check and assign to parms_rta
>   ipntable: Make sure filter.name is NULL-terminated
>   iproute: Fix for missing 'Oifs:' display
>   iproute: Check mark value input
>   iproute_lwtunnel: csum_mode value checking was ineffective
>   iproute_lwtunnel: Argument to strerror must be positive
>   ipvrf: Don't try to close an invalid fd
>   ipvrf: Fix error path of vrf_switch()
>   xfrm_state: Make sure alg_name is NULL-terminated
>   lib/bpf: Don't leak fp in bpf_find_mntpt()
>   lib/fs: Fix format string in find_fs_mount()
>   lib/fs: Fix and simplify make_path()
>   lib/inet_proto: Make sure destination buffers are NULL-terminated
>   lib/libnetlink: Don't pass NULL parameter to memcpy()
>   lib/rt_names: Drop dead code in rtnl_rttable_n2a()
>   ifstat: Fix memleak in error case
>   ifstat, nstat: Check fdopen() return value
>   ifstat: Fix memleak in dump_kern_db() for json output
>   lnstat_util: Simplify alloc_and_open() a bit
>   nstat: Fix for potential NULL pointer dereference
>   nstat: Avoid passing negative fd to fdopen()
>   ss: Use C99 initializer in netlink_show_one()
>   ss: Skip useless check in parse_hostcond()
>   ss: Drop useless assignment
>   ss: Make sure index variable is >= 0
>   ss: Don't leak fd in tcp_show_netlink_file()
>   ss: Make sure scanned index value to unix_state_map is sane
>   ss: Fix potential memleak in unix_stats_print()
>   netem/maketable: Check return value of fstat()
>   netem/maketable: Check return value of fscanf()
>   tc/em_ipset: Don't leak sockfd on error path
>   tc/m_gact: Drop dead code
>   tc/m_xt: Fix for potential string buffer overflows
>   tc/q_multiq: Don't pass garbage in TCA_OPTIONS
>   tc/q_netem: Don't dereference possibly NULL pointer
>   tc/tc_filter: Make sure filter name is not empty
>   tipc/bearer: Fix resource leak in error path
>   tipc/bearer: Prevent NULL pointer dereference
>   tipc/node: Fix socket fd check in cmd_node_get_addr()
>   examples: Some shell fixes to cbq.init
>   ifcfg: Quote left-hand side of [ ] expression
>   lib/ll_map: Make sure im->name is NULL-terminated
>   Check user supplied interface name lengths
>   lib/bpf: Check return value of write()
> 
>  devlink/devlink.c        | 18 ++++++++++-----
>  examples/cbq.init-v0.7.3 | 24 ++++++++++----------
>  include/utils.h          |  1 +
>  ip/ifcfg                 |  2 +-
>  ip/ip6tunnel.c           |  6 +++--
>  ip/ipaddress.c           |  4 ++--
>  ip/ipl2tp.c              |  1 +
>  ip/iplink.c              | 27 +++++++----------------
>  ip/iplink_can.c          |  4 ++--
>  ip/iplink_vrf.c          |  5 ++++-
>  ip/ipmaddr.c             |  3 ++-
>  ip/ipntable.c            |  5 ++---
>  ip/iproute.c             | 14 +++++++-----
>  ip/iproute_lwtunnel.c    |  9 ++++----
>  ip/iprule.c              |  4 ++++
>  ip/iptunnel.c            | 12 ++++++----
>  ip/iptuntap.c            |  4 +++-
>  ip/ipvrf.c               | 16 ++++++++------
>  ip/xfrm_state.c          |  3 ++-
>  lib/bpf.c                |  8 +++++--
>  lib/fs.c                 | 22 +++++--------------
>  lib/inet_proto.c         |  9 +++++---
>  lib/libnetlink.c         |  6 +++--
>  lib/ll_map.c             |  4 ++--
>  lib/rt_names.c           |  4 ----
>  lib/utils.c              |  8 +++++++
>  misc/arpd.c              |  1 +
>  misc/ifstat.c            | 28 +++++++++++++++++-------
>  misc/lnstat_util.c       |  7 ++----
>  misc/nstat.c             | 33 +++++++++++++++++++---------
>  misc/ss.c                | 57 +++++++++++++++++++++++++++++-------------------
>  netem/maketable.c        |  8 +++----
>  tc/em_ipset.c            |  1 +
>  tc/m_gact.c              | 14 +++---------
>  tc/m_xt.c                |  7 +++---
>  tc/q_multiq.c            |  2 +-
>  tc/q_netem.c             |  4 +++-
>  tc/tc_filter.c           |  3 +++
>  tipc/bearer.c            |  7 ++++--
>  tipc/node.c              |  3 ++-
>  40 files changed, 230 insertions(+), 168 deletions(-)
> 

I am not amused by large patchsets either.
It takes more time to review, and one comment means the whole series
has to be redone.
