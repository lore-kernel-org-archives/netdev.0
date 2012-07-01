From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 09/16] batman-adv: Prefix packet structs with batadv_
Date: Mon,  2 Jul 2012 01:43:39 +0200
Message-ID: <1341186226-10549-10-git-send-email-ordex@autistici.org>
References: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:23607 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665Ab2GAXnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 19:43:41 -0400
In-Reply-To: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sven Eckelmann <sven@narfation.org>

Reported-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c            |  258 ++++++++++++++++--------=
--------
 net/batman-adv/bridge_loop_avoidance.c |   12 +-
 net/batman-adv/bridge_loop_avoidance.h |    4 +-
 net/batman-adv/hard-interface.c        |    4 +-
 net/batman-adv/icmp_socket.c           |   22 +--
 net/batman-adv/icmp_socket.h           |    2 +-
 net/batman-adv/main.c                  |   10 +-
 net/batman-adv/packet.h                |   44 +++---
 net/batman-adv/routing.c               |   88 +++++------
 net/batman-adv/routing.h               |    2 +-
 net/batman-adv/send.c                  |    4 +-
 net/batman-adv/soft-interface.c        |    4 +-
 net/batman-adv/translation-table.c     |  119 ++++++++-------
 net/batman-adv/translation-table.h     |    4 +-
 net/batman-adv/types.h                 |   10 +-
 net/batman-adv/unicast.c               |   38 ++---
 net/batman-adv/unicast.h               |    6 +-
 net/batman-adv/vis.c                   |   81 +++++-----
 net/batman-adv/vis.h                   |    4 +-
 19 files changed, 369 insertions(+), 347 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index f9981e6..a2bafd9 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -56,7 +56,7 @@ out:
