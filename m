From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 05/10] batman-adv: rearrange batadv_neigh_node_new() arguments to follow convention
Date: Fri, 28 Aug 2015 11:12:31 +0200
Message-ID: <1440753156-7808-6-git-send-email-antonio@meshcoding.com>
References: <1440753156-7808-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:17465 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752339AbbH1JNz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2015 05:13:55 -0400
In-Reply-To: <1440753156-7808-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Acked-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c | 2 +-
 net/batman-adv/originator.c | 7 ++++---
 net/batman-adv/originator.h | 5 +++--
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 5e93af4..912d9c3 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -298,7 +298,7 @@ batadv_iv_ogm_neigh_new(struct batadv_hard_iface *hard_iface,
 {
 	struct batadv_neigh_node *neigh_node;
 
-	neigh_node = batadv_neigh_node_new(hard_iface, neigh_addr, orig_node);
+	neigh_node = batadv_neigh_node_new(orig_node, hard_iface, neigh_addr);
 	if (!neigh_node)
 		goto out;
 
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index d6d9809..099a84a 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -444,16 +444,17 @@ out:
 
 /**
  * batadv_neigh_node_new - create and init a new neigh_node object
+ * @orig_node: originator object representing the neighbour
  * @hard_iface: the interface where the neighbour is connected to
  * @neigh_addr: the mac address of the neighbour interface
- * @orig_node: originator object representing the neighbour
  *
  * Allocates a new neigh_node object and initialises all the generic fields.
  * Returns the new object or NULL on failure.
  */
 struct batadv_neigh_node *
-batadv_neigh_node_new(struct batadv_hard_iface *hard_iface,
-		      const u8 *neigh_addr, struct batadv_orig_node *orig_node)
+batadv_neigh_node_new(struct batadv_orig_node *orig_node,
+		      struct batadv_hard_iface *hard_iface,
+		      const u8 *neigh_addr)
 {
 	struct batadv_neigh_node *neigh_node;
 
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 3fc76f6..fde3438 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -46,8 +46,9 @@ batadv_neigh_node_get(const struct batadv_orig_node *orig_node,
 		      const struct batadv_hard_iface *hard_iface,
 		      const u8 *addr);
 struct batadv_neigh_node *
-batadv_neigh_node_new(struct batadv_hard_iface *hard_iface,
-		      const u8 *neigh_addr, struct batadv_orig_node *orig_node);
+batadv_neigh_node_new(struct batadv_orig_node *orig_node,
+		      struct batadv_hard_iface *hard_iface,
+		      const u8 *neigh_addr);
 void batadv_neigh_node_free_ref(struct batadv_neigh_node *neigh_node);
 struct batadv_neigh_node *
 batadv_orig_router_get(struct batadv_orig_node *orig_node,
-- 
2.5.0
