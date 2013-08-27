From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/8] netfilter updates for net-next
Date: Wed, 28 Aug 2013 00:53:30 +0200
Message-ID: <1377644018-15685-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter updates for your net-next tree,
they are:

* The new SYNPROXY target for iptables, including IPv4 and IPv6 support,
  from Patrick McHardy.

* nf_defrag_ipv6.o should be only linked to nf_defrag_ipv6.ko, from
  Nathan Hintz.

* Fix an old bug in REJECT, which replies with wrong MAC source address
  from the bridge, by Phil Oester.

* Fix uninitialized helper variable in the expectation support over
  nfnetlink_queue, from Florian Westphal.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

Thanks!

----------------------------------------------------------------

The following changes since commit 35fdb94b453bc69b7bc74b717f1e03d41d4bcdba:

  e1000e: balance semaphore put/get for 82573 (2013-08-27 16:05:26 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to b7e092c05b308674c642ed7fb754d555f0ebba81:

  netfilter: ctnetlink: fix uninitialized variable (2013-08-28 00:28:19 +0200)

----------------------------------------------------------------
Florian Westphal (1):
      netfilter: ctnetlink: fix uninitialized variable

Nathan Hintz (1):
      netfilter: nf_defrag_ipv6.o included twice

Patrick McHardy (5):
      netfilter: nf_conntrack: make sequence number adjustments usuable without NAT
      net: syncookies: export cookie_v4_init_sequence/cookie_v4_check
      netfilter: add SYNPROXY core/target
      net: syncookies: export cookie_v6_init_sequence/cookie_v6_check
      netfilter: add IPv6 SYNPROXY target

Phil Oester (1):
      netfilter: ip[6]t_REJECT: tcp-reset using wrong MAC source if bridged

 include/linux/netfilter.h                          |    9 +-
 include/net/netfilter/nf_conntrack_extend.h        |    6 +
 include/net/netfilter/nf_conntrack_seqadj.h        |   51 ++
 include/net/netfilter/nf_conntrack_synproxy.h      |   77 +++
 include/net/netfilter/nf_nat.h                     |   10 -
 include/net/netfilter/nf_nat_helper.h              |   19 -
 include/net/tcp.h                                  |    8 +
 include/uapi/linux/netfilter/nf_conntrack_common.h |    3 +-
 include/uapi/linux/netfilter/nfnetlink_conntrack.h |   15 +-
 include/uapi/linux/netfilter/xt_SYNPROXY.h         |   16 +
 net/ipv4/netfilter/Kconfig                         |   13 +
 net/ipv4/netfilter/Makefile                        |    1 +
 net/ipv4/netfilter/ipt_REJECT.c                    |   21 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c                  |  472 +++++++++++++++++++
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |    7 +-
 net/ipv4/syncookies.c                              |   29 +-
 net/ipv6/netfilter/Kconfig                         |   13 +
 net/ipv6/netfilter/Makefile                        |    3 +-
 net/ipv6/netfilter/ip6t_REJECT.c                   |   20 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c                 |  495 ++++++++++++++++++++
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c     |    7 +-
 net/ipv6/syncookies.c                              |   25 +-
 net/netfilter/Kconfig                              |    3 +
 net/netfilter/Makefile                             |    5 +-
 net/netfilter/nf_conntrack_core.c                  |   22 +-
 net/netfilter/nf_conntrack_netlink.c               |  117 +++--
 net/netfilter/nf_conntrack_proto_tcp.c             |   34 +-
 net/netfilter/nf_conntrack_seqadj.c                |  238 ++++++++++
 net/netfilter/nf_nat_core.c                        |   16 +-
 net/netfilter/nf_nat_helper.c                      |  228 +--------
 net/netfilter/nf_nat_sip.c                         |    3 +-
 net/netfilter/nf_synproxy_core.c                   |  432 +++++++++++++++++
 net/netfilter/nfnetlink_queue_ct.c                 |    8 +-
 33 files changed, 2026 insertions(+), 400 deletions(-)
 create mode 100644 include/net/netfilter/nf_conntrack_seqadj.h
 create mode 100644 include/net/netfilter/nf_conntrack_synproxy.h
 create mode 100644 include/uapi/linux/netfilter/xt_SYNPROXY.h
 create mode 100644 net/ipv4/netfilter/ipt_SYNPROXY.c
 create mode 100644 net/ipv6/netfilter/ip6t_SYNPROXY.c
 create mode 100644 net/netfilter/nf_conntrack_seqadj.c
 create mode 100644 net/netfilter/nf_synproxy_core.c

