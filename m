From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 07/20] batman-adv: Prefix main static inline functions with batadv_
Date: Mon, 25 Jun 2012 08:54:31 +0200
Message-ID: <1340607284-29950-8-git-send-email-ordex@autistici.org>
References: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:30461 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754538Ab2FYGyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 02:54:46 -0400
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
 net/batman-adv/bat_iv_ogm.c            |  206 +++++++++++++++++---------------
 net/batman-adv/bat_sysfs.c             |    8 +-
 net/batman-adv/bitarray.c              |   10 +-
 net/batman-adv/bridge_loop_avoidance.c |  165 ++++++++++++-------------
 net/batman-adv/gateway_client.c        |   54 ++++-----
 net/batman-adv/hard-interface.c        |    4 +-
 net/batman-adv/icmp_socket.c           |   12 +-
 net/batman-adv/main.c                  |    8 +-
 net/batman-adv/main.h                  |   17 +--
 net/batman-adv/originator.c            |   61 +++++-----
 net/batman-adv/originator.h            |    2 +-
 net/batman-adv/routing.c               |   68 ++++++-----
 net/batman-adv/send.c                  |   12 +-
 net/batman-adv/soft-interface.c        |    2 +-
 net/batman-adv/translation-table.c     |  149 +++++++++++------------
 net/batman-adv/vis.c                   |   27 +++--
 16 files changed, 412 insertions(+), 393 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 94e6fdb..025df7c 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -179,16 +179,16 @@ static void bat_iv_ogm_send_to_if(struct forw_packet *forw_packet,
 		fwd_str = (packet_num > 0 ? "Forwarding" : (forw_packet->own ?
 							    "Sending own" :
 							    "Forwarding"));
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"%s %spacket (originator %pM, seqno %u, TQ %d, TTL %d, IDF %s, ttvn %d) on interface %s [%pM]\n",
-			fwd_str, (packet_num > 0 ? "aggregated " : ""),
-			batman_ogm_packet->orig,
-			ntohl(batman_ogm_packet->seqno),
-			batman_ogm_packet->tq, batman_ogm_packet->header.ttl,
-			(batman_ogm_packet->flags & DIRECTLINK ?
-			 "on" : "off"),
-			batman_ogm_packet->ttvn, hard_iface->net_dev->name,
-			hard_iface->net_dev->dev_addr);
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "%s %spacket (originator %pM, seqno %u, TQ %d, TTL %d, IDF %s, ttvn %d) on interface %s [%pM]\n",
+			   fwd_str, (packet_num > 0 ? "aggregated " : ""),
+			   batman_ogm_packet->orig,
+			   ntohl(batman_ogm_packet->seqno),
+			   batman_ogm_packet->tq, batman_ogm_packet->header.ttl,
+			   (batman_ogm_packet->flags & DIRECTLINK ?
+			    "on" : "off"),
+			   batman_ogm_packet->ttvn, hard_iface->net_dev->name,
+			   hard_iface->net_dev->dev_addr);
 
 		buff_pos += BATMAN_OGM_HLEN;
 		buff_pos += batadv_tt_len(batman_ogm_packet->tt_num_changes);
@@ -243,14 +243,14 @@ static void bat_iv_ogm_emit(struct forw_packet *forw_packet)
 	    (forw_packet->own && (forw_packet->if_incoming != primary_if))) {
 
 		/* FIXME: what about aggregated packets ? */
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"%s packet (originator %pM, seqno %u, TTL %d) on interface %s [%pM]\n",
-			(forw_packet->own ? "Sending own" : "Forwarding"),
-			batman_ogm_packet->orig,
-			ntohl(batman_ogm_packet->seqno),
-			batman_ogm_packet->header.ttl,
-			forw_packet->if_incoming->net_dev->name,
-			forw_packet->if_incoming->net_dev->dev_addr);
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "%s packet (originator %pM, seqno %u, TTL %d) on interface %s [%pM]\n",
+			   (forw_packet->own ? "Sending own" : "Forwarding"),
+			   batman_ogm_packet->orig,
+			   ntohl(batman_ogm_packet->seqno),
+			   batman_ogm_packet->header.ttl,
+			   forw_packet->if_incoming->net_dev->name,
+			   forw_packet->if_incoming->net_dev->dev_addr);
 
 		/* skb is only used once and than forw_packet is free'd */
 		batadv_send_skb_packet(forw_packet->skb,
@@ -373,8 +373,8 @@ static void bat_iv_ogm_aggregate_new(const unsigned char *packet_buff,
 	/* own packet should always be scheduled */
 	if (!own_packet) {
 		if (!atomic_dec_not_zero(&bat_priv->batman_queue_left)) {
-			bat_dbg(DBG_BATMAN, bat_priv,
-				"batman packet queue full\n");
+			batadv_dbg(DBG_BATMAN, bat_priv,
+				   "batman packet queue full\n");
 			goto out;
 		}
 	}
@@ -521,7 +521,7 @@ static void bat_iv_ogm_forward(struct orig_node *orig_node,
 	uint8_t tt_num_changes;
 
 	if (batman_ogm_packet->header.ttl <= 1) {
-		bat_dbg(DBG_BATMAN, bat_priv, "ttl exceeded\n");
+		batadv_dbg(DBG_BATMAN, bat_priv, "ttl exceeded\n");
 		return;
 	}
 
@@ -546,9 +546,9 @@ static void bat_iv_ogm_forward(struct orig_node *orig_node,
 	/* apply hop penalty */
 	batman_ogm_packet->tq = hop_penalty(batman_ogm_packet->tq, bat_priv);
 
-	bat_dbg(DBG_BATMAN, bat_priv,
-		"Forwarding packet: tq: %i, ttl: %i\n",
-		batman_ogm_packet->tq, batman_ogm_packet->header.ttl);
+	batadv_dbg(DBG_BATMAN, bat_priv,
+		   "Forwarding packet: tq: %i, ttl: %i\n",
+		   batman_ogm_packet->tq, batman_ogm_packet->header.ttl);
 
 	/* switch of primaries first hop flag when forwarding */
 	batman_ogm_packet->flags &= ~PRIMARIES_FIRST_HOP;
@@ -625,16 +625,18 @@ static void bat_iv_ogm_orig_update(struct bat_priv *bat_priv,
 	struct orig_node *orig_node_tmp;
 	struct hlist_node *node;
 	uint8_t bcast_own_sum_orig, bcast_own_sum_neigh;
+	uint8_t *neigh_addr;
 
-	bat_dbg(DBG_BATMAN, bat_priv,
-		"update_originator(): Searching and updating originator entry of received packet\n");
+	batadv_dbg(DBG_BATMAN, bat_priv,
+		   "update_originator(): Searching and updating originator entry of received packet\n");
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(tmp_neigh_node, node,
 				 &orig_node->neigh_list, list) {
-		if (compare_eth(tmp_neigh_node->addr, ethhdr->h_source) &&
-		    (tmp_neigh_node->if_incoming == if_incoming) &&
-		     atomic_inc_not_zero(&tmp_neigh_node->refcount)) {
+		neigh_addr = tmp_neigh_node->addr;
+		if (batadv_compare_eth(neigh_addr, ethhdr->h_source) &&
+		    tmp_neigh_node->if_incoming == if_incoming &&
+		    atomic_inc_not_zero(&tmp_neigh_node->refcount)) {
 			if (neigh_node)
 				batadv_neigh_node_free_ref(neigh_node);
 			neigh_node = tmp_neigh_node;
@@ -667,8 +669,8 @@ static void bat_iv_ogm_orig_update(struct bat_priv *bat_priv,
 		if (!neigh_node)
 			goto unlock;
 	} else
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Updating existing last-hop neighbor of originator\n");
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Updating existing last-hop neighbor of originator\n");
 
 	rcu_read_unlock();
 
@@ -774,7 +776,8 @@ static int bat_iv_ogm_calc_tq(struct orig_node *orig_node,
 	hlist_for_each_entry_rcu(tmp_neigh_node, node,
 				 &orig_neigh_node->neigh_list, list) {
 
-		if (!compare_eth(tmp_neigh_node->addr, orig_neigh_node->orig))
+		if (!batadv_compare_eth(tmp_neigh_node->addr,
+					orig_neigh_node->orig))
 			continue;
 
 		if (tmp_neigh_node->if_incoming != if_incoming)
@@ -844,10 +847,11 @@ static int bat_iv_ogm_calc_tq(struct orig_node *orig_node,
 							* tq_asym_penalty) /
 						(TQ_MAX_VALUE * TQ_MAX_VALUE));
 
-	bat_dbg(DBG_BATMAN, bat_priv,
-		"bidirectional: orig = %-15pM neigh = %-15pM => own_bcast = %2i, real recv = %2i, local tq: %3i, asym_penalty: %3i, total tq: %3i\n",
-		orig_node->orig, orig_neigh_node->orig, total_count,
-		neigh_rq_count, tq_own,	tq_asym_penalty, batman_ogm_packet->tq);
+	batadv_dbg(DBG_BATMAN, bat_priv,
+		   "bidirectional: orig = %-15pM neigh = %-15pM => own_bcast = %2i, real recv = %2i, local tq: %3i, asym_penalty: %3i, total tq: %3i\n",
+		   orig_node->orig, orig_neigh_node->orig, total_count,
+		   neigh_rq_count, tq_own,
+		   tq_asym_penalty, batman_ogm_packet->tq);
 
 	/* if link has the minimum required transmission quality
 	 * consider it bidirectional
@@ -883,6 +887,7 @@ static int bat_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 	int need_update = 0;
 	int set_mark, ret = -1;
 	uint32_t seqno = ntohl(batman_ogm_packet->seqno);
+	uint8_t *neigh_addr;
 
 	orig_node = batadv_get_orig_node(bat_priv, batman_ogm_packet->orig);
 	if (!orig_node)
@@ -905,8 +910,9 @@ static int bat_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 						orig_node->last_real_seqno,
 						seqno);
 
-		if (compare_eth(tmp_neigh_node->addr, ethhdr->h_source) &&
-		    (tmp_neigh_node->if_incoming == if_incoming))
+		neigh_addr = tmp_neigh_node->addr;
+		if (batadv_compare_eth(neigh_addr, ethhdr->h_source) &&
+		    tmp_neigh_node->if_incoming == if_incoming)
 			set_mark = 1;
 		else
 			set_mark = 0;
@@ -923,9 +929,9 @@ static int bat_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 	rcu_read_unlock();
 
 	if (need_update) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"updating last_seqno: old %u, new %u\n",
-			orig_node->last_real_seqno, seqno);
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "updating last_seqno: old %u, new %u\n",
+			   orig_node->last_real_seqno, seqno);
 		orig_node->last_real_seqno = seqno;
 	}
 
@@ -954,6 +960,7 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	bool is_from_best_next_hop = false;
 	int is_duplicate;
 	uint32_t if_incoming_seqno;
+	uint8_t *prev_sender;
 
 	/* Silently drop when the batman packet is actually not a
 	 * correct packet.
@@ -975,18 +982,19 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 
 	has_directlink_flag = (batman_ogm_packet->flags & DIRECTLINK ? 1 : 0);
 
-	if (compare_eth(ethhdr->h_source, batman_ogm_packet->orig))
+	if (batadv_compare_eth(ethhdr->h_source, batman_ogm_packet->orig))
 		is_single_hop_neigh = true;
 
-	bat_dbg(DBG_BATMAN, bat_priv,
-		"Received BATMAN packet via NB: %pM, IF: %s [%pM] (from OG: %pM, via prev OG: %pM, seqno %u, ttvn %u, crc %u, changes %u, td %d, TTL %d, V %d, IDF %d)\n",
-		ethhdr->h_source, if_incoming->net_dev->name,
-		if_incoming->net_dev->dev_addr, batman_ogm_packet->orig,
-		batman_ogm_packet->prev_sender, ntohl(batman_ogm_packet->seqno),
-		batman_ogm_packet->ttvn, ntohs(batman_ogm_packet->tt_crc),
-		batman_ogm_packet->tt_num_changes, batman_ogm_packet->tq,
-		batman_ogm_packet->header.ttl,
-		batman_ogm_packet->header.version, has_directlink_flag);
+	batadv_dbg(DBG_BATMAN, bat_priv,
+		   "Received BATMAN packet via NB: %pM, IF: %s [%pM] (from OG: %pM, via prev OG: %pM, seqno %u, ttvn %u, crc %u, changes %u, td %d, TTL %d, V %d, IDF %d)\n",
+		   ethhdr->h_source, if_incoming->net_dev->name,
+		   if_incoming->net_dev->dev_addr, batman_ogm_packet->orig,
+		   batman_ogm_packet->prev_sender,
+		   ntohl(batman_ogm_packet->seqno), batman_ogm_packet->ttvn,
+		   ntohs(batman_ogm_packet->tt_crc),
+		   batman_ogm_packet->tt_num_changes, batman_ogm_packet->tq,
+		   batman_ogm_packet->header.ttl,
+		   batman_ogm_packet->header.version, has_directlink_flag);
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
@@ -996,16 +1004,16 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 		if (hard_iface->soft_iface != if_incoming->soft_iface)
 			continue;
 
-		if (compare_eth(ethhdr->h_source,
-				hard_iface->net_dev->dev_addr))
+		if (batadv_compare_eth(ethhdr->h_source,
+				       hard_iface->net_dev->dev_addr))
 			is_my_addr = 1;
 
-		if (compare_eth(batman_ogm_packet->orig,
-				hard_iface->net_dev->dev_addr))
+		if (batadv_compare_eth(batman_ogm_packet->orig,
+				       hard_iface->net_dev->dev_addr))
 			is_my_orig = 1;
 
-		if (compare_eth(batman_ogm_packet->prev_sender,
-				hard_iface->net_dev->dev_addr))
+		if (batadv_compare_eth(batman_ogm_packet->prev_sender,
+				       hard_iface->net_dev->dev_addr))
 			is_my_oldorig = 1;
 
 		if (is_broadcast_ether_addr(ethhdr->h_source))
@@ -1014,23 +1022,23 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	rcu_read_unlock();
 
 	if (batman_ogm_packet->header.version != COMPAT_VERSION) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: incompatible batman version (%i)\n",
-			batman_ogm_packet->header.version);
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Drop packet: incompatible batman version (%i)\n",
+			   batman_ogm_packet->header.version);
 		return;
 	}
 
 	if (is_my_addr) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: received my own broadcast (sender: %pM)\n",
-			ethhdr->h_source);
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Drop packet: received my own broadcast (sender: %pM)\n",
+			   ethhdr->h_source);
 		return;
 	}
 
 	if (is_broadcast) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: ignoring all packets with broadcast source addr (sender: %pM)\n",
-			ethhdr->h_source);
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Drop packet: ignoring all packets with broadcast source addr (sender: %pM)\n",
+			   ethhdr->h_source);
 		return;
 	}
 
@@ -1049,8 +1057,8 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 		 * save packet seqno for bidirectional check
 		 */
 		if (has_directlink_flag &&
-		    compare_eth(if_incoming->net_dev->dev_addr,
-				batman_ogm_packet->orig)) {
+		    batadv_compare_eth(if_incoming->net_dev->dev_addr,
+				       batman_ogm_packet->orig)) {
 			offset = if_incoming->if_num * NUM_WORDS;
 
 			spin_lock_bh(&orig_neigh_node->ogm_cnt_lock);
@@ -1063,23 +1071,23 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 			spin_unlock_bh(&orig_neigh_node->ogm_cnt_lock);
 		}
 
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: originator packet from myself (via neighbor)\n");
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Drop packet: originator packet from myself (via neighbor)\n");
 		batadv_orig_node_free_ref(orig_neigh_node);
 		return;
 	}
 
 	if (is_my_oldorig) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: ignoring all rebroadcast echos (sender: %pM)\n",
-			ethhdr->h_source);
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Drop packet: ignoring all rebroadcast echos (sender: %pM)\n",
+			   ethhdr->h_source);
 		return;
 	}
 
 	if (batman_ogm_packet->flags & NOT_BEST_NEXT_HOP) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: ignoring all packets not forwarded from the best next hop (sender: %pM)\n",
-			ethhdr->h_source);
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Drop packet: ignoring all packets not forwarded from the best next hop (sender: %pM)\n",
+			   ethhdr->h_source);
 		return;
 	}
 
@@ -1091,15 +1099,15 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 						if_incoming);
 
 	if (is_duplicate == -1) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: packet within seqno protection time (sender: %pM)\n",
-			ethhdr->h_source);
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Drop packet: packet within seqno protection time (sender: %pM)\n",
+			   ethhdr->h_source);
 		goto out;
 	}
 
 	if (batman_ogm_packet->tq == 0) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: originator packet with tq equal 0\n");
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Drop packet: originator packet with tq equal 0\n");
 		goto out;
 	}
 
