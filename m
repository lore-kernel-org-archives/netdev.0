From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/13] netfilter fixes for net
Date: Wed, 18 Jun 2014 11:44:26 +0200
Message-ID: <1403084679-11227-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains netfilter updates for your net tree,
they are:

1) Fix refcount leak when dumping the dying/unconfirmed conntrack lists,
   from Florian Westphal.

2) Fix crash in NAT when removing a netnamespace, also from Florian.

3) Fix a crash in IPVS when trying to remove an estimator out of the
   sysctl scope, from Julian Anastasov.

4) Add zone attribute to the routing to calculate the message size in
   ctnetlink events, from Ken-ichirou MATSUZAWA.

5) Another fix for the dying/unconfirmed list which was preventing to
   dump more than one memory page of entries (~17 entries in x86_64).

6) Fix missing RCU-safe list insertion in the rule replacement code
   in nf_tables.

7) Since the new transaction infrastructure is in place, we have to
   upgrade the chain use counter from u16 to u32 to avoid overflow
   after more than 2^16 rules are added.

8) Fix refcount leak when replacing rule in nf_tables. This problem
   was also introduced in new transaction.

9) Call the ->destroy() callback when releasing nft-xt rules to fix
   module refcount leaks.

10) Set the family in the netlink messages that contain set elements
    in nf_tables to make it consistent with other object types.

11) Don't dump NAT port information if it is unset in nft_nat.

12) Update the MAINTAINERS file, I have merged the ebtables entry
    into netfilter. While at it, also removed the netfilter users
    mailing list, the development list should be enough.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 7171511eaec5bf23fb06078f59784a3a0626b38f:

  Linux 3.16-rc1 (2014-06-15 17:45:28 -1000)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to db9cf3a345d310bd459f369e8fa5f039076293f2:

  MAINTAINERS: merge ebtables into netfilter entry (2014-06-18 11:27:03 +0200)

----------------------------------------------------------------
Florian Westphal (2):
      netfilter: ctnetlink: fix refcnt leak in dying/unconfirmed list dumper
      netfilter: nf_nat: fix oops on netns removal

Julian Anastasov (1):
      ipvs: stop tot_stats estimator only under CONFIG_SYSCTL

Ken-ichirou MATSUZAWA (1):
      netfilter: ctnetlink: add zone size to length

Pablo Neira Ayuso (10):
      netfilter: ctnetlink: fix dumping of dying/unconfirmed conntracks
      netfilter: nf_tables: use RCU-safe list insertion when replacing rules
      netfilter: nf_tables: use u32 for chain use counter
      netfilter: nf_tables: decrement chain use counter when replacing rules
      netfilter: nf_tables: fix wrong type in transaction when replacing rules
      netfilter: nft_compat: call {target, match}->destroy() to cleanup entry
      netfilter: nf_tables: indicate family when dumping set elements
      netfilter: nft_nat: don't dump port information if unset
      Merge branch 'ipvs'
      MAINTAINERS: merge ebtables into netfilter entry

 MAINTAINERS                          |   11 +----------
 include/net/netfilter/nf_tables.h    |    6 +++---
 net/netfilter/ipvs/ip_vs_ctl.c       |    2 +-
 net/netfilter/nf_conntrack_netlink.c |   20 ++++++++++++-------
 net/netfilter/nf_nat_core.c          |   35 +++++++++++++++++++++++++++++++++-
 net/netfilter/nf_tables_api.c        |   11 ++++++++---
 net/netfilter/nft_compat.c           |   18 +++++++++++++++++
 net/netfilter/nft_nat.c              |   14 ++++++++------
 8 files changed, 86 insertions(+), 31 deletions(-)
