From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: [PATCH 1/4] batman-adv: Ignore 80-chars per line
	limits for strings
Date: Sun, 11 Mar 2012 06:44:48 +0800
Message-ID: <1331419491-21333-2-git-send-email-lindner_marek@yahoo.de>
References: <1331419491-21333-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1331419491-21333-1-git-send-email-lindner_marek-LWAfsSFWpa4@public.gmane.org>
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

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 net/batman-adv/bat_iv_ogm.c        |   54 +++++++++-------------
 net/batman-adv/bat_sysfs.c         |   16 +++---
 net/batman-adv/gateway_client.c    |   31 +++++-------
 net/batman-adv/gateway_common.c    |    8 ++--
 net/batman-adv/hard-interface.c    |   36 +++++----------
 net/batman-adv/icmp_socket.c       |   12 ++---
 net/batman-adv/main.c              |    8 ++--
 net/batman-adv/originator.c        |   14 ++---
 net/batman-adv/routing.c           |   27 +++++------
 net/batman-adv/send.c              |    4 +-
 net/batman-adv/soft-interface.c    |   15 +++---
 net/batman-adv/translation-table.c |   89 +++++++++++++++++------------------
 12 files changed, 137 insertions(+), 177 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 2b66dae..677997b 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -132,8 +132,7 @@ static void bat_iv_ogm_send_to_if(struct forw_packet *forw_packet,
 							    "Sending own" :
 							    "Forwarding"));
 		bat_dbg(DBG_BATMAN, bat_priv,
-			"%s %spacket (originator %pM, seqno %d, TQ %d, TTL %d,"
-			" IDF %s, ttvn %d) on interface %s [%pM]\n",
+			"%s %spacket (originator %pM, seqno %d, TQ %d, TTL %d, IDF %s, ttvn %d) on interface %s [%pM]\n",
 			fwd_str, (packet_num > 0 ? "aggregated " : ""),
 			batman_ogm_packet->orig,
 			ntohl(batman_ogm_packet->seqno),
@@ -171,8 +170,7 @@ static void bat_iv_ogm_emit(struct forw_packet *forw_packet)
 	directlink = (batman_ogm_packet->flags & DIRECTLINK ? 1 : 0);
 
 	if (!forw_packet->if_incoming) {
-		pr_err("Error - can't forward packet: incoming iface not "
-		       "specified\n");
+		pr_err("Error - can't forward packet: incoming iface not specified\n");
 		goto out;
 	}
 
@@ -193,8 +191,7 @@ static void bat_iv_ogm_emit(struct forw_packet *forw_packet)
 
 		/* FIXME: what about aggregated packets ? */
 		bat_dbg(DBG_BATMAN, bat_priv,
-			"%s packet (originator %pM, seqno %d, TTL %d) "
-			"on interface %s [%pM]\n",
+			"%s packet (originator %pM, seqno %d, TTL %d) on interface %s [%pM]\n",
 			(forw_packet->own ? "Sending own" : "Forwarding"),
 			batman_ogm_packet->orig,
 			ntohl(batman_ogm_packet->seqno),
@@ -508,8 +505,7 @@ static void bat_iv_ogm_forward(struct orig_node *orig_node,
 	batman_ogm_packet->tq = hop_penalty(batman_ogm_packet->tq, bat_priv);
 
 	bat_dbg(DBG_BATMAN, bat_priv,
-		"Forwarding packet: tq_orig: %i, tq_avg: %i, "
-		"tq_forw: %i, ttl_orig: %i, ttl_forw: %i\n",
+		"Forwarding packet: tq_orig: %i, tq_avg: %i, tq_forw: %i, ttl_orig: %i, ttl_forw: %i\n",
 		in_tq, tq_avg, batman_ogm_packet->tq, in_ttl - 1,
 		batman_ogm_packet->header.ttl);
 
@@ -589,8 +585,8 @@ static void bat_iv_ogm_orig_update(struct bat_priv *bat_priv,
 	struct hlist_node *node;
 	uint8_t bcast_own_sum_orig, bcast_own_sum_neigh;
 
-	bat_dbg(DBG_BATMAN, bat_priv, "update_originator(): "
-		"Searching and updating originator entry of received packet\n");
+	bat_dbg(DBG_BATMAN, bat_priv,
+		"update_originator(): Searching and updating originator entry of received packet\n");
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(tmp_neigh_node, node,
@@ -802,10 +798,7 @@ static int bat_iv_ogm_calc_tq(struct orig_node *orig_node,
 						(TQ_MAX_VALUE * TQ_MAX_VALUE));
 
 	bat_dbg(DBG_BATMAN, bat_priv,
-		"bidirectional: "
-		"orig = %-15pM neigh = %-15pM => own_bcast = %2i, "
-		"real recv = %2i, local tq: %3i, asym_penalty: %3i, "
-		"total tq: %3i\n",
+		"bidirectional: orig = %-15pM neigh = %-15pM => own_bcast = %2i, real recv = %2i, local tq: %3i, asym_penalty: %3i, total tq: %3i\n",
 		orig_node->orig, orig_neigh_node->orig, total_count,
 		neigh_rq_count, tq_own,	tq_asym_penalty, batman_ogm_packet->tq);
 
@@ -933,9 +926,7 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 					   batman_ogm_packet->orig) ? 1 : 0);
 
 	bat_dbg(DBG_BATMAN, bat_priv,
-		"Received BATMAN packet via NB: %pM, IF: %s [%pM] "
-		"(from OG: %pM, via prev OG: %pM, seqno %d, ttvn %u, "
-		"crc %u, changes %u, td %d, TTL %d, V %d, IDF %d)\n",
+		"Received BATMAN packet via NB: %pM, IF: %s [%pM] (from OG: %pM, via prev OG: %pM, seqno %d, ttvn %u, crc %u, changes %u, td %d, TTL %d, V %d, IDF %d)\n",
 		ethhdr->h_source, if_incoming->net_dev->name,
 		if_incoming->net_dev->dev_addr, batman_ogm_packet->orig,
 		batman_ogm_packet->prev_sender, batman_ogm_packet->seqno,
@@ -978,16 +969,15 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 
 	if (is_my_addr) {
 		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: received my own broadcast (sender: %pM"
-			")\n",
+			"Drop packet: received my own broadcast (sender: %pM)\n",
 			ethhdr->h_source);
 		return;
 	}
 
 	if (is_broadcast) {
-		bat_dbg(DBG_BATMAN, bat_priv, "Drop packet: "
-		"ignoring all packets with broadcast source addr (sender: %pM"
-		")\n", ethhdr->h_source);
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: ignoring all packets with broadcast source addr (sender: %pM)\n",
+			ethhdr->h_source);
 		return;
 	}
 
@@ -1017,16 +1007,16 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 			spin_unlock_bh(&orig_neigh_node->ogm_cnt_lock);
 		}
 
-		bat_dbg(DBG_BATMAN, bat_priv, "Drop packet: "
-			"originator packet from myself (via neighbor)\n");
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: originator packet from myself (via neighbor)\n");
 		orig_node_free_ref(orig_neigh_node);
 		return;
 	}
 
 	if (is_my_oldorig) {
 		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: ignoring all rebroadcast echos (sender: "
-			"%pM)\n", ethhdr->h_source);
+			"Drop packet: ignoring all rebroadcast echos (sender: %pM)\n",
+			ethhdr->h_source);
 		return;
 	}
 
