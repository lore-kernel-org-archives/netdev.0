From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 05/20] batman-adv: Prefix originator static inline functions with batadv_
Date: Mon, 25 Jun 2012 08:54:29 +0200
Message-ID: <1340607284-29950-6-git-send-email-ordex@autistici.org>
References: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:30470 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754579Ab2FYGyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 02:54:44 -0400
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
 net/batman-adv/bridge_loop_avoidance.c |    4 ++--
 net/batman-adv/icmp_socket.c           |    2 +-
 net/batman-adv/originator.c            |    4 ++--
 net/batman-adv/originator.h            |    8 ++++----
 net/batman-adv/routing.c               |   26 +++++++++++++++-----------
 net/batman-adv/translation-table.c     |   21 +++++++++++----------
 net/batman-adv/unicast.c               |    2 +-
 net/batman-adv/vis.c                   |    2 +-
 8 files changed, 37 insertions(+), 32 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 7a2dfd4..1d143d5 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -390,7 +390,7 @@ static struct backbone_gw *bla_get_backbone_gw(struct bat_priv *bat_priv,
 	}
 
 	/* this is a gateway now, remove any tt entries */
-	orig_node = orig_hash_find(bat_priv, orig);
+	orig_node = batadv_orig_hash_find(bat_priv, orig);
 	if (orig_node) {
 		batadv_tt_global_del_orig(bat_priv, orig_node,
 					  "became a backbone gateway");
@@ -780,7 +780,7 @@ static int check_claim_group(struct bat_priv *bat_priv,
 		return 2;
 
 	/* lets see if this originator is in our mesh */
-	orig_node = orig_hash_find(bat_priv, backbone_addr);
+	orig_node = batadv_orig_hash_find(bat_priv, backbone_addr);
 
 	/* dont accept claims from gateways which are not in
 	 * the same mesh or group.
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 2523436..50a74da 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -213,7 +213,7 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 	if (atomic_read(&bat_priv->mesh_state) != MESH_ACTIVE)
 		goto dst_unreach;
 
-	orig_node = orig_hash_find(bat_priv, icmp_packet->dst);
+	orig_node = batadv_orig_hash_find(bat_priv, icmp_packet->dst);
 	if (!orig_node)
 		goto dst_unreach;
 
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 623c23c..36f5ee5 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -195,7 +195,7 @@ struct orig_node *batadv_get_orig_node(struct bat_priv *bat_priv,
 	int size;
 	int hash_added;
 
-	orig_node = orig_hash_find(bat_priv, addr);
+	orig_node = batadv_orig_hash_find(bat_priv, addr);
 	if (orig_node)
 		return orig_node;
 
@@ -249,7 +249,7 @@ struct orig_node *batadv_get_orig_node(struct bat_priv *bat_priv,
 		goto free_bcast_own;
 
 	hash_added = batadv_hash_add(bat_priv->orig_hash, compare_orig,
-				     choose_orig, orig_node,
+				     batadv_choose_orig, orig_node,
 				     &orig_node->hash_entry);
 	if (hash_added != 0)
 		goto free_bcast_own_sum;
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index a721719..c4f63b4 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -41,7 +41,7 @@ int batadv_orig_hash_del_if(struct hard_iface *hard_iface, int max_if_num);
 /* hashfunction to choose an entry in a hash table of given size
  * hash algorithm from http://en.wikipedia.org/wiki/Hash_table
  */
-static inline uint32_t choose_orig(const void *data, uint32_t size)
+static inline uint32_t batadv_choose_orig(const void *data, uint32_t size)
 {
 	const unsigned char *key = data;
 	uint32_t hash = 0;
@@ -60,8 +60,8 @@ static inline uint32_t choose_orig(const void *data, uint32_t size)
 	return hash % size;
 }
 
-static inline struct orig_node *orig_hash_find(struct bat_priv *bat_priv,
-					       const void *data)
+static inline struct orig_node *batadv_orig_hash_find(struct bat_priv *bat_priv,
+						      const void *data)
 {
 	struct hashtable_t *hash = bat_priv->orig_hash;
 	struct hlist_head *head;
@@ -72,7 +72,7 @@ static inline struct orig_node *orig_hash_find(struct bat_priv *bat_priv,
 	if (!hash)
 		return NULL;
 
-	index = choose_orig(data, hash->size);
+	index = batadv_choose_orig(data, hash->size);
 	head = &hash->table[index];
 
 	rcu_read_lock();
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 9c6edc2..0888f1e 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -298,7 +298,7 @@ static int recv_my_icmp_packet(struct bat_priv *bat_priv,
 
 	/* answer echo request (ping) */
 	/* get routing information */
-	orig_node = orig_hash_find(bat_priv, icmp_packet->orig);
+	orig_node = batadv_orig_hash_find(bat_priv, icmp_packet->orig);
 	if (!orig_node)
 		goto out;
 
@@ -353,7 +353,7 @@ static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
 		goto out;
 
 	/* get routing information */
-	orig_node = orig_hash_find(bat_priv, icmp_packet->orig);
+	orig_node = batadv_orig_hash_find(bat_priv, icmp_packet->orig);
 	if (!orig_node)
 		goto out;
 
@@ -437,7 +437,7 @@ int batadv_recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 		return recv_icmp_ttl_exceeded(bat_priv, skb);
 
 	/* get routing information */
-	orig_node = orig_hash_find(bat_priv, icmp_packet->dst);
+	orig_node = batadv_orig_hash_find(bat_priv, icmp_packet->dst);
 	if (!orig_node)
 		goto out;
 
@@ -684,7 +684,7 @@ int batadv_recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_if)
 	if (batadv_bla_is_backbone_gw_orig(bat_priv, roam_adv_packet->src))
 		goto out;
 
-	orig_node = orig_hash_find(bat_priv, roam_adv_packet->src);
+	orig_node = batadv_orig_hash_find(bat_priv, roam_adv_packet->src);
 	if (!orig_node)
 		goto out;
 
@@ -721,6 +721,7 @@ struct neigh_node *batadv_find_router(struct bat_priv *bat_priv,
 	struct neigh_node *router;
 	static uint8_t zero_mac[ETH_ALEN] = {0, 0, 0, 0, 0, 0};
 	int bonding_enabled;
+	uint8_t *primary_addr;
 
 	if (!orig_node)
 		return NULL;
@@ -743,20 +744,22 @@ struct neigh_node *batadv_find_router(struct bat_priv *bat_priv,
 	if ((!recv_if) && (!bonding_enabled))
 		goto return_router;
 
+	primary_addr = router_orig->primary_addr;
+
 	/* if we have something in the primary_addr, we can search
 	 * for a potential bonding candidate.
 	 */
-	if (compare_eth(router_orig->primary_addr, zero_mac))
+	if (compare_eth(primary_addr, zero_mac))
 		goto return_router;
 
 	/* find the orig_node which has the primary interface. might
 	 * even be the same as our router_orig in many cases
 	 */
-	if (compare_eth(router_orig->primary_addr, router_orig->orig)) {
+	if (compare_eth(primary_addr, router_orig->orig)) {
 		primary_orig_node = router_orig;
 	} else {
-		primary_orig_node = orig_hash_find(bat_priv,
-						   router_orig->primary_addr);
+		primary_orig_node = batadv_orig_hash_find(bat_priv,
+							  primary_addr);
 		if (!primary_orig_node)
 			goto return_router;
 
@@ -839,7 +842,7 @@ static int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	}
 
 	/* get routing information */
-	orig_node = orig_hash_find(bat_priv, unicast_packet->dest);
+	orig_node = batadv_orig_hash_find(bat_priv, unicast_packet->dest);
 
 	if (!orig_node)
 		goto out;
@@ -922,7 +925,8 @@ static int check_unicast_ttvn(struct bat_priv *bat_priv,
 		tt_poss_change = bat_priv->tt_poss_change;
 		curr_ttvn = (uint8_t)atomic_read(&bat_priv->ttvn);
 	} else {
-		orig_node = orig_hash_find(bat_priv, unicast_packet->dest);
+		orig_node = batadv_orig_hash_find(bat_priv,
+						  unicast_packet->dest);
 
 		if (!orig_node)
 			return 0;
@@ -1078,7 +1082,7 @@ int batadv_recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	if (bcast_packet->header.ttl < 2)
 		goto out;
 
-	orig_node = orig_hash_find(bat_priv, bcast_packet->orig);
+	orig_node = batadv_orig_hash_find(bat_priv, bcast_packet->orig);
 
 	if (!orig_node)
 		goto out;
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 72a8548..1dfa231 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -61,7 +61,7 @@ static struct tt_common_entry *tt_hash_find(struct hashtable_t *hash,
 	if (!hash)
 		return NULL;
 
-	index = choose_orig(data, hash->size);
+	index = batadv_choose_orig(data, hash->size);
 	head = &hash->table[index];
 
 	rcu_read_lock();
@@ -235,7 +235,8 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	tt_local_entry->common.flags |= TT_CLIENT_NEW;
 
 	hash_added = batadv_hash_add(bat_priv->tt_local_hash, compare_tt,
-				     choose_orig, &tt_local_entry->common,
+				     batadv_choose_orig,
+				     &tt_local_entry->common,
 				     &tt_local_entry->common.hash_entry);
 
 	if (unlikely(hash_added != 0)) {
@@ -639,7 +640,7 @@ int batadv_tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 		spin_lock_init(&tt_global_entry->list_lock);
 
 		hash_added = batadv_hash_add(bat_priv->tt_global_hash,
-					     compare_tt, choose_orig,
+					     compare_tt, batadv_choose_orig,
 					     common, &common->hash_entry);
 
 		if (unlikely(hash_added != 0)) {
@@ -818,8 +819,8 @@ static void tt_global_del_struct(struct bat_priv *bat_priv,
 		"Deleting global tt entry %pM: %s\n",
 		tt_global_entry->common.addr, message);
 
-	batadv_hash_remove(bat_priv->tt_global_hash, compare_tt, choose_orig,
-			   tt_global_entry->common.addr);
+	batadv_hash_remove(bat_priv->tt_global_hash, compare_tt,
+			   batadv_choose_orig, tt_global_entry->common.addr);
 	tt_global_entry_free_ref(tt_global_entry);
 
 }
@@ -1454,11 +1455,11 @@ static bool send_other_tt_response(struct bat_priv *bat_priv,
 		(tt_request->flags & TT_FULL_TABLE ? 'F' : '.'));
 
 	/* Let's get the orig node of the REAL destination */
-	req_dst_orig_node = orig_hash_find(bat_priv, tt_request->dst);
+	req_dst_orig_node = batadv_orig_hash_find(bat_priv, tt_request->dst);
 	if (!req_dst_orig_node)
 		goto out;
 
-	res_dst_orig_node = orig_hash_find(bat_priv, tt_request->src);
+	res_dst_orig_node = batadv_orig_hash_find(bat_priv, tt_request->src);
 	if (!res_dst_orig_node)
 		goto out;
 
@@ -1586,7 +1587,7 @@ static bool send_my_tt_response(struct bat_priv *bat_priv,
 	my_ttvn = (uint8_t)atomic_read(&bat_priv->ttvn);
 	req_ttvn = tt_request->ttvn;
 
-	orig_node = orig_hash_find(bat_priv, tt_request->src);
+	orig_node = batadv_orig_hash_find(bat_priv, tt_request->src);
 	if (!orig_node)
 		goto out;
 
@@ -1731,7 +1732,7 @@ static void tt_fill_gtable(struct bat_priv *bat_priv,
 {
 	struct orig_node *orig_node = NULL;
 
-	orig_node = orig_hash_find(bat_priv, tt_response->src);
+	orig_node = batadv_orig_hash_find(bat_priv, tt_response->src);
 	if (!orig_node)
 		goto out;
 
@@ -1804,7 +1805,7 @@ void batadv_handle_tt_response(struct bat_priv *bat_priv,
 	if (batadv_bla_is_backbone_gw_orig(bat_priv, tt_response->src))
 		goto out;
 
-	orig_node = orig_hash_find(bat_priv, tt_response->src);
+	orig_node = batadv_orig_hash_find(bat_priv, tt_response->src);
 	if (!orig_node)
 		goto out;
 
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index fff34e0..d021055 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -181,7 +181,7 @@ int batadv_frag_reassemble_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 
 	*new_skb = NULL;
 
-	orig_node = orig_hash_find(bat_priv, unicast_packet->orig);
+	orig_node = batadv_orig_hash_find(bat_priv, unicast_packet->orig);
 	if (!orig_node)
 		goto out;
 
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index e0a9057..bf72c52 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -803,7 +803,7 @@ static void unicast_vis_packet(struct bat_priv *bat_priv,
 
 	packet = (struct vis_packet *)info->skb_packet->data;
 
-	orig_node = orig_hash_find(bat_priv, packet->target_orig);
+	orig_node = batadv_orig_hash_find(bat_priv, packet->target_orig);
 	if (!orig_node)
 		goto out;
 
-- 
1.7.9.4
