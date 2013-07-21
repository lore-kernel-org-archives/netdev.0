From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next] ip6mr: change the prototype of ip6_mr_forward().
Date: Sun, 21 Jul 2013 03:00:31 +0300
Message-ID: <1374364831-13190-1-git-send-email-ramirose@gmail.com>
Cc: nicolas.dichtel@6wind.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:61830 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754971Ab3GTVAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jul 2013 17:00:46 -0400
Received: by mail-ee0-f53.google.com with SMTP id c41so3044049eek.26
        for <netdev@vger.kernel.org>; Sat, 20 Jul 2013 14:00:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the prototpye of the ip6_mr_forward() method to return void
instead of int.

The ip6_mr_forward() method always returns 0; moreover, the return value of this
method is not checked anywhere.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 net/ipv6/ip6mr.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 583e8d4..6d78615 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -110,8 +110,8 @@ static struct kmem_cache *mrt_cachep __read_mostly;
 static struct mr6_table *ip6mr_new_table(struct net *net, u32 id);
 static void ip6mr_free_table(struct mr6_table *mrt);
 
-static int ip6_mr_forward(struct net *net, struct mr6_table *mrt,
-			  struct sk_buff *skb, struct mfc6_cache *cache);
+static void ip6_mr_forward(struct net *net, struct mr6_table *mrt,
+			   struct sk_buff *skb, struct mfc6_cache *cache);
 static int ip6mr_cache_report(struct mr6_table *mrt, struct sk_buff *pkt,
 			      mifi_t mifi, int assert);
 static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
@@ -2069,8 +2069,8 @@ static int ip6mr_find_vif(struct mr6_table *mrt, struct net_device *dev)
 	return ct;
 }
 
-static int ip6_mr_forward(struct net *net, struct mr6_table *mrt,
-			  struct sk_buff *skb, struct mfc6_cache *cache)
+static void ip6_mr_forward(struct net *net, struct mr6_table *mrt,
+			   struct sk_buff *skb, struct mfc6_cache *cache)
 {
 	int psend = -1;
 	int vif, ct;
@@ -2151,12 +2151,11 @@ forward:
 last_forward:
 	if (psend != -1) {
 		ip6mr_forward2(net, mrt, skb, cache, psend);
-		return 0;
+		return;
 	}
 
 dont_forward:
 	kfree_skb(skb);
-	return 0;
 }
 
 
-- 
1.8.1.4