@@ -1039,8 +1029,8 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 
 	if (is_duplicate == -1) {
 		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: packet within seqno protection time "
-			"(sender: %pM)\n", ethhdr->h_source);
+			"Drop packet: packet within seqno protection time (sender: %pM)\n",
+			ethhdr->h_source);
 		goto out;
 	}
 
@@ -1061,8 +1051,8 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 			  batman_ogm_packet->prev_sender)) &&
 	    (compare_eth(router->addr, router_router->addr))) {
 		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: ignoring all rebroadcast packets that "
-			"may make me loop (sender: %pM)\n", ethhdr->h_source);
+			"Drop packet: ignoring all rebroadcast packets that may make me loop (sender: %pM)\n",
+			ethhdr->h_source);
 		goto out;
 	}
 
@@ -1106,8 +1096,8 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 		bat_iv_ogm_forward(orig_node, ethhdr, batman_ogm_packet,
 				   1, if_incoming);
 
-		bat_dbg(DBG_BATMAN, bat_priv, "Forwarding packet: "
-			"rebroadcast neighbor packet with direct link flag\n");
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Forwarding packet: rebroadcast neighbor packet with direct link flag\n");
 		goto out_neigh;
 	}
 
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index b00101d..68ff759 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -255,8 +255,8 @@ static ssize_t store_vis_mode(struct kobject *kobj, struct attribute *attr,
 			buff[count - 1] = '\0';
 
 		bat_info(net_dev,
-			 "Invalid parameter for 'vis mode' setting received: "
-			 "%s\n", buff);
+			 "Invalid parameter for 'vis mode' setting received: %s\n",
+			 buff);
 		return -EINVAL;
 	}
 
@@ -330,8 +330,8 @@ static ssize_t store_gw_mode(struct kobject *kobj, struct attribute *attr,
 
 	if (gw_mode_tmp < 0) {
 		bat_info(net_dev,
-			 "Invalid parameter for 'gw mode' setting received: "
-			 "%s\n", buff);
+			 "Invalid parameter for 'gw mode' setting received: %s\n",
+			 buff);
 		return -EINVAL;
 	}
 
