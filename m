From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 05/16] batman-adv: Remove declaration of only locally used functions
Date: Sat,  7 Apr 2012 20:49:47 +0200
Message-ID: <1333824598-27771-6-git-send-email-ordex@autistici.org>
References: <1333824598-27771-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:60885 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754261Ab2DGStT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Apr 2012 14:49:19 -0400
In-Reply-To: <1333824598-27771-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Acked-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/translation-table.c |   22 ++++++++++++++--------
 net/batman-adv/translation-table.h |    8 --------
 2 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 1f86921..5f8c540 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -30,6 +30,8 @@
 
 #include <linux/crc16.h>
 
+static void send_roam_adv(struct bat_priv *bat_priv, uint8_t *client,
+			  struct orig_node *orig_node);
 static void _tt_global_del(struct bat_priv *bat_priv,
 			   struct tt_global_entry *tt_global_entry,
 			   const char *message);
@@ -645,9 +647,10 @@ out:
 		tt_global_entry_free_ref(tt_global_entry);
 }
 
-void tt_global_del(struct bat_priv *bat_priv,
-		   struct orig_node *orig_node, const unsigned char *addr,
-		   const char *message, bool roaming)
+static void tt_global_del(struct bat_priv *bat_priv,
+			  struct orig_node *orig_node,
+			  const unsigned char *addr,
+			  const char *message, bool roaming)
 {
 	struct tt_global_entry *tt_global_entry = NULL;
 	struct tt_local_entry *tt_local_entry = NULL;
@@ -848,7 +851,8 @@ out:
 }
 
 /* Calculates the checksum of the local table of a given orig_node */
-uint16_t tt_global_crc(struct bat_priv *bat_priv, struct orig_node *orig_node)
+static uint16_t tt_global_crc(struct bat_priv *bat_priv,
+			      struct orig_node *orig_node)
 {
 	uint16_t total = 0, total_one;
 	struct hashtable_t *hash = bat_priv->tt_global_hash;
@@ -936,8 +940,10 @@ static void tt_req_list_free(struct bat_priv *bat_priv)
 	spin_unlock_bh(&bat_priv->tt_req_list_lock);
 }
 
-void tt_save_orig_buffer(struct bat_priv *bat_priv, struct orig_node *orig_node,
-			 const unsigned char *tt_buff, uint8_t tt_num_changes)
+static void tt_save_orig_buffer(struct bat_priv *bat_priv,
+				struct orig_node *orig_node,
+				const unsigned char *tt_buff,
+				uint8_t tt_num_changes)
 {
 	uint16_t tt_buff_len = tt_len(tt_num_changes);
 
@@ -1627,8 +1633,8 @@ unlock:
 	return ret;
 }
 
-void send_roam_adv(struct bat_priv *bat_priv, uint8_t *client,
-		   struct orig_node *orig_node)
+static void send_roam_adv(struct bat_priv *bat_priv, uint8_t *client,
+			  struct orig_node *orig_node)
 {
 	struct neigh_node *neigh_node = NULL;
 	struct sk_buff *skb = NULL;
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index c753633..bfebe26 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -39,23 +39,15 @@ int tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 int tt_global_seq_print_text(struct seq_file *seq, void *offset);
 void tt_global_del_orig(struct bat_priv *bat_priv,
 			struct orig_node *orig_node, const char *message);
-void tt_global_del(struct bat_priv *bat_priv,
-		   struct orig_node *orig_node, const unsigned char *addr,
-		   const char *message, bool roaming);
 struct orig_node *transtable_search(struct bat_priv *bat_priv,
 				    const uint8_t *src, const uint8_t *addr);
-void tt_save_orig_buffer(struct bat_priv *bat_priv, struct orig_node *orig_node,
-			 const unsigned char *tt_buff, uint8_t tt_num_changes);
 uint16_t tt_local_crc(struct bat_priv *bat_priv);
-uint16_t tt_global_crc(struct bat_priv *bat_priv, struct orig_node *orig_node);
 void tt_free(struct bat_priv *bat_priv);
 bool send_tt_response(struct bat_priv *bat_priv,
 		      struct tt_query_packet *tt_request);
 bool is_my_client(struct bat_priv *bat_priv, const uint8_t *addr);
 void handle_tt_response(struct bat_priv *bat_priv,
 			struct tt_query_packet *tt_response);
-void send_roam_adv(struct bat_priv *bat_priv, uint8_t *client,
-		   struct orig_node *orig_node);
 void tt_commit_changes(struct bat_priv *bat_priv);
 bool is_ap_isolated(struct bat_priv *bat_priv, uint8_t *src, uint8_t *dst);
 void tt_update_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
-- 
1.7.9.4
