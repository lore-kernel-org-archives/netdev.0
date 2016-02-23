From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 17/20] batman-adv: Rename batadv_orig_node_vlan *_free_ref function to *_put
Date: Tue, 23 Feb 2016 14:08:20 +0800
Message-ID: <1456207703-903-18-git-send-email-a@unstable.cc>
References: <1456207703-903-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:9383 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756677AbcBWGUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 01:20:20 -0500
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
 net/batman-adv/originator.c        |  8 ++++----
 net/batman-adv/originator.h        |  2 +-
 net/batman-adv/translation-table.c | 10 +++++-----
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 0b1a77da2e1e..e4cbb0753e37 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -151,11 +151,11 @@ static void batadv_orig_node_vlan_release(struct kref *ref)
 }
 
 /**
- * batadv_orig_node_vlan_free_ref - decrement the refcounter and possibly
- *  release the originator-vlan object
+ * batadv_orig_node_vlan_put - decrement the refcounter and possibly release
+ *  the originator-vlan object
  * @orig_vlan: the originator-vlan object to release
  */
-void batadv_orig_node_vlan_free_ref(struct batadv_orig_node_vlan *orig_vlan)
+void batadv_orig_node_vlan_put(struct batadv_orig_node_vlan *orig_vlan)
 {
 	kref_put(&orig_vlan->refcount, batadv_orig_node_vlan_release);
 }
@@ -917,7 +917,7 @@ struct batadv_orig_node *batadv_orig_node_new(struct batadv_priv *bat_priv,
 	 * Immediately release vlan since it is not needed anymore in this
 	 * context
 	 */
-	batadv_orig_node_vlan_free_ref(vlan);
+	batadv_orig_node_vlan_put(vlan);
 
 	for (i = 0; i < BATADV_FRAG_BUFFER_COUNT; i++) {
 		INIT_HLIST_HEAD(&orig_node->fragments[i].head);
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 97748e84b66b..4e8b67f11051 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -83,7 +83,7 @@ batadv_orig_node_vlan_new(struct batadv_orig_node *orig_node,
 struct batadv_orig_node_vlan *
 batadv_orig_node_vlan_get(struct batadv_orig_node *orig_node,
 			  unsigned short vid);
-void batadv_orig_node_vlan_free_ref(struct batadv_orig_node_vlan *orig_vlan);
+void batadv_orig_node_vlan_put(struct batadv_orig_node_vlan *orig_vlan);
 
 /* hashfunction to choose an entry in a hash table of given size
  * hash algorithm from http://en.wikipedia.org/wiki/Hash_table
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index b81f8ea3395d..396b095c8a1d 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -348,12 +348,12 @@ static void batadv_tt_global_size_mod(struct batadv_orig_node *orig_node,
 		spin_lock_bh(&orig_node->vlan_list_lock);
 		if (!hlist_unhashed(&vlan->list)) {
 			hlist_del_init_rcu(&vlan->list);
-			batadv_orig_node_vlan_free_ref(vlan);
+			batadv_orig_node_vlan_put(vlan);
 		}
 		spin_unlock_bh(&orig_node->vlan_list_lock);
 	}
 
-	batadv_orig_node_vlan_free_ref(vlan);
+	batadv_orig_node_vlan_put(vlan);
 }
 
 /**
@@ -1652,7 +1652,7 @@ batadv_tt_global_print_entry(struct batadv_priv *bat_priv,
 			   ((flags & BATADV_TT_CLIENT_ISOLA) ? 'I' : '.'),
 			   ((flags & BATADV_TT_CLIENT_TEMP) ? 'T' : '.'));
 
-		batadv_orig_node_vlan_free_ref(vlan);
+		batadv_orig_node_vlan_put(vlan);
 	}
 
 print_list:
@@ -1684,7 +1684,7 @@ print_list:
 			   ((flags & BATADV_TT_CLIENT_ISOLA) ? 'I' : '.'),
 			   ((flags & BATADV_TT_CLIENT_TEMP) ? 'T' : '.'));
 
-		batadv_orig_node_vlan_free_ref(vlan);
+		batadv_orig_node_vlan_put(vlan);
 	}
 }
 
@@ -2503,7 +2503,7 @@ static bool batadv_tt_global_check_crc(struct batadv_orig_node *orig_node,
 			return false;
 
 		crc = vlan->tt.crc;
-		batadv_orig_node_vlan_free_ref(vlan);
+		batadv_orig_node_vlan_put(vlan);
 
 		if (crc != ntohl(tt_vlan_tmp->crc))
 			return false;
-- 
2.7.1
