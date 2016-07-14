From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 1/4] net: bridge: minor style adjustments in br_handle_frame_finish
Date: Thu, 14 Jul 2016 06:09:59 +0300
Message-ID: <1468465802-4571-2-git-send-email-nikolay@cumulusnetworks.com>
References: <1468465802-4571-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	davem@davemloft.net, bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33516 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175AbcGNSDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 14:03:53 -0400
Received: by mail-pf0-f180.google.com with SMTP id y134so6275102pfg.0
        for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 11:03:53 -0700 (PDT)
In-Reply-To: <1468465802-4571-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trivial style changes in br_handle_frame_finish.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_input.c | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index a7817e6f306f..0b6d32619468 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -131,11 +131,11 @@ static void br_do_proxy_arp(struct sk_buff *skb, struct net_bridge *br,
 /* note: already called with rcu_read_lock */
 int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	const unsigned char *dest = eth_hdr(skb)->h_dest;
 	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
-	struct net_bridge *br;
-	struct net_bridge_fdb_entry *dst;
+	const unsigned char *dest = eth_hdr(skb)->h_dest;
+	struct net_bridge_fdb_entry *dst = NULL;
 	struct net_bridge_mdb_entry *mdst;
+	struct net_bridge *br;
 	struct sk_buff *skb2;
 	bool unicast = true;
 	u16 vid = 0;
@@ -166,8 +166,6 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 	if (br->dev->flags & IFF_PROMISC)
 		skb2 = skb;
 
-	dst = NULL;
-
 	if (IS_ENABLED(CONFIG_INET) && skb->protocol == htons(ETH_P_ARP))
 		br_do_proxy_arp(skb, br, vid, p);
 
@@ -185,13 +183,12 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 			skb = NULL;
 			if (!skb2)
 				goto out;
-		} else
+		} else {
 			skb2 = skb;
-
+		}
 		unicast = false;
 		br->dev->stats.multicast++;
-	} else if ((dst = __br_fdb_get(br, dest, vid)) &&
-			dst->is_local) {
+	} else if ((dst = __br_fdb_get(br, dest, vid)) && dst->is_local) {
 		skb2 = skb;
 		/* Do not forward the packet since it's local. */
 		skb = NULL;
@@ -201,8 +198,9 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 		if (dst) {
 			dst->used = jiffies;
 			br_forward(dst->dst, skb, skb2);
-		} else
+		} else {
 			br_flood_forward(br, skb, skb2, unicast);
+		}
 	}
 
 	if (skb2)
-- 
2.4.3
