From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 01/16] batman-adv: use check_unicast_packet() in recv_roam_adv()
Date: Mon, 29 Oct 2012 09:58:02 +0100
Message-ID: <1351501097-1289-2-git-send-email-ordex@autistici.org>
References: <1351501097-1289-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:54040 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664Ab2J2I66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 04:58:58 -0400
In-Reply-To: <1351501097-1289-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To avoid code duplication and to simplify further changes,
check_unicast_packet() is now used in recv_roam_adv() to check for not
well formed packets and so discard them.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/routing.c | 15 +--------------
 1 file changed, 1 insertion(+), 14 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 376b4cc..8bdafc8 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -687,21 +687,8 @@ int batadv_recv_roam_adv(struct sk_buff *skb, struct batadv_hard_iface *recv_if)
 	struct batadv_priv *bat_priv = netdev_priv(recv_if->soft_iface);
 	struct batadv_roam_adv_packet *roam_adv_packet;
 	struct batadv_orig_node *orig_node;
-	struct ethhdr *ethhdr;
 
-	/* drop packet if it has not necessary minimum size */
-	if (unlikely(!pskb_may_pull(skb,
-				    sizeof(struct batadv_roam_adv_packet))))
-		goto out;
-
-	ethhdr = (struct ethhdr *)skb_mac_header(skb);
-
-	/* packet with unicast indication but broadcast recipient */
-	if (is_broadcast_ether_addr(ethhdr->h_dest))
-		goto out;
-
-	/* packet with broadcast sender address */
-	if (is_broadcast_ether_addr(ethhdr->h_source))
+	if (batadv_check_unicast_packet(skb, sizeof(*roam_adv_packet)) < 0)
 		goto out;
 
 	batadv_inc_counter(bat_priv, BATADV_CNT_TT_ROAM_ADV_RX);
-- 
1.7.12.4
