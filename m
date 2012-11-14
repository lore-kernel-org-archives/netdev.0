From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 09/11] batman-adv: refactor tt_global_del_struct()
Date: Wed, 14 Nov 2012 21:16:27 +0100
Message-ID: <1352924189-18843-10-git-send-email-ordex@autistici.org>
References: <1352924189-18843-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:31301 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423359Ab2KNURg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 15:17:36 -0500
In-Reply-To: <1352924189-18843-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

batadv_tt_global_del_struct() function is not properly named.
Having a more meaningful name which reflects the current behavior helps other
developers to easily understand what it does.

A parameter has also been renamed in order to let the function header better fit
the 80-chars line-width

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/translation-table.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index c24e604..cb8433a 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -927,18 +927,17 @@ batadv_tt_global_del_orig_entry(struct batadv_priv *bat_priv,
 	spin_unlock_bh(&tt_global_entry->list_lock);
 }
 
-static void
-batadv_tt_global_del_struct(struct batadv_priv *bat_priv,
-			    struct batadv_tt_global_entry *tt_global_entry,
-			    const char *message)
+static void batadv_tt_global_free(struct batadv_priv *bat_priv,
+				  struct batadv_tt_global_entry *tt_global,
+				  const char *message)
 {
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Deleting global tt entry %pM: %s\n",
-		   tt_global_entry->common.addr, message);
+		   tt_global->common.addr, message);
 
 	batadv_hash_remove(bat_priv->tt.global_hash, batadv_compare_tt,
-			   batadv_choose_orig, tt_global_entry->common.addr);
-	batadv_tt_global_entry_free_ref(tt_global_entry);
+			   batadv_choose_orig, tt_global->common.addr);
+	batadv_tt_global_entry_free_ref(tt_global);
 
 }
 
@@ -1002,8 +1001,8 @@ static void batadv_tt_global_del(struct batadv_priv *bat_priv,
 						orig_node, message);
 
 		if (hlist_empty(&tt_global_entry->orig_list))
-			batadv_tt_global_del_struct(bat_priv, tt_global_entry,
-						    message);
+			batadv_tt_global_free(bat_priv, tt_global_entry,
+					      message);
 
 		goto out;
 	}
@@ -1026,7 +1025,7 @@ static void batadv_tt_global_del(struct batadv_priv *bat_priv,
 	if (local_entry) {
 		/* local entry exists, case 2: client roamed to us. */
 		batadv_tt_global_del_orig_list(tt_global_entry);
-		batadv_tt_global_del_struct(bat_priv, tt_global_entry, message);
+		batadv_tt_global_free(bat_priv, tt_global_entry, message);
 	} else
 		/* no local entry exists, case 1: check for roaming */
 		batadv_tt_global_del_roaming(bat_priv, tt_global_entry,
-- 
1.8.0
