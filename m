From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 04/15] batman-adv: update kernel doc of batadv_tt_global_del_orig_entry()
Date: Tue, 25 Aug 2015 13:02:28 +0200
Message-ID: <1440500559-28368-5-git-send-email-antonio__22422.8370273069$1440500680$gmane$org@meshcoding.com>
References: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:17674 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755134AbbHYLDy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 07:03:54 -0400
In-Reply-To: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

The updated kernel doc & additional comment shall prevent accidental
copy & paste errors or calling the function without the required
precautions.

Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/translation-table.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 7e34901..6b5f718 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1658,20 +1658,26 @@ out:
 }
 
 /**
- * batadv_tt_global_del_orig_entry - remove and free an orig_entry
+ * _batadv_tt_global_del_orig_entry - remove and free an orig_entry
  * @tt_global_entry: the global entry to remove the orig_entry from
  * @orig_entry: the orig entry to remove and free
  *
  * Remove an orig_entry from its list in the given tt_global_entry and
  * free this orig_entry afterwards.
+ *
+ * Caller must hold tt_global_entry->list_lock and ensure orig_entry->list is
+ * part of a list.
  */
 static void
-batadv_tt_global_del_orig_entry(struct batadv_tt_global_entry *tt_global_entry,
-				struct batadv_tt_orig_list_entry *orig_entry)
+_batadv_tt_global_del_orig_entry(struct batadv_tt_global_entry *tt_global_entry,
+				 struct batadv_tt_orig_list_entry *orig_entry)
 {
 	batadv_tt_global_size_dec(orig_entry->orig_node,
 				  tt_global_entry->common.vid);
 	atomic_dec(&tt_global_entry->orig_list_count);
+	/* requires holding tt_global_entry->list_lock and orig_entry->list
+	 * being part of a list
+	 */
 	hlist_del_rcu(&orig_entry->list);
 	batadv_tt_orig_list_entry_free_ref(orig_entry);
 }
@@ -1687,7 +1693,7 @@ batadv_tt_global_del_orig_list(struct batadv_tt_global_entry *tt_global_entry)
 	spin_lock_bh(&tt_global_entry->list_lock);
 	head = &tt_global_entry->orig_list;
 	hlist_for_each_entry_safe(orig_entry, safe, head, list)
-		batadv_tt_global_del_orig_entry(tt_global_entry, orig_entry);
+		_batadv_tt_global_del_orig_entry(tt_global_entry, orig_entry);
 	spin_unlock_bh(&tt_global_entry->list_lock);
 }
 
@@ -1722,8 +1728,8 @@ batadv_tt_global_del_orig_node(struct batadv_priv *bat_priv,
 				   orig_node->orig,
 				   tt_global_entry->common.addr,
 				   BATADV_PRINT_VID(vid), message);
-			batadv_tt_global_del_orig_entry(tt_global_entry,
-							orig_entry);
+			_batadv_tt_global_del_orig_entry(tt_global_entry,
+							 orig_entry);
 		}
 	}
 	spin_unlock_bh(&tt_global_entry->list_lock);
-- 
2.5.0
