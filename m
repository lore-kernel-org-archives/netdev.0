From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 11/20] batman-adv: Prefix originator
	non-static functions with batadv_
Date: Thu, 21 Jun 2012 18:57:47 +0200
Message-ID: <1340297876-29923-12-git-send-email-ordex@autistici.org>
References: <1340297876-29923-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1340297876-29923-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

batman-adv can be compiled as part of the kernel instead of an module. In that
case the linker will see all non-static symbols of batman-adv and all other
non-static symbols of the kernel. This could lead to symbol collisions. A
prefix for the batman-adv symbols that defines their private namespace avoids
such a problem.

Reported-by: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/bat_debugfs.c           |    2 +-
 net/batman-adv/bat_iv_ogm.c            |   43 +++++++++++------------
 net/batman-adv/bridge_loop_avoidance.c |    4 +--
 net/batman-adv/gateway_client.c        |   28 +++++++--------
 net/batman-adv/hard-interface.c        |    6 ++--
 net/batman-adv/icmp_socket.c           |    6 ++--
 net/batman-adv/main.c                  |    4 +--
 net/batman-adv/originator.c            |   35 +++++++++----------
 net/batman-adv/originator.h            |   21 ++++++------
 net/batman-adv/routing.c               |   58 ++++++++++++++++----------------
 net/batman-adv/translation-table.c     |   32 +++++++++---------
 net/batman-adv/unicast.c               |    6 ++--
 net/batman-adv/vis.c                   |   20 +++++------
 13 files changed, 134 insertions(+), 131 deletions(-)

diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
index 9177a06..51b67f4 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -230,7 +230,7 @@ static int bat_algorithms_open(struct inode *inode, struct file *file)
 static int originators_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
-	return single_open(file, orig_seq_print_text, net_dev);
+	return single_open(file, batadv_orig_seq_print_text, net_dev);
 }
 
 static int gateways_open(struct inode *inode, struct file *file)
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index defcac1..9c8c9d0 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -633,7 +633,7 @@ static void bat_iv_ogm_orig_update(struct bat_priv *bat_priv,
 		    (tmp_neigh_node->if_incoming == if_incoming) &&
 		     atomic_inc_not_zero(&tmp_neigh_node->refcount)) {
 			if (neigh_node)
-				neigh_node_free_ref(neigh_node);
+				batadv_neigh_node_free_ref(neigh_node);
 			neigh_node = tmp_neigh_node;
 			continue;
 		}
@@ -652,7 +652,7 @@ static void bat_iv_ogm_orig_update(struct bat_priv *bat_priv,
 	if (!neigh_node) {
 		struct orig_node *orig_tmp;
 
-		orig_tmp = get_orig_node(bat_priv, ethhdr->h_source);
+		orig_tmp = batadv_get_orig_node(bat_priv, ethhdr->h_source);
 		if (!orig_tmp)
 			goto unlock;
 
@@ -660,7 +660,7 @@ static void bat_iv_ogm_orig_update(struct bat_priv *bat_priv,
 						  orig_node, orig_tmp,
 						  batman_ogm_packet->seqno);
 
-		orig_node_free_ref(orig_tmp);
+		batadv_orig_node_free_ref(orig_tmp);
 		if (!neigh_node)
 			goto unlock;
 	} else
@@ -688,7 +688,7 @@ static void bat_iv_ogm_orig_update(struct bat_priv *bat_priv,
 
 	/* if this neighbor already is our next hop there is nothing
 	 * to change */
-	router = orig_node_get_router(orig_node);
+	router = batadv_orig_node_get_router(orig_node);
 	if (router == neigh_node)
 		goto update_tt;
 
@@ -746,9 +746,9 @@ unlock:
 	rcu_read_unlock();
 out:
 	if (neigh_node)
-		neigh_node_free_ref(neigh_node);
+		batadv_neigh_node_free_ref(neigh_node);
 	if (router)
-		neigh_node_free_ref(router);
+		batadv_neigh_node_free_ref(router);
 }
 
 static int bat_iv_ogm_calc_tq(struct orig_node *orig_node,
@@ -848,7 +848,7 @@ static int bat_iv_ogm_calc_tq(struct orig_node *orig_node,
 
 out:
 	if (neigh_node)
-		neigh_node_free_ref(neigh_node);
+		batadv_neigh_node_free_ref(neigh_node);
 	return ret;
 }
 
@@ -875,7 +875,7 @@ static int bat_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 	int set_mark, ret = -1;
 	uint32_t seqno = ntohl(batman_ogm_packet->seqno);
 
-	orig_node = get_orig_node(bat_priv, batman_ogm_packet->orig);
+	orig_node = batadv_get_orig_node(bat_priv, batman_ogm_packet->orig);
 	if (!orig_node)
 		return 0;
 
@@ -924,7 +924,7 @@ static int bat_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 
 out:
 	spin_unlock_bh(&orig_node->ogm_cnt_lock);
-	orig_node_free_ref(orig_node);
+	batadv_orig_node_free_ref(orig_node);
 	return ret;
 }
 
@@ -1029,7 +1029,8 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 		unsigned long *word;
 		int offset;
 
-		orig_neigh_node = get_orig_node(bat_priv, ethhdr->h_source);
+		orig_neigh_node = batadv_get_orig_node(bat_priv,
+						       ethhdr->h_source);
 		if (!orig_neigh_node)
 			return;
 
@@ -1053,7 +1054,7 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Drop packet: originator packet from myself (via neighbor)\n");
-		orig_node_free_ref(orig_neigh_node);
+		batadv_orig_node_free_ref(orig_neigh_node);
 		return;
 	}
 
