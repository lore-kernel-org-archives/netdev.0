From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 17/20] batman-adv: Prefix routing local static functions with batadv_
Date: Mon, 25 Jun 2012 08:54:41 +0200
Message-ID: <1340607284-29950-18-git-send-email-ordex@autistici.org>
References: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:30541 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754793Ab2FYGyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 02:54:52 -0400
In-Reply-To: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

All non-static symbols of batman-adv were prefixed with batadv_ to avoid
collisions with other symbols of the kernel. Other symbols of batman-adv
should use the same prefix to keep the naming scheme consistent.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/routing.c |   65 ++++++++++++++++++++++++----------------------
 1 file changed, 34 insertions(+), 31 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 57ff851..e7ee40d 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -29,8 +29,8 @@
 #include "unicast.h"
 #include "bridge_loop_avoidance.h"
 
-static int route_unicast_packet(struct sk_buff *skb,
-				struct hard_iface *recv_if);
+static int batadv_route_unicast_packet(struct sk_buff *skb,
+				       struct hard_iface *recv_if);
 
 void batadv_slide_own_bcast_window(struct hard_iface *hard_iface)
 {
@@ -61,9 +61,9 @@ void batadv_slide_own_bcast_window(struct hard_iface *hard_iface)
 	}
 }
 
-static void _update_route(struct bat_priv *bat_priv,
-			  struct orig_node *orig_node,
-			  struct neigh_node *neigh_node)
+static void _batadv_update_route(struct bat_priv *bat_priv,
+				 struct orig_node *orig_node,
+				 struct neigh_node *neigh_node)
 {
 	struct neigh_node *curr_router;
 
@@ -117,7 +117,7 @@ void batadv_update_route(struct bat_priv *bat_priv, struct orig_node *orig_node,
 	router = batadv_orig_node_get_router(orig_node);
 
 	if (router != neigh_node)
-		_update_route(bat_priv, orig_node, neigh_node);
+		_batadv_update_route(bat_priv, orig_node, neigh_node);
 
 out:
 	if (router)
@@ -276,8 +276,8 @@ bool batadv_check_management_packet(struct sk_buff *skb,
 	return true;
 }
 
-static int recv_my_icmp_packet(struct bat_priv *bat_priv,
-			       struct sk_buff *skb, size_t icmp_len)
+static int batadv_recv_my_icmp_packet(struct bat_priv *bat_priv,
+				      struct sk_buff *skb, size_t icmp_len)
 {
 	struct hard_iface *primary_if = NULL;
 	struct orig_node *orig_node = NULL;
@@ -331,8 +331,8 @@ out:
 	return ret;
 }
 
-static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
-				  struct sk_buff *skb)
+static int batadv_recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
+					 struct sk_buff *skb)
 {
 	struct hard_iface *primary_if = NULL;
 	struct orig_node *orig_node = NULL;
@@ -431,11 +431,11 @@ int batadv_recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 
 	/* packet for me */
 	if (batadv_is_my_mac(icmp_packet->dst))
-		return recv_my_icmp_packet(bat_priv, skb, hdr_size);
+		return batadv_recv_my_icmp_packet(bat_priv, skb, hdr_size);
 
 	/* TTL exceeded */
 	if (icmp_packet->header.ttl < 2)
-		return recv_icmp_ttl_exceeded(bat_priv, skb);
+		return batadv_recv_icmp_ttl_exceeded(bat_priv, skb);
 
 	/* get routing information */
 	orig_node = batadv_orig_hash_find(bat_priv, icmp_packet->dst);
@@ -473,8 +473,9 @@ out:
  * This method rotates the bonding list and increases the
  * returned router's refcount.
  */
-static struct neigh_node *find_bond_router(struct orig_node *primary_orig,
-					   const struct hard_iface *recv_if)
+static struct neigh_node *
+batadv_find_bond_router(struct orig_node *primary_orig,
+			const struct hard_iface *recv_if)
 {
 	struct neigh_node *tmp_neigh_node;
 	struct neigh_node *router = NULL, *first_candidate = NULL;
@@ -527,8 +528,9 @@ out:
  *
  * Increases the returned router's refcount
  */
-static struct neigh_node *find_ifalter_router(struct orig_node *primary_orig,
-					      const struct hard_iface *recv_if)
+static struct neigh_node *
+batadv_find_ifalter_router(struct orig_node *primary_orig,
+			   const struct hard_iface *recv_if)
 {
 	struct neigh_node *tmp_neigh_node;
 	struct neigh_node *router = NULL, *first_candidate = NULL;
@@ -614,7 +616,7 @@ int batadv_recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 				   "Routing TT_REQUEST to %pM [%c]\n",
 				   tt_query->dst,
 				   tt_flag);
-			return route_unicast_packet(skb, recv_if);
+			return batadv_route_unicast_packet(skb, recv_if);
 		}
 		break;
 	case TT_RESPONSE:
@@ -643,7 +645,7 @@ int batadv_recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 				   "Routing TT_RESPONSE to %pM [%c]\n",
 				   tt_query->dst,
 				   tt_flag);
