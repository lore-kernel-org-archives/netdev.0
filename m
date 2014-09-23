From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/5] nf pull request for net
Date: Tue, 23 Sep 2014 11:24:43 +0200
Message-ID: <1411464288-18069-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

This series contains netfilter fixes for net, they are:

1) Fix lockdep splat in nft_hash when releasing sets from the
   rcu_callback context. We don't the mutex there anymore.

2) Remove unnecessary spinlock_bh in the destroy path of the nf_tables
   rbtree set type from rcu_callback context.

3) Fix another lockdep splat in rhashtable. None of the callers hold
   a mutex when calling rhashtable_destroy.

4) Fix duplicated error reporting from nfnetlink when aborting and
   replaying a batch.

5) Fix a Kconfig issue reported by kbuild robot.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit bec6bfb2437f4676dbaaacba6019e9dafef18962:

  amd-xgbe: Fix initialization of the wrong spin lock (2014-09-02 14:03:37 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 679ab4ddbdfab8af39104e63819db71f428aefd9:

  netfilter: xt_TPROXY: undefined reference to `udp6_lib_lookup' (2014-09-07 17:25:16 +0200)

----------------------------------------------------------------
Pablo Neira Ayuso (5):
      netfilter: nft_hash: no need for rcu in the hash set destroy path
      netfilter: nft_rbtree: no need for spinlock from set destroy path
      rhashtable: fix lockdep splat in rhashtable_destroy()
      netfilter: nfnetlink: deliver netlink errors on batch completion
      netfilter: xt_TPROXY: undefined reference to `udp6_lib_lookup'

 lib/rhashtable.c           |    8 +++---
 net/netfilter/Kconfig      |    1 +
 net/netfilter/nfnetlink.c  |   64 +++++++++++++++++++++++++++++++++++++++++++-
 net/netfilter/nft_hash.c   |   12 +++++----
 net/netfilter/nft_rbtree.c |    2 --
 5 files changed, 75 insertions(+), 12 deletions(-)
