From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 02/16] batman-adv: make tt_global_add static and return bool
Date: Sun, 13 Oct 2013 13:22:47 +0200
Message-ID: <1381663381-626-3-git-send-email-antonio@meshcoding.com>
References: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:28712 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754305Ab3JMLYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 07:24:19 -0400
In-Reply-To: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

batadv_tt_global_add is not used anymore outside of the TT
code thanks to the TVLV implementation. It can therefore be
declared as static

Last user has been removed by 3de4e64df0f1326db7cc0ef25f5af8522850252d
("batman-adv: tvlv - convert roaming adv packet to use tvlv unicast packets")

Moreover make it return bool since its result can be either 0 or 1.

Reported-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/translation-table.c | 14 ++++++++------
 net/batman-adv/translation-table.h |  4 ----
 2 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index c741694..b3c4369 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -805,15 +805,17 @@ out:
  * If a TT local entry exists for this non-mesh client remove it.
  *
  * The caller must hold orig_node refcount.
+ *
+ * Return true if the new entry has been added, false otherwise
  */
-int batadv_tt_global_add(struct batadv_priv *bat_priv,
-			 struct batadv_orig_node *orig_node,
-			 const unsigned char *tt_addr, uint16_t flags,
-			 uint8_t ttvn)
+static bool batadv_tt_global_add(struct batadv_priv *bat_priv,
+				 struct batadv_orig_node *orig_node,
+				 const unsigned char *tt_addr, uint16_t flags,
+				 uint8_t ttvn)
 {
 	struct batadv_tt_global_entry *tt_global_entry;
 	struct batadv_tt_local_entry *tt_local_entry;
-	int ret = 0;
+	bool ret = false;
 	int hash_added;
 	struct batadv_tt_common_entry *common;
 	uint16_t local_flags;
@@ -914,7 +916,7 @@ add_orig_entry:
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Creating new global tt entry: %pM (via %pM)\n",
 		   common->addr, orig_node->orig);
-	ret = 1;
+	ret = true;
 
 out_remove:
 
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index b4b6dea..fb710c5 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -30,10 +30,6 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset);
 void batadv_tt_global_add_orig(struct batadv_priv *bat_priv,
 			       struct batadv_orig_node *orig_node,
 			       const unsigned char *tt_buff, int tt_buff_len);
-int batadv_tt_global_add(struct batadv_priv *bat_priv,
-			 struct batadv_orig_node *orig_node,
-			 const unsigned char *addr, uint16_t flags,
-			 uint8_t ttvn);
 int batadv_tt_global_seq_print_text(struct seq_file *seq, void *offset);
 void batadv_tt_global_del_orig(struct batadv_priv *bat_priv,
 			       struct batadv_orig_node *orig_node,
-- 
1.8.3.2
