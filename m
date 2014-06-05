From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/6] Netfilter/nf_tables fixes for net-next
Date: Thu,  5 Jun 2014 17:08:20 +0200
Message-ID: <1401980906-25290-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

This patchset contains fixes for recent updates available in your
net-next, they are:

1) Fix double memory allocation for accounting objects that results
   in a leak, this slipped through with the new quota extension,
   patch from Mathieu Poirier.

2) Fix broken ordering when adding set element transactions.

3) Make sure that objects are released in reverse order in the abort
   path, to avoid possible use-after-free when accessing dependencies.

4) Allow to delete several objects (as long as dependencies are
   fulfilled) by using one batch. This includes changes in the use
   counter semantics of the nf_tables objects.

5) Fix illegal sleeping allocation from rcu callback.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 96b2e73c5471542cb9c622c4360716684f8797ed:

  Revert "net/mlx4_en: Use affinity hint" (2014-06-02 00:18:48 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 31f8441c328b1c038c3e44bec740fb29393a56ad:

  netfilter: nf_tables: atomic allocation in set notifications from rcu callback (2014-06-02 10:54:38 +0200)

----------------------------------------------------------------
Mathieu Poirier (1):
      netfilter: nfnetlink_acct: Fix memory leak

Pablo Neira Ayuso (5):
      netfilter: nf_tables: fix wrong transaction ordering in set elements
      netfilter: nf_tables: release objects in reverse order in the abort path
      netfilter: nft_rbtree: introduce locking
      netfilter: nf_tables: allow to delete several objects from a batch
      netfilter: nf_tables: atomic allocation in set notifications from rcu callback

 net/netfilter/nf_tables_api.c  |   59 ++++++++++++++++++++++++++++------------
 net/netfilter/nfnetlink_acct.c |    1 -
 net/netfilter/nft_rbtree.c     |   22 ++++++++++++++-
 3 files changed, 62 insertions(+), 20 deletions(-)