@@ -1071,7 +1072,7 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 		return;
 	}
 
-	orig_node = get_orig_node(bat_priv, batman_ogm_packet->orig);
+	orig_node = batadv_get_orig_node(bat_priv, batman_ogm_packet->orig);
 	if (!orig_node)
 		return;
 
@@ -1091,9 +1092,9 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 		goto out;
 	}
 
-	router = orig_node_get_router(orig_node);
+	router = batadv_orig_node_get_router(orig_node);
 	if (router)
-		router_router = orig_node_get_router(router->orig_node);
+		router_router = batadv_orig_node_get_router(router->orig_node);
 
 	if ((router && router->tq_avg != 0) &&
 	    (compare_eth(router->addr, ethhdr->h_source)))
@@ -1115,11 +1116,11 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	 * originator mac */
 	orig_neigh_node = (is_single_hop_neigh ?
 			   orig_node :
-			   get_orig_node(bat_priv, ethhdr->h_source));
+			   batadv_get_orig_node(bat_priv, ethhdr->h_source));
 	if (!orig_neigh_node)
 		goto out;
 
-	orig_neigh_router = orig_node_get_router(orig_neigh_node);
+	orig_neigh_router = batadv_orig_node_get_router(orig_neigh_node);
 
 	/* drop packet if sender is not a direct neighbor and if we
 	 * don't route towards it */
@@ -1178,16 +1179,16 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 
 out_neigh:
 	if ((orig_neigh_node) && (!is_single_hop_neigh))
-		orig_node_free_ref(orig_neigh_node);
+		batadv_orig_node_free_ref(orig_neigh_node);
 out:
 	if (router)
-		neigh_node_free_ref(router);
+		batadv_neigh_node_free_ref(router);
 	if (router_router)
-		neigh_node_free_ref(router_router);
+		batadv_neigh_node_free_ref(router_router);
 	if (orig_neigh_router)
-		neigh_node_free_ref(orig_neigh_router);
+		batadv_neigh_node_free_ref(orig_neigh_router);
 
-	orig_node_free_ref(orig_node);
+	batadv_orig_node_free_ref(orig_node);
 }
 
 static int bat_iv_ogm_receive(struct sk_buff *skb,
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index eb21789..c4b28af 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -399,7 +399,7 @@ static struct backbone_gw *bla_get_backbone_gw(struct bat_priv *bat_priv,
 	if (orig_node) {
 		tt_global_del_orig(bat_priv, orig_node,
 				   "became a backbone gateway");
-		orig_node_free_ref(orig_node);
+		batadv_orig_node_free_ref(orig_node);
 	}
 	return entry;
 }
@@ -804,7 +804,7 @@ static int check_claim_group(struct bat_priv *bat_priv,
 		bla_dst_own->group = bla_dst->group;
 	}
 
-	orig_node_free_ref(orig_node);
+	batadv_orig_node_free_ref(orig_node);
 
 	return 2;
 }
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index a3f944b..e92055d 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -124,7 +124,7 @@ static struct gw_node *gw_get_best_gw_node(struct bat_priv *bat_priv)
 			continue;
 
 		orig_node = gw_node->orig_node;
-		router = orig_node_get_router(orig_node);
+		router = batadv_orig_node_get_router(orig_node);
 		if (!router)
 			continue;
 
@@ -177,7 +177,7 @@ static struct gw_node *gw_get_best_gw_node(struct bat_priv *bat_priv)
 		gw_node_free_ref(gw_node);
 
 next:
-		neigh_node_free_ref(router);
+		batadv_neigh_node_free_ref(router);
 	}
 	rcu_read_unlock();
 
