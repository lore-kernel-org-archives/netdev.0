From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 20/20] batman-adv: Rename batadv_tt_orig_list_entry *_free_ref function to *_put
Date: Tue, 23 Feb 2016 14:08:23 +0800
Message-ID: <1456207703-903-21-git-send-email-a__16489.2509034418$1456208423$gmane$org@unstable.cc>
References: <1456207703-903-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:43549 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750736AbcBWGUM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 01:20:12 -0500
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
 net/batman-adv/translation-table.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 7f65a8f17f52..0b43e86328a5 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -397,12 +397,12 @@ static void batadv_tt_orig_list_entry_release(struct kref *ref)
 }
 
 /**
- * batadv_tt_orig_list_entry_free_ref - decrement the tt orig entry refcounter
- *  and possibly release it
+ * batadv_tt_orig_list_entry_put - decrement the tt orig entry refcounter and
+ *  possibly release it
  * @orig_entry: tt orig entry to be free'd
  */
 static void
-batadv_tt_orig_list_entry_free_ref(struct batadv_tt_orig_list_entry *orig_entry)
+batadv_tt_orig_list_entry_put(struct batadv_tt_orig_list_entry *orig_entry)
 {
 	kref_put(&orig_entry->refcount, batadv_tt_orig_list_entry_release);
 }
@@ -1345,7 +1345,7 @@ batadv_tt_global_entry_has_orig(const struct batadv_tt_global_entry *entry,
 	orig_entry = batadv_tt_global_orig_entry_find(entry, orig_node);
 	if (orig_entry) {
 		found = true;
-		batadv_tt_orig_list_entry_free_ref(orig_entry);
+		batadv_tt_orig_list_entry_put(orig_entry);
 	}
 
 	return found;
@@ -1386,7 +1386,7 @@ batadv_tt_global_orig_entry_add(struct batadv_tt_global_entry *tt_global,
 
 out:
 	if (orig_entry)
-		batadv_tt_orig_list_entry_free_ref(orig_entry);
+		batadv_tt_orig_list_entry_put(orig_entry);
 }
 
 /**
@@ -1753,7 +1753,7 @@ _batadv_tt_global_del_orig_entry(struct batadv_tt_global_entry *tt_global_entry,
 	 * being part of a list
 	 */
 	hlist_del_rcu(&orig_entry->list);
-	batadv_tt_orig_list_entry_free_ref(orig_entry);
+	batadv_tt_orig_list_entry_put(orig_entry);
 }
 
 /* deletes the orig list of a tt_global_entry */
-- 
2.7.1