@@ -1108,18 +1116,18 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 		router_router = batadv_orig_node_get_router(router->orig_node);
 
 	if ((router && router->tq_avg != 0) &&
-	    (compare_eth(router->addr, ethhdr->h_source)))
+	    (batadv_compare_eth(router->addr, ethhdr->h_source)))
 		is_from_best_next_hop = true;
 
+	prev_sender = batman_ogm_packet->prev_sender;
 	/* avoid temporary routing loops */
 	if (router && router_router &&
-	    (compare_eth(router->addr, batman_ogm_packet->prev_sender)) &&
-	    !(compare_eth(batman_ogm_packet->orig,
-			  batman_ogm_packet->prev_sender)) &&
-	    (compare_eth(router->addr, router_router->addr))) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: ignoring all rebroadcast packets that may make me loop (sender: %pM)\n",
-			ethhdr->h_source);
+	    (batadv_compare_eth(router->addr, prev_sender)) &&
+	    !(batadv_compare_eth(batman_ogm_packet->orig, prev_sender)) &&
+	    (batadv_compare_eth(router->addr, router_router->addr))) {
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Drop packet: ignoring all rebroadcast packets that may make me loop (sender: %pM)\n",
+			   ethhdr->h_source);
 		goto out;
 	}
 
@@ -1138,8 +1146,8 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	 * don't route towards it
 	 */
 	if (!is_single_hop_neigh && (!orig_neigh_router)) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: OGM via unknown neighbor!\n");
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Drop packet: OGM via unknown neighbor!\n");
 		goto out_neigh;
 	}
 
@@ -1168,26 +1176,26 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 				   is_single_hop_neigh, is_from_best_next_hop,
 				   if_incoming);
 
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Forwarding packet: rebroadcast neighbor packet with direct link flag\n");
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Forwarding packet: rebroadcast neighbor packet with direct link flag\n");
 		goto out_neigh;
 	}
 
 	/* multihop originator */
 	if (!is_bidirectional) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: not received via bidirectional link\n");
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Drop packet: not received via bidirectional link\n");
 		goto out_neigh;
 	}
 
 	if (is_duplicate) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: duplicate packet received\n");
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Drop packet: duplicate packet received\n");
 		goto out_neigh;
 	}
 
-	bat_dbg(DBG_BATMAN, bat_priv,
-		"Forwarding packet: rebroadcast originator packet\n");
+	batadv_dbg(DBG_BATMAN, bat_priv,
+		   "Forwarding packet: rebroadcast originator packet\n");
 	bat_iv_ogm_forward(orig_node, ethhdr, batman_ogm_packet,
 			   is_single_hop_neigh, is_from_best_next_hop,
 			   if_incoming);
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 0c7e22e..7f464a9 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -730,9 +730,9 @@ out:
 		batadv_hardif_free_ref(primary_if);
 
 	if (ret)
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Impossible to send uevent for (%s,%s,%s) event (err: %d)\n",
-			uev_type_str[type], uev_action_str[action],
-			(action == UEV_DEL ? "NULL" : data), ret);
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Impossible to send uevent for (%s,%s,%s) event (err: %d)\n",
+			   uev_type_str[type], uev_action_str[action],
+			   (action == UEV_DEL ? "NULL" : data), ret);
 	return ret;
 }
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index 7a7065c..e195b9e 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -66,9 +66,9 @@ int batadv_bit_get_packet(void *priv, unsigned long *seq_bits,
 	/* sequence number is much newer, probably missed a lot of packets */
 	if ((seq_num_diff >= TQ_LOCAL_WINDOW_SIZE) &&
 	    (seq_num_diff < EXPECTED_SEQNO_RANGE)) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"We missed a lot of packets (%i) !\n",
-			seq_num_diff - 1);
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "We missed a lot of packets (%i) !\n",
+			   seq_num_diff - 1);
 		bitmap_zero(seq_bits, TQ_LOCAL_WINDOW_SIZE);
 		if (set_mark)
 			batadv_set_bit(seq_bits, 0);