@@ -212,7 +212,7 @@ void batadv_gw_election(struct bat_priv *bat_priv)
 	if (next_gw) {
 		sprintf(gw_addr, "%pM", next_gw->orig_node->orig);
 
-		router = orig_node_get_router(next_gw->orig_node);
+		router = batadv_orig_node_get_router(next_gw->orig_node);
 		if (!router) {
 			batadv_gw_deselect(bat_priv);
 			goto out;
@@ -245,7 +245,7 @@ out:
 	if (next_gw)
 		gw_node_free_ref(next_gw);
 	if (router)
-		neigh_node_free_ref(router);
+		batadv_neigh_node_free_ref(router);
 }
 
 void batadv_gw_check_election(struct bat_priv *bat_priv,
@@ -259,7 +259,7 @@ void batadv_gw_check_election(struct bat_priv *bat_priv,
 	if (!curr_gw_orig)
 		goto deselect;
 
-	router_gw = orig_node_get_router(curr_gw_orig);
+	router_gw = batadv_orig_node_get_router(curr_gw_orig);
 	if (!router_gw)
 		goto deselect;
 
@@ -267,7 +267,7 @@ void batadv_gw_check_election(struct bat_priv *bat_priv,
 	if (curr_gw_orig == orig_node)
 		goto out;
 
-	router_orig = orig_node_get_router(orig_node);
+	router_orig = batadv_orig_node_get_router(orig_node);
 	if (!router_orig)
 		goto out;
 
@@ -294,11 +294,11 @@ deselect:
 	batadv_gw_deselect(bat_priv);
 out:
 	if (curr_gw_orig)
-		orig_node_free_ref(curr_gw_orig);
+		batadv_orig_node_free_ref(curr_gw_orig);
 	if (router_gw)
-		neigh_node_free_ref(router_gw);
+		batadv_neigh_node_free_ref(router_gw);
 	if (router_orig)
-		neigh_node_free_ref(router_orig);
+		batadv_neigh_node_free_ref(router_orig);
 
 	return;
 }
@@ -438,7 +438,7 @@ static int _write_buffer_text(struct bat_priv *bat_priv, struct seq_file *seq,
 
 	batadv_gw_bandwidth_to_kbit(gw_node->orig_node->gw_flags, &down, &up);
 
-	router = orig_node_get_router(gw_node->orig_node);
+	router = batadv_orig_node_get_router(gw_node->orig_node);
 	if (!router)
 		goto out;
 
@@ -455,7 +455,7 @@ static int _write_buffer_text(struct bat_priv *bat_priv, struct seq_file *seq,
 			 (up > 2048 ? up / 1024 : up),
 			 (up > 2048 ? "MBit" : "KBit"));
 
-	neigh_node_free_ref(router);
+	batadv_neigh_node_free_ref(router);
 	if (curr_gw)
 		gw_node_free_ref(curr_gw);
 out:
@@ -702,12 +702,12 @@ bool batadv_gw_out_of_range(struct bat_priv *bat_priv,
 
 out:
 	if (orig_dst_node)
-		orig_node_free_ref(orig_dst_node);
+		batadv_orig_node_free_ref(orig_dst_node);
 	if (curr_gw)
 		gw_node_free_ref(curr_gw);
 	if (neigh_old)
-		neigh_node_free_ref(neigh_old);
+		batadv_neigh_node_free_ref(neigh_old);
 	if (neigh_curr)
-		neigh_node_free_ref(neigh_curr);
+		batadv_neigh_node_free_ref(neigh_curr);
 	return out_of_range;
 }
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 4f44f04..1f126cb 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -312,7 +312,7 @@ int batadv_hardif_enable_interface(struct hard_iface *hard_iface,
 	hard_iface->if_num = bat_priv->num_ifaces;
 	bat_priv->num_ifaces++;
 	hard_iface->if_status = IF_INACTIVE;
-	orig_hash_add_if(hard_iface, bat_priv->num_ifaces);
+	batadv_orig_hash_add_if(hard_iface, bat_priv->num_ifaces);
 
 	hard_iface->batman_adv_ptype.type = __constant_htons(ETH_P_BATMAN);
 	hard_iface->batman_adv_ptype.func = batman_skb_recv;
@@ -373,7 +373,7 @@ void batadv_hardif_disable_interface(struct hard_iface *hard_iface)
 	dev_remove_pack(&hard_iface->batman_adv_ptype);
 
 	bat_priv->num_ifaces--;
-	orig_hash_del_if(hard_iface, bat_priv->num_ifaces);
+	batadv_orig_hash_del_if(hard_iface, bat_priv->num_ifaces);
 
 	primary_if = primary_if_get_selected(bat_priv);
 	if (hard_iface == primary_if) {
@@ -390,7 +390,7 @@ void batadv_hardif_disable_interface(struct hard_iface *hard_iface)
 	hard_iface->if_status = IF_NOT_IN_USE;
 
 	/* delete all references to this hard_iface */
-	purge_orig_ref(bat_priv);
+	batadv_purge_orig_ref(bat_priv);
 	purge_outstanding_packets(bat_priv, hard_iface);
 	dev_put(hard_iface->soft_iface);
 
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 38ca3a8..44cbee5 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -219,7 +219,7 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 	if (!orig_node)
 		goto dst_unreach;
 
-	neigh_node = orig_node_get_router(orig_node);
+	neigh_node = batadv_orig_node_get_router(orig_node);
 	if (!neigh_node)
 		goto dst_unreach;
 
@@ -248,9 +248,9 @@ out:
 	if (primary_if)
 		hardif_free_ref(primary_if);
 	if (neigh_node)
-		neigh_node_free_ref(neigh_node);
+		batadv_neigh_node_free_ref(neigh_node);
 	if (orig_node)
-		orig_node_free_ref(orig_node);
+		batadv_orig_node_free_ref(orig_node);
 	return len;
 }
 
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 84dbda5..eba5d28 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -111,7 +111,7 @@ int mesh_init(struct net_device *soft_iface)
 	INIT_LIST_HEAD(&bat_priv->tt_req_list);
 	INIT_LIST_HEAD(&bat_priv->tt_roam_list);
 
-	ret = originator_init(bat_priv);
+	ret = batadv_originator_init(bat_priv);
 	if (ret < 0)
 		goto err;
 
@@ -150,7 +150,7 @@ void mesh_free(struct net_device *soft_iface)
 	vis_quit(bat_priv);
 
 	batadv_gw_node_purge(bat_priv);
-	originator_free(bat_priv);
+	batadv_originator_free(bat_priv);
 
 	tt_free(bat_priv);
 
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 410a197..9358513 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -47,7 +47,7 @@ static int compare_orig(const struct hlist_node *node, const void *data2)
 	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
 }
 
-int originator_init(struct bat_priv *bat_priv)
+int batadv_originator_init(struct bat_priv *bat_priv)
 {
 	if (bat_priv->orig_hash)
 		return 0;
@@ -64,14 +64,14 @@ err:
 	return -ENOMEM;
 }
 
-void neigh_node_free_ref(struct neigh_node *neigh_node)
+void batadv_neigh_node_free_ref(struct neigh_node *neigh_node)
 {
 	if (atomic_dec_and_test(&neigh_node->refcount))
 		kfree_rcu(neigh_node, rcu);
 }
 
 /* increases the refcounter of a found router */
-struct neigh_node *orig_node_get_router(struct orig_node *orig_node)
+struct neigh_node *batadv_orig_node_get_router(struct orig_node *orig_node)
 {
 	struct neigh_node *router;
 
@@ -126,14 +126,14 @@ static void orig_node_free_rcu(struct rcu_head *rcu)
 	list_for_each_entry_safe(neigh_node, tmp_neigh_node,
 				 &orig_node->bond_list, bonding_list) {
 		list_del_rcu(&neigh_node->bonding_list);
-		neigh_node_free_ref(neigh_node);
+		batadv_neigh_node_free_ref(neigh_node);
 	}
 
 	/* for all neighbors towards this originator ... */
 	hlist_for_each_entry_safe(neigh_node, node, node_tmp,
 				  &orig_node->neigh_list, list) {
 		hlist_del_rcu(&neigh_node->list);
-		neigh_node_free_ref(neigh_node);
+		batadv_neigh_node_free_ref(neigh_node);
 	}
 
 	spin_unlock_bh(&orig_node->neigh_list_lock);
@@ -148,13 +148,13 @@ static void orig_node_free_rcu(struct rcu_head *rcu)
 	kfree(orig_node);
 }
 
-void orig_node_free_ref(struct orig_node *orig_node)
+void batadv_orig_node_free_ref(struct orig_node *orig_node)
 {
 	if (atomic_dec_and_test(&orig_node->refcount))
 		call_rcu(&orig_node->rcu, orig_node_free_rcu);
 }
 
-void originator_free(struct bat_priv *bat_priv)
+void batadv_originator_free(struct bat_priv *bat_priv)
 {
 	struct hashtable_t *hash = bat_priv->orig_hash;
 	struct hlist_node *node, *node_tmp;
@@ -179,7 +179,7 @@ void originator_free(struct bat_priv *bat_priv)
 					  head, hash_entry) {
 
 			hlist_del_rcu(node);
-			orig_node_free_ref(orig_node);
+			batadv_orig_node_free_ref(orig_node);
 		}
 		spin_unlock_bh(list_lock);
 	}
@@ -189,7 +189,8 @@ void originator_free(struct bat_priv *bat_priv)
 
 /* this function finds or creates an originator entry for the given
  * address if it does not exits */
-struct orig_node *get_orig_node(struct bat_priv *bat_priv, const uint8_t *addr)
+struct orig_node *batadv_get_orig_node(struct bat_priv *bat_priv,
+				       const uint8_t *addr)
 {
 	struct orig_node *orig_node;
 	int size;
@@ -307,7 +308,7 @@ static bool purge_orig_neighbors(struct bat_priv *bat_priv,
 
 			hlist_del_rcu(&neigh_node->list);
 			bonding_candidate_del(orig_node, neigh_node);
-			neigh_node_free_ref(neigh_node);
+			batadv_neigh_node_free_ref(neigh_node);
 		} else {
 			if ((!*best_neigh_node) ||
 			    (neigh_node->tq_avg > (*best_neigh_node)->tq_avg))
@@ -364,7 +365,7 @@ static void _purge_orig(struct bat_priv *bat_priv)
 					batadv_gw_node_delete(bat_priv,
 							      orig_node);
 				hlist_del_rcu(node);
-				orig_node_free_ref(orig_node);
+				batadv_orig_node_free_ref(orig_node);
 				continue;
 			}
 
@@ -390,12 +391,12 @@ static void purge_orig(struct work_struct *work)
 	start_purge_timer(bat_priv);
 }
 
-void purge_orig_ref(struct bat_priv *bat_priv)
+void batadv_purge_orig_ref(struct bat_priv *bat_priv)
 {
 	_purge_orig(bat_priv);
 }
 
-int orig_seq_print_text(struct seq_file *seq, void *offset)
+int batadv_orig_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct net_device *net_dev = (struct net_device *)seq->private;
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
@@ -439,7 +440,7 @@ int orig_seq_print_text(struct seq_file *seq, void *offset)
 
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(orig_node, node, head, hash_entry) {
-			neigh_node = orig_node_get_router(orig_node);
+			neigh_node = batadv_orig_node_get_router(orig_node);
 			if (!neigh_node)
 				continue;
 
@@ -468,7 +469,7 @@ int orig_seq_print_text(struct seq_file *seq, void *offset)
 			batman_count++;
 
 next:
-			neigh_node_free_ref(neigh_node);
+			batadv_neigh_node_free_ref(neigh_node);
 		}
 		rcu_read_unlock();
 	}
@@ -508,7 +509,7 @@ static int orig_node_add_if(struct orig_node *orig_node, int max_if_num)
 	return 0;
 }
 
-int orig_hash_add_if(struct hard_iface *hard_iface, int max_if_num)
+int batadv_orig_hash_add_if(struct hard_iface *hard_iface, int max_if_num)
 {
 	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	struct hashtable_t *hash = bat_priv->orig_hash;
@@ -590,7 +591,7 @@ free_own_sum:
 	return 0;
 }
 
-int orig_hash_del_if(struct hard_iface *hard_iface, int max_if_num)
+int batadv_orig_hash_del_if(struct hard_iface *hard_iface, int max_if_num)
 {
 	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	struct hashtable_t *hash = bat_priv->orig_hash;
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index f74d0d6..97deeba 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -24,19 +24,20 @@
 
 #include "hash.h"
 
-int originator_init(struct bat_priv *bat_priv);
-void originator_free(struct bat_priv *bat_priv);
-void purge_orig_ref(struct bat_priv *bat_priv);
-void orig_node_free_ref(struct orig_node *orig_node);
-struct orig_node *get_orig_node(struct bat_priv *bat_priv, const uint8_t *addr);
+int batadv_originator_init(struct bat_priv *bat_priv);
+void batadv_originator_free(struct bat_priv *bat_priv);
+void batadv_purge_orig_ref(struct bat_priv *bat_priv);
+void batadv_orig_node_free_ref(struct orig_node *orig_node);
+struct orig_node *batadv_get_orig_node(struct bat_priv *bat_priv,
+				       const uint8_t *addr);
 struct neigh_node *batadv_neigh_node_new(struct hard_iface *hard_iface,
 					 const uint8_t *neigh_addr,
 					 uint32_t seqno);
-void neigh_node_free_ref(struct neigh_node *neigh_node);
-struct neigh_node *orig_node_get_router(struct orig_node *orig_node);
-int orig_seq_print_text(struct seq_file *seq, void *offset);
-int orig_hash_add_if(struct hard_iface *hard_iface, int max_if_num);
-int orig_hash_del_if(struct hard_iface *hard_iface, int max_if_num);
+void batadv_neigh_node_free_ref(struct neigh_node *neigh_node);
+struct neigh_node *batadv_orig_node_get_router(struct orig_node *orig_node);
+int batadv_orig_seq_print_text(struct seq_file *seq, void *offset);
+int batadv_orig_hash_add_if(struct hard_iface *hard_iface, int max_if_num);
+int batadv_orig_hash_del_if(struct hard_iface *hard_iface, int max_if_num);
 
 
 /* hashfunction to choose an entry in a hash table of given size */
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 7525e4f..77fe460 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -69,7 +69,7 @@ static void _update_route(struct bat_priv *bat_priv,
 {
 	struct neigh_node *curr_router;
 
-	curr_router = orig_node_get_router(orig_node);
+	curr_router = batadv_orig_node_get_router(orig_node);
 
 	/* route deleted */
 	if ((curr_router) && (!neigh_node)) {
@@ -93,7 +93,7 @@ static void _update_route(struct bat_priv *bat_priv,
 	}
 
 	if (curr_router)
-		neigh_node_free_ref(curr_router);
+		batadv_neigh_node_free_ref(curr_router);
 
 	/* increase refcount of new best neighbor */
 	if (neigh_node && !atomic_inc_not_zero(&neigh_node->refcount))
@@ -105,7 +105,7 @@ static void _update_route(struct bat_priv *bat_priv,
 
 	/* decrease refcount of previous best neighbor */
 	if (curr_router)
-		neigh_node_free_ref(curr_router);
+		batadv_neigh_node_free_ref(curr_router);
 }
 
 void update_route(struct bat_priv *bat_priv, struct orig_node *orig_node,
@@ -116,14 +116,14 @@ void update_route(struct bat_priv *bat_priv, struct orig_node *orig_node,
 	if (!orig_node)
 		goto out;
 
-	router = orig_node_get_router(orig_node);
+	router = batadv_orig_node_get_router(orig_node);
 
 	if (router != neigh_node)
 		_update_route(bat_priv, orig_node, neigh_node);
 
 out:
 	if (router)
-		neigh_node_free_ref(router);
+		batadv_neigh_node_free_ref(router);
 }
 
 /* caller must hold the neigh_list_lock */
@@ -136,7 +136,7 @@ void bonding_candidate_del(struct orig_node *orig_node,
 
 	list_del_rcu(&neigh_node->bonding_list);
 	INIT_LIST_HEAD(&neigh_node->bonding_list);
-	neigh_node_free_ref(neigh_node);
+	batadv_neigh_node_free_ref(neigh_node);
 	atomic_dec(&orig_node->bond_candidates);
 
 out:
@@ -157,7 +157,7 @@ void bonding_candidate_add(struct orig_node *orig_node,
 			 neigh_node->orig_node->primary_addr))
 		goto candidate_del;
 
-	router = orig_node_get_router(orig_node);
+	router = batadv_orig_node_get_router(orig_node);
 	if (!router)
 		goto candidate_del;
 
@@ -210,7 +210,7 @@ out:
 	spin_unlock_bh(&orig_node->neigh_list_lock);
 
 	if (router)
-		neigh_node_free_ref(router);
+		batadv_neigh_node_free_ref(router);
 }
 
 /* copy primary address for bonding */
@@ -303,7 +303,7 @@ static int recv_my_icmp_packet(struct bat_priv *bat_priv,
 	if (!orig_node)
 		goto out;
 
-	router = orig_node_get_router(orig_node);
+	router = batadv_orig_node_get_router(orig_node);
 	if (!router)
 		goto out;
 
@@ -325,9 +325,9 @@ out:
 	if (primary_if)
 		hardif_free_ref(primary_if);
 	if (router)
-		neigh_node_free_ref(router);
+		batadv_neigh_node_free_ref(router);
 	if (orig_node)
-		orig_node_free_ref(orig_node);
+		batadv_orig_node_free_ref(orig_node);
 	return ret;
 }
 
@@ -358,7 +358,7 @@ static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
 	if (!orig_node)
 		goto out;
 
-	router = orig_node_get_router(orig_node);
+	router = batadv_orig_node_get_router(orig_node);
 	if (!router)
 		goto out;
 
@@ -380,9 +380,9 @@ out:
 	if (primary_if)
 		hardif_free_ref(primary_if);
 	if (router)
-		neigh_node_free_ref(router);
+		batadv_neigh_node_free_ref(router);
 	if (orig_node)
-		orig_node_free_ref(orig_node);
+		batadv_orig_node_free_ref(orig_node);
 	return ret;
 }
 
@@ -444,7 +444,7 @@ int recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	if (!orig_node)
 		goto out;
 
-	router = orig_node_get_router(orig_node);
+	router = batadv_orig_node_get_router(orig_node);
 	if (!router)
 		goto out;
 
@@ -463,9 +463,9 @@ int recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 
 out:
 	if (router)
-		neigh_node_free_ref(router);
+		batadv_neigh_node_free_ref(router);
 	if (orig_node)
-		orig_node_free_ref(orig_node);
+		batadv_orig_node_free_ref(orig_node);
 	return ret;
 }
 
@@ -551,13 +551,13 @@ static struct neigh_node *find_ifalter_router(struct orig_node *primary_orig,
 			/* decrement refcount of
 			 * previously selected router */
 			if (router)
-				neigh_node_free_ref(router);
+				batadv_neigh_node_free_ref(router);
 
 			router = tmp_neigh_node;
 			atomic_inc_not_zero(&router->refcount);
 		}
 
-		neigh_node_free_ref(tmp_neigh_node);
+		batadv_neigh_node_free_ref(tmp_neigh_node);
 	}
 
 	/* use the first candidate if nothing was found. */
@@ -695,7 +695,7 @@ int recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_if)
 	 * packets for the correct destination. */
 	bat_priv->tt_poss_change = true;
 
-	orig_node_free_ref(orig_node);
+	batadv_orig_node_free_ref(orig_node);
 out:
 	/* returning NET_RX_DROP will make the caller function kfree the skb */
 	return NET_RX_DROP;
@@ -717,7 +717,7 @@ struct neigh_node *find_router(struct bat_priv *bat_priv,
 	if (!orig_node)
 		return NULL;
 
-	router = orig_node_get_router(orig_node);
+	router = batadv_orig_node_get_router(orig_node);
 	if (!router)
 		goto err;
 
@@ -750,7 +750,7 @@ struct neigh_node *find_router(struct bat_priv *bat_priv,
 		if (!primary_orig_node)
 			goto return_router;
 
-		orig_node_free_ref(primary_orig_node);
+		batadv_orig_node_free_ref(primary_orig_node);
 	}
 
 	/* with less than 2 candidates, we can't do any
@@ -762,7 +762,7 @@ struct neigh_node *find_router(struct bat_priv *bat_priv,
 	 * is is not on the interface where the packet came
 	 * in. */
 
-	neigh_node_free_ref(router);
+	batadv_neigh_node_free_ref(router);
 
 	if (bonding_enabled)
 		router = find_bond_router(primary_orig_node, recv_if);
@@ -779,7 +779,7 @@ err_unlock:
 	rcu_read_unlock();
 err:
 	if (router)
-		neigh_node_free_ref(router);
+		batadv_neigh_node_free_ref(router);
 	return NULL;
 }
 
@@ -885,9 +885,9 @@ static int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 
 out:
 	if (neigh_node)
-		neigh_node_free_ref(neigh_node);
+		batadv_neigh_node_free_ref(neigh_node);
 	if (orig_node)
-		orig_node_free_ref(orig_node);
+		batadv_orig_node_free_ref(orig_node);
 	return ret;
 }
 
