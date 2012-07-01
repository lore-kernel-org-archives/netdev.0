From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 05/16] batman-adv: Prefix main enum with BATADV_
Date: Mon,  2 Jul 2012 01:43:35 +0200
Message-ID: <1341186226-10549-6-git-send-email-ordex@autistici.org>
References: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:23565 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382Ab2GAXni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 19:43:38 -0400
In-Reply-To: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sven Eckelmann <sven@narfation.org>

Reported-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c            |   48 ++++++++++++++++--------=
--------
 net/batman-adv/bat_sysfs.c             |   12 ++++----
 net/batman-adv/bat_sysfs.h             |    4 +--
 net/batman-adv/bitarray.c              |    4 +--
 net/batman-adv/bridge_loop_avoidance.c |   46 +++++++++++++++---------=
------
 net/batman-adv/gateway_client.c        |   25 +++++++++--------
 net/batman-adv/icmp_socket.c           |    8 +++---
 net/batman-adv/main.c                  |   10 +++----
 net/batman-adv/main.h                  |   36 ++++++++++++------------
 net/batman-adv/originator.c            |   12 ++++----
 net/batman-adv/routing.c               |   18 ++++++------
 net/batman-adv/send.c                  |   11 ++++----
 net/batman-adv/soft-interface.c        |    6 ++--
 net/batman-adv/translation-table.c     |   35 ++++++++++++-----------
 14 files changed, 140 insertions(+), 135 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 58bbb20..f9981e6 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -188,7 +188,7 @@ static void batadv_iv_ogm_send_to_if(struct forw_pa=
cket *forw_packet,
 		fwd_str =3D (packet_num > 0 ? "Forwarding" : (forw_packet->own ?
 							    "Sending own" :
 							    "Forwarding"));
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "%s %spacket (originator %pM, seqno %u, TQ %d, TTL %d, IDF %s, t=
tvn %d) on interface %s [%pM]\n",
 			   fwd_str, (packet_num > 0 ? "aggregated " : ""),
 			   batman_ogm_packet->orig,
@@ -252,7 +252,7 @@ static void batadv_iv_ogm_emit(struct forw_packet *=
forw_packet)
 	    (forw_packet->own && (forw_packet->if_incoming !=3D primary_if)))=
 {
=20
 		/* FIXME: what about aggregated packets ? */
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "%s packet (originator %pM, seqno %u, TTL %d) on interface %s [%=
pM]\n",
 			   (forw_packet->own ? "Sending own" : "Forwarding"),
 			   batman_ogm_packet->orig,
