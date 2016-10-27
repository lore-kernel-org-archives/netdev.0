From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 15/17] batman-adv: Use proper name for gateway list head
Date: Thu, 27 Oct 2016 21:01:48 +0200
Message-ID: <20161027190150.7880-16-sw@simonwunderlich.de>
References: <20161027190150.7880-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:38382 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942670AbcJ0TCB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 15:02:01 -0400
In-Reply-To: <20161027190150.7880-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The batman-adv codebase is using "list" for the list node (prev/next) and
<list content descriptor>+"_list" for the head of a list. Not using this
naming scheme can up in confusions when reading the code.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/bat_iv_ogm.c     | 6 +++---
 net/batman-adv/bat_v.c          | 6 +++---
 net/batman-adv/gateway_client.c | 7 ++++---
 net/batman-adv/main.c           | 2 +-
 net/batman-adv/types.h          | 8 ++++----
 5 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index e2d18d0..0b9be62 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -2486,7 +2486,7 @@ batadv_iv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 	struct batadv_orig_node *orig_node;
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.list, list) {
+	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.gateway_list, list) {
 		orig_node = gw_node->orig_node;
 		router = batadv_orig_router_get(orig_node, BATADV_IF_DEFAULT);
 		if (!router)
@@ -2674,7 +2674,7 @@ static void batadv_iv_gw_print(struct batadv_priv *bat_priv,
 		 "      Gateway      (#/255)           Nexthop [outgoingIF]: advertised uplink bandwidth\n");
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.list, list) {
+	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.gateway_list, list) {
 		/* fails if orig_node has no router */
 		if (batadv_iv_gw_write_buffer_text(bat_priv, seq, gw_node) < 0)
 			continue;
@@ -2774,7 +2774,7 @@ static void batadv_iv_gw_dump(struct sk_buff *msg, struct netlink_callback *cb,
 	int idx = 0;
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.list, list) {
+	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.gateway_list, list) {
 		if (idx++ < idx_skip)
 			continue;
 
diff --git a/net/batman-adv/bat_v.c b/net/batman-adv/bat_v.c
index 57c795c..2ac612d 100644
--- a/net/batman-adv/bat_v.c
+++ b/net/batman-adv/bat_v.c
@@ -750,7 +750,7 @@ batadv_v_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 	u32 max_bw = 0, bw;
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.list, list) {
+	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.gateway_list, list) {
 		if (!kref_get_unless_zero(&gw_node->refcount))
 			continue;
 
@@ -889,7 +889,7 @@ static void batadv_v_gw_print(struct batadv_priv *bat_priv,
 		 "      Gateway        ( throughput)           Nexthop [outgoingIF]: advertised uplink bandwidth\n");
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.list, list) {
+	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.gateway_list, list) {
 		/* fails if orig_node has no router */
 		if (batadv_v_gw_write_buffer_text(bat_priv, seq, gw_node) < 0)
 			continue;
@@ -1009,7 +1009,7 @@ static void batadv_v_gw_dump(struct sk_buff *msg, struct netlink_callback *cb,
 	int idx = 0;
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.list, list) {
+	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.gateway_list, list) {
 		if (idx++ < idx_skip)
 			continue;
 
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 69bfe98..52b8bd6 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -348,7 +348,7 @@ static void batadv_gw_node_add(struct batadv_priv *bat_priv,
 
 	spin_lock_bh(&bat_priv->gw.list_lock);
 	kref_get(&gw_node->refcount);
-	hlist_add_head_rcu(&gw_node->list, &bat_priv->gw.list);
+	hlist_add_head_rcu(&gw_node->list, &bat_priv->gw.gateway_list);
 	spin_unlock_bh(&bat_priv->gw.list_lock);
 
 	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
@@ -376,7 +376,8 @@ struct batadv_gw_node *batadv_gw_node_get(struct batadv_priv *bat_priv,
 	struct batadv_gw_node *gw_node_tmp, *gw_node = NULL;
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(gw_node_tmp, &bat_priv->gw.list, list) {
+	hlist_for_each_entry_rcu(gw_node_tmp, &bat_priv->gw.gateway_list,
+				 list) {
 		if (gw_node_tmp->orig_node != orig_node)
 			continue;
 
@@ -475,7 +476,7 @@ void batadv_gw_node_free(struct batadv_priv *bat_priv)
 
 	spin_lock_bh(&bat_priv->gw.list_lock);
 	hlist_for_each_entry_safe(gw_node, node_tmp,
-				  &bat_priv->gw.list, list) {
+				  &bat_priv->gw.gateway_list, list) {
 		hlist_del_init_rcu(&gw_node->list);
 		batadv_gw_node_put(gw_node);
 	}
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 2c017ab..5e4e818 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -160,7 +160,7 @@ int batadv_mesh_init(struct net_device *soft_iface)
 
 	INIT_HLIST_HEAD(&bat_priv->forw_bat_list);
 	INIT_HLIST_HEAD(&bat_priv->forw_bcast_list);
-	INIT_HLIST_HEAD(&bat_priv->gw.list);
+	INIT_HLIST_HEAD(&bat_priv->gw.gateway_list);
 #ifdef CONFIG_BATMAN_ADV_MCAST
 	INIT_HLIST_HEAD(&bat_priv->mcast.want_all_unsnoopables_list);
 	INIT_HLIST_HEAD(&bat_priv->mcast.want_all_ipv4_list);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index d31e7ec..673a22e 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -706,8 +706,8 @@ struct batadv_priv_debug_log {
 
 /**
  * struct batadv_priv_gw - per mesh interface gateway data
- * @list: list of available gateway nodes
- * @list_lock: lock protecting gw_list & curr_gw
+ * @gateway_list: list of available gateway nodes
+ * @list_lock: lock protecting gateway_list & curr_gw
  * @curr_gw: pointer to currently selected gateway node
  * @mode: gateway operation: off, client or server (see batadv_gw_modes)
  * @sel_class: gateway selection class (applies if gw_mode client)
@@ -716,8 +716,8 @@ struct batadv_priv_debug_log {
  * @reselect: bool indicating a gateway re-selection is in progress
  */
 struct batadv_priv_gw {
-	struct hlist_head list;
-	spinlock_t list_lock; /* protects gw_list & curr_gw */
+	struct hlist_head gateway_list;
+	spinlock_t list_lock; /* protects gateway_list & curr_gw */
 	struct batadv_gw_node __rcu *curr_gw;  /* rcu protected pointer */
 	atomic_t mode;
 	atomic_t sel_class;
-- 
2.10.1
