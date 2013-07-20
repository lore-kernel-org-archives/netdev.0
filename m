From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH v3 net-next] ipmr: change the prototype of ip_mr_forward().
Date: Sat, 20 Jul 2013 15:09:28 +0300
Message-ID: <1374322168-5115-1-git-send-email-ramirose@gmail.com>
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:55970 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308Ab3GTJJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jul 2013 05:09:45 -0400
Received: by mail-ee0-f48.google.com with SMTP id b47so2801582eek.35
        for <netdev@vger.kernel.org>; Sat, 20 Jul 2013 02:09:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the prototpye of the ip_mr_forward() method to return void
instead of int.

The ip_mr_forward() method always returns 0; moreover, the return value of this
method is not checked anywhere.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 net/ipv4/ipmr.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 132a096..bacc0bc 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -127,9 +127,9 @@ static struct kmem_cache *mrt_cachep __read_mostly;
 static struct mr_table *ipmr_new_table(struct net *net, u32 id);
 static void ipmr_free_table(struct mr_table *mrt);
 
-static int ip_mr_forward(struct net *net, struct mr_table *mrt,
-			 struct sk_buff *skb, struct mfc_cache *cache,
-			 int local);
+static void ip_mr_forward(struct net *net, struct mr_table *mrt,
+			  struct sk_buff *skb, struct mfc_cache *cache,
+			  int local);
 static int ipmr_cache_report(struct mr_table *mrt,
 			     struct sk_buff *pkt, vifi_t vifi, int assert);
 static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
@@ -1795,9 +1795,9 @@ static int ipmr_find_vif(struct mr_table *mrt, struct net_device *dev)
 
 /* "local" means that we should preserve one skb (for local delivery) */
 
-static int ip_mr_forward(struct net *net, struct mr_table *mrt,
-			 struct sk_buff *skb, struct mfc_cache *cache,
-			 int local)
+static void ip_mr_forward(struct net *net, struct mr_table *mrt,
+			  struct sk_buff *skb, struct mfc_cache *cache,
+			  int local)
 {
 	int psend = -1;
 	int vif, ct;
@@ -1903,14 +1903,13 @@ last_forward:
 				ipmr_queue_xmit(net, mrt, skb2, cache, psend);
 		} else {
 			ipmr_queue_xmit(net, mrt, skb, cache, psend);
-			return 0;
+			return;
 		}
 	}
 
 dont_forward:
 	if (!local)
 		kfree_skb(skb);
-	return 0;
 }
 
 static struct mr_table *ipmr_rt_fib_lookup(struct net *net, struct sk_buff *skb)
-- 
1.8.1.4
