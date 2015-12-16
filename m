From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 06/12] batman-adv: update last seen field of single hop originators
Date: Wed, 16 Dec 2015 15:49:27 +0800
Message-ID: <1450252173-20949-7-git-send-email-antonio@meshcoding.com>
References: <1450252173-20949-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:8619 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933816AbbLPHvY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 02:51:24 -0500
In-Reply-To: <1450252173-20949-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 1efdb5c..3738a2f 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1379,6 +1379,7 @@ batadv_iv_ogm_process_per_outif(const struct sk_buff *skb, int ogm_offset,
 				struct batadv_hard_iface *if_outgoing)
 {
 	struct batadv_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
+	struct batadv_hardif_neigh_node *hardif_neigh = NULL;
 	struct batadv_neigh_node *router = NULL;
 	struct batadv_neigh_node *router_router = NULL;
 	struct batadv_orig_node *orig_neigh_node;
@@ -1423,6 +1424,13 @@ batadv_iv_ogm_process_per_outif(const struct sk_buff *skb, int ogm_offset,
 		goto out;
 	}
 
+	if (is_single_hop_neigh) {
+		hardif_neigh = batadv_hardif_neigh_get(if_incoming,
+						       ethhdr->h_source);
+		if (hardif_neigh)
+			hardif_neigh->last_seen = jiffies;
+	}
+
 	router = batadv_orig_router_get(orig_node, if_outgoing);
 	if (router) {
 		router_router = batadv_orig_router_get(router->orig_node,
@@ -1557,6 +1565,8 @@ out:
 		batadv_neigh_node_free_ref(router_router);
 	if (orig_neigh_router)
 		batadv_neigh_node_free_ref(orig_neigh_router);
+	if (hardif_neigh)
+		batadv_hardif_neigh_free_ref(hardif_neigh);
 
 	kfree_skb(skb_priv);
 }
-- 
2.6.4
