From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/31: netfilter update
Date: Wed, 10 Jun 2009 21:46:22 +0200 (MEST)
Message-ID: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

following is my netfilter update for 2.6.31, containing:

- various *tables cleanups by Jan Engelhardt

- nfnetlink queue balancing support from Florian Westphal

- the iptables OSF match from Evgeniy

- a patch to improve ICMP conntrack timeout behaviour from Jan Kasprzak

- various cleanups for the ctnetlink subsystem from Pablo

- a patch to use per-conntrack locks instead of the global protocol locks
  (your prediction turned out right :))

Pablo still has a set of patches we discussed, reviewed and improved
during the past week that he didn't manage to submit in the final state
today. If you don't mind I would send those as a second and final update,
but they *are* late, so we fully understand if you prefer to have them
delayed until the next merge window.

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!

PS: Please note: there's no patch 12, my scripts can't handle merges
correctly. Will fix until next time :)


 include/linux/netfilter/Kbuild                   |    1 +
 include/linux/netfilter/nf_conntrack_common.h    |   69 ----
 include/linux/netfilter/nf_conntrack_tcp.h       |    3 +-
 include/linux/netfilter/nfnetlink.h              |    5 +-
 include/linux/netfilter/nfnetlink_conntrack.h    |    1 +
 include/linux/netfilter/x_tables.h               |    6 +-
 include/linux/netfilter/xt_NFQUEUE.h             |    5 +
 include/linux/netfilter/xt_osf.h                 |  133 +++++++
 include/linux/netfilter/xt_socket.h              |   12 +
 include/net/netfilter/ipv4/nf_conntrack_icmp.h   |   11 -
 include/net/netfilter/ipv6/nf_conntrack_icmpv6.h |    7 -
 include/net/netfilter/nf_conntrack.h             |    9 +-
 include/net/netfilter/nf_conntrack_ecache.h      |  113 +++++-
 include/net/netfilter/nf_conntrack_l4proto.h     |    4 +-
 include/net/netlink.h                            |    9 +
 net/bridge/netfilter/ebtables.c                  |   18 +-
 net/ipv4/netfilter/arp_tables.c                  |  117 +++---
 net/ipv4/netfilter/ip_queue.c                    |    2 +-
 net/ipv4/netfilter/ip_tables.c                   |  172 +++++-----
 net/ipv4/netfilter/ipt_MASQUERADE.c              |   12 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c     |   17 +-
 net/ipv6/netfilter/ip6_queue.c                   |    2 +-
 net/ipv6/netfilter/ip6_tables.c                  |  170 +++++-----
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c   |   17 +-
 net/netfilter/Kconfig                            |   13 +
 net/netfilter/Makefile                           |    1 +
 net/netfilter/nf_conntrack_core.c                |   30 +-
 net/netfilter/nf_conntrack_ecache.c              |   83 ++++-
 net/netfilter/nf_conntrack_ftp.c                 |    2 -
 net/netfilter/nf_conntrack_netlink.c             |  263 ++++++--------
 net/netfilter/nf_conntrack_proto_dccp.c          |   31 +-
 net/netfilter/nf_conntrack_proto_gre.c           |    3 +-
 net/netfilter/nf_conntrack_proto_sctp.c          |   27 +-
 net/netfilter/nf_conntrack_proto_tcp.c           |  138 ++++---
 net/netfilter/nf_queue.c                         |    4 +-
 net/netfilter/nfnetlink.c                        |   28 +-
 net/netfilter/x_tables.c                         |   42 ++-
 net/netfilter/xt_NFQUEUE.c                       |   93 +++++-
 net/netfilter/xt_osf.c                           |  428 ++++++++++++++++++++++
 net/netfilter/xt_socket.c                        |   63 +++-
 40 files changed, 1462 insertions(+), 702 deletions(-)
 create mode 100644 include/linux/netfilter/xt_osf.h
 create mode 100644 include/linux/netfilter/xt_socket.h
 delete mode 100644 include/net/netfilter/ipv4/nf_conntrack_icmp.h
 create mode 100644 net/netfilter/xt_osf.c

Evgeniy Polyakov (2):
      netfilter: x_tables: added hook number into match extension parameter structure.
      netfilter: passive OS fingerprint xtables match

Florian Westphal (3):
      netfilter: xt_NFQUEUE: use NFPROTO_UNSPEC
      netfilter: xt_NFQUEUE: queue balancing support
      netfilter: ipt_MASQUERADE: remove redundant rwlock

Jan Engelhardt (11):
      netfilter: xtables: use NFPROTO_ for xt_proto_init callsites
      netfilter: queue: use NFPROTO_ for queue callsites
      netfilter: xtables: use NFPROTO_ in standard targets
      netfilter: xtables: remove redundant casts
      netfilter: xtables: fix const inconsistency
      netfilter: xtables: consolidate open-coded logic
      netfilter: xtables: reduce indent level by one
      netfilter: xtables: remove some goto
      netfilter: xtables: remove another level of indent
      netfilter: xtables: consolidate comefrom debug cast access
      netfilter: xtables: print hook name instead of mask

Jan Kasprzak (1):
      netfilter: nf_ct_icmp: keep the ICMP ct entries longer

Jozsef Kadlecsik (1):
      netfilter: nf_ct_tcp: TCP simultaneous open support

Laszlo Attila Toth (1):
      netfilter: xt_socket: added new revision of the 'socket' match supporting flags

Pablo Neira Ayuso (10):
      netfilter: conntrack: add support for DCCP handshake sequence to ctnetlink
      netfilter: nfnetlink: cleanup for nfnetlink_rcv_msg() function
      netfilter: ctnetlink: remove nowait parameter from *fill_info()
      netfilter: ctnetlink: rename tuple() by nf_ct_tuple() macro definition
      netfilter: ctnetlink: use nlmsg_* helper function to build messages
      netfilter: ctnetlink: cleanup message-size calculation
      netfilter: conntrack: don't report events on module removal
      netfilter: conntrack: remove events flags from userspace exposed file
      netfilter: conntrack: simplify event caching system
      netfilter: conntrack: replace notify chain by function pointer

Patrick McHardy (2):
      Merge branch 'master' of git://dev.medozas.de/linux
      netfilter: nf_conntrack: use per-conntrack locks for protocol data
