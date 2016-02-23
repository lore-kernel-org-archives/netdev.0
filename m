From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 07/20] batman-adv: Rename batadv_hardif_neigh *_free_ref function to *_put
Date: Tue, 23 Feb 2016 14:08:10 +0800
Message-ID: <1456207703-903-8-git-send-email-a@unstable.cc>
References: <1456207703-903-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:9600 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757072AbcBWGLK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 01:11:10 -0500
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
 net/batman-adv/bat_iv_ogm.c |  2 +-
 net/batman-adv/originator.c | 10 +++++-----
 net/batman-adv/originator.h |  2 +-
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index ba48fb2818fc..5651e33ca6bd 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1574,7 +1574,7 @@ out:
 	if (orig_neigh_router)
 		batadv_neigh_node_put(orig_neigh_router);
 	if (hardif_neigh)
-		batadv_hardif_neigh_free_ref(hardif_neigh);
+		batadv_hardif_neigh_put(hardif_neigh);
 
 	kfree_skb(skb_priv);
 }
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 605641536c82..0b1a77da2e1e 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -232,11 +232,11 @@ static void batadv_hardif_neigh_release(struct kref *ref)
 }
 
 /**
- * batadv_hardif_neigh_free_ref - decrement the hardif neighbors refcounter
+ * batadv_hardif_neigh_put - decrement the hardif neighbors refcounter
  *  and possibly release it
  * @hardif_neigh: hardif neigh neighbor to free
  */
-void batadv_hardif_neigh_free_ref(struct batadv_hardif_neigh_node *hardif_neigh)
+void batadv_hardif_neigh_put(struct batadv_hardif_neigh_node *hardif_neigh)
 {
 	kref_put(&hardif_neigh->refcount, batadv_hardif_neigh_release);
 }
@@ -266,8 +266,8 @@ static void batadv_neigh_node_release(struct kref *ref)
 					       neigh_node->addr);
 	if (hardif_neigh) {
 		/* batadv_hardif_neigh_get() increases refcount too */
-		batadv_hardif_neigh_free_ref(hardif_neigh);
-		batadv_hardif_neigh_free_ref(hardif_neigh);
+		batadv_hardif_neigh_put(hardif_neigh);
+		batadv_hardif_neigh_put(hardif_neigh);
 	}
 
 	if (bao->bat_neigh_free)
@@ -681,7 +681,7 @@ batadv_neigh_node_new(struct batadv_orig_node *orig_node,
 
 out:
 	if (hardif_neigh)
-		batadv_hardif_neigh_free_ref(hardif_neigh);
+		batadv_hardif_neigh_put(hardif_neigh);
 	return neigh_node;
 }
 
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index adbe7aa749a9..97748e84b66b 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -44,7 +44,7 @@ struct batadv_hardif_neigh_node *
 batadv_hardif_neigh_get(const struct batadv_hard_iface *hard_iface,
 			const u8 *neigh_addr);
 void
-batadv_hardif_neigh_free_ref(struct batadv_hardif_neigh_node *hardif_neigh);
+batadv_hardif_neigh_put(struct batadv_hardif_neigh_node *hardif_neigh);
 struct batadv_neigh_node *
 batadv_neigh_node_new(struct batadv_orig_node *orig_node,
 		      struct batadv_hard_iface *hard_iface,
-- 
2.7.1
