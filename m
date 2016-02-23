From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 19/20] batman-adv: Rename batadv_tt_global_entry *_free_ref function to *_put
Date: Tue, 23 Feb 2016 14:08:22 +0800
Message-ID: <1456207703-903-20-git-send-email-a__14484.4611910687$1456208899$gmane$org@unstable.cc>
References: <1456207703-903-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:31639 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757088AbcBWG2L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 01:28:11 -0500
In-Reply-To: <1456207703-903-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The batman-adv source code is the only place in the kernel which uses the
*_free_ref naming scheme for the *_put functions. Changing it to *_put
makes it more consistent and makes it easier to understand the connection
to the *_get functions.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/translation-table.c | 32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index de3e731542e3..7f65a8f17f52 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -247,12 +247,12 @@ static void batadv_tt_global_entry_release(struct kref *ref)
 }
 
 /**
- * batadv_tt_global_entry_free_ref - decrement the tt_global_entry refcounter
- *  and possibly release it
+ * batadv_tt_global_entry_put - decrement the tt_global_entry refcounter and
+ *  possibly release it
  * @tt_global_entry: tt_global_entry to be free'd
  */
 static void
-batadv_tt_global_entry_free_ref(struct batadv_tt_global_entry *tt_global_entry)
+batadv_tt_global_entry_put(struct batadv_tt_global_entry *tt_global_entry)
 {
 	kref_put(&tt_global_entry->common.refcount,
 		 batadv_tt_global_entry_release);
@@ -278,7 +278,7 @@ int batadv_tt_global_hash_count(struct batadv_priv *bat_priv,
 		return 0;
 
 	count = atomic_read(&tt_global_entry->orig_list_count);
-	batadv_tt_global_entry_free_ref(tt_global_entry);
+	batadv_tt_global_entry_put(tt_global_entry);
 
 	return count;
 }
@@ -561,7 +561,7 @@ static void batadv_tt_global_free(struct batadv_priv *bat_priv,
 
 	batadv_hash_remove(bat_priv->tt.global_hash, batadv_compare_tt,
 			   batadv_choose_tt, &tt_global->common);
-	batadv_tt_global_entry_free_ref(tt_global);
+	batadv_tt_global_entry_put(tt_global);
 }
 
 /**
@@ -756,7 +756,7 @@ out:
 	if (tt_local)
 		batadv_tt_local_entry_put(tt_local);
 	if (tt_global)
-		batadv_tt_global_entry_free_ref(tt_global);
+		batadv_tt_global_entry_put(tt_global);
 	return ret;
 }
 
@@ -1467,7 +1467,7 @@ static bool batadv_tt_global_add(struct batadv_priv *bat_priv,
 
 		if (unlikely(hash_added != 0)) {
 			/* remove the reference for the hash */
-			batadv_tt_global_entry_free_ref(tt_global_entry);
+			batadv_tt_global_entry_put(tt_global_entry);
 			goto out_remove;
 		}
 	} else {
@@ -1553,7 +1553,7 @@ out_remove:
 
 out:
 	if (tt_global_entry)
-		batadv_tt_global_entry_free_ref(tt_global_entry);
+		batadv_tt_global_entry_put(tt_global_entry);
 	if (tt_local_entry)
 		batadv_tt_local_entry_put(tt_local_entry);
 	return ret;
@@ -1909,7 +1909,7 @@ static void batadv_tt_global_del(struct batadv_priv *bat_priv,
 
 out:
 	if (tt_global_entry)
-		batadv_tt_global_entry_free_ref(tt_global_entry);
+		batadv_tt_global_entry_put(tt_global_entry);
 	if (local_entry)
 		batadv_tt_local_entry_put(local_entry);
 }
@@ -1965,7 +1965,7 @@ void batadv_tt_global_del_orig(struct batadv_priv *bat_priv,
 					   tt_global->common.addr,
 					   BATADV_PRINT_VID(vid), message);
 				hlist_del_rcu(&tt_common_entry->hash_entry);
-				batadv_tt_global_entry_free_ref(tt_global);
+				batadv_tt_global_entry_put(tt_global);
 			}
 		}
 		spin_unlock_bh(list_lock);
@@ -2028,7 +2028,7 @@ static void batadv_tt_global_purge(struct batadv_priv *bat_priv)
 
 			hlist_del_rcu(&tt_common->hash_entry);
 
-			batadv_tt_global_entry_free_ref(tt_global);
+			batadv_tt_global_entry_put(tt_global);
 		}
 		spin_unlock_bh(list_lock);
 	}
@@ -2060,7 +2060,7 @@ static void batadv_tt_global_table_free(struct batadv_priv *bat_priv)
 			tt_global = container_of(tt_common_entry,
 						 struct batadv_tt_global_entry,
 						 common);
-			batadv_tt_global_entry_free_ref(tt_global);
+			batadv_tt_global_entry_put(tt_global);
 		}
 		spin_unlock_bh(list_lock);
 	}
@@ -2141,7 +2141,7 @@ struct batadv_orig_node *batadv_transtable_search(struct batadv_priv *bat_priv,
 
 out:
 	if (tt_global_entry)
-		batadv_tt_global_entry_free_ref(tt_global_entry);
+		batadv_tt_global_entry_put(tt_global_entry);
 	if (tt_local_entry)
 		batadv_tt_local_entry_put(tt_local_entry);
 
@@ -3431,7 +3431,7 @@ bool batadv_is_ap_isolated(struct batadv_priv *bat_priv, u8 *src, u8 *dst,
 out:
 	batadv_softif_vlan_put(vlan);
 	if (tt_global_entry)
-		batadv_tt_global_entry_free_ref(tt_global_entry);
+		batadv_tt_global_entry_put(tt_global_entry);
 	if (tt_local_entry)
 		batadv_tt_local_entry_put(tt_local_entry);
 	return ret;
@@ -3543,7 +3543,7 @@ bool batadv_tt_global_client_is_roaming(struct batadv_priv *bat_priv,
 		goto out;
 
 	ret = tt_global_entry->common.flags & BATADV_TT_CLIENT_ROAM;
-	batadv_tt_global_entry_free_ref(tt_global_entry);
+	batadv_tt_global_entry_put(tt_global_entry);
 out:
 	return ret;
 }
@@ -3863,7 +3863,7 @@ bool batadv_tt_global_is_isolated(struct batadv_priv *bat_priv,
 
 	ret = tt->common.flags & BATADV_TT_CLIENT_ISOLA;
 
-	batadv_tt_global_entry_free_ref(tt);
+	batadv_tt_global_entry_put(tt);
 
 	return ret;
 }
-- 
2.7.1
