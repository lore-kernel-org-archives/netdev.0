From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 14/18] batman-adv: Prefix packet defines with BATADV_
Date: Thu, 28 Jun 2012 11:34:23 +0200
Message-ID: <1340876067-28333-15-git-send-email-ordex@autistici.org>
References: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:30386 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932806Ab2F1Jeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 05:34:37 -0400
In-Reply-To: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sven Eckelmann <sven@narfation.org>

Reported-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c        |   20 ++++++++++----------
 net/batman-adv/hard-interface.c    |    3 ++-
 net/batman-adv/icmp_socket.c       |    4 ++--
 net/batman-adv/main.c              |    4 ++--
 net/batman-adv/packet.h            |   12 ++++++------
 net/batman-adv/routing.c           |    4 ++--
 net/batman-adv/send.c              |    4 ++--
 net/batman-adv/soft-interface.c    |   12 +++++++-----
 net/batman-adv/translation-table.c |    8 ++++----
 net/batman-adv/unicast.c           |    4 ++--
 net/batman-adv/vis.c               |    2 +-
 11 files changed, 40 insertions(+), 37 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index ffe9d1d..245bb2d 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -64,7 +64,7 @@ static int batadv_iv_ogm_iface_enable(struct hard_ifa=
ce *hard_iface)
 	get_random_bytes(&random_seqno, sizeof(random_seqno));
 	atomic_set(&hard_iface->seqno, random_seqno);
=20
-	hard_iface->packet_len =3D BATMAN_OGM_HLEN;
+	hard_iface->packet_len =3D BATADV_OGM_HLEN;
 	hard_iface->packet_buff =3D kmalloc(hard_iface->packet_len, GFP_ATOMI=
C);
=20
 	if (!hard_iface->packet_buff)
@@ -72,7 +72,7 @@ static int batadv_iv_ogm_iface_enable(struct hard_ifa=
ce *hard_iface)
=20
 	batman_ogm_packet =3D (struct batman_ogm_packet *)hard_iface->packet_=
buff;
 	batman_ogm_packet->header.packet_type =3D BAT_IV_OGM;
-	batman_ogm_packet->header.version =3D COMPAT_VERSION;
+	batman_ogm_packet->header.version =3D BATADV_COMPAT_VERSION;
 	batman_ogm_packet->header.ttl =3D 2;
 	batman_ogm_packet->flags =3D NO_FLAGS;
 	batman_ogm_packet->tq =3D TQ_MAX_VALUE;
