From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 6/7] batman-adv: Remove one condition check in batadv_route_unicast_packet
Date: Thu, 26 Jan 2017 17:44:03 +0100
Message-ID: <20170126164404.16074-7-sw@simonwunderlich.de>
References: <20170126164404.16074-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Gao Feng <gfree.wind@gmail.com>,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:54086 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752605AbdAZQoR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 11:44:17 -0500
In-Reply-To: <20170126164404.16074-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@gmail.com>

It could decrease one condition check to collect some statements in the
first condition block.

Signed-off-by: Gao Feng <gfree.wind@gmail.com>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/routing.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 5f050fbdfff7..7fd740b6e36d 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -719,20 +719,19 @@ static int batadv_route_unicast_packet(struct sk_buff *skb,
 
 	len = skb->len;
 	res = batadv_send_skb_to_orig(skb, orig_node, recv_if);
-	if (res == NET_XMIT_SUCCESS)
-		ret = NET_RX_SUCCESS;
-
-	/* skb was consumed */
-	skb = NULL;
 
 	/* translate transmit result into receive result */
 	if (res == NET_XMIT_SUCCESS) {
+		ret = NET_RX_SUCCESS;
 		/* skb was transmitted and consumed */
 		batadv_inc_counter(bat_priv, BATADV_CNT_FORWARD);
 		batadv_add_counter(bat_priv, BATADV_CNT_FORWARD_BYTES,
 				   len + ETH_HLEN);
 	}
 
+	/* skb was consumed */
+	skb = NULL;
+
 put_orig_node:
 	batadv_orig_node_put(orig_node);
 free_skb:
-- 
2.11.0
