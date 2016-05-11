From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 11 May 2016 10:11:01 +1000
Message-ID: <20160511101101.2bf6e5ef@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/netfilter/nf_conntrack_core.c

between commit:

  70d72b7e060e ("netfilter: conntrack: init all_locks to avoid debug warning")

from the net tree and commit:

  a3efd81205b1 ("netfilter: conntrack: move generation seqcnt out of netns_ct")
  56d52d4892d0 ("netfilter: conntrack: use a single hashtable for all namespaces")
  0c5366b3a8c7 ("netfilter: conntrack: use single slab cache")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc net/netfilter/nf_conntrack_core.c
index 895d11dced3c,566c64e3ec50..000000000000
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@@ -66,7 -69,12 +69,12 @@@ EXPORT_SYMBOL_GPL(nf_conntrack_locks)
  __cacheline_aligned_in_smp DEFINE_SPINLOCK(nf_conntrack_expect_lock);
  EXPORT_SYMBOL_GPL(nf_conntrack_expect_lock);
  
+ struct hlist_nulls_head *nf_conntrack_hash __read_mostly;
+ EXPORT_SYMBOL_GPL(nf_conntrack_hash);
+ 
+ static __read_mostly struct kmem_cache *nf_conntrack_cachep;
 -static __read_mostly spinlock_t nf_conntrack_locks_all_lock;
 +static __read_mostly DEFINE_SPINLOCK(nf_conntrack_locks_all_lock);
+ static __read_mostly seqcount_t nf_conntrack_generation;
  static __read_mostly bool nf_conntrack_locks_all;
  
  void nf_conntrack_lock(spinlock_t *lock) __acquires(lock)
