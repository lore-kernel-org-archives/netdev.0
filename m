From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 08/20] batman-adv: Prefix bat_iv_ogm local static functions with batadv_
Date: Mon, 25 Jun 2012 08:54:32 +0200
Message-ID: <1340607284-29950-9-git-send-email-ordex@autistici.org>
References: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:30470 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754678Ab2FYGyq (ORCPT
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
 net/batman-adv/bat_iv_ogm.c |  257 ++++++++++++++++++++++---------------------
 1 file changed, 130 insertions(+), 127 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 025df7c..ca64665 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -28,11 +28,11 @@
 #include "send.h"
 #include "bat_algo.h"
 
-static struct neigh_node *bat_iv_ogm_neigh_new(struct hard_iface *hard_iface,
-					       const uint8_t *neigh_addr,
-					       struct orig_node *orig_node,
-					       struct orig_node *orig_neigh,
-					       __be32 seqno)
+static struct neigh_node *batadv_iv_ogm_neigh_new(struct hard_iface *hard_iface,
+						  const uint8_t *neigh_addr,
+						  struct orig_node *orig_node,
+						  struct orig_node *orig_neigh,
+						  __be32 seqno)
 {
 	struct neigh_node *neigh_node;
 
@@ -54,7 +54,7 @@ out:
 	return neigh_node;
 }
 
-static int bat_iv_ogm_iface_enable(struct hard_iface *hard_iface)
+static int batadv_iv_ogm_iface_enable(struct hard_iface *hard_iface)
 {
 	struct batman_ogm_packet *batman_ogm_packet;
 	uint32_t random_seqno;
@@ -85,13 +85,13 @@ out:
 	return res;
 }
 
-static void bat_iv_ogm_iface_disable(struct hard_iface *hard_iface)
+static void batadv_iv_ogm_iface_disable(struct hard_iface *hard_iface)
 {
 	kfree(hard_iface->packet_buff);
 	hard_iface->packet_buff = NULL;
 }
 
-static void bat_iv_ogm_iface_update_mac(struct hard_iface *hard_iface)
+static void batadv_iv_ogm_iface_update_mac(struct hard_iface *hard_iface)
 {
 	struct batman_ogm_packet *batman_ogm_packet;
 
@@ -102,7 +102,7 @@ static void bat_iv_ogm_iface_update_mac(struct hard_iface *hard_iface)
 	       hard_iface->net_dev->dev_addr, ETH_ALEN);
 }
 
-static void bat_iv_ogm_primary_iface_set(struct hard_iface *hard_iface)
+static void batadv_iv_ogm_primary_iface_set(struct hard_iface *hard_iface)
 {
 	struct batman_ogm_packet *batman_ogm_packet;
 
@@ -112,7 +112,8 @@ static void bat_iv_ogm_primary_iface_set(struct hard_iface *hard_iface)
 }
 
 /* when do we schedule our own ogm to be sent */