@@ -139,7 +139,7 @@ static int batadv_iv_ogm_aggr_packet(int buff_pos, =
int packet_len,
 {
 	int next_buff_pos =3D 0;
=20
-	next_buff_pos +=3D buff_pos + BATMAN_OGM_HLEN;
+	next_buff_pos +=3D buff_pos + BATADV_OGM_HLEN;
 	next_buff_pos +=3D batadv_tt_len(tt_num_changes);
=20
 	return (next_buff_pos <=3D packet_len) &&
@@ -191,7 +191,7 @@ static void batadv_iv_ogm_send_to_if(struct forw_pa=
cket *forw_packet,
 			   batman_ogm_packet->ttvn, hard_iface->net_dev->name,
 			   hard_iface->net_dev->dev_addr);
=20
-		buff_pos +=3D BATMAN_OGM_HLEN;
+		buff_pos +=3D BATADV_OGM_HLEN;
 		buff_pos +=3D batadv_tt_len(batman_ogm_packet->tt_num_changes);
 		packet_num++;
 		batman_ogm_packet =3D (struct batman_ogm_packet *)
@@ -561,7 +561,7 @@ static void batadv_iv_ogm_forward(struct orig_node =
*orig_node,
 		batman_ogm_packet->flags &=3D ~DIRECTLINK;
=20
 	batadv_iv_ogm_queue_add(bat_priv, (unsigned char *)batman_ogm_packet,
-				BATMAN_OGM_HLEN + batadv_tt_len(tt_num_changes),
+				BATADV_OGM_HLEN + batadv_tt_len(tt_num_changes),
 				if_incoming, 0, batadv_iv_ogm_fwd_send_time());
 }
=20
@@ -579,7 +579,7 @@ static void batadv_iv_ogm_schedule(struct hard_ifac=
e *hard_iface)
 		tt_num_changes =3D batadv_tt_append_diff(bat_priv,
 						       &hard_iface->packet_buff,
 						       &hard_iface->packet_len,
-						       BATMAN_OGM_HLEN);
+						       BATADV_OGM_HLEN);
=20
 	batman_ogm_packet =3D (struct batman_ogm_packet *)hard_iface->packet_=
buff;
=20
@@ -1025,7 +1025,7 @@ static void batadv_iv_ogm_process(const struct et=
hhdr *ethhdr,
 	}
 	rcu_read_unlock();
=20
-	if (batman_ogm_packet->header.version !=3D COMPAT_VERSION) {
+	if (batman_ogm_packet->header.version !=3D BATADV_COMPAT_VERSION) {
 		batadv_dbg(DBG_BATMAN, bat_priv,
 			   "Drop packet: incompatible batman version (%i)\n",
 			   batman_ogm_packet->header.version);
@@ -1227,7 +1227,7 @@ static int batadv_iv_ogm_receive(struct sk_buff *=
skb,
 	unsigned char *tt_buff, *packet_buff;
 	bool ret;
=20
-	ret =3D batadv_check_management_packet(skb, if_incoming, BATMAN_OGM_H=
LEN);
+	ret =3D batadv_check_management_packet(skb, if_incoming, BATADV_OGM_H=
LEN);
 	if (!ret)
 		return NET_RX_DROP;
=20
@@ -1248,12 +1248,12 @@ static int batadv_iv_ogm_receive(struct sk_buff=
 *skb,
=20
 	/* unpack the aggregated packets and process them one by one */
 	do {
-		tt_buff =3D packet_buff + buff_pos + BATMAN_OGM_HLEN;
+		tt_buff =3D packet_buff + buff_pos + BATADV_OGM_HLEN;
=20
 		batadv_iv_ogm_process(ethhdr, batman_ogm_packet, tt_buff,
 				      if_incoming);
=20
-		buff_pos +=3D BATMAN_OGM_HLEN;
+		buff_pos +=3D BATADV_OGM_HLEN;
 		buff_pos +=3D batadv_tt_len(batman_ogm_packet->tt_num_changes);
=20
 		batman_ogm_packet =3D (struct batman_ogm_packet *)
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-inte=
rface.c
index c1ba6e2..3401084 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -263,6 +263,7 @@ int batadv_hardif_enable_interface(struct hard_ifac=
e *hard_iface,
 {
 	struct bat_priv *bat_priv;
 	struct net_device *soft_iface;
+	__be16 ethertype =3D __constant_htons(BATADV_ETH_P_BATMAN);
 	int ret;
=20
 	if (hard_iface->if_status !=3D IF_NOT_IN_USE)
@@ -309,7 +310,7 @@ int batadv_hardif_enable_interface(struct hard_ifac=
e *hard_iface,
 	hard_iface->if_status =3D IF_INACTIVE;
 	batadv_orig_hash_add_if(hard_iface, bat_priv->num_ifaces);
=20
-	hard_iface->batman_adv_ptype.type =3D __constant_htons(ETH_P_BATMAN);
+	hard_iface->batman_adv_ptype.type =3D ethertype;
 	hard_iface->batman_adv_ptype.func =3D batadv_batman_skb_recv;
 	hard_iface->batman_adv_ptype.dev =3D hard_iface->net_dev;
 	dev_add_pack(&hard_iface->batman_adv_ptype);
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.=
c
index 4f45ca7..f2f578b 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -203,9 +203,9 @@ static ssize_t batadv_socket_write(struct file *fil=
e, const char __user *buff,
=20
 	icmp_packet->uid =3D socket_client->index;
=20
-	if (icmp_packet->header.version !=3D COMPAT_VERSION) {
+	if (icmp_packet->header.version !=3D BATADV_COMPAT_VERSION) {
 		icmp_packet->msg_type =3D PARAMETER_PROBLEM;
-		icmp_packet->header.version =3D COMPAT_VERSION;
+		icmp_packet->header.version =3D BATADV_COMPAT_VERSION;
 		batadv_socket_add_packet(socket_client, icmp_packet,
 					 packet_len);
 		goto free_skb;
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 9cf0b38..986be72 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -72,7 +72,7 @@ static int __init batadv_init(void)
 	register_netdevice_notifier(&batadv_hard_if_notifier);
=20
 	pr_info("B.A.T.M.A.N. advanced %s (compatibility version %i) loaded\n=
",
-		SOURCE_VERSION, COMPAT_VERSION);
+		SOURCE_VERSION, BATADV_COMPAT_VERSION);
=20
 	return 0;
 }
@@ -238,7 +238,7 @@ int batadv_batman_skb_recv(struct sk_buff *skb, str=
uct net_device *dev,
=20
 	batman_ogm_packet =3D (struct batman_ogm_packet *)skb->data;
=20
-	if (batman_ogm_packet->header.version !=3D COMPAT_VERSION) {
+	if (batman_ogm_packet->header.version !=3D BATADV_COMPAT_VERSION) {
 		batadv_dbg(DBG_BATMAN, bat_priv,
 			   "Drop packet: incompatible batman version (%i)\n",
 			   batman_ogm_packet->header.version);
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index c90219c..e562414 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -20,7 +20,7 @@
 #ifndef _NET_BATMAN_ADV_PACKET_H_
 #define _NET_BATMAN_ADV_PACKET_H_
=20
-#define ETH_P_BATMAN  0x4305	/* unofficial/not registered Ethertype */
+#define BATADV_ETH_P_BATMAN  0x4305 /* unofficial/not registered Ether=
type */
=20
 enum bat_packettype {
 	BAT_IV_OGM	 =3D 0x01,
@@ -34,7 +34,7 @@ enum bat_packettype {
 };
=20
 /* this file is included by batctl which needs these defines */
-#define COMPAT_VERSION 14
+#define BATADV_COMPAT_VERSION 14
=20
 enum batman_iv_flags {
 	NOT_BEST_NEXT_HOP   =3D 1 << 3,
@@ -65,7 +65,7 @@ enum unicast_frag_flags {
 };
=20
 /* TT_QUERY subtypes */
-#define TT_QUERY_TYPE_MASK 0x3
+#define BATADV_TT_QUERY_TYPE_MASK 0x3
=20
 enum tt_query_packettype {
 	TT_REQUEST    =3D 0,
@@ -126,7 +126,7 @@ struct batman_ogm_packet {
 	__be16   tt_crc;
 } __packed;
=20
-#define BATMAN_OGM_HLEN sizeof(struct batman_ogm_packet)
+#define BATADV_OGM_HLEN sizeof(struct batman_ogm_packet)
=20
 struct icmp_packet {
 	struct batman_header header;
@@ -138,7 +138,7 @@ struct icmp_packet {
 	uint8_t  reserved;
 } __packed;
=20
-#define BAT_RR_LEN 16
+#define BATADV_RR_LEN 16
=20
 /* icmp_packet_rr must start with all fields from imcp_packet
  * as this is assumed by code that handles ICMP packets
@@ -151,7 +151,7 @@ struct icmp_packet_rr {
 	__be16   seqno;
 	uint8_t  uid;
 	uint8_t  rr_cur;
-	uint8_t  rr[BAT_RR_LEN][ETH_ALEN];
+	uint8_t  rr[BATADV_RR_LEN][ETH_ALEN];
 } __packed;
=20
 struct unicast_packet {
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 864692a..c8fee74 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -423,7 +423,7 @@ int batadv_recv_icmp_packet(struct sk_buff *skb, st=
ruct hard_iface *recv_if)
=20
 	/* add record route information if not full */
 	if ((hdr_size =3D=3D sizeof(struct icmp_packet_rr)) &&
-	    (icmp_packet->rr_cur < BAT_RR_LEN)) {
+	    (icmp_packet->rr_cur < BATADV_RR_LEN)) {
 		memcpy(&(icmp_packet->rr[icmp_packet->rr_cur]),
 		       ethhdr->h_dest, ETH_ALEN);
 		icmp_packet->rr_cur++;
@@ -603,7 +603,7 @@ int batadv_recv_tt_query(struct sk_buff *skb, struc=
t hard_iface *recv_if)
=20
 	tt_query =3D (struct tt_query_packet *)skb->data;
=20
-	switch (tt_query->flags & TT_QUERY_TYPE_MASK) {
+	switch (tt_query->flags & BATADV_TT_QUERY_TYPE_MASK) {
 	case TT_REQUEST:
 		batadv_inc_counter(bat_priv, BAT_CNT_TT_REQUEST_RX);
=20
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 3d725e0..72542cb 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -58,11 +58,11 @@ int batadv_send_skb_packet(struct sk_buff *skb, str=
uct hard_iface *hard_iface,
 	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
 	memcpy(ethhdr->h_source, hard_iface->net_dev->dev_addr, ETH_ALEN);
 	memcpy(ethhdr->h_dest, dst_addr, ETH_ALEN);
-	ethhdr->h_proto =3D __constant_htons(ETH_P_BATMAN);
+	ethhdr->h_proto =3D __constant_htons(BATADV_ETH_P_BATMAN);
=20
 	skb_set_network_header(skb, ETH_HLEN);
 	skb->priority =3D TC_PRIO_CONTROL;
-	skb->protocol =3D __constant_htons(ETH_P_BATMAN);
+	skb->protocol =3D __constant_htons(BATADV_ETH_P_BATMAN);
=20
 	skb->dev =3D hard_iface->net_dev;
=20
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 2de1d74..e726419 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -135,6 +135,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	struct hard_iface *primary_if =3D NULL;
 	struct bcast_packet *bcast_packet;
 	struct vlan_ethhdr *vhdr;
+	__be16 ethertype =3D __constant_htons(BATADV_ETH_P_BATMAN);
 	static const uint8_t stp_addr[ETH_ALEN] =3D {0x01, 0x80, 0xC2, 0x00, =
0x00,
 						   0x00};
 	unsigned int header_len =3D 0;
@@ -152,11 +153,11 @@ static int batadv_interface_tx(struct sk_buff *sk=
b,
 		vhdr =3D (struct vlan_ethhdr *)skb->data;
 		vid =3D ntohs(vhdr->h_vlan_TCI) & VLAN_VID_MASK;
=20
-		if (ntohs(vhdr->h_vlan_encapsulated_proto) !=3D ETH_P_BATMAN)
+		if (vhdr->h_vlan_encapsulated_proto !=3D ethertype)
 			break;
=20
 		/* fall through */
-	case ETH_P_BATMAN:
+	case BATADV_ETH_P_BATMAN:
 		goto dropped;
 	}
=20
@@ -208,7 +209,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 			goto dropped;
=20
 		bcast_packet =3D (struct bcast_packet *)skb->data;
-		bcast_packet->header.version =3D COMPAT_VERSION;
+		bcast_packet->header.version =3D BATADV_COMPAT_VERSION;
 		bcast_packet->header.ttl =3D TTL;
=20
 		/* batman packet type: broadcast */
@@ -266,6 +267,7 @@ void batadv_interface_rx(struct net_device *soft_if=
ace,
 	struct ethhdr *ethhdr;
 	struct vlan_ethhdr *vhdr;
 	short vid __maybe_unused =3D -1;
+	__be16 ethertype =3D __constant_htons(BATADV_ETH_P_BATMAN);
=20
 	/* check if enough space is available for pulling, and pull */
 	if (!pskb_may_pull(skb, hdr_size))
@@ -281,11 +283,11 @@ void batadv_interface_rx(struct net_device *soft_=
iface,
 		vhdr =3D (struct vlan_ethhdr *)skb->data;
 		vid =3D ntohs(vhdr->h_vlan_TCI) & VLAN_VID_MASK;
=20
-		if (ntohs(vhdr->h_vlan_encapsulated_proto) !=3D ETH_P_BATMAN)
+		if (vhdr->h_vlan_encapsulated_proto !=3D ethertype)
 			break;
=20
 		/* fall through */
-	case ETH_P_BATMAN:
+	case BATADV_ETH_P_BATMAN:
 		goto dropped;
 	}
=20
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/transl=
ation-table.c
index 3ca2e48..79cd3f7 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1441,7 +1441,7 @@ static int batadv_send_tt_request(struct bat_priv=
 *bat_priv,
 				sizeof(struct tt_query_packet));
=20
 	tt_request->header.packet_type =3D BAT_TT_QUERY;
-	tt_request->header.version =3D COMPAT_VERSION;
+	tt_request->header.version =3D BATADV_COMPAT_VERSION;
 	memcpy(tt_request->src, primary_if->net_dev->dev_addr, ETH_ALEN);
 	memcpy(tt_request->dst, dst_orig_node->orig, ETH_ALEN);
 	tt_request->header.ttl =3D TTL;
@@ -1575,7 +1575,7 @@ static bool batadv_send_other_tt_response(struct =
bat_priv *bat_priv,
 	}
=20
 	tt_response->header.packet_type =3D BAT_TT_QUERY;
-	tt_response->header.version =3D COMPAT_VERSION;
+	tt_response->header.version =3D BATADV_COMPAT_VERSION;
 	tt_response->header.ttl =3D TTL;
 	memcpy(tt_response->src, req_dst_orig_node->orig, ETH_ALEN);
 	memcpy(tt_response->dst, tt_request->src, ETH_ALEN);
@@ -1696,7 +1696,7 @@ static bool batadv_send_my_tt_response(struct bat=
_priv *bat_priv,
 	}
=20
 	tt_response->header.packet_type =3D BAT_TT_QUERY;
-	tt_response->header.version =3D COMPAT_VERSION;
+	tt_response->header.version =3D BATADV_COMPAT_VERSION;
 	tt_response->header.ttl =3D TTL;
 	memcpy(tt_response->src, primary_if->net_dev->dev_addr, ETH_ALEN);
 	memcpy(tt_response->dst, tt_request->src, ETH_ALEN);
@@ -2008,7 +2008,7 @@ static void batadv_send_roam_adv(struct bat_priv =
*bat_priv, uint8_t *client,
 					sizeof(struct roam_adv_packet));
=20
 	roam_adv_packet->header.packet_type =3D BAT_ROAM_ADV;
-	roam_adv_packet->header.version =3D COMPAT_VERSION;
+	roam_adv_packet->header.version =3D BATADV_COMPAT_VERSION;
 	roam_adv_packet->header.ttl =3D TTL;
 	primary_if =3D batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 472436a..c8da6b0 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -253,7 +253,7 @@ int batadv_frag_send_skb(struct sk_buff *skb, struc=
t bat_priv *bat_priv,
 	memcpy(frag1, &tmp_uc, sizeof(tmp_uc));
=20
 	frag1->header.ttl--;
-	frag1->header.version =3D COMPAT_VERSION;
+	frag1->header.version =3D BATADV_COMPAT_VERSION;
 	frag1->header.packet_type =3D BAT_UNICAST_FRAG;
=20
 	memcpy(frag1->orig, primary_if->net_dev->dev_addr, ETH_ALEN);
@@ -319,7 +319,7 @@ find_router:
=20
 	unicast_packet =3D (struct unicast_packet *)skb->data;
=20
-	unicast_packet->header.version =3D COMPAT_VERSION;
+	unicast_packet->header.version =3D BATADV_COMPAT_VERSION;
 	/* batman packet type: unicast */
 	unicast_packet->header.packet_type =3D BAT_UNICAST;
 	/* set unicast ttl */
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 7dc7506..596eacc 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -873,7 +873,7 @@ int batadv_vis_init(struct bat_priv *bat_priv)
 	INIT_LIST_HEAD(&bat_priv->my_vis_info->send_list);
 	kref_init(&bat_priv->my_vis_info->refcount);
 	bat_priv->my_vis_info->bat_priv =3D bat_priv;
-	packet->header.version =3D COMPAT_VERSION;
+	packet->header.version =3D BATADV_COMPAT_VERSION;
 	packet->header.packet_type =3D BAT_VIS;
 	packet->header.ttl =3D TTL;
 	packet->seqno =3D 0;
--=20
1.7.9.4
