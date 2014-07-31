From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/9] Netfilter updates for net-next
Date: Thu, 31 Jul 2014 21:26:59 +0200
Message-ID: <1406834828-8500-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains netfilter updates for net-next, they are:

1) Add the reject expression for the nf_tables bridge family, this
   allows us to send explicit reject (TCP RST / ICMP dest unrech) to
   the packets matching a rule.

2) Simplify and consolidate the nf_tables set dumping logic. This uses
   netlink control->data to filter out depending on the request.

3) Perform garbage collection in xt_hashlimit using a workqueue instead
   of a timer, which is problematic when many entries are in place in
   the tables, from Eric Dumazet.

4) Remove leftover code from the removed ulog target support, from
   Paul Bolle.

5) Dump unmodified flags in the netfilter packet accounting when resetting
   counters, so userspace knows that a counter was in overquota situation,
   from Alexey Perevalov.

6) Fix wrong usage of the bitwise functions in nfnetlink_acct, also from
   Alexey.

7) Fix a crash when adding new set element with an empty NFTA_SET_ELEM_LIST
   attribute.

This patchset also includes a couple of cleanups for xt_LED from
Duan Jiong and for nf_conntrack_ipv4 (using coccinelle) from
Himangi Saraogi.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 8fd90bb889635fa1e7f80a3950948cc2e74c1446:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2014-07-22 00:44:59 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 7d5570ca8972aad58de0b4ad03a5e991c41d4ce2:

  netfilter: nf_tables: check for unset NFTA_SET_ELEM_LIST_ELEMENTS attribute (2014-07-31 21:11:43 +0200)

----------------------------------------------------------------
Alexey Perevalov (2):
      netfilter: nfnetlink_acct: dump unmodified nfacct flags
      netfilter: nfnetlink_acct: avoid using NFACCT_F_OVERQUOTA with bit helper functions

Duan Jiong (1):
      netfilter: xt_LED: don't output error message redundantly

Eric Dumazet (1):
      netfilter: xt_hashlimit: perform garbage collection from process context

Himangi Saraogi (1):
      netfilter: nf_conntrack: remove exceptional & on function name

Pablo Neira Ayuso (3):
      netfilter: bridge: add reject support
      netfilter: nf_tables: simplify set dump through netlink
      netfilter: nf_tables: check for unset NFTA_SET_ELEM_LIST_ELEMENTS attribute

Paul Bolle (1):
      netfilter: kill remnants of ulog targets

 include/net/netns/x_tables.h                   |    6 --
 net/bridge/netfilter/Kconfig                   |    6 ++
 net/bridge/netfilter/Makefile                  |    2 +-
 net/bridge/netfilter/nft_reject_bridge.c       |   67 ++++++++++++
 net/ipv4/netfilter/Makefile                    |    1 -
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    2 +-
 net/netfilter/nf_tables_api.c                  |  137 ++++++------------------
 net/netfilter/nfnetlink_acct.c                 |   12 ++-
 net/netfilter/xt_LED.c                         |    4 +-
 net/netfilter/xt_hashlimit.c                   |   31 +++---
 10 files changed, 133 insertions(+), 135 deletions(-)
 create mode 100644 net/bridge/netfilter/nft_reject_bridge.c
