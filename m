From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 20/36] net,rcu: convert call_rcu(netlbl_unlhsh_free_addr4)
 to kfree_rcu()
Date: Fri, 18 Mar 2011 12:03:56 +0800
Message-ID: <4D82D9AC.30205@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>, Paul Moore <paul.moore@hp.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-ke
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



The rcu callback netlbl_unlhsh_free_addr4() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(netlbl_unlhsh_free_addr4).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 net/netlabel/netlabel_unlabeled.c |   20 +-------------------
 1 files changed, 1 insertions(+), 19 deletions(-)

diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index e2b0a68..4e5ad90 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -153,24 +153,6 @@ static const struct nla_policy netlbl_unlabel_genl_policy[NLBL_UNLABEL_A_MAX + 1
  * Unlabeled Connection Hash Table Functions
  */
 
-/**
- * netlbl_unlhsh_free_addr4 - Frees an IPv4 address entry from the hash table
- * @entry: the entry's RCU field
- *
- * Description:
- * This function is designed to be used as a callback to the call_rcu()
- * function so that memory allocated to a hash table address entry can be
- * released safely.
- *
- */
-static void netlbl_unlhsh_free_addr4(struct rcu_head *entry)
-{
-	struct netlbl_unlhsh_addr4 *ptr;
-
-	ptr = container_of(entry, struct netlbl_unlhsh_addr4, rcu);
-	kfree(ptr);
-}
-
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 /**
  * netlbl_unlhsh_free_addr6 - Frees an IPv6 address entry from the hash table
@@ -568,7 +550,7 @@ static int netlbl_unlhsh_remove_addr4(struct net *net,
 	if (entry == NULL)
 		return -ENOENT;
 
-	call_rcu(&entry->rcu, netlbl_unlhsh_free_addr4);
+	kfree_rcu(entry, rcu);
 	return 0;
 }
 
-- 
1.7.4
