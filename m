From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/38] Netfilter/IPVS updates for net-next
Date: Mon, 17 Mar 2014 13:42:20 +0100
Message-ID: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter/IPVS updates for net-next,
most relevantly they are:

* cleanup to remove double semicolon from stephen hemminger.

* calm down sparse warning in xt_ipcomp, from Fan Du.

* nf_ct_labels support for nf_tables, from Florian Westphal.

* new macros to simplify rcu dereferences in the scope of nfnetlink
  and nf_tables, from Patrick McHardy.

* Accept queue and drop (including reason for drop) to verdict
  parsing in nf_tables, also from Patrick.

* Remove unused random seed initialization in nfnetlink_log, from
  Florian Westphal.

* Allow to attach user-specific information to nf_tables rules, useful
  to attach user comments to rule, from me.

* Return errors in ipset according to the manpage documentation, from
  Jozsef Kadlecsik.

* Fix coccinelle warnings related to incorrect bool type usage for ipset,
  from Fengguang Wu.

* Add hash:ip,mark set type to ipset, from Vytas Dauksa.

* Fix message for each spotted by ipset for each netns that is created,
  from Ilia Mirkin.

* Add forceadd option to ipset, which evicts a random entry from the set
  if it becomes full, from Josh Hunt.

* Minor IPVS cleanups and fixes from Andi Kleen and Tingwei Liu.

* Improve conntrack scalability by removing a central spinlock, original
  work from Eric Dumazet. Jesper Dangaard Brouer took them over to address
  remaining issues. Several patches to prepare this change come in first
  place.

* Rework nft_hash to resolve bugs (leaking chain, missing rcu synchronization
  on element removal, etc. from Patrick McHardy.

* Restore context in the rule deletion path, as we now release rule objects
  synchronously, from Patrick McHardy. This gets back event notification for
  anonymous sets.

* Fix NAT family validation in nft_nat, also from Patrick.

* Improve scalability of xt_connlimit by using an array of spinlocks and
  by introducing a rb-tree of hashtables for faster lookup of accounted
  objects per network. This patch was preceded by several patches and
  refactorizations to accomodate this change including the use of kmem_cache,
  from Florian Westphal.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

These changes should merge cleanly without conflicts to your net-next tree.

Thanks a lot!

----------------------------------------------------------------

The following changes since commit 1e8d6421cff2c24fe0b345711e7a21af02e8bcf5:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2014-02-19 01:24:22 -0500)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 7d08487777c8b30dea34790734d708470faaf1e5:

  netfilter: connlimit: use rbtree for per-host conntrack obj storage (2014-03-17 11:11:57 +0100)

----------------------------------------------------------------
Andi Kleen (1):
      sections, ipvs: Remove useless __read_mostly for ipvs genl_ops

Fengguang Wu (1):
      netfilter: ipset: Add hash: fix coccinelle warnings

Florian Westphal (10):
      netfilter: nft_ct: labels get support
      netfilter: nfnetlink_log: remove unused code
      netfilter: ipset: kernel: uapi: fix MARKMASK attr ABI breakage
      netfilter: connlimit: factor hlist search into new function
      netfilter: connlimit: improve packet-to-closed-connection logic
      netfilter: connlimit: move insertion of new element out of count function
      netfilter: connlimit: use kmem_cache for conn objects
      netfilter: connlimit: use keyed locks
      netfilter: connlimit: make same_source_net signed
      netfilter: connlimit: use rbtree for per-host conntrack obj storage

Ilia Mirkin (1):
      netfilter: ipset: move registration message to init from net_init

Jesper Dangaard Brouer (5):
      netfilter: trivial code cleanup and doc changes
      netfilter: conntrack: spinlock per cpu to protect special lists.
      netfilter: avoid race with exp->master ct
      netfilter: conntrack: seperate expect locking from nf_conntrack_lock
      netfilter: conntrack: remove central spinlock nf_conntrack_lock

Joe Perches (1):
      netfilter: Convert uses of __constant_<foo> to <foo>

Josh Hunt (1):
      netfilter: ipset: add forceadd kernel support for hash set types

Jozsef Kadlecsik (1):
      netfilter: ipset: Prepare the kernel for create option flags when no extension is needed

Pablo Neira Ayuso (3):
      netfilter: xt_ipcomp: Use ntohs to ease sparse warning
      netfilter: nf_tables: add optional user data area to rules
      Merge git://git.kernel.org/.../horms/ipvs-next

