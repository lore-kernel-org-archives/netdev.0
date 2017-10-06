From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 2/4] batman-adv: Remove unnecessary parentheses
Date: Fri,  6 Oct 2017 15:54:35 +0200
Message-ID: <20171006135437.26736-3-sw@simonwunderlich.de>
References: <20171006135437.26736-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:38964 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751933AbdJFOAZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 10:00:25 -0400
In-Reply-To: <20171006135437.26736-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

checkpatch introduced with commit 63b7c73ec86b ("checkpatch: add --strict
check for ifs with unnecessary parentheses") an additional test which
identifies some unnecessary parentheses.

Remove these unnecessary parentheses to avoid the warnings and to unify the
coding style slightly more.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/bat_iv_ogm.c            | 24 ++++++++++++------------
 net/batman-adv/bat_v.c                 |  2 +-
 net/batman-adv/bat_v_elp.c             |  6 +++---
 net/batman-adv/bat_v_ogm.c             | 12 ++++++------
 net/batman-adv/distributed-arp-table.c |  4 ++--
 net/batman-adv/gateway_client.c        |  8 ++++----
 net/batman-adv/gateway_common.c        | 18 +++++++++---------
 net/batman-adv/hard-interface.c        | 12 ++++++------
 net/batman-adv/icmp_socket.c           |  4 ++--
 net/batman-adv/main.c                  |  4 ++--
 net/batman-adv/multicast.c             |  2 +-
 net/batman-adv/originator.c            | 26 +++++++++++++-------------
 net/batman-adv/routing.c               |  6 +++---
 net/batman-adv/send.c                  |  6 +++---
 net/batman-adv/soft-interface.c        |  2 +-
 net/batman-adv/sysfs.c                 |  4 ++--
 net/batman-adv/tp_meter.c              |  2 +-
 17 files changed, 71 insertions(+), 71 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 83ba5483455a..1b659ab652fb 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -916,8 +916,8 @@ static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 	u16 tvlv_len = 0;
 	unsigned long send_time;
 
-	if ((hard_iface->if_status == BATADV_IF_NOT_IN_USE) ||
-	    (hard_iface->if_status == BATADV_IF_TO_BE_REMOVED))
+	if (hard_iface->if_status == BATADV_IF_NOT_IN_USE ||
+	    hard_iface->if_status == BATADV_IF_TO_BE_REMOVED)
 		return;
 
 	/* the interface gets activated here to avoid race conditions between
@@ -1264,7 +1264,7 @@ static bool batadv_iv_ogm_calc_tq(struct batadv_orig_node *orig_node,
 	 * drops as they can't send and receive at the same time.
 	 */
 	tq_iface_penalty = BATADV_TQ_MAX_VALUE;
-	if (if_outgoing && (if_incoming == if_outgoing) &&
+	if (if_outgoing && if_incoming == if_outgoing &&
 	    batadv_is_wifi_hardif(if_outgoing))
 		tq_iface_penalty = batadv_hop_penalty(BATADV_TQ_MAX_VALUE,
 						      bat_priv);
@@ -1369,7 +1369,7 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 				ret = BATADV_NEIGH_DUP;
 		} else {
 			set_mark = 0;
-			if (is_dup && (ret != BATADV_NEIGH_DUP))
+			if (is_dup && ret != BATADV_NEIGH_DUP)
 				ret = BATADV_ORIG_DUP;
 		}
 
@@ -1515,7 +1515,7 @@ batadv_iv_ogm_process_per_outif(const struct sk_buff *skb, int ogm_offset,
 	/* drop packet if sender is not a direct neighbor and if we
 	 * don't route towards it
 	 */
-	if (!is_single_hop_neigh && (!orig_neigh_router)) {
+	if (!is_single_hop_neigh && !orig_neigh_router) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: OGM via unknown neighbor!\n");
 		goto out_neigh;
@@ -1535,7 +1535,7 @@ batadv_iv_ogm_process_per_outif(const struct sk_buff *skb, int ogm_offset,
 	sameseq = orig_ifinfo->last_real_seqno == ntohl(ogm_packet->seqno);
 	similar_ttl = (orig_ifinfo->last_ttl - 3) <= ogm_packet->ttl;
 
-	if (is_bidirect && ((dup_status == BATADV_NO_DUP) ||
+	if (is_bidirect && (dup_status == BATADV_NO_DUP ||
 			    (sameseq && similar_ttl))) {
 		batadv_iv_ogm_orig_update(bat_priv, orig_node,
 					  orig_ifinfo, ethhdr,
@@ -1553,8 +1553,8 @@ batadv_iv_ogm_process_per_outif(const struct sk_buff *skb, int ogm_offset,
 		/* OGMs from secondary interfaces should only scheduled once
 		 * per interface where it has been received, not multiple times
 		 */
-		if ((ogm_packet->ttl <= 2) &&
-		    (if_incoming != if_outgoing)) {
+		if (ogm_packet->ttl <= 2 &&
+		    if_incoming != if_outgoing) {
 			batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 				   "Drop packet: OGM from secondary interface and wrong outgoing interface\n");
 			goto out_neigh;
@@ -1590,7 +1590,7 @@ batadv_iv_ogm_process_per_outif(const struct sk_buff *skb, int ogm_offset,
 			      if_incoming, if_outgoing);
 
 out_neigh:
-	if ((orig_neigh_node) && (!is_single_hop_neigh))
+	if (orig_neigh_node && !is_single_hop_neigh)
 		batadv_orig_node_put(orig_neigh_node);
 out:
 	if (router_ifinfo)
@@ -2523,9 +2523,9 @@ batadv_iv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 			tmp_gw_factor *= 100 * 100;
 			tmp_gw_factor >>= 18;
 
-			if ((tmp_gw_factor > max_gw_factor) ||
-			    ((tmp_gw_factor == max_gw_factor) &&
-			     (tq_avg > max_tq))) {
+			if (tmp_gw_factor > max_gw_factor ||
+			    (tmp_gw_factor == max_gw_factor &&
+			     tq_avg > max_tq)) {
 				if (curr_gw)
 					batadv_gw_node_put(curr_gw);
 				curr_gw = gw_node;
diff --git a/net/batman-adv/bat_v.c b/net/batman-adv/bat_v.c
index 4e2724c5b33d..93ef1c06227e 100644
--- a/net/batman-adv/bat_v.c
+++ b/net/batman-adv/bat_v.c
@@ -767,7 +767,7 @@ batadv_v_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 		if (batadv_v_gw_throughput_get(gw_node, &bw) < 0)
 			goto next;
 
-		if (curr_gw && (bw <= max_bw))
+		if (curr_gw && bw <= max_bw)
 			goto next;
 
 		if (curr_gw)
diff --git a/net/batman-adv/bat_v_elp.c b/net/batman-adv/bat_v_elp.c
index bd1064d98e16..1de992c58b35 100644
--- a/net/batman-adv/bat_v_elp.c
+++ b/net/batman-adv/bat_v_elp.c
@@ -134,7 +134,7 @@ static u32 batadv_v_elp_get_throughput(struct batadv_hardif_neigh_node *neigh)
 			hard_iface->bat_v.flags &= ~BATADV_FULL_DUPLEX;
 
 		throughput = link_settings.base.speed;
-		if (throughput && (throughput != SPEED_UNKNOWN))
+		if (throughput && throughput != SPEED_UNKNOWN)
 			return throughput * 10;
 	}
 
@@ -263,8 +263,8 @@ static void batadv_v_elp_periodic_work(struct work_struct *work)
 		goto out;
 
 	/* we are in the process of shutting this interface down */
-	if ((hard_iface->if_status == BATADV_IF_NOT_IN_USE) ||
-	    (hard_iface->if_status == BATADV_IF_TO_BE_REMOVED))
+	if (hard_iface->if_status == BATADV_IF_NOT_IN_USE ||
+	    hard_iface->if_status == BATADV_IF_TO_BE_REMOVED)
 		goto out;
 
 	/* the interface was enabled but may not be ready yet */
diff --git a/net/batman-adv/bat_v_ogm.c b/net/batman-adv/bat_v_ogm.c
index 8be61734fc43..c251445a42a0 100644
--- a/net/batman-adv/bat_v_ogm.c
+++ b/net/batman-adv/bat_v_ogm.c
@@ -304,8 +304,8 @@ static u32 batadv_v_forward_penalty(struct batadv_priv *bat_priv,
 	 * due to the store & forward characteristics of WIFI.
 	 * Very low throughput values are the exception.
 	 */
-	if ((throughput > 10) &&
-	    (if_incoming == if_outgoing) &&
+	if (throughput > 10 &&
+	    if_incoming == if_outgoing &&
 	    !(if_incoming->bat_v.flags & BATADV_FULL_DUPLEX))
 		return throughput / 2;
 
@@ -455,7 +455,7 @@ static int batadv_v_ogm_metric_update(struct batadv_priv *bat_priv,
 	/* drop packets with old seqnos, however accept the first packet after
 	 * a host has been rebooted.
 	 */
-	if ((seq_diff < 0) && !protection_started)
+	if (seq_diff < 0 && !protection_started)
 		goto out;
 
 	neigh_node->last_seen = jiffies;
@@ -568,8 +568,8 @@ static bool batadv_v_ogm_route_update(struct batadv_priv *bat_priv,
 		router_throughput = router_ifinfo->bat_v.throughput;
 		neigh_throughput = neigh_ifinfo->bat_v.throughput;
 
-		if ((neigh_seq_diff < BATADV_OGM_MAX_ORIGDIFF) &&
-		    (router_throughput >= neigh_throughput))
+		if (neigh_seq_diff < BATADV_OGM_MAX_ORIGDIFF &&
+		    router_throughput >= neigh_throughput)
 			goto out;
 	}
 
@@ -621,7 +621,7 @@ batadv_v_ogm_process_per_outif(struct batadv_priv *bat_priv,
 		return;
 
 	/* only unknown & newer OGMs contain TVLVs we are interested in */
-	if ((seqno_age > 0) && (if_outgoing == BATADV_IF_DEFAULT))
+	if (seqno_age > 0 && if_outgoing == BATADV_IF_DEFAULT)
 		batadv_tvlv_containers_process(bat_priv, true, orig_node,
 					       NULL, NULL,
 					       (unsigned char *)(ogm2 + 1),
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index b6cfa78e9381..760c0de72582 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -492,8 +492,8 @@ static bool batadv_is_orig_node_eligible(struct batadv_dat_candidate *res,
 	/* this is an hash collision with the temporary selected node. Choose
 	 * the one with the lowest address
 	 */
-	if ((tmp_max == max) && max_orig_node &&
-	    (batadv_compare_eth(candidate->orig, max_orig_node->orig) > 0))
+	if (tmp_max == max && max_orig_node &&
+	    batadv_compare_eth(candidate->orig, max_orig_node->orig) > 0)
 		goto out;
 
 	ret = true;
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index de9955d5224d..10d521f0b17f 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -248,12 +248,12 @@ void batadv_gw_election(struct batadv_priv *bat_priv)
 		}
 	}
 
-	if ((curr_gw) && (!next_gw)) {
+	if (curr_gw && !next_gw) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Removing selected gateway - no gateway in range\n");
 		batadv_throw_uevent(bat_priv, BATADV_UEV_GW, BATADV_UEV_DEL,
 				    NULL);
-	} else if ((!curr_gw) && (next_gw)) {
+	} else if (!curr_gw && next_gw) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Adding route to gateway %pM (bandwidth: %u.%u/%u.%u MBit, tq: %i)\n",
 			   next_gw->orig_node->orig,
@@ -411,8 +411,8 @@ void batadv_gw_node_update(struct batadv_priv *bat_priv,
 		goto out;
 	}
 
-	if ((gw_node->bandwidth_down == ntohl(gateway->bandwidth_down)) &&
-	    (gw_node->bandwidth_up == ntohl(gateway->bandwidth_up)))
+	if (gw_node->bandwidth_down == ntohl(gateway->bandwidth_down) &&
+	    gw_node->bandwidth_up == ntohl(gateway->bandwidth_up))
 		goto out;
 
 	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index 33940c5c74a8..2c26039c23fc 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -56,8 +56,8 @@ bool batadv_parse_throughput(struct net_device *net_dev, char *buff,
 		if (strncasecmp(tmp_ptr, "mbit", 4) == 0)
 			bw_unit_type = BATADV_BW_UNIT_MBIT;
 
-		if ((strncasecmp(tmp_ptr, "kbit", 4) == 0) ||
-		    (bw_unit_type == BATADV_BW_UNIT_MBIT))
+		if (strncasecmp(tmp_ptr, "kbit", 4) == 0 ||
+		    bw_unit_type == BATADV_BW_UNIT_MBIT)
 			*tmp_ptr = '\0';
 	}
 
@@ -190,7 +190,7 @@ ssize_t batadv_gw_bandwidth_set(struct net_device *net_dev, char *buff,
 	if (!up_new)
 		up_new = 1;
 
-	if ((down_curr == down_new) && (up_curr == up_new))
+	if (down_curr == down_new && up_curr == up_new)
 		return count;
 
 	batadv_gw_reselect(bat_priv);
@@ -224,16 +224,16 @@ static void batadv_gw_tvlv_ogm_handler_v1(struct batadv_priv *bat_priv,
 	/* only fetch the tvlv value if the handler wasn't called via the
 	 * CIFNOTFND flag and if there is data to fetch
 	 */
-	if ((flags & BATADV_TVLV_HANDLER_OGM_CIFNOTFND) ||
-	    (tvlv_value_len < sizeof(gateway))) {
+	if (flags & BATADV_TVLV_HANDLER_OGM_CIFNOTFND ||
+	    tvlv_value_len < sizeof(gateway)) {
 		gateway.bandwidth_down = 0;
 		gateway.bandwidth_up = 0;
 	} else {
 		gateway_ptr = tvlv_value;
 		gateway.bandwidth_down = gateway_ptr->bandwidth_down;
 		gateway.bandwidth_up = gateway_ptr->bandwidth_up;
-		if ((gateway.bandwidth_down == 0) ||
-		    (gateway.bandwidth_up == 0)) {
+		if (gateway.bandwidth_down == 0 ||
+		    gateway.bandwidth_up == 0) {
 			gateway.bandwidth_down = 0;
 			gateway.bandwidth_up = 0;
 		}
@@ -242,8 +242,8 @@ static void batadv_gw_tvlv_ogm_handler_v1(struct batadv_priv *bat_priv,
 	batadv_gw_node_update(bat_priv, orig, &gateway);
 
 	/* restart gateway selection */
-	if ((gateway.bandwidth_down != 0) &&
-	    (atomic_read(&bat_priv->gw.mode) == BATADV_GW_MODE_CLIENT))
+	if (gateway.bandwidth_down != 0 &&
+	    atomic_read(&bat_priv->gw.mode) == BATADV_GW_MODE_CLIENT)
 		batadv_gw_check_election(bat_priv, orig);
 }
 
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index e348f76ea8c1..d4aa99c060f9 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -504,8 +504,8 @@ static void batadv_check_known_mac_addr(const struct net_device *net_dev)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
-		if ((hard_iface->if_status != BATADV_IF_ACTIVE) &&
-		    (hard_iface->if_status != BATADV_IF_TO_BE_ACTIVATED))
+		if (hard_iface->if_status != BATADV_IF_ACTIVE &&
+		    hard_iface->if_status != BATADV_IF_TO_BE_ACTIVATED)
 			continue;
 
 		if (hard_iface->net_dev == net_dev)
@@ -568,8 +568,8 @@ int batadv_hardif_min_mtu(struct net_device *soft_iface)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
-		if ((hard_iface->if_status != BATADV_IF_ACTIVE) &&
-		    (hard_iface->if_status != BATADV_IF_TO_BE_ACTIVATED))
+		if (hard_iface->if_status != BATADV_IF_ACTIVE &&
+		    hard_iface->if_status != BATADV_IF_TO_BE_ACTIVATED)
 			continue;
 
 		if (hard_iface->soft_iface != soft_iface)
@@ -654,8 +654,8 @@ batadv_hardif_activate_interface(struct batadv_hard_iface *hard_iface)
 static void
 batadv_hardif_deactivate_interface(struct batadv_hard_iface *hard_iface)
 {
-	if ((hard_iface->if_status != BATADV_IF_ACTIVE) &&
-	    (hard_iface->if_status != BATADV_IF_TO_BE_ACTIVATED))
+	if (hard_iface->if_status != BATADV_IF_ACTIVE &&
+	    hard_iface->if_status != BATADV_IF_TO_BE_ACTIVATED)
 		return;
 
 	hard_iface->if_status = BATADV_IF_INACTIVE;
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 8ead292886d1..bded31121d12 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -132,10 +132,10 @@ static ssize_t batadv_socket_read(struct file *file, char __user *buf,
 	size_t packet_len;
 	int error;
 
-	if ((file->f_flags & O_NONBLOCK) && (socket_client->queue_len == 0))
+	if ((file->f_flags & O_NONBLOCK) && socket_client->queue_len == 0)
 		return -EAGAIN;
 
-	if ((!buf) || (count < sizeof(struct batadv_icmp_packet)))
+	if (!buf || count < sizeof(struct batadv_icmp_packet))
 		return -EINVAL;
 
 	if (!access_ok(VERIFY_WRITE, buf, count))
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index fb381fb26a66..033819aefc39 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -544,8 +544,8 @@ batadv_recv_handler_register(u8 packet_type,
 		    struct batadv_hard_iface *);
 	curr = batadv_rx_handler[packet_type];
 
-	if ((curr != batadv_recv_unhandled_packet) &&
-	    (curr != batadv_recv_unhandled_unicast_packet))
+	if (curr != batadv_recv_unhandled_packet &&
+	    curr != batadv_recv_unhandled_unicast_packet)
 		return -EBUSY;
 
 	batadv_rx_handler[packet_type] = recv_handler;
diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index d327670641ac..e553a8770a89 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -1126,7 +1126,7 @@ static void batadv_mcast_tvlv_ogm_handler(struct batadv_priv *bat_priv,
 	bool orig_initialized;
 
 	if (orig_mcast_enabled && tvlv_value &&
-	    (tvlv_value_len >= sizeof(mcast_flags)))
+	    tvlv_value_len >= sizeof(mcast_flags))
 		mcast_flags = *(u8 *)tvlv_value;
 
 	spin_lock_bh(&orig->mcast_handler_lock);
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 8e2a4b205257..2967b86c13da 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -1062,9 +1062,9 @@ batadv_purge_neigh_ifinfo(struct batadv_priv *bat_priv,
 			continue;
 
 		/* don't purge if the interface is not (going) down */
-		if ((if_outgoing->if_status != BATADV_IF_INACTIVE) &&
-		    (if_outgoing->if_status != BATADV_IF_NOT_IN_USE) &&
-		    (if_outgoing->if_status != BATADV_IF_TO_BE_REMOVED))
+		if (if_outgoing->if_status != BATADV_IF_INACTIVE &&
+		    if_outgoing->if_status != BATADV_IF_NOT_IN_USE &&
+		    if_outgoing->if_status != BATADV_IF_TO_BE_REMOVED)
 			continue;
 
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
@@ -1106,9 +1106,9 @@ batadv_purge_orig_ifinfo(struct batadv_priv *bat_priv,
 			continue;
 
 		/* don't purge if the interface is not (going) down */
-		if ((if_outgoing->if_status != BATADV_IF_INACTIVE) &&
-		    (if_outgoing->if_status != BATADV_IF_NOT_IN_USE) &&
-		    (if_outgoing->if_status != BATADV_IF_TO_BE_REMOVED))
+		if (if_outgoing->if_status != BATADV_IF_INACTIVE &&
+		    if_outgoing->if_status != BATADV_IF_NOT_IN_USE &&
+		    if_outgoing->if_status != BATADV_IF_TO_BE_REMOVED)
 			continue;
 
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
@@ -1155,13 +1155,13 @@ batadv_purge_orig_neighbors(struct batadv_priv *bat_priv,
 		last_seen = neigh_node->last_seen;
 		if_incoming = neigh_node->if_incoming;
 
-		if ((batadv_has_timed_out(last_seen, BATADV_PURGE_TIMEOUT)) ||
-		    (if_incoming->if_status == BATADV_IF_INACTIVE) ||
-		    (if_incoming->if_status == BATADV_IF_NOT_IN_USE) ||
-		    (if_incoming->if_status == BATADV_IF_TO_BE_REMOVED)) {
-			if ((if_incoming->if_status == BATADV_IF_INACTIVE) ||
-			    (if_incoming->if_status == BATADV_IF_NOT_IN_USE) ||
-			    (if_incoming->if_status == BATADV_IF_TO_BE_REMOVED))
+		if (batadv_has_timed_out(last_seen, BATADV_PURGE_TIMEOUT) ||
+		    if_incoming->if_status == BATADV_IF_INACTIVE ||
+		    if_incoming->if_status == BATADV_IF_NOT_IN_USE ||
+		    if_incoming->if_status == BATADV_IF_TO_BE_REMOVED) {
+			if (if_incoming->if_status == BATADV_IF_INACTIVE ||
+			    if_incoming->if_status == BATADV_IF_NOT_IN_USE ||
+			    if_incoming->if_status == BATADV_IF_TO_BE_REMOVED)
 				batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 					   "neighbor purge: originator %pM, neighbor: %pM, iface: %s\n",
 					   orig_node->orig, neigh_node->addr,
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index f10e3ff26f9d..40d9bf3e5bfe 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -93,14 +93,14 @@ static void _batadv_update_route(struct batadv_priv *bat_priv,
 	batadv_orig_ifinfo_put(orig_ifinfo);
 
 	/* route deleted */
-	if ((curr_router) && (!neigh_node)) {
+	if (curr_router && !neigh_node) {
 		batadv_dbg(BATADV_DBG_ROUTES, bat_priv,
 			   "Deleting route towards: %pM\n", orig_node->orig);
 		batadv_tt_global_del_orig(bat_priv, orig_node, -1,
 					  "Deleted route towards originator");
 
 	/* route added */
-	} else if ((!curr_router) && (neigh_node)) {
+	} else if (!curr_router && neigh_node) {
 		batadv_dbg(BATADV_DBG_ROUTES, bat_priv,
 			   "Adding route towards: %pM (via %pM)\n",
 			   orig_node->orig, neigh_node->addr);
@@ -381,7 +381,7 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 	/* add record route information if not full */
 	if ((icmph->msg_type == BATADV_ECHO_REPLY ||
 	     icmph->msg_type == BATADV_ECHO_REQUEST) &&
-	    (skb->len >= sizeof(struct batadv_icmp_packet_rr))) {
+	    skb->len >= sizeof(struct batadv_icmp_packet_rr)) {
 		if (skb_linearize(skb) < 0)
 			goto free_skb;
 
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 054a65e6eb68..7895323fd2a7 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -142,7 +142,7 @@ int batadv_send_unicast_skb(struct sk_buff *skb,
 #ifdef CONFIG_BATMAN_ADV_BATMAN_V
 	hardif_neigh = batadv_hardif_neigh_get(neigh->if_incoming, neigh->addr);
 
-	if ((hardif_neigh) && (ret != NET_XMIT_DROP))
+	if (hardif_neigh && ret != NET_XMIT_DROP)
 		hardif_neigh->bat_v.last_unicast_tx = jiffies;
 
 	if (hardif_neigh)
@@ -615,8 +615,8 @@ batadv_forw_packet_list_steal(struct hlist_head *forw_list,
 		 * we delete only packets belonging to the given interface
 		 */
 		if (hard_iface &&
-		    (forw_packet->if_incoming != hard_iface) &&
-		    (forw_packet->if_outgoing != hard_iface))
+		    forw_packet->if_incoming != hard_iface &&
+		    forw_packet->if_outgoing != hard_iface)
 			continue;
 
 		hlist_del(&forw_packet->list);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index c2c986746d0b..7c8288245f80 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -160,7 +160,7 @@ static int batadv_interface_set_mac_addr(struct net_device *dev, void *p)
 static int batadv_interface_change_mtu(struct net_device *dev, int new_mtu)
 {
 	/* check ranges */
-	if ((new_mtu < 68) || (new_mtu > batadv_hardif_min_mtu(dev)))
+	if (new_mtu < 68 || new_mtu > batadv_hardif_min_mtu(dev))
 		return -EINVAL;
 
 	dev->mtu = new_mtu;
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 0ae8b30e4eaa..aa187fd42475 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -925,8 +925,8 @@ static int batadv_store_mesh_iface_finish(struct net_device *net_dev,
 	if (hard_iface->if_status == status_tmp)
 		goto out;
 
-	if ((hard_iface->soft_iface) &&
-	    (strncmp(hard_iface->soft_iface->name, ifname, IFNAMSIZ) == 0))
+	if (hard_iface->soft_iface &&
+	    strncmp(hard_iface->soft_iface->name, ifname, IFNAMSIZ) == 0)
 		goto out;
 
 	if (status_tmp == BATADV_IF_NOT_IN_USE) {
diff --git a/net/batman-adv/tp_meter.c b/net/batman-adv/tp_meter.c
index bfe8effe9238..4b90033f35a8 100644
--- a/net/batman-adv/tp_meter.c
+++ b/net/batman-adv/tp_meter.c
@@ -1206,7 +1206,7 @@ static int batadv_tp_send_ack(struct batadv_priv *bat_priv, const u8 *dst,
 
 	/* send the ack */
 	r = batadv_send_skb_to_orig(skb, orig_node, NULL);
-	if (unlikely(r < 0) || (r == NET_XMIT_DROP)) {
+	if (unlikely(r < 0) || r == NET_XMIT_DROP) {
 		ret = BATADV_TP_REASON_DST_UNREACHABLE;
 		goto out;
 	}
-- 
2.11.0