-static unsigned long bat_iv_ogm_emit_send_time(const struct bat_priv *bat_priv)
+static unsigned long
+batadv_iv_ogm_emit_send_time(const struct bat_priv *bat_priv)
 {
 	return jiffies + msecs_to_jiffies(
 		   atomic_read(&bat_priv->orig_interval) -
@@ -120,21 +121,21 @@ static unsigned long bat_iv_ogm_emit_send_time(const struct bat_priv *bat_priv)
 }
 
 /* when do we schedule a ogm packet to be sent */
-static unsigned long bat_iv_ogm_fwd_send_time(void)
+static unsigned long batadv_iv_ogm_fwd_send_time(void)
 {
 	return jiffies + msecs_to_jiffies(random32() % (JITTER/2));
 }
 
 /* apply hop penalty for a normal link */
-static uint8_t hop_penalty(uint8_t tq, const struct bat_priv *bat_priv)
+static uint8_t batadv_hop_penalty(uint8_t tq, const struct bat_priv *bat_priv)
 {
 	int hop_penalty = atomic_read(&bat_priv->hop_penalty);
 	return (tq * (TQ_MAX_VALUE - hop_penalty)) / (TQ_MAX_VALUE);
 }
 
 /* is there another aggregated packet here? */
-static int bat_iv_ogm_aggr_packet(int buff_pos, int packet_len,
-				  int tt_num_changes)
+static int batadv_iv_ogm_aggr_packet(int buff_pos, int packet_len,
+				     int tt_num_changes)
 {
 	int next_buff_pos = 0;
 
@@ -146,7 +147,7 @@ static int bat_iv_ogm_aggr_packet(int buff_pos, int packet_len,
 }
 
 /* send a batman ogm to a given interface */
-static void bat_iv_ogm_send_to_if(struct forw_packet *forw_packet,
+static void batadv_iv_ogm_send_to_if(struct forw_packet *forw_packet,
 				  struct hard_iface *hard_iface)
 {
 	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
@@ -164,8 +165,8 @@ static void bat_iv_ogm_send_to_if(struct forw_packet *forw_packet,
 	batman_ogm_packet = (struct batman_ogm_packet *)forw_packet->skb->data;
 
 	/* adjust all flags and log packets */
-	while (bat_iv_ogm_aggr_packet(buff_pos, forw_packet->packet_len,
-				      batman_ogm_packet->tt_num_changes)) {
+	while (batadv_iv_ogm_aggr_packet(buff_pos, forw_packet->packet_len,
+					 batman_ogm_packet->tt_num_changes)) {
 
 		/* we might have aggregated direct link packets with an
 		 * ordinary base packet
@@ -208,7 +209,7 @@ static void bat_iv_ogm_send_to_if(struct forw_packet *forw_packet,
 }
 
 /* send a batman ogm packet */
-static void bat_iv_ogm_emit(struct forw_packet *forw_packet)
+static void batadv_iv_ogm_emit(struct forw_packet *forw_packet)
 {
 	struct hard_iface *hard_iface;
 	struct net_device *soft_iface;
@@ -267,7 +268,7 @@ static void bat_iv_ogm_emit(struct forw_packet *forw_packet)
 		if (hard_iface->soft_iface != soft_iface)
 			continue;
 
-		bat_iv_ogm_send_to_if(forw_packet, hard_iface);
+		batadv_iv_ogm_send_to_if(forw_packet, hard_iface);
 	}
 	rcu_read_unlock();
 
@@ -277,13 +278,13 @@ out:
 }
 
 /* return true if new_packet can be aggregated with forw_packet */
-static bool bat_iv_ogm_can_aggregate(const struct batman_ogm_packet
-							*new_batman_ogm_packet,
-				     struct bat_priv *bat_priv,
-				     int packet_len, unsigned long send_time,
-				     bool directlink,
-				     const struct hard_iface *if_incoming,
-				     const struct forw_packet *forw_packet)
+static bool
+batadv_iv_ogm_can_aggregate(const struct batman_ogm_packet *new_bat_ogm_packet,
+			    struct bat_priv *bat_priv,
+			    int packet_len, unsigned long send_time,
+			    bool directlink,
+			    const struct hard_iface *if_incoming,
+			    const struct forw_packet *forw_packet)
 {
 	struct batman_ogm_packet *batman_ogm_packet;
 	int aggregated_bytes = forw_packet->packet_len + packet_len;
@@ -335,7 +336,7 @@ static bool bat_iv_ogm_can_aggregate(const struct batman_ogm_packet
 		 * interface only - we still can aggregate
 		 */
 		if ((directlink) &&
-		    (new_batman_ogm_packet->header.ttl == 1) &&
+		    (new_bat_ogm_packet->header.ttl == 1) &&
 		    (forw_packet->if_incoming == if_incoming) &&
 
 		    /* packets from direct neighbors or
@@ -357,11 +358,11 @@ out:
 }
 
 /* create a new aggregated packet and add this packet to it */
-static void bat_iv_ogm_aggregate_new(const unsigned char *packet_buff,
-				     int packet_len, unsigned long send_time,
-				     bool direct_link,
-				     struct hard_iface *if_incoming,
-				     int own_packet)
+static void batadv_iv_ogm_aggregate_new(const unsigned char *packet_buff,
+					int packet_len, unsigned long send_time,
+					bool direct_link,
+					struct hard_iface *if_incoming,
+					int own_packet)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct forw_packet *forw_packet_aggr;
@@ -435,9 +436,9 @@ out:
 }
 
 /* aggregate a new packet into the existing ogm packet */
-static void bat_iv_ogm_aggregate(struct forw_packet *forw_packet_aggr,
-				 const unsigned char *packet_buff,
-				 int packet_len, bool direct_link)
+static void batadv_iv_ogm_aggregate(struct forw_packet *forw_packet_aggr,
+				    const unsigned char *packet_buff,
+				    int packet_len, bool direct_link)
 {
 	unsigned char *skb_buff;
 
@@ -452,10 +453,11 @@ static void bat_iv_ogm_aggregate(struct forw_packet *forw_packet_aggr,
 			(1 << forw_packet_aggr->num_packets);
 }
 
-static void bat_iv_ogm_queue_add(struct bat_priv *bat_priv,
-				 unsigned char *packet_buff,
-				 int packet_len, struct hard_iface *if_incoming,
-				 int own_packet, unsigned long send_time)
+static void batadv_iv_ogm_queue_add(struct bat_priv *bat_priv,
+				    unsigned char *packet_buff,
+				    int packet_len,
+				    struct hard_iface *if_incoming,
+				    int own_packet, unsigned long send_time)
 {
 	/* _aggr -> pointer to the packet we want to aggregate with
 	 * _pos -> pointer to the position in the queue
@@ -474,11 +476,11 @@ static void bat_iv_ogm_queue_add(struct bat_priv *bat_priv,
 	if ((atomic_read(&bat_priv->aggregated_ogms)) && (!own_packet)) {
 		hlist_for_each_entry(forw_packet_pos, tmp_node,
 				     &bat_priv->forw_bat_list, list) {
-			if (bat_iv_ogm_can_aggregate(batman_ogm_packet,
-						     bat_priv, packet_len,
-						     send_time, direct_link,
-						     if_incoming,
-						     forw_packet_pos)) {
+			if (batadv_iv_ogm_can_aggregate(batman_ogm_packet,
+							bat_priv, packet_len,
+							send_time, direct_link,
+							if_incoming,
+							forw_packet_pos)) {
 				forw_packet_aggr = forw_packet_pos;
 				break;
 			}
@@ -500,22 +502,22 @@ static void bat_iv_ogm_queue_add(struct bat_priv *bat_priv,
 		    (atomic_read(&bat_priv->aggregated_ogms)))
 			send_time += msecs_to_jiffies(MAX_AGGREGATION_MS);
 
-		bat_iv_ogm_aggregate_new(packet_buff, packet_len,
-					 send_time, direct_link,
-					 if_incoming, own_packet);
+		batadv_iv_ogm_aggregate_new(packet_buff, packet_len,
+					    send_time, direct_link,
+					    if_incoming, own_packet);
 	} else {
-		bat_iv_ogm_aggregate(forw_packet_aggr, packet_buff,
-				     packet_len, direct_link);
+		batadv_iv_ogm_aggregate(forw_packet_aggr, packet_buff,
+					packet_len, direct_link);
 		spin_unlock_bh(&bat_priv->forw_bat_list_lock);
 	}
 }
 
-static void bat_iv_ogm_forward(struct orig_node *orig_node,
-			       const struct ethhdr *ethhdr,
-			       struct batman_ogm_packet *batman_ogm_packet,
-			       bool is_single_hop_neigh,
-			       bool is_from_best_next_hop,
-			       struct hard_iface *if_incoming)
+static void batadv_iv_ogm_forward(struct orig_node *orig_node,
+				  const struct ethhdr *ethhdr,
+				  struct batman_ogm_packet *batman_ogm_packet,
+				  bool is_single_hop_neigh,
+				  bool is_from_best_next_hop,
+				  struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	uint8_t tt_num_changes;
@@ -544,7 +546,8 @@ static void bat_iv_ogm_forward(struct orig_node *orig_node,
 	memcpy(batman_ogm_packet->prev_sender, ethhdr->h_source, ETH_ALEN);
 
 	/* apply hop penalty */
-	batman_ogm_packet->tq = hop_penalty(batman_ogm_packet->tq, bat_priv);
+	batman_ogm_packet->tq = batadv_hop_penalty(batman_ogm_packet->tq,
+						   bat_priv);
 
 	batadv_dbg(DBG_BATMAN, bat_priv,
 		   "Forwarding packet: tq: %i, ttl: %i\n",
@@ -557,12 +560,12 @@ static void bat_iv_ogm_forward(struct orig_node *orig_node,
 	else
 		batman_ogm_packet->flags &= ~DIRECTLINK;
 
-	bat_iv_ogm_queue_add(bat_priv, (unsigned char *)batman_ogm_packet,
-			     BATMAN_OGM_HLEN + batadv_tt_len(tt_num_changes),
-			     if_incoming, 0, bat_iv_ogm_fwd_send_time());
+	batadv_iv_ogm_queue_add(bat_priv, (unsigned char *)batman_ogm_packet,
+				BATMAN_OGM_HLEN + batadv_tt_len(tt_num_changes),
+				if_incoming, 0, batadv_iv_ogm_fwd_send_time());
 }
 
-static void bat_iv_ogm_schedule(struct hard_iface *hard_iface)
+static void batadv_iv_ogm_schedule(struct hard_iface *hard_iface)
 {
 	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	struct batman_ogm_packet *batman_ogm_packet;
@@ -603,22 +606,22 @@ static void bat_iv_ogm_schedule(struct hard_iface *hard_iface)
 		batman_ogm_packet->gw_flags = NO_FLAGS;
 
 	batadv_slide_own_bcast_window(hard_iface);
-	bat_iv_ogm_queue_add(bat_priv, hard_iface->packet_buff,
-			     hard_iface->packet_len, hard_iface, 1,
-			     bat_iv_ogm_emit_send_time(bat_priv));
+	batadv_iv_ogm_queue_add(bat_priv, hard_iface->packet_buff,
+				hard_iface->packet_len, hard_iface, 1,
+				batadv_iv_ogm_emit_send_time(bat_priv));
 
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
 }
 
-static void bat_iv_ogm_orig_update(struct bat_priv *bat_priv,
-				   struct orig_node *orig_node,
-				   const struct ethhdr *ethhdr,
-				   const struct batman_ogm_packet
-							*batman_ogm_packet,
-				   struct hard_iface *if_incoming,
-				   const unsigned char *tt_buff,
-				   int is_duplicate)
+static void
+batadv_iv_ogm_orig_update(struct bat_priv *bat_priv,
+			  struct orig_node *orig_node,
+			  const struct ethhdr *ethhdr,
+			  const struct batman_ogm_packet *batman_ogm_packet,
+			  struct hard_iface *if_incoming,
+			  const unsigned char *tt_buff,
+			  int is_duplicate)
 {
 	struct neigh_node *neigh_node = NULL, *tmp_neigh_node = NULL;
 	struct neigh_node *router = NULL;
@@ -661,9 +664,10 @@ static void bat_iv_ogm_orig_update(struct bat_priv *bat_priv,
 		if (!orig_tmp)
 			goto unlock;
 
-		neigh_node = bat_iv_ogm_neigh_new(if_incoming, ethhdr->h_source,
-						  orig_node, orig_tmp,
-						  batman_ogm_packet->seqno);
+		neigh_node = batadv_iv_ogm_neigh_new(if_incoming,
+						     ethhdr->h_source,
+						     orig_node, orig_tmp,
+						     batman_ogm_packet->seqno);
 
 		batadv_orig_node_free_ref(orig_tmp);
 		if (!neigh_node)
@@ -759,10 +763,10 @@ out:
 		batadv_neigh_node_free_ref(router);
 }
 
-static int bat_iv_ogm_calc_tq(struct orig_node *orig_node,
-			      struct orig_node *orig_neigh_node,
-			      struct batman_ogm_packet *batman_ogm_packet,
-			      struct hard_iface *if_incoming)
+static int batadv_iv_ogm_calc_tq(struct orig_node *orig_node,
+				 struct orig_node *orig_neigh_node,
+				 struct batman_ogm_packet *batman_ogm_packet,
+				 struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct neigh_node *neigh_node = NULL, *tmp_neigh_node;
@@ -792,11 +796,11 @@ static int bat_iv_ogm_calc_tq(struct orig_node *orig_node,
 	rcu_read_unlock();
 
 	if (!neigh_node)
-		neigh_node = bat_iv_ogm_neigh_new(if_incoming,
-						  orig_neigh_node->orig,
-						  orig_neigh_node,
-						  orig_neigh_node,
-						  batman_ogm_packet->seqno);
+		neigh_node = batadv_iv_ogm_neigh_new(if_incoming,
+						     orig_neigh_node->orig,
+						     orig_neigh_node,
+						     orig_neigh_node,
+						     batman_ogm_packet->seqno);
 
 	if (!neigh_node)
 		goto out;
@@ -873,10 +877,10 @@ out:
  *  -1 the packet is old and has been received while the seqno window
  *     was protected. Caller should drop it.
  */
-static int bat_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
-				    const struct batman_ogm_packet
-							*batman_ogm_packet,
-				    const struct hard_iface *if_incoming)
+static int
+batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
+			    const struct batman_ogm_packet *batman_ogm_packet,
+			    const struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct orig_node *orig_node;
@@ -943,10 +947,10 @@ out:
 	return ret;
 }
 
-static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
-			       struct batman_ogm_packet *batman_ogm_packet,
-			       const unsigned char *tt_buff,
-			       struct hard_iface *if_incoming)
+static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
+				  struct batman_ogm_packet *batman_ogm_packet,
+				  const unsigned char *tt_buff,
+				  struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct hard_iface *hard_iface;
@@ -955,10 +959,10 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	struct neigh_node *orig_neigh_router = NULL;
 	int has_directlink_flag;
 	int is_my_addr = 0, is_my_orig = 0, is_my_oldorig = 0;
-	int is_broadcast = 0, is_bidirectional;
+	int is_broadcast = 0, is_bidirect;
 	bool is_single_hop_neigh = false;
 	bool is_from_best_next_hop = false;
-	int is_duplicate;
+	int is_duplicate, sameseq, simlar_ttl;
 	uint32_t if_incoming_seqno;
 	uint8_t *prev_sender;
 
@@ -1095,8 +1099,8 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	if (!orig_node)
 		return;
 
-	is_duplicate = bat_iv_ogm_update_seqnos(ethhdr, batman_ogm_packet,
-						if_incoming);
+	is_duplicate = batadv_iv_ogm_update_seqnos(ethhdr, batman_ogm_packet,
+						   if_incoming);
 
 	if (is_duplicate == -1) {
 		batadv_dbg(DBG_BATMAN, bat_priv,
@@ -1151,8 +1155,8 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 		goto out_neigh;
 	}
 
-	is_bidirectional = bat_iv_ogm_calc_tq(orig_node, orig_neigh_node,
-					      batman_ogm_packet, if_incoming);
+	is_bidirect = batadv_iv_ogm_calc_tq(orig_node, orig_neigh_node,
+					    batman_ogm_packet, if_incoming);
 
 	batadv_bonding_save_primary(orig_node, orig_neigh_node,
 				    batman_ogm_packet);
@@ -1160,21 +1164,20 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	/* update ranking if it is not a duplicate or has the same
 	 * seqno and similar ttl as the non-duplicate
 	 */
-	if (is_bidirectional &&
-	    (!is_duplicate ||
-	     ((orig_node->last_real_seqno == ntohl(batman_ogm_packet->seqno)) &&
-	      (orig_node->last_ttl - 3 <= batman_ogm_packet->header.ttl))))
-		bat_iv_ogm_orig_update(bat_priv, orig_node, ethhdr,
-				       batman_ogm_packet, if_incoming,
-				       tt_buff, is_duplicate);
+	sameseq = orig_node->last_real_seqno == ntohl(batman_ogm_packet->seqno);
+	simlar_ttl = orig_node->last_ttl - 3 <= batman_ogm_packet->header.ttl;
+	if (is_bidirect && (!is_duplicate || (sameseq && simlar_ttl)))
+		batadv_iv_ogm_orig_update(bat_priv, orig_node, ethhdr,
+					  batman_ogm_packet, if_incoming,
+					  tt_buff, is_duplicate);
 
 	/* is single hop (direct) neighbor */
 	if (is_single_hop_neigh) {
 
 		/* mark direct link on incoming interface */
-		bat_iv_ogm_forward(orig_node, ethhdr, batman_ogm_packet,
-				   is_single_hop_neigh, is_from_best_next_hop,
-				   if_incoming);
+		batadv_iv_ogm_forward(orig_node, ethhdr, batman_ogm_packet,
+				      is_single_hop_neigh,
+				      is_from_best_next_hop, if_incoming);
 
 		batadv_dbg(DBG_BATMAN, bat_priv,
 			   "Forwarding packet: rebroadcast neighbor packet with direct link flag\n");
@@ -1182,7 +1185,7 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	}
 
 	/* multihop originator */
-	if (!is_bidirectional) {
+	if (!is_bidirect) {
 		batadv_dbg(DBG_BATMAN, bat_priv,
 			   "Drop packet: not received via bidirectional link\n");
 		goto out_neigh;
@@ -1196,9 +1199,9 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 
 	batadv_dbg(DBG_BATMAN, bat_priv,
 		   "Forwarding packet: rebroadcast originator packet\n");
-	bat_iv_ogm_forward(orig_node, ethhdr, batman_ogm_packet,
-			   is_single_hop_neigh, is_from_best_next_hop,
-			   if_incoming);
+	batadv_iv_ogm_forward(orig_node, ethhdr, batman_ogm_packet,
+			      is_single_hop_neigh, is_from_best_next_hop,
+			      if_incoming);
 
 out_neigh:
 	if ((orig_neigh_node) && (!is_single_hop_neigh))
@@ -1214,8 +1217,8 @@ out:
 	batadv_orig_node_free_ref(orig_node);
 }
 
-static int bat_iv_ogm_receive(struct sk_buff *skb,
-			      struct hard_iface *if_incoming)
+static int batadv_iv_ogm_receive(struct sk_buff *skb,
+				 struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct batman_ogm_packet *batman_ogm_packet;
@@ -1231,7 +1234,7 @@ static int bat_iv_ogm_receive(struct sk_buff *skb,
 	/* did we receive a B.A.T.M.A.N. IV OGM packet on an interface
 	 * that does not have B.A.T.M.A.N. IV enabled ?
 	 */
-	if (bat_priv->bat_algo_ops->bat_ogm_emit != bat_iv_ogm_emit)
+	if (bat_priv->bat_algo_ops->bat_ogm_emit != batadv_iv_ogm_emit)
 		return NET_RX_DROP;
 
 	batadv_inc_counter(bat_priv, BAT_CNT_MGMT_RX);
@@ -1247,29 +1250,29 @@ static int bat_iv_ogm_receive(struct sk_buff *skb,
 	do {
 		tt_buff = packet_buff + buff_pos + BATMAN_OGM_HLEN;
 
-		bat_iv_ogm_process(ethhdr, batman_ogm_packet,
-				   tt_buff, if_incoming);
+		batadv_iv_ogm_process(ethhdr, batman_ogm_packet, tt_buff,
+				      if_incoming);
 
 		buff_pos += BATMAN_OGM_HLEN;
 		buff_pos += batadv_tt_len(batman_ogm_packet->tt_num_changes);
 
 		batman_ogm_packet = (struct batman_ogm_packet *)
 						(packet_buff + buff_pos);
-	} while (bat_iv_ogm_aggr_packet(buff_pos, packet_len,
-					batman_ogm_packet->tt_num_changes));
+	} while (batadv_iv_ogm_aggr_packet(buff_pos, packet_len,
+					   batman_ogm_packet->tt_num_changes));
 
 	kfree_skb(skb);
 	return NET_RX_SUCCESS;
 }
 
-static struct bat_algo_ops batman_iv __read_mostly = {
+static struct bat_algo_ops batadv_batman_iv __read_mostly = {
 	.name = "BATMAN_IV",
-	.bat_iface_enable = bat_iv_ogm_iface_enable,
-	.bat_iface_disable = bat_iv_ogm_iface_disable,
-	.bat_iface_update_mac = bat_iv_ogm_iface_update_mac,
-	.bat_primary_iface_set = bat_iv_ogm_primary_iface_set,
-	.bat_ogm_schedule = bat_iv_ogm_schedule,
-	.bat_ogm_emit = bat_iv_ogm_emit,
+	.bat_iface_enable = batadv_iv_ogm_iface_enable,
+	.bat_iface_disable = batadv_iv_ogm_iface_disable,
+	.bat_iface_update_mac = batadv_iv_ogm_iface_update_mac,
+	.bat_primary_iface_set = batadv_iv_ogm_primary_iface_set,
+	.bat_ogm_schedule = batadv_iv_ogm_schedule,
+	.bat_ogm_emit = batadv_iv_ogm_emit,
 };
 
 int __init batadv_iv_init(void)
@@ -1277,11 +1280,11 @@ int __init batadv_iv_init(void)
 	int ret;
 
 	/* batman originator packet */
-	ret = batadv_recv_handler_register(BAT_IV_OGM, bat_iv_ogm_receive);
+	ret = batadv_recv_handler_register(BAT_IV_OGM, batadv_iv_ogm_receive);
 	if (ret < 0)
 		goto out;
 
-	ret = batadv_algo_register(&batman_iv);
+	ret = batadv_algo_register(&batadv_batman_iv);
 	if (ret < 0)
 		goto handler_unregister;
 
-- 
1.7.9.4
