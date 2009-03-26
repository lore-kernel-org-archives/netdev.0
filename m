From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/12: Netfilter fixes/2.6.30 update part II
Date: Thu, 26 Mar 2009 20:02:30 +0100 (MET)
Message-ID: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

following are a few late netfilter patches and fixes for 2.6.30, containing:

- Eric's patch to use SLAB_DESTROY_BY_RCU in conntrack, which reduces
  the conntrack size and avoids temporarily exceeding the configured
  maximum amount of entries before the RCU threshold kicks in.

- another patch from Eric to factorize the optimized ifname comparisons

- a fix from Eric to use hlist_add_head_rcu in nf_conntrack_set_hashsize()
  to avoid a race condition

- a number of patches from Holger Eitzenberger to perform approximately
  correct allocation (might overshoot by a bit) for ctnetlink event
  messages to avoid reallocation in netlink_trim(). According to some
  benchmarks by Pablo. this increases throughput by about 10% in an
  connection intensive workload.

- a patch fixing a build-failure in the new LED target

- a patch from Francis Dupont to fix an old regression in the *tables
  loop detection. Slightly modified and ported to ip6_tables and
  arp_tables by myself.

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git

Thanks!


 include/linux/netfilter/x_tables.h                 |   23 ++++
 include/net/netfilter/nf_conntrack.h               |   14 ++-
 include/net/netfilter/nf_conntrack_helper.h        |    2 +
 include/net/netfilter/nf_conntrack_l3proto.h       |    7 +
 include/net/netfilter/nf_conntrack_l4proto.h       |    7 +
 include/net/netfilter/nf_conntrack_tuple.h         |    6 +-
 include/net/netlink.h                              |    1 +
 include/net/netns/conntrack.h                      |    5 +-
 net/ipv4/netfilter/arp_tables.c                    |   18 +--
 net/ipv4/netfilter/ip_tables.c                     |   27 +----
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |    6 +
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   |   63 ++++++----
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c       |    6 +
 net/ipv4/netfilter/nf_nat_core.c                   |    2 +-
 net/ipv6/netfilter/ip6_tables.c                    |   27 +----
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c     |    6 +
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c     |    6 +
 net/netfilter/Kconfig                              |    2 +-
 net/netfilter/nf_conntrack_core.c                  |  129 ++++++++++++--------
 net/netfilter/nf_conntrack_expect.c                |    2 +-
 net/netfilter/nf_conntrack_helper.c                |    8 +-
 net/netfilter/nf_conntrack_netlink.c               |   94 +++++++++++++--
 net/netfilter/nf_conntrack_proto.c                 |   16 +++
 net/netfilter/nf_conntrack_proto_dccp.c            |    9 ++
 net/netfilter/nf_conntrack_proto_gre.c             |    1 +
 net/netfilter/nf_conntrack_proto_sctp.c            |   10 ++
 net/netfilter/nf_conntrack_proto_tcp.c             |   15 +++
 net/netfilter/nf_conntrack_proto_udp.c             |    2 +
 net/netfilter/nf_conntrack_proto_udplite.c         |    1 +
 net/netfilter/nf_conntrack_standalone.c            |   57 +++++----
 net/netfilter/xt_connlimit.c                       |    6 +-
 net/netfilter/xt_physdev.c                         |   21 +---
 net/netlink/attr.c                                 |   27 ++++
 33 files changed, 416 insertions(+), 210 deletions(-)

Eric Dumazet (3):
      netfilter: nf_conntrack: use hlist_add_head_rcu() in nf_conntrack_set_hashsize()
      netfilter: factorize ifname_compare()
      netfilter: nf_conntrack: use SLAB_DESTROY_BY_RCU and get rid of call_rcu()

Holger Eitzenberger (7):
      netfilter: ctnetlink: add callbacks to the per-proto nlattrs
      netlink: add nla_policy_len()
      netfilter: limit the length of the helper name
      netfilter: ctnetlink: allocate right-sized ctnetlink skb
      netfilter: nf_conntrack: add generic function to get len of generic policy
      netfilter: nf_conntrack: calculate per-protocol nlattr size
      ctnetlink: compute generic part of event more acurately

Patrick McHardy (2):
      netfilter: fix xt_LED build failure
      netfilter: {ip,ip6,arp}_tables: fix incorrect loop detection
