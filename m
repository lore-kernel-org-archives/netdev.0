From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 13/20] batman-adv: Prefix routing non-static
	functions with batadv_
Date: Thu, 21 Jun 2012 18:57:49 +0200
Message-ID: <1340297876-29923-14-git-send-email-ordex@autistici.org>
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
 net/batman-adv/bat_iv_ogm.c     |   15 +++++-----
 net/batman-adv/gateway_client.c |    5 ++--
 net/batman-adv/main.c           |   14 ++++-----
 net/batman-adv/originator.c     |    5 ++--
 net/batman-adv/routing.c        |   60 ++++++++++++++++++++-------------------
 net/batman-adv/routing.h        |   52 +++++++++++++++++----------------
 net/batman-adv/unicast.c        |    3 +-
 7 files changed, 80 insertions(+), 74 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index cd57cf2..f48467f 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -599,7 +599,7 @@ static void bat_iv_ogm_schedule(struct hard_iface *hard_iface)
 	else
 		batman_ogm_packet->gw_flags = NO_FLAGS;
 
-	slide_own_bcast_window(hard_iface);
+	batadv_slide_own_bcast_window(hard_iface);
 	bat_iv_ogm_queue_add(bat_priv, hard_iface->packet_buff,
 			     hard_iface->packet_len, hard_iface, 1,
 			     bat_iv_ogm_emit_send_time(bat_priv));
@@ -684,7 +684,7 @@ static void bat_iv_ogm_orig_update(struct bat_priv *bat_priv,
 		neigh_node->last_ttl = batman_ogm_packet->header.ttl;
 	}
 
-	bonding_candidate_add(orig_node, neigh_node);
+	batadv_bonding_candidate_add(orig_node, neigh_node);
 
 	/* if this neighbor already is our next hop there is nothing
 	 * to change */
@@ -715,7 +715,7 @@ static void bat_iv_ogm_orig_update(struct bat_priv *bat_priv,
 			goto update_tt;
 	}
 
-	update_route(bat_priv, orig_node, neigh_node);
+	batadv_update_route(bat_priv, orig_node, neigh_node);
 
 update_tt:
 	/* I have to check for transtable changes only if the OGM has been
@@ -884,8 +884,8 @@ static int bat_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 
 	/* signalize caller that the packet is to be dropped. */
 	if (!hlist_empty(&orig_node->neigh_list) &&
-	    window_protected(bat_priv, seq_diff,
-			     &orig_node->batman_seqno_reset))
+	    batadv_window_protected(bat_priv, seq_diff,
+				    &orig_node->batman_seqno_reset))
 		goto out;
 
 	rcu_read_lock();
@@ -1133,7 +1133,8 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	is_bidirectional = bat_iv_ogm_calc_tq(orig_node, orig_neigh_node,
 					      batman_ogm_packet, if_incoming);
 
-	bonding_save_primary(orig_node, orig_neigh_node, batman_ogm_packet);
+	batadv_bonding_save_primary(orig_node, orig_neigh_node,
+				    batman_ogm_packet);
 
 	/* update ranking if it is not a duplicate or has the same
 	 * seqno and similar ttl as the non-duplicate */