@@ -385,7 +385,7 @@ static void batadv_iv_ogm_aggregate_new(const unsig=
ned char *packet_buff,
 	/* own packet should always be scheduled */
 	if (!own_packet) {
 		if (!batadv_atomic_dec_not_zero(&bat_priv->batman_queue_left)) {
-			batadv_dbg(DBG_BATMAN, bat_priv,
+			batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 				   "batman packet queue full\n");
 			goto out;
 		}
@@ -535,7 +535,7 @@ static void batadv_iv_ogm_forward(struct orig_node =
*orig_node,
 	uint8_t tt_num_changes;
=20
 	if (batman_ogm_packet->header.ttl <=3D 1) {
-		batadv_dbg(DBG_BATMAN, bat_priv, "ttl exceeded\n");
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv, "ttl exceeded\n");
 		return;
 	}
=20
@@ -561,7 +561,7 @@ static void batadv_iv_ogm_forward(struct orig_node =
*orig_node,
 	batman_ogm_packet->tq =3D batadv_hop_penalty(batman_ogm_packet->tq,
 						   bat_priv);
=20
-	batadv_dbg(DBG_BATMAN, bat_priv,
+	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 		   "Forwarding packet: tq: %i, ttl: %i\n",
 		   batman_ogm_packet->tq, batman_ogm_packet->header.ttl);
=20
@@ -642,7 +642,7 @@ batadv_iv_ogm_orig_update(struct bat_priv *bat_priv=
,
 	uint8_t bcast_own_sum_orig, bcast_own_sum_neigh;
 	uint8_t *neigh_addr;
=20
-	batadv_dbg(DBG_BATMAN, bat_priv,
+	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 		   "update_originator(): Searching and updating originator entry of =
received packet\n");
=20
 	rcu_read_lock();
@@ -685,7 +685,7 @@ batadv_iv_ogm_orig_update(struct bat_priv *bat_priv=
,
 		if (!neigh_node)
 			goto unlock;
 	} else
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Updating existing last-hop neighbor of originator\n");
=20
 	rcu_read_unlock();
@@ -866,7 +866,7 @@ static int batadv_iv_ogm_calc_tq(struct orig_node *=
orig_node,
 	combined_tq /=3D BATADV_TQ_MAX_VALUE * BATADV_TQ_MAX_VALUE;
 	batman_ogm_packet->tq =3D combined_tq;
=20
-	batadv_dbg(DBG_BATMAN, bat_priv,
+	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 		   "bidirectional: orig =3D %-15pM neigh =3D %-15pM =3D> own_bcast =3D=
 %2i, real recv =3D %2i, local tq: %3i, asym_penalty: %3i, total tq: %3=
i\n",
 		   orig_node->orig, orig_neigh_node->orig, total_count,
 		   neigh_rq_count, tq_own,
@@ -948,7 +948,7 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *et=
hhdr,
 	rcu_read_unlock();
=20
 	if (need_update) {
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "updating last_seqno: old %u, new %u\n",
 			   orig_node->last_real_seqno, seqno);
 		orig_node->last_real_seqno =3D seqno;
@@ -1007,7 +1007,7 @@ static void batadv_iv_ogm_process(const struct et=
hhdr *ethhdr,
 	if (batadv_compare_eth(ethhdr->h_source, batman_ogm_packet->orig))
 		is_single_hop_neigh =3D true;
=20
-	batadv_dbg(DBG_BATMAN, bat_priv,
+	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 		   "Received BATMAN packet via NB: %pM, IF: %s [%pM] (from OG: %pM, =
via prev OG: %pM, seqno %u, ttvn %u, crc %u, changes %u, td %d, TTL %d,=
 V %d, IDF %d)\n",
 		   ethhdr->h_source, if_incoming->net_dev->name,
 		   if_incoming->net_dev->dev_addr, batman_ogm_packet->orig,
@@ -1044,21 +1044,21 @@ static void batadv_iv_ogm_process(const struct =
ethhdr *ethhdr,
 	rcu_read_unlock();
=20
 	if (batman_ogm_packet->header.version !=3D BATADV_COMPAT_VERSION) {
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: incompatible batman version (%i)\n",
 			   batman_ogm_packet->header.version);
 		return;
 	}
=20
 	if (is_my_addr) {
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: received my own broadcast (sender: %pM)\n",
 			   ethhdr->h_source);
 		return;
 	}
=20
 	if (is_broadcast) {
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: ignoring all packets with broadcast source addr (s=
ender: %pM)\n",
 			   ethhdr->h_source);
 		return;
@@ -1097,21 +1097,21 @@ static void batadv_iv_ogm_process(const struct =
ethhdr *ethhdr,
 			spin_unlock_bh(&orig_neigh_node->ogm_cnt_lock);
 		}
=20
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: originator packet from myself (via neighbor)\n");
 		batadv_orig_node_free_ref(orig_neigh_node);
 		return;
 	}
=20
 	if (is_my_oldorig) {
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: ignoring all rebroadcast echos (sender: %pM)\n",
 			   ethhdr->h_source);
 		return;
 	}
=20
 	if (batman_ogm_packet->flags & BATADV_NOT_BEST_NEXT_HOP) {
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: ignoring all packets not forwarded from the best n=
ext hop (sender: %pM)\n",
 			   ethhdr->h_source);
 		return;
@@ -1125,14 +1125,14 @@ static void batadv_iv_ogm_process(const struct =
ethhdr *ethhdr,
 						   if_incoming);
=20
 	if (is_duplicate =3D=3D -1) {
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: packet within seqno protection time (sender: %pM)\=
n",
 			   ethhdr->h_source);
 		goto out;
 	}
=20
 	if (batman_ogm_packet->tq =3D=3D 0) {
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: originator packet with tq equal 0\n");
 		goto out;
 	}
@@ -1151,7 +1151,7 @@ static void batadv_iv_ogm_process(const struct et=
hhdr *ethhdr,
 	    (batadv_compare_eth(router->addr, prev_sender)) &&
 	    !(batadv_compare_eth(batman_ogm_packet->orig, prev_sender)) &&
 	    (batadv_compare_eth(router->addr, router_router->addr))) {
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: ignoring all rebroadcast packets that may make me =
loop (sender: %pM)\n",
 			   ethhdr->h_source);
 		goto out;
@@ -1172,7 +1172,7 @@ static void batadv_iv_ogm_process(const struct et=
hhdr *ethhdr,
 	 * don't route towards it
 	 */
 	if (!is_single_hop_neigh && (!orig_neigh_router)) {
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: OGM via unknown neighbor!\n");
 		goto out_neigh;
 	}
@@ -1201,25 +1201,25 @@ static void batadv_iv_ogm_process(const struct =
ethhdr *ethhdr,
 				      is_single_hop_neigh,
 				      is_from_best_next_hop, if_incoming);
=20
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Forwarding packet: rebroadcast neighbor packet with direct link=
 flag\n");
 		goto out_neigh;
 	}
=20
 	/* multihop originator */
 	if (!is_bidirect) {
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: not received via bidirectional link\n");
 		goto out_neigh;
 	}
=20
 	if (is_duplicate) {
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: duplicate packet received\n");
 		goto out_neigh;
 	}
=20
-	batadv_dbg(DBG_BATMAN, bat_priv,
+	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 		   "Forwarding packet: rebroadcast originator packet\n");
 	batadv_iv_ogm_forward(orig_node, ethhdr, batman_ogm_packet,
 			      is_single_hop_neigh, is_from_best_next_hop,
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index e27bfe3..c4794c6 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -485,7 +485,7 @@ BATADV_ATTR_SIF_UINT(gw_sel_class, S_IRUGO | S_IWUS=
R, 1, BATADV_TQ_MAX_VALUE,
 static BATADV_ATTR(gw_bandwidth, S_IRUGO | S_IWUSR, batadv_show_gw_bwi=
dth,
 		   batadv_store_gw_bwidth);
 #ifdef CONFIG_BATMAN_ADV_DEBUG
-BATADV_ATTR_SIF_UINT(log_level, S_IRUGO | S_IWUSR, 0, DBG_ALL, NULL);
+BATADV_ATTR_SIF_UINT(log_level, S_IRUGO | S_IWUSR, 0, BATADV_DBG_ALL, =
NULL);
 #endif
=20
 static struct bat_attribute *batadv_mesh_attrs[] =3D {
@@ -723,8 +723,8 @@ void batadv_sysfs_del_hardif(struct kobject **hardi=
f_obj)
 	*hardif_obj =3D NULL;
 }
=20
-int batadv_throw_uevent(struct bat_priv *bat_priv, enum uev_type type,
-			enum uev_action action, const char *data)
+int batadv_throw_uevent(struct bat_priv *bat_priv, enum batadv_uev_typ=
e type,
+			enum batadv_uev_action action, const char *data)
 {
 	int ret =3D -ENOMEM;
 	struct hard_iface *primary_if =3D NULL;
@@ -756,7 +756,7 @@ int batadv_throw_uevent(struct bat_priv *bat_priv, =
enum uev_type type,
 		batadv_uev_action_str[action]);
=20
 	/* If the event is DEL, ignore the data field */
-	if (action !=3D UEV_DEL) {
+	if (action !=3D BATADV_UEV_DEL) {
 		uevent_env[2] =3D kmalloc(strlen(BATADV_UEV_DATA_VAR) +
 					strlen(data) + 1, GFP_ATOMIC);
 		if (!uevent_env[2])
@@ -775,10 +775,10 @@ out:
 		batadv_hardif_free_ref(primary_if);
=20
 	if (ret)
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Impossible to send uevent for (%s,%s,%s) event (err: %d)\n",
 			   batadv_uev_type_str[type],
 			   batadv_uev_action_str[action],
-			   (action =3D=3D UEV_DEL ? "NULL" : data), ret);
+			   (action =3D=3D BATADV_UEV_DEL ? "NULL" : data), ret);
 	return ret;
 }
diff --git a/net/batman-adv/bat_sysfs.h b/net/batman-adv/bat_sysfs.h
index 23a8390..28c2948 100644
--- a/net/batman-adv/bat_sysfs.h
+++ b/net/batman-adv/bat_sysfs.h
@@ -36,7 +36,7 @@ void batadv_sysfs_del_meshif(struct net_device *dev);
 int batadv_sysfs_add_hardif(struct kobject **hardif_obj,
 			    struct net_device *dev);
 void batadv_sysfs_del_hardif(struct kobject **hardif_obj);
-int batadv_throw_uevent(struct bat_priv *bat_priv, enum uev_type type,
-			enum uev_action action, const char *data);
+int batadv_throw_uevent(struct bat_priv *bat_priv, enum batadv_uev_typ=
e type,
+			enum batadv_uev_action action, const char *data);
=20
 #endif /* _NET_BATMAN_ADV_SYSFS_H_ */
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index 4a009b5..835d3b6 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -66,7 +66,7 @@ int batadv_bit_get_packet(void *priv, unsigned long *=
seq_bits,
 	/* sequence number is much newer, probably missed a lot of packets */
 	if (seq_num_diff >=3D BATADV_TQ_LOCAL_WINDOW_SIZE &&
 	    seq_num_diff < BATADV_EXPECTED_SEQNO_RANGE) {
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "We missed a lot of packets (%i) !\n",
 			   seq_num_diff - 1);
 		bitmap_zero(seq_bits, BATADV_TQ_LOCAL_WINDOW_SIZE);
@@ -83,7 +83,7 @@ int batadv_bit_get_packet(void *priv, unsigned long *=
seq_bits,
 	if (seq_num_diff <=3D -BATADV_TQ_LOCAL_WINDOW_SIZE ||
 	    seq_num_diff >=3D BATADV_EXPECTED_SEQNO_RANGE) {
=20
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Other host probably restarted!\n");
=20
 		bitmap_zero(seq_bits, BATADV_TQ_LOCAL_WINDOW_SIZE);
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/br=
idge_loop_avoidance.c
index c375131..b463402 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -297,7 +297,7 @@ static void batadv_bla_send_claim(struct bat_priv *=
bat_priv, uint8_t *mac,
 		 * set Ethernet SRC to the clients mac
 		 */
 		memcpy(ethhdr->h_source, mac, ETH_ALEN);
-		batadv_dbg(DBG_BLA, bat_priv,
+		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_send_claim(): CLAIM %pM on vid %d\n", mac, vid);
 		break;
 	case BATADV_CLAIM_TYPE_DEL:
@@ -305,7 +305,7 @@ static void batadv_bla_send_claim(struct bat_priv *=
bat_priv, uint8_t *mac,
 		 * set HW SRC to the clients mac
 		 */
 		memcpy(hw_src, mac, ETH_ALEN);
-		batadv_dbg(DBG_BLA, bat_priv,
+		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_send_claim(): UNCLAIM %pM on vid %d\n", mac,
 			   vid);
 		break;
@@ -314,7 +314,7 @@ static void batadv_bla_send_claim(struct bat_priv *=
bat_priv, uint8_t *mac,
 		 * set HW SRC to the special mac containg the crc
 		 */
 		memcpy(hw_src, mac, ETH_ALEN);
-		batadv_dbg(DBG_BLA, bat_priv,
+		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_send_claim(): ANNOUNCE of %pM on vid %d\n",
 			   ethhdr->h_source, vid);
 		break;
@@ -324,7 +324,7 @@ static void batadv_bla_send_claim(struct bat_priv *=
bat_priv, uint8_t *mac,
 		 */
 		memcpy(hw_src, mac, ETH_ALEN);
 		memcpy(ethhdr->h_dest, mac, ETH_ALEN);
-		batadv_dbg(DBG_BLA, bat_priv,
+		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_send_claim(): REQUEST of %pM to %pMon vid %d\n",
 			   ethhdr->h_source, ethhdr->h_dest, vid);
 		break;
@@ -365,7 +365,7 @@ static struct backbone_gw *batadv_bla_get_backbone_=
gw(struct bat_priv *bat_priv,
 	if (entry)
 		return entry;
=20
-	batadv_dbg(DBG_BLA, bat_priv,
+	batadv_dbg(BATADV_DBG_BLA, bat_priv,
 		   "bla_get_backbone_gw(): not found (%pM, %d), creating new entry\n=
",
 		   orig, vid);
=20
@@ -439,7 +439,7 @@ static void batadv_bla_answer_request(struct bat_pr=
iv *bat_priv,
 	struct backbone_gw *backbone_gw;
 	int i;
=20
-	batadv_dbg(DBG_BLA, bat_priv,
+	batadv_dbg(BATADV_DBG_BLA, bat_priv,
 		   "bla_answer_request(): received a claim request, send all of our =
own claims again\n");
=20
 	backbone_gw =3D batadv_backbone_hash_find(bat_priv,
@@ -480,8 +480,8 @@ static void batadv_bla_send_request(struct backbone=
_gw *backbone_gw)
 	/* first, remove all old entries */
 	batadv_bla_del_backbone_claims(backbone_gw);
=20
-	batadv_dbg(DBG_BLA, backbone_gw->bat_priv, "Sending REQUEST to %pM\n"=
,
-		   backbone_gw->orig);
+	batadv_dbg(BATADV_DBG_BLA, backbone_gw->bat_priv,
+		   "Sending REQUEST to %pM\n", backbone_gw->orig);
=20
 	/* send request */
 	batadv_bla_send_claim(backbone_gw->bat_priv, backbone_gw->orig,
@@ -546,7 +546,7 @@ static void batadv_bla_add_claim(struct bat_priv *b=
at_priv, const uint8_t *mac,
 		claim->backbone_gw =3D backbone_gw;
=20
 		atomic_set(&claim->refcount, 2);
-		batadv_dbg(DBG_BLA, bat_priv,
+		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_add_claim(): adding new entry %pM, vid %d to hash ...\n",
 			   mac, vid);
 		hash_added =3D batadv_hash_add(bat_priv->claim_hash,
@@ -565,7 +565,7 @@ static void batadv_bla_add_claim(struct bat_priv *b=
at_priv, const uint8_t *mac,
 			/* no need to register a new backbone */
 			goto claim_free_ref;
=20
-		batadv_dbg(DBG_BLA, bat_priv,
+		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_add_claim(): changing ownership for %pM, vid %d\n",
 			   mac, vid);
=20
@@ -599,8 +599,8 @@ static void batadv_bla_del_claim(struct bat_priv *b=
at_priv, const uint8_t *mac,
 	if (!claim)
 		return;
=20
-	batadv_dbg(DBG_BLA, bat_priv, "bla_del_claim(): %pM, vid %d\n", mac,
-		   vid);
+	batadv_dbg(BATADV_DBG_BLA, bat_priv, "bla_del_claim(): %pM, vid %d\n"=
,
+		   mac, vid);
=20
 	batadv_hash_remove(bat_priv->claim_hash, batadv_compare_claim,
 			   batadv_choose_claim, claim);
@@ -633,12 +633,12 @@ static int batadv_handle_announce(struct bat_priv=
 *bat_priv,
 	backbone_gw->lasttime =3D jiffies;
 	crc =3D ntohs(*((__be16 *)(&an_addr[4])));
=20
-	batadv_dbg(DBG_BLA, bat_priv,
+	batadv_dbg(BATADV_DBG_BLA, bat_priv,
 		   "handle_announce(): ANNOUNCE vid %d (sent by %pM)... CRC =3D %04x=
\n",
 		   vid, backbone_gw->orig, crc);
=20
 	if (backbone_gw->crc !=3D crc) {
-		batadv_dbg(DBG_BLA, backbone_gw->bat_priv,
+		batadv_dbg(BATADV_DBG_BLA, backbone_gw->bat_priv,
 			   "handle_announce(): CRC FAILED for %pM/%d (my =3D %04x, sent =3D=
 %04x)\n",
 			   backbone_gw->orig, backbone_gw->vid,
 			   backbone_gw->crc, crc);
@@ -674,7 +674,7 @@ static int batadv_handle_request(struct bat_priv *b=
at_priv,
 	if (!batadv_compare_eth(ethhdr->h_dest, primary_if->net_dev->dev_addr=
))
 		return 1;
=20
-	batadv_dbg(DBG_BLA, bat_priv,
+	batadv_dbg(BATADV_DBG_BLA, bat_priv,
 		   "handle_request(): REQUEST vid %d (sent by %pM)...\n",
 		   vid, ethhdr->h_source);
=20
@@ -702,7 +702,7 @@ static int batadv_handle_unclaim(struct bat_priv *b=
at_priv,
 		return 1;
=20
 	/* this must be an UNCLAIM frame */
-	batadv_dbg(DBG_BLA, bat_priv,
+	batadv_dbg(BATADV_DBG_BLA, bat_priv,
 		   "handle_unclaim(): UNCLAIM %pM on vid %d (sent by %pM)...\n",
 		   claim_addr, vid, backbone_gw->orig);
=20
@@ -804,7 +804,7 @@ static int batadv_check_claim_group(struct bat_priv=
 *bat_priv,
=20
 	/* if our mesh friends mac is bigger, use it for ourselves. */
 	if (ntohs(bla_dst->group) > ntohs(bla_dst_own->group)) {
-		batadv_dbg(DBG_BLA, bat_priv,
+		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "taking other backbones claim group: %04x\n",
 			   ntohs(bla_dst->group));
 		bla_dst_own->group =3D bla_dst->group;
@@ -882,7 +882,7 @@ static int batadv_bla_process_claim(struct bat_priv=
 *bat_priv,
 	ret =3D batadv_check_claim_group(bat_priv, primary_if, hw_src, hw_dst=
,
 				       ethhdr);
 	if (ret =3D=3D 1)
-		batadv_dbg(DBG_BLA, bat_priv,
+		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_process_claim(): received a claim frame from another group.=
 From: %pM on vid %d ...(hw_src %pM, hw_dst %pM)\n",
 			   ethhdr->h_source, vid, hw_src, hw_dst);
=20
@@ -917,7 +917,7 @@ static int batadv_bla_process_claim(struct bat_priv=
 *bat_priv,
 		break;
 	}
=20
-	batadv_dbg(DBG_BLA, bat_priv,
+	batadv_dbg(BATADV_DBG_BLA, bat_priv,
 		   "bla_process_claim(): ERROR - this looks like a claim frame, but =
is useless. eth src %pM on vid %d ...(hw_src %pM, hw_dst %pM)\n",
 		   ethhdr->h_source, vid, hw_src, hw_dst);
 	return 1;
@@ -952,7 +952,7 @@ static void batadv_bla_purge_backbone_gw(struct bat=
_priv *bat_priv, int now)
 						  BATADV_BLA_BACKBONE_TIMEOUT))
 				continue;
=20
-			batadv_dbg(DBG_BLA, backbone_gw->bat_priv,
+			batadv_dbg(BATADV_DBG_BLA, backbone_gw->bat_priv,
 				   "bla_purge_backbone_gw(): backbone gw %pM timed out\n",
 				   backbone_gw->orig);
=20
@@ -1004,7 +1004,7 @@ static void batadv_bla_purge_claims(struct bat_pr=
iv *bat_priv,
 						  BATADV_BLA_CLAIM_TIMEOUT))
 				continue;
=20
-			batadv_dbg(DBG_BLA, bat_priv,
+			batadv_dbg(BATADV_DBG_BLA, bat_priv,
 				   "bla_purge_claims(): %pM, vid %d, time out\n",
 				   claim->addr, claim->vid);
=20
@@ -1146,7 +1146,7 @@ int batadv_bla_init(struct bat_priv *bat_priv)
 	uint8_t claim_dest[ETH_ALEN] =3D {0xff, 0x43, 0x05, 0x00, 0x00, 0x00}=
;
 	struct hard_iface *primary_if;
=20
-	batadv_dbg(DBG_BLA, bat_priv, "bla hash registering\n");
+	batadv_dbg(BATADV_DBG_BLA, bat_priv, "bla hash registering\n");
=20
 	/* setting claim destination address */
 	memcpy(&bat_priv->claim_dest.magic, claim_dest, 3);
@@ -1181,7 +1181,7 @@ int batadv_bla_init(struct bat_priv *bat_priv)
 	batadv_hash_set_lock_class(bat_priv->backbone_hash,
 				   &batadv_backbone_hash_lock_class_key);
=20
-	batadv_dbg(DBG_BLA, bat_priv, "bla hashes initialized\n");
+	batadv_dbg(BATADV_DBG_BLA, bat_priv, "bla hashes initialized\n");
=20
 	batadv_bla_start_timer(bat_priv);
 	return 0;
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_c=
lient.c
index 3b50c31..00273b9 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -218,21 +218,24 @@ void batadv_gw_election(struct bat_priv *bat_priv=
)
 	}
=20
 	if ((curr_gw) && (!next_gw)) {
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Removing selected gateway - no gateway in range\n");
-		batadv_throw_uevent(bat_priv, UEV_GW, UEV_DEL, NULL);
+		batadv_throw_uevent(bat_priv, BATADV_UEV_GW, BATADV_UEV_DEL,
+				    NULL);
 	} else if ((!curr_gw) && (next_gw)) {
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Adding route to gateway %pM (gw_flags: %i, tq: %i)\n",
 			   next_gw->orig_node->orig,
 			   next_gw->orig_node->gw_flags, router->tq_avg);
-		batadv_throw_uevent(bat_priv, UEV_GW, UEV_ADD, gw_addr);
+		batadv_throw_uevent(bat_priv, BATADV_UEV_GW, BATADV_UEV_ADD,
+				    gw_addr);
 	} else {
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Changing route to gateway %pM (gw_flags: %i, tq: %i)\n",
 			   next_gw->orig_node->orig,
 			   next_gw->orig_node->gw_flags, router->tq_avg);
-		batadv_throw_uevent(bat_priv, UEV_GW, UEV_CHANGE, gw_addr);
+		batadv_throw_uevent(bat_priv, BATADV_UEV_GW, BATADV_UEV_CHANGE,
+				    gw_addr);
 	}
=20
 	batadv_gw_select(bat_priv, next_gw);
@@ -283,7 +286,7 @@ void batadv_gw_check_election(struct bat_priv *bat_=
priv,
 	    (orig_tq_avg - gw_tq_avg < atomic_read(&bat_priv->gw_sel_class)))
 		goto out;
=20
-	batadv_dbg(DBG_BATMAN, bat_priv,
+	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 		   "Restarting gateway selection: better gateway found (tq curr: %i,=
 tq new: %i)\n",
 		   gw_tq_avg, orig_tq_avg);
=20
@@ -320,7 +323,7 @@ static void batadv_gw_node_add(struct bat_priv *bat=
_priv,
 	spin_unlock_bh(&bat_priv->gw_list_lock);
=20
 	batadv_gw_bandwidth_to_kbit(new_gwflags, &down, &up);
-	batadv_dbg(DBG_BATMAN, bat_priv,
+	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 		   "Found new gateway %pM -> gw_class: %i - %i%s/%i%s\n",
 		   orig_node->orig, new_gwflags,
 		   (down > 2048 ? down / 1024 : down),
@@ -347,7 +350,7 @@ void batadv_gw_node_update(struct bat_priv *bat_pri=
v,
 		if (gw_node->orig_node !=3D orig_node)
 			continue;
=20
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Gateway class of originator %pM changed from %i to %i\n",
 			   orig_node->orig, gw_node->orig_node->gw_flags,
 			   new_gwflags);
@@ -356,7 +359,7 @@ void batadv_gw_node_update(struct bat_priv *bat_pri=
v,
=20
 		if (new_gwflags =3D=3D BATADV_NO_FLAGS) {
 			gw_node->deleted =3D jiffies;
-			batadv_dbg(DBG_BATMAN, bat_priv,
+			batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 				   "Gateway %pM removed from gateway list\n",
 				   orig_node->orig);
=20
@@ -403,7 +406,7 @@ void batadv_gw_node_purge(struct bat_priv *bat_priv=
)
 				  &bat_priv->gw_list, list) {
 		if (((!gw_node->deleted) ||
 		     (time_before(jiffies, gw_node->deleted + timeout))) &&
-		    atomic_read(&bat_priv->mesh_state) =3D=3D MESH_ACTIVE)
+		    atomic_read(&bat_priv->mesh_state) =3D=3D BATADV_MESH_ACTIVE)
 			continue;
=20
 		if (curr_gw =3D=3D gw_node)
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.=
c
index a64cce2..61b52b3 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -158,7 +158,7 @@ static ssize_t batadv_socket_write(struct file *fil=
e, const char __user *buff,
 	size_t packet_len =3D sizeof(struct icmp_packet);
=20
 	if (len < sizeof(struct icmp_packet)) {
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Error - can't send packet from char device: invalid packet size=
\n");
 		return -EINVAL;
 	}
@@ -188,14 +188,14 @@ static ssize_t batadv_socket_write(struct file *f=
ile, const char __user *buff,
 	}
=20
 	if (icmp_packet->header.packet_type !=3D BATADV_ICMP) {
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Error - can't send packet from char device: got bogus packet ty=
pe (expected: BAT_ICMP)\n");
 		len =3D -EINVAL;
 		goto free_skb;
 	}
=20
 	if (icmp_packet->msg_type !=3D BATADV_ECHO_REQUEST) {
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Error - can't send packet from char device: got bogus message t=
ype (expected: ECHO_REQUEST)\n");
 		len =3D -EINVAL;
 		goto free_skb;
@@ -211,7 +211,7 @@ static ssize_t batadv_socket_write(struct file *fil=
e, const char __user *buff,
 		goto free_skb;
 	}
=20
-	if (atomic_read(&bat_priv->mesh_state) !=3D MESH_ACTIVE)
+	if (atomic_read(&bat_priv->mesh_state) !=3D BATADV_MESH_ACTIVE)
 		goto dst_unreach;
=20
 	orig_node =3D batadv_orig_hash_find(bat_priv, icmp_packet->dst);
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index b3f0a2e..24d651d 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -132,7 +132,7 @@ int batadv_mesh_init(struct net_device *soft_iface)
 		goto err;
=20
 	atomic_set(&bat_priv->gw_reselect, 0);
-	atomic_set(&bat_priv->mesh_state, MESH_ACTIVE);
+	atomic_set(&bat_priv->mesh_state, BATADV_MESH_ACTIVE);
=20
 	return 0;
=20
@@ -145,7 +145,7 @@ void batadv_mesh_free(struct net_device *soft_iface=
)
 {
 	struct bat_priv *bat_priv =3D netdev_priv(soft_iface);
=20
-	atomic_set(&bat_priv->mesh_state, MESH_DEACTIVATING);
+	atomic_set(&bat_priv->mesh_state, BATADV_MESH_DEACTIVATING);
=20
 	batadv_purge_outstanding_packets(bat_priv, NULL);
=20
@@ -160,7 +160,7 @@ void batadv_mesh_free(struct net_device *soft_iface=
)
=20
 	free_percpu(bat_priv->bat_counters);
=20
-	atomic_set(&bat_priv->mesh_state, MESH_INACTIVE);
+	atomic_set(&bat_priv->mesh_state, BATADV_MESH_INACTIVE);
 }
=20
 void batadv_inc_module_count(void)
@@ -230,7 +230,7 @@ int batadv_batman_skb_recv(struct sk_buff *skb, str=
uct net_device *dev,
=20
 	bat_priv =3D netdev_priv(hard_iface->soft_iface);
=20
-	if (atomic_read(&bat_priv->mesh_state) !=3D MESH_ACTIVE)
+	if (atomic_read(&bat_priv->mesh_state) !=3D BATADV_MESH_ACTIVE)
 		goto err_free;
=20
 	/* discard frames on not active interfaces */
@@ -240,7 +240,7 @@ int batadv_batman_skb_recv(struct sk_buff *skb, str=
uct net_device *dev,
 	batman_ogm_packet =3D (struct batman_ogm_packet *)skb->data;
=20
 	if (batman_ogm_packet->header.version !=3D BATADV_COMPAT_VERSION) {
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: incompatible batman version (%i)\n",
 			   batman_ogm_packet->header.version);
 		goto err_free;
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 09660b4..68e13ac 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -95,23 +95,23 @@
 #define BATADV_RESET_PROTECTION_MS 30000
 #define BATADV_EXPECTED_SEQNO_RANGE	65536
=20
-enum mesh_state {
-	MESH_INACTIVE,
-	MESH_ACTIVE,
-	MESH_DEACTIVATING
+enum batadv_mesh_state {
+	BATADV_MESH_INACTIVE,
+	BATADV_MESH_ACTIVE,
+	BATADV_MESH_DEACTIVATING,
 };
=20
 #define BATADV_BCAST_QUEUE_LEN		256
 #define BATADV_BATMAN_QUEUE_LEN	256
=20
-enum uev_action {
-	UEV_ADD =3D 0,
-	UEV_DEL,
-	UEV_CHANGE
+enum batadv_uev_action {
+	BATADV_UEV_ADD =3D 0,
+	BATADV_UEV_DEL,
+	BATADV_UEV_CHANGE,
 };
=20
-enum uev_type {
-	UEV_GW =3D 0
+enum batadv_uev_type {
+	BATADV_UEV_GW =3D 0,
 };
=20
 #define BATADV_GW_THRESHOLD	50
@@ -124,12 +124,12 @@ enum uev_type {
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
=20
 /* all messages related to routing / flooding / broadcasting / etc */
-enum dbg_level {
-	DBG_BATMAN =3D 1 << 0,
-	DBG_ROUTES =3D 1 << 1, /* route added / changed / deleted */
-	DBG_TT	   =3D 1 << 2, /* translation table operations */
-	DBG_BLA    =3D 1 << 3, /* bridge loop avoidance */
-	DBG_ALL    =3D 15
+enum batadv_dbg_level {
+	BATADV_DBG_BATMAN =3D 1 << 0,
+	BATADV_DBG_ROUTES =3D 1 << 1, /* route added / changed / deleted */
+	BATADV_DBG_TT	  =3D 1 << 2, /* translation table operations */
+	BATADV_DBG_BLA    =3D 1 << 3, /* bridge loop avoidance */
+	BATADV_DBG_ALL    =3D 15,
 };
=20
 /* Kernel headers */
@@ -195,14 +195,14 @@ static inline void batadv_dbg(int type __always_u=
nused,
 	do {								\
 		struct net_device *_netdev =3D (net_dev);                 \
 		struct bat_priv *_batpriv =3D netdev_priv(_netdev);       \
-		batadv_dbg(DBG_ALL, _batpriv, fmt, ## arg);		\
+		batadv_dbg(BATADV_DBG_ALL, _batpriv, fmt, ## arg);	\
 		pr_info("%s: " fmt, _netdev->name, ## arg);		\
 	} while (0)
 #define batadv_err(net_dev, fmt, arg...)				\
 	do {								\
 		struct net_device *_netdev =3D (net_dev);                 \
 		struct bat_priv *_batpriv =3D netdev_priv(_netdev);       \
-		batadv_dbg(DBG_ALL, _batpriv, fmt, ## arg);		\
+		batadv_dbg(BATADV_DBG_ALL, _batpriv, fmt, ## arg);	\
 		pr_err("%s: " fmt, _netdev->name, ## arg);		\
 	} while (0)
=20
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 9e60cc0..4ddea31 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -102,7 +102,7 @@ struct neigh_node *batadv_neigh_node_new(struct har=
d_iface *hard_iface,
 	/* extra reference for return */
 	atomic_set(&neigh_node->refcount, 2);
=20
-	batadv_dbg(DBG_BATMAN, bat_priv,
+	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 		   "Creating new neighbor %pM, initial seqno %d\n",
 		   neigh_addr, seqno);
=20
@@ -200,8 +200,8 @@ struct orig_node *batadv_get_orig_node(struct bat_p=
riv *bat_priv,
 	if (orig_node)
 		return orig_node;
=20
-	batadv_dbg(DBG_BATMAN, bat_priv, "Creating new originator: %pM\n",
-		   addr);
+	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+		   "Creating new originator: %pM\n", addr);
=20
 	orig_node =3D kzalloc(sizeof(*orig_node), GFP_ATOMIC);
 	if (!orig_node)
@@ -293,12 +293,12 @@ static bool batadv_purge_orig_neighbors(struct ba=
t_priv *bat_priv,
 			if ((if_incoming->if_status =3D=3D BATADV_IF_INACTIVE) ||
 			    (if_incoming->if_status =3D=3D BATADV_IF_NOT_IN_USE) ||
 			    (if_incoming->if_status =3D=3D BATADV_IF_TO_BE_REMOVED))
-				batadv_dbg(DBG_BATMAN, bat_priv,
+				batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 					   "neighbor purge: originator %pM, neighbor: %pM, iface: %s\n",
 					   orig_node->orig, neigh_node->addr,
 					   if_incoming->net_dev->name);
 			else
-				batadv_dbg(DBG_BATMAN, bat_priv,
+				batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 					   "neighbor timeout: originator %pM, neighbor: %pM, last_seen: %=
u\n",
 					   orig_node->orig, neigh_node->addr,
 					   jiffies_to_msecs(last_seen));
@@ -326,7 +326,7 @@ static bool batadv_purge_orig_node(struct bat_priv =
*bat_priv,
=20
 	if (batadv_has_timed_out(orig_node->last_seen,
 				 2 * BATADV_PURGE_TIMEOUT)) {
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Originator timeout: originator %pM, last_seen %u\n",
 			   orig_node->orig,
 			   jiffies_to_msecs(orig_node->last_seen));
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 8e43a95..b8c47dc 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -72,20 +72,20 @@ static void _batadv_update_route(struct bat_priv *b=
at_priv,
=20
 	/* route deleted */
 	if ((curr_router) && (!neigh_node)) {
-		batadv_dbg(DBG_ROUTES, bat_priv, "Deleting route towards: %pM\n",
-			   orig_node->orig);
+		batadv_dbg(BATADV_DBG_ROUTES, bat_priv,
+			   "Deleting route towards: %pM\n", orig_node->orig);
 		batadv_tt_global_del_orig(bat_priv, orig_node,
 					  "Deleted route towards originator");
=20
 	/* route added */
 	} else if ((!curr_router) && (neigh_node)) {
=20
-		batadv_dbg(DBG_ROUTES, bat_priv,
+		batadv_dbg(BATADV_DBG_ROUTES, bat_priv,
 			   "Adding route towards: %pM (via %pM)\n",
 			   orig_node->orig, neigh_node->addr);
 	/* route changed */
 	} else if (neigh_node && curr_router) {
-		batadv_dbg(DBG_ROUTES, bat_priv,
+		batadv_dbg(BATADV_DBG_ROUTES, bat_priv,
 			   "Changing route towards: %pM (now via %pM - was via %pM)\n",
 			   orig_node->orig, neigh_node->addr,
 			   curr_router->addr);
@@ -240,7 +240,7 @@ int batadv_window_protected(struct bat_priv *bat_pr=
iv, int32_t seq_num_diff,
 			return 1;
=20
 		*last_reset =3D jiffies;
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "old packet received, start protection\n");
 	}
=20
@@ -618,7 +618,7 @@ int batadv_recv_tt_query(struct sk_buff *skb, struc=
t hard_iface *recv_if)
 			else
 				tt_flag =3D '.';
=20
-			batadv_dbg(DBG_TT, bat_priv,
+			batadv_dbg(BATADV_DBG_TT, bat_priv,
 				   "Routing TT_REQUEST to %pM [%c]\n",
 				   tt_query->dst,
 				   tt_flag);
@@ -650,7 +650,7 @@ int batadv_recv_tt_query(struct sk_buff *skb, struc=
t hard_iface *recv_if)
 				tt_flag =3D  'F';
 			else
 				tt_flag =3D '.';
-			batadv_dbg(DBG_TT, bat_priv,
+			batadv_dbg(BATADV_DBG_TT, bat_priv,
 				   "Routing TT_RESPONSE to %pM [%c]\n",
 				   tt_query->dst,
 				   tt_flag);
@@ -703,7 +703,7 @@ int batadv_recv_roam_adv(struct sk_buff *skb, struc=
t hard_iface *recv_if)
 	if (!orig_node)
 		goto out;
=20
-	batadv_dbg(DBG_TT, bat_priv,
+	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Received ROAMING_ADV from %pM (client %pM)\n",
 		   roam_adv_packet->src, roam_adv_packet->client);
=20
@@ -992,7 +992,7 @@ static int batadv_check_unicast_ttvn(struct bat_pri=
v *bat_priv,
 			batadv_orig_node_free_ref(orig_node);
 		}
=20
-		batadv_dbg(DBG_ROUTES, bat_priv,
+		batadv_dbg(BATADV_DBG_ROUTES, bat_priv,
 			   "TTVN mismatch (old_ttvn %u new_ttvn %u)! Rerouting unicast pack=
et (for %pM) to %pM\n",
 			   unicast_packet->ttvn, curr_ttvn, ethhdr->h_dest,
 			   unicast_packet->dest);
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 8de6e25..aad9818 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -142,7 +142,8 @@ int batadv_add_bcast_packet_to_list(struct bat_priv=
 *bat_priv,
 	struct sk_buff *newskb;
=20
 	if (!batadv_atomic_dec_not_zero(&bat_priv->bcast_queue_left)) {
-		batadv_dbg(DBG_BATMAN, bat_priv, "bcast packet queue full\n");
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+			   "bcast packet queue full\n");
 		goto out;
 	}
=20
@@ -199,7 +200,7 @@ static void batadv_send_outstanding_bcast_packet(st=
ruct work_struct *work)
 	hlist_del(&forw_packet->list);
 	spin_unlock_bh(&bat_priv->forw_bcast_list_lock);
=20
-	if (atomic_read(&bat_priv->mesh_state) =3D=3D MESH_DEACTIVATING)
+	if (atomic_read(&bat_priv->mesh_state) =3D=3D BATADV_MESH_DEACTIVATIN=
G)
 		goto out;
=20
 	/* rebroadcast packet */
@@ -243,7 +244,7 @@ void batadv_send_outstanding_bat_ogm_packet(struct =
work_struct *work)
 	hlist_del(&forw_packet->list);
 	spin_unlock_bh(&bat_priv->forw_bat_list_lock);
=20
-	if (atomic_read(&bat_priv->mesh_state) =3D=3D MESH_DEACTIVATING)
+	if (atomic_read(&bat_priv->mesh_state) =3D=3D BATADV_MESH_DEACTIVATIN=
G)
 		goto out;
=20
 	bat_priv->bat_algo_ops->bat_ogm_emit(forw_packet);
@@ -271,11 +272,11 @@ void batadv_purge_outstanding_packets(struct bat_=
priv *bat_priv,
 	bool pending;
=20
 	if (hard_iface)
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "purge_outstanding_packets(): %s\n",
 			   hard_iface->net_dev->name);
 	else
-		batadv_dbg(DBG_BATMAN, bat_priv,
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "purge_outstanding_packets()\n");
=20
 	/* free bcast list */
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 3aae91d..0a00324 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -105,7 +105,7 @@ static int batadv_interface_set_mac_addr(struct net=
_device *dev, void *p)
 		return -EADDRNOTAVAIL;
=20
 	/* only modify transtable if it has been initialized before */
-	if (atomic_read(&bat_priv->mesh_state) =3D=3D MESH_ACTIVE) {
+	if (atomic_read(&bat_priv->mesh_state) =3D=3D BATADV_MESH_ACTIVE) {
 		batadv_tt_local_remove(bat_priv, dev->dev_addr,
 				       "mac address changed", false);
 		batadv_tt_local_add(dev, addr->sa_data, BATADV_NULL_IFINDEX);
@@ -143,7 +143,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	short vid __maybe_unused =3D -1;
 	bool do_bcast =3D false;
=20
-	if (atomic_read(&bat_priv->mesh_state) !=3D MESH_ACTIVE)
+	if (atomic_read(&bat_priv->mesh_state) !=3D BATADV_MESH_ACTIVE)
 		goto dropped;
=20
 	soft_iface->trans_start =3D jiffies;
@@ -398,7 +398,7 @@ struct net_device *batadv_softif_create(const char =
*name)
 	atomic_set(&bat_priv->bcast_queue_left, BATADV_BCAST_QUEUE_LEN);
 	atomic_set(&bat_priv->batman_queue_left, BATADV_BATMAN_QUEUE_LEN);
=20
-	atomic_set(&bat_priv->mesh_state, MESH_INACTIVE);
+	atomic_set(&bat_priv->mesh_state, BATADV_MESH_INACTIVE);
 	atomic_set(&bat_priv->bcast_seqno, 1);
 	atomic_set(&bat_priv->ttvn, 0);
 	atomic_set(&bat_priv->tt_local_changes, 0);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/transl=
ation-table.c
index 309d691..6d03cb1 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -252,7 +252,7 @@ void batadv_tt_local_add(struct net_device *soft_if=
ace, const uint8_t *addr,
 	if (!tt_local_entry)
 		goto out;
=20
-	batadv_dbg(DBG_TT, bat_priv,
+	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Creating new local tt entry: %pM (ttvn: %d)\n", addr,
 		   (uint8_t)atomic_read(&bat_priv->ttvn));
=20
@@ -484,7 +484,7 @@ static void batadv_tt_local_set_pending(struct bat_=
priv *bat_priv,
 	 */
 	tt_local_entry->common.flags |=3D BATADV_TT_CLIENT_PENDING;
=20
-	batadv_dbg(DBG_TT, bat_priv,
+	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Local tt entry (%pM) pending to be removed: %s\n",
 		   tt_local_entry->common.addr, message);
 }
@@ -726,7 +726,7 @@ int batadv_tt_global_add(struct bat_priv *bat_priv,=
 struct orig_node *orig_node,
 							orig_node, ttvn);
 	}
=20
-	batadv_dbg(DBG_TT, bat_priv,
+	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Creating new global tt entry: %pM (via %pM)\n",
 		   tt_global_entry->common.addr, orig_node->orig);
=20
@@ -856,7 +856,7 @@ batadv_tt_global_del_orig_entry(struct bat_priv *ba=
t_priv,
 	head =3D &tt_global_entry->orig_list;
 	hlist_for_each_entry_safe(orig_entry, node, safe, head, list) {
 		if (orig_entry->orig_node =3D=3D orig_node) {
-			batadv_dbg(DBG_TT, bat_priv,
+			batadv_dbg(BATADV_DBG_TT, bat_priv,
 				   "Deleting %pM from global tt entry %pM: %s\n",
 				   orig_node->orig,
 				   tt_global_entry->common.addr, message);
@@ -871,7 +871,8 @@ static void batadv_tt_global_del_struct(struct bat_=
priv *bat_priv,
 					struct tt_global_entry *tt_global_entry,
 					const char *message)
 {
-	batadv_dbg(DBG_TT, bat_priv, "Deleting global tt entry %pM: %s\n",
+	batadv_dbg(BATADV_DBG_TT, bat_priv,
+		   "Deleting global tt entry %pM: %s\n",
 		   tt_global_entry->common.addr, message);
=20
 	batadv_hash_remove(bat_priv->tt_global_hash, batadv_compare_tt,
@@ -1006,7 +1007,7 @@ void batadv_tt_global_del_orig(struct bat_priv *b=
at_priv,
 							orig_node, message);
=20
 			if (hlist_empty(&global_entry->orig_list)) {
-				batadv_dbg(DBG_TT, bat_priv,
+				batadv_dbg(BATADV_DBG_TT, bat_priv,
 					   "Deleting global tt entry %pM: %s\n",
 					   global_entry->common.addr, message);
 				hlist_del_rcu(node);
@@ -1035,7 +1036,7 @@ static void batadv_tt_global_roam_purge_list(stru=
ct bat_priv *bat_priv,
 					  BATADV_TT_CLIENT_ROAM_TIMEOUT))
 			continue;
=20
-		batadv_dbg(DBG_TT, bat_priv,
+		batadv_dbg(BATADV_DBG_TT, bat_priv,
 			   "Deleting global tt entry (%pM): Roaming timeout\n",
 			   tt_global_entry->common.addr);
=20
@@ -1471,7 +1472,7 @@ static int batadv_send_tt_request(struct bat_priv=
 *bat_priv,
 	if (!neigh_node)
 		goto out;
=20
-	batadv_dbg(DBG_TT, bat_priv,
+	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Sending TT_REQUEST to %pM via %pM [%c]\n",
 		   dst_orig_node->orig, neigh_node->addr,
 		   (full_table ? 'F' : '.'));
@@ -1511,7 +1512,7 @@ static bool batadv_send_other_tt_response(struct =
bat_priv *bat_priv,
 	struct sk_buff *skb =3D NULL;
 	struct tt_query_packet *tt_response;
=20
-	batadv_dbg(DBG_TT, bat_priv,
+	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Received TT_REQUEST from %pM for ttvn: %u (%pM) [%c]\n",
 		   tt_request->src, tt_request->ttvn, tt_request->dst,
 		   (tt_request->flags & BATADV_TT_FULL_TABLE ? 'F' : '.'));
@@ -1599,7 +1600,7 @@ static bool batadv_send_other_tt_response(struct =
bat_priv *bat_priv,
 	if (full_table)
 		tt_response->flags |=3D BATADV_TT_FULL_TABLE;
=20
-	batadv_dbg(DBG_TT, bat_priv,
+	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Sending TT_RESPONSE %pM via %pM for %pM (ttvn: %u)\n",
 		   res_dst_orig_node->orig, neigh_node->addr,
 		   req_dst_orig_node->orig, req_ttvn);
@@ -1641,7 +1642,7 @@ static bool batadv_send_my_tt_response(struct bat=
_priv *bat_priv,
 	struct sk_buff *skb =3D NULL;
 	struct tt_query_packet *tt_response;
=20
-	batadv_dbg(DBG_TT, bat_priv,
+	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Received TT_REQUEST from %pM for ttvn: %u (me) [%c]\n",
 		   tt_request->src, tt_request->ttvn,
 		   (tt_request->flags & BATADV_TT_FULL_TABLE ? 'F' : '.'));
@@ -1720,7 +1721,7 @@ static bool batadv_send_my_tt_response(struct bat=
_priv *bat_priv,
 	if (full_table)
 		tt_response->flags |=3D BATADV_TT_FULL_TABLE;
=20
-	batadv_dbg(DBG_TT, bat_priv,
+	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Sending TT_RESPONSE to %pM via %pM [%c]\n",
 		   orig_node->orig, neigh_node->addr,
 		   (tt_response->flags & BATADV_TT_FULL_TABLE ? 'F' : '.'));
@@ -1860,7 +1861,7 @@ void batadv_handle_tt_response(struct bat_priv *b=
at_priv,
 	struct tt_req_node *node, *safe;
 	struct orig_node *orig_node =3D NULL;
=20
-	batadv_dbg(DBG_TT, bat_priv,
+	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Received TT_RESPONSE from %pM for ttvn %d t_size: %d [%c]\n",
 		   tt_response->src, tt_response->ttvn,
 		   ntohs(tt_response->tt_data),
@@ -2039,7 +2040,7 @@ static void batadv_send_roam_adv(struct bat_priv =
*bat_priv, uint8_t *client,
 	if (!neigh_node)
 		goto out;
=20
-	batadv_dbg(DBG_TT, bat_priv,
+	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Sending ROAMING_ADV to %pM (client %pM) via %pM\n",
 		   orig_node->orig, client, neigh_node->addr);
=20
@@ -2146,7 +2147,7 @@ static void batadv_tt_local_purge_pending_clients=
(struct bat_priv *bat_priv)
 			if (!(tt_common->flags & BATADV_TT_CLIENT_PENDING))
 				continue;
=20
-			batadv_dbg(DBG_TT, bat_priv,
+			batadv_dbg(BATADV_DBG_TT, bat_priv,
 				   "Deleting local tt entry (%pM): pending\n",
 				   tt_common->addr);
=20
@@ -2181,7 +2182,7 @@ static int batadv_tt_commit_changes(struct bat_pr=
iv *bat_priv,
=20
 	/* Increment the TTVN only once per OGM interval */
 	atomic_inc(&bat_priv->ttvn);
-	batadv_dbg(DBG_TT, bat_priv,
+	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Local changes committed, updating to ttvn %u\n",
 		   (uint8_t)atomic_read(&bat_priv->ttvn));
 	bat_priv->tt_poss_change =3D false;
@@ -2306,7 +2307,7 @@ void batadv_tt_update_orig(struct bat_priv *bat_p=
riv,
 		if (!orig_node->tt_initialised || ttvn !=3D orig_ttvn ||
 		    orig_node->tt_crc !=3D tt_crc) {
 request_table:
-			batadv_dbg(DBG_TT, bat_priv,
+			batadv_dbg(BATADV_DBG_TT, bat_priv,
 				   "TT inconsistency for %pM. Need to retrieve the correct informa=
tion (ttvn: %u last_ttvn: %u crc: %u last_crc: %u num_changes: %u)\n",
 				   orig_node->orig, ttvn, orig_ttvn, tt_crc,
 				   orig_node->tt_crc, tt_num_changes);
--=20
1.7.9.4
