From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 18/20] batman-adv: Rename batadv_tt_local_entry *_free_ref function to *_put
Date: Tue, 23 Feb 2016 14:08:21 +0800
Message-ID: <1456207703-903-19-git-send-email-a__33813.7610503056$1456208432$gmane$org@unstable.cc>
References: <1456207703-903-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:11625 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750736AbcBWGUQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 01:20:16 -0500
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
 net/batman-adv/translation-table.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 396b095c8a1d..de3e731542e3 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -219,12 +219,12 @@ static void batadv_tt_local_entry_release(struct kref *ref)
 }
 
 /**
- * batadv_tt_local_entry_free_ref - decrement the tt_local_entry refcounter and
+ * batadv_tt_local_entry_put - decrement the tt_local_entry refcounter and
  *  possibly release it
  * @tt_local_entry: tt_local_entry to be free'd
  */
 static void
-batadv_tt_local_entry_free_ref(struct batadv_tt_local_entry *tt_local_entry)
+batadv_tt_local_entry_put(struct batadv_tt_local_entry *tt_local_entry)
 {
 	kref_put(&tt_local_entry->common.refcount,
 		 batadv_tt_local_entry_release);
@@ -687,7 +687,7 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
 
 	if (unlikely(hash_added != 0)) {
 		/* remove the reference for the hash */
-		batadv_tt_local_entry_free_ref(tt_local);
+		batadv_tt_local_entry_put(tt_local);
 		batadv_softif_vlan_put(vlan);
 		goto out;
 	}
@@ -754,7 +754,7 @@ out:
 	if (in_dev)
 		dev_put(in_dev);
 	if (tt_local)
-		batadv_tt_local_entry_free_ref(tt_local);
+		batadv_tt_local_entry_put(tt_local);
 	if (tt_global)
 		batadv_tt_global_entry_free_ref(tt_global);
 	return ret;
@@ -1137,7 +1137,7 @@ u16 batadv_tt_local_remove(struct batadv_priv *bat_priv, const u8 *addr,
 		goto out;
 
 	/* extra call to free the local tt entry */
-	batadv_tt_local_entry_free_ref(tt_local_entry);
+	batadv_tt_local_entry_put(tt_local_entry);
 
 	/* decrease the reference held for this vlan */
 	vlan = batadv_softif_vlan_get(bat_priv, vid);
@@ -1149,7 +1149,7 @@ u16 batadv_tt_local_remove(struct batadv_priv *bat_priv, const u8 *addr,
 
 out:
 	if (tt_local_entry)
-		batadv_tt_local_entry_free_ref(tt_local_entry);
+		batadv_tt_local_entry_put(tt_local_entry);
 
 	return curr_flags;
 }
@@ -1249,7 +1249,7 @@ static void batadv_tt_local_table_free(struct batadv_priv *bat_priv)
 				batadv_softif_vlan_put(vlan);
 			}
 
-			batadv_tt_local_entry_free_ref(tt_local);
+			batadv_tt_local_entry_put(tt_local);
 		}
 		spin_unlock_bh(list_lock);
 	}
@@ -1555,7 +1555,7 @@ out:
 	if (tt_global_entry)
 		batadv_tt_global_entry_free_ref(tt_global_entry);
 	if (tt_local_entry)
-		batadv_tt_local_entry_free_ref(tt_local_entry);
+		batadv_tt_local_entry_put(tt_local_entry);
 	return ret;
 }
 
@@ -1911,7 +1911,7 @@ out:
 	if (tt_global_entry)
 		batadv_tt_global_entry_free_ref(tt_global_entry);
 	if (local_entry)
-		batadv_tt_local_entry_free_ref(local_entry);
+		batadv_tt_local_entry_put(local_entry);
 }
 
 /**
@@ -2143,7 +2143,7 @@ out:
 	if (tt_global_entry)
 		batadv_tt_global_entry_free_ref(tt_global_entry);
 	if (tt_local_entry)
-		batadv_tt_local_entry_free_ref(tt_local_entry);
+		batadv_tt_local_entry_put(tt_local_entry);
 
 	return orig_node;
 }
@@ -3023,7 +3023,7 @@ bool batadv_is_my_client(struct batadv_priv *bat_priv, const u8 *addr,
 	ret = true;
 out:
 	if (tt_local_entry)
-		batadv_tt_local_entry_free_ref(tt_local_entry);
+		batadv_tt_local_entry_put(tt_local_entry);
 	return ret;
 }
 
@@ -3346,7 +3346,7 @@ static void batadv_tt_local_purge_pending_clients(struct batadv_priv *bat_priv)
 				batadv_softif_vlan_put(vlan);
 			}
 
-			batadv_tt_local_entry_free_ref(tt_local);
+			batadv_tt_local_entry_put(tt_local);
 		}
 		spin_unlock_bh(list_lock);
 	}
@@ -3433,7 +3433,7 @@ out:
 	if (tt_global_entry)
 		batadv_tt_global_entry_free_ref(tt_global_entry);
 	if (tt_local_entry)
-		batadv_tt_local_entry_free_ref(tt_local_entry);
+		batadv_tt_local_entry_put(tt_local_entry);
 	return ret;
 }
 
@@ -3569,7 +3569,7 @@ bool batadv_tt_local_client_is_roaming(struct batadv_priv *bat_priv,
 		goto out;
 
 	ret = tt_local_entry->common.flags & BATADV_TT_CLIENT_ROAM;
-	batadv_tt_local_entry_free_ref(tt_local_entry);
+	batadv_tt_local_entry_put(tt_local_entry);
 out:
 	return ret;
 }
-- 
2.7.1