@@ -1201,7 +1202,7 @@ static int bat_iv_ogm_receive(struct sk_buff *skb,
 	unsigned char *tt_buff, *packet_buff;
 	bool ret;
 
-	ret = check_management_packet(skb, if_incoming, BATMAN_OGM_HLEN);
+	ret = batadv_check_management_packet(skb, if_incoming, BATMAN_OGM_HLEN);
 	if (!ret)
 		return NET_RX_DROP;
 
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index e92055d..2bf330d 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -682,7 +682,8 @@ bool batadv_gw_out_of_range(struct bat_priv *bat_priv,
 		/* If the dhcp packet has been sent to a different gw,
 		 * we have to evaluate whether the old gw is still
 		 * reliable enough */
-		neigh_curr = find_router(bat_priv, curr_gw->orig_node, NULL);
+		neigh_curr = batadv_find_router(bat_priv, curr_gw->orig_node,
+						NULL);
 		if (!neigh_curr)
 			goto out;
 
@@ -693,7 +694,7 @@ bool batadv_gw_out_of_range(struct bat_priv *bat_priv,
 		goto out;
 	}
 
-	neigh_old = find_router(bat_priv, orig_dst_node, NULL);
+	neigh_old = batadv_find_router(bat_priv, orig_dst_node, NULL);
 	if (!neigh_old)
 		goto out;
 
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index eba5d28..92f39b5 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -272,19 +272,19 @@ static void recv_handler_init(void)
 		recv_packet_handler[i] = recv_unhandled_packet;
 
 	/* batman icmp packet */
-	recv_packet_handler[BAT_ICMP] = recv_icmp_packet;
+	recv_packet_handler[BAT_ICMP] = batadv_recv_icmp_packet;
 	/* unicast packet */
-	recv_packet_handler[BAT_UNICAST] = recv_unicast_packet;
+	recv_packet_handler[BAT_UNICAST] = batadv_recv_unicast_packet;
 	/* fragmented unicast packet */
-	recv_packet_handler[BAT_UNICAST_FRAG] = recv_ucast_frag_packet;
+	recv_packet_handler[BAT_UNICAST_FRAG] = batadv_recv_ucast_frag_packet;
 	/* broadcast packet */
-	recv_packet_handler[BAT_BCAST] = recv_bcast_packet;
+	recv_packet_handler[BAT_BCAST] = batadv_recv_bcast_packet;
 	/* vis packet */
-	recv_packet_handler[BAT_VIS] = recv_vis_packet;
+	recv_packet_handler[BAT_VIS] = batadv_recv_vis_packet;
 	/* Translation table query (request or response) */
-	recv_packet_handler[BAT_TT_QUERY] = recv_tt_query;
+	recv_packet_handler[BAT_TT_QUERY] = batadv_recv_tt_query;
 	/* Roaming advertisement */
-	recv_packet_handler[BAT_ROAM_ADV] = recv_roam_adv;
+	recv_packet_handler[BAT_ROAM_ADV] = batadv_recv_roam_adv;
 }
 
 int recv_handler_register(uint8_t packet_type,
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 9358513..12c2e1e 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -307,7 +307,7 @@ static bool purge_orig_neighbors(struct bat_priv *bat_priv,
 			neigh_purged = true;
 
 			hlist_del_rcu(&neigh_node->list);
-			bonding_candidate_del(orig_node, neigh_node);
+			batadv_bonding_candidate_del(orig_node, neigh_node);
 			batadv_neigh_node_free_ref(neigh_node);
 		} else {
 			if ((!*best_neigh_node) ||
@@ -334,7 +334,8 @@ static bool purge_orig_node(struct bat_priv *bat_priv,
 	} else {
 		if (purge_orig_neighbors(bat_priv, orig_node,
 					 &best_neigh_node))
-			update_route(bat_priv, orig_node, best_neigh_node);
+			batadv_update_route(bat_priv, orig_node,
+					    best_neigh_node);
 	}
 
 	return false;
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 77fe460..631b40b 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -34,7 +34,7 @@
 static int route_unicast_packet(struct sk_buff *skb,
 				struct hard_iface *recv_if);
 
-void slide_own_bcast_window(struct hard_iface *hard_iface)
+void batadv_slide_own_bcast_window(struct hard_iface *hard_iface)
 {
 	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	struct hashtable_t *hash = bat_priv->orig_hash;
@@ -108,8 +108,8 @@ static void _update_route(struct bat_priv *bat_priv,
 		batadv_neigh_node_free_ref(curr_router);
 }
 
-void update_route(struct bat_priv *bat_priv, struct orig_node *orig_node,
-		  struct neigh_node *neigh_node)
+void batadv_update_route(struct bat_priv *bat_priv, struct orig_node *orig_node,
+			 struct neigh_node *neigh_node)
 {
 	struct neigh_node *router = NULL;
 
@@ -127,8 +127,8 @@ out:
 }
 
 /* caller must hold the neigh_list_lock */
-void bonding_candidate_del(struct orig_node *orig_node,
-			   struct neigh_node *neigh_node)
+void batadv_bonding_candidate_del(struct orig_node *orig_node,
+				  struct neigh_node *neigh_node)
 {
 	/* this neighbor is not part of our candidate list */
 	if (list_empty(&neigh_node->bonding_list))
@@ -143,8 +143,8 @@ out:
 	return;
 }
 
-void bonding_candidate_add(struct orig_node *orig_node,
-			   struct neigh_node *neigh_node)
+void batadv_bonding_candidate_add(struct orig_node *orig_node,
+				  struct neigh_node *neigh_node)
 {
 	struct hlist_node *node;
 	struct neigh_node *tmp_neigh_node, *router = NULL;
@@ -204,7 +204,7 @@ void bonding_candidate_add(struct orig_node *orig_node,
 	goto out;
 
 candidate_del:
-	bonding_candidate_del(orig_node, neigh_node);
+	batadv_bonding_candidate_del(orig_node, neigh_node);
 
 out:
 	spin_unlock_bh(&orig_node->neigh_list_lock);
@@ -214,9 +214,10 @@ out:
 }
 
 /* copy primary address for bonding */
-void bonding_save_primary(const struct orig_node *orig_node,
-			  struct orig_node *orig_neigh_node,
-			  const struct batman_ogm_packet *batman_ogm_packet)
+void
+batadv_bonding_save_primary(const struct orig_node *orig_node,
+			    struct orig_node *orig_neigh_node,
+			    const struct batman_ogm_packet *batman_ogm_packet)
 {
 	if (!(batman_ogm_packet->flags & PRIMARIES_FIRST_HOP))
 		return;
@@ -229,8 +230,8 @@ void bonding_save_primary(const struct orig_node *orig_node,
  *  0 if the packet is to be accepted
  *  1 if the packet is to be ignored.
  */
-int window_protected(struct bat_priv *bat_priv, int32_t seq_num_diff,
-		     unsigned long *last_reset)
+int batadv_window_protected(struct bat_priv *bat_priv, int32_t seq_num_diff,
+			    unsigned long *last_reset)
 {
 	if ((seq_num_diff <= -TQ_LOCAL_WINDOW_SIZE) ||
 	    (seq_num_diff >= EXPECTED_SEQNO_RANGE)) {
@@ -245,9 +246,9 @@ int window_protected(struct bat_priv *bat_priv, int32_t seq_num_diff,
 	return 0;
 }
 
-bool check_management_packet(struct sk_buff *skb,
-			     struct hard_iface *hard_iface,
-			     int header_len)
+bool batadv_check_management_packet(struct sk_buff *skb,
+				    struct hard_iface *hard_iface,
+				    int header_len)
 {
 	struct ethhdr *ethhdr;
 
@@ -387,7 +388,7 @@ out:
 }
 
 
-int recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if)
+int batadv_recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 {
 	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
 	struct icmp_packet_rr *icmp_packet;
@@ -569,7 +570,7 @@ static struct neigh_node *find_ifalter_router(struct orig_node *primary_orig,
 	return router;
 }
 
-int recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
+int batadv_recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 {
 	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
 	struct tt_query_packet *tt_query;
@@ -644,7 +645,7 @@ out:
 	return NET_RX_DROP;
 }
 
-int recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_if)
+int batadv_recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_if)
 {
 	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
 	struct roam_adv_packet *roam_adv_packet;
@@ -704,9 +705,9 @@ out:
 /* find a suitable router for this originator, and use
  * bonding if possible. increases the found neighbors
  * refcount.*/
-struct neigh_node *find_router(struct bat_priv *bat_priv,
-			       struct orig_node *orig_node,
-			       const struct hard_iface *recv_if)
+struct neigh_node *batadv_find_router(struct bat_priv *bat_priv,
+				      struct orig_node *orig_node,
+				      const struct hard_iface *recv_if)
 {
 	struct orig_node *primary_orig_node;
 	struct orig_node *router_orig;
@@ -834,7 +835,7 @@ static int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 		goto out;
 
 	/* find_router() increases neigh_nodes refcount if found. */
-	neigh_node = find_router(bat_priv, orig_node, recv_if);
+	neigh_node = batadv_find_router(bat_priv, orig_node, recv_if);
 
 	if (!neigh_node)
 		goto out;
@@ -965,7 +966,7 @@ static int check_unicast_ttvn(struct bat_priv *bat_priv,
 	return 1;
 }
 
-int recv_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
+int batadv_recv_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 {
 	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
 	struct unicast_packet *unicast_packet;
@@ -988,7 +989,8 @@ int recv_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	return route_unicast_packet(skb, recv_if);
 }
 
-int recv_ucast_frag_packet(struct sk_buff *skb, struct hard_iface *recv_if)
+int batadv_recv_ucast_frag_packet(struct sk_buff *skb,
+				  struct hard_iface *recv_if)
 {
 	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
 	struct unicast_frag_packet *unicast_packet;
@@ -1025,7 +1027,7 @@ int recv_ucast_frag_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 }
 
 
-int recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
+int batadv_recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 {
 	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
 	struct orig_node *orig_node = NULL;
@@ -1077,8 +1079,8 @@ int recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	seq_diff = ntohl(bcast_packet->seqno) - orig_node->last_bcast_seqno;
 
 	/* check whether the packet is old and the host just restarted. */
-	if (window_protected(bat_priv, seq_diff,
-			     &orig_node->bcast_seqno_reset))
+	if (batadv_window_protected(bat_priv, seq_diff,
+				    &orig_node->bcast_seqno_reset))
 		goto spin_unlock;
 
 	/* mark broadcast in flood history, update window position
@@ -1114,7 +1116,7 @@ out:
 	return ret;
 }
 
-int recv_vis_packet(struct sk_buff *skb, struct hard_iface *recv_if)
+int batadv_recv_vis_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 {
 	struct vis_packet *vis_packet;
 	struct ethhdr *ethhdr;
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index d6bbbeb..4652f0c 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -22,30 +22,32 @@
 #ifndef _NET_BATMAN_ADV_ROUTING_H_
 #define _NET_BATMAN_ADV_ROUTING_H_
 
-void slide_own_bcast_window(struct hard_iface *hard_iface);
-bool check_management_packet(struct sk_buff *skb,
-			     struct hard_iface *hard_iface,
-			     int header_len);
-void update_route(struct bat_priv *bat_priv, struct orig_node *orig_node,
-		  struct neigh_node *neigh_node);
-int recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if);
-int recv_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if);
-int recv_ucast_frag_packet(struct sk_buff *skb, struct hard_iface *recv_if);
-int recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if);
-int recv_vis_packet(struct sk_buff *skb, struct hard_iface *recv_if);
-int recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if);
-int recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_if);
-struct neigh_node *find_router(struct bat_priv *bat_priv,
-			       struct orig_node *orig_node,
-			       const struct hard_iface *recv_if);
-void bonding_candidate_del(struct orig_node *orig_node,
-			   struct neigh_node *neigh_node);
-void bonding_candidate_add(struct orig_node *orig_node,
-			   struct neigh_node *neigh_node);
-void bonding_save_primary(const struct orig_node *orig_node,
-			  struct orig_node *orig_neigh_node,
-			  const struct batman_ogm_packet *batman_ogm_packet);
-int window_protected(struct bat_priv *bat_priv, int32_t seq_num_diff,
-		     unsigned long *last_reset);
+void batadv_slide_own_bcast_window(struct hard_iface *hard_iface);
+bool batadv_check_management_packet(struct sk_buff *skb,
+				    struct hard_iface *hard_iface,
+				    int header_len);
+void batadv_update_route(struct bat_priv *bat_priv, struct orig_node *orig_node,
+			 struct neigh_node *neigh_node);
+int batadv_recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if);
+int batadv_recv_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if);
+int batadv_recv_ucast_frag_packet(struct sk_buff *skb,
+				  struct hard_iface *recv_if);
+int batadv_recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if);
+int batadv_recv_vis_packet(struct sk_buff *skb, struct hard_iface *recv_if);
+int batadv_recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if);
+int batadv_recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_if);
+struct neigh_node *batadv_find_router(struct bat_priv *bat_priv,
+				      struct orig_node *orig_node,
+				      const struct hard_iface *recv_if);
+void batadv_bonding_candidate_del(struct orig_node *orig_node,
+				  struct neigh_node *neigh_node);
+void batadv_bonding_candidate_add(struct orig_node *orig_node,
+				  struct neigh_node *neigh_node);
+void batadv_bonding_save_primary(const struct orig_node *orig_node,
+				 struct orig_node *orig_neigh_node,
+				 const struct batman_ogm_packet
+				 *batman_ogm_packet);
+int batadv_window_protected(struct bat_priv *bat_priv, int32_t seq_num_diff,
+			    unsigned long *last_reset);
 
 #endif /* _NET_BATMAN_ADV_ROUTING_H_ */
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 6117100..894c6a4 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -310,8 +310,7 @@ find_router:
 	 *  - if orig_node is NULL it returns NULL
 	 *  - increases neigh_nodes refcount if found.
 	 */
-	neigh_node = find_router(bat_priv, orig_node, NULL);
-
+	neigh_node = batadv_find_router(bat_priv, orig_node, NULL);
 	if (!neigh_node)
 		goto out;
 
-- 
1.7.9.4
