From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 6/7][MAC80211]: Merge error paths in mesh_table_grow().
Date: Wed, 07 May 2008 19:55:59 +0400
Message-ID: <4821D10F.4020702@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is the first (of two) clean ups after the fixes above.

The err variable is not even required after this cleaning.

Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

---
 net/mac80211/mesh.c |   16 ++++------------
 1 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index 273f0b6..f46fbdb 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -350,20 +350,15 @@ struct mesh_table *mesh_table_grow(struct mesh_table *tbl)
 	struct mesh_table *newtbl;
 	struct hlist_head *oldhash;
 	struct hlist_node *p, *q;
-	int err = 0;
 	int i;
 
 	if (atomic_read(&tbl->entries)
-			< tbl->mean_chain_len * (tbl->hash_mask + 1)) {
-		err = -EPERM;
+			< tbl->mean_chain_len * (tbl->hash_mask + 1))
 		goto endgrow;
-	}
 
 	newtbl = mesh_table_alloc(tbl->size_order + 1);
-	if (!newtbl) {
-		err = -ENOMEM;
+	if (!newtbl)
 		goto endgrow;
-	}
 
 	newtbl->free_node = tbl->free_node;
 	newtbl->mean_chain_len = tbl->mean_chain_len;
@@ -376,11 +371,7 @@ struct mesh_table *mesh_table_grow(struct mesh_table *tbl)
 			if (tbl->copy_node(p, newtbl) < 0)
 				goto errcopy;
 
-endgrow:
-	if (err)
-		return NULL;
-	else
-		return newtbl;
+	return newtbl;
 
 errcopy:
 	for (i = 0; i <= newtbl->hash_mask; i++) {
@@ -390,6 +381,7 @@ errcopy:
 	kfree(newtbl->hash_buckets);
 	kfree(newtbl->hashwlock);
 	kfree(newtbl);
+endgrow:
 	return NULL;
 }
 
-- 
1.5.3.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
