From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 02/17] batman-adv: Remove hdr_size skb size check in batadv_interface_rx
Date: Wed, 11 May 2016 03:29:50 +0800
Message-ID: <1462908605-27412-3-git-send-email-a@unstable.cc>
References: <1462908605-27412-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:6545 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751989AbcEJTa6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 15:30:58 -0400
In-Reply-To: <1462908605-27412-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The callers of batadv_interface_rx have to make sure that enough data can
be pulled from the skb when they read the batman-adv header. The only two
functions using it are either calling pskb_may_pull with hdr_size directly
(batadv_recv_bcast_packet) or indirectly via batadv_check_unicast_packet
(batadv_recv_unicast_packet).

Reported-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/soft-interface.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index dc9a61a5122d..d72f88707736 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -413,10 +413,6 @@ void batadv_interface_rx(struct net_device *soft_iface,
 	batadv_bcast_packet = (struct batadv_bcast_packet *)skb->data;
 	is_bcast = (batadv_bcast_packet->packet_type == BATADV_BCAST);
 
-	/* check if enough space is available for pulling, and pull */
-	if (!pskb_may_pull(skb, hdr_size))
-		goto dropped;
-
 	skb_pull_rcsum(skb, hdr_size);
 	skb_reset_mac_header(skb);
 
-- 
2.8.2
