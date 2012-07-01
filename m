From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 04/16] batman-adv: Prefix packet enum with BATADV_
Date: Mon,  2 Jul 2012 01:43:34 +0200
Message-ID: <1341186226-10549-5-git-send-email-ordex@autistici.org>
References: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:23551 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252Ab2GAXnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 19:43:37 -0400
In-Reply-To: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sven Eckelmann <sven@narfation.org>

Reported-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c            |   48 ++++----
 net/batman-adv/bat_sysfs.c             |   24 ++--
 net/batman-adv/bridge_loop_avoidance.c |   34 +++---
 net/batman-adv/icmp_socket.c           |    8 +-
 net/batman-adv/main.c                  |   14 +--
 net/batman-adv/packet.h                |   88 +++++++--------
 net/batman-adv/routing.c               |   35 +++---
 net/batman-adv/soft-interface.c        |    4 +-
 net/batman-adv/translation-table.c     |  193 ++++++++++++++++--------=
--------
 net/batman-adv/unicast.c               |   18 +--
 net/batman-adv/unicast.h               |    4 +-
 net/batman-adv/vis.c                   |   18 +--
 12 files changed, 255 insertions(+), 233 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 6099719..58bbb20 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -71,7 +71,7 @@ static int batadv_iv_ogm_iface_enable(struct hard_ifa=
ce *hard_iface)
 		goto out;
=20
 	batman_ogm_packet =3D (struct batman_ogm_packet *)hard_iface->packet_=
buff;
-	batman_ogm_packet->header.packet_type =3D BAT_IV_OGM;
+	batman_ogm_packet->header.packet_type =3D BATADV_IV_OGM;
 	batman_ogm_packet->header.version =3D BATADV_COMPAT_VERSION;
 	batman_ogm_packet->header.ttl =3D 2;
 	batman_ogm_packet->flags =3D BATADV_NO_FLAGS;
@@ -107,7 +107,7 @@ static void batadv_iv_ogm_primary_iface_set(struct =
hard_iface *hard_iface)
 	struct batman_ogm_packet *batman_ogm_packet;
=20
 	batman_ogm_packet =3D (struct batman_ogm_packet *)hard_iface->packet_=
buff;
-	batman_ogm_packet->flags =3D PRIMARIES_FIRST_HOP;
+	batman_ogm_packet->flags =3D BATADV_PRIMARIES_FIRST_HOP;
 	batman_ogm_packet->header.ttl =3D BATADV_TTL;
 }
