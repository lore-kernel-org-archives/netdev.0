From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/12] Netfilter/IPVS fixes for net
Date: Mon,  9 Oct 2017 18:25:34 +0200
Message-ID: <1507566346-32553-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter/IPVS fixes for your net tree,
they are:

1) Fix packet drops due to incorrect ECN handling in IPVS, from Vadim
   Fedorenko.

2) Fix splat with mark restoration in xt_socket with non-full-sock,
   patch from Subash Abhinov Kasiviswanathan.

3) ipset bogusly bails out when adding IPv4 range containing more than
   2^31 addresses, from Jozsef Kadlecsik.

4) Incorrect pernet unregistration order in ipset, from Florian Westphal.

5) Races between dump and swap in ipset results in BUG_ON splats, from
   Ross Lagerwall.

6) Fix chain renames in nf_tables, from JingPiao Chen.

7) Fix race in pernet codepath with ebtables table registration, from
   Artem Savkov.

8) Memory leak in error path in set name allocation in nf_tables, patch
   from Arvind Yadav.

9) Don't dump chain counters if they are not available, this fixes a
   crash when listing the ruleset.

10) Fix out of bound memory read in strlcpy() in x_tables compat code,
    from Eric Dumazet.

11) Make sure we only process TCP packets in SYNPROXY hooks, patch from
    Lin Zhang.

12) Cannot load rules incrementally anymore after xt_bpf with pinned
    objects, added in revision 1. From Shmulik Ladkani.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit b4391db42308c9940944b5d7be5ca4b78fb88dd0:

  netlink: fix nla_put_{u8,u16,u32} for KASAN (2017-09-25 20:18:27 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 98589a0998b8b13c4a8fa1ccb0e62751a019faa5:

  netfilter: xt_bpf: Fix XT_BPF_MODE_FD_PINNED mode of 'xt_bpf_info_v1' (2017-10-09 15:18:04 +0200)

----------------------------------------------------------------
Artem Savkov (1):
      netfilter: ebtables: fix race condition in frame_filter_net_init()

Arvind Yadav (1):
      netfilter: nf_tables: Release memory obtained by kasprintf

Eric Dumazet (1):
      netfilter: x_tables: avoid stack-out-of-bounds read in xt_copy_counters_from_user

Florian Westphal (1):
      netfilter: ipset: pernet ops must be unregistered last

JingPiao Chen (1):
      netfilter: nf_tables: fix update chain error

Jozsef Kadlecsik (1):
      netfilter: ipset: Fix adding an IPv4 range containing more than 2^31 addresses

Lin Zhang (1):
      netfilter: SYNPROXY: skip non-tcp packet in {ipv4, ipv6}_synproxy_hook

Pablo Neira Ayuso (1):
      netfilter: nf_tables: do not dump chain counters if not enabled

Ross Lagerwall (1):
      netfilter: ipset: Fix race between dump and swap

Shmulik Ladkani (1):
      netfilter: xt_bpf: Fix XT_BPF_MODE_FD_PINNED mode of 'xt_bpf_info_v1'

Subash Abhinov Kasiviswanathan (1):
      netfilter: xt_socket: Restore mark from full sockets only

Vadim Fedorenko (1):
      netfilter: ipvs: full-functionality option for ECN encapsulation in tunnel

 include/linux/bpf.h                          |  5 +++++
 include/linux/netfilter_bridge/ebtables.h    |  7 ++++---
 include/uapi/linux/netfilter/xt_bpf.h        |  1 +
 kernel/bpf/inode.c                           |  1 +
 net/bridge/netfilter/ebtable_broute.c        |  4 ++--
 net/bridge/netfilter/ebtable_filter.c        |  4 ++--
 net/bridge/netfilter/ebtable_nat.c           |  4 ++--
 net/bridge/netfilter/ebtables.c              | 17 ++++++++--------
 net/ipv4/netfilter/ipt_SYNPROXY.c            |  3 ++-
 net/ipv6/netfilter/ip6t_SYNPROXY.c           |  2 +-
 net/netfilter/ipset/ip_set_core.c            | 29 +++++++++++++++++-----------
 net/netfilter/ipset/ip_set_hash_ip.c         | 22 +++++++++++----------
 net/netfilter/ipset/ip_set_hash_ipmark.c     |  2 +-
 net/netfilter/ipset/ip_set_hash_ipport.c     |  2 +-
 net/netfilter/ipset/ip_set_hash_ipportip.c   |  2 +-
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |  4 ++--
 net/netfilter/ipset/ip_set_hash_net.c        |  2 +-
 net/netfilter/ipset/ip_set_hash_netiface.c   |  2 +-
 net/netfilter/ipset/ip_set_hash_netnet.c     |  4 ++--
 net/netfilter/ipset/ip_set_hash_netport.c    |  2 +-
 net/netfilter/ipset/ip_set_hash_netportnet.c |  4 ++--
 net/netfilter/ipvs/ip_vs_xmit.c              |  8 ++++++--
 net/netfilter/nf_tables_api.c                | 10 ++++++----
 net/netfilter/x_tables.c                     |  4 ++--
 net/netfilter/xt_bpf.c                       | 22 +++++++++++++++++++--
 net/netfilter/xt_socket.c                    |  4 ++--
 26 files changed, 107 insertions(+), 64 deletions(-)
