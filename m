From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 12/20] batman-adv: Rename batadv_tvlv_handler *_free_ref function to *_put
Date: Tue, 23 Feb 2016 14:08:15 +0800
Message-ID: <1456207703-903-13-git-send-email-a@unstable.cc>
References: <1456207703-903-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:38897 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757049AbcBWGV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 01:21:56 -0500
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
 net/batman-adv/main.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 476554b3adce..95aaff371966 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -638,12 +638,11 @@ static void batadv_tvlv_handler_release(struct kref *ref)
 }
 
 /**
- * batadv_tvlv_handler_free_ref - decrement the tvlv container refcounter and
+ * batadv_tvlv_handler_put - decrement the tvlv container refcounter and
  *  possibly release it
  * @tvlv_handler: the tvlv handler to free
  */
-static void
-batadv_tvlv_handler_free_ref(struct batadv_tvlv_handler *tvlv_handler)
+static void batadv_tvlv_handler_put(struct batadv_tvlv_handler *tvlv_handler)
 {
 	kref_put(&tvlv_handler->refcount, batadv_tvlv_handler_release);
 }
@@ -1031,7 +1030,7 @@ int batadv_tvlv_containers_process(struct batadv_priv *bat_priv,
 						src, dst, tvlv_value,
 						tvlv_value_cont_len);
 		if (tvlv_handler)
-			batadv_tvlv_handler_free_ref(tvlv_handler);
+			batadv_tvlv_handler_put(tvlv_handler);
 		tvlv_value = (u8 *)tvlv_value + tvlv_value_cont_len;
 		tvlv_value_len -= tvlv_value_cont_len;
 	}
@@ -1111,7 +1110,7 @@ void batadv_tvlv_handler_register(struct batadv_priv *bat_priv,
 
 	tvlv_handler = batadv_tvlv_handler_get(bat_priv, type, version);
 	if (tvlv_handler) {
-		batadv_tvlv_handler_free_ref(tvlv_handler);
+		batadv_tvlv_handler_put(tvlv_handler);
 		return;
 	}
 
@@ -1148,11 +1147,11 @@ void batadv_tvlv_handler_unregister(struct batadv_priv *bat_priv,
 	if (!tvlv_handler)
 		return;
 
-	batadv_tvlv_handler_free_ref(tvlv_handler);
+	batadv_tvlv_handler_put(tvlv_handler);
 	spin_lock_bh(&bat_priv->tvlv.handler_list_lock);
 	hlist_del_rcu(&tvlv_handler->list);
 	spin_unlock_bh(&bat_priv->tvlv.handler_list_lock);
-	batadv_tvlv_handler_free_ref(tvlv_handler);
+	batadv_tvlv_handler_put(tvlv_handler);
 }
 
 /**
-- 
2.7.1
