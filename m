From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 11/20] batman-adv: Prefix gateway_client local static functions with batadv_
Date: Mon, 25 Jun 2012 08:54:35 +0200
Message-ID: <1340607284-29950-12-git-send-email-ordex@autistici.org>
References: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:30532 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754746Ab2FYGys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 02:54:48 -0400
In-Reply-To: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

All non-static symbols of batman-adv were prefixed with batadv_ to avoid
collisions with other symbols of the kernel. Other symbols of batman-adv
should use the same prefix to keep the naming scheme consistent.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/gateway_client.c |   67 ++++++++++++++++++++-------------------
 1 file changed, 35 insertions(+), 32 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 318c112..efe7519 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -36,13 +36,13 @@
 #define DHCP_OPTIONS_OFFSET 240
 #define DHCP_REQUEST 3
 
-static void gw_node_free_ref(struct gw_node *gw_node)
+static void batadv_gw_node_free_ref(struct gw_node *gw_node)
 {
 	if (atomic_dec_and_test(&gw_node->refcount))
 		kfree_rcu(gw_node, rcu);
 }
 
-static struct gw_node *gw_get_selected_gw_node(struct bat_priv *bat_priv)
+static struct gw_node *batadv_gw_get_selected_gw_node(struct bat_priv *bat_priv)
 {
 	struct gw_node *gw_node;
 
@@ -64,7 +64,7 @@ struct orig_node *batadv_gw_get_selected_orig(struct bat_priv *bat_priv)
 	struct gw_node *gw_node;
 	struct orig_node *orig_node = NULL;
 
-	gw_node = gw_get_selected_gw_node(bat_priv);
+	gw_node = batadv_gw_get_selected_gw_node(bat_priv);
 	if (!gw_node)
 		goto out;
 
@@ -80,11 +80,12 @@ unlock:
 	rcu_read_unlock();
 out:
 	if (gw_node)
-		gw_node_free_ref(gw_node);
+		batadv_gw_node_free_ref(gw_node);
 	return orig_node;
 }
 
-static void gw_select(struct bat_priv *bat_priv, struct gw_node *new_gw_node)
+static void batadv_gw_select(struct bat_priv *bat_priv,
+			     struct gw_node *new_gw_node)
 {
 	struct gw_node *curr_gw_node;
 
@@ -97,7 +98,7 @@ static void gw_select(struct bat_priv *bat_priv, struct gw_node *new_gw_node)
 	rcu_assign_pointer(bat_priv->curr_gw, new_gw_node);
 
 	if (curr_gw_node)
-		gw_node_free_ref(curr_gw_node);
+		batadv_gw_node_free_ref(curr_gw_node);
 
 	spin_unlock_bh(&bat_priv->gw_list_lock);
 }
@@ -107,7 +108,7 @@ void batadv_gw_deselect(struct bat_priv *bat_priv)
 	atomic_set(&bat_priv->gw_reselect, 1);
 }
 
-static struct gw_node *gw_get_best_gw_node(struct bat_priv *bat_priv)
+static struct gw_node *batadv_gw_get_best_gw_node(struct bat_priv *bat_priv)
 {
 	struct neigh_node *router;
 	struct hlist_node *node;
@@ -144,7 +145,7 @@ static struct gw_node *gw_get_best_gw_node(struct bat_priv *bat_priv)
 			    ((tmp_gw_factor == max_gw_factor) &&
 			     (router->tq_avg > max_tq))) {
 				if (curr_gw)
-					gw_node_free_ref(curr_gw);
+					batadv_gw_node_free_ref(curr_gw);
 				curr_gw = gw_node;
 				atomic_inc(&curr_gw->refcount);
 			}
@@ -159,7 +160,7 @@ static struct gw_node *gw_get_best_gw_node(struct bat_priv *bat_priv)
 			  */
 			if (router->tq_avg > max_tq) {
 				if (curr_gw)
-					gw_node_free_ref(curr_gw);
+					batadv_gw_node_free_ref(curr_gw);
 				curr_gw = gw_node;
 				atomic_inc(&curr_gw->refcount);
 			}
@@ -172,7 +173,7 @@ static struct gw_node *gw_get_best_gw_node(struct bat_priv *bat_priv)
 		if (tmp_gw_factor > max_gw_factor)
 			max_gw_factor = tmp_gw_factor;
 
-		gw_node_free_ref(gw_node);
+		batadv_gw_node_free_ref(gw_node);
 
 next:
 		batadv_neigh_node_free_ref(router);
@@ -199,9 +200,9 @@ void batadv_gw_election(struct bat_priv *bat_priv)
 	if (!atomic_dec_not_zero(&bat_priv->gw_reselect))
 		goto out;
 
-	curr_gw = gw_get_selected_gw_node(bat_priv);
+	curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
 
-	next_gw = gw_get_best_gw_node(bat_priv);
+	next_gw = batadv_gw_get_best_gw_node(bat_priv);
 
 	if (curr_gw == next_gw)
 		goto out;
@@ -234,13 +235,13 @@ void batadv_gw_election(struct bat_priv *bat_priv)
 		batadv_throw_uevent(bat_priv, UEV_GW, UEV_CHANGE, gw_addr);
 	}
 
-	gw_select(bat_priv, next_gw);
+	batadv_gw_select(bat_priv, next_gw);
 
 out:
 	if (curr_gw)
-		gw_node_free_ref(curr_gw);
+		batadv_gw_node_free_ref(curr_gw);
 	if (next_gw)
-		gw_node_free_ref(next_gw);
+		batadv_gw_node_free_ref(next_gw);
 	if (router)
 		batadv_neigh_node_free_ref(router);
 }
