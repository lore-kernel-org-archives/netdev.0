From: fgao@ikuai8.com
Subject: [PATCH net-next 2/2] net: batman-adv: Remove one condition check in batadv_route_unicast_packet
Date: Mon, 21 Nov 2016 23:01:09 +0800
Message-ID: <1479740469-3797-1-git-send-email-fgao@ikuai8.com>
To: mareklindner@neomailbox.ch, sw@simonwunderlich.de, a@unstable.cc,
        davem@davemloft.net, b.a.t.m.a.n@lists.open-mesh.org,
        netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg278.qq.com ([113.108.11.203]:41253 "EHLO smtpbg278.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754678AbcKUPBu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 10:01:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@gmail.com>

It could decrease one condition check to collect some statements in the
first condition block.

Signed-off-by: Gao Feng <gfree.wind@gmail.com>
---
 net/batman-adv/routing.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 6b08b26..9d657cf 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -719,20 +719,18 @@ static int batadv_route_unicast_packet(struct sk_buff *skb,
 
 	len = skb->len;
 	res = batadv_send_skb_to_orig(skb, orig_node, recv_if);
-	if (res == NET_XMIT_SUCCESS || res == NET_XMIT_CN)
-		ret = NET_RX_SUCCESS;
-
-	/* skb was consumed */
-	skb = NULL;
-
 	/* translate transmit result into receive result */
 	if (res == NET_XMIT_SUCCESS || res == NET_XMIT_CN) {
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
1.9.1
