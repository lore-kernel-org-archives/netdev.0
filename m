From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 08/11] batman-adv: refactor code to simplify long lines
Date: Wed, 14 Nov 2012 21:16:26 +0100
Message-ID: <1352924189-18843-9-git-send-email-ordex@autistici.org>
References: <1352924189-18843-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:31301 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423305Ab2KNURf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 15:17:35 -0500
In-Reply-To: <1352924189-18843-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/translation-table.c | 62 ++++++++++++++++++--------------------
 1 file changed, 30 insertions(+), 32 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index d741851..c24e604 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -242,86 +242,84 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 			 int ifindex)
 {
 	struct batadv_priv *bat_priv = netdev_priv(soft_iface);
-	struct batadv_tt_local_entry *tt_local_entry = NULL;
-	struct batadv_tt_global_entry *tt_global_entry = NULL;
+	struct batadv_tt_local_entry *tt_local = NULL;
+	struct batadv_tt_global_entry *tt_global = NULL;
 	struct hlist_head *head;
 	struct hlist_node *node;
 	struct batadv_tt_orig_list_entry *orig_entry;
 	int hash_added;
 
-	tt_local_entry = batadv_tt_local_hash_find(bat_priv, addr);
+	tt_local = batadv_tt_local_hash_find(bat_priv, addr);
 
-	if (tt_local_entry) {
-		tt_local_entry->last_seen = jiffies;
+	if (tt_local) {
+		tt_local->last_seen = jiffies;
 		/* possibly unset the BATADV_TT_CLIENT_PENDING flag */
-		tt_local_entry->common.flags &= ~BATADV_TT_CLIENT_PENDING;
+		tt_local->common.flags &= ~BATADV_TT_CLIENT_PENDING;
 		goto out;
 	}
 
-	tt_local_entry = kmalloc(sizeof(*tt_local_entry), GFP_ATOMIC);
-	if (!tt_local_entry)
+	tt_local = kmalloc(sizeof(*tt_local), GFP_ATOMIC);
+	if (!tt_local)
 		goto out;
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Creating new local tt entry: %pM (ttvn: %d)\n", addr,
 		   (uint8_t)atomic_read(&bat_priv->tt.vn));
 
-	memcpy(tt_local_entry->common.addr, addr, ETH_ALEN);
-	tt_local_entry->common.flags = BATADV_NO_FLAGS;
+	memcpy(tt_local->common.addr, addr, ETH_ALEN);
+	tt_local->common.flags = BATADV_NO_FLAGS;
 	if (batadv_is_wifi_iface(ifindex))
-		tt_local_entry->common.flags |= BATADV_TT_CLIENT_WIFI;
-	atomic_set(&tt_local_entry->common.refcount, 2);
-	tt_local_entry->last_seen = jiffies;
-	tt_local_entry->common.added_at = tt_local_entry->last_seen;
+		tt_local->common.flags |= BATADV_TT_CLIENT_WIFI;
+	atomic_set(&tt_local->common.refcount, 2);
+	tt_local->last_seen = jiffies;
+	tt_local->common.added_at = tt_local->last_seen;
 
 	/* the batman interface mac address should never be purged */
 	if (batadv_compare_eth(addr, soft_iface->dev_addr))
-		tt_local_entry->common.flags |= BATADV_TT_CLIENT_NOPURGE;
+		tt_local->common.flags |= BATADV_TT_CLIENT_NOPURGE;
 
 	/* The local entry has to be marked as NEW to avoid to send it in
 	 * a full table response going out before the next ttvn increment
 	 * (consistency check)
 	 */
-	tt_local_entry->common.flags |= BATADV_TT_CLIENT_NEW;
+	tt_local->common.flags |= BATADV_TT_CLIENT_NEW;
 
 	hash_added = batadv_hash_add(bat_priv->tt.local_hash, batadv_compare_tt,
-				     batadv_choose_orig,
-				     &tt_local_entry->common,
-				     &tt_local_entry->common.hash_entry);
+				     batadv_choose_orig, &tt_local->common,
+				     &tt_local->common.hash_entry);
 
 	if (unlikely(hash_added != 0)) {
 		/* remove the reference for the hash */
-		batadv_tt_local_entry_free_ref(tt_local_entry);
+		batadv_tt_local_entry_free_ref(tt_local);
 		goto out;
 	}
 
-	batadv_tt_local_event(bat_priv, addr, tt_local_entry->common.flags);
+	batadv_tt_local_event(bat_priv, addr, tt_local->common.flags);
 
 	/* remove address from global hash if present */
-	tt_global_entry = batadv_tt_global_hash_find(bat_priv, addr);
+	tt_global = batadv_tt_global_hash_find(bat_priv, addr);
 
 	/* Check whether it is a roaming! */
-	if (tt_global_entry) {
+	if (tt_global) {
 		/* These node are probably going to update their tt table */
-		head = &tt_global_entry->orig_list;
+		head = &tt_global->orig_list;
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(orig_entry, node, head, list) {
-			batadv_send_roam_adv(bat_priv,
-					     tt_global_entry->common.addr,
+			batadv_send_roam_adv(bat_priv, tt_global->common.addr,
 					     orig_entry->orig_node);
 		}
 		rcu_read_unlock();
 		/* The global entry has to be marked as ROAMING and
 		 * has to be kept for consistency purpose
 		 */
-		tt_global_entry->common.flags |= BATADV_TT_CLIENT_ROAM;
-		tt_global_entry->roam_at = jiffies;
+		tt_global->common.flags |= BATADV_TT_CLIENT_ROAM;
+		tt_global->roam_at = jiffies;
 	}
 out:
-	if (tt_local_entry)
-		batadv_tt_local_entry_free_ref(tt_local_entry);
-	if (tt_global_entry)
-		batadv_tt_global_entry_free_ref(tt_global_entry);
+	if (tt_local)
+		batadv_tt_local_entry_free_ref(tt_local);
+	if (tt_global)
+		batadv_tt_global_entry_free_ref(tt_global);
 }
 
 static void batadv_tt_realloc_packet_buff(unsigned char **packet_buff,
-- 
1.8.0
