From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 16/16] batman-adv: Don't leak information through uninitialized packet fields
Date: Mon,  2 Jul 2012 01:43:46 +0200
Message-ID: <1341186226-10549-17-git-send-email-ordex@autistici.org>
References: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:23583 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752177Ab2GAXnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 19:43:45 -0400
In-Reply-To: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The reserved fields in batman-adv packets are not set to a constant value. The
content of these memory regions is leaked unintentionally to the network.

This regression was introduced in 3b27ffb00fbe9d9189715ea13ce8712e2f0cb0c5

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/soft-interface.c    |    1 +
 net/batman-adv/translation-table.c |    1 +
 net/batman-adv/vis.c               |    2 ++
 3 files changed, 4 insertions(+)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index b7c655c..9e4bb61 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -214,6 +214,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 
 		/* batman packet type: broadcast */
 		bcast_packet->header.packet_type = BATADV_BCAST;
+		bcast_packet->reserved = 0;
 
 		/* hw address of first interface is the orig mac because only
 		 * this mac is known throughout the mesh
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 245cc9a..a438f4b 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -2052,6 +2052,7 @@ static void batadv_send_roam_adv(struct batadv_priv *bat_priv, uint8_t *client,
 	roam_adv_packet->header.packet_type = BATADV_ROAM_ADV;
 	roam_adv_packet->header.version = BATADV_COMPAT_VERSION;
 	roam_adv_packet->header.ttl = BATADV_TTL;
+	roam_adv_packet->reserved = 0;
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index f09cc9a..2a2ea06 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -589,6 +589,7 @@ static int batadv_generate_vis_packet(struct batadv_priv *bat_priv)
 	packet->header.ttl = BATADV_TTL;
 	packet->seqno = htonl(ntohl(packet->seqno) + 1);
 	packet->entries = 0;
+	packet->reserved = 0;
 	skb_trim(info->skb_packet, sizeof(*packet));
 
 	if (packet->vis_type == BATADV_VIS_TYPE_CLIENT_UPDATE) {
@@ -890,6 +891,7 @@ int batadv_vis_init(struct batadv_priv *bat_priv)
 	packet->header.packet_type = BATADV_VIS;
 	packet->header.ttl = BATADV_TTL;
 	packet->seqno = 0;
+	packet->reserved = 0;
 	packet->entries = 0;
 
 	INIT_LIST_HEAD(&bat_priv->vis_send_list);
-- 
1.7.9.4