=20
 static int batadv_iv_ogm_iface_enable(struct hard_iface *hard_iface)
 {
-	struct batman_ogm_packet *batman_ogm_packet;
+	struct batadv_ogm_packet *batadv_ogm_packet;
 	uint32_t random_seqno;
 	int res =3D -ENOMEM;
=20
@@ -70,14 +70,14 @@ static int batadv_iv_ogm_iface_enable(struct hard_i=
face *hard_iface)
 	if (!hard_iface->packet_buff)
 		goto out;
=20
-	batman_ogm_packet =3D (struct batman_ogm_packet *)hard_iface->packet_=
buff;
-	batman_ogm_packet->header.packet_type =3D BATADV_IV_OGM;
-	batman_ogm_packet->header.version =3D BATADV_COMPAT_VERSION;
-	batman_ogm_packet->header.ttl =3D 2;
-	batman_ogm_packet->flags =3D BATADV_NO_FLAGS;
-	batman_ogm_packet->tq =3D BATADV_TQ_MAX_VALUE;
-	batman_ogm_packet->tt_num_changes =3D 0;
-	batman_ogm_packet->ttvn =3D 0;
+	batadv_ogm_packet =3D (struct batadv_ogm_packet *)hard_iface->packet_=
buff;
+	batadv_ogm_packet->header.packet_type =3D BATADV_IV_OGM;
+	batadv_ogm_packet->header.version =3D BATADV_COMPAT_VERSION;
+	batadv_ogm_packet->header.ttl =3D 2;
+	batadv_ogm_packet->flags =3D BATADV_NO_FLAGS;
+	batadv_ogm_packet->tq =3D BATADV_TQ_MAX_VALUE;
+	batadv_ogm_packet->tt_num_changes =3D 0;
+	batadv_ogm_packet->ttvn =3D 0;
=20
 	res =3D 0;
=20
@@ -93,22 +93,22 @@ static void batadv_iv_ogm_iface_disable(struct hard=
_iface *hard_iface)
=20
 static void batadv_iv_ogm_iface_update_mac(struct hard_iface *hard_ifa=
ce)
 {
-	struct batman_ogm_packet *batman_ogm_packet;
+	struct batadv_ogm_packet *batadv_ogm_packet;
=20
-	batman_ogm_packet =3D (struct batman_ogm_packet *)hard_iface->packet_=
buff;
-	memcpy(batman_ogm_packet->orig,
+	batadv_ogm_packet =3D (struct batadv_ogm_packet *)hard_iface->packet_=
buff;
+	memcpy(batadv_ogm_packet->orig,
 	       hard_iface->net_dev->dev_addr, ETH_ALEN);
-	memcpy(batman_ogm_packet->prev_sender,
+	memcpy(batadv_ogm_packet->prev_sender,
 	       hard_iface->net_dev->dev_addr, ETH_ALEN);
 }
=20
 static void batadv_iv_ogm_primary_iface_set(struct hard_iface *hard_if=
ace)
 {
-	struct batman_ogm_packet *batman_ogm_packet;
+	struct batadv_ogm_packet *batadv_ogm_packet;
=20
-	batman_ogm_packet =3D (struct batman_ogm_packet *)hard_iface->packet_=
buff;
-	batman_ogm_packet->flags =3D BATADV_PRIMARIES_FIRST_HOP;
-	batman_ogm_packet->header.ttl =3D BATADV_TTL;
+	batadv_ogm_packet =3D (struct batadv_ogm_packet *)hard_iface->packet_=
buff;
+	batadv_ogm_packet->flags =3D BATADV_PRIMARIES_FIRST_HOP;
+	batadv_ogm_packet->header.ttl =3D BATADV_TTL;
 }
=20
 /* when do we schedule our own ogm to be sent */
@@ -162,7 +162,7 @@ static void batadv_iv_ogm_send_to_if(struct forw_pa=
cket *forw_packet,
 	char *fwd_str;
 	uint8_t packet_num;
 	int16_t buff_pos;
-	struct batman_ogm_packet *batman_ogm_packet;
+	struct batadv_ogm_packet *batadv_ogm_packet;
 	struct sk_buff *skb;
=20
 	if (hard_iface->if_status !=3D BATADV_IF_ACTIVE)
@@ -170,20 +170,20 @@ static void batadv_iv_ogm_send_to_if(struct forw_=
packet *forw_packet,
=20
 	packet_num =3D 0;
 	buff_pos =3D 0;
-	batman_ogm_packet =3D (struct batman_ogm_packet *)forw_packet->skb->d=
ata;
+	batadv_ogm_packet =3D (struct batadv_ogm_packet *)forw_packet->skb->d=
ata;
=20
 	/* adjust all flags and log packets */
 	while (batadv_iv_ogm_aggr_packet(buff_pos, forw_packet->packet_len,
-					 batman_ogm_packet->tt_num_changes)) {
+					 batadv_ogm_packet->tt_num_changes)) {
=20
 		/* we might have aggregated direct link packets with an
 		 * ordinary base packet
 		 */
 		if ((forw_packet->direct_link_flags & (1 << packet_num)) &&
 		    (forw_packet->if_incoming =3D=3D hard_iface))
-			batman_ogm_packet->flags |=3D BATADV_DIRECTLINK;
+			batadv_ogm_packet->flags |=3D BATADV_DIRECTLINK;
 		else
-			batman_ogm_packet->flags &=3D ~BATADV_DIRECTLINK;
+			batadv_ogm_packet->flags &=3D ~BATADV_DIRECTLINK;
=20
 		fwd_str =3D (packet_num > 0 ? "Forwarding" : (forw_packet->own ?
 							    "Sending own" :
@@ -191,18 +191,18 @@ static void batadv_iv_ogm_send_to_if(struct forw_=
packet *forw_packet,
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "%s %spacket (originator %pM, seqno %u, TQ %d, TTL %d, IDF %s, t=
tvn %d) on interface %s [%pM]\n",
 			   fwd_str, (packet_num > 0 ? "aggregated " : ""),
-			   batman_ogm_packet->orig,
-			   ntohl(batman_ogm_packet->seqno),
-			   batman_ogm_packet->tq, batman_ogm_packet->header.ttl,
-			   (batman_ogm_packet->flags & BATADV_DIRECTLINK ?
+			   batadv_ogm_packet->orig,
+			   ntohl(batadv_ogm_packet->seqno),
+			   batadv_ogm_packet->tq, batadv_ogm_packet->header.ttl,
+			   (batadv_ogm_packet->flags & BATADV_DIRECTLINK ?
 			    "on" : "off"),
-			   batman_ogm_packet->ttvn, hard_iface->net_dev->name,
+			   batadv_ogm_packet->ttvn, hard_iface->net_dev->name,
 			   hard_iface->net_dev->dev_addr);
=20
 		buff_pos +=3D BATADV_OGM_HLEN;
-		buff_pos +=3D batadv_tt_len(batman_ogm_packet->tt_num_changes);
+		buff_pos +=3D batadv_tt_len(batadv_ogm_packet->tt_num_changes);
 		packet_num++;
-		batman_ogm_packet =3D (struct batman_ogm_packet *)
+		batadv_ogm_packet =3D (struct batadv_ogm_packet *)
 					(forw_packet->skb->data + buff_pos);
 	}
=20
@@ -223,12 +223,12 @@ static void batadv_iv_ogm_emit(struct forw_packet=
 *forw_packet)
 	struct net_device *soft_iface;
 	struct bat_priv *bat_priv;
 	struct hard_iface *primary_if =3D NULL;
-	struct batman_ogm_packet *batman_ogm_packet;
+	struct batadv_ogm_packet *batadv_ogm_packet;
 	unsigned char directlink;
=20
-	batman_ogm_packet =3D (struct batman_ogm_packet *)
+	batadv_ogm_packet =3D (struct batadv_ogm_packet *)
 						(forw_packet->skb->data);
-	directlink =3D (batman_ogm_packet->flags & BATADV_DIRECTLINK ? 1 : 0)=
;
+	directlink =3D (batadv_ogm_packet->flags & BATADV_DIRECTLINK ? 1 : 0)=
;
=20
 	if (!forw_packet->if_incoming) {
 		pr_err("Error - can't forward packet: incoming iface not specified\n=
");
@@ -248,16 +248,16 @@ static void batadv_iv_ogm_emit(struct forw_packet=
 *forw_packet)
 	/* multihomed peer assumed
 	 * non-primary OGMs are only broadcasted on their interface
 	 */
-	if ((directlink && (batman_ogm_packet->header.ttl =3D=3D 1)) ||
+	if ((directlink && (batadv_ogm_packet->header.ttl =3D=3D 1)) ||
 	    (forw_packet->own && (forw_packet->if_incoming !=3D primary_if)))=
 {
=20
 		/* FIXME: what about aggregated packets ? */
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "%s packet (originator %pM, seqno %u, TTL %d) on interface %s [%=
pM]\n",
 			   (forw_packet->own ? "Sending own" : "Forwarding"),
-			   batman_ogm_packet->orig,
-			   ntohl(batman_ogm_packet->seqno),
-			   batman_ogm_packet->header.ttl,
+			   batadv_ogm_packet->orig,
+			   ntohl(batadv_ogm_packet->seqno),
+			   batadv_ogm_packet->header.ttl,
 			   forw_packet->if_incoming->net_dev->name,
 			   forw_packet->if_incoming->net_dev->dev_addr);
=20
@@ -287,20 +287,20 @@ out:
=20
 /* return true if new_packet can be aggregated with forw_packet */
 static bool
-batadv_iv_ogm_can_aggregate(const struct batman_ogm_packet *new_bat_og=
m_packet,
+batadv_iv_ogm_can_aggregate(const struct batadv_ogm_packet *new_bat_og=
m_packet,
 			    struct bat_priv *bat_priv,
 			    int packet_len, unsigned long send_time,
 			    bool directlink,
 			    const struct hard_iface *if_incoming,
 			    const struct forw_packet *forw_packet)
 {
-	struct batman_ogm_packet *batman_ogm_packet;
+	struct batadv_ogm_packet *batadv_ogm_packet;
 	int aggregated_bytes =3D forw_packet->packet_len + packet_len;
 	struct hard_iface *primary_if =3D NULL;
 	bool res =3D false;
 	unsigned long aggregation_end_time;
=20
-	batman_ogm_packet =3D (struct batman_ogm_packet *)forw_packet->skb->d=
ata;
+	batadv_ogm_packet =3D (struct batadv_ogm_packet *)forw_packet->skb->d=
ata;
 	aggregation_end_time =3D send_time;
 	aggregation_end_time +=3D msecs_to_jiffies(BATADV_MAX_AGGREGATION_MS)=
;
=20
@@ -330,8 +330,8 @@ batadv_iv_ogm_can_aggregate(const struct batman_ogm=
_packet *new_bat_ogm_packet,
 		 * are flooded through the net
 		 */
 		if ((!directlink) &&
-		    (!(batman_ogm_packet->flags & BATADV_DIRECTLINK)) &&
-		    (batman_ogm_packet->header.ttl !=3D 1) &&
+		    (!(batadv_ogm_packet->flags & BATADV_DIRECTLINK)) &&
+		    (batadv_ogm_packet->header.ttl !=3D 1) &&
=20
 		    /* own packets originating non-primary
 		     * interfaces leave only that interface
@@ -353,7 +353,7 @@ batadv_iv_ogm_can_aggregate(const struct batman_ogm=
_packet *new_bat_ogm_packet,
 		     * own secondary interface packets
 		     * (=3D secondary interface packets in general)
 		     */
-		    (batman_ogm_packet->flags & BATADV_DIRECTLINK ||
+		    (batadv_ogm_packet->flags & BATADV_DIRECTLINK ||
 		     (forw_packet->own &&
 		      forw_packet->if_incoming !=3D primary_if))) {
 			res =3D true;
@@ -475,12 +475,12 @@ static void batadv_iv_ogm_queue_add(struct bat_pr=
iv *bat_priv,
 	 */
 	struct forw_packet *forw_packet_aggr =3D NULL, *forw_packet_pos =3D N=
ULL;
 	struct hlist_node *tmp_node;
-	struct batman_ogm_packet *batman_ogm_packet;
+	struct batadv_ogm_packet *batadv_ogm_packet;
 	bool direct_link;
 	unsigned long max_aggregation_jiffies;
=20
-	batman_ogm_packet =3D (struct batman_ogm_packet *)packet_buff;
-	direct_link =3D batman_ogm_packet->flags & BATADV_DIRECTLINK ? 1 : 0;
+	batadv_ogm_packet =3D (struct batadv_ogm_packet *)packet_buff;
+	direct_link =3D batadv_ogm_packet->flags & BATADV_DIRECTLINK ? 1 : 0;
 	max_aggregation_jiffies =3D msecs_to_jiffies(BATADV_MAX_AGGREGATION_M=
S);
=20
 	/* find position for the packet in the forward queue */
@@ -489,7 +489,7 @@ static void batadv_iv_ogm_queue_add(struct bat_priv=
 *bat_priv,
 	if ((atomic_read(&bat_priv->aggregated_ogms)) && (!own_packet)) {
 		hlist_for_each_entry(forw_packet_pos, tmp_node,
 				     &bat_priv->forw_bat_list, list) {
-			if (batadv_iv_ogm_can_aggregate(batman_ogm_packet,
+			if (batadv_iv_ogm_can_aggregate(batadv_ogm_packet,
 							bat_priv, packet_len,
 							send_time, direct_link,
 							if_incoming,
@@ -526,7 +526,7 @@ static void batadv_iv_ogm_queue_add(struct bat_priv=
 *bat_priv,
=20
 static void batadv_iv_ogm_forward(struct orig_node *orig_node,
 				  const struct ethhdr *ethhdr,
-				  struct batman_ogm_packet *batman_ogm_packet,
+				  struct batadv_ogm_packet *batadv_ogm_packet,
 				  bool is_single_hop_neigh,
 				  bool is_from_best_next_hop,
 				  struct hard_iface *if_incoming)
@@ -534,7 +534,7 @@ static void batadv_iv_ogm_forward(struct orig_node =
*orig_node,
 	struct bat_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface);
 	uint8_t tt_num_changes;
=20
-	if (batman_ogm_packet->header.ttl <=3D 1) {
+	if (batadv_ogm_packet->header.ttl <=3D 1) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv, "ttl exceeded\n");
 		return;
 	}
@@ -547,32 +547,32 @@ static void batadv_iv_ogm_forward(struct orig_nod=
e *orig_node,
 		 * simply drop the ogm.
 		 */
 		if (is_single_hop_neigh)
-			batman_ogm_packet->flags |=3D BATADV_NOT_BEST_NEXT_HOP;
+			batadv_ogm_packet->flags |=3D BATADV_NOT_BEST_NEXT_HOP;
 		else
 			return;
 	}
=20
-	tt_num_changes =3D batman_ogm_packet->tt_num_changes;
+	tt_num_changes =3D batadv_ogm_packet->tt_num_changes;
=20
-	batman_ogm_packet->header.ttl--;
-	memcpy(batman_ogm_packet->prev_sender, ethhdr->h_source, ETH_ALEN);
+	batadv_ogm_packet->header.ttl--;
+	memcpy(batadv_ogm_packet->prev_sender, ethhdr->h_source, ETH_ALEN);
=20
 	/* apply hop penalty */
-	batman_ogm_packet->tq =3D batadv_hop_penalty(batman_ogm_packet->tq,
+	batadv_ogm_packet->tq =3D batadv_hop_penalty(batadv_ogm_packet->tq,
 						   bat_priv);
=20
 	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 		   "Forwarding packet: tq: %i, ttl: %i\n",
-		   batman_ogm_packet->tq, batman_ogm_packet->header.ttl);
+		   batadv_ogm_packet->tq, batadv_ogm_packet->header.ttl);
=20
 	/* switch of primaries first hop flag when forwarding */
-	batman_ogm_packet->flags &=3D ~BATADV_PRIMARIES_FIRST_HOP;
+	batadv_ogm_packet->flags &=3D ~BATADV_PRIMARIES_FIRST_HOP;
 	if (is_single_hop_neigh)
-		batman_ogm_packet->flags |=3D BATADV_DIRECTLINK;
+		batadv_ogm_packet->flags |=3D BATADV_DIRECTLINK;
 	else
-		batman_ogm_packet->flags &=3D ~BATADV_DIRECTLINK;
+		batadv_ogm_packet->flags &=3D ~BATADV_DIRECTLINK;
=20
-	batadv_iv_ogm_queue_add(bat_priv, (unsigned char *)batman_ogm_packet,
+	batadv_iv_ogm_queue_add(bat_priv, (unsigned char *)batadv_ogm_packet,
 				BATADV_OGM_HLEN + batadv_tt_len(tt_num_changes),
 				if_incoming, 0, batadv_iv_ogm_fwd_send_time());
 }
@@ -580,7 +580,7 @@ static void batadv_iv_ogm_forward(struct orig_node =
*orig_node,
 static void batadv_iv_ogm_schedule(struct hard_iface *hard_iface)
 {
 	struct bat_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
-	struct batman_ogm_packet *batman_ogm_packet;
+	struct batadv_ogm_packet *batadv_ogm_packet;
 	struct hard_iface *primary_if;
 	int vis_server, tt_num_changes =3D 0;
=20
@@ -593,29 +593,29 @@ static void batadv_iv_ogm_schedule(struct hard_if=
ace *hard_iface)
 						       &hard_iface->packet_len,
 						       BATADV_OGM_HLEN);
=20
-	batman_ogm_packet =3D (struct batman_ogm_packet *)hard_iface->packet_=
buff;
+	batadv_ogm_packet =3D (struct batadv_ogm_packet *)hard_iface->packet_=
buff;
=20
 	/* change sequence number to network order */
-	batman_ogm_packet->seqno =3D
+	batadv_ogm_packet->seqno =3D
 			htonl((uint32_t)atomic_read(&hard_iface->seqno));
 	atomic_inc(&hard_iface->seqno);
=20
-	batman_ogm_packet->ttvn =3D atomic_read(&bat_priv->ttvn);
-	batman_ogm_packet->tt_crc =3D htons(bat_priv->tt_crc);
+	batadv_ogm_packet->ttvn =3D atomic_read(&bat_priv->ttvn);
+	batadv_ogm_packet->tt_crc =3D htons(bat_priv->tt_crc);
 	if (tt_num_changes >=3D 0)
-		batman_ogm_packet->tt_num_changes =3D tt_num_changes;
+		batadv_ogm_packet->tt_num_changes =3D tt_num_changes;
=20
 	if (vis_server =3D=3D BATADV_VIS_TYPE_SERVER_SYNC)
-		batman_ogm_packet->flags |=3D BATADV_VIS_SERVER;
+		batadv_ogm_packet->flags |=3D BATADV_VIS_SERVER;
 	else
-		batman_ogm_packet->flags &=3D ~BATADV_VIS_SERVER;
+		batadv_ogm_packet->flags &=3D ~BATADV_VIS_SERVER;
=20
 	if ((hard_iface =3D=3D primary_if) &&
 	    (atomic_read(&bat_priv->gw_mode) =3D=3D BATADV_GW_MODE_SERVER))
-		batman_ogm_packet->gw_flags =3D
+		batadv_ogm_packet->gw_flags =3D
 				(uint8_t)atomic_read(&bat_priv->gw_bandwidth);
 	else
-		batman_ogm_packet->gw_flags =3D BATADV_NO_FLAGS;
+		batadv_ogm_packet->gw_flags =3D BATADV_NO_FLAGS;
=20
 	batadv_slide_own_bcast_window(hard_iface);
 	batadv_iv_ogm_queue_add(bat_priv, hard_iface->packet_buff,
@@ -630,7 +630,7 @@ static void
 batadv_iv_ogm_orig_update(struct bat_priv *bat_priv,
 			  struct orig_node *orig_node,
 			  const struct ethhdr *ethhdr,
-			  const struct batman_ogm_packet *batman_ogm_packet,
+			  const struct batadv_ogm_packet *batadv_ogm_packet,
 			  struct hard_iface *if_incoming,
 			  const unsigned char *tt_buff,
 			  int is_duplicate)
@@ -679,7 +679,7 @@ batadv_iv_ogm_orig_update(struct bat_priv *bat_priv=
,
 		neigh_node =3D batadv_iv_ogm_neigh_new(if_incoming,
 						     ethhdr->h_source,
 						     orig_node, orig_tmp,
-						     batman_ogm_packet->seqno);
+						     batadv_ogm_packet->seqno);
=20
 		batadv_orig_node_free_ref(orig_tmp);
 		if (!neigh_node)
@@ -690,19 +690,19 @@ batadv_iv_ogm_orig_update(struct bat_priv *bat_pr=
iv,
=20
 	rcu_read_unlock();
=20
-	orig_node->flags =3D batman_ogm_packet->flags;
+	orig_node->flags =3D batadv_ogm_packet->flags;
 	neigh_node->last_seen =3D jiffies;
=20
 	spin_lock_bh(&neigh_node->lq_update_lock);
 	batadv_ring_buffer_set(neigh_node->tq_recv,
 			       &neigh_node->tq_index,
-			       batman_ogm_packet->tq);
+			       batadv_ogm_packet->tq);
 	neigh_node->tq_avg =3D batadv_ring_buffer_avg(neigh_node->tq_recv);
 	spin_unlock_bh(&neigh_node->lq_update_lock);
=20
 	if (!is_duplicate) {
-		orig_node->last_ttl =3D batman_ogm_packet->header.ttl;
-		neigh_node->last_ttl =3D batman_ogm_packet->header.ttl;
+		orig_node->last_ttl =3D batadv_ogm_packet->header.ttl;
+		neigh_node->last_ttl =3D batadv_ogm_packet->header.ttl;
 	}
=20
 	batadv_bonding_candidate_add(orig_node, neigh_node);
@@ -744,19 +744,19 @@ update_tt:
 	/* I have to check for transtable changes only if the OGM has been
 	 * sent through a primary interface
 	 */
-	if (((batman_ogm_packet->orig !=3D ethhdr->h_source) &&
-	     (batman_ogm_packet->header.ttl > 2)) ||
-	    (batman_ogm_packet->flags & BATADV_PRIMARIES_FIRST_HOP))
+	if (((batadv_ogm_packet->orig !=3D ethhdr->h_source) &&
+	     (batadv_ogm_packet->header.ttl > 2)) ||
+	    (batadv_ogm_packet->flags & BATADV_PRIMARIES_FIRST_HOP))
 		batadv_tt_update_orig(bat_priv, orig_node, tt_buff,
-				      batman_ogm_packet->tt_num_changes,
-				      batman_ogm_packet->ttvn,
-				      ntohs(batman_ogm_packet->tt_crc));
+				      batadv_ogm_packet->tt_num_changes,
+				      batadv_ogm_packet->ttvn,
+				      ntohs(batadv_ogm_packet->tt_crc));
=20
-	if (orig_node->gw_flags !=3D batman_ogm_packet->gw_flags)
+	if (orig_node->gw_flags !=3D batadv_ogm_packet->gw_flags)
 		batadv_gw_node_update(bat_priv, orig_node,
-				      batman_ogm_packet->gw_flags);
+				      batadv_ogm_packet->gw_flags);
=20
-	orig_node->gw_flags =3D batman_ogm_packet->gw_flags;
+	orig_node->gw_flags =3D batadv_ogm_packet->gw_flags;
=20
 	/* restart gateway selection if fast or late switching was enabled */
 	if ((orig_node->gw_flags) &&
@@ -777,7 +777,7 @@ out:
=20
 static int batadv_iv_ogm_calc_tq(struct orig_node *orig_node,
 				 struct orig_node *orig_neigh_node,
-				 struct batman_ogm_packet *batman_ogm_packet,
+				 struct batadv_ogm_packet *batadv_ogm_packet,
 				 struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface);
@@ -814,7 +814,7 @@ static int batadv_iv_ogm_calc_tq(struct orig_node *=
orig_node,
 						     orig_neigh_node->orig,
 						     orig_neigh_node,
 						     orig_neigh_node,
-						     batman_ogm_packet->seqno);
+						     batadv_ogm_packet->seqno);
=20
 	if (!neigh_node)
 		goto out;
@@ -862,20 +862,20 @@ static int batadv_iv_ogm_calc_tq(struct orig_node=
 *orig_node,
 	inv_asym_penalty /=3D neigh_rq_max_cube;
 	tq_asym_penalty =3D BATADV_TQ_MAX_VALUE - inv_asym_penalty;
=20
-	combined_tq =3D batman_ogm_packet->tq * tq_own * tq_asym_penalty;
+	combined_tq =3D batadv_ogm_packet->tq * tq_own * tq_asym_penalty;
 	combined_tq /=3D BATADV_TQ_MAX_VALUE * BATADV_TQ_MAX_VALUE;
-	batman_ogm_packet->tq =3D combined_tq;
+	batadv_ogm_packet->tq =3D combined_tq;
=20
 	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 		   "bidirectional: orig =3D %-15pM neigh =3D %-15pM =3D> own_bcast =3D=
 %2i, real recv =3D %2i, local tq: %3i, asym_penalty: %3i, total tq: %3=
i\n",
 		   orig_node->orig, orig_neigh_node->orig, total_count,
 		   neigh_rq_count, tq_own,
-		   tq_asym_penalty, batman_ogm_packet->tq);
+		   tq_asym_penalty, batadv_ogm_packet->tq);
=20
 	/* if link has the minimum required transmission quality
 	 * consider it bidirectional
 	 */
-	if (batman_ogm_packet->tq >=3D BATADV_TQ_TOTAL_BIDRECT_LIMIT)
+	if (batadv_ogm_packet->tq >=3D BATADV_TQ_TOTAL_BIDRECT_LIMIT)
 		ret =3D 1;
=20
 out:
@@ -894,7 +894,7 @@ out:
  */
 static int
 batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
-			    const struct batman_ogm_packet *batman_ogm_packet,
+			    const struct batadv_ogm_packet *batadv_ogm_packet,
 			    const struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface);
@@ -905,10 +905,10 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *=
ethhdr,
 	int32_t seq_diff;
 	int need_update =3D 0;
 	int set_mark, ret =3D -1;
-	uint32_t seqno =3D ntohl(batman_ogm_packet->seqno);
+	uint32_t seqno =3D ntohl(batadv_ogm_packet->seqno);
 	uint8_t *neigh_addr;
=20
-	orig_node =3D batadv_get_orig_node(bat_priv, batman_ogm_packet->orig)=
;
+	orig_node =3D batadv_get_orig_node(bat_priv, batadv_ogm_packet->orig)=
;
 	if (!orig_node)
 		return 0;
=20
@@ -963,7 +963,7 @@ out:
 }
=20
 static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
-				  struct batman_ogm_packet *batman_ogm_packet,
+				  struct batadv_ogm_packet *batadv_ogm_packet,
 				  const unsigned char *tt_buff,
 				  struct hard_iface *if_incoming)
 {
@@ -989,34 +989,34 @@ static void batadv_iv_ogm_process(const struct et=
hhdr *ethhdr,
 	 * it as an additional length.
 	 *
 	 * TODO: A more sane solution would be to have a bit in the
-	 * batman_ogm_packet to detect whether the packet is the last
+	 * batadv_ogm_packet to detect whether the packet is the last
 	 * packet in an aggregation.  Here we expect that the padding
 	 * is always zero (or not 0x01)
 	 */
-	if (batman_ogm_packet->header.packet_type !=3D BATADV_IV_OGM)
+	if (batadv_ogm_packet->header.packet_type !=3D BATADV_IV_OGM)
 		return;
=20
 	/* could be changed by schedule_own_packet() */
 	if_incoming_seqno =3D atomic_read(&if_incoming->seqno);
=20
-	if (batman_ogm_packet->flags & BATADV_DIRECTLINK)
+	if (batadv_ogm_packet->flags & BATADV_DIRECTLINK)
 		has_directlink_flag =3D 1;
 	else
 		has_directlink_flag =3D 0;
=20
-	if (batadv_compare_eth(ethhdr->h_source, batman_ogm_packet->orig))
+	if (batadv_compare_eth(ethhdr->h_source, batadv_ogm_packet->orig))
 		is_single_hop_neigh =3D true;
=20
 	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 		   "Received BATMAN packet via NB: %pM, IF: %s [%pM] (from OG: %pM, =
via prev OG: %pM, seqno %u, ttvn %u, crc %u, changes %u, td %d, TTL %d,=
 V %d, IDF %d)\n",
 		   ethhdr->h_source, if_incoming->net_dev->name,
-		   if_incoming->net_dev->dev_addr, batman_ogm_packet->orig,
-		   batman_ogm_packet->prev_sender,
-		   ntohl(batman_ogm_packet->seqno), batman_ogm_packet->ttvn,
-		   ntohs(batman_ogm_packet->tt_crc),
-		   batman_ogm_packet->tt_num_changes, batman_ogm_packet->tq,
-		   batman_ogm_packet->header.ttl,
-		   batman_ogm_packet->header.version, has_directlink_flag);
+		   if_incoming->net_dev->dev_addr, batadv_ogm_packet->orig,
+		   batadv_ogm_packet->prev_sender,
+		   ntohl(batadv_ogm_packet->seqno), batadv_ogm_packet->ttvn,
+		   ntohs(batadv_ogm_packet->tt_crc),
+		   batadv_ogm_packet->tt_num_changes, batadv_ogm_packet->tq,
+		   batadv_ogm_packet->header.ttl,
+		   batadv_ogm_packet->header.version, has_directlink_flag);
=20
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
@@ -1030,11 +1030,11 @@ static void batadv_iv_ogm_process(const struct =
ethhdr *ethhdr,
 				       hard_iface->net_dev->dev_addr))
 			is_my_addr =3D 1;
=20
-		if (batadv_compare_eth(batman_ogm_packet->orig,
+		if (batadv_compare_eth(batadv_ogm_packet->orig,
 				       hard_iface->net_dev->dev_addr))
 			is_my_orig =3D 1;
=20
-		if (batadv_compare_eth(batman_ogm_packet->prev_sender,
+		if (batadv_compare_eth(batadv_ogm_packet->prev_sender,
 				       hard_iface->net_dev->dev_addr))
 			is_my_oldorig =3D 1;
=20
@@ -1043,10 +1043,10 @@ static void batadv_iv_ogm_process(const struct =
ethhdr *ethhdr,
 	}
 	rcu_read_unlock();
=20
-	if (batman_ogm_packet->header.version !=3D BATADV_COMPAT_VERSION) {
+	if (batadv_ogm_packet->header.version !=3D BATADV_COMPAT_VERSION) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: incompatible batman version (%i)\n",
-			   batman_ogm_packet->header.version);
+			   batadv_ogm_packet->header.version);
 		return;
 	}
=20
@@ -1082,14 +1082,14 @@ static void batadv_iv_ogm_process(const struct =
ethhdr *ethhdr,
 		 */
 		if (has_directlink_flag &&
 		    batadv_compare_eth(if_incoming->net_dev->dev_addr,
-				       batman_ogm_packet->orig)) {
+				       batadv_ogm_packet->orig)) {
 			if_num =3D if_incoming->if_num;
 			offset =3D if_num * BATADV_NUM_WORDS;
=20
 			spin_lock_bh(&orig_neigh_node->ogm_cnt_lock);
 			word =3D &(orig_neigh_node->bcast_own[offset]);
 			bit_pos =3D if_incoming_seqno - 2;
-			bit_pos -=3D ntohl(batman_ogm_packet->seqno);
+			bit_pos -=3D ntohl(batadv_ogm_packet->seqno);
 			batadv_set_bit(word, bit_pos);
 			weight =3D &orig_neigh_node->bcast_own_sum[if_num];
 			*weight =3D bitmap_weight(word,
@@ -1110,18 +1110,18 @@ static void batadv_iv_ogm_process(const struct =
ethhdr *ethhdr,
 		return;
 	}
=20
-	if (batman_ogm_packet->flags & BATADV_NOT_BEST_NEXT_HOP) {
+	if (batadv_ogm_packet->flags & BATADV_NOT_BEST_NEXT_HOP) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: ignoring all packets not forwarded from the best n=
ext hop (sender: %pM)\n",
 			   ethhdr->h_source);
 		return;
 	}
=20
-	orig_node =3D batadv_get_orig_node(bat_priv, batman_ogm_packet->orig)=
;
+	orig_node =3D batadv_get_orig_node(bat_priv, batadv_ogm_packet->orig)=
;
 	if (!orig_node)
 		return;
=20
-	is_duplicate =3D batadv_iv_ogm_update_seqnos(ethhdr, batman_ogm_packe=
t,
+	is_duplicate =3D batadv_iv_ogm_update_seqnos(ethhdr, batadv_ogm_packe=
t,
 						   if_incoming);
=20
 	if (is_duplicate =3D=3D -1) {
@@ -1131,7 +1131,7 @@ static void batadv_iv_ogm_process(const struct et=
hhdr *ethhdr,
 		goto out;
 	}
=20
-	if (batman_ogm_packet->tq =3D=3D 0) {
+	if (batadv_ogm_packet->tq =3D=3D 0) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: originator packet with tq equal 0\n");
 		goto out;
@@ -1145,11 +1145,11 @@ static void batadv_iv_ogm_process(const struct =
ethhdr *ethhdr,
 	    (batadv_compare_eth(router->addr, ethhdr->h_source)))
 		is_from_best_next_hop =3D true;
=20
-	prev_sender =3D batman_ogm_packet->prev_sender;
+	prev_sender =3D batadv_ogm_packet->prev_sender;
 	/* avoid temporary routing loops */
 	if (router && router_router &&
 	    (batadv_compare_eth(router->addr, prev_sender)) &&
-	    !(batadv_compare_eth(batman_ogm_packet->orig, prev_sender)) &&
+	    !(batadv_compare_eth(batadv_ogm_packet->orig, prev_sender)) &&
 	    (batadv_compare_eth(router->addr, router_router->addr))) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: ignoring all rebroadcast packets that may make me =
loop (sender: %pM)\n",
@@ -1178,26 +1178,26 @@ static void batadv_iv_ogm_process(const struct =
ethhdr *ethhdr,
 	}
=20
 	is_bidirect =3D batadv_iv_ogm_calc_tq(orig_node, orig_neigh_node,
-					    batman_ogm_packet, if_incoming);
+					    batadv_ogm_packet, if_incoming);
=20
 	batadv_bonding_save_primary(orig_node, orig_neigh_node,
-				    batman_ogm_packet);
+				    batadv_ogm_packet);
=20
 	/* update ranking if it is not a duplicate or has the same
 	 * seqno and similar ttl as the non-duplicate
 	 */
-	sameseq =3D orig_node->last_real_seqno =3D=3D ntohl(batman_ogm_packet=
->seqno);
-	simlar_ttl =3D orig_node->last_ttl - 3 <=3D batman_ogm_packet->header=
=2Ettl;
+	sameseq =3D orig_node->last_real_seqno =3D=3D ntohl(batadv_ogm_packet=
->seqno);
+	simlar_ttl =3D orig_node->last_ttl - 3 <=3D batadv_ogm_packet->header=
=2Ettl;
 	if (is_bidirect && (!is_duplicate || (sameseq && simlar_ttl)))
 		batadv_iv_ogm_orig_update(bat_priv, orig_node, ethhdr,
-					  batman_ogm_packet, if_incoming,
+					  batadv_ogm_packet, if_incoming,
 					  tt_buff, is_duplicate);
=20
 	/* is single hop (direct) neighbor */
 	if (is_single_hop_neigh) {
=20
 		/* mark direct link on incoming interface */
-		batadv_iv_ogm_forward(orig_node, ethhdr, batman_ogm_packet,
+		batadv_iv_ogm_forward(orig_node, ethhdr, batadv_ogm_packet,
 				      is_single_hop_neigh,
 				      is_from_best_next_hop, if_incoming);
=20
@@ -1221,7 +1221,7 @@ static void batadv_iv_ogm_process(const struct et=
hhdr *ethhdr,
=20
 	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 		   "Forwarding packet: rebroadcast originator packet\n");
-	batadv_iv_ogm_forward(orig_node, ethhdr, batman_ogm_packet,
+	batadv_iv_ogm_forward(orig_node, ethhdr, batadv_ogm_packet,
 			      is_single_hop_neigh, is_from_best_next_hop,
 			      if_incoming);
=20
@@ -1243,7 +1243,7 @@ static int batadv_iv_ogm_receive(struct sk_buff *=
skb,
 				 struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface);
-	struct batman_ogm_packet *batman_ogm_packet;
+	struct batadv_ogm_packet *batadv_ogm_packet;
 	struct ethhdr *ethhdr;
 	int buff_pos =3D 0, packet_len;
 	unsigned char *tt_buff, *packet_buff;
@@ -1266,22 +1266,22 @@ static int batadv_iv_ogm_receive(struct sk_buff=
 *skb,
 	packet_len =3D skb_headlen(skb);
 	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
 	packet_buff =3D skb->data;
-	batman_ogm_packet =3D (struct batman_ogm_packet *)packet_buff;
+	batadv_ogm_packet =3D (struct batadv_ogm_packet *)packet_buff;
=20
 	/* unpack the aggregated packets and process them one by one */
 	do {
 		tt_buff =3D packet_buff + buff_pos + BATADV_OGM_HLEN;
=20
-		batadv_iv_ogm_process(ethhdr, batman_ogm_packet, tt_buff,
+		batadv_iv_ogm_process(ethhdr, batadv_ogm_packet, tt_buff,
 				      if_incoming);
=20
 		buff_pos +=3D BATADV_OGM_HLEN;
-		buff_pos +=3D batadv_tt_len(batman_ogm_packet->tt_num_changes);
+		buff_pos +=3D batadv_tt_len(batadv_ogm_packet->tt_num_changes);
=20
-		batman_ogm_packet =3D (struct batman_ogm_packet *)
+		batadv_ogm_packet =3D (struct batadv_ogm_packet *)
 						(packet_buff + buff_pos);
 	} while (batadv_iv_ogm_aggr_packet(buff_pos, packet_len,
-					   batman_ogm_packet->tt_num_changes));
+					   batadv_ogm_packet->tt_num_changes));
=20
 	kfree_skb(skb);
 	return NET_RX_SUCCESS;
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/br=
idge_loop_avoidance.c
index 8bd7050..fdda2c8 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -255,7 +255,7 @@ static void batadv_bla_send_claim(struct bat_priv *=
bat_priv, uint8_t *mac,
 	struct hard_iface *primary_if;
 	struct net_device *soft_iface;
 	uint8_t *hw_src;
-	struct bla_claim_dst local_claim_dest;
+	struct batadv_bla_claim_dst local_claim_dest;
 	__be32 zeroip =3D 0;
=20
 	primary_if =3D batadv_primary_if_get_selected(bat_priv);
@@ -759,9 +759,9 @@ static int batadv_check_claim_group(struct bat_priv=
 *bat_priv,
 {
 	uint8_t *backbone_addr;
 	struct orig_node *orig_node;
-	struct bla_claim_dst *bla_dst, *bla_dst_own;
+	struct batadv_bla_claim_dst *bla_dst, *bla_dst_own;
=20
-	bla_dst =3D (struct bla_claim_dst *)hw_dst;
+	bla_dst =3D (struct batadv_bla_claim_dst *)hw_dst;
 	bla_dst_own =3D &bat_priv->claim_dest;
=20
 	/* check if it is a claim packet in general */
@@ -832,7 +832,7 @@ static int batadv_bla_process_claim(struct bat_priv=
 *bat_priv,
 	struct vlan_ethhdr *vhdr;
 	struct arphdr *arphdr;
 	uint8_t *hw_src, *hw_dst;
-	struct bla_claim_dst *bla_dst;
+	struct batadv_bla_claim_dst *bla_dst;
 	uint16_t proto;
 	int headlen;
 	short vid =3D -1;
@@ -876,7 +876,7 @@ static int batadv_bla_process_claim(struct bat_priv=
 *bat_priv,
=20
 	hw_src =3D (uint8_t *)arphdr + sizeof(struct arphdr);
 	hw_dst =3D hw_src + ETH_ALEN + 4;
-	bla_dst =3D (struct bla_claim_dst *)hw_dst;
+	bla_dst =3D (struct batadv_bla_claim_dst *)hw_dst;
=20
 	/* check if it is a claim frame. */
 	ret =3D batadv_check_claim_group(bat_priv, primary_if, hw_src, hw_dst=
,
@@ -1201,7 +1201,7 @@ int batadv_bla_init(struct bat_priv *bat_priv)
  * the same host however as this might be intended.
  */
 int batadv_bla_check_bcast_duplist(struct bat_priv *bat_priv,
-				   struct bcast_packet *bcast_packet,
+				   struct batadv_bcast_packet *bcast_packet,
 				   int hdr_size)
 {
 	int i, length, curr;
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/br=
idge_loop_avoidance.h
index 58563f0..d69f453 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -28,7 +28,7 @@ int batadv_bla_is_backbone_gw(struct sk_buff *skb,
 int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *=
offset);
 int batadv_bla_is_backbone_gw_orig(struct bat_priv *bat_priv, uint8_t =
*orig);
 int batadv_bla_check_bcast_duplist(struct bat_priv *bat_priv,
-				   struct bcast_packet *bcast_packet,
+				   struct batadv_bcast_packet *bcast_packet,
 				   int hdr_size);
 void batadv_bla_update_orig_address(struct bat_priv *bat_priv,
 				    struct hard_iface *primary_if,
@@ -72,7 +72,7 @@ static inline int batadv_bla_is_backbone_gw_orig(stru=
ct bat_priv *bat_priv,
=20
 static inline int
 batadv_bla_check_bcast_duplist(struct bat_priv *bat_priv,
-			       struct bcast_packet *bcast_packet,
+			       struct batadv_bcast_packet *bcast_packet,
 			       int hdr_size)
 {
 	return 0;
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-inte=
rface.c
index e109d65..0a14fdf 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -100,14 +100,14 @@ out:
 static void batadv_primary_if_update_addr(struct bat_priv *bat_priv,
 					  struct hard_iface *oldif)
 {
-	struct vis_packet *vis_packet;
+	struct batadv_vis_packet *vis_packet;
 	struct hard_iface *primary_if;
=20
 	primary_if =3D batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
=20
-	vis_packet =3D (struct vis_packet *)
+	vis_packet =3D (struct batadv_vis_packet *)
 				bat_priv->my_vis_info->skb_packet->data;
 	memcpy(vis_packet->vis_orig, primary_if->net_dev->dev_addr, ETH_ALEN)=
;
 	memcpy(vis_packet->sender_orig,
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.=
c
index 61b52b3..ca07580 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -29,7 +29,7 @@
 static struct socket_client *batadv_socket_client_hash[256];
=20
 static void batadv_socket_add_packet(struct socket_client *socket_clie=
nt,
-				     struct icmp_packet_rr *icmp_packet,
+				     struct batadv_icmp_packet_rr *icmp_packet,
 				     size_t icmp_len);
=20
 void batadv_socket_init(void)
@@ -112,7 +112,7 @@ static ssize_t batadv_socket_read(struct file *file=
, char __user *buf,
 	if ((file->f_flags & O_NONBLOCK) && (socket_client->queue_len =3D=3D =
0))
 		return -EAGAIN;
=20
-	if ((!buf) || (count < sizeof(struct icmp_packet)))
+	if ((!buf) || (count < sizeof(struct batadv_icmp_packet)))
 		return -EINVAL;
=20
 	if (!access_ok(VERIFY_WRITE, buf, count))
@@ -151,13 +151,13 @@ static ssize_t batadv_socket_write(struct file *f=
ile, const char __user *buff,
 	struct bat_priv *bat_priv =3D socket_client->bat_priv;
 	struct hard_iface *primary_if =3D NULL;
 	struct sk_buff *skb;
-	struct icmp_packet_rr *icmp_packet;
+	struct batadv_icmp_packet_rr *icmp_packet;
=20
 	struct orig_node *orig_node =3D NULL;
 	struct neigh_node *neigh_node =3D NULL;
-	size_t packet_len =3D sizeof(struct icmp_packet);
+	size_t packet_len =3D sizeof(struct batadv_icmp_packet);
=20
-	if (len < sizeof(struct icmp_packet)) {
+	if (len < sizeof(struct batadv_icmp_packet)) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Error - can't send packet from char device: invalid packet size=
\n");
 		return -EINVAL;
@@ -170,8 +170,8 @@ static ssize_t batadv_socket_write(struct file *fil=
e, const char __user *buff,
 		goto out;
 	}
=20
-	if (len >=3D sizeof(struct icmp_packet_rr))
-		packet_len =3D sizeof(struct icmp_packet_rr);
+	if (len >=3D sizeof(struct batadv_icmp_packet_rr))
+		packet_len =3D sizeof(struct batadv_icmp_packet_rr);
=20
 	skb =3D dev_alloc_skb(packet_len + ETH_HLEN);
 	if (!skb) {
@@ -180,7 +180,7 @@ static ssize_t batadv_socket_write(struct file *fil=
e, const char __user *buff,
 	}
=20
 	skb_reserve(skb, ETH_HLEN);
-	icmp_packet =3D (struct icmp_packet_rr *)skb_put(skb, packet_len);
+	icmp_packet =3D (struct batadv_icmp_packet_rr *)skb_put(skb, packet_l=
en);
=20
 	if (copy_from_user(icmp_packet, buff, packet_len)) {
 		len =3D -EFAULT;
@@ -231,7 +231,7 @@ static ssize_t batadv_socket_write(struct file *fil=
e, const char __user *buff,
 	memcpy(icmp_packet->orig,
 	       primary_if->net_dev->dev_addr, ETH_ALEN);
=20
-	if (packet_len =3D=3D sizeof(struct icmp_packet_rr))
+	if (packet_len =3D=3D sizeof(struct batadv_icmp_packet_rr))
 		memcpy(icmp_packet->rr,
 		       neigh_node->if_incoming->net_dev->dev_addr, ETH_ALEN);
=20
@@ -294,7 +294,7 @@ err:
 }
=20
 static void batadv_socket_add_packet(struct socket_client *socket_clie=
nt,
-				     struct icmp_packet_rr *icmp_packet,
+				     struct batadv_icmp_packet_rr *icmp_packet,
 				     size_t icmp_len)
 {
 	struct socket_packet *socket_packet;
@@ -336,7 +336,7 @@ static void batadv_socket_add_packet(struct socket_=
client *socket_client,
 	wake_up(&socket_client->queue_wait);
 }
=20
-void batadv_socket_receive_packet(struct icmp_packet_rr *icmp_packet,
+void batadv_socket_receive_packet(struct batadv_icmp_packet_rr *icmp_p=
acket,
 				  size_t icmp_len)
 {
 	struct socket_client *hash;
diff --git a/net/batman-adv/icmp_socket.h b/net/batman-adv/icmp_socket.=
h
index f88f9f0..7b8ad52 100644
--- a/net/batman-adv/icmp_socket.h
+++ b/net/batman-adv/icmp_socket.h
@@ -24,7 +24,7 @@
=20
 void batadv_socket_init(void);
 int batadv_socket_setup(struct bat_priv *bat_priv);
-void batadv_socket_receive_packet(struct icmp_packet_rr *icmp_packet,
+void batadv_socket_receive_packet(struct batadv_icmp_packet_rr *icmp_p=
acket,
 				  size_t icmp_len);
=20
 #endif /* _NET_BATMAN_ADV_ICMP_SOCKET_H_ */
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 24d651d..97144a9 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -205,7 +205,7 @@ int batadv_batman_skb_recv(struct sk_buff *skb, str=
uct net_device *dev,
 			   struct net_device *orig_dev)
 {
 	struct bat_priv *bat_priv;
-	struct batman_ogm_packet *batman_ogm_packet;
+	struct batadv_ogm_packet *batadv_ogm_packet;
 	struct hard_iface *hard_iface;
 	uint8_t idx;
 	int ret;
@@ -237,19 +237,19 @@ int batadv_batman_skb_recv(struct sk_buff *skb, s=
truct net_device *dev,
 	if (hard_iface->if_status !=3D BATADV_IF_ACTIVE)
 		goto err_free;
=20
-	batman_ogm_packet =3D (struct batman_ogm_packet *)skb->data;
+	batadv_ogm_packet =3D (struct batadv_ogm_packet *)skb->data;
=20
-	if (batman_ogm_packet->header.version !=3D BATADV_COMPAT_VERSION) {
+	if (batadv_ogm_packet->header.version !=3D BATADV_COMPAT_VERSION) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: incompatible batman version (%i)\n",
-			   batman_ogm_packet->header.version);
+			   batadv_ogm_packet->header.version);
 		goto err_free;
 	}
=20
 	/* all receive handlers return whether they received or reused
 	 * the supplied skb. if not, we have to free the skb.
 	 */
-	idx =3D batman_ogm_packet->header.packet_type;
+	idx =3D batadv_ogm_packet->header.packet_type;
 	ret =3D (*batadv_rx_handler[idx])(skb, hard_iface);
=20
 	if (ret =3D=3D NET_RX_DROP)
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 59e328a..8d3e55a 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -101,20 +101,20 @@ enum batadv_bla_claimframe {
 /* the destination hardware field in the ARP frame is used to
  * transport the claim type and the group id
  */
-struct bla_claim_dst {
+struct batadv_bla_claim_dst {
 	uint8_t magic[3];	/* FF:43:05 */
 	uint8_t type;		/* bla_claimframe */
 	__be16 group;		/* group id */
 } __packed;
=20
-struct batman_header {
+struct batadv_header {
 	uint8_t  packet_type;
 	uint8_t  version;  /* batman version field */
 	uint8_t  ttl;
 } __packed;
=20
-struct batman_ogm_packet {
-	struct batman_header header;
+struct batadv_ogm_packet {
+	struct batadv_header header;
 	uint8_t  flags;    /* 0x40: DIRECTLINK flag, 0x20 VIS_SERVER flag... =
*/
 	__be32   seqno;
 	uint8_t  orig[ETH_ALEN];
@@ -126,10 +126,10 @@ struct batman_ogm_packet {
 	__be16   tt_crc;
 } __packed;
=20
-#define BATADV_OGM_HLEN sizeof(struct batman_ogm_packet)
+#define BATADV_OGM_HLEN sizeof(struct batadv_ogm_packet)
=20
-struct icmp_packet {
-	struct batman_header header;
+struct batadv_icmp_packet {
+	struct batadv_header header;
 	uint8_t  msg_type; /* see ICMP message types above */
 	uint8_t  dst[ETH_ALEN];
 	uint8_t  orig[ETH_ALEN];
@@ -143,8 +143,8 @@ struct icmp_packet {
 /* icmp_packet_rr must start with all fields from imcp_packet
  * as this is assumed by code that handles ICMP packets
  */
-struct icmp_packet_rr {
-	struct batman_header header;
+struct batadv_icmp_packet_rr {
+	struct batadv_header header;
 	uint8_t  msg_type; /* see ICMP message types above */
 	uint8_t  dst[ETH_ALEN];
 	uint8_t  orig[ETH_ALEN];
@@ -154,14 +154,14 @@ struct icmp_packet_rr {
 	uint8_t  rr[BATADV_RR_LEN][ETH_ALEN];
 } __packed;
=20
-struct unicast_packet {
-	struct batman_header header;
+struct batadv_unicast_packet {
+	struct batadv_header header;
 	uint8_t  ttvn; /* destination translation table version number */
 	uint8_t  dest[ETH_ALEN];
 } __packed;
=20
-struct unicast_frag_packet {
-	struct batman_header header;
+struct batadv_unicast_frag_packet {
+	struct batadv_header header;
 	uint8_t  ttvn; /* destination translation table version number */
 	uint8_t  dest[ETH_ALEN];
 	uint8_t  flags;
@@ -170,15 +170,15 @@ struct unicast_frag_packet {
 	__be16   seqno;
 } __packed;
=20
-struct bcast_packet {
-	struct batman_header header;
+struct batadv_bcast_packet {
+	struct batadv_header header;
 	uint8_t  reserved;
 	__be32   seqno;
 	uint8_t  orig[ETH_ALEN];
 } __packed;
=20
-struct vis_packet {
-	struct batman_header header;
+struct batadv_vis_packet {
+	struct batadv_header header;
 	uint8_t  vis_type;	 /* which type of vis-participant sent this? */
 	__be32   seqno;		 /* sequence number */
 	uint8_t  entries;	 /* number of entries behind this struct */
@@ -188,8 +188,8 @@ struct vis_packet {
 	uint8_t  sender_orig[ETH_ALEN]; /* who sent or forwarded this packet =
*/
 } __packed;
=20
-struct tt_query_packet {
-	struct batman_header header;
+struct batadv_tt_query_packet {
+	struct batadv_header header;
 	/* the flag field is a combination of:
 	 * - TT_REQUEST or TT_RESPONSE
 	 * - TT_FULL_TABLE
@@ -212,15 +212,15 @@ struct tt_query_packet {
 	__be16 tt_data;
 } __packed;
=20
-struct roam_adv_packet {
-	struct batman_header header;
+struct batadv_roam_adv_packet {
+	struct batadv_header header;
 	uint8_t  reserved;
 	uint8_t  dst[ETH_ALEN];
 	uint8_t  src[ETH_ALEN];
 	uint8_t  client[ETH_ALEN];
 } __packed;
=20
-struct tt_change {
+struct batadv_tt_change {
 	uint8_t flags;
 	uint8_t addr[ETH_ALEN];
 } __packed;
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 86d444a..e157907 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -217,7 +217,7 @@ out:
 void
 batadv_bonding_save_primary(const struct orig_node *orig_node,
 			    struct orig_node *orig_neigh_node,
-			    const struct batman_ogm_packet *batman_ogm_packet)
+			    const struct batadv_ogm_packet *batman_ogm_packet)
 {
 	if (!(batman_ogm_packet->flags & BATADV_PRIMARIES_FIRST_HOP))
 		return;
@@ -284,10 +284,10 @@ static int batadv_recv_my_icmp_packet(struct bat_=
priv *bat_priv,
 	struct hard_iface *primary_if =3D NULL;
 	struct orig_node *orig_node =3D NULL;
 	struct neigh_node *router =3D NULL;
-	struct icmp_packet_rr *icmp_packet;
+	struct batadv_icmp_packet_rr *icmp_packet;
 	int ret =3D NET_RX_DROP;
=20
-	icmp_packet =3D (struct icmp_packet_rr *)skb->data;
+	icmp_packet =3D (struct batadv_icmp_packet_rr *)skb->data;
=20
 	/* add data to device queue */
 	if (icmp_packet->msg_type !=3D BATADV_ECHO_REQUEST) {
@@ -313,7 +313,7 @@ static int batadv_recv_my_icmp_packet(struct bat_pr=
iv *bat_priv,
 	if (skb_cow(skb, ETH_HLEN) < 0)
 		goto out;
=20
-	icmp_packet =3D (struct icmp_packet_rr *)skb->data;
+	icmp_packet =3D (struct batadv_icmp_packet_rr *)skb->data;
=20
 	memcpy(icmp_packet->dst, icmp_packet->orig, ETH_ALEN);
 	memcpy(icmp_packet->orig, primary_if->net_dev->dev_addr, ETH_ALEN);
@@ -339,10 +339,10 @@ static int batadv_recv_icmp_ttl_exceeded(struct b=
at_priv *bat_priv,
 	struct hard_iface *primary_if =3D NULL;
 	struct orig_node *orig_node =3D NULL;
 	struct neigh_node *router =3D NULL;
-	struct icmp_packet *icmp_packet;
+	struct batadv_icmp_packet *icmp_packet;
 	int ret =3D NET_RX_DROP;
=20
-	icmp_packet =3D (struct icmp_packet *)skb->data;
+	icmp_packet =3D (struct batadv_icmp_packet *)skb->data;
=20
 	/* send TTL exceeded if packet is an echo request (traceroute) */
 	if (icmp_packet->msg_type !=3D BATADV_ECHO_REQUEST) {
@@ -368,7 +368,7 @@ static int batadv_recv_icmp_ttl_exceeded(struct bat=
_priv *bat_priv,
 	if (skb_cow(skb, ETH_HLEN) < 0)
 		goto out;
=20
-	icmp_packet =3D (struct icmp_packet *)skb->data;
+	icmp_packet =3D (struct batadv_icmp_packet *)skb->data;
=20
 	memcpy(icmp_packet->dst, icmp_packet->orig, ETH_ALEN);
 	memcpy(icmp_packet->orig, primary_if->net_dev->dev_addr, ETH_ALEN);
@@ -392,16 +392,16 @@ out:
 int batadv_recv_icmp_packet(struct sk_buff *skb, struct hard_iface *re=
cv_if)
 {
 	struct bat_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
-	struct icmp_packet_rr *icmp_packet;
+	struct batadv_icmp_packet_rr *icmp_packet;
 	struct ethhdr *ethhdr;
 	struct orig_node *orig_node =3D NULL;
 	struct neigh_node *router =3D NULL;
-	int hdr_size =3D sizeof(struct icmp_packet);
+	int hdr_size =3D sizeof(struct batadv_icmp_packet);
 	int ret =3D NET_RX_DROP;
=20
 	/* we truncate all incoming icmp packets if they don't match our size=
 */
-	if (skb->len >=3D sizeof(struct icmp_packet_rr))
-		hdr_size =3D sizeof(struct icmp_packet_rr);
+	if (skb->len >=3D sizeof(struct batadv_icmp_packet_rr))
+		hdr_size =3D sizeof(struct batadv_icmp_packet_rr);
=20
 	/* drop packet if it has not necessary minimum size */
 	if (unlikely(!pskb_may_pull(skb, hdr_size)))
@@ -421,10 +421,10 @@ int batadv_recv_icmp_packet(struct sk_buff *skb, =
struct hard_iface *recv_if)
 	if (!batadv_is_my_mac(ethhdr->h_dest))
 		goto out;
=20
-	icmp_packet =3D (struct icmp_packet_rr *)skb->data;
+	icmp_packet =3D (struct batadv_icmp_packet_rr *)skb->data;
=20
 	/* add record route information if not full */
-	if ((hdr_size =3D=3D sizeof(struct icmp_packet_rr)) &&
+	if ((hdr_size =3D=3D sizeof(struct batadv_icmp_packet_rr)) &&
 	    (icmp_packet->rr_cur < BATADV_RR_LEN)) {
 		memcpy(&(icmp_packet->rr[icmp_packet->rr_cur]),
 		       ethhdr->h_dest, ETH_ALEN);
@@ -452,7 +452,7 @@ int batadv_recv_icmp_packet(struct sk_buff *skb, st=
ruct hard_iface *recv_if)
 	if (skb_cow(skb, ETH_HLEN) < 0)
 		goto out;
=20
-	icmp_packet =3D (struct icmp_packet_rr *)skb->data;
+	icmp_packet =3D (struct batadv_icmp_packet_rr *)skb->data;
=20
 	/* decrement ttl */
 	icmp_packet->header.ttl--;
@@ -580,17 +580,19 @@ batadv_find_ifalter_router(struct orig_node *prim=
ary_orig,
 int batadv_recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_=
if)
 {
 	struct bat_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
-	struct tt_query_packet *tt_query;
+	struct batadv_tt_query_packet *tt_query;
 	uint16_t tt_size;
 	struct ethhdr *ethhdr;
 	char tt_flag;
+	size_t packet_size;
=20
 	/* drop packet if it has not necessary minimum size */
-	if (unlikely(!pskb_may_pull(skb, sizeof(struct tt_query_packet))))
+	if (unlikely(!pskb_may_pull(skb,
+				    sizeof(struct batadv_tt_query_packet))))
 		goto out;
=20
 	/* I could need to modify it */
-	if (skb_cow(skb, sizeof(struct tt_query_packet)) < 0)
+	if (skb_cow(skb, sizeof(struct batadv_tt_query_packet)) < 0)
 		goto out;
=20
 	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
@@ -603,7 +605,7 @@ int batadv_recv_tt_query(struct sk_buff *skb, struc=
t hard_iface *recv_if)
 	if (is_broadcast_ether_addr(ethhdr->h_source))
 		goto out;
=20
-	tt_query =3D (struct tt_query_packet *)skb->data;
+	tt_query =3D (struct batadv_tt_query_packet *)skb->data;
=20
 	switch (tt_query->flags & BATADV_TT_QUERY_TYPE_MASK) {
 	case BATADV_TT_REQUEST:
@@ -635,13 +637,14 @@ int batadv_recv_tt_query(struct sk_buff *skb, str=
uct hard_iface *recv_if)
 			if (skb_linearize(skb) < 0)
 				goto out;
 			/* skb_linearize() possibly changed skb->data */
-			tt_query =3D (struct tt_query_packet *)skb->data;
+			tt_query =3D (struct batadv_tt_query_packet *)skb->data;
=20
 			tt_size =3D batadv_tt_len(ntohs(tt_query->tt_data));
=20
 			/* Ensure we have all the claimed data */
-			if (unlikely(skb_headlen(skb) <
-				     sizeof(struct tt_query_packet) + tt_size))
+			packet_size =3D sizeof(struct batadv_tt_query_packet);
+			packet_size +=3D tt_size;
+			if (unlikely(skb_headlen(skb) < packet_size))
 				goto out;
=20
 			batadv_handle_tt_response(bat_priv, tt_query);
@@ -667,12 +670,13 @@ out:
 int batadv_recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_=
if)
 {
 	struct bat_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
-	struct roam_adv_packet *roam_adv_packet;
+	struct batadv_roam_adv_packet *roam_adv_packet;
 	struct orig_node *orig_node;
 	struct ethhdr *ethhdr;
=20
 	/* drop packet if it has not necessary minimum size */
-	if (unlikely(!pskb_may_pull(skb, sizeof(struct roam_adv_packet))))
+	if (unlikely(!pskb_may_pull(skb,
+				    sizeof(struct batadv_roam_adv_packet))))
 		goto out;
=20
 	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
@@ -687,7 +691,7 @@ int batadv_recv_roam_adv(struct sk_buff *skb, struc=
t hard_iface *recv_if)
=20
 	batadv_inc_counter(bat_priv, BATADV_CNT_TT_ROAM_ADV_RX);
=20
-	roam_adv_packet =3D (struct roam_adv_packet *)skb->data;
+	roam_adv_packet =3D (struct batadv_roam_adv_packet *)skb->data;
=20
 	if (!batadv_is_my_mac(roam_adv_packet->dst))
 		return batadv_route_unicast_packet(skb, recv_if);
@@ -843,12 +847,12 @@ static int batadv_route_unicast_packet(struct sk_=
buff *skb,
 	struct bat_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
 	struct orig_node *orig_node =3D NULL;
 	struct neigh_node *neigh_node =3D NULL;
-	struct unicast_packet *unicast_packet;
+	struct batadv_unicast_packet *unicast_packet;
 	struct ethhdr *ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
 	int ret =3D NET_RX_DROP;
 	struct sk_buff *new_skb;
=20
-	unicast_packet =3D (struct unicast_packet *)skb->data;
+	unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
=20
 	/* TTL exceeded */
 	if (unicast_packet->header.ttl < 2) {
@@ -873,7 +877,7 @@ static int batadv_route_unicast_packet(struct sk_bu=
ff *skb,
 	if (skb_cow(skb, ETH_HLEN) < 0)
 		goto out;
=20
-	unicast_packet =3D (struct unicast_packet *)skb->data;
+	unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
=20
 	if (unicast_packet->header.packet_type =3D=3D BATADV_UNICAST &&
 	    atomic_read(&bat_priv->fragmentation) &&
@@ -900,7 +904,7 @@ static int batadv_route_unicast_packet(struct sk_bu=
ff *skb,
 		}
=20
 		skb =3D new_skb;
-		unicast_packet =3D (struct unicast_packet *)skb->data;
+		unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
 	}
=20
 	/* decrement ttl */
@@ -929,15 +933,15 @@ static int batadv_check_unicast_ttvn(struct bat_p=
riv *bat_priv,
 	struct orig_node *orig_node;
 	struct ethhdr *ethhdr;
 	struct hard_iface *primary_if;
-	struct unicast_packet *unicast_packet;
+	struct batadv_unicast_packet *unicast_packet;
 	bool tt_poss_change;
 	int is_old_ttvn;
=20
 	/* I could need to modify it */
-	if (skb_cow(skb, sizeof(struct unicast_packet)) < 0)
+	if (skb_cow(skb, sizeof(struct batadv_unicast_packet)) < 0)
 		return 0;
=20
-	unicast_packet =3D (struct unicast_packet *)skb->data;
+	unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
=20
 	if (batadv_is_my_mac(unicast_packet->dest)) {
 		tt_poss_change =3D bat_priv->tt_poss_change;
@@ -958,12 +962,12 @@ static int batadv_check_unicast_ttvn(struct bat_p=
riv *bat_priv,
 	is_old_ttvn =3D batadv_seq_before(unicast_packet->ttvn, curr_ttvn);
 	if (is_old_ttvn || tt_poss_change) {
 		/* check if there is enough data before accessing it */
-		if (pskb_may_pull(skb, sizeof(struct unicast_packet) +
+		if (pskb_may_pull(skb, sizeof(struct batadv_unicast_packet) +
 				  ETH_HLEN) < 0)
 			return 0;
=20
 		ethhdr =3D (struct ethhdr *)(skb->data +
-			sizeof(struct unicast_packet));
+			sizeof(struct batadv_unicast_packet));
=20
 		/* we don't have an updated route for this client, so we should
 		 * not try to reroute the packet!!
@@ -1005,7 +1009,7 @@ static int batadv_check_unicast_ttvn(struct bat_p=
riv *bat_priv,
 int batadv_recv_unicast_packet(struct sk_buff *skb, struct hard_iface =
*recv_if)
 {
 	struct bat_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
-	struct unicast_packet *unicast_packet;
+	struct batadv_unicast_packet *unicast_packet;
 	int hdr_size =3D sizeof(*unicast_packet);
=20
 	if (batadv_check_unicast_packet(skb, hdr_size) < 0)
@@ -1014,7 +1018,7 @@ int batadv_recv_unicast_packet(struct sk_buff *sk=
b, struct hard_iface *recv_if)
 	if (!batadv_check_unicast_ttvn(bat_priv, skb))
 		return NET_RX_DROP;
=20
-	unicast_packet =3D (struct unicast_packet *)skb->data;
+	unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
=20
 	/* packet for me */
 	if (batadv_is_my_mac(unicast_packet->dest)) {
@@ -1030,7 +1034,7 @@ int batadv_recv_ucast_frag_packet(struct sk_buff =
*skb,
 				  struct hard_iface *recv_if)
 {
 	struct bat_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
-	struct unicast_frag_packet *unicast_packet;
+	struct batadv_unicast_frag_packet *unicast_packet;
 	int hdr_size =3D sizeof(*unicast_packet);
 	struct sk_buff *new_skb =3D NULL;
 	int ret;
@@ -1041,7 +1045,7 @@ int batadv_recv_ucast_frag_packet(struct sk_buff =
*skb,
 	if (!batadv_check_unicast_ttvn(bat_priv, skb))
 		return NET_RX_DROP;
=20
-	unicast_packet =3D (struct unicast_frag_packet *)skb->data;
+	unicast_packet =3D (struct batadv_unicast_frag_packet *)skb->data;
=20
 	/* packet for me */
 	if (batadv_is_my_mac(unicast_packet->dest)) {
@@ -1056,7 +1060,7 @@ int batadv_recv_ucast_frag_packet(struct sk_buff =
*skb,
 			return NET_RX_SUCCESS;
=20
 		batadv_interface_rx(recv_if->soft_iface, new_skb, recv_if,
-				    sizeof(struct unicast_packet));
+				    sizeof(struct batadv_unicast_packet));
 		return NET_RX_SUCCESS;
 	}
=20
@@ -1068,7 +1072,7 @@ int batadv_recv_bcast_packet(struct sk_buff *skb,=
 struct hard_iface *recv_if)
 {
 	struct bat_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
 	struct orig_node *orig_node =3D NULL;
-	struct bcast_packet *bcast_packet;
+	struct batadv_bcast_packet *bcast_packet;
 	struct ethhdr *ethhdr;
 	int hdr_size =3D sizeof(*bcast_packet);
 	int ret =3D NET_RX_DROP;
@@ -1092,7 +1096,7 @@ int batadv_recv_bcast_packet(struct sk_buff *skb,=
 struct hard_iface *recv_if)
 	if (batadv_is_my_mac(ethhdr->h_source))
 		goto out;
=20
-	bcast_packet =3D (struct bcast_packet *)skb->data;
+	bcast_packet =3D (struct batadv_bcast_packet *)skb->data;
=20
 	/* ignore broadcasts originated by myself */
 	if (batadv_is_my_mac(bcast_packet->orig))
@@ -1156,7 +1160,7 @@ out:
=20
 int batadv_recv_vis_packet(struct sk_buff *skb, struct hard_iface *rec=
v_if)
 {
-	struct vis_packet *vis_packet;
+	struct batadv_vis_packet *vis_packet;
 	struct ethhdr *ethhdr;
 	struct bat_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
 	int hdr_size =3D sizeof(*vis_packet);
@@ -1168,7 +1172,7 @@ int batadv_recv_vis_packet(struct sk_buff *skb, s=
truct hard_iface *recv_if)
 	if (unlikely(!pskb_may_pull(skb, hdr_size)))
 		return NET_RX_DROP;
=20
-	vis_packet =3D (struct vis_packet *)skb->data;
+	vis_packet =3D (struct batadv_vis_packet *)skb->data;
 	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
=20
 	/* not for me */
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index c3fd219..ead4ae0 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -43,7 +43,7 @@ void batadv_bonding_candidate_add(struct orig_node *o=
rig_node,
 				  struct neigh_node *neigh_node);
 void batadv_bonding_save_primary(const struct orig_node *orig_node,
 				 struct orig_node *orig_neigh_node,
-				 const struct batman_ogm_packet
+				 const struct batadv_ogm_packet
 				 *batman_ogm_packet);
 int batadv_window_protected(struct bat_priv *bat_priv, int32_t seq_num=
_diff,
 			    unsigned long *last_reset);
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index aad9818..67c1c6c 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -138,7 +138,7 @@ int batadv_add_bcast_packet_to_list(struct bat_priv=
 *bat_priv,
 {
 	struct hard_iface *primary_if =3D NULL;
 	struct forw_packet *forw_packet;
-	struct bcast_packet *bcast_packet;
+	struct batadv_bcast_packet *bcast_packet;
 	struct sk_buff *newskb;
=20
 	if (!batadv_atomic_dec_not_zero(&bat_priv->bcast_queue_left)) {
@@ -161,7 +161,7 @@ int batadv_add_bcast_packet_to_list(struct bat_priv=
 *bat_priv,
 		goto packet_free;
=20
 	/* as we have a copy now, it is safe to decrease the TTL */
-	bcast_packet =3D (struct bcast_packet *)newskb->data;
+	bcast_packet =3D (struct batadv_bcast_packet *)newskb->data;
 	bcast_packet->header.ttl--;
=20
 	skb_reset_mac_header(newskb);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 0a00324..0a5d73a 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -133,7 +133,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	struct ethhdr *ethhdr =3D (struct ethhdr *)skb->data;
 	struct bat_priv *bat_priv =3D netdev_priv(soft_iface);
 	struct hard_iface *primary_if =3D NULL;
-	struct bcast_packet *bcast_packet;
+	struct batadv_bcast_packet *bcast_packet;
 	struct vlan_ethhdr *vhdr;
 	__be16 ethertype =3D __constant_htons(BATADV_ETH_P_BATMAN);
 	static const uint8_t stp_addr[ETH_ALEN] =3D {0x01, 0x80, 0xC2, 0x00, =
0x00,
@@ -208,7 +208,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 		if (batadv_skb_head_push(skb, sizeof(*bcast_packet)) < 0)
 			goto dropped;
=20
-		bcast_packet =3D (struct bcast_packet *)skb->data;
+		bcast_packet =3D (struct batadv_bcast_packet *)skb->data;
 		bcast_packet->header.version =3D BATADV_COMPAT_VERSION;
 		bcast_packet->header.ttl =3D BATADV_TTL;
=20
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/transl=
ation-table.c
index 9b35d1f..48217cc 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -212,7 +212,7 @@ unlock:
=20
 int batadv_tt_len(int changes_num)
 {
-	return changes_num * sizeof(struct tt_change);
+	return changes_num * sizeof(struct batadv_tt_change);
 }
=20
 static int batadv_tt_local_init(struct bat_priv *bat_priv)
@@ -384,7 +384,7 @@ static int batadv_tt_changes_fill_buff(struct bat_p=
riv *bat_priv,
 				 list) {
 		if (count < tot_changes) {
 			memcpy(tt_buff + batadv_tt_len(count),
-			       &entry->change, sizeof(struct tt_change));
+			       &entry->change, sizeof(struct batadv_tt_change));
 			count++;
 		}
 		list_del(&entry->list);
@@ -1366,31 +1366,32 @@ batadv_tt_response_fill_table(uint16_t tt_len, =
uint8_t ttvn,
 			      void *cb_data)
 {
 	struct tt_common_entry *tt_common_entry;
-	struct tt_query_packet *tt_response;
-	struct tt_change *tt_change;
+	struct batadv_tt_query_packet *tt_response;
+	struct batadv_tt_change *tt_change;
 	struct hlist_node *node;
 	struct hlist_head *head;
 	struct sk_buff *skb =3D NULL;
 	uint16_t tt_tot, tt_count;
-	ssize_t tt_query_size =3D sizeof(struct tt_query_packet);
+	ssize_t tt_query_size =3D sizeof(struct batadv_tt_query_packet);
 	uint32_t i;
+	size_t len;
=20
 	if (tt_query_size + tt_len > primary_if->soft_iface->mtu) {
 		tt_len =3D primary_if->soft_iface->mtu - tt_query_size;
-		tt_len -=3D tt_len % sizeof(struct tt_change);
+		tt_len -=3D tt_len % sizeof(struct batadv_tt_change);
 	}
-	tt_tot =3D tt_len / sizeof(struct tt_change);
+	tt_tot =3D tt_len / sizeof(struct batadv_tt_change);
=20
-	skb =3D dev_alloc_skb(tt_query_size + tt_len + ETH_HLEN);
+	len =3D tt_query_size + tt_len;
+	skb =3D dev_alloc_skb(len + ETH_HLEN);
 	if (!skb)
 		goto out;
=20
 	skb_reserve(skb, ETH_HLEN);
-	tt_response =3D (struct tt_query_packet *)skb_put(skb,
-						     tt_query_size + tt_len);
+	tt_response =3D (struct batadv_tt_query_packet *)skb_put(skb, len);
 	tt_response->ttvn =3D ttvn;
=20
-	tt_change =3D (struct tt_change *)(skb->data + tt_query_size);
+	tt_change =3D (struct batadv_tt_change *)(skb->data + tt_query_size);
 	tt_count =3D 0;
=20
 	rcu_read_lock();
@@ -1430,11 +1431,12 @@ static int batadv_send_tt_request(struct bat_pr=
iv *bat_priv,
 				  bool full_table)
 {
 	struct sk_buff *skb =3D NULL;
-	struct tt_query_packet *tt_request;
+	struct batadv_tt_query_packet *tt_request;
 	struct neigh_node *neigh_node =3D NULL;
 	struct hard_iface *primary_if;
 	struct tt_req_node *tt_req_node =3D NULL;
 	int ret =3D 1;
+	size_t tt_req_len;
=20
 	primary_if =3D batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
@@ -1447,14 +1449,14 @@ static int batadv_send_tt_request(struct bat_pr=
iv *bat_priv,
 	if (!tt_req_node)
 		goto out;
=20
-	skb =3D dev_alloc_skb(sizeof(struct tt_query_packet) + ETH_HLEN);
+	skb =3D dev_alloc_skb(sizeof(*tt_request) + ETH_HLEN);
 	if (!skb)
 		goto out;
=20
 	skb_reserve(skb, ETH_HLEN);
=20
-	tt_request =3D (struct tt_query_packet *)skb_put(skb,
-				sizeof(struct tt_query_packet));
+	tt_req_len =3D sizeof(*tt_request);
+	tt_request =3D (struct batadv_tt_query_packet *)skb_put(skb, tt_req_l=
en);
=20
 	tt_request->header.packet_type =3D BATADV_TT_QUERY;
 	tt_request->header.version =3D BATADV_COMPAT_VERSION;
@@ -1498,8 +1500,9 @@ out:
 	return ret;
 }
=20
-static bool batadv_send_other_tt_response(struct bat_priv *bat_priv,
-					  struct tt_query_packet *tt_request)
+static bool
+batadv_send_other_tt_response(struct bat_priv *bat_priv,
+			      struct batadv_tt_query_packet *tt_request)
 {
 	struct orig_node *req_dst_orig_node =3D NULL, *res_dst_orig_node =3D =
NULL;
 	struct neigh_node *neigh_node =3D NULL;
@@ -1510,7 +1513,8 @@ static bool batadv_send_other_tt_response(struct =
bat_priv *bat_priv,
 	bool full_table;
 	uint16_t tt_len, tt_tot;
 	struct sk_buff *skb =3D NULL;
-	struct tt_query_packet *tt_response;
+	struct batadv_tt_query_packet *tt_response;
+	size_t len;
=20
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Received TT_REQUEST from %pM for ttvn: %u (%pM) [%c]\n",
@@ -1555,28 +1559,28 @@ static bool batadv_send_other_tt_response(struc=
t bat_priv *bat_priv,
 	if (!full_table) {
 		spin_lock_bh(&req_dst_orig_node->tt_buff_lock);
 		tt_len =3D req_dst_orig_node->tt_buff_len;
-		tt_tot =3D tt_len / sizeof(struct tt_change);
+		tt_tot =3D tt_len / sizeof(struct batadv_tt_change);
=20
-		skb =3D dev_alloc_skb(sizeof(struct tt_query_packet) +
-				    tt_len + ETH_HLEN);
+		len =3D sizeof(*tt_response) + tt_len;
+		skb =3D dev_alloc_skb(len + ETH_HLEN);
 		if (!skb)
 			goto unlock;
=20
 		skb_reserve(skb, ETH_HLEN);
-		tt_response =3D (struct tt_query_packet *)skb_put(skb,
-				sizeof(struct tt_query_packet) + tt_len);
+		tt_response =3D (struct batadv_tt_query_packet *)skb_put(skb,
+								       len);
 		tt_response->ttvn =3D req_ttvn;
 		tt_response->tt_data =3D htons(tt_tot);
=20
-		tt_buff =3D skb->data + sizeof(struct tt_query_packet);
+		tt_buff =3D skb->data + sizeof(*tt_response);
 		/* Copy the last orig_node's OGM buffer */
 		memcpy(tt_buff, req_dst_orig_node->tt_buff,
 		       req_dst_orig_node->tt_buff_len);
=20
 		spin_unlock_bh(&req_dst_orig_node->tt_buff_lock);
 	} else {
-		tt_len =3D (uint16_t)atomic_read(&req_dst_orig_node->tt_size) *
-						sizeof(struct tt_change);
+		tt_len =3D (uint16_t)atomic_read(&req_dst_orig_node->tt_size);
+		tt_len *=3D sizeof(struct batadv_tt_change);
 		ttvn =3D (uint8_t)atomic_read(&req_dst_orig_node->last_ttvn);
=20
 		skb =3D batadv_tt_response_fill_table(tt_len, ttvn,
@@ -1587,7 +1591,7 @@ static bool batadv_send_other_tt_response(struct =
bat_priv *bat_priv,
 		if (!skb)
 			goto out;
=20
-		tt_response =3D (struct tt_query_packet *)skb->data;
+		tt_response =3D (struct batadv_tt_query_packet *)skb->data;
 	}
=20
 	tt_response->header.packet_type =3D BATADV_TT_QUERY;
@@ -1628,8 +1632,10 @@ out:
 	return ret;
=20
 }
-static bool batadv_send_my_tt_response(struct bat_priv *bat_priv,
-				       struct tt_query_packet *tt_request)
+
+static bool
+batadv_send_my_tt_response(struct bat_priv *bat_priv,
+			   struct batadv_tt_query_packet *tt_request)
 {
 	struct orig_node *orig_node =3D NULL;
 	struct neigh_node *neigh_node =3D NULL;
@@ -1640,7 +1646,8 @@ static bool batadv_send_my_tt_response(struct bat=
_priv *bat_priv,
 	bool full_table;
 	uint16_t tt_len, tt_tot;
 	struct sk_buff *skb =3D NULL;
-	struct tt_query_packet *tt_response;
+	struct batadv_tt_query_packet *tt_response;
+	size_t len;
=20
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Received TT_REQUEST from %pM for ttvn: %u (me) [%c]\n",
@@ -1678,26 +1685,26 @@ static bool batadv_send_my_tt_response(struct b=
at_priv *bat_priv,
 	if (!full_table) {
 		spin_lock_bh(&bat_priv->tt_buff_lock);
 		tt_len =3D bat_priv->tt_buff_len;
-		tt_tot =3D tt_len / sizeof(struct tt_change);
+		tt_tot =3D tt_len / sizeof(struct batadv_tt_change);
=20
-		skb =3D dev_alloc_skb(sizeof(struct tt_query_packet) +
-				    tt_len + ETH_HLEN);
+		len =3D sizeof(*tt_response) + tt_len;
+		skb =3D dev_alloc_skb(len + ETH_HLEN);
 		if (!skb)
 			goto unlock;
=20
 		skb_reserve(skb, ETH_HLEN);
-		tt_response =3D (struct tt_query_packet *)skb_put(skb,
-				sizeof(struct tt_query_packet) + tt_len);
+		tt_response =3D (struct batadv_tt_query_packet *)skb_put(skb,
+								       len);
 		tt_response->ttvn =3D req_ttvn;
 		tt_response->tt_data =3D htons(tt_tot);
=20
-		tt_buff =3D skb->data + sizeof(struct tt_query_packet);
+		tt_buff =3D skb->data + sizeof(*tt_response);
 		memcpy(tt_buff, bat_priv->tt_buff,
 		       bat_priv->tt_buff_len);
 		spin_unlock_bh(&bat_priv->tt_buff_lock);
 	} else {
-		tt_len =3D (uint16_t)atomic_read(&bat_priv->num_local_tt) *
-						sizeof(struct tt_change);
+		tt_len =3D (uint16_t)atomic_read(&bat_priv->num_local_tt);
+		tt_len *=3D sizeof(struct batadv_tt_change);
 		ttvn =3D (uint8_t)atomic_read(&bat_priv->ttvn);
=20
 		skb =3D batadv_tt_response_fill_table(tt_len, ttvn,
@@ -1708,7 +1715,7 @@ static bool batadv_send_my_tt_response(struct bat=
_priv *bat_priv,
 		if (!skb)
 			goto out;
=20
-		tt_response =3D (struct tt_query_packet *)skb->data;
+		tt_response =3D (struct batadv_tt_query_packet *)skb->data;
 	}
=20
 	tt_response->header.packet_type =3D BATADV_TT_QUERY;
@@ -1748,7 +1755,7 @@ out:
 }
=20
 bool batadv_send_tt_response(struct bat_priv *bat_priv,
-			     struct tt_query_packet *tt_request)
+			     struct batadv_tt_query_packet *tt_request)
 {
 	if (batadv_is_my_mac(tt_request->dst)) {
 		/* don't answer backbone gws! */
@@ -1763,7 +1770,7 @@ bool batadv_send_tt_response(struct bat_priv *bat=
_priv,
=20
 static void _batadv_tt_update_changes(struct bat_priv *bat_priv,
 				      struct orig_node *orig_node,
-				      struct tt_change *tt_change,
+				      struct batadv_tt_change *tt_change,
 				      uint16_t tt_num_changes, uint8_t ttvn)
 {
 	int i;
@@ -1793,7 +1800,7 @@ static void _batadv_tt_update_changes(struct bat_=
priv *bat_priv,
 }
=20
 static void batadv_tt_fill_gtable(struct bat_priv *bat_priv,
-				  struct tt_query_packet *tt_response)
+				  struct batadv_tt_query_packet *tt_response)
 {
 	struct orig_node *orig_node =3D NULL;
=20
@@ -1805,7 +1812,7 @@ static void batadv_tt_fill_gtable(struct bat_priv=
 *bat_priv,
 	batadv_tt_global_del_orig(bat_priv, orig_node, "Received full table")=
;
=20
 	_batadv_tt_update_changes(bat_priv, orig_node,
-				  (struct tt_change *)(tt_response + 1),
+				  (struct batadv_tt_change *)(tt_response + 1),
 				  ntohs(tt_response->tt_data),
 				  tt_response->ttvn);
=20
@@ -1825,7 +1832,7 @@ out:
 static void batadv_tt_update_changes(struct bat_priv *bat_priv,
 				     struct orig_node *orig_node,
 				     uint16_t tt_num_changes, uint8_t ttvn,
-				     struct tt_change *tt_change)
+				     struct batadv_tt_change *tt_change)
 {
 	_batadv_tt_update_changes(bat_priv, orig_node, tt_change,
 				  tt_num_changes, ttvn);
@@ -1856,10 +1863,11 @@ out:
 }
=20
 void batadv_handle_tt_response(struct bat_priv *bat_priv,
-			       struct tt_query_packet *tt_response)
+			       struct batadv_tt_query_packet *tt_response)
 {
 	struct tt_req_node *node, *safe;
 	struct orig_node *orig_node =3D NULL;
+	struct batadv_tt_change *tt_change;
=20
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Received TT_RESPONSE from %pM for ttvn %d t_size: %d [%c]\n",
@@ -1875,13 +1883,14 @@ void batadv_handle_tt_response(struct bat_priv =
*bat_priv,
 	if (!orig_node)
 		goto out;
=20
-	if (tt_response->flags & BATADV_TT_FULL_TABLE)
+	if (tt_response->flags & BATADV_TT_FULL_TABLE) {
 		batadv_tt_fill_gtable(bat_priv, tt_response);
-	else
+	} else {
+		tt_change =3D (struct batadv_tt_change *)(tt_response + 1);
 		batadv_tt_update_changes(bat_priv, orig_node,
 					 ntohs(tt_response->tt_data),
-					 tt_response->ttvn,
-					 (struct tt_change *)(tt_response + 1));
+					 tt_response->ttvn, tt_change);
+	}
=20
 	/* Delete the tt_req_node from pending tt_requests list */
 	spin_lock_bh(&bat_priv->tt_req_list_lock);
@@ -2006,9 +2015,10 @@ static void batadv_send_roam_adv(struct bat_priv=
 *bat_priv, uint8_t *client,
 {
 	struct neigh_node *neigh_node =3D NULL;
 	struct sk_buff *skb =3D NULL;
-	struct roam_adv_packet *roam_adv_packet;
+	struct batadv_roam_adv_packet *roam_adv_packet;
 	int ret =3D 1;
 	struct hard_iface *primary_if;
+	size_t len =3D sizeof(*roam_adv_packet);
=20
 	/* before going on we have to check whether the client has
 	 * already roamed to us too many times
@@ -2016,14 +2026,13 @@ static void batadv_send_roam_adv(struct bat_pri=
v *bat_priv, uint8_t *client,
 	if (!batadv_tt_check_roam_count(bat_priv, client))
 		goto out;
=20
-	skb =3D dev_alloc_skb(sizeof(struct roam_adv_packet) + ETH_HLEN);
+	skb =3D dev_alloc_skb(sizeof(*roam_adv_packet) + ETH_HLEN);
 	if (!skb)
 		goto out;
=20
 	skb_reserve(skb, ETH_HLEN);
=20
-	roam_adv_packet =3D (struct roam_adv_packet *)skb_put(skb,
-					sizeof(struct roam_adv_packet));
+	roam_adv_packet =3D (struct batadv_roam_adv_packet *)skb_put(skb, len=
);
=20
 	roam_adv_packet->header.packet_type =3D BATADV_ROAM_ADV;
 	roam_adv_packet->header.version =3D BATADV_COMPAT_VERSION;
@@ -2255,6 +2264,7 @@ void batadv_tt_update_orig(struct bat_priv *bat_p=
riv,
 {
 	uint8_t orig_ttvn =3D (uint8_t)atomic_read(&orig_node->last_ttvn);
 	bool full_table =3D true;
+	struct batadv_tt_change *tt_change;
=20
 	/* don't care about a backbone gateways updates. */
 	if (batadv_bla_is_backbone_gw_orig(bat_priv, orig_node->orig))
@@ -2275,8 +2285,9 @@ void batadv_tt_update_orig(struct bat_priv *bat_p=
riv,
 			goto request_table;
 		}
=20
+		tt_change =3D (struct batadv_tt_change *)tt_buff;
 		batadv_tt_update_changes(bat_priv, orig_node, tt_num_changes,
-					 ttvn, (struct tt_change *)tt_buff);
+					 ttvn, tt_change);
=20
 		/* Even if we received the precomputed crc with the OGM, we
 		 * prefer to recompute it to spot any possible inconsistency
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/transl=
ation-table.h
index 46b60bd..4e83b29 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -43,10 +43,10 @@ struct orig_node *batadv_transtable_search(struct b=
at_priv *bat_priv,
 					   const uint8_t *addr);
 void batadv_tt_free(struct bat_priv *bat_priv);
 bool batadv_send_tt_response(struct bat_priv *bat_priv,
-			     struct tt_query_packet *tt_request);
+			     struct batadv_tt_query_packet *tt_request);
 bool batadv_is_my_client(struct bat_priv *bat_priv, const uint8_t *add=
r);
 void batadv_handle_tt_response(struct bat_priv *bat_priv,
-			       struct tt_query_packet *tt_response);
+			       struct batadv_tt_query_packet *tt_response);
 bool batadv_is_ap_isolated(struct bat_priv *bat_priv, uint8_t *src,
 			   uint8_t *dst);
 void batadv_tt_update_orig(struct bat_priv *bat_priv,
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 9dddaf1..fb61d9c 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -25,8 +25,8 @@
 #include <linux/kernel.h>
=20
 #define BATADV_HEADER_LEN \
-	(ETH_HLEN + max(sizeof(struct unicast_packet), \
-			sizeof(struct bcast_packet)))
+	(ETH_HLEN + max(sizeof(struct batadv_unicast_packet), \
+			sizeof(struct batadv_bcast_packet)))
=20
 struct hard_iface {
 	struct list_head list;
@@ -211,7 +211,7 @@ struct bat_priv {
 #ifdef CONFIG_BATMAN_ADV_BLA
 	struct bcast_duplist_entry bcast_duplist[BATADV_DUPLIST_SIZE];
 	int bcast_duplist_curr;
-	struct bla_claim_dst claim_dest;
+	struct batadv_bla_claim_dst claim_dest;
 #endif
 	spinlock_t forw_bat_list_lock; /* protects forw_bat_list */
 	spinlock_t forw_bcast_list_lock; /* protects  */
@@ -250,7 +250,7 @@ struct socket_client {
 struct socket_packet {
 	struct list_head list;
 	size_t icmp_len;
-	struct icmp_packet_rr icmp_packet;
+	struct batadv_icmp_packet_rr icmp_packet;
 };
=20
 struct tt_common_entry {
@@ -306,7 +306,7 @@ struct claim {
=20
 struct tt_change_node {
 	struct list_head list;
-	struct tt_change change;
+	struct batadv_tt_change change;
 };
=20
 struct tt_req_node {
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index c460355..8a2a3df 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -34,13 +34,13 @@ batadv_frag_merge_packet(struct list_head *head,
 			 struct frag_packet_list_entry *tfp,
 			 struct sk_buff *skb)
 {
-	struct unicast_frag_packet *up =3D
-		(struct unicast_frag_packet *)skb->data;
+	struct batadv_unicast_frag_packet *up;
 	struct sk_buff *tmp_skb;
-	struct unicast_packet *unicast_packet;
+	struct batadv_unicast_packet *unicast_packet;
 	int hdr_len =3D sizeof(*unicast_packet);
 	int uni_diff =3D sizeof(*up) - hdr_len;
=20
+	up =3D (struct batadv_unicast_frag_packet *)skb->data;
 	/* set skb to the first part and tmp_skb to the second part */
 	if (up->flags & BATADV_UNI_FRAG_HEAD) {
 		tmp_skb =3D tfp->skb;
@@ -65,7 +65,8 @@ batadv_frag_merge_packet(struct list_head *head,
 	kfree_skb(tmp_skb);
=20
 	memmove(skb->data + uni_diff, skb->data, hdr_len);
-	unicast_packet =3D (struct unicast_packet *)skb_pull(skb, uni_diff);
+	unicast_packet =3D (struct batadv_unicast_packet *)skb_pull(skb,
+								  uni_diff);
 	unicast_packet->header.packet_type =3D BATADV_UNICAST;
=20
 	return skb;
@@ -80,8 +81,9 @@ static void batadv_frag_create_entry(struct list_head=
 *head,
 				     struct sk_buff *skb)
 {
 	struct frag_packet_list_entry *tfp;
-	struct unicast_frag_packet *up =3D
-		(struct unicast_frag_packet *)skb->data;
+	struct batadv_unicast_frag_packet *up;
+
+	up =3D (struct batadv_unicast_frag_packet *)skb->data;
=20
 	/* free and oldest packets stand at the end */
 	tfp =3D list_entry((head)->prev, typeof(*tfp), list);
@@ -115,10 +117,10 @@ static int batadv_frag_create_buffer(struct list_=
head *head)
=20
 static struct frag_packet_list_entry *
 batadv_frag_search_packet(struct list_head *head,
-			  const struct unicast_frag_packet *up)
+			  const struct batadv_unicast_frag_packet *up)
 {
 	struct frag_packet_list_entry *tfp;
-	struct unicast_frag_packet *tmp_up =3D NULL;
+	struct batadv_unicast_frag_packet *tmp_up =3D NULL;
 	uint16_t search_seqno;
=20
 	if (up->flags & BATADV_UNI_FRAG_HEAD)
@@ -134,7 +136,7 @@ batadv_frag_search_packet(struct list_head *head,
 		if (tfp->seqno =3D=3D ntohs(up->seqno))
 			goto mov_tail;
=20
-		tmp_up =3D (struct unicast_frag_packet *)tfp->skb->data;
+		tmp_up =3D (struct batadv_unicast_frag_packet *)tfp->skb->data;
=20
 		if (tfp->seqno =3D=3D search_seqno) {
=20
@@ -179,9 +181,9 @@ int batadv_frag_reassemble_skb(struct sk_buff *skb,=
 struct bat_priv *bat_priv,
 	struct orig_node *orig_node;
 	struct frag_packet_list_entry *tmp_frag_entry;
 	int ret =3D NET_RX_DROP;
-	struct unicast_frag_packet *unicast_packet =3D
-		(struct unicast_frag_packet *)skb->data;
+	struct batadv_unicast_frag_packet *unicast_packet;
=20
+	unicast_packet =3D (struct batadv_unicast_frag_packet *)skb->data;
 	*new_skb =3D NULL;
=20
 	orig_node =3D batadv_orig_hash_find(bat_priv, unicast_packet->orig);
@@ -220,10 +222,10 @@ out:
 int batadv_frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_pri=
v,
 			 struct hard_iface *hard_iface, const uint8_t dstaddr[])
 {
-	struct unicast_packet tmp_uc, *unicast_packet;
+	struct batadv_unicast_packet tmp_uc, *unicast_packet;
 	struct hard_iface *primary_if;
 	struct sk_buff *frag_skb;
-	struct unicast_frag_packet *frag1, *frag2;
+	struct batadv_unicast_frag_packet *frag1, *frag2;
 	int uc_hdr_len =3D sizeof(*unicast_packet);
 	int ucf_hdr_len =3D sizeof(*frag1);
 	int data_len =3D skb->len - uc_hdr_len;
@@ -239,7 +241,7 @@ int batadv_frag_send_skb(struct sk_buff *skb, struc=
t bat_priv *bat_priv,
 		goto dropped;
 	skb_reserve(frag_skb, ucf_hdr_len);
=20
-	unicast_packet =3D (struct unicast_packet *)skb->data;
+	unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
 	memcpy(&tmp_uc, unicast_packet, uc_hdr_len);
 	skb_split(skb, frag_skb, data_len / 2 + uc_hdr_len);
=20
@@ -247,8 +249,8 @@ int batadv_frag_send_skb(struct sk_buff *skb, struc=
t bat_priv *bat_priv,
 	    batadv_skb_head_push(frag_skb, ucf_hdr_len) < 0)
 		goto drop_frag;
=20
-	frag1 =3D (struct unicast_frag_packet *)skb->data;
-	frag2 =3D (struct unicast_frag_packet *)frag_skb->data;
+	frag1 =3D (struct batadv_unicast_frag_packet *)skb->data;
+	frag2 =3D (struct batadv_unicast_frag_packet *)frag_skb->data;
=20
 	memcpy(frag1, &tmp_uc, sizeof(tmp_uc));
=20
@@ -287,7 +289,7 @@ out:
 int batadv_unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_=
priv)
 {
 	struct ethhdr *ethhdr =3D (struct ethhdr *)skb->data;
-	struct unicast_packet *unicast_packet;
+	struct batadv_unicast_packet *unicast_packet;
 	struct orig_node *orig_node;
 	struct neigh_node *neigh_node;
 	int data_len =3D skb->len;
@@ -317,7 +319,7 @@ find_router:
 	if (batadv_skb_head_push(skb, sizeof(*unicast_packet)) < 0)
 		goto out;
=20
-	unicast_packet =3D (struct unicast_packet *)skb->data;
+	unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
=20
 	unicast_packet->header.version =3D BATADV_COMPAT_VERSION;
 	/* batman packet type: unicast */
diff --git a/net/batman-adv/unicast.h b/net/batman-adv/unicast.h
index 510e23f..e0b6e33 100644
--- a/net/batman-adv/unicast.h
+++ b/net/batman-adv/unicast.h
@@ -35,11 +35,11 @@ int batadv_frag_send_skb(struct sk_buff *skb, struc=
t bat_priv *bat_priv,
=20
 static inline int batadv_frag_can_reassemble(const struct sk_buff *skb=
, int mtu)
 {
-	const struct unicast_frag_packet *unicast_packet;
+	const struct batadv_unicast_frag_packet *unicast_packet;
 	int uneven_correction =3D 0;
 	unsigned int merged_size;
=20
-	unicast_packet =3D (struct unicast_frag_packet *)skb->data;
+	unicast_packet =3D (struct batadv_unicast_frag_packet *)skb->data;
=20
 	if (unicast_packet->flags & BATADV_UNI_FRAG_LARGETAIL) {
 		if (unicast_packet->flags & BATADV_UNI_FRAG_HEAD)
@@ -49,7 +49,7 @@ static inline int batadv_frag_can_reassemble(const st=
ruct sk_buff *skb, int mtu)
 	}
=20
 	merged_size =3D (skb->len - sizeof(*unicast_packet)) * 2;
-	merged_size +=3D sizeof(struct unicast_packet) + uneven_correction;
+	merged_size +=3D sizeof(struct batadv_unicast_packet) + uneven_correc=
tion;
=20
 	return merged_size <=3D mtu;
 }
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index c1fafa3..309493d 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -53,12 +53,12 @@ static void batadv_free_info(struct kref *ref)
 static int batadv_vis_info_cmp(const struct hlist_node *node, const vo=
id *data2)
 {
 	const struct vis_info *d1, *d2;
-	const struct vis_packet *p1, *p2;
+	const struct batadv_vis_packet *p1, *p2;
=20
 	d1 =3D container_of(node, struct vis_info, hash_entry);
 	d2 =3D data2;
-	p1 =3D (struct vis_packet *)d1->skb_packet->data;
-	p2 =3D (struct vis_packet *)d2->skb_packet->data;
+	p1 =3D (struct batadv_vis_packet *)d1->skb_packet->data;
+	p2 =3D (struct batadv_vis_packet *)d2->skb_packet->data;
 	return batadv_compare_eth(p1->vis_orig, p2->vis_orig);
 }
=20
@@ -68,12 +68,12 @@ static int batadv_vis_info_cmp(const struct hlist_n=
ode *node, const void *data2)
 static uint32_t batadv_vis_info_choose(const void *data, uint32_t size=
)
 {
 	const struct vis_info *vis_info =3D data;
-	const struct vis_packet *packet;
+	const struct batadv_vis_packet *packet;
 	const unsigned char *key;
 	uint32_t hash =3D 0;
 	size_t i;
=20
-	packet =3D (struct vis_packet *)vis_info->skb_packet->data;
+	packet =3D (struct batadv_vis_packet *)vis_info->skb_packet->data;
 	key =3D packet->vis_orig;
 	for (i =3D 0; i < ETH_ALEN; i++) {
 		hash +=3D key[i];
@@ -169,7 +169,7 @@ static ssize_t batadv_vis_data_read_entry(struct se=
q_file *seq,
 }
=20
 static void batadv_vis_data_insert_interfaces(struct hlist_head *list,
-					      struct vis_packet *packet,
+					      struct batadv_vis_packet *packet,
 					      struct vis_info_entry *entries)
 {
 	int i;
@@ -187,7 +187,7 @@ static void batadv_vis_data_insert_interfaces(struc=
t hlist_head *list,
=20
 static void batadv_vis_data_read_entries(struct seq_file *seq,
 					 struct hlist_head *list,
-					 struct vis_packet *packet,
+					 struct batadv_vis_packet *packet,
 					 struct vis_info_entry *entries)
 {
 	int i;
@@ -214,7 +214,7 @@ static void batadv_vis_seq_print_text_bucket(struct=
 seq_file *seq,
 {
 	struct hlist_node *node;
 	struct vis_info *info;
-	struct vis_packet *packet;
+	struct batadv_vis_packet *packet;
 	uint8_t *entries_pos;
 	struct vis_info_entry *entries;
 	struct if_list_entry *entry;
@@ -223,7 +223,7 @@ static void batadv_vis_seq_print_text_bucket(struct=
 seq_file *seq,
 	HLIST_HEAD(vis_if_list);
=20
 	hlist_for_each_entry_rcu(info, node, head, hash_entry) {
-		packet =3D (struct vis_packet *)info->skb_packet->data;
+		packet =3D (struct batadv_vis_packet *)info->skb_packet->data;
 		entries_pos =3D (uint8_t *)packet + sizeof(*packet);
 		entries =3D (struct vis_info_entry *)entries_pos;
=20
@@ -334,15 +334,17 @@ static int batadv_recv_list_is_in(struct bat_priv=
 *bat_priv,
  * is newer than old entries in the hash.
  */
 static struct vis_info *batadv_add_packet(struct bat_priv *bat_priv,
-					  struct vis_packet *vis_packet,
+					  struct batadv_vis_packet *vis_packet,
 					  int vis_info_len, int *is_new,
 					  int make_broadcast)
 {
 	struct vis_info *info, *old_info;
-	struct vis_packet *search_packet, *old_packet;
+	struct batadv_vis_packet *search_packet, *old_packet;
 	struct vis_info search_elem;
-	struct vis_packet *packet;
+	struct batadv_vis_packet *packet;
+	struct sk_buff *tmp_skb;
 	int hash_added;
+	size_t len;
=20
 	*is_new =3D 0;
 	/* sanity check */
@@ -353,15 +355,17 @@ static struct vis_info *batadv_add_packet(struct =
bat_priv *bat_priv,
 	search_elem.skb_packet =3D dev_alloc_skb(sizeof(*search_packet));
 	if (!search_elem.skb_packet)
 		return NULL;
-	search_packet =3D (struct vis_packet *)skb_put(search_elem.skb_packet=
,
-						     sizeof(*search_packet));
+	len =3D sizeof(*search_packet);
+	tmp_skb =3D search_elem.skb_packet;
+	search_packet =3D (struct batadv_vis_packet *)skb_put(tmp_skb, len);
=20
 	memcpy(search_packet->vis_orig, vis_packet->vis_orig, ETH_ALEN);
 	old_info =3D batadv_vis_hash_find(bat_priv, &search_elem);
 	kfree_skb(search_elem.skb_packet);
=20
 	if (old_info) {
-		old_packet =3D (struct vis_packet *)old_info->skb_packet->data;
+		tmp_skb =3D old_info->skb_packet;
+		old_packet =3D (struct batadv_vis_packet *)tmp_skb->data;
 		if (!batadv_seq_after(ntohl(vis_packet->seqno),
 				      ntohl(old_packet->seqno))) {
 			if (old_packet->seqno =3D=3D vis_packet->seqno) {
@@ -385,22 +389,21 @@ static struct vis_info *batadv_add_packet(struct =
bat_priv *bat_priv,
 	if (!info)
 		return NULL;
=20
-	info->skb_packet =3D dev_alloc_skb(sizeof(*packet) + vis_info_len +
-					 ETH_HLEN);
+	len =3D sizeof(*packet) + vis_info_len;
+	info->skb_packet =3D dev_alloc_skb(len + ETH_HLEN);
 	if (!info->skb_packet) {
 		kfree(info);
 		return NULL;
 	}
 	skb_reserve(info->skb_packet, ETH_HLEN);
-	packet =3D (struct vis_packet *)skb_put(info->skb_packet, sizeof(*pac=
ket)
-					      + vis_info_len);
+	packet =3D (struct batadv_vis_packet *)skb_put(info->skb_packet, len)=
;
=20
 	kref_init(&info->refcount);
 	INIT_LIST_HEAD(&info->send_list);
 	INIT_LIST_HEAD(&info->recv_list);
 	info->first_seen =3D jiffies;
 	info->bat_priv =3D bat_priv;
-	memcpy(packet, vis_packet, sizeof(*packet) + vis_info_len);
+	memcpy(packet, vis_packet, len);
=20
 	/* initialize and add new packet. */
 	*is_new =3D 1;
@@ -430,7 +433,7 @@ static struct vis_info *batadv_add_packet(struct ba=
t_priv *bat_priv,
=20
 /* handle the server sync packet, forward if needed. */
 void batadv_receive_server_sync_packet(struct bat_priv *bat_priv,
-				       struct vis_packet *vis_packet,
+				       struct batadv_vis_packet *vis_packet,
 				       int vis_info_len)
 {
 	struct vis_info *info;
@@ -456,11 +459,11 @@ end:
=20
 /* handle an incoming client update packet and schedule forward if nee=
ded. */
 void batadv_receive_client_update_packet(struct bat_priv *bat_priv,
-					 struct vis_packet *vis_packet,
+					 struct batadv_vis_packet *vis_packet,
 					 int vis_info_len)
 {
 	struct vis_info *info;
-	struct vis_packet *packet;
+	struct batadv_vis_packet *packet;
 	int is_new;
 	int vis_server =3D atomic_read(&bat_priv->vis_mode);
 	int are_target =3D 0;
@@ -482,7 +485,7 @@ void batadv_receive_client_update_packet(struct bat=
_priv *bat_priv,
 		goto end;
 	/* note that outdated packets will be dropped at this point. */
=20
-	packet =3D (struct vis_packet *)info->skb_packet->data;
+	packet =3D (struct batadv_vis_packet *)info->skb_packet->data;
=20
 	/* send only if we're the target server or ... */
 	if (are_target && is_new) {
@@ -511,11 +514,11 @@ static int batadv_find_best_vis_server(struct bat=
_priv *bat_priv,
 	struct hlist_node *node;
 	struct hlist_head *head;
 	struct orig_node *orig_node;
-	struct vis_packet *packet;
+	struct batadv_vis_packet *packet;
 	int best_tq =3D -1;
 	uint32_t i;
=20
-	packet =3D (struct vis_packet *)info->skb_packet->data;
+	packet =3D (struct batadv_vis_packet *)info->skb_packet->data;
=20
 	for (i =3D 0; i < hash->size; i++) {
 		head =3D &hash->table[i];
@@ -543,10 +546,10 @@ static int batadv_find_best_vis_server(struct bat=
_priv *bat_priv,
 /* Return true if the vis packet is full. */
 static bool batadv_vis_packet_full(const struct vis_info *info)
 {
-	const struct vis_packet *packet;
+	const struct batadv_vis_packet *packet;
 	size_t num_items;
=20
-	packet =3D (struct vis_packet *)info->skb_packet->data;
+	packet =3D (struct batadv_vis_packet *)info->skb_packet->data;
 	num_items =3D BATADV_MAX_VIS_PACKET_SIZE / sizeof(struct vis_info_ent=
ry);
=20
 	if (num_items < packet->entries + 1)
@@ -565,13 +568,14 @@ static int batadv_generate_vis_packet(struct bat_=
priv *bat_priv)
 	struct orig_node *orig_node;
 	struct neigh_node *router;
 	struct vis_info *info =3D bat_priv->my_vis_info;
-	struct vis_packet *packet =3D (struct vis_packet *)info->skb_packet->=
data;
+	struct batadv_vis_packet *packet;
 	struct vis_info_entry *entry;
 	struct tt_common_entry *tt_common_entry;
 	int best_tq =3D -1;
 	uint32_t i;
=20
 	info->first_seen =3D jiffies;
+	packet =3D (struct batadv_vis_packet *)info->skb_packet->data;
 	packet->vis_type =3D atomic_read(&bat_priv->vis_mode);
=20
 	memcpy(packet->target_orig, batadv_broadcast_addr, ETH_ALEN);
@@ -691,14 +695,14 @@ static void batadv_broadcast_vis_packet(struct ba=
t_priv *bat_priv,
 	struct hlist_node *node;
 	struct hlist_head *head;
 	struct orig_node *orig_node;
-	struct vis_packet *packet;
+	struct batadv_vis_packet *packet;
 	struct sk_buff *skb;
 	struct hard_iface *hard_iface;
 	uint8_t dstaddr[ETH_ALEN];
 	uint32_t i;
=20
=20
-	packet =3D (struct vis_packet *)info->skb_packet->data;
+	packet =3D (struct batadv_vis_packet *)info->skb_packet->data;
=20
 	/* send to all routers in range. */
 	for (i =3D 0; i < hash->size; i++) {
@@ -745,9 +749,9 @@ static void batadv_unicast_vis_packet(struct bat_pr=
iv *bat_priv,
 	struct orig_node *orig_node;
 	struct neigh_node *router =3D NULL;
 	struct sk_buff *skb;
-	struct vis_packet *packet;
+	struct batadv_vis_packet *packet;
=20
-	packet =3D (struct vis_packet *)info->skb_packet->data;
+	packet =3D (struct batadv_vis_packet *)info->skb_packet->data;
=20
 	orig_node =3D batadv_orig_hash_find(bat_priv, packet->target_orig);
 	if (!orig_node)
@@ -773,13 +777,13 @@ static void batadv_send_vis_packet(struct bat_pri=
v *bat_priv,
 				   struct vis_info *info)
 {
 	struct hard_iface *primary_if;
-	struct vis_packet *packet;
+	struct batadv_vis_packet *packet;
=20
 	primary_if =3D batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
=20
-	packet =3D (struct vis_packet *)info->skb_packet->data;
+	packet =3D (struct batadv_vis_packet *)info->skb_packet->data;
 	if (packet->header.ttl < 2) {
 		pr_debug("Error - can't send vis packet: ttl exceeded\n");
 		goto out;
@@ -838,10 +842,11 @@ static void batadv_send_vis_packets(struct work_s=
truct *work)
  */
 int batadv_vis_init(struct bat_priv *bat_priv)
 {
-	struct vis_packet *packet;
+	struct batadv_vis_packet *packet;
 	int hash_added;
 	unsigned int len;
 	unsigned long first_seen;
+	struct sk_buff *tmp_skb;
=20
 	if (bat_priv->vis_hash)
 		return 0;
@@ -864,8 +869,8 @@ int batadv_vis_init(struct bat_priv *bat_priv)
 		goto free_info;
=20
 	skb_reserve(bat_priv->my_vis_info->skb_packet, ETH_HLEN);
-	packet =3D (struct vis_packet *)skb_put(bat_priv->my_vis_info->skb_pa=
cket,
-					      sizeof(*packet));
+	tmp_skb =3D bat_priv->my_vis_info->skb_packet;
+	packet =3D (struct batadv_vis_packet *)skb_put(tmp_skb, sizeof(*packe=
t));
=20
 	/* prefill the vis info */
 	first_seen =3D jiffies - msecs_to_jiffies(BATADV_VIS_INTERVAL);
diff --git a/net/batman-adv/vis.h b/net/batman-adv/vis.h
index 16a1a6b..d6bfcc7 100644
--- a/net/batman-adv/vis.h
+++ b/net/batman-adv/vis.h
@@ -25,10 +25,10 @@
=20
 int batadv_vis_seq_print_text(struct seq_file *seq, void *offset);
 void batadv_receive_server_sync_packet(struct bat_priv *bat_priv,
-				       struct vis_packet *vis_packet,
+				       struct batadv_vis_packet *vis_packet,
 				       int vis_info_len);
 void batadv_receive_client_update_packet(struct bat_priv *bat_priv,
-					 struct vis_packet *vis_packet,
+					 struct batadv_vis_packet *vis_packet,
 					 int vis_info_len);
 int batadv_vis_init(struct bat_priv *bat_priv);
 void batadv_vis_quit(struct bat_priv *bat_priv);
--=20
1.7.9.4
