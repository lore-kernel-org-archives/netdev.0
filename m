From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/19] Netfilter/IPVS updates for net-next
Date: Tue, 20 Aug 2013 12:54:32 +0200
Message-ID: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following batch contains Netfilter/IPVS updates for your net-next tree.
More specifically, they are:

* Trivial typo fix in xt_addrtype, from Phil Oester.

* Remove net_ratelimit in the conntrack logging for consistency with other
  logging subsystem, from Patrick McHardy.

* Remove unneeded includes from the recently added xt_connlabel support, from
  Florian Westphal.

* Allow to update conntracks via nfqueue, don't need NFQA_CFG_F_CONNTRACK for
  this, from Florian Westphal.

* Remove tproxy core, now that we have socket early demux, from Florian
  Westphal.

* A couple of patches to refactor conntrack event reporting to save a good
  bunch of lines, from Florian Westphal.

* Fix missing locking in NAT sequence adjustment, it did not manifested in
  any known bug so far, from Patrick McHardy.

* Change sequence number adjustment variable to 32 bits, to delay the
  possible early overflow in long standing connections, also from Patrick.

* Comestic cleanups for IPVS, from Dragos Foianu.

* Fix possible null dereference in IPVS in the SH scheduler, from Daniel
  Borkmann.

* Allow to attach conntrack expectations via nfqueue. Before this patch, you
  had to use ctnetlink instead, thus, we save the conntrack lookup.

* Export xt_rpfilter and xt_HMARK header files, from Nicolas Dichtel.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

Thanks!

----------------------------------------------------------------

The following changes since commit 9025c8e253369d324111c041032018955b80dd55:

  drivers/net/ethernet/stmicro/stmmac: don't check resource with devm_ioremap_resource (2013-07-24 23:59:33 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 38c67328ac79cb9eaf61b5d4750fe3b9cff0dd15:

  netfilter: export xt_HMARK.h to userland (2013-08-14 10:48:05 +0200)

----------------------------------------------------------------
Daniel Borkmann (1):
      ipvs: ip_vs_sh: ip_vs_sh_get_port: check skb_header_pointer for NULL

Dragos Foianu (1):
      ipvs: fixed spacing at for statements

Florian Westphal (7):
      netfilter: connlabels: remove unneeded includes
      netfilter: nf_queue: relax NFQA_CT attribute check
      netfilter: tproxy: remove nf_tproxy_core, keep tw sk assigned to skb
      netfilter: tproxy: remove nf_tproxy_core.h
      netfilter: nf_conntrack: remove duplicate code in ctnetlink
      netfilter: tproxy: fix build with IP6_NF_IPTABLES=n
      netfilter: nf_conntrack: don't send destroy events from iterator

Nicolas Dichtel (2):
      netfilter: export xt_rpfilter.h to userland
      netfilter: export xt_HMARK.h to userland

Pablo Neira Ayuso (2):
      netfilter: ctnetlink: refactor ctnetlink_create_expect
      netfilter: nfnetlink_queue: allow to attach expectations to conntracks

Patrick McHardy (5):
      netfilter: nf_conntrack: remove net_ratelimit() for LOG_INVALID()
      netfilter: nf_conntrack: constify sk_buff argument to nf_ct_attach()
      netfilter: nf_nat: fix locking in nf_nat_seq_adjust()
      netfilter: nf_nat: change sequence number adjustments to 32 bits
      netfilter: nf_nat: use per-conntrack locking for sequence number adjustments

Phil Oester (1):
      netfilter: xt_addrtype: fix trivial typo

 Documentation/networking/tproxy.txt              |    5 +-
 include/linux/netfilter.h                        |    8 +-
 include/net/netfilter/nf_conntrack.h             |    9 +-
 include/net/netfilter/nf_conntrack_l4proto.h     |    7 -
 include/net/netfilter/nf_nat.h                   |    2 +-
 include/net/netfilter/nf_nat_helper.h            |    6 +-
 include/net/netfilter/nf_tproxy_core.h           |  210 -----------------
 include/net/netfilter/nfnetlink_queue.h          |    8 +
 include/uapi/linux/netfilter/Kbuild              |    2 +
 include/uapi/linux/netfilter/nfnetlink_queue.h   |    1 +
 include/{ => uapi}/linux/netfilter/xt_HMARK.h    |    0
 include/{ => uapi}/linux/netfilter/xt_rpfilter.h |    0
 net/ipv4/netfilter/ipt_MASQUERADE.c              |    2 +-
 net/ipv6/netfilter/ip6t_MASQUERADE.c             |    2 +-
 net/netfilter/Kconfig                            |   22 +-
 net/netfilter/Makefile                           |    3 -
 net/netfilter/core.c                             |    7 +-
 net/netfilter/ipvs/ip_vs_lblcr.c                 |    8 +-
 net/netfilter/ipvs/ip_vs_sh.c                    |    6 +
 net/netfilter/nf_conntrack_core.c                |   69 ++----
 net/netfilter/nf_conntrack_labels.c              |    4 -
 net/netfilter/nf_conntrack_netlink.c             |  269 ++++++++++++++--------
 net/netfilter/nf_conntrack_proto.c               |    4 +-
 net/netfilter/nf_conntrack_proto_tcp.c           |    4 +-
 net/netfilter/nf_nat_core.c                      |    6 +-
 net/netfilter/nf_nat_helper.c                    |   28 ++-
 net/netfilter/nf_tproxy_core.c                   |   62 -----
 net/netfilter/nfnetlink_queue_core.c             |   11 +-
 net/netfilter/nfnetlink_queue_ct.c               |   15 ++
 net/netfilter/xt_TPROXY.c                        |  169 +++++++++++++-
 net/netfilter/xt_addrtype.c                      |    2 +-
 net/netfilter/xt_socket.c                        |   66 +++++-
 32 files changed, 513 insertions(+), 504 deletions(-)
 delete mode 100644 include/net/netfilter/nf_tproxy_core.h
 rename include/{ => uapi}/linux/netfilter/xt_HMARK.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_rpfilter.h (100%)
 delete mode 100644 net/netfilter/nf_tproxy_core.c

