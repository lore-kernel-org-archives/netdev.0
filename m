From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 16/20] batman-adv: Rename batadv_nc_path *_free_ref function to *_put
Date: Tue, 23 Feb 2016 14:08:19 +0800
Message-ID: <1456207703-903-17-git-send-email-a__37836.4912387498$1456208507$gmane$org@unstable.cc>
References: <1456207703-903-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:45769 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753523AbcBWGVk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 01:21:40 -0500
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
 net/batman-adv/network-coding.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 6105cfb0574c..d253bb23e2ac 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -247,11 +247,11 @@ static void batadv_nc_path_release(struct kref *ref)
 }
 
 /**
- * batadv_nc_path_free_ref - decrement the nc_path refcounter and possibly
+ * batadv_nc_path_put - decrement the nc_path refcounter and possibly
  *  release it
  * @nc_path: nc_path to be free'd
  */
-static void batadv_nc_path_free_ref(struct batadv_nc_path *nc_path)
+static void batadv_nc_path_put(struct batadv_nc_path *nc_path)
 {
 	kref_put(&nc_path->refcount, batadv_nc_path_release);
 }
@@ -263,7 +263,7 @@ static void batadv_nc_path_free_ref(struct batadv_nc_path *nc_path)
 static void batadv_nc_packet_free(struct batadv_nc_packet *nc_packet)
 {
 	kfree_skb(nc_packet->skb);
-	batadv_nc_path_free_ref(nc_packet->nc_path);
+	batadv_nc_path_put(nc_packet->nc_path);
 	kfree(nc_packet);
 }
 
@@ -467,7 +467,7 @@ static void batadv_nc_purge_paths(struct batadv_priv *bat_priv,
 				   "Remove nc_path %pM -> %pM\n",
 				   nc_path->prev_hop, nc_path->next_hop);
 			hlist_del_rcu(&nc_path->hash_entry);
-			batadv_nc_path_free_ref(nc_path);
+			batadv_nc_path_put(nc_path);
 		}
 		spin_unlock_bh(lock);
 	}
@@ -1555,7 +1555,7 @@ bool batadv_nc_skb_forward(struct sk_buff *skb,
 	return true;
 
 free_nc_path:
-	batadv_nc_path_free_ref(nc_path);
+	batadv_nc_path_put(nc_path);
 out:
 	/* Packet is not consumed */
 	return false;
@@ -1617,7 +1617,7 @@ void batadv_nc_skb_store_for_decoding(struct batadv_priv *bat_priv,
 free_skb:
 	kfree_skb(skb);
 free_nc_path:
-	batadv_nc_path_free_ref(nc_path);
+	batadv_nc_path_put(nc_path);
 out:
 	return;
 }
-- 
2.7.1
