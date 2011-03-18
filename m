From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 21/36] net,rcu: convert call_rcu(netlbl_unlhsh_free_addr6)
 to kfree_rcu()
Date: Fri, 18 Mar 2011 12:04:50 +0800
Message-ID: <4D82D9E2.4000408@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>, Paul Moore <paul.moore@hp.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-ke
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52306 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750926Ab1CREDD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2011 00:03:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The rcu callback netlbl_unlhsh_free_addr6() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(netlbl_unlhsh_free_addr6).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 net/netlabel/netlabel_unlabeled.c |   22 +---------------------
 1 files changed, 1 insertions(+), 21 deletions(-)

diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 4e5ad90..9c38658 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -153,26 +153,6 @@ static const struct nla_policy netlbl_unlabel_genl_policy[NLBL_UNLABEL_A_MAX + 1
  * Unlabeled Connection Hash Table Functions
  */
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-/**
- * netlbl_unlhsh_free_addr6 - Frees an IPv6 address entry from the hash table
- * @entry: the entry's RCU field
- *
- * Description:
- * This function is designed to be used as a callback to the call_rcu()
- * function so that memory allocated to a hash table address entry can be
- * released safely.
- *
- */
-static void netlbl_unlhsh_free_addr6(struct rcu_head *entry)
-{
-	struct netlbl_unlhsh_addr6 *ptr;
-
-	ptr = container_of(entry, struct netlbl_unlhsh_addr6, rcu);
-	kfree(ptr);
-}
-#endif /* IPv6 */
-
 /**
  * netlbl_unlhsh_free_iface - Frees an interface entry from the hash table
  * @entry: the entry's RCU field
@@ -611,7 +591,7 @@ static int netlbl_unlhsh_remove_addr6(struct net *net,
 	if (entry == NULL)
 		return -ENOENT;
 
-	call_rcu(&entry->rcu, netlbl_unlhsh_free_addr6);
+	kfree_rcu(entry, rcu);
 	return 0;
 }
 #endif /* IPv6 */
-- 
1.7.4
