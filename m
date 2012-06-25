From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 04/20] batman-adv: Prefix hash static inline functions with batadv_
Date: Mon, 25 Jun 2012 08:54:28 +0200
Message-ID: <1340607284-29950-5-git-send-email-ordex@autistici.org>
References: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:30461 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754562Ab2FYGyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 02:54:43 -0400
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
 net/batman-adv/bridge_loop_avoidance.c |   13 ++++++++-----
 net/batman-adv/hash.h                  |   19 ++++++++++---------
 net/batman-adv/originator.c            |    5 +++--
 net/batman-adv/translation-table.c     |   24 +++++++++++++-----------
 net/batman-adv/vis.c                   |   16 ++++++++--------
 5 files changed, 42 insertions(+), 35 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 72ff8b9..7a2dfd4 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -379,8 +379,9 @@ static struct backbone_gw *bla_get_backbone_gw(struct bat_priv *bat_priv,
 	/* one for the hash, one for returning */
 	atomic_set(&entry->refcount, 2);
 
-	hash_added = hash_add(bat_priv->backbone_hash, compare_backbone_gw,
-			      choose_backbone_gw, entry, &entry->hash_entry);
+	hash_added = batadv_hash_add(bat_priv->backbone_hash,
+				     compare_backbone_gw, choose_backbone_gw,
+				     entry, &entry->hash_entry);
 
 	if (unlikely(hash_added != 0)) {
 		/* hash failed, free the structure */
@@ -540,8 +541,9 @@ static void bla_add_claim(struct bat_priv *bat_priv, const uint8_t *mac,
 		bat_dbg(DBG_BLA, bat_priv,
 			"bla_add_claim(): adding new entry %pM, vid %d to hash ...\n",
 			mac, vid);
-		hash_added = hash_add(bat_priv->claim_hash, compare_claim,
-				      choose_claim, claim, &claim->hash_entry);
+		hash_added = batadv_hash_add(bat_priv->claim_hash,
+					     compare_claim, choose_claim,
+					     claim, &claim->hash_entry);
 
 		if (unlikely(hash_added != 0)) {
 			/* only local changes happened. */
@@ -590,7 +592,8 @@ static void bla_del_claim(struct bat_priv *bat_priv, const uint8_t *mac,
 
 	bat_dbg(DBG_BLA, bat_priv, "bla_del_claim(): %pM, vid %d\n", mac, vid);
 
-	hash_remove(bat_priv->claim_hash, compare_claim, choose_claim, claim);
+	batadv_hash_remove(bat_priv->claim_hash, compare_claim, choose_claim,
+			   claim);
 	claim_free_ref(claim); /* reference from the hash is gone */
 
 	claim->backbone_gw->crc ^= crc16(0, claim->addr, ETH_ALEN);
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index eba8f2a..7ec4e5b 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -54,8 +54,8 @@ void batadv_hash_destroy(struct hashtable_t *hash);
  * called to remove the elements inside of the hash.  if you don't remove the
  * elements, memory might be leaked.
  */
-static inline void hash_delete(struct hashtable_t *hash,
-			       hashdata_free_cb free_cb, void *arg)
+static inline void batadv_hash_delete(struct hashtable_t *hash,
+				      hashdata_free_cb free_cb, void *arg)
 {
 	struct hlist_head *head;
 	struct hlist_node *node, *node_tmp;
@@ -89,10 +89,11 @@ static inline void hash_delete(struct hashtable_t *hash,
  *	Returns 0 on success, 1 if the element already is in the hash
  *	and -1 on error.
  */
-static inline int hash_add(struct hashtable_t *hash,
-			   hashdata_compare_cb compare,
-			   hashdata_choose_cb choose,
-			   const void *data, struct hlist_node *data_node)
+static inline int batadv_hash_add(struct hashtable_t *hash,
+				  hashdata_compare_cb compare,
+				  hashdata_choose_cb choose,
+				  const void *data,
+				  struct hlist_node *data_node)
 {
 	uint32_t index;
 	int ret = -1;
@@ -133,9 +134,9 @@ out:
  * structure you use with just the key filled, we just need the key for
  * comparing.
  */
-static inline void *hash_remove(struct hashtable_t *hash,
-				hashdata_compare_cb compare,
-				hashdata_choose_cb choose, void *data)
+static inline void *batadv_hash_remove(struct hashtable_t *hash,
+				       hashdata_compare_cb compare,
+				       hashdata_choose_cb choose, void *data)
 {
 	uint32_t index;
 	struct hlist_node *node;
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 90d24fc..623c23c 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -248,8 +248,9 @@ struct orig_node *batadv_get_orig_node(struct bat_priv *bat_priv,
 	if (!orig_node->bcast_own_sum)
 		goto free_bcast_own;
 
-	hash_added = hash_add(bat_priv->orig_hash, compare_orig,
-			      choose_orig, orig_node, &orig_node->hash_entry);
+	hash_added = batadv_hash_add(bat_priv->orig_hash, compare_orig,
+				     choose_orig, orig_node,
+				     &orig_node->hash_entry);
 	if (hash_added != 0)
 		goto free_bcast_own_sum;
 
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index bc06af4..72a8548 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -234,9 +234,9 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	 */
 	tt_local_entry->common.flags |= TT_CLIENT_NEW;
 
-	hash_added = hash_add(bat_priv->tt_local_hash, compare_tt, choose_orig,
-			 &tt_local_entry->common,
-			 &tt_local_entry->common.hash_entry);
+	hash_added = batadv_hash_add(bat_priv->tt_local_hash, compare_tt,
+				     choose_orig, &tt_local_entry->common,
+				     &tt_local_entry->common.hash_entry);
 
 	if (unlikely(hash_added != 0)) {
 		/* remove the reference for the hash */
@@ -618,6 +618,7 @@ int batadv_tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 	struct tt_global_entry *tt_global_entry = NULL;
 	int ret = 0;
 	int hash_added;
+	struct tt_common_entry *common;
 
 	tt_global_entry = tt_global_hash_find(bat_priv, tt_addr);
 
@@ -627,18 +628,19 @@ int batadv_tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 		if (!tt_global_entry)
 			goto out;
 
-		memcpy(tt_global_entry->common.addr, tt_addr, ETH_ALEN);
+		common = &tt_global_entry->common;
+		memcpy(common->addr, tt_addr, ETH_ALEN);
 
-		tt_global_entry->common.flags = NO_FLAGS;
+		common->flags = NO_FLAGS;
 		tt_global_entry->roam_at = 0;
-		atomic_set(&tt_global_entry->common.refcount, 2);
+		atomic_set(&common->refcount, 2);
 
 		INIT_HLIST_HEAD(&tt_global_entry->orig_list);
 		spin_lock_init(&tt_global_entry->list_lock);
 
-		hash_added = hash_add(bat_priv->tt_global_hash, compare_tt,
-				 choose_orig, &tt_global_entry->common,
-				 &tt_global_entry->common.hash_entry);
+		hash_added = batadv_hash_add(bat_priv->tt_global_hash,
+					     compare_tt, choose_orig,
+					     common, &common->hash_entry);
 
 		if (unlikely(hash_added != 0)) {
 			/* remove the reference for the hash */
@@ -816,8 +818,8 @@ static void tt_global_del_struct(struct bat_priv *bat_priv,
 		"Deleting global tt entry %pM: %s\n",
 		tt_global_entry->common.addr, message);
 
-	hash_remove(bat_priv->tt_global_hash, compare_tt, choose_orig,
-		    tt_global_entry->common.addr);
+	batadv_hash_remove(bat_priv->tt_global_hash, compare_tt, choose_orig,
+			   tt_global_entry->common.addr);
 	tt_global_entry_free_ref(tt_global_entry);
 
 }
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 619f0a5..e0a9057 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -433,8 +433,8 @@ static struct vis_info *add_packet(struct bat_priv *bat_priv,
 			}
 		}
 		/* remove old entry */
-		hash_remove(bat_priv->vis_hash, vis_info_cmp, vis_info_choose,
-			    old_info);
+		batadv_hash_remove(bat_priv->vis_hash, vis_info_cmp,
+				   vis_info_choose, old_info);
 		send_list_del(old_info);
 		kref_put(&old_info->refcount, free_info);
 	}
@@ -474,8 +474,8 @@ static struct vis_info *add_packet(struct bat_priv *bat_priv,
 	recv_list_add(bat_priv, &info->recv_list, packet->sender_orig);
 
 	/* try to add it */
-	hash_added = hash_add(bat_priv->vis_hash, vis_info_cmp, vis_info_choose,
-			      info, &info->hash_entry);
+	hash_added = batadv_hash_add(bat_priv->vis_hash, vis_info_cmp,
+				     vis_info_choose, info, &info->hash_entry);
 	if (hash_added != 0) {
 		/* did not work (for some reason) */
 		kref_put(&info->refcount, free_info);
@@ -934,9 +934,9 @@ int batadv_vis_init(struct bat_priv *bat_priv)
 
 	INIT_LIST_HEAD(&bat_priv->vis_send_list);
 
-	hash_added = hash_add(bat_priv->vis_hash, vis_info_cmp, vis_info_choose,
-			      bat_priv->my_vis_info,
-			      &bat_priv->my_vis_info->hash_entry);
+	hash_added = batadv_hash_add(bat_priv->vis_hash, vis_info_cmp,
+				     vis_info_choose, bat_priv->my_vis_info,
+				     &bat_priv->my_vis_info->hash_entry);
 	if (hash_added != 0) {
 		pr_err("Can't add own vis packet into hash\n");
 		/* not in hash, need to remove it manually. */
@@ -977,7 +977,7 @@ void batadv_vis_quit(struct bat_priv *bat_priv)
 
 	spin_lock_bh(&bat_priv->vis_hash_lock);
 	/* properly remove, kill timers ... */
-	hash_delete(bat_priv->vis_hash, free_info_ref, NULL);
+	batadv_hash_delete(bat_priv->vis_hash, free_info_ref, NULL);
 	bat_priv->vis_hash = NULL;
 	bat_priv->my_vis_info = NULL;
 	spin_unlock_bh(&bat_priv->vis_hash_lock);
-- 
1.7.9.4