Patrick McHardy (10):
      netfilter: ip_set: rename nfnl_dereference()/nfnl_set()
      netfilter: nfnetlink: add rcu_dereference_protected() helpers
      netfilter: nf_tables: add nft_dereference() macro
      netfilter: nf_tables: accept QUEUE/DROP verdict parameters
      netfilter: nft_hash: bug fixes and resizing
      netfilter: nf_tables: clean up nf_tables_trans_add() argument order
      netfilter: nf_tables: restore context for expression destructors
      netfilter: nf_tables: restore notifications for anonymous set destruction
      netfilter: nft_ct: remove family from struct nft_ct
      netfilter: nft_nat: fix family validation

Sergey Popovich (1):
      netfilter: ipset: Follow manual page behavior for SET target on list:set

Tingwei Liu (1):
      ipvs: Reduce checkpatch noise in ip_vs_lblc.c

Vytas Dauksa (2):
      netfilter: ipset: add hash:ip,mark data type to ipset
      netfilter: ipset: add markmask for hash:ip,mark data type

stephen hemminger (1):
      netfilter: remove double colon

 include/linux/netfilter/ipset/ip_set.h       |   15 +-
 include/linux/netfilter/nfnetlink.h          |   21 ++
 include/net/netfilter/nf_conntrack.h         |   11 +-
 include/net/netfilter/nf_conntrack_core.h    |    9 +-
 include/net/netfilter/nf_conntrack_labels.h  |    4 +-
 include/net/netfilter/nf_tables.h            |   28 +-
 include/net/netns/conntrack.h                |   13 +-
 include/uapi/linux/netfilter/ipset/ip_set.h  |   12 +
 include/uapi/linux/netfilter/nf_tables.h     |    6 +-
 net/ipv4/netfilter.c                         |    2 +-
 net/netfilter/ipset/Kconfig                  |    9 +
 net/netfilter/ipset/Makefile                 |    1 +
 net/netfilter/ipset/ip_set_core.c            |   54 ++--
 net/netfilter/ipset/ip_set_hash_gen.h        |   43 +++
 net/netfilter/ipset/ip_set_hash_ip.c         |    3 +-
 net/netfilter/ipset/ip_set_hash_ipmark.c     |  321 +++++++++++++++++++
 net/netfilter/ipset/ip_set_hash_ipport.c     |    3 +-
 net/netfilter/ipset/ip_set_hash_ipportip.c   |    3 +-
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |    3 +-
 net/netfilter/ipset/ip_set_hash_net.c        |    3 +-
 net/netfilter/ipset/ip_set_hash_netiface.c   |    3 +-
 net/netfilter/ipset/ip_set_hash_netnet.c     |   10 +-
 net/netfilter/ipset/ip_set_hash_netport.c    |    3 +-
 net/netfilter/ipset/ip_set_hash_netportnet.c |    3 +-
 net/netfilter/ipset/pfxlen.c                 |    4 +-
 net/netfilter/ipvs/ip_vs_ctl.c               |    2 +-
 net/netfilter/ipvs/ip_vs_lblc.c              |   13 +-
 net/netfilter/nf_conntrack_core.c            |  432 ++++++++++++++++++--------
 net/netfilter/nf_conntrack_expect.c          |   36 ++-
 net/netfilter/nf_conntrack_h323_main.c       |    4 +-
 net/netfilter/nf_conntrack_helper.c          |   41 ++-
 net/netfilter/nf_conntrack_netlink.c         |  133 ++++----
 net/netfilter/nf_conntrack_sip.c             |    8 +-
 net/netfilter/nf_tables_api.c                |   80 +++--
 net/netfilter/nfnetlink.c                    |    8 +
 net/netfilter/nfnetlink_log.c                |    8 -
 net/netfilter/nft_compat.c                   |    4 +-
 net/netfilter/nft_ct.c                       |   36 ++-
 net/netfilter/nft_hash.c                     |  260 +++++++++++++---
 net/netfilter/nft_immediate.c                |    3 +-
 net/netfilter/nft_log.c                      |    3 +-
 net/netfilter/nft_lookup.c                   |    5 +-
 net/netfilter/nft_nat.c                      |   22 +-
 net/netfilter/xt_AUDIT.c                     |    4 +-
 net/netfilter/xt_connlimit.c                 |  311 ++++++++++++++----
 net/netfilter/xt_ipcomp.c                    |    2 +-
 46 files changed, 1527 insertions(+), 475 deletions(-)
 create mode 100644 net/netfilter/ipset/ip_set_hash_ipmark.c
