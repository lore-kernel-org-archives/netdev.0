From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 07/12] batman-adv: rename equiv/equal or better to similar or better
Date: Wed, 16 Dec 2015 15:49:28 +0800
Message-ID: <1450252173-20949-8-git-send-email-antonio@meshcoding.com>
References: <1450252173-20949-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:23008 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932763AbbLPHva (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 02:51:30 -0500
In-Reply-To: <1450252173-20949-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>

Since the function applies a threshold and also slightly worse
values are accepted, ''equal or better'' does not represent the
intention of the function. ''Similar or better'' represents that better.

Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c | 8 ++++----
 net/batman-adv/main.c       | 2 +-
 net/batman-adv/routing.c    | 6 +++---
 net/batman-adv/types.h      | 6 +++---
 4 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 3738a2f..5677169 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1964,8 +1964,8 @@ out:
 }
 
 /**
- * batadv_iv_ogm_neigh_is_eob - check if neigh1 is equally good or better than
- *  neigh2 from the metric prospective
+ * batadv_iv_ogm_neigh_is_sob - check if neigh1 is similarly good or better
+ *  than neigh2 from the metric prospective
  * @neigh1: the first neighbor object of the comparison
  * @if_outgoing1: outgoing interface for the first neighbor
  * @neigh2: the second neighbor object of the comparison
@@ -1975,7 +1975,7 @@ out:
  * the metric via neigh2, false otherwise.
  */
 static bool
-batadv_iv_ogm_neigh_is_eob(struct batadv_neigh_node *neigh1,
+batadv_iv_ogm_neigh_is_sob(struct batadv_neigh_node *neigh1,
 			   struct batadv_hard_iface *if_outgoing1,
 			   struct batadv_neigh_node *neigh2,
 			   struct batadv_hard_iface *if_outgoing2)
@@ -2015,7 +2015,7 @@ static struct batadv_algo_ops batadv_batman_iv __read_mostly = {
 	.bat_ogm_schedule = batadv_iv_ogm_schedule,
 	.bat_ogm_emit = batadv_iv_ogm_emit,
 	.bat_neigh_cmp = batadv_iv_ogm_neigh_cmp,
-	.bat_neigh_is_equiv_or_better = batadv_iv_ogm_neigh_is_eob,
+	.bat_neigh_is_similar_or_better = batadv_iv_ogm_neigh_is_sob,
 	.bat_neigh_print = batadv_iv_neigh_print,
 	.bat_orig_print = batadv_iv_ogm_orig_print,
 	.bat_orig_free = batadv_iv_ogm_orig_free,
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index d7f17c1..45952dc 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -552,7 +552,7 @@ int batadv_algo_register(struct batadv_algo_ops *bat_algo_ops)
 	    !bat_algo_ops->bat_ogm_schedule ||
 	    !bat_algo_ops->bat_ogm_emit ||
 	    !bat_algo_ops->bat_neigh_cmp ||
-	    !bat_algo_ops->bat_neigh_is_equiv_or_better) {
+	    !bat_algo_ops->bat_neigh_is_similar_or_better) {
 		pr_info("Routing algo '%s' does not implement required ops\n",
 			bat_algo_ops->name);
 		return -EINVAL;
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 8d990b0..a43f02e 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -497,9 +497,9 @@ batadv_find_router(struct batadv_priv *bat_priv,
 		/* alternative candidate should be good enough to be
 		 * considered
 		 */
-		if (!bao->bat_neigh_is_equiv_or_better(cand_router,
-						       cand->if_outgoing,
-						       router, recv_if))
+		if (!bao->bat_neigh_is_similar_or_better(cand_router,
+							 cand->if_outgoing,
+							 router, recv_if))
 			goto next;
 
 		/* don't use the same router twice */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 815c960..9bdb21c 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1156,8 +1156,8 @@ struct batadv_forw_packet {
  * @bat_hardif_neigh_init: called on creation of single hop entry
  * @bat_neigh_cmp: compare the metrics of two neighbors for their respective
  *  outgoing interfaces
- * @bat_neigh_is_equiv_or_better: check if neigh1 is equally good or better
- *  than neigh2 for their respective outgoing interface from the metric
+ * @bat_neigh_is_similar_or_better: check if neigh1 is equally similar or
+ *  better than neigh2 for their respective outgoing interface from the metric
  *  prospective
  * @bat_neigh_print: print the single hop neighbor list (optional)
  * @bat_neigh_free: free the resources allocated by the routing algorithm for a
@@ -1185,7 +1185,7 @@ struct batadv_algo_ops {
 			     struct batadv_hard_iface *if_outgoing1,
 			     struct batadv_neigh_node *neigh2,
 			     struct batadv_hard_iface *if_outgoing2);
-	bool (*bat_neigh_is_equiv_or_better)
+	bool (*bat_neigh_is_similar_or_better)
 		(struct batadv_neigh_node *neigh1,
 		 struct batadv_hard_iface *if_outgoing1,
 		 struct batadv_neigh_node *neigh2,
-- 
2.6.4
