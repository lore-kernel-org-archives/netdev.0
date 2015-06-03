From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 02/12] batman-adv: iv_ogm_queue_add, Simplify expressions
Date: Wed,  3 Jun 2015 16:13:58 +0200
Message-ID: <1433340848-1682-3-git-send-email-antonio@meshcoding.com>
References: <1433340848-1682-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Markus Pargmann <mpa@pengutronix.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:41977 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932588AbbFCOQN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 10:16:13 -0400
In-Reply-To: <1433340848-1682-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Pargmann <mpa@pengutronix.de>

Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 190a642..159f30a 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -750,13 +750,13 @@ static void batadv_iv_ogm_queue_add(struct batadv_priv *bat_priv,
 	unsigned long max_aggregation_jiffies;
 
 	batadv_ogm_packet = (struct batadv_ogm_packet *)packet_buff;
-	direct_link = batadv_ogm_packet->flags & BATADV_DIRECTLINK ? 1 : 0;
+	direct_link = !!(batadv_ogm_packet->flags & BATADV_DIRECTLINK);
 	max_aggregation_jiffies = msecs_to_jiffies(BATADV_MAX_AGGREGATION_MS);
 
 	/* find position for the packet in the forward queue */
 	spin_lock_bh(&bat_priv->forw_bat_list_lock);
 	/* own packets are not to be aggregated */
-	if ((atomic_read(&bat_priv->aggregated_ogms)) && (!own_packet)) {
+	if (atomic_read(&bat_priv->aggregated_ogms) && !own_packet) {
 		hlist_for_each_entry(forw_packet_pos,
 				     &bat_priv->forw_bat_list, list) {
 			if (batadv_iv_ogm_can_aggregate(batadv_ogm_packet,
-- 
2.4.2
