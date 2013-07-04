From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next] ipmr: change the prototype of ip_mr_forward().
Date: Thu,  4 Jul 2013 21:24:35 +0300
Message-ID: <1372962275-29138-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com,
	Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:58022 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838Ab3GDPYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 11:24:49 -0400
Received: by mail-wi0-f170.google.com with SMTP id ey16so7451828wid.3
        for <netdev@vger.kernel.org>; Thu, 04 Jul 2013 08:24:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the prototpye of the ip_mr_forward() method to return void
instead of int.

The ip_mr_forward() method always returns 0; moreover, the retun value
of this method is not checked anywhere.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 net/ipv4/ipmr.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 132a096..eca2742 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -127,7 +127,7 @@ static struct kmem_cache *mrt_cachep __read_mostly;
 static struct mr_table *ipmr_new_table(struct net *net, u32 id);
 static void ipmr_free_table(struct mr_table *mrt);
 
-static int ip_mr_forward(struct net *net, struct mr_table *mrt,
+static void ip_mr_forward(struct net *net, struct mr_table *mrt,
 			 struct sk_buff *skb, struct mfc_cache *cache,
 			 int local);
 static int ipmr_cache_report(struct mr_table *mrt,
@@ -1795,7 +1795,7 @@ static int ipmr_find_vif(struct mr_table *mrt, struct net_device *dev)
 
 /* "local" means that we should preserve one skb (for local delivery) */
 
-static int ip_mr_forward(struct net *net, struct mr_table *mrt,
+static void ip_mr_forward(struct net *net, struct mr_table *mrt,
 			 struct sk_buff *skb, struct mfc_cache *cache,
 			 int local)
 {
@@ -1903,14 +1903,14 @@ last_forward:
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
+	return;
 }
 
 static struct mr_table *ipmr_rt_fib_lookup(struct net *net, struct sk_buff *skb)
-- 
1.8.1.4