@@ -917,7 +917,7 @@ static int check_unicast_ttvn(struct bat_priv *bat_priv,
 
 		curr_ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
 		tt_poss_change = orig_node->tt_poss_change;
-		orig_node_free_ref(orig_node);
+		batadv_orig_node_free_ref(orig_node);
 	}
 
 	/* Check whether I have to reroute the packet */
@@ -952,7 +952,7 @@ static int check_unicast_ttvn(struct bat_priv *bat_priv,
 			       ETH_ALEN);
 			curr_ttvn = (uint8_t)
 				atomic_read(&orig_node->last_ttvn);
-			orig_node_free_ref(orig_node);
+			batadv_orig_node_free_ref(orig_node);
 		}
 
 		bat_dbg(DBG_ROUTES, bat_priv,
@@ -1110,7 +1110,7 @@ spin_unlock:
 	spin_unlock_bh(&orig_node->bcast_seqno_lock);
 out:
 	if (orig_node)
-		orig_node_free_ref(orig_node);
+		batadv_orig_node_free_ref(orig_node);
 	return ret;
 }
 
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index a7cbc91..3d2c3b1 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -142,7 +142,7 @@ static void tt_orig_list_entry_free_rcu(struct rcu_head *rcu)
 
 	orig_entry = container_of(rcu, struct tt_orig_list_entry, rcu);
 	atomic_dec(&orig_entry->orig_node->tt_size);