@@ -299,8 +300,9 @@ out:
 	return;
 }
 
-static void gw_node_add(struct bat_priv *bat_priv,
-			struct orig_node *orig_node, uint8_t new_gwflags)
+static void batadv_gw_node_add(struct bat_priv *bat_priv,
+			       struct orig_node *orig_node,
+			       uint8_t new_gwflags)
 {
 	struct gw_node *gw_node;
 	int down, up;
@@ -338,7 +340,7 @@ void batadv_gw_node_update(struct bat_priv *bat_priv,
 	 * have this gateway in our list (duplication check!) even though we
 	 * have no currently selected gateway.
 	 */
-	curr_gw = gw_get_selected_gw_node(bat_priv);
+	curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(gw_node, node, &bat_priv->gw_list, list) {
@@ -368,7 +370,7 @@ void batadv_gw_node_update(struct bat_priv *bat_priv,
 	if (new_gwflags == NO_FLAGS)
 		goto unlock;
 
-	gw_node_add(bat_priv, orig_node, new_gwflags);
+	batadv_gw_node_add(bat_priv, orig_node, new_gwflags);
 	goto unlock;
 
 deselect:
@@ -377,7 +379,7 @@ unlock:
 	rcu_read_unlock();
 
 	if (curr_gw)
-		gw_node_free_ref(curr_gw);
+		batadv_gw_node_free_ref(curr_gw);
 }
 
 void batadv_gw_node_delete(struct bat_priv *bat_priv,
@@ -393,7 +395,7 @@ void batadv_gw_node_purge(struct bat_priv *bat_priv)
 	unsigned long timeout = msecs_to_jiffies(2 * PURGE_TIMEOUT);
 	int do_deselect = 0;
 
-	curr_gw = gw_get_selected_gw_node(bat_priv);
+	curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
 
 	spin_lock_bh(&bat_priv->gw_list_lock);
 
@@ -408,7 +410,7 @@ void batadv_gw_node_purge(struct bat_priv *bat_priv)
 			do_deselect = 1;
 
 		hlist_del_rcu(&gw_node->list);
-		gw_node_free_ref(gw_node);
+		batadv_gw_node_free_ref(gw_node);
 	}
 
 	spin_unlock_bh(&bat_priv->gw_list_lock);
@@ -418,12 +420,13 @@ void batadv_gw_node_purge(struct bat_priv *bat_priv)
 		batadv_gw_deselect(bat_priv);
 
 	if (curr_gw)
-		gw_node_free_ref(curr_gw);
+		batadv_gw_node_free_ref(curr_gw);
 }
 
 /* fails if orig_node has no router */
-static int _write_buffer_text(struct bat_priv *bat_priv, struct seq_file *seq,
-			      const struct gw_node *gw_node)
+static int batadv_write_buffer_text(struct bat_priv *bat_priv,
+				     struct seq_file *seq,
+				     const struct gw_node *gw_node)
 {
 	struct gw_node *curr_gw;
 	struct neigh_node *router;
@@ -435,7 +438,7 @@ static int _write_buffer_text(struct bat_priv *bat_priv, struct seq_file *seq,
 	if (!router)
 		goto out;
 
-	curr_gw = gw_get_selected_gw_node(bat_priv);
+	curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
 
 	ret = seq_printf(seq, "%s %pM (%3i) %pM [%10s]: %3i - %i%s/%i%s\n",
 			 (curr_gw == gw_node ? "=>" : "  "),
@@ -450,7 +453,7 @@ static int _write_buffer_text(struct bat_priv *bat_priv, struct seq_file *seq,
 
 	batadv_neigh_node_free_ref(router);
 	if (curr_gw)
-		gw_node_free_ref(curr_gw);
+		batadv_gw_node_free_ref(curr_gw);
 out:
 	return ret;
 }
@@ -491,7 +494,7 @@ int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset)
 			continue;
 
 		/* fails if orig_node has no router */
-		if (_write_buffer_text(bat_priv, seq, gw_node) < 0)
+		if (batadv_write_buffer_text(bat_priv, seq, gw_node) < 0)
 			continue;
 
 		gw_count++;
@@ -507,7 +510,7 @@ out:
 	return ret;
 }
 
-static bool is_type_dhcprequest(struct sk_buff *skb, int header_len)
+static bool batadv_is_type_dhcprequest(struct sk_buff *skb, int header_len)
 {
 	int ret = false;
 	unsigned char *p;
@@ -655,7 +658,7 @@ bool batadv_gw_out_of_range(struct bat_priv *bat_priv,
 	if (!orig_dst_node->gw_flags)
 		goto out;
 
-	ret = is_type_dhcprequest(skb, header_len);
+	ret = batadv_is_type_dhcprequest(skb, header_len);
 	if (!ret)
 		goto out;
 
@@ -667,7 +670,7 @@ bool batadv_gw_out_of_range(struct bat_priv *bat_priv,
 		curr_tq_avg = TQ_MAX_VALUE;
 		break;
 	case GW_MODE_CLIENT:
-		curr_gw = gw_get_selected_gw_node(bat_priv);
+		curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
 		if (!curr_gw)
 			goto out;
 
@@ -702,7 +705,7 @@ out:
 	if (orig_dst_node)
 		batadv_orig_node_free_ref(orig_dst_node);
 	if (curr_gw)
-		gw_node_free_ref(curr_gw);
+		batadv_gw_node_free_ref(curr_gw);
 	if (neigh_old)
 		batadv_neigh_node_free_ref(neigh_old);
 	if (neigh_curr)
-- 
1.7.9.4