=20
@@ -181,9 +181,9 @@ static void batadv_iv_ogm_send_to_if(struct forw_pa=
cket *forw_packet,
 		 */
 		if ((forw_packet->direct_link_flags & (1 << packet_num)) &&
 		    (forw_packet->if_incoming =3D=3D hard_iface))
-			batman_ogm_packet->flags |=3D DIRECTLINK;
+			batman_ogm_packet->flags |=3D BATADV_DIRECTLINK;
 		else
-			batman_ogm_packet->flags &=3D ~DIRECTLINK;
+			batman_ogm_packet->flags &=3D ~BATADV_DIRECTLINK;
=20
 		fwd_str =3D (packet_num > 0 ? "Forwarding" : (forw_packet->own ?
 							    "Sending own" :
@@ -194,7 +194,7 @@ static void batadv_iv_ogm_send_to_if(struct forw_pa=
cket *forw_packet,
 			   batman_ogm_packet->orig,
 			   ntohl(batman_ogm_packet->seqno),
 			   batman_ogm_packet->tq, batman_ogm_packet->header.ttl,
-			   (batman_ogm_packet->flags & DIRECTLINK ?
+			   (batman_ogm_packet->flags & BATADV_DIRECTLINK ?
 			    "on" : "off"),
 			   batman_ogm_packet->ttvn, hard_iface->net_dev->name,
 			   hard_iface->net_dev->dev_addr);
@@ -228,7 +228,7 @@ static void batadv_iv_ogm_emit(struct forw_packet *=
forw_packet)
=20
 	batman_ogm_packet =3D (struct batman_ogm_packet *)
 						(forw_packet->skb->data);
-	directlink =3D (batman_ogm_packet->flags & DIRECTLINK ? 1 : 0);
+	directlink =3D (batman_ogm_packet->flags & BATADV_DIRECTLINK ? 1 : 0)=
;
=20
 	if (!forw_packet->if_incoming) {
 		pr_err("Error - can't forward packet: incoming iface not specified\n=
");
@@ -330,7 +330,7 @@ batadv_iv_ogm_can_aggregate(const struct batman_ogm=
_packet *new_bat_ogm_packet,
 		 * are flooded through the net
 		 */
 		if ((!directlink) &&
-		    (!(batman_ogm_packet->flags & DIRECTLINK)) &&
+		    (!(batman_ogm_packet->flags & BATADV_DIRECTLINK)) &&
 		    (batman_ogm_packet->header.ttl !=3D 1) &&
=20
 		    /* own packets originating non-primary
@@ -353,7 +353,7 @@ batadv_iv_ogm_can_aggregate(const struct batman_ogm=
_packet *new_bat_ogm_packet,
 		     * own secondary interface packets
 		     * (=3D secondary interface packets in general)
 		     */
-		    (batman_ogm_packet->flags & DIRECTLINK ||
+		    (batman_ogm_packet->flags & BATADV_DIRECTLINK ||
 		     (forw_packet->own &&
 		      forw_packet->if_incoming !=3D primary_if))) {
 			res =3D true;
@@ -480,7 +480,7 @@ static void batadv_iv_ogm_queue_add(struct bat_priv=
 *bat_priv,
 	unsigned long max_aggregation_jiffies;
=20
 	batman_ogm_packet =3D (struct batman_ogm_packet *)packet_buff;
-	direct_link =3D batman_ogm_packet->flags & DIRECTLINK ? 1 : 0;
+	direct_link =3D batman_ogm_packet->flags & BATADV_DIRECTLINK ? 1 : 0;
 	max_aggregation_jiffies =3D msecs_to_jiffies(BATADV_MAX_AGGREGATION_M=
S);
=20
 	/* find position for the packet in the forward queue */
@@ -547,7 +547,7 @@ static void batadv_iv_ogm_forward(struct orig_node =
*orig_node,
 		 * simply drop the ogm.
 		 */
 		if (is_single_hop_neigh)
-			batman_ogm_packet->flags |=3D NOT_BEST_NEXT_HOP;
+			batman_ogm_packet->flags |=3D BATADV_NOT_BEST_NEXT_HOP;
 		else
 			return;
 	}
@@ -566,11 +566,11 @@ static void batadv_iv_ogm_forward(struct orig_nod=
e *orig_node,
 		   batman_ogm_packet->tq, batman_ogm_packet->header.ttl);
=20
 	/* switch of primaries first hop flag when forwarding */
-	batman_ogm_packet->flags &=3D ~PRIMARIES_FIRST_HOP;
+	batman_ogm_packet->flags &=3D ~BATADV_PRIMARIES_FIRST_HOP;
 	if (is_single_hop_neigh)
-		batman_ogm_packet->flags |=3D DIRECTLINK;
+		batman_ogm_packet->flags |=3D BATADV_DIRECTLINK;
 	else
-		batman_ogm_packet->flags &=3D ~DIRECTLINK;
+		batman_ogm_packet->flags &=3D ~BATADV_DIRECTLINK;
=20
 	batadv_iv_ogm_queue_add(bat_priv, (unsigned char *)batman_ogm_packet,
 				BATADV_OGM_HLEN + batadv_tt_len(tt_num_changes),
@@ -605,10 +605,10 @@ static void batadv_iv_ogm_schedule(struct hard_if=
ace *hard_iface)
 	if (tt_num_changes >=3D 0)
 		batman_ogm_packet->tt_num_changes =3D tt_num_changes;
=20
-	if (vis_server =3D=3D VIS_TYPE_SERVER_SYNC)
-		batman_ogm_packet->flags |=3D VIS_SERVER;
+	if (vis_server =3D=3D BATADV_VIS_TYPE_SERVER_SYNC)
+		batman_ogm_packet->flags |=3D BATADV_VIS_SERVER;
 	else
-		batman_ogm_packet->flags &=3D ~VIS_SERVER;
+		batman_ogm_packet->flags &=3D ~BATADV_VIS_SERVER;
=20
 	if ((hard_iface =3D=3D primary_if) &&
 	    (atomic_read(&bat_priv->gw_mode) =3D=3D BATADV_GW_MODE_SERVER))
@@ -746,7 +746,7 @@ update_tt:
 	 */
 	if (((batman_ogm_packet->orig !=3D ethhdr->h_source) &&
 	     (batman_ogm_packet->header.ttl > 2)) ||
-	    (batman_ogm_packet->flags & PRIMARIES_FIRST_HOP))
+	    (batman_ogm_packet->flags & BATADV_PRIMARIES_FIRST_HOP))
 		batadv_tt_update_orig(bat_priv, orig_node, tt_buff,
 				      batman_ogm_packet->tt_num_changes,
 				      batman_ogm_packet->ttvn,
@@ -993,13 +993,16 @@ static void batadv_iv_ogm_process(const struct et=
hhdr *ethhdr,
 	 * packet in an aggregation.  Here we expect that the padding
 	 * is always zero (or not 0x01)
 	 */
-	if (batman_ogm_packet->header.packet_type !=3D BAT_IV_OGM)
+	if (batman_ogm_packet->header.packet_type !=3D BATADV_IV_OGM)
 		return;
=20
 	/* could be changed by schedule_own_packet() */
 	if_incoming_seqno =3D atomic_read(&if_incoming->seqno);
=20
-	has_directlink_flag =3D (batman_ogm_packet->flags & DIRECTLINK ? 1 : =
0);
+	if (batman_ogm_packet->flags & BATADV_DIRECTLINK)
+		has_directlink_flag =3D 1;
+	else
+		has_directlink_flag =3D 0;
=20
 	if (batadv_compare_eth(ethhdr->h_source, batman_ogm_packet->orig))
 		is_single_hop_neigh =3D true;
@@ -1107,7 +1110,7 @@ static void batadv_iv_ogm_process(const struct et=
hhdr *ethhdr,
 		return;
 	}
=20
-	if (batman_ogm_packet->flags & NOT_BEST_NEXT_HOP) {
+	if (batman_ogm_packet->flags & BATADV_NOT_BEST_NEXT_HOP) {
 		batadv_dbg(DBG_BATMAN, bat_priv,
 			   "Drop packet: ignoring all packets not forwarded from the best n=
ext hop (sender: %pM)\n",
 			   ethhdr->h_source);
@@ -1299,7 +1302,8 @@ int __init batadv_iv_init(void)
 	int ret;
=20
 	/* batman originator packet */
-	ret =3D batadv_recv_handler_register(BAT_IV_OGM, batadv_iv_ogm_receiv=
e);
+	ret =3D batadv_recv_handler_register(BATADV_IV_OGM,
+					   batadv_iv_ogm_receive);
 	if (ret < 0)
 		goto out;
=20
@@ -1310,7 +1314,7 @@ int __init batadv_iv_init(void)
 	goto out;
=20
 handler_unregister:
-	batadv_recv_handler_unregister(BAT_IV_OGM);
+	batadv_recv_handler_unregister(BATADV_IV_OGM);
 out:
 	return ret;
 }
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 680caca..e27bfe3 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -283,10 +283,14 @@ static ssize_t batadv_show_vis_mode(struct kobjec=
t *kobj,
 {
 	struct bat_priv *bat_priv =3D batadv_kobj_to_batpriv(kobj);
 	int vis_mode =3D atomic_read(&bat_priv->vis_mode);
+	const char *mode;
=20
-	return sprintf(buff, "%s\n",
-		       vis_mode =3D=3D VIS_TYPE_CLIENT_UPDATE ?
-							"client" : "server");
+	if (vis_mode =3D=3D BATADV_VIS_TYPE_CLIENT_UPDATE)
+		mode =3D "client";
+	else
+		mode =3D "server";
+
+	return sprintf(buff, "%s\n", mode);
 }
=20
 static ssize_t batadv_store_vis_mode(struct kobject *kobj,
@@ -301,14 +305,16 @@ static ssize_t batadv_store_vis_mode(struct kobje=
ct *kobj,
=20
 	ret =3D kstrtoul(buff, 10, &val);
=20
-	if (((count =3D=3D 2) && (!ret) && (val =3D=3D VIS_TYPE_CLIENT_UPDATE=
)) ||
+	if (((count =3D=3D 2) && (!ret) &&
+	     (val =3D=3D BATADV_VIS_TYPE_CLIENT_UPDATE)) ||
 	    (strncmp(buff, "client", 6) =3D=3D 0) ||
 	    (strncmp(buff, "off", 3) =3D=3D 0))
-		vis_mode_tmp =3D VIS_TYPE_CLIENT_UPDATE;
+		vis_mode_tmp =3D BATADV_VIS_TYPE_CLIENT_UPDATE;
=20
-	if (((count =3D=3D 2) && (!ret) && (val =3D=3D VIS_TYPE_SERVER_SYNC))=
 ||
+	if (((count =3D=3D 2) && (!ret) &&
+	     (val =3D=3D BATADV_VIS_TYPE_SERVER_SYNC)) ||
 	    (strncmp(buff, "server", 6) =3D=3D 0))
-		vis_mode_tmp =3D VIS_TYPE_SERVER_SYNC;
+		vis_mode_tmp =3D BATADV_VIS_TYPE_SERVER_SYNC;
=20
 	if (vis_mode_tmp < 0) {
 		if (buff[count - 1] =3D=3D '\n')
@@ -323,12 +329,12 @@ static ssize_t batadv_store_vis_mode(struct kobje=
ct *kobj,
 	if (atomic_read(&bat_priv->vis_mode) =3D=3D vis_mode_tmp)
 		return count;
=20
-	if (atomic_read(&bat_priv->vis_mode) =3D=3D VIS_TYPE_CLIENT_UPDATE)
+	if (atomic_read(&bat_priv->vis_mode) =3D=3D BATADV_VIS_TYPE_CLIENT_UP=
DATE)
 		old_mode =3D  "client";
 	else
 		old_mode =3D "server";
=20
-	if (vis_mode_tmp =3D=3D VIS_TYPE_CLIENT_UPDATE)
+	if (vis_mode_tmp =3D=3D BATADV_VIS_TYPE_CLIENT_UPDATE)
 		new_mode =3D  "client";
 	else
 		new_mode =3D "server";
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/br=
idge_loop_avoidance.c
index 13afc65..c375131 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -292,7 +292,7 @@ static void batadv_bla_send_claim(struct bat_priv *=
bat_priv, uint8_t *mac,
=20
 	/* now we pretend that the client would have sent this ... */
 	switch (claimtype) {
-	case CLAIM_TYPE_ADD:
+	case BATADV_CLAIM_TYPE_ADD:
 		/* normal claim frame
 		 * set Ethernet SRC to the clients mac
 		 */
@@ -300,7 +300,7 @@ static void batadv_bla_send_claim(struct bat_priv *=
bat_priv, uint8_t *mac,
 		batadv_dbg(DBG_BLA, bat_priv,
 			   "bla_send_claim(): CLAIM %pM on vid %d\n", mac, vid);
 		break;
-	case CLAIM_TYPE_DEL:
+	case BATADV_CLAIM_TYPE_DEL:
 		/* unclaim frame
 		 * set HW SRC to the clients mac
 		 */
@@ -309,7 +309,7 @@ static void batadv_bla_send_claim(struct bat_priv *=
bat_priv, uint8_t *mac,
 			   "bla_send_claim(): UNCLAIM %pM on vid %d\n", mac,
 			   vid);
 		break;
-	case CLAIM_TYPE_ANNOUNCE:
+	case BATADV_CLAIM_TYPE_ANNOUNCE:
 		/* announcement frame
 		 * set HW SRC to the special mac containg the crc
 		 */
@@ -318,7 +318,7 @@ static void batadv_bla_send_claim(struct bat_priv *=
bat_priv, uint8_t *mac,
 			   "bla_send_claim(): ANNOUNCE of %pM on vid %d\n",
 			   ethhdr->h_source, vid);
 		break;
-	case CLAIM_TYPE_REQUEST:
+	case BATADV_CLAIM_TYPE_REQUEST:
 		/* request frame
 		 * set HW SRC to the special mac containg the crc
 		 */
@@ -459,7 +459,7 @@ static void batadv_bla_answer_request(struct bat_pr=
iv *bat_priv,
 				continue;
=20
 			batadv_bla_send_claim(bat_priv, claim->addr, claim->vid,
-					      CLAIM_TYPE_ADD);
+					      BATADV_CLAIM_TYPE_ADD);
 		}
 		rcu_read_unlock();
 	}
@@ -485,7 +485,7 @@ static void batadv_bla_send_request(struct backbone=
_gw *backbone_gw)
=20
 	/* send request */
 	batadv_bla_send_claim(backbone_gw->bat_priv, backbone_gw->orig,
-			      backbone_gw->vid, CLAIM_TYPE_REQUEST);
+			      backbone_gw->vid, BATADV_CLAIM_TYPE_REQUEST);
=20
 	/* no local broadcasts should be sent or received, for now. */
 	if (!atomic_read(&backbone_gw->request_sent)) {
@@ -511,7 +511,7 @@ static void batadv_bla_send_announce(struct bat_pri=
v *bat_priv,
 	memcpy(&mac[4], &crc, 2);
=20
 	batadv_bla_send_claim(bat_priv, mac, backbone_gw->vid,
-			      CLAIM_TYPE_ANNOUNCE);
+			      BATADV_CLAIM_TYPE_ANNOUNCE);
=20
 }
=20
@@ -694,7 +694,7 @@ static int batadv_handle_unclaim(struct bat_priv *b=
at_priv,
 	if (primary_if && batadv_compare_eth(backbone_addr,
 					     primary_if->net_dev->dev_addr))
 		batadv_bla_send_claim(bat_priv, claim_addr, vid,
-				      CLAIM_TYPE_DEL);
+				      BATADV_CLAIM_TYPE_DEL);
=20
 	backbone_gw =3D batadv_backbone_hash_find(bat_priv, backbone_addr, vi=
d);
=20
@@ -730,7 +730,7 @@ static int batadv_handle_claim(struct bat_priv *bat=
_priv,
 	batadv_bla_add_claim(bat_priv, claim_addr, vid, backbone_gw);
 	if (batadv_compare_eth(backbone_addr, primary_if->net_dev->dev_addr))
 		batadv_bla_send_claim(bat_priv, claim_addr, vid,
-				      CLAIM_TYPE_ADD);
+				      BATADV_CLAIM_TYPE_ADD);
=20
 	/* TODO: we could call something like tt_local_del() here. */
=20
@@ -773,12 +773,12 @@ static int batadv_check_claim_group(struct bat_pr=
iv *bat_priv,
 	 * otherwise assume it is in the hw_src
 	 */
 	switch (bla_dst->type) {
-	case CLAIM_TYPE_ADD:
+	case BATADV_CLAIM_TYPE_ADD:
 		backbone_addr =3D hw_src;
 		break;
-	case CLAIM_TYPE_REQUEST:
-	case CLAIM_TYPE_ANNOUNCE:
-	case CLAIM_TYPE_DEL:
+	case BATADV_CLAIM_TYPE_REQUEST:
+	case BATADV_CLAIM_TYPE_ANNOUNCE:
+	case BATADV_CLAIM_TYPE_DEL:
 		backbone_addr =3D ethhdr->h_source;
 		break;
 	default:
@@ -894,23 +894,23 @@ static int batadv_bla_process_claim(struct bat_pr=
iv *bat_priv,
=20
 	/* check for the different types of claim frames ... */
 	switch (bla_dst->type) {
-	case CLAIM_TYPE_ADD:
+	case BATADV_CLAIM_TYPE_ADD:
 		if (batadv_handle_claim(bat_priv, primary_if, hw_src,
 					ethhdr->h_source, vid))
 			return 1;
 		break;
-	case CLAIM_TYPE_DEL:
+	case BATADV_CLAIM_TYPE_DEL:
 		if (batadv_handle_unclaim(bat_priv, primary_if,
 					  ethhdr->h_source, hw_src, vid))
 			return 1;
 		break;
=20
-	case CLAIM_TYPE_ANNOUNCE:
+	case BATADV_CLAIM_TYPE_ANNOUNCE:
 		if (batadv_handle_announce(bat_priv, hw_src, ethhdr->h_source,
 					   vid))
 			return 1;
 		break;
-	case CLAIM_TYPE_REQUEST:
+	case BATADV_CLAIM_TYPE_REQUEST:
 		if (batadv_handle_request(bat_priv, primary_if, hw_src, ethhdr,
 					  vid))
 			return 1;
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.=
c
index f5373a2..a64cce2 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -187,14 +187,14 @@ static ssize_t batadv_socket_write(struct file *f=
ile, const char __user *buff,
 		goto free_skb;
 	}
=20
-	if (icmp_packet->header.packet_type !=3D BAT_ICMP) {
+	if (icmp_packet->header.packet_type !=3D BATADV_ICMP) {
 		batadv_dbg(DBG_BATMAN, bat_priv,
 			   "Error - can't send packet from char device: got bogus packet ty=
pe (expected: BAT_ICMP)\n");
 		len =3D -EINVAL;
 		goto free_skb;
 	}
=20
-	if (icmp_packet->msg_type !=3D ECHO_REQUEST) {
+	if (icmp_packet->msg_type !=3D BATADV_ECHO_REQUEST) {
 		batadv_dbg(DBG_BATMAN, bat_priv,
 			   "Error - can't send packet from char device: got bogus message t=
ype (expected: ECHO_REQUEST)\n");
 		len =3D -EINVAL;
@@ -204,7 +204,7 @@ static ssize_t batadv_socket_write(struct file *fil=
e, const char __user *buff,
 	icmp_packet->uid =3D socket_client->index;
=20
 	if (icmp_packet->header.version !=3D BATADV_COMPAT_VERSION) {
-		icmp_packet->msg_type =3D PARAMETER_PROBLEM;
+		icmp_packet->msg_type =3D BATADV_PARAMETER_PROBLEM;
 		icmp_packet->header.version =3D BATADV_COMPAT_VERSION;
 		batadv_socket_add_packet(socket_client, icmp_packet,
 					 packet_len);
@@ -239,7 +239,7 @@ static ssize_t batadv_socket_write(struct file *fil=
e, const char __user *buff,
 	goto out;
=20
 dst_unreach:
-	icmp_packet->msg_type =3D DESTINATION_UNREACHABLE;
+	icmp_packet->msg_type =3D BATADV_DESTINATION_UNREACHABLE;
 	batadv_socket_add_packet(socket_client, icmp_packet, packet_len);
 free_skb:
 	kfree_skb(skb);
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 23f5c8e..b3f0a2e 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -275,19 +275,19 @@ static void batadv_recv_handler_init(void)
 		batadv_rx_handler[i] =3D batadv_recv_unhandled_packet;
=20
 	/* batman icmp packet */
-	batadv_rx_handler[BAT_ICMP] =3D batadv_recv_icmp_packet;
+	batadv_rx_handler[BATADV_ICMP] =3D batadv_recv_icmp_packet;
 	/* unicast packet */
-	batadv_rx_handler[BAT_UNICAST] =3D batadv_recv_unicast_packet;
+	batadv_rx_handler[BATADV_UNICAST] =3D batadv_recv_unicast_packet;
 	/* fragmented unicast packet */
-	batadv_rx_handler[BAT_UNICAST_FRAG] =3D batadv_recv_ucast_frag_packet=
;
+	batadv_rx_handler[BATADV_UNICAST_FRAG] =3D batadv_recv_ucast_frag_pac=
ket;
 	/* broadcast packet */
-	batadv_rx_handler[BAT_BCAST] =3D batadv_recv_bcast_packet;
+	batadv_rx_handler[BATADV_BCAST] =3D batadv_recv_bcast_packet;
 	/* vis packet */
-	batadv_rx_handler[BAT_VIS] =3D batadv_recv_vis_packet;
+	batadv_rx_handler[BATADV_VIS] =3D batadv_recv_vis_packet;
 	/* Translation table query (request or response) */
-	batadv_rx_handler[BAT_TT_QUERY] =3D batadv_recv_tt_query;
+	batadv_rx_handler[BATADV_TT_QUERY] =3D batadv_recv_tt_query;
 	/* Roaming advertisement */
-	batadv_rx_handler[BAT_ROAM_ADV] =3D batadv_recv_roam_adv;
+	batadv_rx_handler[BATADV_ROAM_ADV] =3D batadv_recv_roam_adv;
 }
=20
 int batadv_recv_handler_register(uint8_t packet_type,
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index e562414..59e328a 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -22,80 +22,80 @@
=20
 #define BATADV_ETH_P_BATMAN  0x4305 /* unofficial/not registered Ether=
type */
=20
-enum bat_packettype {
-	BAT_IV_OGM	 =3D 0x01,
-	BAT_ICMP	 =3D 0x02,
-	BAT_UNICAST	 =3D 0x03,
-	BAT_BCAST	 =3D 0x04,
-	BAT_VIS		 =3D 0x05,
-	BAT_UNICAST_FRAG =3D 0x06,
-	BAT_TT_QUERY	 =3D 0x07,
-	BAT_ROAM_ADV	 =3D 0x08
+enum batadv_packettype {
+	BATADV_IV_OGM	    =3D 0x01,
+	BATADV_ICMP	    =3D 0x02,
+	BATADV_UNICAST	    =3D 0x03,
+	BATADV_BCAST	    =3D 0x04,
+	BATADV_VIS	    =3D 0x05,
+	BATADV_UNICAST_FRAG =3D 0x06,
+	BATADV_TT_QUERY	    =3D 0x07,
+	BATADV_ROAM_ADV	    =3D 0x08,
 };
=20
 /* this file is included by batctl which needs these defines */
 #define BATADV_COMPAT_VERSION 14
=20
-enum batman_iv_flags {
-	NOT_BEST_NEXT_HOP   =3D 1 << 3,
-	PRIMARIES_FIRST_HOP =3D 1 << 4,
-	VIS_SERVER	    =3D 1 << 5,
-	DIRECTLINK	    =3D 1 << 6
+enum batadv_iv_flags {
+	BATADV_NOT_BEST_NEXT_HOP   =3D 1 << 3,
+	BATADV_PRIMARIES_FIRST_HOP =3D 1 << 4,
+	BATADV_VIS_SERVER	   =3D 1 << 5,
+	BATADV_DIRECTLINK	   =3D 1 << 6,
 };
=20
 /* ICMP message types */
-enum icmp_packettype {
-	ECHO_REPLY		=3D 0,
-	DESTINATION_UNREACHABLE =3D 3,
-	ECHO_REQUEST		=3D 8,
-	TTL_EXCEEDED		=3D 11,
-	PARAMETER_PROBLEM	=3D 12
+enum batadv_icmp_packettype {
+	BATADV_ECHO_REPLY	       =3D 0,
+	BATADV_DESTINATION_UNREACHABLE =3D 3,
+	BATADV_ECHO_REQUEST	       =3D 8,
+	BATADV_TTL_EXCEEDED	       =3D 11,
+	BATADV_PARAMETER_PROBLEM       =3D 12,
 };
=20
 /* vis defines */
-enum vis_packettype {
-	VIS_TYPE_SERVER_SYNC   =3D 0,
-	VIS_TYPE_CLIENT_UPDATE =3D 1
+enum batadv_vis_packettype {
+	BATADV_VIS_TYPE_SERVER_SYNC   =3D 0,
+	BATADV_VIS_TYPE_CLIENT_UPDATE =3D 1,
 };
=20
 /* fragmentation defines */
-enum unicast_frag_flags {
-	UNI_FRAG_HEAD	   =3D 1 << 0,
-	UNI_FRAG_LARGETAIL =3D 1 << 1
+enum batadv_unicast_frag_flags {
+	BATADV_UNI_FRAG_HEAD	  =3D 1 << 0,
+	BATADV_UNI_FRAG_LARGETAIL =3D 1 << 1,
 };
=20
 /* TT_QUERY subtypes */
 #define BATADV_TT_QUERY_TYPE_MASK 0x3
=20
-enum tt_query_packettype {
-	TT_REQUEST    =3D 0,
-	TT_RESPONSE   =3D 1
+enum batadv_tt_query_packettype {
+	BATADV_TT_REQUEST  =3D 0,
+	BATADV_TT_RESPONSE =3D 1,
 };
=20
 /* TT_QUERY flags */
-enum tt_query_flags {
-	TT_FULL_TABLE =3D 1 << 2
+enum batadv_tt_query_flags {
+	BATADV_TT_FULL_TABLE =3D 1 << 2,
 };
=20
-/* TT_CLIENT flags.
+/* BATADV_TT_CLIENT flags.
  * Flags from 1 to 1 << 7 are sent on the wire, while flags from 1 << =
8 to
  * 1 << 15 are used for local computation only
  */
-enum tt_client_flags {
-	TT_CLIENT_DEL     =3D 1 << 0,
-	TT_CLIENT_ROAM    =3D 1 << 1,
-	TT_CLIENT_WIFI    =3D 1 << 2,
-	TT_CLIENT_NOPURGE =3D 1 << 8,
-	TT_CLIENT_NEW     =3D 1 << 9,
-	TT_CLIENT_PENDING =3D 1 << 10
+enum batadv_tt_client_flags {
+	BATADV_TT_CLIENT_DEL     =3D 1 << 0,
+	BATADV_TT_CLIENT_ROAM    =3D 1 << 1,
+	BATADV_TT_CLIENT_WIFI    =3D 1 << 2,
+	BATADV_TT_CLIENT_NOPURGE =3D 1 << 8,
+	BATADV_TT_CLIENT_NEW     =3D 1 << 9,
+	BATADV_TT_CLIENT_PENDING =3D 1 << 10,
 };
=20
 /* claim frame types for the bridge loop avoidance */
-enum bla_claimframe {
-	CLAIM_TYPE_ADD		=3D 0x00,
-	CLAIM_TYPE_DEL		=3D 0x01,
-	CLAIM_TYPE_ANNOUNCE	=3D 0x02,
-	CLAIM_TYPE_REQUEST	=3D 0x03
+enum batadv_bla_claimframe {
+	BATADV_CLAIM_TYPE_ADD		=3D 0x00,
+	BATADV_CLAIM_TYPE_DEL		=3D 0x01,
+	BATADV_CLAIM_TYPE_ANNOUNCE	=3D 0x02,
+	BATADV_CLAIM_TYPE_REQUEST	=3D 0x03,
 };
=20
 /* the destination hardware field in the ARP frame is used to
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index aa8325e..8e43a95 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -219,7 +219,7 @@ batadv_bonding_save_primary(const struct orig_node =
*orig_node,
 			    struct orig_node *orig_neigh_node,
 			    const struct batman_ogm_packet *batman_ogm_packet)
 {
-	if (!(batman_ogm_packet->flags & PRIMARIES_FIRST_HOP))
+	if (!(batman_ogm_packet->flags & BATADV_PRIMARIES_FIRST_HOP))
 		return;
=20
 	memcpy(orig_neigh_node->primary_addr, orig_node->orig, ETH_ALEN);
@@ -290,7 +290,7 @@ static int batadv_recv_my_icmp_packet(struct bat_pr=
iv *bat_priv,
 	icmp_packet =3D (struct icmp_packet_rr *)skb->data;
=20
 	/* add data to device queue */
-	if (icmp_packet->msg_type !=3D ECHO_REQUEST) {
+	if (icmp_packet->msg_type !=3D BATADV_ECHO_REQUEST) {
 		batadv_socket_receive_packet(icmp_packet, icmp_len);
 		goto out;
 	}
@@ -317,7 +317,7 @@ static int batadv_recv_my_icmp_packet(struct bat_pr=
iv *bat_priv,
=20
 	memcpy(icmp_packet->dst, icmp_packet->orig, ETH_ALEN);
 	memcpy(icmp_packet->orig, primary_if->net_dev->dev_addr, ETH_ALEN);
-	icmp_packet->msg_type =3D ECHO_REPLY;
+	icmp_packet->msg_type =3D BATADV_ECHO_REPLY;
 	icmp_packet->header.ttl =3D BATADV_TTL;
=20
 	batadv_send_skb_packet(skb, router->if_incoming, router->addr);
@@ -345,7 +345,7 @@ static int batadv_recv_icmp_ttl_exceeded(struct bat=
_priv *bat_priv,
 	icmp_packet =3D (struct icmp_packet *)skb->data;
=20
 	/* send TTL exceeded if packet is an echo request (traceroute) */
-	if (icmp_packet->msg_type !=3D ECHO_REQUEST) {
+	if (icmp_packet->msg_type !=3D BATADV_ECHO_REQUEST) {
 		pr_debug("Warning - can't forward icmp packet from %pM to %pM: ttl e=
xceeded\n",
 			 icmp_packet->orig, icmp_packet->dst);
 		goto out;
@@ -372,7 +372,7 @@ static int batadv_recv_icmp_ttl_exceeded(struct bat=
_priv *bat_priv,
=20
 	memcpy(icmp_packet->dst, icmp_packet->orig, ETH_ALEN);
 	memcpy(icmp_packet->orig, primary_if->net_dev->dev_addr, ETH_ALEN);
-	icmp_packet->msg_type =3D TTL_EXCEEDED;
+	icmp_packet->msg_type =3D BATADV_TTL_EXCEEDED;
 	icmp_packet->header.ttl =3D BATADV_TTL;
=20
 	batadv_send_skb_packet(skb, router->if_incoming, router->addr);
@@ -606,14 +606,18 @@ int batadv_recv_tt_query(struct sk_buff *skb, str=
uct hard_iface *recv_if)
 	tt_query =3D (struct tt_query_packet *)skb->data;
=20
 	switch (tt_query->flags & BATADV_TT_QUERY_TYPE_MASK) {
-	case TT_REQUEST:
+	case BATADV_TT_REQUEST:
 		batadv_inc_counter(bat_priv, BATADV_CNT_TT_REQUEST_RX);
=20
 		/* If we cannot provide an answer the tt_request is
 		 * forwarded
 		 */
 		if (!batadv_send_tt_response(bat_priv, tt_query)) {
-			tt_flag =3D tt_query->flags & TT_FULL_TABLE ? 'F' : '.';
+			if (tt_query->flags & BATADV_TT_FULL_TABLE)
+				tt_flag =3D 'F';
+			else
+				tt_flag =3D '.';
+
 			batadv_dbg(DBG_TT, bat_priv,
 				   "Routing TT_REQUEST to %pM [%c]\n",
 				   tt_query->dst,
@@ -621,7 +625,7 @@ int batadv_recv_tt_query(struct sk_buff *skb, struc=
t hard_iface *recv_if)
 			return batadv_route_unicast_packet(skb, recv_if);
 		}
 		break;
-	case TT_RESPONSE:
+	case BATADV_TT_RESPONSE:
 		batadv_inc_counter(bat_priv, BATADV_CNT_TT_RESPONSE_RX);
=20
 		if (batadv_is_my_mac(tt_query->dst)) {
@@ -642,7 +646,10 @@ int batadv_recv_tt_query(struct sk_buff *skb, stru=
ct hard_iface *recv_if)
=20
 			batadv_handle_tt_response(bat_priv, tt_query);
 		} else {
-			tt_flag =3D tt_query->flags & TT_FULL_TABLE ? 'F' : '.';
+			if (tt_query->flags & BATADV_TT_FULL_TABLE)
+				tt_flag =3D  'F';
+			else
+				tt_flag =3D '.';
 			batadv_dbg(DBG_TT, bat_priv,
 				   "Routing TT_RESPONSE to %pM [%c]\n",
 				   tt_query->dst,
@@ -701,7 +708,7 @@ int batadv_recv_roam_adv(struct sk_buff *skb, struc=
t hard_iface *recv_if)
 		   roam_adv_packet->src, roam_adv_packet->client);
=20
 	batadv_tt_global_add(bat_priv, orig_node, roam_adv_packet->client,
-			     TT_CLIENT_ROAM,
+			     BATADV_TT_CLIENT_ROAM,
 			     atomic_read(&orig_node->last_ttvn) + 1);
=20
 	/* Roaming phase starts: I have new information but the ttvn has not
@@ -868,7 +875,7 @@ static int batadv_route_unicast_packet(struct sk_bu=
ff *skb,
=20
 	unicast_packet =3D (struct unicast_packet *)skb->data;
=20
-	if (unicast_packet->header.packet_type =3D=3D BAT_UNICAST &&
+	if (unicast_packet->header.packet_type =3D=3D BATADV_UNICAST &&
 	    atomic_read(&bat_priv->fragmentation) &&
 	    skb->len > neigh_node->if_incoming->net_dev->mtu) {
 		ret =3D batadv_frag_send_skb(skb, bat_priv,
@@ -877,7 +884,7 @@ static int batadv_route_unicast_packet(struct sk_bu=
ff *skb,
 		goto out;
 	}
=20
-	if (unicast_packet->header.packet_type =3D=3D BAT_UNICAST_FRAG &&
+	if (unicast_packet->header.packet_type =3D=3D BATADV_UNICAST_FRAG &&
 	    batadv_frag_can_reassemble(skb,
 				       neigh_node->if_incoming->net_dev->mtu)) {
=20
@@ -1176,12 +1183,12 @@ int batadv_recv_vis_packet(struct sk_buff *skb,=
 struct hard_iface *recv_if)
 		return NET_RX_DROP;
=20
 	switch (vis_packet->vis_type) {
-	case VIS_TYPE_SERVER_SYNC:
+	case BATADV_VIS_TYPE_SERVER_SYNC:
 		batadv_receive_server_sync_packet(bat_priv, vis_packet,
 						  skb_headlen(skb));
 		break;
=20
-	case VIS_TYPE_CLIENT_UPDATE:
+	case BATADV_VIS_TYPE_CLIENT_UPDATE:
 		batadv_receive_client_update_packet(bat_priv, vis_packet,
 						    skb_headlen(skb));
 		break;
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 19a80d2..3aae91d 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -213,7 +213,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 		bcast_packet->header.ttl =3D BATADV_TTL;
=20
 		/* batman packet type: broadcast */
-		bcast_packet->header.packet_type =3D BAT_BCAST;
+		bcast_packet->header.packet_type =3D BATADV_BCAST;
=20
 		/* hw address of first interface is the orig mac because only
 		 * this mac is known throughout the mesh
@@ -387,7 +387,7 @@ struct net_device *batadv_softif_create(const char =
*name)
 	atomic_set(&bat_priv->bonding, 0);
 	atomic_set(&bat_priv->bridge_loop_avoidance, 0);
 	atomic_set(&bat_priv->ap_isolation, 0);
-	atomic_set(&bat_priv->vis_mode, VIS_TYPE_CLIENT_UPDATE);
+	atomic_set(&bat_priv->vis_mode, BATADV_VIS_TYPE_CLIENT_UPDATE);
 	atomic_set(&bat_priv->gw_mode, BATADV_GW_MODE_OFF);
 	atomic_set(&bat_priv->gw_sel_class, 20);
 	atomic_set(&bat_priv->gw_bandwidth, 41);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/transl=
ation-table.c
index f36d1d5..309d691 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -169,7 +169,7 @@ static void batadv_tt_local_event(struct bat_priv *=
bat_priv,
 	tt_change_node->change.flags =3D flags;
 	memcpy(tt_change_node->change.addr, addr, ETH_ALEN);
=20
-	del_op_requested =3D flags & TT_CLIENT_DEL;
+	del_op_requested =3D flags & BATADV_TT_CLIENT_DEL;
=20
 	/* check for ADD+DEL or DEL+ADD events */
 	spin_lock_bh(&bat_priv->tt_changes_list_lock);
@@ -185,7 +185,7 @@ static void batadv_tt_local_event(struct bat_priv *=
bat_priv,
 		 * now possible due to automatically recognition of "temporary"
 		 * clients
 		 */
-		del_op_entry =3D entry->change.flags & TT_CLIENT_DEL;
+		del_op_entry =3D entry->change.flags & BATADV_TT_CLIENT_DEL;
 		if (!del_op_requested && del_op_entry)
 			goto del;
 		if (del_op_requested && !del_op_entry)
@@ -243,8 +243,8 @@ void batadv_tt_local_add(struct net_device *soft_if=
ace, const uint8_t *addr,
=20
 	if (tt_local_entry) {
 		tt_local_entry->last_seen =3D jiffies;
-		/* possibly unset the TT_CLIENT_PENDING flag */
-		tt_local_entry->common.flags &=3D ~TT_CLIENT_PENDING;
+		/* possibly unset the BATADV_TT_CLIENT_PENDING flag */
+		tt_local_entry->common.flags &=3D ~BATADV_TT_CLIENT_PENDING;
 		goto out;
 	}
=20
@@ -259,19 +259,19 @@ void batadv_tt_local_add(struct net_device *soft_=
iface, const uint8_t *addr,
 	memcpy(tt_local_entry->common.addr, addr, ETH_ALEN);
 	tt_local_entry->common.flags =3D BATADV_NO_FLAGS;
 	if (batadv_is_wifi_iface(ifindex))
-		tt_local_entry->common.flags |=3D TT_CLIENT_WIFI;
+		tt_local_entry->common.flags |=3D BATADV_TT_CLIENT_WIFI;
 	atomic_set(&tt_local_entry->common.refcount, 2);
 	tt_local_entry->last_seen =3D jiffies;
=20
 	/* the batman interface mac address should never be purged */
 	if (batadv_compare_eth(addr, soft_iface->dev_addr))
-		tt_local_entry->common.flags |=3D TT_CLIENT_NOPURGE;
+		tt_local_entry->common.flags |=3D BATADV_TT_CLIENT_NOPURGE;
=20
 	/* The local entry has to be marked as NEW to avoid to send it in
 	 * a full table response going out before the next ttvn increment
 	 * (consistency check)
 	 */
-	tt_local_entry->common.flags |=3D TT_CLIENT_NEW;
+	tt_local_entry->common.flags |=3D BATADV_TT_CLIENT_NEW;
=20
 	hash_added =3D batadv_hash_add(bat_priv->tt_local_hash, batadv_compar=
e_tt,
 				     batadv_choose_orig,
@@ -305,7 +305,7 @@ void batadv_tt_local_add(struct net_device *soft_if=
ace, const uint8_t *addr,
 		/* The global entry has to be marked as ROAMING and
 		 * has to be kept for consistency purpose
 		 */
-		tt_global_entry->common.flags |=3D TT_CLIENT_ROAM;
+		tt_global_entry->common.flags |=3D BATADV_TT_CLIENT_ROAM;
 		tt_global_entry->roam_at =3D jiffies;
 	}
 out:
@@ -453,15 +453,15 @@ int batadv_tt_local_seq_print_text(struct seq_fil=
e *seq, void *offset)
 			seq_printf(seq, " * %pM [%c%c%c%c%c]\n",
 				   tt_common_entry->addr,
 				   (tt_common_entry->flags &
-				    TT_CLIENT_ROAM ? 'R' : '.'),
+				    BATADV_TT_CLIENT_ROAM ? 'R' : '.'),
 				   (tt_common_entry->flags &
-				    TT_CLIENT_NOPURGE ? 'P' : '.'),
+				    BATADV_TT_CLIENT_NOPURGE ? 'P' : '.'),
 				   (tt_common_entry->flags &
-				    TT_CLIENT_NEW ? 'N' : '.'),
+				    BATADV_TT_CLIENT_NEW ? 'N' : '.'),
 				   (tt_common_entry->flags &
-				    TT_CLIENT_PENDING ? 'X' : '.'),
+				    BATADV_TT_CLIENT_PENDING ? 'X' : '.'),
 				   (tt_common_entry->flags &
-				    TT_CLIENT_WIFI ? 'W' : '.'));
+				    BATADV_TT_CLIENT_WIFI ? 'W' : '.'));
 		}
 		rcu_read_unlock();
 	}
@@ -482,7 +482,7 @@ static void batadv_tt_local_set_pending(struct bat_=
priv *bat_priv,
 	 * to be kept in the table in order to send it in a full table
 	 * response issued before the net ttvn increment (consistency check)
 	 */
-	tt_local_entry->common.flags |=3D TT_CLIENT_PENDING;
+	tt_local_entry->common.flags |=3D BATADV_TT_CLIENT_PENDING;
=20
 	batadv_dbg(DBG_TT, bat_priv,
 		   "Local tt entry (%pM) pending to be removed: %s\n",
@@ -499,9 +499,9 @@ void batadv_tt_local_remove(struct bat_priv *bat_pr=
iv, const uint8_t *addr,
 	if (!tt_local_entry)
 		goto out;
=20
-	flags =3D TT_CLIENT_DEL;
+	flags =3D BATADV_TT_CLIENT_DEL;
 	if (roaming)
-		flags |=3D TT_CLIENT_ROAM;
+		flags |=3D BATADV_TT_CLIENT_ROAM;
=20
 	batadv_tt_local_set_pending(bat_priv, tt_local_entry, flags, message)=
;
 out:
@@ -509,12 +509,36 @@ out:
 		batadv_tt_local_entry_free_ref(tt_local_entry);
 }
=20
+static void batadv_tt_local_purge_list(struct bat_priv *bat_priv,
+				       struct hlist_head *head)
+{
+	struct tt_local_entry *tt_local_entry;
+	struct tt_common_entry *tt_common_entry;
+	struct hlist_node *node, *node_tmp;
+
+	hlist_for_each_entry_safe(tt_common_entry, node, node_tmp, head,
+				  hash_entry) {
+		tt_local_entry =3D container_of(tt_common_entry,
+					      struct tt_local_entry, common);
+		if (tt_local_entry->common.flags & BATADV_TT_CLIENT_NOPURGE)
+			continue;
+
+		/* entry already marked for deletion */
+		if (tt_local_entry->common.flags & BATADV_TT_CLIENT_PENDING)
+			continue;
+
+		if (!batadv_has_timed_out(tt_local_entry->last_seen,
+					  BATADV_TT_LOCAL_TIMEOUT))
+			continue;
+
+		batadv_tt_local_set_pending(bat_priv, tt_local_entry,
+					    BATADV_TT_CLIENT_DEL, "timed out");
+	}
+}
+
 static void batadv_tt_local_purge(struct bat_priv *bat_priv)
 {
 	struct hashtable_t *hash =3D bat_priv->tt_local_hash;
-	struct tt_local_entry *tt_local_entry;
-	struct tt_common_entry *tt_common_entry;
-	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
 	spinlock_t *list_lock; /* protects write access to the hash lists */
 	uint32_t i;
@@ -524,25 +548,7 @@ static void batadv_tt_local_purge(struct bat_priv =
*bat_priv)
 		list_lock =3D &hash->list_locks[i];
=20
 		spin_lock_bh(list_lock);
-		hlist_for_each_entry_safe(tt_common_entry, node, node_tmp,
-					  head, hash_entry) {
-			tt_local_entry =3D container_of(tt_common_entry,
-						      struct tt_local_entry,
-						      common);
-			if (tt_local_entry->common.flags & TT_CLIENT_NOPURGE)
-				continue;
-
-			/* entry already marked for deletion */
-			if (tt_local_entry->common.flags & TT_CLIENT_PENDING)
-				continue;
-
-			if (!batadv_has_timed_out(tt_local_entry->last_seen,
-						  BATADV_TT_LOCAL_TIMEOUT))
-				continue;
-
-			batadv_tt_local_set_pending(bat_priv, tt_local_entry,
-						    TT_CLIENT_DEL, "timed out");
-		}
+		batadv_tt_local_purge_list(bat_priv, head);
 		spin_unlock_bh(list_lock);
 	}
=20
@@ -701,16 +707,16 @@ int batadv_tt_global_add(struct bat_priv *bat_pri=
v, struct orig_node *orig_node,
 	} else {
 		/* there is already a global entry, use this one. */
=20
-		/* If there is the TT_CLIENT_ROAM flag set, there is only one
-		 * originator left in the list and we previously received a
+		/* If there is the BATADV_TT_CLIENT_ROAM flag set, there is only
+		 * one originator left in the list and we previously received a
 		 * delete + roaming change for this originator.
 		 *
 		 * We should first delete the old originator before adding the
 		 * new one.
 		 */
-		if (tt_global_entry->common.flags & TT_CLIENT_ROAM) {
+		if (tt_global_entry->common.flags & BATADV_TT_CLIENT_ROAM) {
 			batadv_tt_global_del_orig_list(tt_global_entry);
-			tt_global_entry->common.flags &=3D ~TT_CLIENT_ROAM;
+			tt_global_entry->common.flags &=3D ~BATADV_TT_CLIENT_ROAM;
 			tt_global_entry->roam_at =3D 0;
 		}
=20
@@ -727,7 +733,8 @@ int batadv_tt_global_add(struct bat_priv *bat_priv,=
 struct orig_node *orig_node,
 out_remove:
 	/* remove address from local hash if present */
 	batadv_tt_local_remove(bat_priv, tt_global_entry->common.addr,
-			       "global tt received", flags & TT_CLIENT_ROAM);
+			       "global tt received",
+			       flags & BATADV_TT_CLIENT_ROAM);
 	ret =3D 1;
 out:
 	if (tt_global_entry)
@@ -759,8 +766,8 @@ batadv_tt_global_print_entry(struct tt_global_entry=
 *tt_global_entry,
 		seq_printf(seq, " * %pM  (%3u) via %pM     (%3u)   [%c%c]\n",
 			   tt_global_entry->common.addr, orig_entry->ttvn,
 			   orig_entry->orig_node->orig, last_ttvn,
-			   (flags & TT_CLIENT_ROAM ? 'R' : '.'),
-			   (flags & TT_CLIENT_WIFI ? 'W' : '.'));
+			   (flags & BATADV_TT_CLIENT_ROAM ? 'R' : '.'),
+			   (flags & BATADV_TT_CLIENT_WIFI ? 'W' : '.'));
 	}
 }
=20
@@ -874,8 +881,8 @@ static void batadv_tt_global_del_struct(struct bat_=
priv *bat_priv,
 }
=20
 /* If the client is to be deleted, we check if it is the last origanto=
r entry
- * within tt_global entry. If yes, we set the TT_CLIENT_ROAM flag and =
the timer,
- * otherwise we simply remove the originator scheduled for deletion.
+ * within tt_global entry. If yes, we set the BATADV_TT_CLIENT_ROAM fl=
ag and the
+ * timer, otherwise we simply remove the originator scheduled for dele=
tion.
  */
 static void
 batadv_tt_global_del_roaming(struct bat_priv *bat_priv,
@@ -903,7 +910,7 @@ batadv_tt_global_del_roaming(struct bat_priv *bat_p=
riv,
=20
 	if (last_entry) {
 		/* its the last one, mark for roaming. */
-		tt_global_entry->common.flags |=3D TT_CLIENT_ROAM;
+		tt_global_entry->common.flags |=3D BATADV_TT_CLIENT_ROAM;
 		tt_global_entry->roam_at =3D jiffies;
 	} else
 		/* there is another entry, we can simply delete this
@@ -942,7 +949,7 @@ static void batadv_tt_global_del(struct bat_priv *b=
at_priv,
 	 * event, there are two possibilities:
 	 * 1) the client roamed from node A to node B =3D> if there
 	 *    is only one originator left for this client, we mark
-	 *    it with TT_CLIENT_ROAM, we start a timer and we
+	 *    it with BATADV_TT_CLIENT_ROAM, we start a timer and we
 	 *    wait for node B to claim it. In case of timeout
 	 *    the entry is purged.
 	 *
@@ -1022,7 +1029,7 @@ static void batadv_tt_global_roam_purge_list(stru=
ct bat_priv *bat_priv,
 				  hash_entry) {
 		tt_global_entry =3D container_of(tt_common_entry,
 					       struct tt_global_entry, common);
-		if (!(tt_global_entry->common.flags & TT_CLIENT_ROAM))
+		if (!(tt_global_entry->common.flags & BATADV_TT_CLIENT_ROAM))
 			continue;
 		if (!batadv_has_timed_out(tt_global_entry->roam_at,
 					  BATADV_TT_CLIENT_ROAM_TIMEOUT))
@@ -1096,8 +1103,8 @@ static bool _batadv_is_ap_isolated(struct tt_loca=
l_entry *tt_local_entry,
 {
 	bool ret =3D false;
=20
-	if (tt_local_entry->common.flags & TT_CLIENT_WIFI &&
-	    tt_global_entry->common.flags & TT_CLIENT_WIFI)
+	if (tt_local_entry->common.flags & BATADV_TT_CLIENT_WIFI &&
+	    tt_global_entry->common.flags & BATADV_TT_CLIENT_WIFI)
 		ret =3D true;
=20
 	return ret;
@@ -1167,7 +1174,7 @@ static uint16_t batadv_tt_global_crc(struct bat_p=
riv *bat_priv,
 {
 	uint16_t total =3D 0, total_one;
 	struct hashtable_t *hash =3D bat_priv->tt_global_hash;
-	struct tt_common_entry *tt_common_entry;
+	struct tt_common_entry *tt_common;
 	struct tt_global_entry *tt_global_entry;
 	struct hlist_node *node;
 	struct hlist_head *head;
@@ -1178,9 +1185,8 @@ static uint16_t batadv_tt_global_crc(struct bat_p=
riv *bat_priv,
 		head =3D &hash->table[i];
=20
 		rcu_read_lock();
-		hlist_for_each_entry_rcu(tt_common_entry, node,
-					 head, hash_entry) {
-			tt_global_entry =3D container_of(tt_common_entry,
+		hlist_for_each_entry_rcu(tt_common, node, head, hash_entry) {
+			tt_global_entry =3D container_of(tt_common,
 						       struct tt_global_entry,
 						       common);
 			/* Roaming clients are in the global table for
@@ -1188,7 +1194,7 @@ static uint16_t batadv_tt_global_crc(struct bat_p=
riv *bat_priv,
 			 * taken into account while computing the
 			 * global crc
 			 */
-			if (tt_global_entry->common.flags & TT_CLIENT_ROAM)
+			if (tt_common->flags & BATADV_TT_CLIENT_ROAM)
 				continue;
=20
 			/* find out if this global entry is announced by this
@@ -1201,7 +1207,7 @@ static uint16_t batadv_tt_global_crc(struct bat_p=
riv *bat_priv,
 			total_one =3D 0;
 			for (j =3D 0; j < ETH_ALEN; j++)
 				total_one =3D crc16_byte(total_one,
-					tt_global_entry->common.addr[j]);
+						       tt_common->addr[j]);
 			total ^=3D total_one;
 		}
 		rcu_read_unlock();
@@ -1215,7 +1221,7 @@ static uint16_t batadv_tt_local_crc(struct bat_pr=
iv *bat_priv)
 {
 	uint16_t total =3D 0, total_one;
 	struct hashtable_t *hash =3D bat_priv->tt_local_hash;
-	struct tt_common_entry *tt_common_entry;
+	struct tt_common_entry *tt_common;
 	struct hlist_node *node;
 	struct hlist_head *head;
 	uint32_t i;
@@ -1225,17 +1231,16 @@ static uint16_t batadv_tt_local_crc(struct bat_=
priv *bat_priv)
 		head =3D &hash->table[i];
=20
 		rcu_read_lock();
-		hlist_for_each_entry_rcu(tt_common_entry, node,
-					 head, hash_entry) {
+		hlist_for_each_entry_rcu(tt_common, node, head, hash_entry) {
 			/* not yet committed clients have not to be taken into
 			 * account while computing the CRC
 			 */
-			if (tt_common_entry->flags & TT_CLIENT_NEW)
+			if (tt_common->flags & BATADV_TT_CLIENT_NEW)
 				continue;
 			total_one =3D 0;
 			for (j =3D 0; j < ETH_ALEN; j++)
 				total_one =3D crc16_byte(total_one,
-						   tt_common_entry->addr[j]);
+						       tt_common->addr[j]);
 			total ^=3D total_one;
 		}
 		rcu_read_unlock();
@@ -1331,7 +1336,7 @@ static int batadv_tt_local_valid_entry(const void=
 *entry_ptr,
 {
 	const struct tt_common_entry *tt_common_entry =3D entry_ptr;
=20
-	if (tt_common_entry->flags & TT_CLIENT_NEW)
+	if (tt_common_entry->flags & BATADV_TT_CLIENT_NEW)
 		return 0;
 	return 1;
 }
@@ -1343,7 +1348,7 @@ static int batadv_tt_global_valid(const void *ent=
ry_ptr,
 	const struct tt_global_entry *tt_global_entry;
 	const struct orig_node *orig_node =3D data_ptr;
=20
-	if (tt_common_entry->flags & TT_CLIENT_ROAM)
+	if (tt_common_entry->flags & BATADV_TT_CLIENT_ROAM)
 		return 0;
=20
 	tt_global_entry =3D container_of(tt_common_entry, struct tt_global_en=
try,
@@ -1450,17 +1455,17 @@ static int batadv_send_tt_request(struct bat_pr=
iv *bat_priv,
 	tt_request =3D (struct tt_query_packet *)skb_put(skb,
 				sizeof(struct tt_query_packet));
=20
-	tt_request->header.packet_type =3D BAT_TT_QUERY;
+	tt_request->header.packet_type =3D BATADV_TT_QUERY;
 	tt_request->header.version =3D BATADV_COMPAT_VERSION;
 	memcpy(tt_request->src, primary_if->net_dev->dev_addr, ETH_ALEN);
 	memcpy(tt_request->dst, dst_orig_node->orig, ETH_ALEN);
 	tt_request->header.ttl =3D BATADV_TTL;
 	tt_request->ttvn =3D ttvn;
 	tt_request->tt_data =3D htons(tt_crc);
-	tt_request->flags =3D TT_REQUEST;
+	tt_request->flags =3D BATADV_TT_REQUEST;
=20
 	if (full_table)
-		tt_request->flags |=3D TT_FULL_TABLE;
+		tt_request->flags |=3D BATADV_TT_FULL_TABLE;
=20
 	neigh_node =3D batadv_orig_node_get_router(dst_orig_node);
 	if (!neigh_node)
@@ -1509,7 +1514,7 @@ static bool batadv_send_other_tt_response(struct =
bat_priv *bat_priv,
 	batadv_dbg(DBG_TT, bat_priv,
 		   "Received TT_REQUEST from %pM for ttvn: %u (%pM) [%c]\n",
 		   tt_request->src, tt_request->ttvn, tt_request->dst,
-		   (tt_request->flags & TT_FULL_TABLE ? 'F' : '.'));
+		   (tt_request->flags & BATADV_TT_FULL_TABLE ? 'F' : '.'));
=20
 	/* Let's get the orig node of the REAL destination */
 	req_dst_orig_node =3D batadv_orig_hash_find(bat_priv, tt_request->dst=
);
@@ -1537,7 +1542,7 @@ static bool batadv_send_other_tt_response(struct =
bat_priv *bat_priv,
 		goto out;
=20
 	/* If the full table has been explicitly requested */
-	if (tt_request->flags & TT_FULL_TABLE ||
+	if (tt_request->flags & BATADV_TT_FULL_TABLE ||
 	    !req_dst_orig_node->tt_buff)
 		full_table =3D true;
 	else
@@ -1584,15 +1589,15 @@ static bool batadv_send_other_tt_response(struc=
t bat_priv *bat_priv,
 		tt_response =3D (struct tt_query_packet *)skb->data;
 	}
=20
-	tt_response->header.packet_type =3D BAT_TT_QUERY;
+	tt_response->header.packet_type =3D BATADV_TT_QUERY;
 	tt_response->header.version =3D BATADV_COMPAT_VERSION;
 	tt_response->header.ttl =3D BATADV_TTL;
 	memcpy(tt_response->src, req_dst_orig_node->orig, ETH_ALEN);
 	memcpy(tt_response->dst, tt_request->src, ETH_ALEN);
-	tt_response->flags =3D TT_RESPONSE;
+	tt_response->flags =3D BATADV_TT_RESPONSE;
=20
 	if (full_table)
-		tt_response->flags |=3D TT_FULL_TABLE;
+		tt_response->flags |=3D BATADV_TT_FULL_TABLE;
=20
 	batadv_dbg(DBG_TT, bat_priv,
 		   "Sending TT_RESPONSE %pM via %pM for %pM (ttvn: %u)\n",
@@ -1639,7 +1644,7 @@ static bool batadv_send_my_tt_response(struct bat=
_priv *bat_priv,
 	batadv_dbg(DBG_TT, bat_priv,
 		   "Received TT_REQUEST from %pM for ttvn: %u (me) [%c]\n",
 		   tt_request->src, tt_request->ttvn,
-		   (tt_request->flags & TT_FULL_TABLE ? 'F' : '.'));
+		   (tt_request->flags & BATADV_TT_FULL_TABLE ? 'F' : '.'));
=20
=20
 	my_ttvn =3D (uint8_t)atomic_read(&bat_priv->ttvn);
@@ -1660,7 +1665,7 @@ static bool batadv_send_my_tt_response(struct bat=
_priv *bat_priv,
 	/* If the full table has been explicitly requested or the gap
 	 * is too big send the whole local translation table
 	 */
-	if (tt_request->flags & TT_FULL_TABLE || my_ttvn !=3D req_ttvn ||
+	if (tt_request->flags & BATADV_TT_FULL_TABLE || my_ttvn !=3D req_ttvn=
 ||
 	    !bat_priv->tt_buff)
 		full_table =3D true;
 	else
@@ -1705,20 +1710,20 @@ static bool batadv_send_my_tt_response(struct b=
at_priv *bat_priv,
 		tt_response =3D (struct tt_query_packet *)skb->data;
 	}
=20
-	tt_response->header.packet_type =3D BAT_TT_QUERY;
+	tt_response->header.packet_type =3D BATADV_TT_QUERY;
 	tt_response->header.version =3D BATADV_COMPAT_VERSION;
 	tt_response->header.ttl =3D BATADV_TTL;
 	memcpy(tt_response->src, primary_if->net_dev->dev_addr, ETH_ALEN);
 	memcpy(tt_response->dst, tt_request->src, ETH_ALEN);
-	tt_response->flags =3D TT_RESPONSE;
+	tt_response->flags =3D BATADV_TT_RESPONSE;
=20
 	if (full_table)
-		tt_response->flags |=3D TT_FULL_TABLE;
+		tt_response->flags |=3D BATADV_TT_FULL_TABLE;
=20
 	batadv_dbg(DBG_TT, bat_priv,
 		   "Sending TT_RESPONSE to %pM via %pM [%c]\n",
 		   orig_node->orig, neigh_node->addr,
-		   (tt_response->flags & TT_FULL_TABLE ? 'F' : '.'));
+		   (tt_response->flags & BATADV_TT_FULL_TABLE ? 'F' : '.'));
=20
 	batadv_inc_counter(bat_priv, BATADV_CNT_TT_RESPONSE_TX);
=20
@@ -1764,8 +1769,8 @@ static void _batadv_tt_update_changes(struct bat_=
priv *bat_priv,
 	int roams;
=20
 	for (i =3D 0; i < tt_num_changes; i++) {
-		if ((tt_change + i)->flags & TT_CLIENT_DEL) {
-			roams =3D (tt_change + i)->flags & TT_CLIENT_ROAM;
+		if ((tt_change + i)->flags & BATADV_TT_CLIENT_DEL) {
+			roams =3D (tt_change + i)->flags & BATADV_TT_CLIENT_ROAM;
 			batadv_tt_global_del(bat_priv, orig_node,
 					     (tt_change + i)->addr,
 					     "tt removed by changes",
@@ -1840,7 +1845,7 @@ bool batadv_is_my_client(struct bat_priv *bat_pri=
v, const uint8_t *addr)
 	/* Check if the client has been logically deleted (but is kept for
 	 * consistency purpose)
 	 */
-	if (tt_local_entry->common.flags & TT_CLIENT_PENDING)
+	if (tt_local_entry->common.flags & BATADV_TT_CLIENT_PENDING)
 		goto out;
 	ret =3D true;
 out:
@@ -1859,7 +1864,7 @@ void batadv_handle_tt_response(struct bat_priv *b=
at_priv,
 		   "Received TT_RESPONSE from %pM for ttvn %d t_size: %d [%c]\n",
 		   tt_response->src, tt_response->ttvn,
 		   ntohs(tt_response->tt_data),
-		   (tt_response->flags & TT_FULL_TABLE ? 'F' : '.'));
+		   (tt_response->flags & BATADV_TT_FULL_TABLE ? 'F' : '.'));
=20
 	/* we should have never asked a backbone gw */
 	if (batadv_bla_is_backbone_gw_orig(bat_priv, tt_response->src))
@@ -1869,7 +1874,7 @@ void batadv_handle_tt_response(struct bat_priv *b=
at_priv,
 	if (!orig_node)
 		goto out;
=20
-	if (tt_response->flags & TT_FULL_TABLE)
+	if (tt_response->flags & BATADV_TT_FULL_TABLE)
 		batadv_tt_fill_gtable(bat_priv, tt_response);
 	else
 		batadv_tt_update_changes(bat_priv, orig_node,
@@ -2019,7 +2024,7 @@ static void batadv_send_roam_adv(struct bat_priv =
*bat_priv, uint8_t *client,
 	roam_adv_packet =3D (struct roam_adv_packet *)skb_put(skb,
 					sizeof(struct roam_adv_packet));
=20
-	roam_adv_packet->header.packet_type =3D BAT_ROAM_ADV;
+	roam_adv_packet->header.packet_type =3D BATADV_ROAM_ADV;
 	roam_adv_packet->header.version =3D BATADV_COMPAT_VERSION;
 	roam_adv_packet->header.ttl =3D BATADV_TTL;
 	primary_if =3D batadv_primary_if_get_selected(bat_priv);
@@ -2117,11 +2122,11 @@ out:
 	return changed_num;
 }
=20
-/* Purge out all the tt local entries marked with TT_CLIENT_PENDING */
+/* Purge out all the tt local entries marked with BATADV_TT_CLIENT_PEN=
DING */
 static void batadv_tt_local_purge_pending_clients(struct bat_priv *bat=
_priv)
 {
 	struct hashtable_t *hash =3D bat_priv->tt_local_hash;
-	struct tt_common_entry *tt_common_entry;
+	struct tt_common_entry *tt_common;
 	struct tt_local_entry *tt_local_entry;
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
@@ -2136,18 +2141,18 @@ static void batadv_tt_local_purge_pending_clien=
ts(struct bat_priv *bat_priv)
 		list_lock =3D &hash->list_locks[i];
=20
 		spin_lock_bh(list_lock);
-		hlist_for_each_entry_safe(tt_common_entry, node, node_tmp,
-					  head, hash_entry) {
-			if (!(tt_common_entry->flags & TT_CLIENT_PENDING))
+		hlist_for_each_entry_safe(tt_common, node, node_tmp, head,
+					  hash_entry) {
+			if (!(tt_common->flags & BATADV_TT_CLIENT_PENDING))
 				continue;
=20
 			batadv_dbg(DBG_TT, bat_priv,
 				   "Deleting local tt entry (%pM): pending\n",
-				   tt_common_entry->addr);
+				   tt_common->addr);
=20
 			atomic_dec(&bat_priv->num_local_tt);
 			hlist_del_rcu(node);
-			tt_local_entry =3D container_of(tt_common_entry,
+			tt_local_entry =3D container_of(tt_common,
 						      struct tt_local_entry,
 						      common);
 			batadv_tt_local_entry_free_ref(tt_local_entry);
@@ -2167,7 +2172,7 @@ static int batadv_tt_commit_changes(struct bat_pr=
iv *bat_priv,
 		return -ENOENT;
=20
 	changed_num =3D batadv_tt_set_flags(bat_priv->tt_local_hash,
-					  TT_CLIENT_NEW, false);
+					  BATADV_TT_CLIENT_NEW, false);
=20
 	/* all reset entries have to be counted as local entries */
 	atomic_add(changed_num, &bat_priv->num_local_tt);
@@ -2326,7 +2331,7 @@ bool batadv_tt_global_client_is_roaming(struct ba=
t_priv *bat_priv,
 	if (!tt_global_entry)
 		goto out;
=20
-	ret =3D tt_global_entry->common.flags & TT_CLIENT_ROAM;
+	ret =3D tt_global_entry->common.flags & BATADV_TT_CLIENT_ROAM;
 	batadv_tt_global_entry_free_ref(tt_global_entry);
 out:
 	return ret;
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 8454d91..c460355 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -42,7 +42,7 @@ batadv_frag_merge_packet(struct list_head *head,
 	int uni_diff =3D sizeof(*up) - hdr_len;
=20
 	/* set skb to the first part and tmp_skb to the second part */
-	if (up->flags & UNI_FRAG_HEAD) {
+	if (up->flags & BATADV_UNI_FRAG_HEAD) {
 		tmp_skb =3D tfp->skb;
 	} else {
 		tmp_skb =3D skb;
@@ -66,7 +66,7 @@ batadv_frag_merge_packet(struct list_head *head,
=20
 	memmove(skb->data + uni_diff, skb->data, hdr_len);
 	unicast_packet =3D (struct unicast_packet *)skb_pull(skb, uni_diff);
-	unicast_packet->header.packet_type =3D BAT_UNICAST;
+	unicast_packet->header.packet_type =3D BATADV_UNICAST;
=20
 	return skb;
=20
@@ -121,7 +121,7 @@ batadv_frag_search_packet(struct list_head *head,
 	struct unicast_frag_packet *tmp_up =3D NULL;
 	uint16_t search_seqno;
=20
-	if (up->flags & UNI_FRAG_HEAD)
+	if (up->flags & BATADV_UNI_FRAG_HEAD)
 		search_seqno =3D ntohs(up->seqno)+1;
 	else
 		search_seqno =3D ntohs(up->seqno)-1;
@@ -138,8 +138,8 @@ batadv_frag_search_packet(struct list_head *head,
=20
 		if (tfp->seqno =3D=3D search_seqno) {
=20
-			if ((tmp_up->flags & UNI_FRAG_HEAD) !=3D
-			    (up->flags & UNI_FRAG_HEAD))
+			if ((tmp_up->flags & BATADV_UNI_FRAG_HEAD) !=3D
+			    (up->flags & BATADV_UNI_FRAG_HEAD))
 				return tfp;
 			else
 				goto mov_tail;
@@ -254,15 +254,15 @@ int batadv_frag_send_skb(struct sk_buff *skb, str=
uct bat_priv *bat_priv,
=20
 	frag1->header.ttl--;
 	frag1->header.version =3D BATADV_COMPAT_VERSION;
-	frag1->header.packet_type =3D BAT_UNICAST_FRAG;
+	frag1->header.packet_type =3D BATADV_UNICAST_FRAG;
=20
 	memcpy(frag1->orig, primary_if->net_dev->dev_addr, ETH_ALEN);
 	memcpy(frag2, frag1, sizeof(*frag2));
=20
 	if (data_len & 1)
-		large_tail =3D UNI_FRAG_LARGETAIL;
+		large_tail =3D BATADV_UNI_FRAG_LARGETAIL;
=20
-	frag1->flags =3D UNI_FRAG_HEAD | large_tail;
+	frag1->flags =3D BATADV_UNI_FRAG_HEAD | large_tail;
 	frag2->flags =3D large_tail;
=20
 	seqno =3D atomic_add_return(2, &hard_iface->frag_seqno);
@@ -321,7 +321,7 @@ find_router:
=20
 	unicast_packet->header.version =3D BATADV_COMPAT_VERSION;
 	/* batman packet type: unicast */
-	unicast_packet->header.packet_type =3D BAT_UNICAST;
+	unicast_packet->header.packet_type =3D BATADV_UNICAST;
 	/* set unicast ttl */
 	unicast_packet->header.ttl =3D BATADV_TTL;
 	/* copy the destination for faster routing */
diff --git a/net/batman-adv/unicast.h b/net/batman-adv/unicast.h
index 936287f..510e23f 100644
--- a/net/batman-adv/unicast.h
+++ b/net/batman-adv/unicast.h
@@ -41,8 +41,8 @@ static inline int batadv_frag_can_reassemble(const st=
ruct sk_buff *skb, int mtu)
=20
 	unicast_packet =3D (struct unicast_frag_packet *)skb->data;
=20
-	if (unicast_packet->flags & UNI_FRAG_LARGETAIL) {
-		if (unicast_packet->flags & UNI_FRAG_HEAD)
+	if (unicast_packet->flags & BATADV_UNI_FRAG_LARGETAIL) {
+		if (unicast_packet->flags & BATADV_UNI_FRAG_HEAD)
 			uneven_correction =3D 1;
 		else
 			uneven_correction =3D -1;
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index c920b4b..f5692ee 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -256,7 +256,7 @@ int batadv_vis_seq_print_text(struct seq_file *seq,=
 void *offset)
 	if (!primary_if)
 		goto out;
=20
-	if (vis_server =3D=3D VIS_TYPE_CLIENT_UPDATE)
+	if (vis_server =3D=3D BATADV_VIS_TYPE_CLIENT_UPDATE)
 		goto out;
=20
 	spin_lock_bh(&bat_priv->vis_hash_lock);
@@ -437,7 +437,7 @@ void batadv_receive_server_sync_packet(struct bat_p=
riv *bat_priv,
 	int is_new, make_broadcast;
 	int vis_server =3D atomic_read(&bat_priv->vis_mode);
=20
-	make_broadcast =3D (vis_server =3D=3D VIS_TYPE_SERVER_SYNC);
+	make_broadcast =3D (vis_server =3D=3D BATADV_VIS_TYPE_SERVER_SYNC);
=20
 	spin_lock_bh(&bat_priv->vis_hash_lock);
 	info =3D batadv_add_packet(bat_priv, vis_packet, vis_info_len,
@@ -448,7 +448,7 @@ void batadv_receive_server_sync_packet(struct bat_p=
riv *bat_priv,
 	/* only if we are server ourselves and packet is newer than the one i=
n
 	 * hash.
 	 */
-	if (vis_server =3D=3D VIS_TYPE_SERVER_SYNC && is_new)
+	if (vis_server =3D=3D BATADV_VIS_TYPE_SERVER_SYNC && is_new)
 		batadv_send_list_add(bat_priv, info);
 end:
 	spin_unlock_bh(&bat_priv->vis_hash_lock);
@@ -470,7 +470,7 @@ void batadv_receive_client_update_packet(struct bat=
_priv *bat_priv,
 		return;
=20
 	/* Are we the target for this VIS packet? */
-	if (vis_server =3D=3D VIS_TYPE_SERVER_SYNC	&&
+	if (vis_server =3D=3D BATADV_VIS_TYPE_SERVER_SYNC	&&
 	    batadv_is_my_mac(vis_packet->target_orig))
 		are_target =3D 1;
=20
@@ -486,7 +486,7 @@ void batadv_receive_client_update_packet(struct bat=
_priv *bat_priv,
=20
 	/* send only if we're the target server or ... */
 	if (are_target && is_new) {
-		packet->vis_type =3D VIS_TYPE_SERVER_SYNC;	/* upgrade! */
+		packet->vis_type =3D BATADV_VIS_TYPE_SERVER_SYNC;	/* upgrade! */
 		batadv_send_list_add(bat_priv, info);
=20
 		/* ... we're not the recipient (and thus need to forward). */
@@ -526,7 +526,7 @@ static int batadv_find_best_vis_server(struct bat_p=
riv *bat_priv,
 			if (!router)
 				continue;
=20
-			if ((orig_node->flags & VIS_SERVER) &&
+			if ((orig_node->flags & BATADV_VIS_SERVER) &&
 			    (router->tq_avg > best_tq)) {
 				best_tq =3D router->tq_avg;
 				memcpy(packet->target_orig, orig_node->orig,
@@ -580,7 +580,7 @@ static int batadv_generate_vis_packet(struct bat_pr=
iv *bat_priv)
 	packet->entries =3D 0;
 	skb_trim(info->skb_packet, sizeof(*packet));
=20
-	if (packet->vis_type =3D=3D VIS_TYPE_CLIENT_UPDATE) {
+	if (packet->vis_type =3D=3D BATADV_VIS_TYPE_CLIENT_UPDATE) {
 		best_tq =3D batadv_find_best_vis_server(bat_priv, info);
=20
 		if (best_tq < 0)
@@ -707,7 +707,7 @@ static void batadv_broadcast_vis_packet(struct bat_=
priv *bat_priv,
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(orig_node, node, head, hash_entry) {
 			/* if it's a vis server and reachable, send it. */
-			if (!(orig_node->flags & VIS_SERVER))
+			if (!(orig_node->flags & BATADV_VIS_SERVER))
 				continue;
=20
 			router =3D batadv_orig_node_get_router(orig_node);
@@ -875,7 +875,7 @@ int batadv_vis_init(struct bat_priv *bat_priv)
 	kref_init(&bat_priv->my_vis_info->refcount);
 	bat_priv->my_vis_info->bat_priv =3D bat_priv;
 	packet->header.version =3D BATADV_COMPAT_VERSION;
-	packet->header.packet_type =3D BAT_VIS;
+	packet->header.packet_type =3D BATADV_VIS;
 	packet->header.ttl =3D BATADV_TTL;
 	packet->seqno =3D 0;
 	packet->entries =3D 0;
--=20
1.7.9.4
