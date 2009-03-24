From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/41: Netfilter update for 2.6.30
Date: Tue, 24 Mar 2009 15:03:06 +0100 (MET)
Message-ID: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

the following patches contain (the major part of) my netfilter updates for 2.6.30.
Besides the usual small fixes and cleanups, there is:

- a new LED trigger target by Adam Nielsen

- device name match optimizations for *tables from Eric Dumazet

- Conversion of *tables to use RCU for rulesets and counters from Stephen
  and Eric

- unification of the TTL/HL targets and ttl/hl matches from Jan Engelhardt

- a new "cluster" match from Pablo to transparently distribute traffic over
  a cluster of machines without a load-balancer

- a set of patches to make netfilter logging backends selectable per address
  family from Eric Leblond

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git

Thanks!


 drivers/leds/Kconfig                           |    3 +
 include/linux/netfilter/Kbuild                 |    8 +
 include/linux/netfilter/nfnetlink.h            |    1 +
 include/linux/netfilter/x_tables.h             |   15 +-
 include/linux/netfilter/xt_LED.h               |   13 ++
 include/linux/netfilter/xt_cluster.h           |   15 ++
 include/linux/netfilter/xt_limit.h             |    9 +-
 include/linux/netfilter/xt_quota.h             |    4 +-
 include/linux/netfilter/xt_statistic.h         |    7 +-
 include/linux/netfilter_ipv6/Kbuild            |    1 +
 include/net/netfilter/nf_conntrack.h           |    2 +-
 include/net/netfilter/nf_conntrack_l4proto.h   |   10 +-
 include/net/netfilter/nf_log.h                 |   11 +-
 net/bridge/netfilter/ebtable_broute.c          |    1 -
 net/bridge/netfilter/ebtable_filter.c          |    1 -
 net/bridge/netfilter/ebtable_nat.c             |    1 -
 net/ipv4/netfilter/Kconfig                     |   30 ++--
 net/ipv4/netfilter/Makefile                    |    2 -
 net/ipv4/netfilter/arp_tables.c                |  159 ++++++++++++++-----
 net/ipv4/netfilter/arptable_filter.c           |    2 -
 net/ipv4/netfilter/ip_queue.c                  |    2 +
 net/ipv4/netfilter/ip_tables.c                 |  153 +++++++++++++------
 net/ipv4/netfilter/ipt_LOG.c                   |    2 +-
 net/ipv4/netfilter/ipt_TTL.c                   |   97 ------------
 net/ipv4/netfilter/ipt_ULOG.c                  |    2 +-
 net/ipv4/netfilter/ipt_ttl.c                   |   63 --------
 net/ipv4/netfilter/iptable_filter.c            |    1 -
 net/ipv4/netfilter/iptable_mangle.c            |    1 -
 net/ipv4/netfilter/iptable_raw.c               |    1 -
 net/ipv4/netfilter/iptable_security.c          |    1 -
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    4 +-
 net/ipv4/netfilter/nf_nat_rule.c               |    1 -
 net/ipv6/netfilter/Kconfig                     |   38 ++---
 net/ipv6/netfilter/Makefile                    |    2 -
 net/ipv6/netfilter/ip6_queue.c                 |    1 +
 net/ipv6/netfilter/ip6_tables.c                |  152 ++++++++++++------
 net/ipv6/netfilter/ip6t_HL.c                   |   95 -----------
 net/ipv6/netfilter/ip6t_LOG.c                  |    2 +-
 net/ipv6/netfilter/ip6t_hl.c                   |   68 --------
 net/ipv6/netfilter/ip6table_filter.c           |    1 -
 net/ipv6/netfilter/ip6table_mangle.c           |    1 -
 net/ipv6/netfilter/ip6table_raw.c              |    1 -
 net/ipv6/netfilter/ip6table_security.c         |    1 -
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    1 +
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    4 +
 net/netfilter/Kconfig                          |   63 ++++++++
 net/netfilter/Makefile                         |    4 +
 net/netfilter/core.c                           |    2 -
 net/netfilter/nf_conntrack_core.c              |   14 +-
 net/netfilter/nf_conntrack_expect.c            |    3 +-
 net/netfilter/nf_conntrack_netlink.c           |  161 +++++++++-----------
 net/netfilter/nf_conntrack_proto.c             |   21 ---
 net/netfilter/nf_conntrack_proto_dccp.c        |  145 +++++++++++++-----
 net/netfilter/nf_conntrack_proto_generic.c     |    2 +-
 net/netfilter/nf_conntrack_proto_tcp.c         |    2 +
 net/netfilter/nf_conntrack_proto_udp.c         |    2 +
 net/netfilter/nf_log.c                         |  201 ++++++++++++++++++++----
 net/netfilter/nfnetlink.c                      |    6 +
 net/netfilter/nfnetlink_log.c                  |   18 ++-
 net/netfilter/x_tables.c                       |   26 +++-
 net/netfilter/xt_HL.c                          |  171 ++++++++++++++++++++
 net/netfilter/xt_LED.c                         |  161 +++++++++++++++++++
 net/netfilter/xt_cluster.c                     |  164 +++++++++++++++++++
 net/netfilter/xt_hashlimit.c                   |    7 +-
 net/netfilter/xt_hl.c                          |  108 +++++++++++++
 net/netfilter/xt_limit.c                       |   40 ++++--
 net/netfilter/xt_physdev.c                     |   37 +++--
 net/netfilter/xt_quota.c                       |   31 +++-
 net/netfilter/xt_statistic.c                   |   28 +++-
 net/netlink/af_netlink.c                       |    1 +
 net/sysctl_net.c                               |    2 +-
 71 files changed, 1626 insertions(+), 784 deletions(-)
 create mode 100644 include/linux/netfilter/xt_LED.h
 create mode 100644 include/linux/netfilter/xt_cluster.h
 delete mode 100644 net/ipv4/netfilter/ipt_TTL.c
 delete mode 100644 net/ipv4/netfilter/ipt_ttl.c
 delete mode 100644 net/ipv6/netfilter/ip6t_HL.c
 delete mode 100644 net/ipv6/netfilter/ip6t_hl.c
 create mode 100644 net/netfilter/xt_HL.c
 create mode 100644 net/netfilter/xt_LED.c
 create mode 100644 net/netfilter/xt_cluster.c
 create mode 100644 net/netfilter/xt_hl.c