@@ -83,8 +83,8 @@ int batadv_bit_get_packet(void *priv, unsigned long *seq_bits,
 	if ((seq_num_diff <= -TQ_LOCAL_WINDOW_SIZE) ||
 	    (seq_num_diff >= EXPECTED_SEQNO_RANGE)) {
 
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Other host probably restarted!\n");
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Other host probably restarted!\n");
 
 		bitmap_zero(seq_bits, TQ_LOCAL_WINDOW_SIZE);
 		if (set_mark)
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 1d143d5..b7d7084 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -294,25 +294,26 @@ static void bla_send_claim(struct bat_priv *bat_priv, uint8_t *mac,
 		 * set Ethernet SRC to the clients mac
 		 */
 		memcpy(ethhdr->h_source, mac, ETH_ALEN);
-		bat_dbg(DBG_BLA, bat_priv,
-			"bla_send_claim(): CLAIM %pM on vid %d\n", mac, vid);
+		batadv_dbg(DBG_BLA, bat_priv,
+			   "bla_send_claim(): CLAIM %pM on vid %d\n", mac, vid);
 		break;
 	case CLAIM_TYPE_DEL:
 		/* unclaim frame
 		 * set HW SRC to the clients mac
 		 */
 		memcpy(hw_src, mac, ETH_ALEN);
-		bat_dbg(DBG_BLA, bat_priv,
-			"bla_send_claim(): UNCLAIM %pM on vid %d\n", mac, vid);
+		batadv_dbg(DBG_BLA, bat_priv,
+			   "bla_send_claim(): UNCLAIM %pM on vid %d\n", mac,
+			   vid);
 		break;
 	case CLAIM_TYPE_ANNOUNCE:
 		/* announcement frame
 		 * set HW SRC to the special mac containg the crc
 		 */
 		memcpy(hw_src, mac, ETH_ALEN);
-		bat_dbg(DBG_BLA, bat_priv,
-			"bla_send_claim(): ANNOUNCE of %pM on vid %d\n",
-			ethhdr->h_source, vid);
+		batadv_dbg(DBG_BLA, bat_priv,
+			   "bla_send_claim(): ANNOUNCE of %pM on vid %d\n",
+			   ethhdr->h_source, vid);
 		break;
 	case CLAIM_TYPE_REQUEST:
 		/* request frame
@@ -320,9 +321,9 @@ static void bla_send_claim(struct bat_priv *bat_priv, uint8_t *mac,
 		 */
 		memcpy(hw_src, mac, ETH_ALEN);
 		memcpy(ethhdr->h_dest, mac, ETH_ALEN);
-		bat_dbg(DBG_BLA, bat_priv,
-			"bla_send_claim(): REQUEST of %pM to %pMon vid %d\n",
-			ethhdr->h_source, ethhdr->h_dest, vid);
+		batadv_dbg(DBG_BLA, bat_priv,
+			   "bla_send_claim(): REQUEST of %pM to %pMon vid %d\n",
+			   ethhdr->h_source, ethhdr->h_dest, vid);
 		break;
 
 	}
@@ -361,9 +362,9 @@ static struct backbone_gw *bla_get_backbone_gw(struct bat_priv *bat_priv,
 	if (entry)
 		return entry;
 
-	bat_dbg(DBG_BLA, bat_priv,
-		"bla_get_backbone_gw(): not found (%pM, %d), creating new entry\n",
-		orig, vid);
+	batadv_dbg(DBG_BLA, bat_priv,
+		   "bla_get_backbone_gw(): not found (%pM, %d), creating new entry\n",
+		   orig, vid);
 
 	entry = kzalloc(sizeof(*entry), GFP_ATOMIC);
 	if (!entry)
@@ -433,8 +434,8 @@ static void bla_answer_request(struct bat_priv *bat_priv,
 	struct backbone_gw *backbone_gw;
 	int i;
 
-	bat_dbg(DBG_BLA, bat_priv,
-		"bla_answer_request(): received a claim request, send all of our own claims again\n");
+	batadv_dbg(DBG_BLA, bat_priv,
+		   "bla_answer_request(): received a claim request, send all of our own claims again\n");
 
 	backbone_gw = backbone_hash_find(bat_priv,
 					 primary_if->net_dev->dev_addr, vid);
@@ -473,9 +474,8 @@ static void bla_send_request(struct backbone_gw *backbone_gw)
 	/* first, remove all old entries */
 	bla_del_backbone_claims(backbone_gw);
 
-	bat_dbg(DBG_BLA, backbone_gw->bat_priv,
-		"Sending REQUEST to %pM\n",
-		backbone_gw->orig);
+	batadv_dbg(DBG_BLA, backbone_gw->bat_priv, "Sending REQUEST to %pM\n",
+		   backbone_gw->orig);
 
 	/* send request */
 	bla_send_claim(backbone_gw->bat_priv, backbone_gw->orig,
@@ -538,9 +538,9 @@ static void bla_add_claim(struct bat_priv *bat_priv, const uint8_t *mac,
 		claim->backbone_gw = backbone_gw;
 
 		atomic_set(&claim->refcount, 2);
-		bat_dbg(DBG_BLA, bat_priv,
-			"bla_add_claim(): adding new entry %pM, vid %d to hash ...\n",
-			mac, vid);
+		batadv_dbg(DBG_BLA, bat_priv,
+			   "bla_add_claim(): adding new entry %pM, vid %d to hash ...\n",
+			   mac, vid);
 		hash_added = batadv_hash_add(bat_priv->claim_hash,
 					     compare_claim, choose_claim,
 					     claim, &claim->hash_entry);
@@ -556,9 +556,9 @@ static void bla_add_claim(struct bat_priv *bat_priv, const uint8_t *mac,
 			/* no need to register a new backbone */
 			goto claim_free_ref;
 
-		bat_dbg(DBG_BLA, bat_priv,
-			"bla_add_claim(): changing ownership for %pM, vid %d\n",
-			mac, vid);
+		batadv_dbg(DBG_BLA, bat_priv,
+			   "bla_add_claim(): changing ownership for %pM, vid %d\n",
+			   mac, vid);
 
 		claim->backbone_gw->crc ^=
 			crc16(0, claim->addr, ETH_ALEN);
@@ -590,7 +590,8 @@ static void bla_del_claim(struct bat_priv *bat_priv, const uint8_t *mac,
 	if (!claim)
 		return;
 
-	bat_dbg(DBG_BLA, bat_priv, "bla_del_claim(): %pM, vid %d\n", mac, vid);
+	batadv_dbg(DBG_BLA, bat_priv, "bla_del_claim(): %pM, vid %d\n", mac,
+		   vid);
 
 	batadv_hash_remove(bat_priv->claim_hash, compare_claim, choose_claim,
 			   claim);
@@ -622,15 +623,15 @@ static int handle_announce(struct bat_priv *bat_priv,
 	backbone_gw->lasttime = jiffies;
 	crc = ntohs(*((__be16 *)(&an_addr[4])));
 
-	bat_dbg(DBG_BLA, bat_priv,
-		"handle_announce(): ANNOUNCE vid %d (sent by %pM)... CRC = %04x\n",
-		vid, backbone_gw->orig, crc);
+	batadv_dbg(DBG_BLA, bat_priv,
+		   "handle_announce(): ANNOUNCE vid %d (sent by %pM)... CRC = %04x\n",
+		   vid, backbone_gw->orig, crc);
 
 	if (backbone_gw->crc != crc) {
-		bat_dbg(DBG_BLA, backbone_gw->bat_priv,
-			"handle_announce(): CRC FAILED for %pM/%d (my = %04x, sent = %04x)\n",
-			backbone_gw->orig, backbone_gw->vid, backbone_gw->crc,
-			crc);
+		batadv_dbg(DBG_BLA, backbone_gw->bat_priv,
+			   "handle_announce(): CRC FAILED for %pM/%d (my = %04x, sent = %04x)\n",
+			   backbone_gw->orig, backbone_gw->vid,
+			   backbone_gw->crc, crc);
 
 		bla_send_request(backbone_gw);
 	} else {
@@ -654,18 +655,18 @@ static int handle_request(struct bat_priv *bat_priv,
 			  struct ethhdr *ethhdr, short vid)
 {
 	/* check for REQUEST frame */
-	if (!compare_eth(backbone_addr, ethhdr->h_dest))
+	if (!batadv_compare_eth(backbone_addr, ethhdr->h_dest))
 		return 0;
 
 	/* sanity check, this should not happen on a normal switch,
 	 * we ignore it in this case.
 	 */
-	if (!compare_eth(ethhdr->h_dest, primary_if->net_dev->dev_addr))
+	if (!batadv_compare_eth(ethhdr->h_dest, primary_if->net_dev->dev_addr))
 		return 1;
 
-	bat_dbg(DBG_BLA, bat_priv,
-		"handle_request(): REQUEST vid %d (sent by %pM)...\n",
-		vid, ethhdr->h_source);
+	batadv_dbg(DBG_BLA, bat_priv,
+		   "handle_request(): REQUEST vid %d (sent by %pM)...\n",
+		   vid, ethhdr->h_source);
 
 	bla_answer_request(bat_priv, primary_if, vid);
 	return 1;
@@ -680,8 +681,8 @@ static int handle_unclaim(struct bat_priv *bat_priv,
 	struct backbone_gw *backbone_gw;
 
 	/* unclaim in any case if it is our own */
-	if (primary_if && compare_eth(backbone_addr,
-				      primary_if->net_dev->dev_addr))
+	if (primary_if && batadv_compare_eth(backbone_addr,
+					     primary_if->net_dev->dev_addr))
 		bla_send_claim(bat_priv, claim_addr, vid, CLAIM_TYPE_DEL);
 
 	backbone_gw = backbone_hash_find(bat_priv, backbone_addr, vid);
@@ -690,9 +691,9 @@ static int handle_unclaim(struct bat_priv *bat_priv,
 		return 1;
 
 	/* this must be an UNCLAIM frame */
-	bat_dbg(DBG_BLA, bat_priv,
-		"handle_unclaim(): UNCLAIM %pM on vid %d (sent by %pM)...\n",
-		claim_addr, vid, backbone_gw->orig);
+	batadv_dbg(DBG_BLA, bat_priv,
+		   "handle_unclaim(): UNCLAIM %pM on vid %d (sent by %pM)...\n",
+		   claim_addr, vid, backbone_gw->orig);
 
 	bla_del_claim(bat_priv, claim_addr, vid);
 	backbone_gw_free_ref(backbone_gw);
@@ -715,7 +716,7 @@ static int handle_claim(struct bat_priv *bat_priv,
 
 	/* this must be a CLAIM frame */
 	bla_add_claim(bat_priv, claim_addr, vid, backbone_gw);
-	if (compare_eth(backbone_addr, primary_if->net_dev->dev_addr))
+	if (batadv_compare_eth(backbone_addr, primary_if->net_dev->dev_addr))
 		bla_send_claim(bat_priv, claim_addr, vid, CLAIM_TYPE_ADD);
 
 	/* TODO: we could call something like tt_local_del() here. */
@@ -772,7 +773,7 @@ static int check_claim_group(struct bat_priv *bat_priv,
 	}
 
 	/* don't accept claim frames from ourselves */
-	if (compare_eth(backbone_addr, primary_if->net_dev->dev_addr))
+	if (batadv_compare_eth(backbone_addr, primary_if->net_dev->dev_addr))
 		return 0;
 
 	/* if its already the same group, it is fine. */
@@ -790,9 +791,9 @@ static int check_claim_group(struct bat_priv *bat_priv,
 
 	/* if our mesh friends mac is bigger, use it for ourselves. */
 	if (ntohs(bla_dst->group) > ntohs(bla_dst_own->group)) {
-		bat_dbg(DBG_BLA, bat_priv,
-			"taking other backbones claim group: %04x\n",
-			ntohs(bla_dst->group));
+		batadv_dbg(DBG_BLA, bat_priv,
+			   "taking other backbones claim group: %04x\n",
+			   ntohs(bla_dst->group));
 		bla_dst_own->group = bla_dst->group;
 	}
 
@@ -867,9 +868,9 @@ static int bla_process_claim(struct bat_priv *bat_priv,
 	/* check if it is a claim frame. */
 	ret = check_claim_group(bat_priv, primary_if, hw_src, hw_dst, ethhdr);
 	if (ret == 1)
-		bat_dbg(DBG_BLA, bat_priv,
-			"bla_process_claim(): received a claim frame from another group. From: %pM on vid %d ...(hw_src %pM, hw_dst %pM)\n",
-			ethhdr->h_source, vid, hw_src, hw_dst);
+		batadv_dbg(DBG_BLA, bat_priv,
+			   "bla_process_claim(): received a claim frame from another group. From: %pM on vid %d ...(hw_src %pM, hw_dst %pM)\n",
+			   ethhdr->h_source, vid, hw_src, hw_dst);
 
 	if (ret < 2)
 		return ret;
@@ -900,9 +901,9 @@ static int bla_process_claim(struct bat_priv *bat_priv,
 		break;
 	}
 
-	bat_dbg(DBG_BLA, bat_priv,
-		"bla_process_claim(): ERROR - this looks like a claim frame, but is useless. eth src %pM on vid %d ...(hw_src %pM, hw_dst %pM)\n",
-		ethhdr->h_source, vid, hw_src, hw_dst);
+	batadv_dbg(DBG_BLA, bat_priv,
+		   "bla_process_claim(): ERROR - this looks like a claim frame, but is useless. eth src %pM on vid %d ...(hw_src %pM, hw_dst %pM)\n",
+		   ethhdr->h_source, vid, hw_src, hw_dst);
 	return 1;
 }
 
@@ -931,13 +932,13 @@ static void bla_purge_backbone_gw(struct bat_priv *bat_priv, int now)
 					  head, hash_entry) {
 			if (now)
 				goto purge_now;
-			if (!has_timed_out(backbone_gw->lasttime,
-					   BLA_BACKBONE_TIMEOUT))
+			if (!batadv_has_timed_out(backbone_gw->lasttime,
+						  BLA_BACKBONE_TIMEOUT))
 				continue;
 
-			bat_dbg(DBG_BLA, backbone_gw->bat_priv,
-				"bla_purge_backbone_gw(): backbone gw %pM timed out\n",
-				backbone_gw->orig);
+			batadv_dbg(DBG_BLA, backbone_gw->bat_priv,
+				   "bla_purge_backbone_gw(): backbone gw %pM timed out\n",
+				   backbone_gw->orig);
 
 purge_now:
 			/* don't wait for the pending request anymore */
@@ -980,16 +981,16 @@ static void bla_purge_claims(struct bat_priv *bat_priv,
 		hlist_for_each_entry_rcu(claim, node, head, hash_entry) {
 			if (now)
 				goto purge_now;
-			if (!compare_eth(claim->backbone_gw->orig,
-					 primary_if->net_dev->dev_addr))
+			if (!batadv_compare_eth(claim->backbone_gw->orig,
+						primary_if->net_dev->dev_addr))
 				continue;
-			if (!has_timed_out(claim->lasttime,
-					   BLA_CLAIM_TIMEOUT))
+			if (!batadv_has_timed_out(claim->lasttime,
+						  BLA_CLAIM_TIMEOUT))
 				continue;
 
-			bat_dbg(DBG_BLA, bat_priv,
-				"bla_purge_claims(): %pM, vid %d, time out\n",
-				claim->addr, claim->vid);
+			batadv_dbg(DBG_BLA, bat_priv,
+				   "bla_purge_claims(): %pM, vid %d, time out\n",
+				   claim->addr, claim->vid);
 
 purge_now:
 			handle_unclaim(bat_priv, primary_if,
@@ -1036,8 +1037,8 @@ void batadv_bla_update_orig_address(struct bat_priv *bat_priv,
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(backbone_gw, node, head, hash_entry) {
 			/* own orig still holds the old value. */
-			if (!compare_eth(backbone_gw->orig,
-					 oldif->net_dev->dev_addr))
+			if (!batadv_compare_eth(backbone_gw->orig,
+						oldif->net_dev->dev_addr))
 				continue;
 
 			memcpy(backbone_gw->orig,
@@ -1097,8 +1098,8 @@ static void bla_periodic_work(struct work_struct *work)
 
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(backbone_gw, node, head, hash_entry) {
-			if (!compare_eth(backbone_gw->orig,
-					 primary_if->net_dev->dev_addr))
+			if (!batadv_compare_eth(backbone_gw->orig,
+						primary_if->net_dev->dev_addr))
 				continue;
 
 			backbone_gw->lasttime = jiffies;
@@ -1129,7 +1130,7 @@ int batadv_bla_init(struct bat_priv *bat_priv)
 	uint8_t claim_dest[ETH_ALEN] = {0xff, 0x43, 0x05, 0x00, 0x00, 0x00};
 	struct hard_iface *primary_if;
 
-	bat_dbg(DBG_BLA, bat_priv, "bla hash registering\n");
+	batadv_dbg(DBG_BLA, bat_priv, "bla hash registering\n");
 
 	/* setting claim destination address */
 	memcpy(&bat_priv->claim_dest.magic, claim_dest, 3);
@@ -1164,7 +1165,7 @@ int batadv_bla_init(struct bat_priv *bat_priv)
 	batadv_hash_set_lock_class(bat_priv->backbone_hash,
 				   &backbone_hash_lock_class_key);
 
-	bat_dbg(DBG_BLA, bat_priv, "bla hashes initialized\n");
+	batadv_dbg(DBG_BLA, bat_priv, "bla hashes initialized\n");
 
 	bla_start_timer(bat_priv);
 	return 0;
@@ -1206,13 +1207,13 @@ int batadv_bla_check_bcast_duplist(struct bat_priv *bat_priv,
 		/* we can stop searching if the entry is too old ;
 		 * later entries will be even older
 		 */
-		if (has_timed_out(entry->entrytime, DUPLIST_TIMEOUT))
+		if (batadv_has_timed_out(entry->entrytime, DUPLIST_TIMEOUT))
 			break;
 
 		if (entry->crc != crc)
 			continue;
 
-		if (compare_eth(entry->orig, bcast_packet->orig))
+		if (batadv_compare_eth(entry->orig, bcast_packet->orig))
 			continue;
 
 		/* this entry seems to match: same crc, not too old,
@@ -1260,7 +1261,7 @@ int batadv_bla_is_backbone_gw_orig(struct bat_priv *bat_priv, uint8_t *orig)
 
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(backbone_gw, node, head, hash_entry) {
-			if (compare_eth(backbone_gw->orig, orig)) {
+			if (batadv_compare_eth(backbone_gw->orig, orig)) {
 				rcu_read_unlock();
 				return 1;
 			}
@@ -1387,8 +1388,8 @@ int batadv_bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid)
 	}
 
 	/* if it is our own claim ... */
-	if (compare_eth(claim->backbone_gw->orig,
-			primary_if->net_dev->dev_addr)) {
+	if (batadv_compare_eth(claim->backbone_gw->orig,
+			       primary_if->net_dev->dev_addr)) {
 		/* ... allow it in any case */
 		claim->lasttime = jiffies;
 		goto allow;
@@ -1474,8 +1475,8 @@ int batadv_bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid)
 		goto allow;
 
 	/* check if we are responsible. */
-	if (compare_eth(claim->backbone_gw->orig,
-			primary_if->net_dev->dev_addr)) {
+	if (batadv_compare_eth(claim->backbone_gw->orig,
+			       primary_if->net_dev->dev_addr)) {
 		/* if yes, the client has roamed and we have
 		 * to unclaim it.
 		 */
@@ -1523,6 +1524,7 @@ int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset)
 	uint32_t i;
 	bool is_own;
 	int ret = 0;
+	uint8_t *primary_addr;
 
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if) {
@@ -1539,9 +1541,10 @@ int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset)
 		goto out;
 	}
 
+	primary_addr = primary_if->net_dev->dev_addr;
 	seq_printf(seq,
 		   "Claims announced for the mesh %s (orig %pM, group id %04x)\n",
-		   net_dev->name, primary_if->net_dev->dev_addr,
+		   net_dev->name, primary_addr,
 		   ntohs(bat_priv->claim_dest.group));
 	seq_printf(seq, "   %-17s    %-5s    %-17s [o] (%-4s)\n",
 		   "Client", "VID", "Originator", "CRC");
@@ -1550,8 +1553,8 @@ int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset)
 
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(claim, node, head, hash_entry) {
-			is_own = compare_eth(claim->backbone_gw->orig,
-					     primary_if->net_dev->dev_addr);
+			is_own = batadv_compare_eth(claim->backbone_gw->orig,
+						    primary_addr);
 			seq_printf(seq,	" * %pM on % 5d by %pM [%c] (%04x)\n",
 				   claim->addr, claim->vid,
 				   claim->backbone_gw->orig,
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index c917a2e..318c112 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -217,20 +217,20 @@ void batadv_gw_election(struct bat_priv *bat_priv)
 	}
 
 	if ((curr_gw) && (!next_gw)) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Removing selected gateway - no gateway in range\n");
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Removing selected gateway - no gateway in range\n");
 		batadv_throw_uevent(bat_priv, UEV_GW, UEV_DEL, NULL);
 	} else if ((!curr_gw) && (next_gw)) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Adding route to gateway %pM (gw_flags: %i, tq: %i)\n",
-			next_gw->orig_node->orig, next_gw->orig_node->gw_flags,
-			router->tq_avg);
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Adding route to gateway %pM (gw_flags: %i, tq: %i)\n",
+			   next_gw->orig_node->orig,
+			   next_gw->orig_node->gw_flags, router->tq_avg);
 		batadv_throw_uevent(bat_priv, UEV_GW, UEV_ADD, gw_addr);
 	} else {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Changing route to gateway %pM (gw_flags: %i, tq: %i)\n",
-			next_gw->orig_node->orig, next_gw->orig_node->gw_flags,
-			router->tq_avg);
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Changing route to gateway %pM (gw_flags: %i, tq: %i)\n",
+			   next_gw->orig_node->orig,
+			   next_gw->orig_node->gw_flags, router->tq_avg);
 		batadv_throw_uevent(bat_priv, UEV_GW, UEV_CHANGE, gw_addr);
 	}
 
@@ -282,9 +282,9 @@ void batadv_gw_check_election(struct bat_priv *bat_priv,
 	    (orig_tq_avg - gw_tq_avg < atomic_read(&bat_priv->gw_sel_class)))
 		goto out;
 
-	bat_dbg(DBG_BATMAN, bat_priv,
-		"Restarting gateway selection: better gateway found (tq curr: %i, tq new: %i)\n",
-		gw_tq_avg, orig_tq_avg);
+	batadv_dbg(DBG_BATMAN, bat_priv,
+		   "Restarting gateway selection: better gateway found (tq curr: %i, tq new: %i)\n",
+		   gw_tq_avg, orig_tq_avg);
 
 deselect:
 	batadv_gw_deselect(bat_priv);
@@ -318,13 +318,13 @@ static void gw_node_add(struct bat_priv *bat_priv,
 	spin_unlock_bh(&bat_priv->gw_list_lock);
 
 	batadv_gw_bandwidth_to_kbit(new_gwflags, &down, &up);
-	bat_dbg(DBG_BATMAN, bat_priv,
-		"Found new gateway %pM -> gw_class: %i - %i%s/%i%s\n",
-		orig_node->orig, new_gwflags,
-		(down > 2048 ? down / 1024 : down),
-		(down > 2048 ? "MBit" : "KBit"),
-		(up > 2048 ? up / 1024 : up),
-		(up > 2048 ? "MBit" : "KBit"));
+	batadv_dbg(DBG_BATMAN, bat_priv,
+		   "Found new gateway %pM -> gw_class: %i - %i%s/%i%s\n",
+		   orig_node->orig, new_gwflags,
+		   (down > 2048 ? down / 1024 : down),
+		   (down > 2048 ? "MBit" : "KBit"),
+		   (up > 2048 ? up / 1024 : up),
+		   (up > 2048 ? "MBit" : "KBit"));
 }
 
 void batadv_gw_node_update(struct bat_priv *bat_priv,
@@ -345,18 +345,18 @@ void batadv_gw_node_update(struct bat_priv *bat_priv,
 		if (gw_node->orig_node != orig_node)
 			continue;
 
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Gateway class of originator %pM changed from %i to %i\n",
-			orig_node->orig, gw_node->orig_node->gw_flags,
-			new_gwflags);
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Gateway class of originator %pM changed from %i to %i\n",
+			   orig_node->orig, gw_node->orig_node->gw_flags,
+			   new_gwflags);
 
 		gw_node->deleted = 0;
 
 		if (new_gwflags == NO_FLAGS) {
 			gw_node->deleted = jiffies;
-			bat_dbg(DBG_BATMAN, bat_priv,
-				"Gateway %pM removed from gateway list\n",
-				orig_node->orig);
+			batadv_dbg(DBG_BATMAN, bat_priv,
+				   "Gateway %pM removed from gateway list\n",
+				   orig_node->orig);
 
 			if (gw_node == curr_gw)
 				goto deselect;
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 06f8d63..6131d93 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -163,8 +163,8 @@ static void check_known_mac_addr(const struct net_device *net_dev)
 		if (hard_iface->net_dev == net_dev)
 			continue;
 
-		if (!compare_eth(hard_iface->net_dev->dev_addr,
-				 net_dev->dev_addr))
+		if (!batadv_compare_eth(hard_iface->net_dev->dev_addr,
+					net_dev->dev_addr))
 			continue;
 
 		pr_warn("The newly added mac address (%pM) already exists on: %s\n",
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 50a74da..a3e80b6 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -158,8 +158,8 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 	size_t packet_len = sizeof(struct icmp_packet);
 
 	if (len < sizeof(struct icmp_packet)) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Error - can't send packet from char device: invalid packet size\n");
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Error - can't send packet from char device: invalid packet size\n");
 		return -EINVAL;
 	}
 
@@ -188,15 +188,15 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 	}
 
 	if (icmp_packet->header.packet_type != BAT_ICMP) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Error - can't send packet from char device: got bogus packet type (expected: BAT_ICMP)\n");
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Error - can't send packet from char device: got bogus packet type (expected: BAT_ICMP)\n");
 		len = -EINVAL;
 		goto free_skb;
 	}
 
 	if (icmp_packet->msg_type != ECHO_REQUEST) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Error - can't send packet from char device: got bogus message type (expected: ECHO_REQUEST)\n");
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Error - can't send packet from char device: got bogus message type (expected: ECHO_REQUEST)\n");
 		len = -EINVAL;
 		goto free_skb;
 	}
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index d56d6b2..e456430 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -180,7 +180,7 @@ int batadv_is_my_mac(const uint8_t *addr)
 		if (hard_iface->if_status != IF_ACTIVE)
 			continue;
 
-		if (compare_eth(hard_iface->net_dev->dev_addr, addr)) {
+		if (batadv_compare_eth(hard_iface->net_dev->dev_addr, addr)) {
 			rcu_read_unlock();
 			return 1;
 		}
@@ -238,9 +238,9 @@ int batadv_batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	batman_ogm_packet = (struct batman_ogm_packet *)skb->data;
 
 	if (batman_ogm_packet->header.version != COMPAT_VERSION) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: incompatible batman version (%i)\n",
-			batman_ogm_packet->header.version);
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Drop packet: incompatible batman version (%i)\n",
+			   batman_ogm_packet->header.version);
 		goto err_free;
 	}
 
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 4b06b76..2824264 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -175,7 +175,7 @@ int batadv_algo_seq_print_text(struct seq_file *seq, void *offset);
 int batadv_debug_log(struct bat_priv *bat_priv, const char *fmt, ...)
 __printf(2, 3);
 
-#define bat_dbg(type, bat_priv, fmt, arg...)			\
+#define batadv_dbg(type, bat_priv, fmt, arg...)			\
 	do {							\
 		if (atomic_read(&bat_priv->log_level) & type)	\
 			batadv_debug_log(bat_priv, fmt, ## arg);\
@@ -183,9 +183,9 @@ __printf(2, 3);
 	while (0)
 #else /* !CONFIG_BATMAN_ADV_DEBUG */
 __printf(3, 4)
-static inline void bat_dbg(int type __always_unused,
-			   struct bat_priv *bat_priv __always_unused,
-			   const char *fmt __always_unused, ...)
+static inline void batadv_dbg(int type __always_unused,
+			      struct bat_priv *bat_priv __always_unused,
+			      const char *fmt __always_unused, ...)
 {
 }
 #endif
@@ -194,14 +194,14 @@ static inline void bat_dbg(int type __always_unused,
 	do {								\
 		struct net_device *_netdev = (net_dev);                 \
 		struct bat_priv *_batpriv = netdev_priv(_netdev);       \
-		bat_dbg(DBG_ALL, _batpriv, fmt, ## arg);		\
+		batadv_dbg(DBG_ALL, _batpriv, fmt, ## arg);		\
 		pr_info("%s: " fmt, _netdev->name, ## arg);		\
 	} while (0)
 #define bat_err(net_dev, fmt, arg...)					\
 	do {								\
 		struct net_device *_netdev = (net_dev);                 \
 		struct bat_priv *_batpriv = netdev_priv(_netdev);       \
-		bat_dbg(DBG_ALL, _batpriv, fmt, ## arg);		\
+		batadv_dbg(DBG_ALL, _batpriv, fmt, ## arg);		\
 		pr_err("%s: " fmt, _netdev->name, ## arg);		\
 	} while (0)
 
@@ -209,7 +209,7 @@ static inline void bat_dbg(int type __always_unused,
  *
  * note: can't use compare_ether_addr() as it requires aligned memory
  */
-static inline int compare_eth(const void *data1, const void *data2)
+static inline int batadv_compare_eth(const void *data1, const void *data2)
 {
 	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
 }
@@ -220,7 +220,8 @@ static inline int compare_eth(const void *data1, const void *data2)
  *
  * Returns true if current time is after timestamp + timeout
  */
-static inline bool has_timed_out(unsigned long timestamp, unsigned int timeout)
+static inline bool batadv_has_timed_out(unsigned long timestamp,
+					unsigned int timeout)
 {
 	return time_is_before_jiffies(timestamp + msecs_to_jiffies(timeout));
 }
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 36f5ee5..1cd640e 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -102,9 +102,9 @@ struct neigh_node *batadv_neigh_node_new(struct hard_iface *hard_iface,
 	/* extra reference for return */
 	atomic_set(&neigh_node->refcount, 2);
 
-	bat_dbg(DBG_BATMAN, bat_priv,
-		"Creating new neighbor %pM, initial seqno %d\n",
-		neigh_addr, seqno);
+	batadv_dbg(DBG_BATMAN, bat_priv,
+		   "Creating new neighbor %pM, initial seqno %d\n",
+		   neigh_addr, seqno);
 
 out:
 	return neigh_node;
@@ -199,8 +199,8 @@ struct orig_node *batadv_get_orig_node(struct bat_priv *bat_priv,
 	if (orig_node)
 		return orig_node;
 
-	bat_dbg(DBG_BATMAN, bat_priv,
-		"Creating new originator: %pM\n", addr);
+	batadv_dbg(DBG_BATMAN, bat_priv, "Creating new originator: %pM\n",
+		   addr);
 
 	orig_node = kzalloc(sizeof(*orig_node), GFP_ATOMIC);
 	if (!orig_node)
@@ -272,6 +272,7 @@ static bool purge_orig_neighbors(struct bat_priv *bat_priv,
 	struct neigh_node *neigh_node;
 	bool neigh_purged = false;
 	unsigned long last_seen;
+	struct hard_iface *if_incoming;
 
 	*best_neigh_node = NULL;
 
@@ -281,28 +282,26 @@ static bool purge_orig_neighbors(struct bat_priv *bat_priv,
 	hlist_for_each_entry_safe(neigh_node, node, node_tmp,
 				  &orig_node->neigh_list, list) {
 
-		if ((has_timed_out(neigh_node->last_seen, PURGE_TIMEOUT)) ||
-		    (neigh_node->if_incoming->if_status == IF_INACTIVE) ||
-		    (neigh_node->if_incoming->if_status == IF_NOT_IN_USE) ||
-		    (neigh_node->if_incoming->if_status == IF_TO_BE_REMOVED)) {
+		last_seen = neigh_node->last_seen;
+		if_incoming = neigh_node->if_incoming;
 
-			last_seen = neigh_node->last_seen;
+		if ((batadv_has_timed_out(last_seen, PURGE_TIMEOUT)) ||
+		    (if_incoming->if_status == IF_INACTIVE) ||
+		    (if_incoming->if_status == IF_NOT_IN_USE) ||
+		    (if_incoming->if_status == IF_TO_BE_REMOVED)) {
 
-			if ((neigh_node->if_incoming->if_status ==
-								IF_INACTIVE) ||
-			    (neigh_node->if_incoming->if_status ==
-							IF_NOT_IN_USE) ||
-			    (neigh_node->if_incoming->if_status ==
-							IF_TO_BE_REMOVED))
-				bat_dbg(DBG_BATMAN, bat_priv,
-					"neighbor purge: originator %pM, neighbor: %pM, iface: %s\n",
-					orig_node->orig, neigh_node->addr,
-					neigh_node->if_incoming->net_dev->name);
+			if ((if_incoming->if_status == IF_INACTIVE) ||
+			    (if_incoming->if_status == IF_NOT_IN_USE) ||
+			    (if_incoming->if_status == IF_TO_BE_REMOVED))
+				batadv_dbg(DBG_BATMAN, bat_priv,
+					   "neighbor purge: originator %pM, neighbor: %pM, iface: %s\n",
+					   orig_node->orig, neigh_node->addr,
+					   if_incoming->net_dev->name);
 			else
-				bat_dbg(DBG_BATMAN, bat_priv,
-					"neighbor timeout: originator %pM, neighbor: %pM, last_seen: %u\n",
-					orig_node->orig, neigh_node->addr,
-					jiffies_to_msecs(last_seen));
+				batadv_dbg(DBG_BATMAN, bat_priv,
+					   "neighbor timeout: originator %pM, neighbor: %pM, last_seen: %u\n",
+					   orig_node->orig, neigh_node->addr,
+					   jiffies_to_msecs(last_seen));
 
 			neigh_purged = true;
 
@@ -325,11 +324,11 @@ static bool purge_orig_node(struct bat_priv *bat_priv,
 {
 	struct neigh_node *best_neigh_node;
 
-	if (has_timed_out(orig_node->last_seen, 2 * PURGE_TIMEOUT)) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Originator timeout: originator %pM, last_seen %u\n",
-			orig_node->orig,
-			jiffies_to_msecs(orig_node->last_seen));
+	if (batadv_has_timed_out(orig_node->last_seen, 2 * PURGE_TIMEOUT)) {
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "Originator timeout: originator %pM, last_seen %u\n",
+			   orig_node->orig,
+			   jiffies_to_msecs(orig_node->last_seen));
 		return true;
 	} else {
 		if (purge_orig_neighbors(bat_priv, orig_node,
@@ -370,8 +369,8 @@ static void _purge_orig(struct bat_priv *bat_priv)
 				continue;
 			}
 
-			if (has_timed_out(orig_node->last_frag_packet,
-					  FRAG_TIMEOUT))
+			if (batadv_has_timed_out(orig_node->last_frag_packet,
+						 FRAG_TIMEOUT))
 				batadv_frag_list_free(&orig_node->frag_list);
 		}
 		spin_unlock_bh(list_lock);
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index c4f63b4..35f67eb 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -77,7 +77,7 @@ static inline struct orig_node *batadv_orig_hash_find(struct bat_priv *bat_priv,
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(orig_node, node, head, hash_entry) {
-		if (!compare_eth(orig_node, data))
+		if (!batadv_compare_eth(orig_node, data))
 			continue;
 
 		if (!atomic_inc_not_zero(&orig_node->refcount))
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 3eb4a2e..57ff851 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -71,23 +71,23 @@ static void _update_route(struct bat_priv *bat_priv,
 
 	/* route deleted */
 	if ((curr_router) && (!neigh_node)) {
-		bat_dbg(DBG_ROUTES, bat_priv, "Deleting route towards: %pM\n",
-			orig_node->orig);
+		batadv_dbg(DBG_ROUTES, bat_priv, "Deleting route towards: %pM\n",
+			   orig_node->orig);
 		batadv_tt_global_del_orig(bat_priv, orig_node,
 					  "Deleted route towards originator");
 
 	/* route added */
 	} else if ((!curr_router) && (neigh_node)) {
 
-		bat_dbg(DBG_ROUTES, bat_priv,
-			"Adding route towards: %pM (via %pM)\n",
-			orig_node->orig, neigh_node->addr);
+		batadv_dbg(DBG_ROUTES, bat_priv,
+			   "Adding route towards: %pM (via %pM)\n",
+			   orig_node->orig, neigh_node->addr);
 	/* route changed */
 	} else if (neigh_node && curr_router) {
-		bat_dbg(DBG_ROUTES, bat_priv,
-			"Changing route towards: %pM (now via %pM - was via %pM)\n",
-			orig_node->orig, neigh_node->addr,
-			curr_router->addr);
+		batadv_dbg(DBG_ROUTES, bat_priv,
+			   "Changing route towards: %pM (now via %pM - was via %pM)\n",
+			   orig_node->orig, neigh_node->addr,
+			   curr_router->addr);
 	}
 
 	if (curr_router)
@@ -151,8 +151,8 @@ void batadv_bonding_candidate_add(struct orig_node *orig_node,
 	spin_lock_bh(&orig_node->neigh_list_lock);
 
 	/* only consider if it has the same primary address ...  */
-	if (!compare_eth(orig_node->orig,
-			 neigh_node->orig_node->primary_addr))
+	if (!batadv_compare_eth(orig_node->orig,
+				neigh_node->orig_node->primary_addr))
 		goto candidate_del;
 
 	router = batadv_orig_node_get_router(orig_node);
@@ -180,7 +180,8 @@ void batadv_bonding_candidate_add(struct orig_node *orig_node,
 			continue;
 
 		if ((neigh_node->if_incoming == tmp_neigh_node->if_incoming) ||
-		    (compare_eth(neigh_node->addr, tmp_neigh_node->addr))) {
+		    (batadv_compare_eth(neigh_node->addr,
+					tmp_neigh_node->addr))) {
 			interference_candidate = 1;
 			break;
 		}
@@ -233,12 +234,12 @@ int batadv_window_protected(struct bat_priv *bat_priv, int32_t seq_num_diff,
 {
 	if ((seq_num_diff <= -TQ_LOCAL_WINDOW_SIZE) ||
 	    (seq_num_diff >= EXPECTED_SEQNO_RANGE)) {
-		if (!has_timed_out(*last_reset, RESET_PROTECTION_MS))
+		if (!batadv_has_timed_out(*last_reset, RESET_PROTECTION_MS))
 			return 1;
 
 		*last_reset = jiffies;
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"old packet received, start protection\n");
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "old packet received, start protection\n");
 	}
 
 	return 0;
@@ -578,6 +579,7 @@ int batadv_recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 	struct tt_query_packet *tt_query;
 	uint16_t tt_size;
 	struct ethhdr *ethhdr;
+	char tt_flag;
 
 	/* drop packet if it has not necessary minimum size */
 	if (unlikely(!pskb_may_pull(skb, sizeof(struct tt_query_packet))))
@@ -607,10 +609,11 @@ int batadv_recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 		 * forwarded
 		 */
 		if (!batadv_send_tt_response(bat_priv, tt_query)) {
-			bat_dbg(DBG_TT, bat_priv,
-				"Routing TT_REQUEST to %pM [%c]\n",
-				tt_query->dst,
-				(tt_query->flags & TT_FULL_TABLE ? 'F' : '.'));
+			tt_flag = tt_query->flags & TT_FULL_TABLE ? 'F' : '.';
+			batadv_dbg(DBG_TT, bat_priv,
+				   "Routing TT_REQUEST to %pM [%c]\n",
+				   tt_query->dst,
+				   tt_flag);
 			return route_unicast_packet(skb, recv_if);
 		}
 		break;
@@ -635,10 +638,11 @@ int batadv_recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 
 			batadv_handle_tt_response(bat_priv, tt_query);
 		} else {
-			bat_dbg(DBG_TT, bat_priv,
-				"Routing TT_RESPONSE to %pM [%c]\n",
-				tt_query->dst,
-				(tt_query->flags & TT_FULL_TABLE ? 'F' : '.'));
+			tt_flag = tt_query->flags & TT_FULL_TABLE ? 'F' : '.';
+			batadv_dbg(DBG_TT, bat_priv,
+				   "Routing TT_RESPONSE to %pM [%c]\n",
+				   tt_query->dst,
+				   tt_flag);
 			return route_unicast_packet(skb, recv_if);
 		}
 		break;
@@ -688,9 +692,9 @@ int batadv_recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_if)
 	if (!orig_node)
 		goto out;
 
-	bat_dbg(DBG_TT, bat_priv,
-		"Received ROAMING_ADV from %pM (client %pM)\n",
-		roam_adv_packet->src, roam_adv_packet->client);
+	batadv_dbg(DBG_TT, bat_priv,
+		   "Received ROAMING_ADV from %pM (client %pM)\n",
+		   roam_adv_packet->src, roam_adv_packet->client);
 
 	batadv_tt_global_add(bat_priv, orig_node, roam_adv_packet->client,
 			     atomic_read(&orig_node->last_ttvn) + 1, true,
@@ -749,13 +753,13 @@ struct neigh_node *batadv_find_router(struct bat_priv *bat_priv,
 	/* if we have something in the primary_addr, we can search
 	 * for a potential bonding candidate.
 	 */
-	if (compare_eth(primary_addr, zero_mac))
+	if (batadv_compare_eth(primary_addr, zero_mac))
 		goto return_router;
 
 	/* find the orig_node which has the primary interface. might
 	 * even be the same as our router_orig in many cases
 	 */
-	if (compare_eth(primary_addr, router_orig->orig)) {
+	if (batadv_compare_eth(primary_addr, router_orig->orig)) {
 		primary_orig_node = router_orig;
 	} else {
 		primary_orig_node = batadv_orig_hash_find(bat_priv,
@@ -974,10 +978,10 @@ static int check_unicast_ttvn(struct bat_priv *bat_priv,
 			batadv_orig_node_free_ref(orig_node);
 		}
 
-		bat_dbg(DBG_ROUTES, bat_priv,
-			"TTVN mismatch (old_ttvn %u new_ttvn %u)! Rerouting unicast packet (for %pM) to %pM\n",
-			unicast_packet->ttvn, curr_ttvn, ethhdr->h_dest,
-			unicast_packet->dest);
+		batadv_dbg(DBG_ROUTES, bat_priv,
+			   "TTVN mismatch (old_ttvn %u new_ttvn %u)! Rerouting unicast packet (for %pM) to %pM\n",
+			   unicast_packet->ttvn, curr_ttvn, ethhdr->h_dest,
+			   unicast_packet->dest);
 
 		unicast_packet->ttvn = curr_ttvn;
 	}
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 54091db..47c3a41 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -142,7 +142,7 @@ int batadv_add_bcast_packet_to_list(struct bat_priv *bat_priv,
 	struct sk_buff *newskb;
 
 	if (!atomic_dec_not_zero(&bat_priv->bcast_queue_left)) {
-		bat_dbg(DBG_BATMAN, bat_priv, "bcast packet queue full\n");
+		batadv_dbg(DBG_BATMAN, bat_priv, "bcast packet queue full\n");
 		goto out;
 	}
 
@@ -271,12 +271,12 @@ void batadv_purge_outstanding_packets(struct bat_priv *bat_priv,
 	bool pending;
 
 	if (hard_iface)
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"purge_outstanding_packets(): %s\n",
-			hard_iface->net_dev->name);
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "purge_outstanding_packets(): %s\n",
+			   hard_iface->net_dev->name);
 	else
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"purge_outstanding_packets()\n");
+		batadv_dbg(DBG_BATMAN, bat_priv,
+			   "purge_outstanding_packets()\n");
 
 	/* free bcast list */
 	spin_lock_bh(&bat_priv->forw_bcast_list_lock);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 85fe9c1..af676b8 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -168,7 +168,7 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 	/* don't accept stp packets. STP does not help in meshes.
 	 * better use the bridge loop avoidance ...
 	 */
-	if (compare_eth(ethhdr->h_dest, stp_addr))
+	if (batadv_compare_eth(ethhdr->h_dest, stp_addr))
 		goto dropped;
 
 	if (is_multicast_ether_addr(ethhdr->h_dest)) {
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 1dfa231..2eff22f 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -66,7 +66,7 @@ static struct tt_common_entry *tt_hash_find(struct hashtable_t *hash,
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(tt_common_entry, node, head, hash_entry) {
-		if (!compare_eth(tt_common_entry, data))
+		if (!batadv_compare_eth(tt_common_entry, data))
 			continue;
 
 		if (!atomic_inc_not_zero(&tt_common_entry->refcount))
@@ -213,9 +213,9 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	if (!tt_local_entry)
 		goto out;
 
-	bat_dbg(DBG_TT, bat_priv,
-		"Creating new local tt entry: %pM (ttvn: %d)\n", addr,
-		(uint8_t)atomic_read(&bat_priv->ttvn));
+	batadv_dbg(DBG_TT, bat_priv,
+		   "Creating new local tt entry: %pM (ttvn: %d)\n", addr,
+		   (uint8_t)atomic_read(&bat_priv->ttvn));
 
 	memcpy(tt_local_entry->common.addr, addr, ETH_ALEN);
 	tt_local_entry->common.flags = NO_FLAGS;
@@ -225,7 +225,7 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	tt_local_entry->last_seen = jiffies;
 
 	/* the batman interface mac address should never be purged */
-	if (compare_eth(addr, soft_iface->dev_addr))
+	if (batadv_compare_eth(addr, soft_iface->dev_addr))
 		tt_local_entry->common.flags |= TT_CLIENT_NOPURGE;
 
 	/* The local entry has to be marked as NEW to avoid to send it in
@@ -441,9 +441,9 @@ static void tt_local_set_pending(struct bat_priv *bat_priv,
 	 */
 	tt_local_entry->common.flags |= TT_CLIENT_PENDING;
 
-	bat_dbg(DBG_TT, bat_priv,
-		"Local tt entry (%pM) pending to be removed: %s\n",
-		tt_local_entry->common.addr, message);
+	batadv_dbg(DBG_TT, bat_priv,
+		   "Local tt entry (%pM) pending to be removed: %s\n",
+		   tt_local_entry->common.addr, message);
 }
 
 void batadv_tt_local_remove(struct bat_priv *bat_priv, const uint8_t *addr,
@@ -489,8 +489,8 @@ static void tt_local_purge(struct bat_priv *bat_priv)
 			if (tt_local_entry->common.flags & TT_CLIENT_PENDING)
 				continue;
 
-			if (!has_timed_out(tt_local_entry->last_seen,
-					   TT_LOCAL_TIMEOUT))
+			if (!batadv_has_timed_out(tt_local_entry->last_seen,
+						  TT_LOCAL_TIMEOUT))
 				continue;
 
 			tt_local_set_pending(bat_priv, tt_local_entry,
@@ -674,9 +674,9 @@ int batadv_tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 	if (wifi)
 		tt_global_entry->common.flags |= TT_CLIENT_WIFI;
 
-	bat_dbg(DBG_TT, bat_priv,
-		"Creating new global tt entry: %pM (via %pM)\n",
-		tt_global_entry->common.addr, orig_node->orig);
+	batadv_dbg(DBG_TT, bat_priv,
+		   "Creating new global tt entry: %pM (via %pM)\n",
+		   tt_global_entry->common.addr, orig_node->orig);
 
 out_remove:
 	/* remove address from local hash if present */
@@ -800,10 +800,10 @@ static void tt_global_del_orig_entry(struct bat_priv *bat_priv,
 	head = &tt_global_entry->orig_list;
 	hlist_for_each_entry_safe(orig_entry, node, safe, head, list) {
 		if (orig_entry->orig_node == orig_node) {
-			bat_dbg(DBG_TT, bat_priv,
-				"Deleting %pM from global tt entry %pM: %s\n",
-				orig_node->orig, tt_global_entry->common.addr,
-				message);
+			batadv_dbg(DBG_TT, bat_priv,
+				   "Deleting %pM from global tt entry %pM: %s\n",
+				   orig_node->orig,
+				   tt_global_entry->common.addr, message);
 			hlist_del_rcu(node);
 			tt_orig_list_entry_free_ref(orig_entry);
 		}
@@ -815,9 +815,8 @@ static void tt_global_del_struct(struct bat_priv *bat_priv,
 				 struct tt_global_entry *tt_global_entry,
 				 const char *message)
 {
-	bat_dbg(DBG_TT, bat_priv,
-		"Deleting global tt entry %pM: %s\n",
-		tt_global_entry->common.addr, message);
+	batadv_dbg(DBG_TT, bat_priv, "Deleting global tt entry %pM: %s\n",
+		   tt_global_entry->common.addr, message);
 
 	batadv_hash_remove(bat_priv->tt_global_hash, compare_tt,
 			   batadv_choose_orig, tt_global_entry->common.addr);
@@ -951,10 +950,10 @@ void batadv_tt_global_del_orig(struct bat_priv *bat_priv,
 						 orig_node, message);
 
 			if (hlist_empty(&tt_global_entry->orig_list)) {
-				bat_dbg(DBG_TT, bat_priv,
-					"Deleting global tt entry %pM: %s\n",
-					tt_global_entry->common.addr,
-					message);
+				batadv_dbg(DBG_TT, bat_priv,
+					   "Deleting global tt entry %pM: %s\n",
+					   tt_global_entry->common.addr,
+					   message);
 				hlist_del_rcu(node);
 				tt_global_entry_free_ref(tt_global_entry);
 			}
@@ -987,13 +986,13 @@ static void tt_global_roam_purge(struct bat_priv *bat_priv)
 						       common);
 			if (!(tt_global_entry->common.flags & TT_CLIENT_ROAM))
 				continue;
-			if (!has_timed_out(tt_global_entry->roam_at,
-					   TT_CLIENT_ROAM_TIMEOUT))
+			if (!batadv_has_timed_out(tt_global_entry->roam_at,
+						  TT_CLIENT_ROAM_TIMEOUT))
 				continue;
 
-			bat_dbg(DBG_TT, bat_priv,
-				"Deleting global tt entry (%pM): Roaming timeout\n",
-				tt_global_entry->common.addr);
+			batadv_dbg(DBG_TT, bat_priv,
+				   "Deleting global tt entry (%pM): Roaming timeout\n",
+				   tt_global_entry->common.addr);
 
 			hlist_del_rcu(node);
 			tt_global_entry_free_ref(tt_global_entry);
@@ -1234,7 +1233,7 @@ static void tt_req_purge(struct bat_priv *bat_priv)
 
 	spin_lock_bh(&bat_priv->tt_req_list_lock);
 	list_for_each_entry_safe(node, safe, &bat_priv->tt_req_list, list) {
-		if (has_timed_out(node->issued_at, TT_REQUEST_TIMEOUT)) {
+		if (batadv_has_timed_out(node->issued_at, TT_REQUEST_TIMEOUT)) {
 			list_del(&node->list);
 			kfree(node);
 		}
@@ -1252,9 +1251,9 @@ static struct tt_req_node *new_tt_req_node(struct bat_priv *bat_priv,
 
 	spin_lock_bh(&bat_priv->tt_req_list_lock);
 	list_for_each_entry(tt_req_node_tmp, &bat_priv->tt_req_list, list) {
-		if (compare_eth(tt_req_node_tmp, orig_node) &&
-		    !has_timed_out(tt_req_node_tmp->issued_at,
-				   TT_REQUEST_TIMEOUT))
+		if (batadv_compare_eth(tt_req_node_tmp, orig_node) &&
+		    !batadv_has_timed_out(tt_req_node_tmp->issued_at,
+					  TT_REQUEST_TIMEOUT))
 			goto unlock;
 	}
 
@@ -1409,10 +1408,10 @@ static int send_tt_request(struct bat_priv *bat_priv,
 	if (!neigh_node)
 		goto out;
 
-	bat_dbg(DBG_TT, bat_priv,
-		"Sending TT_REQUEST to %pM via %pM [%c]\n",
-		dst_orig_node->orig, neigh_node->addr,
-		(full_table ? 'F' : '.'));
+	batadv_dbg(DBG_TT, bat_priv,
+		   "Sending TT_REQUEST to %pM via %pM [%c]\n",
+		   dst_orig_node->orig, neigh_node->addr,
+		   (full_table ? 'F' : '.'));
 
 	batadv_inc_counter(bat_priv, BAT_CNT_TT_REQUEST_TX);
 
@@ -1449,10 +1448,10 @@ static bool send_other_tt_response(struct bat_priv *bat_priv,
 	struct sk_buff *skb = NULL;
 	struct tt_query_packet *tt_response;
 
-	bat_dbg(DBG_TT, bat_priv,
-		"Received TT_REQUEST from %pM for ttvn: %u (%pM) [%c]\n",
-		tt_request->src, tt_request->ttvn, tt_request->dst,
-		(tt_request->flags & TT_FULL_TABLE ? 'F' : '.'));
+	batadv_dbg(DBG_TT, bat_priv,
+		   "Received TT_REQUEST from %pM for ttvn: %u (%pM) [%c]\n",
+		   tt_request->src, tt_request->ttvn, tt_request->dst,
+		   (tt_request->flags & TT_FULL_TABLE ? 'F' : '.'));
 
 	/* Let's get the orig node of the REAL destination */
 	req_dst_orig_node = batadv_orig_hash_find(bat_priv, tt_request->dst);
@@ -1536,10 +1535,10 @@ static bool send_other_tt_response(struct bat_priv *bat_priv,
 	if (full_table)
 		tt_response->flags |= TT_FULL_TABLE;
 
-	bat_dbg(DBG_TT, bat_priv,
-		"Sending TT_RESPONSE %pM via %pM for %pM (ttvn: %u)\n",
-		res_dst_orig_node->orig, neigh_node->addr,
-		req_dst_orig_node->orig, req_ttvn);
+	batadv_dbg(DBG_TT, bat_priv,
+		   "Sending TT_RESPONSE %pM via %pM for %pM (ttvn: %u)\n",
+		   res_dst_orig_node->orig, neigh_node->addr,
+		   req_dst_orig_node->orig, req_ttvn);
 
 	batadv_inc_counter(bat_priv, BAT_CNT_TT_RESPONSE_TX);
 
@@ -1578,10 +1577,10 @@ static bool send_my_tt_response(struct bat_priv *bat_priv,
 	struct sk_buff *skb = NULL;
 	struct tt_query_packet *tt_response;
 
-	bat_dbg(DBG_TT, bat_priv,
-		"Received TT_REQUEST from %pM for ttvn: %u (me) [%c]\n",
-		tt_request->src, tt_request->ttvn,
-		(tt_request->flags & TT_FULL_TABLE ? 'F' : '.'));
+	batadv_dbg(DBG_TT, bat_priv,
+		   "Received TT_REQUEST from %pM for ttvn: %u (me) [%c]\n",
+		   tt_request->src, tt_request->ttvn,
+		   (tt_request->flags & TT_FULL_TABLE ? 'F' : '.'));
 
 
 	my_ttvn = (uint8_t)atomic_read(&bat_priv->ttvn);
@@ -1656,10 +1655,10 @@ static bool send_my_tt_response(struct bat_priv *bat_priv,
 	if (full_table)
 		tt_response->flags |= TT_FULL_TABLE;
 
-	bat_dbg(DBG_TT, bat_priv,
-		"Sending TT_RESPONSE to %pM via %pM [%c]\n",
-		orig_node->orig, neigh_node->addr,
-		(tt_response->flags & TT_FULL_TABLE ? 'F' : '.'));
+	batadv_dbg(DBG_TT, bat_priv,
+		   "Sending TT_RESPONSE to %pM via %pM [%c]\n",
+		   orig_node->orig, neigh_node->addr,
+		   (tt_response->flags & TT_FULL_TABLE ? 'F' : '.'));
 
 	batadv_inc_counter(bat_priv, BAT_CNT_TT_RESPONSE_TX);
 
@@ -1795,11 +1794,11 @@ void batadv_handle_tt_response(struct bat_priv *bat_priv,
 	struct tt_req_node *node, *safe;
 	struct orig_node *orig_node = NULL;
 
-	bat_dbg(DBG_TT, bat_priv,
-		"Received TT_RESPONSE from %pM for ttvn %d t_size: %d [%c]\n",
-		tt_response->src, tt_response->ttvn,
-		ntohs(tt_response->tt_data),
-		(tt_response->flags & TT_FULL_TABLE ? 'F' : '.'));
+	batadv_dbg(DBG_TT, bat_priv,
+		   "Received TT_RESPONSE from %pM for ttvn %d t_size: %d [%c]\n",
+		   tt_response->src, tt_response->ttvn,
+		   ntohs(tt_response->tt_data),
+		   (tt_response->flags & TT_FULL_TABLE ? 'F' : '.'));
 
 	/* we should have never asked a backbone gw */
 	if (batadv_bla_is_backbone_gw_orig(bat_priv, tt_response->src))
@@ -1820,7 +1819,7 @@ void batadv_handle_tt_response(struct bat_priv *bat_priv,
 	/* Delete the tt_req_node from pending tt_requests list */
 	spin_lock_bh(&bat_priv->tt_req_list_lock);
 	list_for_each_entry_safe(node, safe, &bat_priv->tt_req_list, list) {
-		if (!compare_eth(node->addr, tt_response->src))
+		if (!batadv_compare_eth(node->addr, tt_response->src))
 			continue;
 		list_del(&node->list);
 		kfree(node);
@@ -1875,7 +1874,7 @@ static void tt_roam_purge(struct bat_priv *bat_priv)
 
 	spin_lock_bh(&bat_priv->tt_roam_list_lock);
 	list_for_each_entry_safe(node, safe, &bat_priv->tt_roam_list, list) {
-		if (!has_timed_out(node->first_time, ROAMING_MAX_TIME))
+		if (!batadv_has_timed_out(node->first_time, ROAMING_MAX_TIME))
 			continue;
 
 		list_del(&node->list);
@@ -1901,10 +1900,11 @@ static bool tt_check_roam_count(struct bat_priv *bat_priv,
 	 * reply from the same orig_node yet
 	 */
 	list_for_each_entry(tt_roam_node, &bat_priv->tt_roam_list, list) {
-		if (!compare_eth(tt_roam_node->addr, client))
+		if (!batadv_compare_eth(tt_roam_node->addr, client))
 			continue;
 
-		if (has_timed_out(tt_roam_node->first_time, ROAMING_MAX_TIME))
+		if (batadv_has_timed_out(tt_roam_node->first_time,
+					 ROAMING_MAX_TIME))
 			continue;
 
 		if (!atomic_dec_not_zero(&tt_roam_node->counter))
@@ -1971,9 +1971,9 @@ static void send_roam_adv(struct bat_priv *bat_priv, uint8_t *client,
 	if (!neigh_node)
 		goto out;
 
-	bat_dbg(DBG_TT, bat_priv,
-		"Sending ROAMING_ADV to %pM (client %pM) via %pM\n",
-		orig_node->orig, client, neigh_node->addr);
+	batadv_dbg(DBG_TT, bat_priv,
+		   "Sending ROAMING_ADV to %pM (client %pM) via %pM\n",
+		   orig_node->orig, client, neigh_node->addr);
 
 	batadv_inc_counter(bat_priv, BAT_CNT_TT_ROAM_ADV_TX);
 
@@ -2078,9 +2078,9 @@ static void tt_local_purge_pending_clients(struct bat_priv *bat_priv)
 			if (!(tt_common_entry->flags & TT_CLIENT_PENDING))
 				continue;
 
-			bat_dbg(DBG_TT, bat_priv,
-				"Deleting local tt entry (%pM): pending\n",
-				tt_common_entry->addr);
+			batadv_dbg(DBG_TT, bat_priv,
+				   "Deleting local tt entry (%pM): pending\n",
+				   tt_common_entry->addr);
 
 			atomic_dec(&bat_priv->num_local_tt);
 			hlist_del_rcu(node);
@@ -2113,8 +2113,9 @@ static int tt_commit_changes(struct bat_priv *bat_priv,
 
 	/* Increment the TTVN only once per OGM interval */
 	atomic_inc(&bat_priv->ttvn);
-	bat_dbg(DBG_TT, bat_priv, "Local changes committed, updating to ttvn %u\n",
-		(uint8_t)atomic_read(&bat_priv->ttvn));
+	batadv_dbg(DBG_TT, bat_priv,
+		   "Local changes committed, updating to ttvn %u\n",
+		   (uint8_t)atomic_read(&bat_priv->ttvn));
 	bat_priv->tt_poss_change = false;
 
 	/* reset the sending counter */
@@ -2235,10 +2236,10 @@ void batadv_tt_update_orig(struct bat_priv *bat_priv,
 		if (!orig_node->tt_initialised || ttvn != orig_ttvn ||
 		    orig_node->tt_crc != tt_crc) {
 request_table:
-			bat_dbg(DBG_TT, bat_priv,
-				"TT inconsistency for %pM. Need to retrieve the correct information (ttvn: %u last_ttvn: %u crc: %u last_crc: %u num_changes: %u)\n",
-				orig_node->orig, ttvn, orig_ttvn, tt_crc,
-				orig_node->tt_crc, tt_num_changes);
+			batadv_dbg(DBG_TT, bat_priv,
+				   "TT inconsistency for %pM. Need to retrieve the correct information (ttvn: %u last_ttvn: %u crc: %u last_crc: %u num_changes: %u)\n",
+				   orig_node->orig, ttvn, orig_ttvn, tt_crc,
+				   orig_node->tt_crc, tt_num_changes);
 			send_tt_request(bat_priv, orig_node, ttvn, tt_crc,
 					full_table);
 			return;
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index bf72c52..d45989e 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -59,7 +59,7 @@ static int vis_info_cmp(const struct hlist_node *node, const void *data2)
 	d2 = data2;
 	p1 = (struct vis_packet *)d1->skb_packet->data;
 	p2 = (struct vis_packet *)d2->skb_packet->data;
-	return compare_eth(p1->vis_orig, p2->vis_orig);
+	return batadv_compare_eth(p1->vis_orig, p2->vis_orig);
 }
 
 /* hash function to choose an entry in a hash table of given size
@@ -127,7 +127,7 @@ static void vis_data_insert_interface(const uint8_t *interface,
 	struct hlist_node *pos;
 
 	hlist_for_each_entry(entry, pos, if_list, list) {
-		if (compare_eth(entry->addr, interface))
+		if (batadv_compare_eth(entry->addr, interface))
 			return;
 	}
 
@@ -181,7 +181,7 @@ static ssize_t vis_data_read_entry(char *buff,
 	/* maximal length: max(4+17+2, 3+17+1+3+2) == 26 */
 	if (primary && entry->quality == 0)
 		return sprintf(buff, "TT %pM, ", entry->dest);
-	else if (compare_eth(entry->src, src))
+	else if (batadv_compare_eth(entry->src, src))
 		return sprintf(buff, "TQ %pM %d, ", entry->dest,
 			       entry->quality);
 
@@ -233,8 +233,8 @@ int batadv_vis_seq_print_text(struct seq_file *seq, void *offset)
 			for (j = 0; j < packet->entries; j++) {
 				if (entries[j].quality == 0)
 					continue;
-				if (compare_eth(entries[j].src,
-						packet->vis_orig))
+				if (batadv_compare_eth(entries[j].src,
+						       packet->vis_orig))
 					continue;
 				vis_data_insert_interface(entries[j].src,
 							  &vis_if_list,
@@ -245,7 +245,8 @@ int batadv_vis_seq_print_text(struct seq_file *seq, void *offset)
 				buf_size += 18 + 26 * packet->entries;
 
 				/* add primary/secondary records */
-				if (compare_eth(entry->addr, packet->vis_orig))
+				if (batadv_compare_eth(entry->addr,
+						       packet->vis_orig))
 					buf_size +=
 					  vis_data_count_prim_sec(&vis_if_list);
 
@@ -285,8 +286,8 @@ int batadv_vis_seq_print_text(struct seq_file *seq, void *offset)
 			for (j = 0; j < packet->entries; j++) {
 				if (entries[j].quality == 0)
 					continue;
-				if (compare_eth(entries[j].src,
-						packet->vis_orig))
+				if (batadv_compare_eth(entries[j].src,
+						       packet->vis_orig))
 					continue;
 				vis_data_insert_interface(entries[j].src,
 							  &vis_if_list,
@@ -305,7 +306,8 @@ int batadv_vis_seq_print_text(struct seq_file *seq, void *offset)
 							entry->primary);
 
 				/* add primary/secondary records */
-				if (compare_eth(entry->addr, packet->vis_orig))
+				if (batadv_compare_eth(entry->addr,
+						       packet->vis_orig))
 					buff_pos +=
 					 vis_data_read_prim_sec(buff + buff_pos,
 								&vis_if_list);
@@ -379,7 +381,7 @@ static int recv_list_is_in(struct bat_priv *bat_priv,
 
 	spin_lock_bh(&bat_priv->vis_list_lock);
 	list_for_each_entry(entry, recv_list, list) {
-		if (compare_eth(entry->mac, mac)) {
+		if (batadv_compare_eth(entry->mac, mac)) {
 			spin_unlock_bh(&bat_priv->vis_list_lock);
 			return 1;
 		}
@@ -651,7 +653,7 @@ static int generate_vis_packet(struct bat_priv *bat_priv)
 			if (!router)
 				continue;
 
-			if (!compare_eth(router->addr, orig_node->orig))
+			if (!batadv_compare_eth(router->addr, orig_node->orig))
 				goto next;
 
 			if (router->if_incoming->if_status != IF_ACTIVE)
@@ -728,7 +730,8 @@ static void purge_vis_packets(struct bat_priv *bat_priv)
 			if (info == bat_priv->my_vis_info)
 				continue;
 
-			if (has_timed_out(info->first_seen, VIS_TIMEOUT)) {
+			if (batadv_has_timed_out(info->first_seen,
+						 VIS_TIMEOUT)) {
 				hlist_del(node);
 				send_list_del(info);
 				kref_put(&info->refcount, free_info);
-- 
1.7.9.4
