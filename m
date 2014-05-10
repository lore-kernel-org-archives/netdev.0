From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 3/4] batman-adv: always run purge_orig_neighbors
Date: Sat, 10 May 2014 17:35:09 +0200
Message-ID: <1399736110-22333-4-git-send-email-antonio@meshcoding.com>
References: <1399736110-22333-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:25077 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004AbaEJPgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 May 2014 11:36:33 -0400
In-Reply-To: <1399736110-22333-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

The current code will not execute batadv_purge_orig_neighbors() when an
orig_ifinfo has already been purged. However we need to run it in any
case. Fix that.

This is a regression introduced by
7351a4822d42827ba0110677c0cbad88a3d52585
("batman-adv: split out router from orig_node")

Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/originator.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index a43da69..8104c3c 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -862,7 +862,7 @@ static bool batadv_purge_orig_node(struct batadv_priv *bat_priv,
 {
 	struct batadv_neigh_node *best_neigh_node;
 	struct batadv_hard_iface *hard_iface;
-	bool changed;
+	bool changed_ifinfo, changed_neigh;
 
 	if (batadv_has_timed_out(orig_node->last_seen,
 				 2 * BATADV_PURGE_TIMEOUT)) {
@@ -872,10 +872,10 @@ static bool batadv_purge_orig_node(struct batadv_priv *bat_priv,
 			   jiffies_to_msecs(orig_node->last_seen));
 		return true;
 	}
-	changed = batadv_purge_orig_ifinfo(bat_priv, orig_node);
-	changed = changed || batadv_purge_orig_neighbors(bat_priv, orig_node);
+	changed_ifinfo = batadv_purge_orig_ifinfo(bat_priv, orig_node);
+	changed_neigh = batadv_purge_orig_neighbors(bat_priv, orig_node);
 
-	if (!changed)
+	if (!changed_ifinfo && !changed_neigh)
 		return false;
 
 	/* first for NULL ... */
-- 
1.8.5.5