Adam Nielsen (1):
      netfilter: x_tables: add LED trigger target

Christoph Paasch (2):
      netfilter: change generic l4 protocol number
      netfilter: remove IPvX specific parts from nf_conntrack_l4proto.h

Cyrill Gorcunov (2):
      net: sysctl_net - use net_eq to compare nets
      net: netfilter conntrack - add per-net functionality for DCCP protocol

Eric Dumazet (7):
      netfilter: arp_tables: unfold two critical loops in arp_packet_match()
      netfilter: xt_physdev fixes
      netfilter: xt_physdev: unfold two loops in physdev_mt()
      netfilter: ip6_tables: unfold two loops in ip6_packet_match()
      netfilter: ip_tables: unfold two critical loops in ip_packet_match()
      netfilter: xt_hashlimit fix
      netfilter: nf_conntrack: Reduce conntrack count in nf_conntrack_free()

Eric Leblond (4):
      netfilter: log invalid new icmpv6 packet with nf_log_packet()
      netfilter: use a linked list of loggers
      netfilter: print the list of register loggers
      netfilter: sysctl support of logger choice

Florian Westphal (2):
      netfilter: ctnetlink: remove remaining module refcounting
      netfilter: remove nf_ct_l4proto_find_get/nf_ct_l4proto_put

Hagen Paul Pfeifer (2):
      netfilter: nf_conntrack: table max size should hold at least table size
      netfilter: fix hardcoded size assumptions

Jan Engelhardt (6):
      netfilter: remove unneeded goto
      netfilter: Combine ipt_TTL and ip6t_HL source
      netfilter: Combine ipt_ttl and ip6t_hl source
      netfilter: xtables: add backward-compat options
      netfilter: install missing headers
      netfilter: xtables: avoid pointer to self

Pablo Neira Ayuso (7):
      netfilter: nf_conntrack: account packets drop by tcp_packet()
      netfilter: conntrack: increase drop stats if sequence adjustment fails
      netfilter: ctnetlink: cleanup master conntrack assignation
      netfilter: ctnetlink: cleanup conntrack update preliminary checkings
      netfilter: ctnetlink: move event reporting for new entries outside the lock
      netfilter: xtables: add cluster match
      nefilter: nfnetlink: add nfnetlink_set_err and use it in ctnetlink

Patrick McHardy (1):
      netfilter: ctnetlink: fix rcu context imbalance

Scott James Remnant (2):
      netfilter: auto-load ip6_queue module when socket opened
      netfilter: auto-load ip_queue module when socket opened

Stephen Hemminger (5):
      netfilter: x_tables: change elements in x_tables
      netfilter: x_tables: remove unneeded initializations
      netfilter: ebtables: remove unneeded initializations
      netfilter: iptables: lock free counters
      netfilter: Kconfig spelling fixes (trivial)