@@ -502,8 +502,8 @@ static ssize_t store_mesh_iface(struct kobject *kobj, struct attribute *attr,
 		buff[count - 1] = '\0';
 
 	if (strlen(buff) >= IFNAMSIZ) {
-		pr_err("Invalid parameter for 'mesh_iface' setting received: "
-		       "interface name too long '%s'\n", buff);
+		pr_err("Invalid parameter for 'mesh_iface' setting received: interface name too long '%s'\n",
+		       buff);
 		hardif_free_ref(hard_iface);
 		return -EINVAL;
 	}
@@ -677,8 +677,8 @@ out:
 		hardif_free_ref(primary_if);
 
 	if (ret)
-		bat_dbg(DBG_BATMAN, bat_priv, "Impossible to send "
-			"uevent for (%s,%s,%s) event (err: %d)\n",
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Impossible to send uevent for (%s,%s,%s) event (err: %d)\n",
 			uev_type_str[type], uev_action_str[action],
 			(action == UEV_DEL ? "NULL" : data), ret);
 	return ret;
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 0fa8e2d..6f9b9b7 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -224,16 +224,13 @@ void gw_election(struct bat_priv *bat_priv)
 	} else if ((!curr_gw) && (next_gw)) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Adding route to gateway %pM (gw_flags: %i, tq: %i)\n",
-			next_gw->orig_node->orig,
-			next_gw->orig_node->gw_flags,
+			next_gw->orig_node->orig, next_gw->orig_node->gw_flags,
 			router->tq_avg);
 		throw_uevent(bat_priv, UEV_GW, UEV_ADD, gw_addr);
 	} else {
 		bat_dbg(DBG_BATMAN, bat_priv,
-			"Changing route to gateway %pM "
-			"(gw_flags: %i, tq: %i)\n",
-			next_gw->orig_node->orig,
-			next_gw->orig_node->gw_flags,
+			"Changing route to gateway %pM (gw_flags: %i, tq: %i)\n",
+			next_gw->orig_node->orig, next_gw->orig_node->gw_flags,
 			router->tq_avg);
 		throw_uevent(bat_priv, UEV_GW, UEV_CHANGE, gw_addr);
 	}
@@ -287,8 +284,7 @@ void gw_check_election(struct bat_priv *bat_priv, struct orig_node *orig_node)
 		goto out;
 
 	bat_dbg(DBG_BATMAN, bat_priv,
-		"Restarting gateway selection: better gateway found (tq curr: "
-		"%i, tq new: %i)\n",
+		"Restarting gateway selection: better gateway found (tq curr: %i, tq new: %i)\n",
 		gw_tq_avg, orig_tq_avg);
 
 deselect:
@@ -352,8 +348,7 @@ void gw_node_update(struct bat_priv *bat_priv,
 			continue;
 
 		bat_dbg(DBG_BATMAN, bat_priv,
-			"Gateway class of originator %pM changed from "
-			"%i to %i\n",
+			"Gateway class of originator %pM changed from %i to %i\n",
 			orig_node->orig, gw_node->orig_node->gw_flags,
 			new_gwflags);
 
@@ -474,23 +469,23 @@ int gw_client_seq_print_text(struct seq_file *seq, void *offset)
 
 	primary_if = primary_if_get_selected(bat_priv);
 	if (!primary_if) {
-		ret = seq_printf(seq, "BATMAN mesh %s disabled - please "
-				 "specify interfaces to enable it\n",
+		ret = seq_printf(seq,
+				 "BATMAN mesh %s disabled - please specify interfaces to enable it\n",
 				 net_dev->name);
 		goto out;
 	}
 
 	if (primary_if->if_status != IF_ACTIVE) {
-		ret = seq_printf(seq, "BATMAN mesh %s disabled - "
-				 "primary interface not active\n",
+		ret = seq_printf(seq,
+				 "BATMAN mesh %s disabled - primary interface not active\n",
 				 net_dev->name);
 		goto out;
 	}
 
-	seq_printf(seq, "      %-12s (%s/%i) %17s [%10s]: gw_class ... "
-		   "[B.A.T.M.A.N. adv %s, MainIF/MAC: %s/%pM (%s)]\n",
-		   "Gateway", "#", TQ_MAX_VALUE, "Nexthop",
-		   "outgoingIF", SOURCE_VERSION, primary_if->net_dev->name,
+	seq_printf(seq,
+		   "      %-12s (%s/%i) %17s [%10s]: gw_class ... [B.A.T.M.A.N. adv %s, MainIF/MAC: %s/%pM (%s)]\n",
+		   "Gateway", "#", TQ_MAX_VALUE, "Nexthop", "outgoingIF",
+		   SOURCE_VERSION, primary_if->net_dev->name,
 		   primary_if->net_dev->dev_addr, net_dev->name);
 
 	rcu_read_lock();
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index 3ccb9c8..ca57ac7 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -125,8 +125,8 @@ static bool parse_gw_bandwidth(struct net_device *net_dev, char *buff,
 		ret = kstrtol(slash_ptr + 1, 10, &lup);
 		if (ret) {
 			bat_err(net_dev,
-				"Upload speed of gateway mode invalid: "
-				"%s\n", slash_ptr + 1);
+				"Upload speed of gateway mode invalid: %s\n",
+				slash_ptr + 1);
 			return false;
 		}
 
@@ -163,8 +163,8 @@ ssize_t gw_bandwidth_set(struct net_device *net_dev, char *buff, size_t count)
 	gw_bandwidth_to_kbit((uint8_t)gw_bandwidth_tmp, &down, &up);
 
 	gw_deselect(bat_priv);
-	bat_info(net_dev, "Changing gateway bandwidth from: '%i' to: '%ld' "
-		 "(propagating: %d%s/%d%s)\n",
+	bat_info(net_dev,
+		 "Changing gateway bandwidth from: '%i' to: '%ld' (propagating: %d%s/%d%s)\n",
 		 atomic_read(&bat_priv->gw_bandwidth), gw_bandwidth_tmp,
 		 (down > 2048 ? down / 1024 : down),
 		 (down > 2048 ? "MBit" : "KBit"),
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 409d027..3778977 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -175,11 +175,9 @@ static void check_known_mac_addr(const struct net_device *net_dev)
 				 net_dev->dev_addr))
 			continue;
 
-		pr_warning("The newly added mac address (%pM) already exists "
-			   "on: %s\n", net_dev->dev_addr,
-			   hard_iface->net_dev->name);
-		pr_warning("It is strongly recommended to keep mac addresses "
-			   "unique to avoid problems!\n");
+		pr_warning("The newly added mac address (%pM) already exists on: %s\n",
+			   net_dev->dev_addr, hard_iface->net_dev->name);
+		pr_warning("It is strongly recommended to keep mac addresses unique to avoid problems!\n");
 	}
 	rcu_read_unlock();
 }
@@ -282,10 +280,7 @@ int hardif_enable_interface(struct hard_iface *hard_iface,
 
 	/* hard-interface is part of a bridge */
 	if (hard_iface->net_dev->priv_flags & IFF_BRIDGE_PORT)
-		pr_err("You are about to enable batman-adv on '%s' which "
-		       "already is part of a bridge. Unless you know exactly "
-		       "what you are doing this is probably wrong and won't "
-		       "work the way you think it would.\n",
+		pr_err("You are about to enable batman-adv on '%s' which already is part of a bridge. Unless you know exactly what you are doing this is probably wrong and won't work the way you think it would.\n",
 		       hard_iface->net_dev->name);
 
 	soft_iface = dev_get_by_name(&init_net, iface_name);
@@ -303,8 +298,7 @@ int hardif_enable_interface(struct hard_iface *hard_iface,
 	}
 
 	if (!softif_is_valid(soft_iface)) {
-		pr_err("Can't create batman mesh interface %s: "
-		       "already exists as regular interface\n",
+		pr_err("Can't create batman mesh interface %s: already exists as regular interface\n",
 		       soft_iface->name);
 		dev_put(soft_iface);
 		ret = -EINVAL;
@@ -317,8 +311,9 @@ int hardif_enable_interface(struct hard_iface *hard_iface,
 	bat_priv->bat_algo_ops->bat_ogm_init(hard_iface);
 
 	if (!hard_iface->packet_buff) {
-		bat_err(hard_iface->soft_iface, "Can't add interface packet "
-			"(%s): out of memory\n", hard_iface->net_dev->name);
+		bat_err(hard_iface->soft_iface,
+			"Can't add interface packet (%s): out of memory\n",
+			hard_iface->net_dev->name);
 		ret = -ENOMEM;
 		goto err;
 	}
@@ -341,29 +336,22 @@ int hardif_enable_interface(struct hard_iface *hard_iface,
 	if (atomic_read(&bat_priv->fragmentation) && hard_iface->net_dev->mtu <
 		ETH_DATA_LEN + BAT_HEADER_LEN)
 		bat_info(hard_iface->soft_iface,
-			 "The MTU of interface %s is too small (%i) to handle "
-			 "the transport of batman-adv packets. Packets going "
-			 "over this interface will be fragmented on layer2 "
-			 "which could impact the performance. Setting the MTU "
-			 "to %zi would solve the problem.\n",
+			 "The MTU of interface %s is too small (%i) to handle the transport of batman-adv packets. Packets going over this interface will be fragmented on layer2 which could impact the performance. Setting the MTU to %zi would solve the problem.\n",
 			 hard_iface->net_dev->name, hard_iface->net_dev->mtu,
 			 ETH_DATA_LEN + BAT_HEADER_LEN);
 
 	if (!atomic_read(&bat_priv->fragmentation) && hard_iface->net_dev->mtu <
 		ETH_DATA_LEN + BAT_HEADER_LEN)
 		bat_info(hard_iface->soft_iface,
-			 "The MTU of interface %s is too small (%i) to handle "
-			 "the transport of batman-adv packets. If you "
-			 "experience problems getting traffic through try "
-			 "increasing the MTU to %zi.\n",
+			 "The MTU of interface %s is too small (%i) to handle the transport of batman-adv packets. If you experience problems getting traffic through try increasing the MTU to %zi.\n",
 			 hard_iface->net_dev->name, hard_iface->net_dev->mtu,
 			 ETH_DATA_LEN + BAT_HEADER_LEN);
 
 	if (hardif_is_iface_up(hard_iface))
 		hardif_activate_interface(hard_iface);
 	else
-		bat_err(hard_iface->soft_iface, "Not using interface %s "
-			"(retrying later): interface not active\n",
+		bat_err(hard_iface->soft_iface,
+			"Not using interface %s (retrying later): interface not active\n",
 			hard_iface->net_dev->name);
 
 	/* begin scheduling originator messages on that interface */
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 9b755f9..b87518e 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -59,8 +59,7 @@ static int bat_socket_open(struct inode *inode, struct file *file)
 	}
 
 	if (i == ARRAY_SIZE(socket_client_hash)) {
-		pr_err("Error - can't add another packet client: "
-		       "maximum number of clients reached\n");
+		pr_err("Error - can't add another packet client: maximum number of clients reached\n");
 		kfree(socket_client);
 		return -EXFULL;
 	}
@@ -162,8 +161,7 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 
 	if (len < sizeof(struct icmp_packet)) {
 		bat_dbg(DBG_BATMAN, bat_priv,
-			"Error - can't send packet from char device: "
-			"invalid packet size\n");
+			"Error - can't send packet from char device: invalid packet size\n");
 		return -EINVAL;
 	}
 
@@ -193,16 +191,14 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 
 	if (icmp_packet->header.packet_type != BAT_ICMP) {
 		bat_dbg(DBG_BATMAN, bat_priv,
-			"Error - can't send packet from char device: "
-			"got bogus packet type (expected: BAT_ICMP)\n");
+			"Error - can't send packet from char device: got bogus packet type (expected: BAT_ICMP)\n");
 		len = -EINVAL;
 		goto free_skb;
 	}
 
 	if (icmp_packet->msg_type != ECHO_REQUEST) {
 		bat_dbg(DBG_BATMAN, bat_priv,
-			"Error - can't send packet from char device: "
-			"got bogus message type (expected: ECHO_REQUEST)\n");
+			"Error - can't send packet from char device: got bogus message type (expected: ECHO_REQUEST)\n");
 		len = -EINVAL;
 		goto free_skb;
 	}
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 08f3b3a..6d51caa 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -64,8 +64,8 @@ static int __init batman_init(void)
 
 	register_netdevice_notifier(&hard_if_notifier);
 
-	pr_info("B.A.T.M.A.N. advanced %s (compatibility version %i) "
-		"loaded\n", SOURCE_VERSION, COMPAT_VERSION);
+	pr_info("B.A.T.M.A.N. advanced %s (compatibility version %i) loaded\n",
+		SOURCE_VERSION, COMPAT_VERSION);
 
 	return 0;
 }
@@ -201,8 +201,8 @@ int bat_algo_register(struct bat_algo_ops *bat_algo_ops)
 
 	bat_algo_ops_tmp = bat_algo_get(bat_algo_ops->name);
 	if (bat_algo_ops_tmp) {
-		pr_info("Trying to register already registered routing "
-			"algorithm: %s\n", bat_algo_ops->name);
+		pr_info("Trying to register already registered routing algorithm: %s\n",
+			bat_algo_ops->name);
 		goto out;
 	}
 
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 371cc93..43c0a4f 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -294,14 +294,12 @@ static bool purge_orig_neighbors(struct bat_priv *bat_priv,
 			    (neigh_node->if_incoming->if_status ==
 							IF_TO_BE_REMOVED))
 				bat_dbg(DBG_BATMAN, bat_priv,
-					"neighbor purge: originator %pM, "
-					"neighbor: %pM, iface: %s\n",
+					"neighbor purge: originator %pM, neighbor: %pM, iface: %s\n",
 					orig_node->orig, neigh_node->addr,
 					neigh_node->if_incoming->net_dev->name);
 			else
 				bat_dbg(DBG_BATMAN, bat_priv,
-					"neighbor timeout: originator %pM, "
-					"neighbor: %pM, last_valid: %lu\n",
+					"neighbor timeout: originator %pM, neighbor: %pM, last_valid: %lu\n",
 					orig_node->orig, neigh_node->addr,
 					(neigh_node->last_valid / HZ));
 
@@ -416,15 +414,15 @@ int orig_seq_print_text(struct seq_file *seq, void *offset)
 	primary_if = primary_if_get_selected(bat_priv);
 
 	if (!primary_if) {
-		ret = seq_printf(seq, "BATMAN mesh %s disabled - "
-				 "please specify interfaces to enable it\n",
+		ret = seq_printf(seq,
+				 "BATMAN mesh %s disabled - please specify interfaces to enable it\n",
 				 net_dev->name);
 		goto out;
 	}
 
 	if (primary_if->if_status != IF_ACTIVE) {
-		ret = seq_printf(seq, "BATMAN mesh %s "
-				 "disabled - primary interface not active\n",
+		ret = seq_printf(seq,
+				 "BATMAN mesh %s disabled - primary interface not active\n",
 				 net_dev->name);
 		goto out;
 	}
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index f535155..01b66d4 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -83,8 +83,7 @@ static void _update_route(struct bat_priv *bat_priv,
 	/* route changed */
 	} else if (neigh_node && curr_router) {
 		bat_dbg(DBG_ROUTES, bat_priv,
-			"Changing route towards: %pM "
-			"(now via %pM - was via %pM)\n",
+			"Changing route towards: %pM (now via %pM - was via %pM)\n",
 			orig_node->orig, neigh_node->addr,
 			curr_router->addr);
 	}
@@ -345,9 +344,8 @@ static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
 
 	/* send TTL exceeded if packet is an echo request (traceroute) */
 	if (icmp_packet->msg_type != ECHO_REQUEST) {
-		pr_debug("Warning - can't forward icmp packet from %pM to "
-			 "%pM: ttl exceeded\n", icmp_packet->orig,
-			 icmp_packet->dst);
+		pr_debug("Warning - can't forward icmp packet from %pM to %pM: ttl exceeded\n",
+			 icmp_packet->orig, icmp_packet->dst);
 		goto out;
 	}
 
@@ -674,9 +672,9 @@ int recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_if)
 	if (!orig_node)
 		goto out;
 
-	bat_dbg(DBG_TT, bat_priv, "Received ROAMING_ADV from %pM "
-		"(client %pM)\n", roam_adv_packet->src,
-		roam_adv_packet->client);
+	bat_dbg(DBG_TT, bat_priv,
+		"Received ROAMING_ADV from %pM (client %pM)\n",
+		roam_adv_packet->src, roam_adv_packet->client);
 
 	tt_global_add(bat_priv, orig_node, roam_adv_packet->client,
 		      atomic_read(&orig_node->last_ttvn) + 1, true, false);
@@ -813,9 +811,8 @@ int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 
 	/* TTL exceeded */
 	if (unicast_packet->header.ttl < 2) {
-		pr_debug("Warning - can't forward unicast packet from %pM to "
-			 "%pM: ttl exceeded\n", ethhdr->h_source,
-			 unicast_packet->dest);
+		pr_debug("Warning - can't forward unicast packet from %pM to %pM: ttl exceeded\n",
+			 ethhdr->h_source, unicast_packet->dest);
 		goto out;
 	}
 
@@ -934,10 +931,10 @@ static int check_unicast_ttvn(struct bat_priv *bat_priv,
 			orig_node_free_ref(orig_node);
 		}
 
-		bat_dbg(DBG_ROUTES, bat_priv, "TTVN mismatch (old_ttvn %u "
-			"new_ttvn %u)! Rerouting unicast packet (for %pM) to "
-			"%pM\n", unicast_packet->ttvn, curr_ttvn,
-			ethhdr->h_dest, unicast_packet->dest);
+		bat_dbg(DBG_ROUTES, bat_priv,
+			"TTVN mismatch (old_ttvn %u new_ttvn %u)! Rerouting unicast packet (for %pM) to %pM\n",
+			unicast_packet->ttvn, curr_ttvn, ethhdr->h_dest,
+			unicast_packet->dest);
 
 		unicast_packet->ttvn = curr_ttvn;
 	}
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 4137580..f261ccf 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -45,8 +45,8 @@ int send_skb_packet(struct sk_buff *skb, struct hard_iface *hard_iface,
 		goto send_skb_err;
 
 	if (!(hard_iface->net_dev->flags & IFF_UP)) {
-		pr_warning("Interface %s is not up - can't send packet via "
-			   "that interface!\n", hard_iface->net_dev->name);
+		pr_warning("Interface %s is not up - can't send packet via that interface!\n",
+			   hard_iface->net_dev->name);
 		goto send_skb_err;
 	}
 
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 8fb16d2..a5590f4 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -252,8 +252,8 @@ static void softif_neigh_vid_select(struct bat_priv *bat_priv,
 			vid, curr_neigh->addr);
 	else if ((curr_neigh) && (new_neigh))
 		bat_dbg(DBG_ROUTES, bat_priv,
-			"Changing mesh exit point on vid: %d from %pM "
-			"to %pM.\n", vid, curr_neigh->addr, new_neigh->addr);
+			"Changing mesh exit point on vid: %d from %pM to %pM.\n",
+			vid, curr_neigh->addr, new_neigh->addr);
 	else if ((!curr_neigh) && (new_neigh))
 		bat_dbg(DBG_ROUTES, bat_priv,
 			"Setting mesh exit point on vid: %d to %pM.\n",
@@ -327,15 +327,15 @@ int softif_neigh_seq_print_text(struct seq_file *seq, void *offset)
 
 	primary_if = primary_if_get_selected(bat_priv);
 	if (!primary_if) {
-		ret = seq_printf(seq, "BATMAN mesh %s disabled - "
-				 "please specify interfaces to enable it\n",
+		ret = seq_printf(seq,
+				 "BATMAN mesh %s disabled - please specify interfaces to enable it\n",
 				 net_dev->name);
 		goto out;
 	}
 
 	if (primary_if->if_status != IF_ACTIVE) {
-		ret = seq_printf(seq, "BATMAN mesh %s "
-				 "disabled - primary interface not active\n",
+		ret = seq_printf(seq,
+				 "BATMAN mesh %s disabled - primary interface not active\n",
 				 net_dev->name);
 		goto out;
 	}
@@ -403,8 +403,7 @@ void softif_neigh_purge(struct bat_priv *bat_priv)
 
 			if (curr_softif_neigh == softif_neigh) {
 				bat_dbg(DBG_ROUTES, bat_priv,
-					"Current mesh exit point on vid: %d "
-					"'%pM' vanished.\n",
+					"Current mesh exit point on vid: %d '%pM' vanished.\n",
 					softif_neigh_vid->vid,
 					softif_neigh->addr);
 				do_deselect = 1;
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index c950705..1f86921 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -309,21 +309,21 @@ int tt_local_seq_print_text(struct seq_file *seq, void *offset)
 
 	primary_if = primary_if_get_selected(bat_priv);
 	if (!primary_if) {
-		ret = seq_printf(seq, "BATMAN mesh %s disabled - "
-				 "please specify interfaces to enable it\n",
+		ret = seq_printf(seq,
+				 "BATMAN mesh %s disabled - please specify interfaces to enable it\n",
 				 net_dev->name);
 		goto out;
 	}
 
 	if (primary_if->if_status != IF_ACTIVE) {
-		ret = seq_printf(seq, "BATMAN mesh %s disabled - "
-				 "primary interface not active\n",
+		ret = seq_printf(seq,
+				 "BATMAN mesh %s disabled - primary interface not active\n",
 				 net_dev->name);
 		goto out;
 	}
 
-	seq_printf(seq, "Locally retrieved addresses (from %s) "
-		   "announced via TT (TTVN: %u):\n",
+	seq_printf(seq,
+		   "Locally retrieved addresses (from %s) announced via TT (TTVN: %u):\n",
 		   net_dev->name, (uint8_t)atomic_read(&bat_priv->ttvn));
 
 	for (i = 0; i < hash->size; i++) {
@@ -365,8 +365,9 @@ static void tt_local_set_pending(struct bat_priv *bat_priv,
 	 * response issued before the net ttvn increment (consistency check) */
 	tt_local_entry->common.flags |= TT_CLIENT_PENDING;
 
-	bat_dbg(DBG_TT, bat_priv, "Local tt entry (%pM) pending to be removed: "
-		"%s\n", tt_local_entry->common.addr, message);
+	bat_dbg(DBG_TT, bat_priv,
+		"Local tt entry (%pM) pending to be removed: %s\n",
+		tt_local_entry->common.addr, message);
 }
 
 void tt_local_remove(struct bat_priv *bat_priv, const uint8_t *addr,
@@ -574,15 +575,15 @@ int tt_global_seq_print_text(struct seq_file *seq, void *offset)
 
 	primary_if = primary_if_get_selected(bat_priv);
 	if (!primary_if) {
-		ret = seq_printf(seq, "BATMAN mesh %s disabled - please "
-				 "specify interfaces to enable it\n",
+		ret = seq_printf(seq,
+				 "BATMAN mesh %s disabled - please specify interfaces to enable it\n",
 				 net_dev->name);
 		goto out;
 	}
 
 	if (primary_if->if_status != IF_ACTIVE) {
-		ret = seq_printf(seq, "BATMAN mesh %s disabled - "
-				 "primary interface not active\n",
+		ret = seq_printf(seq,
+				 "BATMAN mesh %s disabled - primary interface not active\n",
 				 net_dev->name);
 		goto out;
 	}
@@ -602,18 +603,18 @@ int tt_global_seq_print_text(struct seq_file *seq, void *offset)
 			tt_global_entry = container_of(tt_common_entry,
 						       struct tt_global_entry,
 						       common);
-			seq_printf(seq, " * %pM  (%3u) via %pM     (%3u)   "
-					"[%c%c]\n",
-					tt_global_entry->common.addr,
-					tt_global_entry->ttvn,
-					tt_global_entry->orig_node->orig,
-					(uint8_t) atomic_read(
+			seq_printf(seq,
+				   " * %pM  (%3u) via %pM     (%3u)   [%c%c]\n",
+				   tt_global_entry->common.addr,
+				   tt_global_entry->ttvn,
+				   tt_global_entry->orig_node->orig,
+				   (uint8_t) atomic_read(
 						&tt_global_entry->orig_node->
 						last_ttvn),
-					(tt_global_entry->common.flags &
-					 TT_CLIENT_ROAM ? 'R' : '.'),
-					(tt_global_entry->common.flags &
-					 TT_CLIENT_WIFI ? 'W' : '.'));
+				   (tt_global_entry->common.flags &
+				    TT_CLIENT_ROAM ? 'R' : '.'),
+				   (tt_global_entry->common.flags &
+				    TT_CLIENT_WIFI ? 'W' : '.'));
 		}
 		rcu_read_unlock();
 	}
@@ -710,8 +711,7 @@ void tt_global_del_orig(struct bat_priv *bat_priv,
 						       common);
 			if (tt_global_entry->orig_node == orig_node) {
 				bat_dbg(DBG_TT, bat_priv,
-					"Deleting global tt entry %pM "
-					"(via %pM): %s\n",
+					"Deleting global tt entry %pM (via %pM): %s\n",
 					tt_global_entry->common.addr,
 					tt_global_entry->orig_node->orig,
 					message);
@@ -751,8 +751,8 @@ static void tt_global_roam_purge(struct bat_priv *bat_priv)
 					   TT_CLIENT_ROAM_TIMEOUT))
 				continue;
 
-			bat_dbg(DBG_TT, bat_priv, "Deleting global "
-				"tt entry (%pM): Roaming timeout\n",
+			bat_dbg(DBG_TT, bat_priv,
+				"Deleting global tt entry (%pM): Roaming timeout\n",
 				tt_global_entry->common.addr);
 			atomic_dec(&tt_global_entry->orig_node->tt_size);
 			hlist_del_rcu(node);
@@ -1134,8 +1134,9 @@ static int send_tt_request(struct bat_priv *bat_priv,
 	if (!neigh_node)
 		goto out;
 
-	bat_dbg(DBG_TT, bat_priv, "Sending TT_REQUEST to %pM via %pM "
-		"[%c]\n", dst_orig_node->orig, neigh_node->addr,
+	bat_dbg(DBG_TT, bat_priv,
+		"Sending TT_REQUEST to %pM via %pM [%c]\n",
+		dst_orig_node->orig, neigh_node->addr,
 		(full_table ? 'F' : '.'));
 
 	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
@@ -1172,9 +1173,8 @@ static bool send_other_tt_response(struct bat_priv *bat_priv,
 	struct tt_query_packet *tt_response;
 
 	bat_dbg(DBG_TT, bat_priv,
-		"Received TT_REQUEST from %pM for "
-		"ttvn: %u (%pM) [%c]\n", tt_request->src,
-		tt_request->ttvn, tt_request->dst,
+		"Received TT_REQUEST from %pM for ttvn: %u (%pM) [%c]\n",
+		tt_request->src, tt_request->ttvn, tt_request->dst,
 		(tt_request->flags & TT_FULL_TABLE ? 'F' : '.'));
 
 	/* Let's get the orig node of the REAL destination */
@@ -1299,9 +1299,8 @@ static bool send_my_tt_response(struct bat_priv *bat_priv,
 	struct tt_query_packet *tt_response;
 
 	bat_dbg(DBG_TT, bat_priv,
-		"Received TT_REQUEST from %pM for "
-		"ttvn: %u (me) [%c]\n", tt_request->src,
-		tt_request->ttvn,
+		"Received TT_REQUEST from %pM for ttvn: %u (me) [%c]\n",
+		tt_request->src, tt_request->ttvn,
 		(tt_request->flags & TT_FULL_TABLE ? 'F' : '.'));
 
 
@@ -1504,10 +1503,9 @@ void handle_tt_response(struct bat_priv *bat_priv,
 	struct tt_req_node *node, *safe;
 	struct orig_node *orig_node = NULL;
 
-	bat_dbg(DBG_TT, bat_priv, "Received TT_RESPONSE from %pM for "
-		"ttvn %d t_size: %d [%c]\n",
-		tt_response->src, tt_response->ttvn,
-		tt_response->tt_data,
+	bat_dbg(DBG_TT, bat_priv,
+		"Received TT_RESPONSE from %pM for ttvn %d t_size: %d [%c]\n",
+		tt_response->src, tt_response->ttvn, tt_response->tt_data,
 		(tt_response->flags & TT_FULL_TABLE ? 'F' : '.'));
 
 	orig_node = orig_hash_find(bat_priv, tt_response->src);
@@ -1771,8 +1769,9 @@ static void tt_local_purge_pending_clients(struct bat_priv *bat_priv)
 			if (!(tt_common_entry->flags & TT_CLIENT_PENDING))
 				continue;
 
-			bat_dbg(DBG_TT, bat_priv, "Deleting local tt entry "
-				"(%pM): pending\n", tt_common_entry->addr);
+			bat_dbg(DBG_TT, bat_priv,
+				"Deleting local tt entry (%pM): pending\n",
+				tt_common_entry->addr);
 
 			atomic_dec(&bat_priv->num_local_tt);
 			hlist_del_rcu(node);
@@ -1877,12 +1876,10 @@ void tt_update_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
 		if (!orig_node->tt_initialised || ttvn != orig_ttvn ||
 		    orig_node->tt_crc != tt_crc) {
 request_table:
-			bat_dbg(DBG_TT, bat_priv, "TT inconsistency for %pM. "
-				"Need to retrieve the correct information "
-				"(ttvn: %u last_ttvn: %u crc: %u last_crc: "
-				"%u num_changes: %u)\n", orig_node->orig, ttvn,
-				orig_ttvn, tt_crc, orig_node->tt_crc,
-				tt_num_changes);
+			bat_dbg(DBG_TT, bat_priv,
+				"TT inconsistency for %pM. Need to retrieve the correct information (ttvn: %u last_ttvn: %u crc: %u last_crc: %u num_changes: %u)\n",
+				orig_node->orig, ttvn, orig_ttvn, tt_crc,
+				orig_node->tt_crc, tt_num_changes);
 			send_tt_request(bat_priv, orig_node, ttvn, tt_crc,
 					full_table);
 			return;
-- 
1.7.9.1
