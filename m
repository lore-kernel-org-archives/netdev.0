From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 04/36] net,rcu: convert call_rcu(__leaf_info_free_rcu) to
 kfree_rcu()
Date: Fri, 18 Mar 2011 11:42:34 +0800
Message-ID: <4D82D4AA.2080601__32676.7804021531$1300419667$gmane$org@cn.fujitsu.com>
References: <4D82D071.5020703@cn.fujitsu.com> <4D82D3FF.2080303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>,
	Robert Love <robert.w.love@intel.com>,
	"James E.J. Bottomley" <James.Bottom
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60266 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932090Ab1CRDkw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2011 23:40:52 -0400
In-Reply-To: <4D82D3FF.2080303@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The rcu callback __leaf_info_free_rcu() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(__leaf_info_free_rcu).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 net/ipv4/fib_trie.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 0f28034..6a60915 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -350,14 +350,9 @@ static inline void free_leaf(struct leaf *l)
 	call_rcu_bh(&l->rcu, __leaf_free_rcu);
 }
 
-static void __leaf_info_free_rcu(struct rcu_head *head)
-{
-	kfree(container_of(head, struct leaf_info, rcu));
-}
-
 static inline void free_leaf_info(struct leaf_info *leaf)
 {
-	call_rcu(&leaf->rcu, __leaf_info_free_rcu);
+	kfree_rcu(leaf, rcu);
 }
 
 static struct tnode *tnode_alloc(size_t size)
-- 
1.7.4