-			return route_unicast_packet(skb, recv_if);
+			return batadv_route_unicast_packet(skb, recv_if);
 		}
 		break;
 	}
@@ -679,7 +681,7 @@ int batadv_recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_if)
 	roam_adv_packet = (struct roam_adv_packet *)skb->data;
 
 	if (!batadv_is_my_mac(roam_adv_packet->dst))
-		return route_unicast_packet(skb, recv_if);
+		return batadv_route_unicast_packet(skb, recv_if);
 
 	/* check if it is a backbone gateway. we don't accept
 	 * roaming advertisement from it, as it has the same
@@ -783,9 +785,9 @@ struct neigh_node *batadv_find_router(struct bat_priv *bat_priv,
 	batadv_neigh_node_free_ref(router);
 
 	if (bonding_enabled)
-		router = find_bond_router(primary_orig_node, recv_if);
+		router = batadv_find_bond_router(primary_orig_node, recv_if);
 	else
-		router = find_ifalter_router(primary_orig_node, recv_if);
+		router = batadv_find_ifalter_router(primary_orig_node, recv_if);
 
 return_router:
 	if (router && router->if_incoming->if_status != IF_ACTIVE)
@@ -801,7 +803,7 @@ err:
 	return NULL;
 }
 
-static int check_unicast_packet(struct sk_buff *skb, int hdr_size)
+static int batadv_check_unicast_packet(struct sk_buff *skb, int hdr_size)
 {
 	struct ethhdr *ethhdr;
 
@@ -826,7 +828,8 @@ static int check_unicast_packet(struct sk_buff *skb, int hdr_size)
 	return 0;
 }
 
-static int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
+static int batadv_route_unicast_packet(struct sk_buff *skb,
+				       struct hard_iface *recv_if)
 {
 	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
 	struct orig_node *orig_node = NULL;
@@ -911,8 +914,8 @@ out:
 	return ret;
 }
 
-static int check_unicast_ttvn(struct bat_priv *bat_priv,
-			       struct sk_buff *skb) {
+static int batadv_check_unicast_ttvn(struct bat_priv *bat_priv,
+				     struct sk_buff *skb) {
 	uint8_t curr_ttvn;
 	struct orig_node *orig_node;
 	struct ethhdr *ethhdr;
@@ -994,10 +997,10 @@ int batadv_recv_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	struct unicast_packet *unicast_packet;
 	int hdr_size = sizeof(*unicast_packet);
 
-	if (check_unicast_packet(skb, hdr_size) < 0)
+	if (batadv_check_unicast_packet(skb, hdr_size) < 0)
 		return NET_RX_DROP;
 
-	if (!check_unicast_ttvn(bat_priv, skb))
+	if (!batadv_check_unicast_ttvn(bat_priv, skb))
 		return NET_RX_DROP;
 
 	unicast_packet = (struct unicast_packet *)skb->data;
@@ -1009,7 +1012,7 @@ int batadv_recv_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 		return NET_RX_SUCCESS;
 	}
 
-	return route_unicast_packet(skb, recv_if);
+	return batadv_route_unicast_packet(skb, recv_if);
 }
 
 int batadv_recv_ucast_frag_packet(struct sk_buff *skb,
@@ -1021,10 +1024,10 @@ int batadv_recv_ucast_frag_packet(struct sk_buff *skb,
 	struct sk_buff *new_skb = NULL;
 	int ret;
 
-	if (check_unicast_packet(skb, hdr_size) < 0)
+	if (batadv_check_unicast_packet(skb, hdr_size) < 0)
 		return NET_RX_DROP;
 
-	if (!check_unicast_ttvn(bat_priv, skb))
+	if (!batadv_check_unicast_ttvn(bat_priv, skb))
 		return NET_RX_DROP;
 
 	unicast_packet = (struct unicast_frag_packet *)skb->data;
@@ -1046,7 +1049,7 @@ int batadv_recv_ucast_frag_packet(struct sk_buff *skb,
 		return NET_RX_SUCCESS;
 	}
 
-	return route_unicast_packet(skb, recv_if);
+	return batadv_route_unicast_packet(skb, recv_if);
 }
 
 
-- 
1.7.9.4