-	orig_node_free_ref(orig_entry->orig_node);
+	batadv_orig_node_free_ref(orig_entry->orig_node);
 	kfree(orig_entry);
 }
 
@@ -1080,7 +1080,7 @@ struct orig_node *transtable_search(struct bat_priv *bat_priv,
 	rcu_read_lock();
 	head = &tt_global_entry->orig_list;
 	hlist_for_each_entry_rcu(orig_entry, node, head, list) {
-		router = orig_node_get_router(orig_entry->orig_node);
+		router = batadv_orig_node_get_router(orig_entry->orig_node);
 		if (!router)
 			continue;
 
@@ -1088,7 +1088,7 @@ struct orig_node *transtable_search(struct bat_priv *bat_priv,
 			orig_node = orig_entry->orig_node;
 			best_tq = router->tq_avg;
 		}
-		neigh_node_free_ref(router);
+		batadv_neigh_node_free_ref(router);
 	}
 	/* found anything? */
 	if (orig_node && !atomic_inc_not_zero(&orig_node->refcount))
@@ -1395,7 +1395,7 @@ static int send_tt_request(struct bat_priv *bat_priv,
 	if (full_table)
 		tt_request->flags |= TT_FULL_TABLE;
 
-	neigh_node = orig_node_get_router(dst_orig_node);
+	neigh_node = batadv_orig_node_get_router(dst_orig_node);
 	if (!neigh_node)
 		goto out;
 
@@ -1411,7 +1411,7 @@ static int send_tt_request(struct bat_priv *bat_priv,
 
 out:
 	if (neigh_node)
-		neigh_node_free_ref(neigh_node);
+		batadv_neigh_node_free_ref(neigh_node);
 	if (primary_if)
 		hardif_free_ref(primary_if);
 	if (ret)
@@ -1453,7 +1453,7 @@ static bool send_other_tt_response(struct bat_priv *bat_priv,
 	if (!res_dst_orig_node)
 		goto out;
 
-	neigh_node = orig_node_get_router(res_dst_orig_node);
+	neigh_node = batadv_orig_node_get_router(res_dst_orig_node);
 	if (!neigh_node)
 		goto out;
 
@@ -1541,11 +1541,11 @@ unlock:
 
 out:
 	if (res_dst_orig_node)
-		orig_node_free_ref(res_dst_orig_node);
+		batadv_orig_node_free_ref(res_dst_orig_node);
 	if (req_dst_orig_node)
-		orig_node_free_ref(req_dst_orig_node);
+		batadv_orig_node_free_ref(req_dst_orig_node);
 	if (neigh_node)
-		neigh_node_free_ref(neigh_node);
+		batadv_neigh_node_free_ref(neigh_node);
 	if (primary_if)
 		hardif_free_ref(primary_if);
 	if (!ret)
@@ -1580,7 +1580,7 @@ static bool send_my_tt_response(struct bat_priv *bat_priv,
 	if (!orig_node)
 		goto out;
 
-	neigh_node = orig_node_get_router(orig_node);
+	neigh_node = batadv_orig_node_get_router(orig_node);
 	if (!neigh_node)
 		goto out;
 
@@ -1658,9 +1658,9 @@ unlock:
 	spin_unlock_bh(&bat_priv->tt_buff_lock);
 out:
 	if (orig_node)
-		orig_node_free_ref(orig_node);
+		batadv_orig_node_free_ref(orig_node);
 	if (neigh_node)
-		neigh_node_free_ref(neigh_node);
+		batadv_neigh_node_free_ref(neigh_node);
 	if (primary_if)
 		hardif_free_ref(primary_if);
 	if (!ret)
@@ -1738,7 +1738,7 @@ static void tt_fill_gtable(struct bat_priv *bat_priv,
 
 out:
 	if (orig_node)
-		orig_node_free_ref(orig_node);
+		batadv_orig_node_free_ref(orig_node);
 }
 
 static void tt_update_changes(struct bat_priv *bat_priv,
@@ -1818,7 +1818,7 @@ void handle_tt_response(struct bat_priv *bat_priv,
 	orig_node->tt_poss_change = false;
 out:
 	if (orig_node)
-		orig_node_free_ref(orig_node);
+		batadv_orig_node_free_ref(orig_node);
 }
 
 int tt_init(struct bat_priv *bat_priv)
@@ -1947,7 +1947,7 @@ static void send_roam_adv(struct bat_priv *bat_priv, uint8_t *client,
 	memcpy(roam_adv_packet->dst, orig_node->orig, ETH_ALEN);
 	memcpy(roam_adv_packet->client, client, ETH_ALEN);
 
-	neigh_node = orig_node_get_router(orig_node);
+	neigh_node = batadv_orig_node_get_router(orig_node);
 	if (!neigh_node)
 		goto out;
 
@@ -1962,7 +1962,7 @@ static void send_roam_adv(struct bat_priv *bat_priv, uint8_t *client,
 
 out:
 	if (neigh_node)
-		neigh_node_free_ref(neigh_node);
+		batadv_neigh_node_free_ref(neigh_node);
 	if (ret)
 		kfree_skb(skb);
 	return;
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 92d3ea3..6117100 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -212,7 +212,7 @@ int frag_reassemble_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 
 out:
 	if (orig_node)
-		orig_node_free_ref(orig_node);
+		batadv_orig_node_free_ref(orig_node);
 	return ret;
 }
 
@@ -355,9 +355,9 @@ find_router:
 
 out:
 	if (neigh_node)
-		neigh_node_free_ref(neigh_node);
+		batadv_neigh_node_free_ref(neigh_node);
 	if (orig_node)
-		orig_node_free_ref(orig_node);
+		batadv_orig_node_free_ref(orig_node);
 	if (ret == 1)
 		kfree_skb(skb);
 	return ret;
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 99f1931..1972a11 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -574,7 +574,7 @@ static int find_best_vis_server(struct bat_priv *bat_priv,
 
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(orig_node, node, head, hash_entry) {
-			router = orig_node_get_router(orig_node);
+			router = batadv_orig_node_get_router(orig_node);
 			if (!router)
 				continue;
 
@@ -584,7 +584,7 @@ static int find_best_vis_server(struct bat_priv *bat_priv,
 				memcpy(packet->target_orig, orig_node->orig,
 				       ETH_ALEN);
 			}
-			neigh_node_free_ref(router);
+			batadv_neigh_node_free_ref(router);
 		}
 		rcu_read_unlock();
 	}
@@ -641,7 +641,7 @@ static int generate_vis_packet(struct bat_priv *bat_priv)
 
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(orig_node, node, head, hash_entry) {
-			router = orig_node_get_router(orig_node);
+			router = batadv_orig_node_get_router(orig_node);
 			if (!router)
 				continue;
 
@@ -665,7 +665,7 @@ static int generate_vis_packet(struct bat_priv *bat_priv)
 			packet->entries++;
 
 next:
-			neigh_node_free_ref(router);
+			batadv_neigh_node_free_ref(router);
 
 			if (vis_packet_full(info))
 				goto unlock;
@@ -757,7 +757,7 @@ static void broadcast_vis_packet(struct bat_priv *bat_priv,
 			if (!(orig_node->flags & VIS_SERVER))
 				continue;
 
-			router = orig_node_get_router(orig_node);
+			router = batadv_orig_node_get_router(orig_node);
 			if (!router)
 				continue;
 
@@ -765,7 +765,7 @@ static void broadcast_vis_packet(struct bat_priv *bat_priv,
 			 * this node. */
 			if (recv_list_is_in(bat_priv, &info->recv_list,
 					    orig_node->orig)) {
-				neigh_node_free_ref(router);
+				batadv_neigh_node_free_ref(router);
 				continue;
 			}
 
@@ -773,7 +773,7 @@ static void broadcast_vis_packet(struct bat_priv *bat_priv,
 			hard_iface = router->if_incoming;
 			memcpy(dstaddr, router->addr, ETH_ALEN);
 
-			neigh_node_free_ref(router);
+			batadv_neigh_node_free_ref(router);
 
 			skb = skb_clone(info->skb_packet, GFP_ATOMIC);
 			if (skb)
@@ -798,7 +798,7 @@ static void unicast_vis_packet(struct bat_priv *bat_priv,
 	if (!orig_node)
 		goto out;
 
-	router = orig_node_get_router(orig_node);
+	router = batadv_orig_node_get_router(orig_node);
 	if (!router)
 		goto out;
 
@@ -808,9 +808,9 @@ static void unicast_vis_packet(struct bat_priv *bat_priv,
 
 out:
 	if (router)
-		neigh_node_free_ref(router);
+		batadv_neigh_node_free_ref(router);
 	if (orig_node)
-		orig_node_free_ref(orig_node);
+		batadv_orig_node_free_ref(orig_node);
 }
 
 /* only send one vis packet. called from send_vis_packets() */
-- 
1.7.9.4
