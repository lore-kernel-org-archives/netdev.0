From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 10/16] batman-adv: Prefix types structs with batadv_
Date: Mon,  2 Jul 2012 01:43:40 +0200
Message-ID: <1341186226-10549-11-git-send-email-ordex@autistici.org>
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
	with ESMTP id S1751705Ab2GAXnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 19:43:42 -0400
In-Reply-To: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sven Eckelmann <sven@narfation.org>

Reported-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_debugfs.c           |   27 +-
 net/batman-adv/bat_iv_ogm.c            |  125 ++++-----
 net/batman-adv/bat_sysfs.c             |   45 ++--
 net/batman-adv/bat_sysfs.h             |    2 +-
 net/batman-adv/bitarray.c              |    2 +-
 net/batman-adv/bridge_loop_avoidance.c |  188 +++++++-------
 net/batman-adv/bridge_loop_avoidance.h |   44 ++--
 net/batman-adv/gateway_client.c        |   90 ++++---
 net/batman-adv/gateway_client.h        |   24 +-
 net/batman-adv/gateway_common.c        |    2 +-
 net/batman-adv/hard-interface.c        |   71 ++---
 net/batman-adv/hard-interface.h        |   14 +-
 net/batman-adv/icmp_socket.c           |   41 +--
 net/batman-adv/icmp_socket.h           |    2 +-
 net/batman-adv/main.c                  |   40 +--
 net/batman-adv/main.h                  |   24 +-
 net/batman-adv/originator.c            |  102 ++++----
 net/batman-adv/originator.h            |   35 +--
 net/batman-adv/routing.c               |  144 ++++++-----
 net/batman-adv/routing.h               |   50 ++--
 net/batman-adv/send.c                  |   50 ++--
 net/batman-adv/send.h                  |   12 +-
 net/batman-adv/soft-interface.c        |   18 +-
 net/batman-adv/soft-interface.h        |    2 +-
 net/batman-adv/translation-table.c     |  446 +++++++++++++++++-------=
--------
 net/batman-adv/translation-table.h     |   39 +--
 net/batman-adv/types.h                 |  104 ++++----
 net/batman-adv/unicast.c               |   34 +--
 net/batman-adv/unicast.h               |    9 +-
 net/batman-adv/vis.c                   |  173 +++++++------
 net/batman-adv/vis.h                   |    8 +-
 31 files changed, 1029 insertions(+), 938 deletions(-)

diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.=
c
index bd618e4..db7b9bf 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -40,7 +40,7 @@ static struct dentry *batadv_debugfs;
=20
 static int batadv_log_buff_len =3D BATADV_LOG_BUF_LEN;
=20
-static void batadv_emit_log_char(struct debug_log *debug_log, char c)
+static void batadv_emit_log_char(struct batadv_debug_log *debug_log, c=
har c)
 {
 	BATADV_LOG_BUFF(debug_log->log_end) =3D c;
 	debug_log->log_end++;
@@ -50,7 +50,8 @@ static void batadv_emit_log_char(struct debug_log *de=
bug_log, char c)
 }
=20
 __printf(2, 3)
-static int batadv_fdebug_log(struct debug_log *debug_log, const char *=
fmt, ...)
+static int batadv_fdebug_log(struct batadv_debug_log *debug_log,
+			     const char *fmt, ...)
 {
 	va_list args;
 	static char debug_log_buf[256];
@@ -74,7 +75,7 @@ static int batadv_fdebug_log(struct debug_log *debug_=
log, const char *fmt, ...)
 	return 0;
 }
=20
-int batadv_debug_log(struct bat_priv *bat_priv, const char *fmt, ...)
+int batadv_debug_log(struct batadv_priv *bat_priv, const char *fmt, ..=
=2E)
 {
 	va_list args;
 	char tmp_log_buf[256];
@@ -105,8 +106,8 @@ static int batadv_log_release(struct inode *inode, =
struct file *file)
 static ssize_t batadv_log_read(struct file *file, char __user *buf,
 			       size_t count, loff_t *ppos)
 {
-	struct bat_priv *bat_priv =3D file->private_data;
-	struct debug_log *debug_log =3D bat_priv->debug_log;
+	struct batadv_priv *bat_priv =3D file->private_data;
+	struct batadv_debug_log *debug_log =3D bat_priv->debug_log;
 	int error, i =3D 0;
 	char c;
=20
@@ -158,8 +159,8 @@ static ssize_t batadv_log_read(struct file *file, c=
har __user *buf,
=20
 static unsigned int batadv_log_poll(struct file *file, poll_table *wai=
t)
 {
-	struct bat_priv *bat_priv =3D file->private_data;
-	struct debug_log *debug_log =3D bat_priv->debug_log;
+	struct batadv_priv *bat_priv =3D file->private_data;
+	struct batadv_debug_log *debug_log =3D bat_priv->debug_log;
=20
 	poll_wait(file, &debug_log->queue_wait, wait);
=20
@@ -177,7 +178,7 @@ static const struct file_operations batadv_log_fops=
 =3D {
 	.llseek         =3D no_llseek,
 };
=20
-static int batadv_debug_log_setup(struct bat_priv *bat_priv)
+static int batadv_debug_log_setup(struct batadv_priv *bat_priv)
 {
 	struct dentry *d;
=20
@@ -203,19 +204,19 @@ err:
 	return -ENOMEM;
 }
=20
-static void batadv_debug_log_cleanup(struct bat_priv *bat_priv)
+static void batadv_debug_log_cleanup(struct batadv_priv *bat_priv)
 {
 	kfree(bat_priv->debug_log);
 	bat_priv->debug_log =3D NULL;
 }
 #else /* CONFIG_BATMAN_ADV_DEBUG */
-static int batadv_debug_log_setup(struct bat_priv *bat_priv)
+static int batadv_debug_log_setup(struct batadv_priv *bat_priv)
 {
 	bat_priv->debug_log =3D NULL;
 	return 0;
 }
=20
-static void batadv_debug_log_cleanup(struct bat_priv *bat_priv)
+static void batadv_debug_log_cleanup(struct batadv_priv *bat_priv)
 {
 	return;
 }
@@ -339,7 +340,7 @@ void batadv_debugfs_destroy(void)
=20
 int batadv_debugfs_add_meshif(struct net_device *dev)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(dev);
+	struct batadv_priv *bat_priv =3D netdev_priv(dev);
 	struct batadv_debuginfo **bat_debug;
 	struct dentry *file;
=20
@@ -382,7 +383,7 @@ out:
=20
 void batadv_debugfs_del_meshif(struct net_device *dev)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(dev);
+	struct batadv_priv *bat_priv =3D netdev_priv(dev);
=20
 	batadv_debug_log_cleanup(bat_priv);
=20
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index a2bafd9..e877af8 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -28,13 +28,13 @@
 #include "send.h"
 #include "bat_algo.h"
=20
-static struct neigh_node *batadv_iv_ogm_neigh_new(struct hard_iface *h=
ard_iface,
-						  const uint8_t *neigh_addr,
-						  struct orig_node *orig_node,
-						  struct orig_node *orig_neigh,
-						  __be32 seqno)
+static struct batadv_neigh_node *
+batadv_iv_ogm_neigh_new(struct batadv_hard_iface *hard_iface,
+			const uint8_t *neigh_addr,
+			struct batadv_orig_node *orig_node,
+			struct batadv_orig_node *orig_neigh, __be32 seqno)
 {
-	struct neigh_node *neigh_node;
+	struct batadv_neigh_node *neigh_node;
=20
 	neigh_node =3D batadv_neigh_node_new(hard_iface, neigh_addr,
 					   ntohl(seqno));
@@ -54,7 +54,7 @@ out:
 	return neigh_node;
 }
=20
-static int batadv_iv_ogm_iface_enable(struct hard_iface *hard_iface)
+static int batadv_iv_ogm_iface_enable(struct batadv_hard_iface *hard_i=
face)
 {
 	struct batadv_ogm_packet *batadv_ogm_packet;
 	uint32_t random_seqno;
@@ -85,13 +85,13 @@ out:
 	return res;
 }
=20
-static void batadv_iv_ogm_iface_disable(struct hard_iface *hard_iface)
+static void batadv_iv_ogm_iface_disable(struct batadv_hard_iface *hard=
_iface)
 {
 	kfree(hard_iface->packet_buff);
 	hard_iface->packet_buff =3D NULL;
 }
=20
-static void batadv_iv_ogm_iface_update_mac(struct hard_iface *hard_ifa=
ce)
+static void batadv_iv_ogm_iface_update_mac(struct batadv_hard_iface *h=
ard_iface)
 {
 	struct batadv_ogm_packet *batadv_ogm_packet;
=20
@@ -102,7 +102,8 @@ static void batadv_iv_ogm_iface_update_mac(struct h=
ard_iface *hard_iface)
 	       hard_iface->net_dev->dev_addr, ETH_ALEN);
 }
=20
-static void batadv_iv_ogm_primary_iface_set(struct hard_iface *hard_if=
ace)
+static void
+batadv_iv_ogm_primary_iface_set(struct batadv_hard_iface *hard_iface)
 {
 	struct batadv_ogm_packet *batadv_ogm_packet;
=20
@@ -113,7 +114,7 @@ static void batadv_iv_ogm_primary_iface_set(struct =
hard_iface *hard_iface)
=20
 /* when do we schedule our own ogm to be sent */
 static unsigned long
-batadv_iv_ogm_emit_send_time(const struct bat_priv *bat_priv)
+batadv_iv_ogm_emit_send_time(const struct batadv_priv *bat_priv)
 {
 	unsigned int msecs;
=20
@@ -130,7 +131,8 @@ static unsigned long batadv_iv_ogm_fwd_send_time(vo=
id)
 }
=20
 /* apply hop penalty for a normal link */
-static uint8_t batadv_hop_penalty(uint8_t tq, const struct bat_priv *b=
at_priv)
+static uint8_t batadv_hop_penalty(uint8_t tq,
+				  const struct batadv_priv *bat_priv)
 {
 	int hop_penalty =3D atomic_read(&bat_priv->hop_penalty);
 	int new_tq;
@@ -155,10 +157,10 @@ static int batadv_iv_ogm_aggr_packet(int buff_pos=
, int packet_len,
 }
=20
 /* send a batman ogm to a given interface */
-static void batadv_iv_ogm_send_to_if(struct forw_packet *forw_packet,
-				  struct hard_iface *hard_iface)
+static void batadv_iv_ogm_send_to_if(struct batadv_forw_packet *forw_p=
acket,
+				     struct batadv_hard_iface *hard_iface)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
+	struct batadv_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
 	char *fwd_str;
 	uint8_t packet_num;
 	int16_t buff_pos;
@@ -217,12 +219,12 @@ static void batadv_iv_ogm_send_to_if(struct forw_=
packet *forw_packet,
 }
=20
 /* send a batman ogm packet */
-static void batadv_iv_ogm_emit(struct forw_packet *forw_packet)
+static void batadv_iv_ogm_emit(struct batadv_forw_packet *forw_packet)
 {
-	struct hard_iface *hard_iface;
+	struct batadv_hard_iface *hard_iface;
 	struct net_device *soft_iface;
-	struct bat_priv *bat_priv;
-	struct hard_iface *primary_if =3D NULL;
+	struct batadv_priv *bat_priv;
+	struct batadv_hard_iface *primary_if =3D NULL;
 	struct batadv_ogm_packet *batadv_ogm_packet;
 	unsigned char directlink;
=20
@@ -288,15 +290,15 @@ out:
 /* return true if new_packet can be aggregated with forw_packet */
 static bool
 batadv_iv_ogm_can_aggregate(const struct batadv_ogm_packet *new_bat_og=
m_packet,
-			    struct bat_priv *bat_priv,
+			    struct batadv_priv *bat_priv,
 			    int packet_len, unsigned long send_time,
 			    bool directlink,
-			    const struct hard_iface *if_incoming,
-			    const struct forw_packet *forw_packet)
+			    const struct batadv_hard_iface *if_incoming,
+			    const struct batadv_forw_packet *forw_packet)
 {
 	struct batadv_ogm_packet *batadv_ogm_packet;
 	int aggregated_bytes =3D forw_packet->packet_len + packet_len;
-	struct hard_iface *primary_if =3D NULL;
+	struct batadv_hard_iface *primary_if =3D NULL;
 	bool res =3D false;
 	unsigned long aggregation_end_time;
=20
@@ -371,11 +373,11 @@ out:
 static void batadv_iv_ogm_aggregate_new(const unsigned char *packet_bu=
ff,
 					int packet_len, unsigned long send_time,
 					bool direct_link,
-					struct hard_iface *if_incoming,
+					struct batadv_hard_iface *if_incoming,
 					int own_packet)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface);
-	struct forw_packet *forw_packet_aggr;
+	struct batadv_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface)=
;
+	struct batadv_forw_packet *forw_packet_aggr;
 	unsigned char *skb_buff;
 	unsigned int skb_size;
=20
@@ -447,7 +449,7 @@ out:
 }
=20
 /* aggregate a new packet into the existing ogm packet */
-static void batadv_iv_ogm_aggregate(struct forw_packet *forw_packet_ag=
gr,
+static void batadv_iv_ogm_aggregate(struct batadv_forw_packet *forw_pa=
cket_aggr,
 				    const unsigned char *packet_buff,
 				    int packet_len, bool direct_link)
 {
@@ -464,16 +466,17 @@ static void batadv_iv_ogm_aggregate(struct forw_p=
acket *forw_packet_aggr,
 			(1 << forw_packet_aggr->num_packets);
 }
=20
-static void batadv_iv_ogm_queue_add(struct bat_priv *bat_priv,
+static void batadv_iv_ogm_queue_add(struct batadv_priv *bat_priv,
 				    unsigned char *packet_buff,
 				    int packet_len,
-				    struct hard_iface *if_incoming,
+				    struct batadv_hard_iface *if_incoming,
 				    int own_packet, unsigned long send_time)
 {
 	/* _aggr -> pointer to the packet we want to aggregate with
 	 * _pos -> pointer to the position in the queue
 	 */
-	struct forw_packet *forw_packet_aggr =3D NULL, *forw_packet_pos =3D N=
ULL;
+	struct batadv_forw_packet *forw_packet_aggr =3D NULL;
+	struct batadv_forw_packet *forw_packet_pos =3D NULL;
 	struct hlist_node *tmp_node;
 	struct batadv_ogm_packet *batadv_ogm_packet;
 	bool direct_link;
@@ -524,14 +527,14 @@ static void batadv_iv_ogm_queue_add(struct bat_pr=
iv *bat_priv,
 	}
 }
=20
-static void batadv_iv_ogm_forward(struct orig_node *orig_node,
+static void batadv_iv_ogm_forward(struct batadv_orig_node *orig_node,
 				  const struct ethhdr *ethhdr,
 				  struct batadv_ogm_packet *batadv_ogm_packet,
 				  bool is_single_hop_neigh,
 				  bool is_from_best_next_hop,
-				  struct hard_iface *if_incoming)
+				  struct batadv_hard_iface *if_incoming)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface);
+	struct batadv_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface)=
;
 	uint8_t tt_num_changes;
=20
 	if (batadv_ogm_packet->header.ttl <=3D 1) {
@@ -577,11 +580,11 @@ static void batadv_iv_ogm_forward(struct orig_nod=
e *orig_node,
 				if_incoming, 0, batadv_iv_ogm_fwd_send_time());
 }
=20
-static void batadv_iv_ogm_schedule(struct hard_iface *hard_iface)
+static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_ifac=
e)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
+	struct batadv_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
 	struct batadv_ogm_packet *batadv_ogm_packet;
-	struct hard_iface *primary_if;
+	struct batadv_hard_iface *primary_if;
 	int vis_server, tt_num_changes =3D 0;
=20
 	vis_server =3D atomic_read(&bat_priv->vis_mode);
@@ -627,17 +630,17 @@ static void batadv_iv_ogm_schedule(struct hard_if=
ace *hard_iface)
 }
=20
 static void
-batadv_iv_ogm_orig_update(struct bat_priv *bat_priv,
-			  struct orig_node *orig_node,
+batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
+			  struct batadv_orig_node *orig_node,
 			  const struct ethhdr *ethhdr,
 			  const struct batadv_ogm_packet *batadv_ogm_packet,
-			  struct hard_iface *if_incoming,
+			  struct batadv_hard_iface *if_incoming,
 			  const unsigned char *tt_buff,
 			  int is_duplicate)
 {
-	struct neigh_node *neigh_node =3D NULL, *tmp_neigh_node =3D NULL;
-	struct neigh_node *router =3D NULL;
-	struct orig_node *orig_node_tmp;
+	struct batadv_neigh_node *neigh_node =3D NULL, *tmp_neigh_node =3D NU=
LL;
+	struct batadv_neigh_node *router =3D NULL;
+	struct batadv_orig_node *orig_node_tmp;
 	struct hlist_node *node;
 	uint8_t bcast_own_sum_orig, bcast_own_sum_neigh;
 	uint8_t *neigh_addr;
@@ -670,7 +673,7 @@ batadv_iv_ogm_orig_update(struct bat_priv *bat_priv=
,
 	}
=20
 	if (!neigh_node) {
-		struct orig_node *orig_tmp;
+		struct batadv_orig_node *orig_tmp;
=20
 		orig_tmp =3D batadv_get_orig_node(bat_priv, ethhdr->h_source);
 		if (!orig_tmp)
@@ -775,13 +778,13 @@ out:
 		batadv_neigh_node_free_ref(router);
 }
=20
-static int batadv_iv_ogm_calc_tq(struct orig_node *orig_node,
-				 struct orig_node *orig_neigh_node,
+static int batadv_iv_ogm_calc_tq(struct batadv_orig_node *orig_node,
+				 struct batadv_orig_node *orig_neigh_node,
 				 struct batadv_ogm_packet *batadv_ogm_packet,
-				 struct hard_iface *if_incoming)
+				 struct batadv_hard_iface *if_incoming)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface);
-	struct neigh_node *neigh_node =3D NULL, *tmp_neigh_node;
+	struct batadv_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface)=
;
+	struct batadv_neigh_node *neigh_node =3D NULL, *tmp_neigh_node;
 	struct hlist_node *node;
 	uint8_t total_count;
 	uint8_t orig_eq_count, neigh_rq_count, neigh_rq_inv, tq_own;
@@ -895,11 +898,11 @@ out:
 static int
 batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 			    const struct batadv_ogm_packet *batadv_ogm_packet,
-			    const struct hard_iface *if_incoming)
+			    const struct batadv_hard_iface *if_incoming)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface);
-	struct orig_node *orig_node;
-	struct neigh_node *tmp_neigh_node;
+	struct batadv_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface)=
;
+	struct batadv_orig_node *orig_node;
+	struct batadv_neigh_node *tmp_neigh_node;
 	struct hlist_node *node;
 	int is_duplicate =3D 0;
 	int32_t seq_diff;
@@ -965,13 +968,13 @@ out:
 static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 				  struct batadv_ogm_packet *batadv_ogm_packet,
 				  const unsigned char *tt_buff,
-				  struct hard_iface *if_incoming)
+				  struct batadv_hard_iface *if_incoming)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface);
-	struct hard_iface *hard_iface;
-	struct orig_node *orig_neigh_node, *orig_node;
-	struct neigh_node *router =3D NULL, *router_router =3D NULL;
-	struct neigh_node *orig_neigh_router =3D NULL;
+	struct batadv_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface)=
;
+	struct batadv_hard_iface *hard_iface;
+	struct batadv_orig_node *orig_neigh_node, *orig_node;
+	struct batadv_neigh_node *router =3D NULL, *router_router =3D NULL;
+	struct batadv_neigh_node *orig_neigh_router =3D NULL;
 	int has_directlink_flag;
 	int is_my_addr =3D 0, is_my_orig =3D 0, is_my_oldorig =3D 0;
 	int is_broadcast =3D 0, is_bidirect;
@@ -1240,9 +1243,9 @@ out:
 }
=20
 static int batadv_iv_ogm_receive(struct sk_buff *skb,
-				 struct hard_iface *if_incoming)
+				 struct batadv_hard_iface *if_incoming)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface);
+	struct batadv_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface)=
;
 	struct batadv_ogm_packet *batadv_ogm_packet;
 	struct ethhdr *ethhdr;
 	int buff_pos =3D 0, packet_len;
@@ -1287,7 +1290,7 @@ static int batadv_iv_ogm_receive(struct sk_buff *=
skb,
 	return NET_RX_SUCCESS;
 }
=20
-static struct bat_algo_ops batadv_batman_iv __read_mostly =3D {
+static struct batadv_algo_ops batadv_batman_iv __read_mostly =3D {
 	.name =3D "BATMAN_IV",
 	.bat_iface_enable =3D batadv_iv_ogm_iface_enable,
 	.bat_iface_disable =3D batadv_iv_ogm_iface_disable,
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index eb17629..a0a9ea4 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -32,7 +32,7 @@ static struct net_device *batadv_kobj_to_netdev(struc=
t kobject *obj)
 	return to_net_dev(dev);
 }
=20
-static struct bat_priv *batadv_kobj_to_batpriv(struct kobject *obj)
+static struct batadv_priv *batadv_kobj_to_batpriv(struct kobject *obj)
 {
 	struct net_device *net_dev =3D batadv_kobj_to_netdev(obj);
 	return netdev_priv(net_dev);
@@ -67,7 +67,7 @@ ssize_t batadv_store_##_name(struct kobject *kobj,			=
\
 			     size_t count)				\
 {									\
 	struct net_device *net_dev =3D batadv_kobj_to_netdev(kobj);	\
-	struct bat_priv *bat_priv =3D netdev_priv(net_dev);		\
+	struct batadv_priv *bat_priv =3D netdev_priv(net_dev);		\
 	return __batadv_store_bool_attr(buff, count, _post_func, attr,	\
 					&bat_priv->_name, net_dev);	\
 }
@@ -76,7 +76,7 @@ ssize_t batadv_store_##_name(struct kobject *kobj,			=
\
 ssize_t batadv_show_##_name(struct kobject *kobj,			\
 			    struct attribute *attr, char *buff)		\
 {									\
-	struct bat_priv *bat_priv =3D batadv_kobj_to_batpriv(kobj);	\
+	struct batadv_priv *bat_priv =3D batadv_kobj_to_batpriv(kobj);	\
 	return sprintf(buff, "%s\n",					\
 		       atomic_read(&bat_priv->_name) =3D=3D 0 ?		\
 		       "disabled" : "enabled");				\
@@ -98,7 +98,7 @@ ssize_t batadv_store_##_name(struct kobject *kobj,			=
\
 			     size_t count)				\
 {									\
 	struct net_device *net_dev =3D batadv_kobj_to_netdev(kobj);	\
-	struct bat_priv *bat_priv =3D netdev_priv(net_dev);		\
+	struct batadv_priv *bat_priv =3D netdev_priv(net_dev);		\
 	return __batadv_store_uint_attr(buff, count, _min, _max,	\
 					_post_func, attr,		\
 					&bat_priv->_name, net_dev);	\
@@ -108,7 +108,7 @@ ssize_t batadv_store_##_name(struct kobject *kobj,	=
		\
 ssize_t batadv_show_##_name(struct kobject *kobj,			\
 			    struct attribute *attr, char *buff)		\
 {									\
-	struct bat_priv *bat_priv =3D batadv_kobj_to_batpriv(kobj);	\
+	struct batadv_priv *bat_priv =3D batadv_kobj_to_batpriv(kobj);	\
 	return sprintf(buff, "%i\n", atomic_read(&bat_priv->_name));	\
 }									\
=20
@@ -128,7 +128,7 @@ ssize_t batadv_store_##_name(struct kobject *kobj,	=
		\
 			     size_t count)				\
 {									\
 	struct net_device *net_dev =3D batadv_kobj_to_netdev(kobj);	\
-	struct hard_iface *hard_iface;					\
+	struct batadv_hard_iface *hard_iface;				\
 	ssize_t length;							\
 									\
 	hard_iface =3D batadv_hardif_get_by_netdev(net_dev);		\
@@ -148,7 +148,7 @@ ssize_t batadv_show_##_name(struct kobject *kobj,		=
	\
 			    struct attribute *attr, char *buff)		\
 {									\
 	struct net_device *net_dev =3D batadv_kobj_to_netdev(kobj);	\
-	struct hard_iface *hard_iface;					\
+	struct batadv_hard_iface *hard_iface;				\
 	ssize_t length;							\
 									\
 	hard_iface =3D batadv_hardif_get_by_netdev(net_dev);		\
@@ -281,7 +281,7 @@ __batadv_store_uint_attr(const char *buff, size_t c=
ount,
 static ssize_t batadv_show_vis_mode(struct kobject *kobj,
 				    struct attribute *attr, char *buff)
 {
-	struct bat_priv *bat_priv =3D batadv_kobj_to_batpriv(kobj);
+	struct batadv_priv *bat_priv =3D batadv_kobj_to_batpriv(kobj);
 	int vis_mode =3D atomic_read(&bat_priv->vis_mode);
 	const char *mode;
=20
@@ -298,7 +298,7 @@ static ssize_t batadv_store_vis_mode(struct kobject=
 *kobj,
 				     size_t count)
 {
 	struct net_device *net_dev =3D batadv_kobj_to_netdev(kobj);
-	struct bat_priv *bat_priv =3D netdev_priv(net_dev);
+	struct batadv_priv *bat_priv =3D netdev_priv(net_dev);
 	unsigned long val;
 	int ret, vis_mode_tmp =3D -1;
 	const char *old_mode, *new_mode;
@@ -349,20 +349,20 @@ static ssize_t batadv_store_vis_mode(struct kobje=
ct *kobj,
 static ssize_t batadv_show_bat_algo(struct kobject *kobj,
 				    struct attribute *attr, char *buff)
 {
-	struct bat_priv *bat_priv =3D batadv_kobj_to_batpriv(kobj);
+	struct batadv_priv *bat_priv =3D batadv_kobj_to_batpriv(kobj);
 	return sprintf(buff, "%s\n", bat_priv->bat_algo_ops->name);
 }
=20
 static void batadv_post_gw_deselect(struct net_device *net_dev)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(net_dev);
+	struct batadv_priv *bat_priv =3D netdev_priv(net_dev);
 	batadv_gw_deselect(bat_priv);
 }
=20
 static ssize_t batadv_show_gw_mode(struct kobject *kobj, struct attrib=
ute *attr,
 				   char *buff)
 {
-	struct bat_priv *bat_priv =3D batadv_kobj_to_batpriv(kobj);
+	struct batadv_priv *bat_priv =3D batadv_kobj_to_batpriv(kobj);
 	int bytes_written;
=20
 	switch (atomic_read(&bat_priv->gw_mode)) {
@@ -388,7 +388,7 @@ static ssize_t batadv_store_gw_mode(struct kobject =
*kobj,
 				    size_t count)
 {
 	struct net_device *net_dev =3D batadv_kobj_to_netdev(kobj);
-	struct bat_priv *bat_priv =3D netdev_priv(net_dev);
+	struct batadv_priv *bat_priv =3D netdev_priv(net_dev);
 	char *curr_gw_mode_str;
 	int gw_mode_tmp =3D -1;
=20
@@ -440,7 +440,7 @@ static ssize_t batadv_store_gw_mode(struct kobject =
*kobj,
 static ssize_t batadv_show_gw_bwidth(struct kobject *kobj,
 				     struct attribute *attr, char *buff)
 {
-	struct bat_priv *bat_priv =3D batadv_kobj_to_batpriv(kobj);
+	struct batadv_priv *bat_priv =3D batadv_kobj_to_batpriv(kobj);
 	int down, up;
 	int gw_bandwidth =3D atomic_read(&bat_priv->gw_bandwidth);
=20
@@ -512,7 +512,7 @@ static struct batadv_attribute *batadv_mesh_attrs[]=
 =3D {
 int batadv_sysfs_add_meshif(struct net_device *dev)
 {
 	struct kobject *batif_kobject =3D &dev->dev.kobj;
-	struct bat_priv *bat_priv =3D netdev_priv(dev);
+	struct batadv_priv *bat_priv =3D netdev_priv(dev);
 	struct batadv_attribute **bat_attr;
 	int err;
=20
@@ -549,7 +549,7 @@ out:
=20
 void batadv_sysfs_del_meshif(struct net_device *dev)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(dev);
+	struct batadv_priv *bat_priv =3D netdev_priv(dev);
 	struct batadv_attribute **bat_attr;
=20
 	for (bat_attr =3D batadv_mesh_attrs; *bat_attr; ++bat_attr)
@@ -563,10 +563,11 @@ static ssize_t batadv_show_mesh_iface(struct kobj=
ect *kobj,
 				      struct attribute *attr, char *buff)
 {
 	struct net_device *net_dev =3D batadv_kobj_to_netdev(kobj);
-	struct hard_iface *hard_iface =3D batadv_hardif_get_by_netdev(net_dev=
);
+	struct batadv_hard_iface *hard_iface;
 	ssize_t length;
 	const char *ifname;
=20
+	hard_iface =3D batadv_hardif_get_by_netdev(net_dev);
 	if (!hard_iface)
 		return 0;
=20
@@ -587,10 +588,11 @@ static ssize_t batadv_store_mesh_iface(struct kob=
ject *kobj,
 				       size_t count)
 {
 	struct net_device *net_dev =3D batadv_kobj_to_netdev(kobj);
-	struct hard_iface *hard_iface =3D batadv_hardif_get_by_netdev(net_dev=
);
+	struct batadv_hard_iface *hard_iface;
 	int status_tmp =3D -1;
 	int ret =3D count;
=20
+	hard_iface =3D batadv_hardif_get_by_netdev(net_dev);
 	if (!hard_iface)
 		return count;
=20
@@ -643,9 +645,10 @@ static ssize_t batadv_show_iface_status(struct kob=
ject *kobj,
 					struct attribute *attr, char *buff)
 {
 	struct net_device *net_dev =3D batadv_kobj_to_netdev(kobj);
-	struct hard_iface *hard_iface =3D batadv_hardif_get_by_netdev(net_dev=
);
+	struct batadv_hard_iface *hard_iface;
 	ssize_t length;
=20
+	hard_iface =3D batadv_hardif_get_by_netdev(net_dev);
 	if (!hard_iface)
 		return 0;
=20
@@ -723,11 +726,11 @@ void batadv_sysfs_del_hardif(struct kobject **har=
dif_obj)
 	*hardif_obj =3D NULL;
 }
=20
-int batadv_throw_uevent(struct bat_priv *bat_priv, enum batadv_uev_typ=
e type,
+int batadv_throw_uevent(struct batadv_priv *bat_priv, enum batadv_uev_=
type type,
 			enum batadv_uev_action action, const char *data)
 {
 	int ret =3D -ENOMEM;
-	struct hard_iface *primary_if =3D NULL;
+	struct batadv_hard_iface *primary_if =3D NULL;
 	struct kobject *bat_kobj;
 	char *uevent_env[4] =3D { NULL, NULL, NULL, NULL };
=20
diff --git a/net/batman-adv/bat_sysfs.h b/net/batman-adv/bat_sysfs.h
index 88f95f8..3fd1412 100644
--- a/net/batman-adv/bat_sysfs.h
+++ b/net/batman-adv/bat_sysfs.h
@@ -36,7 +36,7 @@ void batadv_sysfs_del_meshif(struct net_device *dev);
 int batadv_sysfs_add_hardif(struct kobject **hardif_obj,
 			    struct net_device *dev);
 void batadv_sysfs_del_hardif(struct kobject **hardif_obj);
-int batadv_throw_uevent(struct bat_priv *bat_priv, enum batadv_uev_typ=
e type,
+int batadv_throw_uevent(struct batadv_priv *bat_priv, enum batadv_uev_=
type type,
 			enum batadv_uev_action action, const char *data);
=20
 #endif /* _NET_BATMAN_ADV_SYSFS_H_ */
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index 835d3b6..aea174c 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -41,7 +41,7 @@ static void batadv_bitmap_shift_left(unsigned long *s=
eq_bits, int32_t n)
 int batadv_bit_get_packet(void *priv, unsigned long *seq_bits,
 			  int32_t seq_num_diff, int set_mark)
 {
-	struct bat_priv *bat_priv =3D priv;
+	struct batadv_priv *bat_priv =3D priv;
=20
 	/* sequence number is slightly older. We already got a sequence numbe=
r
 	 * higher than this one, so we just mark it.
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/br=
idge_loop_avoidance.c
index fdda2c8..49e10d9 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -34,8 +34,8 @@
 static const uint8_t batadv_announce_mac[4] =3D {0x43, 0x05, 0x43, 0x0=
5};
=20
 static void batadv_bla_periodic_work(struct work_struct *work);
-static void batadv_bla_send_announce(struct bat_priv *bat_priv,
-				     struct backbone_gw *backbone_gw);
+static void batadv_bla_send_announce(struct batadv_priv *bat_priv,
+				     struct batadv_backbone_gw *backbone_gw);
=20
 /* return the index of the claim */
 static inline uint32_t batadv_choose_claim(const void *data, uint32_t =
size)
@@ -83,7 +83,7 @@ static inline uint32_t batadv_choose_backbone_gw(cons=
t void *data,
 static int batadv_compare_backbone_gw(const struct hlist_node *node,
 				      const void *data2)
 {
-	const void *data1 =3D container_of(node, struct backbone_gw,
+	const void *data1 =3D container_of(node, struct batadv_backbone_gw,
 					 hash_entry);
=20
 	return (memcmp(data1, data2, ETH_ALEN + sizeof(short)) =3D=3D 0 ? 1 :=
 0);
@@ -93,14 +93,14 @@ static int batadv_compare_backbone_gw(const struct =
hlist_node *node,
 static int batadv_compare_claim(const struct hlist_node *node,
 				const void *data2)
 {
-	const void *data1 =3D container_of(node, struct claim,
+	const void *data1 =3D container_of(node, struct batadv_claim,
 					 hash_entry);
=20
 	return (memcmp(data1, data2, ETH_ALEN + sizeof(short)) =3D=3D 0 ? 1 :=
 0);
 }
=20
 /* free a backbone gw */
-static void batadv_backbone_gw_free_ref(struct backbone_gw *backbone_g=
w)
+static void batadv_backbone_gw_free_ref(struct batadv_backbone_gw *bac=
kbone_gw)
 {
 	if (atomic_dec_and_test(&backbone_gw->refcount))
 		kfree_rcu(backbone_gw, rcu);
@@ -109,16 +109,16 @@ static void batadv_backbone_gw_free_ref(struct ba=
ckbone_gw *backbone_gw)
 /* finally deinitialize the claim */
 static void batadv_claim_free_rcu(struct rcu_head *rcu)
 {
-	struct claim *claim;
+	struct batadv_claim *claim;
=20
-	claim =3D container_of(rcu, struct claim, rcu);
+	claim =3D container_of(rcu, struct batadv_claim, rcu);
=20
 	batadv_backbone_gw_free_ref(claim->backbone_gw);
 	kfree(claim);
 }
=20
 /* free a claim, call claim_free_rcu if its the last reference */
-static void batadv_claim_free_ref(struct claim *claim)
+static void batadv_claim_free_ref(struct batadv_claim *claim)
 {
 	if (atomic_dec_and_test(&claim->refcount))
 		call_rcu(&claim->rcu, batadv_claim_free_rcu);
@@ -130,14 +130,14 @@ static void batadv_claim_free_ref(struct claim *c=
laim)
  * looks for a claim in the hash, and returns it if found
  * or NULL otherwise.
  */
-static struct claim *batadv_claim_hash_find(struct bat_priv *bat_priv,
-					    struct claim *data)
+static struct batadv_claim *batadv_claim_hash_find(struct batadv_priv =
*bat_priv,
+						   struct batadv_claim *data)
 {
 	struct batadv_hashtable *hash =3D bat_priv->claim_hash;
 	struct hlist_head *head;
 	struct hlist_node *node;
-	struct claim *claim;
-	struct claim *claim_tmp =3D NULL;
+	struct batadv_claim *claim;
+	struct batadv_claim *claim_tmp =3D NULL;
 	int index;
=20
 	if (!hash)
@@ -169,14 +169,15 @@ static struct claim *batadv_claim_hash_find(struc=
t bat_priv *bat_priv,
  * looks for a claim in the hash, and returns it if found
  * or NULL otherwise.
  */
-static struct backbone_gw *batadv_backbone_hash_find(struct bat_priv *=
bat_priv,
-						     uint8_t *addr, short vid)
+static struct batadv_backbone_gw *
+batadv_backbone_hash_find(struct batadv_priv *bat_priv,
+			  uint8_t *addr, short vid)
 {
 	struct batadv_hashtable *hash =3D bat_priv->backbone_hash;
 	struct hlist_head *head;
 	struct hlist_node *node;
-	struct backbone_gw search_entry, *backbone_gw;
-	struct backbone_gw *backbone_gw_tmp =3D NULL;
+	struct batadv_backbone_gw search_entry, *backbone_gw;
+	struct batadv_backbone_gw *backbone_gw_tmp =3D NULL;
 	int index;
=20
 	if (!hash)
@@ -206,12 +207,13 @@ static struct backbone_gw *batadv_backbone_hash_f=
ind(struct bat_priv *bat_priv,
 }
=20
 /* delete all claims for a backbone */
-static void batadv_bla_del_backbone_claims(struct backbone_gw *backbon=
e_gw)
+static void
+batadv_bla_del_backbone_claims(struct batadv_backbone_gw *backbone_gw)
 {
 	struct batadv_hashtable *hash;
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
-	struct claim *claim;
+	struct batadv_claim *claim;
 	int i;
 	spinlock_t *list_lock;	/* protects write access to the hash lists */
=20
@@ -247,12 +249,12 @@ static void batadv_bla_del_backbone_claims(struct=
 backbone_gw *backbone_gw)
  *
  * sends a claim frame according to the provided info.
  */
-static void batadv_bla_send_claim(struct bat_priv *bat_priv, uint8_t *=
mac,
+static void batadv_bla_send_claim(struct batadv_priv *bat_priv, uint8_=
t *mac,
 				  short vid, int claimtype)
 {
 	struct sk_buff *skb;
 	struct ethhdr *ethhdr;
-	struct hard_iface *primary_if;
+	struct batadv_hard_iface *primary_if;
 	struct net_device *soft_iface;
 	uint8_t *hw_src;
 	struct batadv_bla_claim_dst local_claim_dest;
@@ -353,11 +355,12 @@ out:
  * searches for the backbone gw or creates a new one if it could not
  * be found.
  */
-static struct backbone_gw *batadv_bla_get_backbone_gw(struct bat_priv =
*bat_priv,
-						      uint8_t *orig, short vid)
+static struct batadv_backbone_gw *
+batadv_bla_get_backbone_gw(struct batadv_priv *bat_priv, uint8_t *orig=
,
+			   short vid)
 {
-	struct backbone_gw *entry;
-	struct orig_node *orig_node;
+	struct batadv_backbone_gw *entry;
+	struct batadv_orig_node *orig_node;
 	int hash_added;
=20
 	entry =3D batadv_backbone_hash_find(bat_priv, orig, vid);
@@ -407,11 +410,12 @@ static struct backbone_gw *batadv_bla_get_backbon=
e_gw(struct bat_priv *bat_priv,
 /* update or add the own backbone gw to make sure we announce
  * where we receive other backbone gws
  */
-static void batadv_bla_update_own_backbone_gw(struct bat_priv *bat_pri=
v,
-					      struct hard_iface *primary_if,
-					      short vid)
+static void
+batadv_bla_update_own_backbone_gw(struct batadv_priv *bat_priv,
+				  struct batadv_hard_iface *primary_if,
+				  short vid)
 {
-	struct backbone_gw *backbone_gw;
+	struct batadv_backbone_gw *backbone_gw;
=20
 	backbone_gw =3D batadv_bla_get_backbone_gw(bat_priv,
 						 primary_if->net_dev->dev_addr,
@@ -429,14 +433,15 @@ static void batadv_bla_update_own_backbone_gw(str=
uct bat_priv *bat_priv,
  * Repeat all of our own claims, and finally send an ANNOUNCE frame
  * to allow the requester another check if the CRC is correct now.
  */
-static void batadv_bla_answer_request(struct bat_priv *bat_priv,
-				      struct hard_iface *primary_if, short vid)
+static void batadv_bla_answer_request(struct batadv_priv *bat_priv,
+				      struct batadv_hard_iface *primary_if,
+				      short vid)
 {
 	struct hlist_node *node;
 	struct hlist_head *head;
 	struct batadv_hashtable *hash;
-	struct claim *claim;
-	struct backbone_gw *backbone_gw;
+	struct batadv_claim *claim;
+	struct batadv_backbone_gw *backbone_gw;
 	int i;
=20
 	batadv_dbg(BATADV_DBG_BLA, bat_priv,
@@ -475,7 +480,7 @@ static void batadv_bla_answer_request(struct bat_pr=
iv *bat_priv,
  * After the request, it will repeat all of his own claims and finally
  * send an announcement claim with which we can check again.
  */
-static void batadv_bla_send_request(struct backbone_gw *backbone_gw)
+static void batadv_bla_send_request(struct batadv_backbone_gw *backbon=
e_gw)
 {
 	/* first, remove all old entries */
 	batadv_bla_del_backbone_claims(backbone_gw);
@@ -500,8 +505,8 @@ static void batadv_bla_send_request(struct backbone=
_gw *backbone_gw)
  * This function sends an announcement. It is called from multiple
  * places.
  */
-static void batadv_bla_send_announce(struct bat_priv *bat_priv,
-				     struct backbone_gw *backbone_gw)
+static void batadv_bla_send_announce(struct batadv_priv *bat_priv,
+				     struct batadv_backbone_gw *backbone_gw)
 {
 	uint8_t mac[ETH_ALEN];
 	__be16 crc;
@@ -522,12 +527,12 @@ static void batadv_bla_send_announce(struct bat_p=
riv *bat_priv,
  *
  * Adds a claim in the claim hash.
  */
-static void batadv_bla_add_claim(struct bat_priv *bat_priv, const uint=
8_t *mac,
-				 const short vid,
-				 struct backbone_gw *backbone_gw)
+static void batadv_bla_add_claim(struct batadv_priv *bat_priv,
+				 const uint8_t *mac, const short vid,
+				 struct batadv_backbone_gw *backbone_gw)
 {
-	struct claim *claim;
-	struct claim search_claim;
+	struct batadv_claim *claim;
+	struct batadv_claim search_claim;
 	int hash_added;
=20
 	memcpy(search_claim.addr, mac, ETH_ALEN);
@@ -588,10 +593,10 @@ claim_free_ref:
 /* Delete a claim from the claim hash which has the
  * given mac address and vid.
  */
-static void batadv_bla_del_claim(struct bat_priv *bat_priv, const uint=
8_t *mac,
-				 const short vid)
+static void batadv_bla_del_claim(struct batadv_priv *bat_priv,
+				 const uint8_t *mac, const short vid)
 {
-	struct claim search_claim, *claim;
+	struct batadv_claim search_claim, *claim;
=20
 	memcpy(search_claim.addr, mac, ETH_ALEN);
 	search_claim.vid =3D vid;
@@ -613,11 +618,11 @@ static void batadv_bla_del_claim(struct bat_priv =
*bat_priv, const uint8_t *mac,
 }
=20
 /* check for ANNOUNCE frame, return 1 if handled */
-static int batadv_handle_announce(struct bat_priv *bat_priv,
+static int batadv_handle_announce(struct batadv_priv *bat_priv,
 				  uint8_t *an_addr, uint8_t *backbone_addr,
 				  short vid)
 {
-	struct backbone_gw *backbone_gw;
+	struct batadv_backbone_gw *backbone_gw;
 	uint16_t crc;
=20
 	if (memcmp(an_addr, batadv_announce_mac, 4) !=3D 0)
@@ -659,8 +664,8 @@ static int batadv_handle_announce(struct bat_priv *=
bat_priv,
 }
=20
 /* check for REQUEST frame, return 1 if handled */
-static int batadv_handle_request(struct bat_priv *bat_priv,
-				 struct hard_iface *primary_if,
+static int batadv_handle_request(struct batadv_priv *bat_priv,
+				 struct batadv_hard_iface *primary_if,
 				 uint8_t *backbone_addr,
 				 struct ethhdr *ethhdr, short vid)
 {
@@ -683,12 +688,12 @@ static int batadv_handle_request(struct bat_priv =
*bat_priv,
 }
=20
 /* check for UNCLAIM frame, return 1 if handled */
-static int batadv_handle_unclaim(struct bat_priv *bat_priv,
-				 struct hard_iface *primary_if,
+static int batadv_handle_unclaim(struct batadv_priv *bat_priv,
+				 struct batadv_hard_iface *primary_if,
 				 uint8_t *backbone_addr,
 				 uint8_t *claim_addr, short vid)
 {
-	struct backbone_gw *backbone_gw;
+	struct batadv_backbone_gw *backbone_gw;
=20
 	/* unclaim in any case if it is our own */
 	if (primary_if && batadv_compare_eth(backbone_addr,
@@ -712,12 +717,12 @@ static int batadv_handle_unclaim(struct bat_priv =
*bat_priv,
 }
=20
 /* check for CLAIM frame, return 1 if handled */
-static int batadv_handle_claim(struct bat_priv *bat_priv,
-			       struct hard_iface *primary_if,
+static int batadv_handle_claim(struct batadv_priv *bat_priv,
+			       struct batadv_hard_iface *primary_if,
 			       uint8_t *backbone_addr, uint8_t *claim_addr,
 			       short vid)
 {
-	struct backbone_gw *backbone_gw;
+	struct batadv_backbone_gw *backbone_gw;
=20
 	/* register the gateway if not yet available, and add the claim. */
=20
@@ -752,13 +757,13 @@ static int batadv_handle_claim(struct bat_priv *b=
at_priv,
  *	1  - if is a claim packet from another group
  *	0  - if it is not a claim packet
  */
-static int batadv_check_claim_group(struct bat_priv *bat_priv,
-				    struct hard_iface *primary_if,
+static int batadv_check_claim_group(struct batadv_priv *bat_priv,
+				    struct batadv_hard_iface *primary_if,
 				    uint8_t *hw_src, uint8_t *hw_dst,
 				    struct ethhdr *ethhdr)
 {
 	uint8_t *backbone_addr;
-	struct orig_node *orig_node;
+	struct batadv_orig_node *orig_node;
 	struct batadv_bla_claim_dst *bla_dst, *bla_dst_own;
=20
 	bla_dst =3D (struct batadv_bla_claim_dst *)hw_dst;
@@ -824,8 +829,8 @@ static int batadv_check_claim_group(struct bat_priv=
 *bat_priv,
  * returns 1 if it was a claim frame, otherwise return 0 to
  * tell the callee that it can use the frame on its own.
  */
-static int batadv_bla_process_claim(struct bat_priv *bat_priv,
-				    struct hard_iface *primary_if,
+static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
+				    struct batadv_hard_iface *primary_if,
 				    struct sk_buff *skb)
 {
 	struct ethhdr *ethhdr;
@@ -926,9 +931,9 @@ static int batadv_bla_process_claim(struct bat_priv=
 *bat_priv,
 /* Check when we last heard from other nodes, and remove them in case =
of
  * a time out, or clean all backbone gws if now is set.
  */
-static void batadv_bla_purge_backbone_gw(struct bat_priv *bat_priv, in=
t now)
+static void batadv_bla_purge_backbone_gw(struct batadv_priv *bat_priv,=
 int now)
 {
-	struct backbone_gw *backbone_gw;
+	struct batadv_backbone_gw *backbone_gw;
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
 	struct batadv_hashtable *hash;
@@ -977,10 +982,11 @@ purge_now:
  * Check when we heard last time from our own claims, and remove them =
in case of
  * a time out, or clean all claims if now is set
  */
-static void batadv_bla_purge_claims(struct bat_priv *bat_priv,
-				    struct hard_iface *primary_if, int now)
+static void batadv_bla_purge_claims(struct batadv_priv *bat_priv,
+				    struct batadv_hard_iface *primary_if,
+				    int now)
 {
-	struct claim *claim;
+	struct batadv_claim *claim;
 	struct hlist_node *node;
 	struct hlist_head *head;
 	struct batadv_hashtable *hash;
@@ -1023,11 +1029,11 @@ purge_now:
  *
  * Update the backbone gateways when the own orig address changes.
  */
-void batadv_bla_update_orig_address(struct bat_priv *bat_priv,
-				    struct hard_iface *primary_if,
-				    struct hard_iface *oldif)
+void batadv_bla_update_orig_address(struct batadv_priv *bat_priv,
+				    struct batadv_hard_iface *primary_if,
+				    struct batadv_hard_iface *oldif)
 {
-	struct backbone_gw *backbone_gw;
+	struct batadv_backbone_gw *backbone_gw;
 	struct hlist_node *node;
 	struct hlist_head *head;
 	struct batadv_hashtable *hash;
@@ -1071,7 +1077,7 @@ void batadv_bla_update_orig_address(struct bat_pr=
iv *bat_priv,
=20
=20
 /* (re)start the timer */
-static void batadv_bla_start_timer(struct bat_priv *bat_priv)
+static void batadv_bla_start_timer(struct batadv_priv *bat_priv)
 {
 	INIT_DELAYED_WORK(&bat_priv->bla_work, batadv_bla_periodic_work);
 	queue_delayed_work(batadv_event_workqueue, &bat_priv->bla_work,
@@ -1086,15 +1092,15 @@ static void batadv_bla_periodic_work(struct wor=
k_struct *work)
 {
 	struct delayed_work *delayed_work =3D
 		container_of(work, struct delayed_work, work);
-	struct bat_priv *bat_priv =3D
-		container_of(delayed_work, struct bat_priv, bla_work);
+	struct batadv_priv *bat_priv;
 	struct hlist_node *node;
 	struct hlist_head *head;
-	struct backbone_gw *backbone_gw;
+	struct batadv_backbone_gw *backbone_gw;
 	struct batadv_hashtable *hash;
-	struct hard_iface *primary_if;
+	struct batadv_hard_iface *primary_if;
 	int i;
=20
+	bat_priv =3D container_of(delayed_work, struct batadv_priv, bla_work)=
;
 	primary_if =3D batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
@@ -1140,11 +1146,11 @@ static struct lock_class_key batadv_claim_hash_=
lock_class_key;
 static struct lock_class_key batadv_backbone_hash_lock_class_key;
=20
 /* initialize all bla structures */
-int batadv_bla_init(struct bat_priv *bat_priv)
+int batadv_bla_init(struct batadv_priv *bat_priv)
 {
 	int i;
 	uint8_t claim_dest[ETH_ALEN] =3D {0xff, 0x43, 0x05, 0x00, 0x00, 0x00}=
;
-	struct hard_iface *primary_if;
+	struct batadv_hard_iface *primary_if;
=20
 	batadv_dbg(BATADV_DBG_BLA, bat_priv, "bla hash registering\n");
=20
@@ -1200,14 +1206,14 @@ int batadv_bla_init(struct bat_priv *bat_priv)
  * sent by another host, drop it. We allow equal packets from
  * the same host however as this might be intended.
  */
-int batadv_bla_check_bcast_duplist(struct bat_priv *bat_priv,
+int batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
 				   struct batadv_bcast_packet *bcast_packet,
 				   int hdr_size)
 {
 	int i, length, curr;
 	uint8_t *content;
 	uint16_t crc;
-	struct bcast_duplist_entry *entry;
+	struct batadv_bcast_duplist_entry *entry;
=20
 	length =3D hdr_size - sizeof(*bcast_packet);
 	content =3D (uint8_t *)bcast_packet;
@@ -1260,12 +1266,12 @@ int batadv_bla_check_bcast_duplist(struct bat_p=
riv *bat_priv,
  *
  * returns 1 if it is found, 0 otherwise
  */
-int batadv_bla_is_backbone_gw_orig(struct bat_priv *bat_priv, uint8_t =
*orig)
+int batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv, uint8=
_t *orig)
 {
 	struct batadv_hashtable *hash =3D bat_priv->backbone_hash;
 	struct hlist_head *head;
 	struct hlist_node *node;
-	struct backbone_gw *backbone_gw;
+	struct batadv_backbone_gw *backbone_gw;
 	int i;
=20
 	if (!atomic_read(&bat_priv->bridge_loop_avoidance))
@@ -1300,11 +1306,11 @@ int batadv_bla_is_backbone_gw_orig(struct bat_p=
riv *bat_priv, uint8_t *orig)
  * returns 0.
  */
 int batadv_bla_is_backbone_gw(struct sk_buff *skb,
-			      struct orig_node *orig_node, int hdr_size)
+			      struct batadv_orig_node *orig_node, int hdr_size)
 {
 	struct ethhdr *ethhdr;
 	struct vlan_ethhdr *vhdr;
-	struct backbone_gw *backbone_gw;
+	struct batadv_backbone_gw *backbone_gw;
 	short vid =3D -1;
=20
 	if (!atomic_read(&orig_node->bat_priv->bridge_loop_avoidance))
@@ -1336,9 +1342,9 @@ int batadv_bla_is_backbone_gw(struct sk_buff *skb=
,
 }
=20
 /* free all bla structures (for softinterface free or module unload) *=
/
-void batadv_bla_free(struct bat_priv *bat_priv)
+void batadv_bla_free(struct batadv_priv *bat_priv)
 {
-	struct hard_iface *primary_if;
+	struct batadv_hard_iface *primary_if;
=20
 	cancel_delayed_work_sync(&bat_priv->bla_work);
 	primary_if =3D batadv_primary_if_get_selected(bat_priv);
@@ -1369,11 +1375,11 @@ void batadv_bla_free(struct bat_priv *bat_priv)
  * returns 1, otherwise it returns 0 and the caller shall further
  * process the skb.
  */
-int batadv_bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, shor=
t vid)
+int batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb, s=
hort vid)
 {
 	struct ethhdr *ethhdr;
-	struct claim search_claim, *claim =3D NULL;
-	struct hard_iface *primary_if;
+	struct batadv_claim search_claim, *claim =3D NULL;
+	struct batadv_hard_iface *primary_if;
 	int ret;
=20
 	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
@@ -1456,11 +1462,11 @@ out:
  * returns 1, otherwise it returns 0 and the caller shall further
  * process the skb.
  */
-int batadv_bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb, shor=
t vid)
+int batadv_bla_tx(struct batadv_priv *bat_priv, struct sk_buff *skb, s=
hort vid)
 {
 	struct ethhdr *ethhdr;
-	struct claim search_claim, *claim =3D NULL;
-	struct hard_iface *primary_if;
+	struct batadv_claim search_claim, *claim =3D NULL;
+	struct batadv_hard_iface *primary_if;
 	int ret =3D 0;
=20
 	primary_if =3D batadv_primary_if_get_selected(bat_priv);
@@ -1533,10 +1539,10 @@ out:
 int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *=
offset)
 {
 	struct net_device *net_dev =3D (struct net_device *)seq->private;
-	struct bat_priv *bat_priv =3D netdev_priv(net_dev);
+	struct batadv_priv *bat_priv =3D netdev_priv(net_dev);
 	struct batadv_hashtable *hash =3D bat_priv->claim_hash;
-	struct claim *claim;
-	struct hard_iface *primary_if;
+	struct batadv_claim *claim;
+	struct batadv_hard_iface *primary_if;
 	struct hlist_node *node;
 	struct hlist_head *head;
 	uint32_t i;
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/br=
idge_loop_avoidance.h
index d69f453..08d13cb 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -21,38 +21,38 @@
 #define _NET_BATMAN_ADV_BLA_H_
=20
 #ifdef CONFIG_BATMAN_ADV_BLA
-int batadv_bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, shor=
t vid);
-int batadv_bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb, shor=
t vid);
+int batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb, s=
hort vid);
+int batadv_bla_tx(struct batadv_priv *bat_priv, struct sk_buff *skb, s=
hort vid);
 int batadv_bla_is_backbone_gw(struct sk_buff *skb,
-			      struct orig_node *orig_node, int hdr_size);
+			      struct batadv_orig_node *orig_node, int hdr_size);
 int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *=
offset);
-int batadv_bla_is_backbone_gw_orig(struct bat_priv *bat_priv, uint8_t =
*orig);
-int batadv_bla_check_bcast_duplist(struct bat_priv *bat_priv,
+int batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv, uint8=
_t *orig);
+int batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
 				   struct batadv_bcast_packet *bcast_packet,
 				   int hdr_size);
-void batadv_bla_update_orig_address(struct bat_priv *bat_priv,
-				    struct hard_iface *primary_if,
-				    struct hard_iface *oldif);
-int batadv_bla_init(struct bat_priv *bat_priv);
-void batadv_bla_free(struct bat_priv *bat_priv);
+void batadv_bla_update_orig_address(struct batadv_priv *bat_priv,
+				    struct batadv_hard_iface *primary_if,
+				    struct batadv_hard_iface *oldif);
+int batadv_bla_init(struct batadv_priv *bat_priv);
+void batadv_bla_free(struct batadv_priv *bat_priv);
=20
 #define BATADV_BLA_CRC_INIT	0
 #else /* ifdef CONFIG_BATMAN_ADV_BLA */
=20
-static inline int batadv_bla_rx(struct bat_priv *bat_priv, struct sk_b=
uff *skb,
-				short vid)
+static inline int batadv_bla_rx(struct batadv_priv *bat_priv,
+				struct sk_buff *skb, short vid)
 {
 	return 0;
 }
=20
-static inline int batadv_bla_tx(struct bat_priv *bat_priv, struct sk_b=
uff *skb,
-				short vid)
+static inline int batadv_bla_tx(struct batadv_priv *bat_priv,
+				struct sk_buff *skb, short vid)
 {
 	return 0;
 }
=20
 static inline int batadv_bla_is_backbone_gw(struct sk_buff *skb,
-					    struct orig_node *orig_node,
+					    struct batadv_orig_node *orig_node,
 					    int hdr_size)
 {
 	return 0;
@@ -64,14 +64,14 @@ static inline int batadv_bla_claim_table_seq_print_=
text(struct seq_file *seq,
 	return 0;
 }
=20
-static inline int batadv_bla_is_backbone_gw_orig(struct bat_priv *bat_=
priv,
+static inline int batadv_bla_is_backbone_gw_orig(struct batadv_priv *b=
at_priv,
 						 uint8_t *orig)
 {
 	return 0;
 }
=20
 static inline int
-batadv_bla_check_bcast_duplist(struct bat_priv *bat_priv,
+batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
 			       struct batadv_bcast_packet *bcast_packet,
 			       int hdr_size)
 {
@@ -79,18 +79,18 @@ batadv_bla_check_bcast_duplist(struct bat_priv *bat=
_priv,
 }
=20
 static inline void
-batadv_bla_update_orig_address(struct bat_priv *bat_priv,
-			       struct hard_iface *primary_if,
-			       struct hard_iface *oldif)
+batadv_bla_update_orig_address(struct batadv_priv *bat_priv,
+			       struct batadv_hard_iface *primary_if,
+			       struct batadv_hard_iface *oldif)
 {
 }
=20
-static inline int batadv_bla_init(struct bat_priv *bat_priv)
+static inline int batadv_bla_init(struct batadv_priv *bat_priv)
 {
 	return 1;
 }
=20
-static inline void batadv_bla_free(struct bat_priv *bat_priv)
+static inline void batadv_bla_free(struct batadv_priv *bat_priv)
 {
 }
=20
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_c=
lient.c
index 00273b9..43b9c17 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -36,15 +36,16 @@
 #define BATADV_DHCP_OPTIONS_OFFSET 240
 #define BATADV_DHCP_REQUEST 3
=20
-static void batadv_gw_node_free_ref(struct gw_node *gw_node)
+static void batadv_gw_node_free_ref(struct batadv_gw_node *gw_node)
 {
 	if (atomic_dec_and_test(&gw_node->refcount))
 		kfree_rcu(gw_node, rcu);
 }
=20
-static struct gw_node *batadv_gw_get_selected_gw_node(struct bat_priv =
*bat_priv)
+static struct batadv_gw_node *
+batadv_gw_get_selected_gw_node(struct batadv_priv *bat_priv)
 {
-	struct gw_node *gw_node;
+	struct batadv_gw_node *gw_node;
=20
 	rcu_read_lock();
 	gw_node =3D rcu_dereference(bat_priv->curr_gw);
@@ -59,10 +60,11 @@ out:
 	return gw_node;
 }
=20
-struct orig_node *batadv_gw_get_selected_orig(struct bat_priv *bat_pri=
v)
+struct batadv_orig_node *
+batadv_gw_get_selected_orig(struct batadv_priv *bat_priv)
 {
-	struct gw_node *gw_node;
-	struct orig_node *orig_node =3D NULL;
+	struct batadv_gw_node *gw_node;
+	struct batadv_orig_node *orig_node =3D NULL;
=20
 	gw_node =3D batadv_gw_get_selected_gw_node(bat_priv);
 	if (!gw_node)
@@ -84,10 +86,10 @@ out:
 	return orig_node;
 }
=20
-static void batadv_gw_select(struct bat_priv *bat_priv,
-			     struct gw_node *new_gw_node)
+static void batadv_gw_select(struct batadv_priv *bat_priv,
+			     struct batadv_gw_node *new_gw_node)
 {
-	struct gw_node *curr_gw_node;
+	struct batadv_gw_node *curr_gw_node;
=20
 	spin_lock_bh(&bat_priv->gw_list_lock);
=20
@@ -103,20 +105,21 @@ static void batadv_gw_select(struct bat_priv *bat=
_priv,
 	spin_unlock_bh(&bat_priv->gw_list_lock);
 }
=20
-void batadv_gw_deselect(struct bat_priv *bat_priv)
+void batadv_gw_deselect(struct batadv_priv *bat_priv)
 {
 	atomic_set(&bat_priv->gw_reselect, 1);
 }
=20
-static struct gw_node *batadv_gw_get_best_gw_node(struct bat_priv *bat=
_priv)
+static struct batadv_gw_node *
+batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 {
-	struct neigh_node *router;
+	struct batadv_neigh_node *router;
 	struct hlist_node *node;
-	struct gw_node *gw_node, *curr_gw =3D NULL;
+	struct batadv_gw_node *gw_node, *curr_gw =3D NULL;
 	uint32_t max_gw_factor =3D 0, tmp_gw_factor =3D 0;
 	uint8_t max_tq =3D 0;
 	int down, up;
-	struct orig_node *orig_node;
+	struct batadv_orig_node *orig_node;
=20
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(gw_node, node, &bat_priv->gw_list, list) {
@@ -183,10 +186,10 @@ next:
 	return curr_gw;
 }
=20
-void batadv_gw_election(struct bat_priv *bat_priv)
+void batadv_gw_election(struct batadv_priv *bat_priv)
 {
-	struct gw_node *curr_gw =3D NULL, *next_gw =3D NULL;
-	struct neigh_node *router =3D NULL;
+	struct batadv_gw_node *curr_gw =3D NULL, *next_gw =3D NULL;
+	struct batadv_neigh_node *router =3D NULL;
 	char gw_addr[18] =3D { '\0' };
=20
 	/* The batman daemon checks here if we already passed a full originat=
or
@@ -249,11 +252,11 @@ out:
 		batadv_neigh_node_free_ref(router);
 }
=20
-void batadv_gw_check_election(struct bat_priv *bat_priv,
-			      struct orig_node *orig_node)
+void batadv_gw_check_election(struct batadv_priv *bat_priv,
+			      struct batadv_orig_node *orig_node)
 {
-	struct orig_node *curr_gw_orig;
-	struct neigh_node *router_gw =3D NULL, *router_orig =3D NULL;
+	struct batadv_orig_node *curr_gw_orig;
+	struct batadv_neigh_node *router_gw =3D NULL, *router_orig =3D NULL;
 	uint8_t gw_tq_avg, orig_tq_avg;
=20
 	curr_gw_orig =3D batadv_gw_get_selected_orig(bat_priv);
@@ -303,11 +306,11 @@ out:
 	return;
 }
=20
-static void batadv_gw_node_add(struct bat_priv *bat_priv,
-			       struct orig_node *orig_node,
+static void batadv_gw_node_add(struct batadv_priv *bat_priv,
+			       struct batadv_orig_node *orig_node,
 			       uint8_t new_gwflags)
 {
-	struct gw_node *gw_node;
+	struct batadv_gw_node *gw_node;
 	int down, up;
=20
 	gw_node =3D kzalloc(sizeof(*gw_node), GFP_ATOMIC);
@@ -332,11 +335,12 @@ static void batadv_gw_node_add(struct bat_priv *b=
at_priv,
 		   (up > 2048 ? "MBit" : "KBit"));
 }
=20
-void batadv_gw_node_update(struct bat_priv *bat_priv,
-			   struct orig_node *orig_node, uint8_t new_gwflags)
+void batadv_gw_node_update(struct batadv_priv *bat_priv,
+			   struct batadv_orig_node *orig_node,
+			   uint8_t new_gwflags)
 {
 	struct hlist_node *node;
-	struct gw_node *gw_node, *curr_gw;
+	struct batadv_gw_node *gw_node, *curr_gw;
=20
 	/* Note: We don't need a NULL check here, since curr_gw never gets
 	 * dereferenced. If curr_gw is NULL we also should not exit as we may
@@ -385,15 +389,15 @@ unlock:
 		batadv_gw_node_free_ref(curr_gw);
 }
=20
-void batadv_gw_node_delete(struct bat_priv *bat_priv,
-			   struct orig_node *orig_node)
+void batadv_gw_node_delete(struct batadv_priv *bat_priv,
+			   struct batadv_orig_node *orig_node)
 {
 	batadv_gw_node_update(bat_priv, orig_node, 0);
 }
=20
-void batadv_gw_node_purge(struct bat_priv *bat_priv)
+void batadv_gw_node_purge(struct batadv_priv *bat_priv)
 {
-	struct gw_node *gw_node, *curr_gw;
+	struct batadv_gw_node *gw_node, *curr_gw;
 	struct hlist_node *node, *node_tmp;
 	unsigned long timeout =3D msecs_to_jiffies(2 * BATADV_PURGE_TIMEOUT);
 	int do_deselect =3D 0;
@@ -427,12 +431,12 @@ void batadv_gw_node_purge(struct bat_priv *bat_pr=
iv)
 }
=20
 /* fails if orig_node has no router */
-static int batadv_write_buffer_text(struct bat_priv *bat_priv,
-				     struct seq_file *seq,
-				     const struct gw_node *gw_node)
+static int batadv_write_buffer_text(struct batadv_priv *bat_priv,
+				    struct seq_file *seq,
+				    const struct batadv_gw_node *gw_node)
 {
-	struct gw_node *curr_gw;
-	struct neigh_node *router;
+	struct batadv_gw_node *curr_gw;
+	struct batadv_neigh_node *router;
 	int down, up, ret =3D -1;
=20
 	batadv_gw_bandwidth_to_kbit(gw_node->orig_node->gw_flags, &down, &up)=
;
@@ -464,9 +468,9 @@ out:
 int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset=
)
 {
 	struct net_device *net_dev =3D (struct net_device *)seq->private;
-	struct bat_priv *bat_priv =3D netdev_priv(net_dev);
-	struct hard_iface *primary_if;
-	struct gw_node *gw_node;
+	struct batadv_priv *bat_priv =3D netdev_priv(net_dev);
+	struct batadv_hard_iface *primary_if;
+	struct batadv_gw_node *gw_node;
 	struct hlist_node *node;
 	int gw_count =3D 0, ret =3D 0;
=20
@@ -639,12 +643,12 @@ bool batadv_gw_is_dhcp_target(struct sk_buff *skb=
, unsigned int *header_len)
 	return true;
 }
=20
-bool batadv_gw_out_of_range(struct bat_priv *bat_priv,
+bool batadv_gw_out_of_range(struct batadv_priv *bat_priv,
 			    struct sk_buff *skb, struct ethhdr *ethhdr)
 {
-	struct neigh_node *neigh_curr =3D NULL, *neigh_old =3D NULL;
-	struct orig_node *orig_dst_node =3D NULL;
-	struct gw_node *curr_gw =3D NULL;
+	struct batadv_neigh_node *neigh_curr =3D NULL, *neigh_old =3D NULL;
+	struct batadv_orig_node *orig_dst_node =3D NULL;
+	struct batadv_gw_node *curr_gw =3D NULL;
 	bool ret, out_of_range =3D false;
 	unsigned int header_len =3D 0;
 	uint8_t curr_tq_avg;
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_c=
lient.h
index 4529d42..f0d129e 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -20,19 +20,21 @@
 #ifndef _NET_BATMAN_ADV_GATEWAY_CLIENT_H_
 #define _NET_BATMAN_ADV_GATEWAY_CLIENT_H_
=20
-void batadv_gw_deselect(struct bat_priv *bat_priv);
-void batadv_gw_election(struct bat_priv *bat_priv);
-struct orig_node *batadv_gw_get_selected_orig(struct bat_priv *bat_pri=
v);
-void batadv_gw_check_election(struct bat_priv *bat_priv,
-			      struct orig_node *orig_node);
-void batadv_gw_node_update(struct bat_priv *bat_priv,
-			   struct orig_node *orig_node, uint8_t new_gwflags);
-void batadv_gw_node_delete(struct bat_priv *bat_priv,
-			   struct orig_node *orig_node);
-void batadv_gw_node_purge(struct bat_priv *bat_priv);
+void batadv_gw_deselect(struct batadv_priv *bat_priv);
+void batadv_gw_election(struct batadv_priv *bat_priv);
+struct batadv_orig_node *
+batadv_gw_get_selected_orig(struct batadv_priv *bat_priv);
+void batadv_gw_check_election(struct batadv_priv *bat_priv,
+			      struct batadv_orig_node *orig_node);
+void batadv_gw_node_update(struct batadv_priv *bat_priv,
+			   struct batadv_orig_node *orig_node,
+			   uint8_t new_gwflags);
+void batadv_gw_node_delete(struct batadv_priv *bat_priv,
+			   struct batadv_orig_node *orig_node);
+void batadv_gw_node_purge(struct batadv_priv *bat_priv);
 int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset=
);
 bool batadv_gw_is_dhcp_target(struct sk_buff *skb, unsigned int *heade=
r_len);
-bool batadv_gw_out_of_range(struct bat_priv *bat_priv,
+bool batadv_gw_out_of_range(struct batadv_priv *bat_priv,
 			    struct sk_buff *skb, struct ethhdr *ethhdr);
=20
 #endif /* _NET_BATMAN_ADV_GATEWAY_CLIENT_H_ */
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_c=
ommon.c
index f5c3980..9001208 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -137,7 +137,7 @@ static bool batadv_parse_gw_bandwidth(struct net_de=
vice *net_dev, char *buff,
 ssize_t batadv_gw_bandwidth_set(struct net_device *net_dev, char *buff=
,
 				size_t count)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(net_dev);
+	struct batadv_priv *bat_priv =3D netdev_priv(net_dev);
 	long gw_bandwidth_tmp =3D 0;
 	int up =3D 0, down =3D 0;
 	bool ret;
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-inte=
rface.c
index 0a14fdf..eb765a7 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -32,16 +32,17 @@
=20
 void batadv_hardif_free_rcu(struct rcu_head *rcu)
 {
-	struct hard_iface *hard_iface;
+	struct batadv_hard_iface *hard_iface;
=20
-	hard_iface =3D container_of(rcu, struct hard_iface, rcu);
+	hard_iface =3D container_of(rcu, struct batadv_hard_iface, rcu);
 	dev_put(hard_iface->net_dev);
 	kfree(hard_iface);
 }
=20
-struct hard_iface *batadv_hardif_get_by_netdev(const struct net_device=
 *net_dev)
+struct batadv_hard_iface *
+batadv_hardif_get_by_netdev(const struct net_device *net_dev)
 {
-	struct hard_iface *hard_iface;
+	struct batadv_hard_iface *hard_iface;
=20
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
@@ -75,10 +76,10 @@ static int batadv_is_valid_iface(const struct net_d=
evice *net_dev)
 	return 1;
 }
=20
-static struct hard_iface *
+static struct batadv_hard_iface *
 batadv_hardif_get_active(const struct net_device *soft_iface)
 {
-	struct hard_iface *hard_iface;
+	struct batadv_hard_iface *hard_iface;
=20
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
@@ -97,11 +98,11 @@ out:
 	return hard_iface;
 }
=20
-static void batadv_primary_if_update_addr(struct bat_priv *bat_priv,
-					  struct hard_iface *oldif)
+static void batadv_primary_if_update_addr(struct batadv_priv *bat_priv=
,
+					  struct batadv_hard_iface *oldif)
 {
 	struct batadv_vis_packet *vis_packet;
-	struct hard_iface *primary_if;
+	struct batadv_hard_iface *primary_if;
=20
 	primary_if =3D batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
@@ -119,10 +120,10 @@ out:
 		batadv_hardif_free_ref(primary_if);
 }
=20
-static void batadv_primary_if_select(struct bat_priv *bat_priv,
-				     struct hard_iface *new_hard_iface)
+static void batadv_primary_if_select(struct batadv_priv *bat_priv,
+				     struct batadv_hard_iface *new_hard_iface)
 {
-	struct hard_iface *curr_hard_iface;
+	struct batadv_hard_iface *curr_hard_iface;
=20
 	ASSERT_RTNL();
=20
@@ -143,7 +144,8 @@ out:
 		batadv_hardif_free_ref(curr_hard_iface);
 }
=20
-static bool batadv_hardif_is_iface_up(const struct hard_iface *hard_if=
ace)
+static bool
+batadv_hardif_is_iface_up(const struct batadv_hard_iface *hard_iface)
 {
 	if (hard_iface->net_dev->flags & IFF_UP)
 		return true;
@@ -153,7 +155,7 @@ static bool batadv_hardif_is_iface_up(const struct =
hard_iface *hard_iface)
=20
 static void batadv_check_known_mac_addr(const struct net_device *net_d=
ev)
 {
-	const struct hard_iface *hard_iface;
+	const struct batadv_hard_iface *hard_iface;
=20
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
@@ -177,8 +179,8 @@ static void batadv_check_known_mac_addr(const struc=
t net_device *net_dev)
=20
 int batadv_hardif_min_mtu(struct net_device *soft_iface)
 {
-	const struct bat_priv *bat_priv =3D netdev_priv(soft_iface);
-	const struct hard_iface *hard_iface;
+	const struct batadv_priv *bat_priv =3D netdev_priv(soft_iface);
+	const struct batadv_hard_iface *hard_iface;
 	/* allow big frames if all devices are capable to do so
 	 * (have MTU > 1500 + BAT_HEADER_LEN)
 	 */
@@ -215,10 +217,11 @@ void batadv_update_min_mtu(struct net_device *sof=
t_iface)
 		soft_iface->mtu =3D min_mtu;
 }
=20
-static void batadv_hardif_activate_interface(struct hard_iface *hard_i=
face)
+static void
+batadv_hardif_activate_interface(struct batadv_hard_iface *hard_iface)
 {
-	struct bat_priv *bat_priv;
-	struct hard_iface *primary_if =3D NULL;
+	struct batadv_priv *bat_priv;
+	struct batadv_hard_iface *primary_if =3D NULL;
=20
 	if (hard_iface->if_status !=3D BATADV_IF_INACTIVE)
 		goto out;
@@ -245,7 +248,8 @@ out:
 		batadv_hardif_free_ref(primary_if);
 }
=20
-static void batadv_hardif_deactivate_interface(struct hard_iface *hard=
_iface)
+static void
+batadv_hardif_deactivate_interface(struct batadv_hard_iface *hard_ifac=
e)
 {
 	if ((hard_iface->if_status !=3D BATADV_IF_ACTIVE) &&
 	    (hard_iface->if_status !=3D BATADV_IF_TO_BE_ACTIVATED))
@@ -259,10 +263,10 @@ static void batadv_hardif_deactivate_interface(st=
ruct hard_iface *hard_iface)
 	batadv_update_min_mtu(hard_iface->soft_iface);
 }
=20
-int batadv_hardif_enable_interface(struct hard_iface *hard_iface,
+int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_ifac=
e,
 				   const char *iface_name)
 {
-	struct bat_priv *bat_priv;
+	struct batadv_priv *bat_priv;
 	struct net_device *soft_iface;
 	__be16 ethertype =3D __constant_htons(BATADV_ETH_P_BATMAN);
 	int ret;
@@ -354,10 +358,10 @@ err:
 	return ret;
 }
=20
-void batadv_hardif_disable_interface(struct hard_iface *hard_iface)
+void batadv_hardif_disable_interface(struct batadv_hard_iface *hard_if=
ace)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
-	struct hard_iface *primary_if =3D NULL;
+	struct batadv_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
+	struct batadv_hard_iface *primary_if =3D NULL;
=20
 	if (hard_iface->if_status =3D=3D BATADV_IF_ACTIVE)
 		batadv_hardif_deactivate_interface(hard_iface);
@@ -374,7 +378,7 @@ void batadv_hardif_disable_interface(struct hard_if=
ace *hard_iface)
=20
 	primary_if =3D batadv_primary_if_get_selected(bat_priv);
 	if (hard_iface =3D=3D primary_if) {
-		struct hard_iface *new_if;
+		struct batadv_hard_iface *new_if;
=20
 		new_if =3D batadv_hardif_get_active(hard_iface->soft_iface);
 		batadv_primary_if_select(bat_priv, new_if);
@@ -403,10 +407,10 @@ out:
 		batadv_hardif_free_ref(primary_if);
 }
=20
-static struct hard_iface *
+static struct batadv_hard_iface *
 batadv_hardif_add_interface(struct net_device *net_dev)
 {
-	struct hard_iface *hard_iface;
+	struct batadv_hard_iface *hard_iface;
 	int ret;
=20
 	ASSERT_RTNL();
@@ -452,7 +456,7 @@ out:
 	return NULL;
 }
=20
-static void batadv_hardif_remove_interface(struct hard_iface *hard_ifa=
ce)
+static void batadv_hardif_remove_interface(struct batadv_hard_iface *h=
ard_iface)
 {
 	ASSERT_RTNL();
=20
@@ -470,7 +474,7 @@ static void batadv_hardif_remove_interface(struct h=
ard_iface *hard_iface)
=20
 void batadv_hardif_remove_interfaces(void)
 {
-	struct hard_iface *hard_iface, *hard_iface_tmp;
+	struct batadv_hard_iface *hard_iface, *hard_iface_tmp;
=20
 	rtnl_lock();
 	list_for_each_entry_safe(hard_iface, hard_iface_tmp,
@@ -485,10 +489,11 @@ static int batadv_hard_if_event(struct notifier_b=
lock *this,
 				unsigned long event, void *ptr)
 {
 	struct net_device *net_dev =3D ptr;
-	struct hard_iface *hard_iface =3D batadv_hardif_get_by_netdev(net_dev=
);
-	struct hard_iface *primary_if =3D NULL;
-	struct bat_priv *bat_priv;
+	struct batadv_hard_iface *hard_iface;
+	struct batadv_hard_iface *primary_if =3D NULL;
+	struct batadv_priv *bat_priv;
=20
+	hard_iface =3D batadv_hardif_get_by_netdev(net_dev);
 	if (!hard_iface && event =3D=3D NETDEV_REGISTER)
 		hard_iface =3D batadv_hardif_add_interface(net_dev);
=20
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-inte=
rface.h
index 4b60d58..3732366 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -31,11 +31,11 @@ enum batadv_hard_if_state {
=20
 extern struct notifier_block batadv_hard_if_notifier;
=20
-struct hard_iface*
+struct batadv_hard_iface*
 batadv_hardif_get_by_netdev(const struct net_device *net_dev);
-int batadv_hardif_enable_interface(struct hard_iface *hard_iface,
+int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_ifac=
e,
 				   const char *iface_name);
-void batadv_hardif_disable_interface(struct hard_iface *hard_iface);
+void batadv_hardif_disable_interface(struct batadv_hard_iface *hard_if=
ace);
 void batadv_hardif_remove_interfaces(void);
 int batadv_hardif_min_mtu(struct net_device *soft_iface);
 void batadv_update_min_mtu(struct net_device *soft_iface);
@@ -43,16 +43,16 @@ void batadv_hardif_free_rcu(struct rcu_head *rcu);
 bool batadv_is_wifi_iface(int ifindex);
=20
 static inline void
-batadv_hardif_free_ref(struct hard_iface *hard_iface)
+batadv_hardif_free_ref(struct batadv_hard_iface *hard_iface)
 {
 	if (atomic_dec_and_test(&hard_iface->refcount))
 		call_rcu(&hard_iface->rcu, batadv_hardif_free_rcu);
 }
=20
-static inline struct hard_iface *
-batadv_primary_if_get_selected(struct bat_priv *bat_priv)
+static inline struct batadv_hard_iface *
+batadv_primary_if_get_selected(struct batadv_priv *bat_priv)
 {
-	struct hard_iface *hard_iface;
+	struct batadv_hard_iface *hard_iface;
=20
 	rcu_read_lock();
 	hard_iface =3D rcu_dereference(bat_priv->primary_if);
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.=
c
index ca07580..bde3cf747 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -26,9 +26,9 @@
 #include "originator.h"
 #include "hard-interface.h"
=20
-static struct socket_client *batadv_socket_client_hash[256];
+static struct batadv_socket_client *batadv_socket_client_hash[256];
=20
-static void batadv_socket_add_packet(struct socket_client *socket_clie=
nt,
+static void batadv_socket_add_packet(struct batadv_socket_client *sock=
et_client,
 				     struct batadv_icmp_packet_rr *icmp_packet,
 				     size_t icmp_len);
=20
@@ -40,7 +40,7 @@ void batadv_socket_init(void)
 static int batadv_socket_open(struct inode *inode, struct file *file)
 {
 	unsigned int i;
-	struct socket_client *socket_client;
+	struct batadv_socket_client *socket_client;
=20
 	nonseekable_open(inode, file);
=20
@@ -77,8 +77,8 @@ static int batadv_socket_open(struct inode *inode, st=
ruct file *file)
=20
 static int batadv_socket_release(struct inode *inode, struct file *fil=
e)
 {
-	struct socket_client *socket_client =3D file->private_data;
-	struct socket_packet *socket_packet;
+	struct batadv_socket_client *socket_client =3D file->private_data;
+	struct batadv_socket_packet *socket_packet;
 	struct list_head *list_pos, *list_pos_tmp;
=20
 	spin_lock_bh(&socket_client->lock);
@@ -86,7 +86,7 @@ static int batadv_socket_release(struct inode *inode,=
 struct file *file)
 	/* for all packets in the queue ... */
 	list_for_each_safe(list_pos, list_pos_tmp, &socket_client->queue_list=
) {
 		socket_packet =3D list_entry(list_pos,
-					   struct socket_packet, list);
+					   struct batadv_socket_packet, list);
=20
 		list_del(list_pos);
 		kfree(socket_packet);
@@ -104,8 +104,8 @@ static int batadv_socket_release(struct inode *inod=
e, struct file *file)
 static ssize_t batadv_socket_read(struct file *file, char __user *buf,
 				  size_t count, loff_t *ppos)
 {
-	struct socket_client *socket_client =3D file->private_data;
-	struct socket_packet *socket_packet;
+	struct batadv_socket_client *socket_client =3D file->private_data;
+	struct batadv_socket_packet *socket_packet;
 	size_t packet_len;
 	int error;
=20
@@ -127,7 +127,7 @@ static ssize_t batadv_socket_read(struct file *file=
, char __user *buf,
 	spin_lock_bh(&socket_client->lock);
=20
 	socket_packet =3D list_first_entry(&socket_client->queue_list,
-					 struct socket_packet, list);
+					 struct batadv_socket_packet, list);
 	list_del(&socket_packet->list);
 	socket_client->queue_len--;
=20
@@ -147,14 +147,14 @@ static ssize_t batadv_socket_read(struct file *fi=
le, char __user *buf,
 static ssize_t batadv_socket_write(struct file *file, const char __use=
r *buff,
 				   size_t len, loff_t *off)
 {
-	struct socket_client *socket_client =3D file->private_data;
-	struct bat_priv *bat_priv =3D socket_client->bat_priv;
-	struct hard_iface *primary_if =3D NULL;
+	struct batadv_socket_client *socket_client =3D file->private_data;
+	struct batadv_priv *bat_priv =3D socket_client->bat_priv;
+	struct batadv_hard_iface *primary_if =3D NULL;
 	struct sk_buff *skb;
 	struct batadv_icmp_packet_rr *icmp_packet;
=20
-	struct orig_node *orig_node =3D NULL;
-	struct neigh_node *neigh_node =3D NULL;
+	struct batadv_orig_node *orig_node =3D NULL;
+	struct batadv_neigh_node *neigh_node =3D NULL;
 	size_t packet_len =3D sizeof(struct batadv_icmp_packet);
=20
 	if (len < sizeof(struct batadv_icmp_packet)) {
@@ -255,7 +255,7 @@ out:
=20
 static unsigned int batadv_socket_poll(struct file *file, poll_table *=
wait)
 {
-	struct socket_client *socket_client =3D file->private_data;
+	struct batadv_socket_client *socket_client =3D file->private_data;
=20
 	poll_wait(file, &socket_client->queue_wait, wait);
=20
@@ -275,7 +275,7 @@ static const struct file_operations batadv_fops =3D=
 {
 	.llseek =3D no_llseek,
 };
=20
-int batadv_socket_setup(struct bat_priv *bat_priv)
+int batadv_socket_setup(struct batadv_priv *bat_priv)
 {
 	struct dentry *d;
=20
@@ -293,11 +293,11 @@ err:
 	return -ENOMEM;
 }
=20
-static void batadv_socket_add_packet(struct socket_client *socket_clie=
nt,
+static void batadv_socket_add_packet(struct batadv_socket_client *sock=
et_client,
 				     struct batadv_icmp_packet_rr *icmp_packet,
 				     size_t icmp_len)
 {
-	struct socket_packet *socket_packet;
+	struct batadv_socket_packet *socket_packet;
=20
 	socket_packet =3D kmalloc(sizeof(*socket_packet), GFP_ATOMIC);
=20
@@ -324,7 +324,8 @@ static void batadv_socket_add_packet(struct socket_=
client *socket_client,
=20
 	if (socket_client->queue_len > 100) {
 		socket_packet =3D list_first_entry(&socket_client->queue_list,
-						 struct socket_packet, list);
+						 struct batadv_socket_packet,
+						 list);
=20
 		list_del(&socket_packet->list);
 		kfree(socket_packet);
@@ -339,7 +340,7 @@ static void batadv_socket_add_packet(struct socket_=
client *socket_client,
 void batadv_socket_receive_packet(struct batadv_icmp_packet_rr *icmp_p=
acket,
 				  size_t icmp_len)
 {
-	struct socket_client *hash;
+	struct batadv_socket_client *hash;
=20
 	hash =3D batadv_socket_client_hash[icmp_packet->uid];
 	if (hash)
diff --git a/net/batman-adv/icmp_socket.h b/net/batman-adv/icmp_socket.=
h
index 7b8ad52..29443a1 100644
--- a/net/batman-adv/icmp_socket.h
+++ b/net/batman-adv/icmp_socket.h
@@ -23,7 +23,7 @@
 #define BATADV_ICMP_SOCKET "socket"
=20
 void batadv_socket_init(void);
-int batadv_socket_setup(struct bat_priv *bat_priv);
+int batadv_socket_setup(struct batadv_priv *bat_priv);
 void batadv_socket_receive_packet(struct batadv_icmp_packet_rr *icmp_p=
acket,
 				  size_t icmp_len);
=20
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 97144a9..17dcdd9 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -39,7 +39,7 @@
  */
 struct list_head batadv_hardif_list;
 static int (*batadv_rx_handler[256])(struct sk_buff *,
-				     struct hard_iface *);
+				     struct batadv_hard_iface *);
 char batadv_routing_algo[20] =3D "BATMAN_IV";
 static struct hlist_head batadv_algo_list;
=20
@@ -92,7 +92,7 @@ static void __exit batadv_exit(void)
=20
 int batadv_mesh_init(struct net_device *soft_iface)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(soft_iface);
+	struct batadv_priv *bat_priv =3D netdev_priv(soft_iface);
 	int ret;
=20
 	spin_lock_init(&bat_priv->forw_bat_list_lock);
@@ -143,7 +143,7 @@ err:
=20
 void batadv_mesh_free(struct net_device *soft_iface)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(soft_iface);
+	struct batadv_priv *bat_priv =3D netdev_priv(soft_iface);
=20
 	atomic_set(&bat_priv->mesh_state, BATADV_MESH_DEACTIVATING);
=20
@@ -175,7 +175,7 @@ void batadv_dec_module_count(void)
=20
 int batadv_is_my_mac(const uint8_t *addr)
 {
-	const struct hard_iface *hard_iface;
+	const struct batadv_hard_iface *hard_iface;
=20
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
@@ -192,7 +192,7 @@ int batadv_is_my_mac(const uint8_t *addr)
 }
=20
 static int batadv_recv_unhandled_packet(struct sk_buff *skb,
-					struct hard_iface *recv_if)
+					struct batadv_hard_iface *recv_if)
 {
 	return NET_RX_DROP;
 }
@@ -204,13 +204,14 @@ int batadv_batman_skb_recv(struct sk_buff *skb, s=
truct net_device *dev,
 			   struct packet_type *ptype,
 			   struct net_device *orig_dev)
 {
-	struct bat_priv *bat_priv;
+	struct batadv_priv *bat_priv;
 	struct batadv_ogm_packet *batadv_ogm_packet;
-	struct hard_iface *hard_iface;
+	struct batadv_hard_iface *hard_iface;
 	uint8_t idx;
 	int ret;
=20
-	hard_iface =3D container_of(ptype, struct hard_iface, batman_adv_ptyp=
e);
+	hard_iface =3D container_of(ptype, struct batadv_hard_iface,
+				  batman_adv_ptype);
 	skb =3D skb_share_check(skb, GFP_ATOMIC);
=20
 	/* skb was released by skb_share_check() */
@@ -290,9 +291,10 @@ static void batadv_recv_handler_init(void)
 	batadv_rx_handler[BATADV_ROAM_ADV] =3D batadv_recv_roam_adv;
 }
=20
-int batadv_recv_handler_register(uint8_t packet_type,
-				 int (*recv_handler)(struct sk_buff *,
-						     struct hard_iface *))
+int
+batadv_recv_handler_register(uint8_t packet_type,
+			     int (*recv_handler)(struct sk_buff *,
+						 struct batadv_hard_iface *))
 {
 	if (batadv_rx_handler[packet_type] !=3D &batadv_recv_unhandled_packet=
)
 		return -EBUSY;
@@ -306,9 +308,9 @@ void batadv_recv_handler_unregister(uint8_t packet_=
type)
 	batadv_rx_handler[packet_type] =3D batadv_recv_unhandled_packet;
 }
=20
-static struct bat_algo_ops *batadv_algo_get(char *name)
+static struct batadv_algo_ops *batadv_algo_get(char *name)
 {
-	struct bat_algo_ops *bat_algo_ops =3D NULL, *bat_algo_ops_tmp;
+	struct batadv_algo_ops *bat_algo_ops =3D NULL, *bat_algo_ops_tmp;
 	struct hlist_node *node;
=20
 	hlist_for_each_entry(bat_algo_ops_tmp, node, &batadv_algo_list, list)=
 {
@@ -322,9 +324,9 @@ static struct bat_algo_ops *batadv_algo_get(char *n=
ame)
 	return bat_algo_ops;
 }
=20
-int batadv_algo_register(struct bat_algo_ops *bat_algo_ops)
+int batadv_algo_register(struct batadv_algo_ops *bat_algo_ops)
 {
-	struct bat_algo_ops *bat_algo_ops_tmp;
+	struct batadv_algo_ops *bat_algo_ops_tmp;
 	int ret;
=20
 	bat_algo_ops_tmp =3D batadv_algo_get(bat_algo_ops->name);
@@ -356,9 +358,9 @@ out:
 	return ret;
 }
=20
-int batadv_algo_select(struct bat_priv *bat_priv, char *name)
+int batadv_algo_select(struct batadv_priv *bat_priv, char *name)
 {
-	struct bat_algo_ops *bat_algo_ops;
+	struct batadv_algo_ops *bat_algo_ops;
 	int ret =3D -EINVAL;
=20
 	bat_algo_ops =3D batadv_algo_get(name);
@@ -374,7 +376,7 @@ out:
=20
 int batadv_algo_seq_print_text(struct seq_file *seq, void *offset)
 {
-	struct bat_algo_ops *bat_algo_ops;
+	struct batadv_algo_ops *bat_algo_ops;
 	struct hlist_node *node;
=20
 	seq_printf(seq, "Available routing algorithms:\n");
@@ -388,7 +390,7 @@ int batadv_algo_seq_print_text(struct seq_file *seq=
, void *offset)
=20
 static int batadv_param_set_ra(const char *val, const struct kernel_pa=
ram *kp)
 {
-	struct bat_algo_ops *bat_algo_ops;
+	struct batadv_algo_ops *bat_algo_ops;
 	char *algo_name =3D (char *)val;
 	size_t name_len =3D strlen(algo_name);
=20
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 68e13ac..8193650 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -164,16 +164,17 @@ int batadv_is_my_mac(const uint8_t *addr);
 int batadv_batman_skb_recv(struct sk_buff *skb, struct net_device *dev=
,
 			   struct packet_type *ptype,
 			   struct net_device *orig_dev);
-int batadv_recv_handler_register(uint8_t packet_type,
-				 int (*recv_handler)(struct sk_buff *,
-						     struct hard_iface *));
+int
+batadv_recv_handler_register(uint8_t packet_type,
+			     int (*recv_handler)(struct sk_buff *,
+						 struct batadv_hard_iface *));
 void batadv_recv_handler_unregister(uint8_t packet_type);
-int batadv_algo_register(struct bat_algo_ops *bat_algo_ops);
-int batadv_algo_select(struct bat_priv *bat_priv, char *name);
+int batadv_algo_register(struct batadv_algo_ops *bat_algo_ops);
+int batadv_algo_select(struct batadv_priv *bat_priv, char *name);
 int batadv_algo_seq_print_text(struct seq_file *seq, void *offset);
=20
 #ifdef CONFIG_BATMAN_ADV_DEBUG
-int batadv_debug_log(struct bat_priv *bat_priv, const char *fmt, ...)
+int batadv_debug_log(struct batadv_priv *bat_priv, const char *fmt, ..=
=2E)
 __printf(2, 3);
=20
 #define batadv_dbg(type, bat_priv, fmt, arg...)			\
@@ -185,7 +186,7 @@ __printf(2, 3);
 #else /* !CONFIG_BATMAN_ADV_DEBUG */
 __printf(3, 4)
 static inline void batadv_dbg(int type __always_unused,
-			      struct bat_priv *bat_priv __always_unused,
+			      struct batadv_priv *bat_priv __always_unused,
 			      const char *fmt __always_unused, ...)
 {
 }
@@ -194,14 +195,14 @@ static inline void batadv_dbg(int type __always_u=
nused,
 #define batadv_info(net_dev, fmt, arg...)				\
 	do {								\
 		struct net_device *_netdev =3D (net_dev);                 \
-		struct bat_priv *_batpriv =3D netdev_priv(_netdev);       \
+		struct batadv_priv *_batpriv =3D netdev_priv(_netdev);    \
 		batadv_dbg(BATADV_DBG_ALL, _batpriv, fmt, ## arg);	\
 		pr_info("%s: " fmt, _netdev->name, ## arg);		\
 	} while (0)
 #define batadv_err(net_dev, fmt, arg...)				\
 	do {								\
 		struct net_device *_netdev =3D (net_dev);                 \
-		struct bat_priv *_batpriv =3D netdev_priv(_netdev);       \
+		struct batadv_priv *_batpriv =3D netdev_priv(_netdev);    \
 		batadv_dbg(BATADV_DBG_ALL, _batpriv, fmt, ## arg);	\
 		pr_err("%s: " fmt, _netdev->name, ## arg);		\
 	} while (0)
@@ -250,7 +251,7 @@ static inline bool batadv_has_timed_out(unsigned lo=
ng timestamp,
 #define batadv_seq_after(x, y) batadv_seq_before(y, x)
=20
 /* Stop preemption on local cpu while incrementing the counter */
-static inline void batadv_add_counter(struct bat_priv *bat_priv, size_=
t idx,
+static inline void batadv_add_counter(struct batadv_priv *bat_priv, si=
ze_t idx,
 				      size_t count)
 {
 	int cpu =3D get_cpu();
@@ -261,7 +262,8 @@ static inline void batadv_add_counter(struct bat_pr=
iv *bat_priv, size_t idx,
 #define batadv_inc_counter(b, i) batadv_add_counter(b, i, 1)
=20
 /* Sum and return the cpu-local counters for index 'idx' */
-static inline uint64_t batadv_sum_counter(struct bat_priv *bat_priv, s=
ize_t idx)
+static inline uint64_t batadv_sum_counter(struct batadv_priv *bat_priv=
,
+					  size_t idx)
 {
 	uint64_t *counters;
 	int cpu;
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index dc9c4bf..fc1ce26 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -30,7 +30,7 @@
=20
 static void batadv_purge_orig(struct work_struct *work);
=20
-static void batadv_start_purge_timer(struct bat_priv *bat_priv)
+static void batadv_start_purge_timer(struct batadv_priv *bat_priv)
 {
 	INIT_DELAYED_WORK(&bat_priv->orig_work, batadv_purge_orig);
 	queue_delayed_work(batadv_event_workqueue,
@@ -40,12 +40,13 @@ static void batadv_start_purge_timer(struct bat_pri=
v *bat_priv)
 /* returns 1 if they are the same originator */
 static int batadv_compare_orig(const struct hlist_node *node, const vo=
id *data2)
 {
-	const void *data1 =3D container_of(node, struct orig_node, hash_entry=
);
+	const void *data1 =3D container_of(node, struct batadv_orig_node,
+					 hash_entry);
=20
 	return (memcmp(data1, data2, ETH_ALEN) =3D=3D 0 ? 1 : 0);
 }
=20
-int batadv_originator_init(struct bat_priv *bat_priv)
+int batadv_originator_init(struct batadv_priv *bat_priv)
 {
 	if (bat_priv->orig_hash)
 		return 0;
@@ -62,16 +63,17 @@ err:
 	return -ENOMEM;
 }
=20
-void batadv_neigh_node_free_ref(struct neigh_node *neigh_node)
+void batadv_neigh_node_free_ref(struct batadv_neigh_node *neigh_node)
 {
 	if (atomic_dec_and_test(&neigh_node->refcount))
 		kfree_rcu(neigh_node, rcu);
 }
=20
 /* increases the refcounter of a found router */
-struct neigh_node *batadv_orig_node_get_router(struct orig_node *orig_=
node)
+struct batadv_neigh_node *
+batadv_orig_node_get_router(struct batadv_orig_node *orig_node)
 {
-	struct neigh_node *router;
+	struct batadv_neigh_node *router;
=20
 	rcu_read_lock();
 	router =3D rcu_dereference(orig_node->router);
@@ -83,12 +85,12 @@ struct neigh_node *batadv_orig_node_get_router(stru=
ct orig_node *orig_node)
 	return router;
 }
=20
-struct neigh_node *batadv_neigh_node_new(struct hard_iface *hard_iface=
,
-					 const uint8_t *neigh_addr,
-					 uint32_t seqno)
+struct batadv_neigh_node *
+batadv_neigh_node_new(struct batadv_hard_iface *hard_iface,
+		      const uint8_t *neigh_addr, uint32_t seqno)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
-	struct neigh_node *neigh_node;
+	struct batadv_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
+	struct batadv_neigh_node *neigh_node;
=20
 	neigh_node =3D kzalloc(sizeof(*neigh_node), GFP_ATOMIC);
 	if (!neigh_node)
@@ -113,10 +115,10 @@ out:
 static void batadv_orig_node_free_rcu(struct rcu_head *rcu)
 {
 	struct hlist_node *node, *node_tmp;
-	struct neigh_node *neigh_node, *tmp_neigh_node;
-	struct orig_node *orig_node;
+	struct batadv_neigh_node *neigh_node, *tmp_neigh_node;
+	struct batadv_orig_node *orig_node;
=20
-	orig_node =3D container_of(rcu, struct orig_node, rcu);
+	orig_node =3D container_of(rcu, struct batadv_orig_node, rcu);
=20
 	spin_lock_bh(&orig_node->neigh_list_lock);
=20
@@ -146,19 +148,19 @@ static void batadv_orig_node_free_rcu(struct rcu_=
head *rcu)
 	kfree(orig_node);
 }
=20
-void batadv_orig_node_free_ref(struct orig_node *orig_node)
+void batadv_orig_node_free_ref(struct batadv_orig_node *orig_node)
 {
 	if (atomic_dec_and_test(&orig_node->refcount))
 		call_rcu(&orig_node->rcu, batadv_orig_node_free_rcu);
 }
=20
-void batadv_originator_free(struct bat_priv *bat_priv)
+void batadv_originator_free(struct batadv_priv *bat_priv)
 {
 	struct batadv_hashtable *hash =3D bat_priv->orig_hash;
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
 	spinlock_t *list_lock; /* spinlock to protect write access */
-	struct orig_node *orig_node;
+	struct batadv_orig_node *orig_node;
 	uint32_t i;
=20
 	if (!hash)
@@ -188,10 +190,10 @@ void batadv_originator_free(struct bat_priv *bat_=
priv)
 /* this function finds or creates an originator entry for the given
  * address if it does not exits
  */
-struct orig_node *batadv_get_orig_node(struct bat_priv *bat_priv,
-				       const uint8_t *addr)
+struct batadv_orig_node *batadv_get_orig_node(struct batadv_priv *bat_=
priv,
+					      const uint8_t *addr)
 {
-	struct orig_node *orig_node;
+	struct batadv_orig_node *orig_node;
 	int size;
 	int hash_added;
 	unsigned long reset_time;
@@ -264,15 +266,16 @@ free_orig_node:
 	return NULL;
 }
=20
-static bool batadv_purge_orig_neighbors(struct bat_priv *bat_priv,
-					struct orig_node *orig_node,
-					struct neigh_node **best_neigh_node)
+static bool
+batadv_purge_orig_neighbors(struct batadv_priv *bat_priv,
+			    struct batadv_orig_node *orig_node,
+			    struct batadv_neigh_node **best_neigh_node)
 {
 	struct hlist_node *node, *node_tmp;
-	struct neigh_node *neigh_node;
+	struct batadv_neigh_node *neigh_node;
 	bool neigh_purged =3D false;
 	unsigned long last_seen;
-	struct hard_iface *if_incoming;
+	struct batadv_hard_iface *if_incoming;
=20
 	*best_neigh_node =3D NULL;
=20
@@ -319,10 +322,10 @@ static bool batadv_purge_orig_neighbors(struct ba=
t_priv *bat_priv,
 	return neigh_purged;
 }
=20
-static bool batadv_purge_orig_node(struct bat_priv *bat_priv,
-				   struct orig_node *orig_node)
+static bool batadv_purge_orig_node(struct batadv_priv *bat_priv,
+				   struct batadv_orig_node *orig_node)
 {
-	struct neigh_node *best_neigh_node;
+	struct batadv_neigh_node *best_neigh_node;
=20
 	if (batadv_has_timed_out(orig_node->last_seen,
 				 2 * BATADV_PURGE_TIMEOUT)) {
@@ -341,13 +344,13 @@ static bool batadv_purge_orig_node(struct bat_pri=
v *bat_priv,
 	return false;
 }
=20
-static void _batadv_purge_orig(struct bat_priv *bat_priv)
+static void _batadv_purge_orig(struct batadv_priv *bat_priv)
 {
 	struct batadv_hashtable *hash =3D bat_priv->orig_hash;
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
 	spinlock_t *list_lock; /* spinlock to protect write access */
-	struct orig_node *orig_node;
+	struct batadv_orig_node *orig_node;
 	uint32_t i;
=20
 	if (!hash)
@@ -383,16 +386,16 @@ static void _batadv_purge_orig(struct bat_priv *b=
at_priv)
=20
 static void batadv_purge_orig(struct work_struct *work)
 {
-	struct delayed_work *delayed_work =3D
-		container_of(work, struct delayed_work, work);
-	struct bat_priv *bat_priv =3D
-		container_of(delayed_work, struct bat_priv, orig_work);
+	struct delayed_work *delayed_work;
+	struct batadv_priv *bat_priv;
=20
+	delayed_work =3D container_of(work, struct delayed_work, work);
+	bat_priv =3D container_of(delayed_work, struct batadv_priv, orig_work=
);
 	_batadv_purge_orig(bat_priv);
 	batadv_start_purge_timer(bat_priv);
 }
=20
-void batadv_purge_orig_ref(struct bat_priv *bat_priv)
+void batadv_purge_orig_ref(struct batadv_priv *bat_priv)
 {
 	_batadv_purge_orig(bat_priv);
 }
@@ -400,13 +403,13 @@ void batadv_purge_orig_ref(struct bat_priv *bat_p=
riv)
 int batadv_orig_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct net_device *net_dev =3D (struct net_device *)seq->private;
-	struct bat_priv *bat_priv =3D netdev_priv(net_dev);
+	struct batadv_priv *bat_priv =3D netdev_priv(net_dev);
 	struct batadv_hashtable *hash =3D bat_priv->orig_hash;
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
-	struct hard_iface *primary_if;
-	struct orig_node *orig_node;
-	struct neigh_node *neigh_node, *neigh_node_tmp;
+	struct batadv_hard_iface *primary_if;
+	struct batadv_orig_node *orig_node;
+	struct batadv_neigh_node *neigh_node, *neigh_node_tmp;
 	int batman_count =3D 0;
 	int last_seen_secs;
 	int last_seen_msecs;
@@ -484,7 +487,8 @@ out:
 	return ret;
 }
=20
-static int batadv_orig_node_add_if(struct orig_node *orig_node, int ma=
x_if_num)
+static int batadv_orig_node_add_if(struct batadv_orig_node *orig_node,
+				   int max_if_num)
 {
 	void *data_ptr;
 	size_t data_size, old_size;
@@ -511,13 +515,14 @@ static int batadv_orig_node_add_if(struct orig_no=
de *orig_node, int max_if_num)
 	return 0;
 }
=20
-int batadv_orig_hash_add_if(struct hard_iface *hard_iface, int max_if_=
num)
+int batadv_orig_hash_add_if(struct batadv_hard_iface *hard_iface,
+			    int max_if_num)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
+	struct batadv_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
 	struct batadv_hashtable *hash =3D bat_priv->orig_hash;
 	struct hlist_node *node;
 	struct hlist_head *head;
-	struct orig_node *orig_node;
+	struct batadv_orig_node *orig_node;
 	uint32_t i;
 	int ret;
=20
@@ -546,7 +551,7 @@ err:
 	return -ENOMEM;
 }
=20
-static int batadv_orig_node_del_if(struct orig_node *orig_node,
+static int batadv_orig_node_del_if(struct batadv_orig_node *orig_node,
 				   int max_if_num, int del_if_num)
 {
 	void *data_ptr =3D NULL;
@@ -594,14 +599,15 @@ free_own_sum:
 	return 0;
 }
=20
-int batadv_orig_hash_del_if(struct hard_iface *hard_iface, int max_if_=
num)
+int batadv_orig_hash_del_if(struct batadv_hard_iface *hard_iface,
+			    int max_if_num)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
+	struct batadv_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
 	struct batadv_hashtable *hash =3D bat_priv->orig_hash;
 	struct hlist_node *node;
 	struct hlist_head *head;
-	struct hard_iface *hard_iface_tmp;
-	struct orig_node *orig_node;
+	struct batadv_hard_iface *hard_iface_tmp;
+	struct batadv_orig_node *orig_node;
 	uint32_t i;
 	int ret;
=20
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 32e7e28..9778e65 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -22,20 +22,23 @@
=20
 #include "hash.h"
=20
-int batadv_originator_init(struct bat_priv *bat_priv);
-void batadv_originator_free(struct bat_priv *bat_priv);
-void batadv_purge_orig_ref(struct bat_priv *bat_priv);
-void batadv_orig_node_free_ref(struct orig_node *orig_node);
-struct orig_node *batadv_get_orig_node(struct bat_priv *bat_priv,
-				       const uint8_t *addr);
-struct neigh_node *batadv_neigh_node_new(struct hard_iface *hard_iface=
,
-					 const uint8_t *neigh_addr,
-					 uint32_t seqno);
-void batadv_neigh_node_free_ref(struct neigh_node *neigh_node);
-struct neigh_node *batadv_orig_node_get_router(struct orig_node *orig_=
node);
+int batadv_originator_init(struct batadv_priv *bat_priv);
+void batadv_originator_free(struct batadv_priv *bat_priv);
+void batadv_purge_orig_ref(struct batadv_priv *bat_priv);
+void batadv_orig_node_free_ref(struct batadv_orig_node *orig_node);
+struct batadv_orig_node *batadv_get_orig_node(struct batadv_priv *bat_=
priv,
+					      const uint8_t *addr);
+struct batadv_neigh_node *
+batadv_neigh_node_new(struct batadv_hard_iface *hard_iface,
+		      const uint8_t *neigh_addr, uint32_t seqno);
+void batadv_neigh_node_free_ref(struct batadv_neigh_node *neigh_node);
+struct batadv_neigh_node *
+batadv_orig_node_get_router(struct batadv_orig_node *orig_node);
 int batadv_orig_seq_print_text(struct seq_file *seq, void *offset);
-int batadv_orig_hash_add_if(struct hard_iface *hard_iface, int max_if_=
num);
-int batadv_orig_hash_del_if(struct hard_iface *hard_iface, int max_if_=
num);
+int batadv_orig_hash_add_if(struct batadv_hard_iface *hard_iface,
+			    int max_if_num);
+int batadv_orig_hash_del_if(struct batadv_hard_iface *hard_iface,
+			    int max_if_num);
=20
=20
 /* hashfunction to choose an entry in a hash table of given size
@@ -60,13 +63,13 @@ static inline uint32_t batadv_choose_orig(const voi=
d *data, uint32_t size)
 	return hash % size;
 }
=20
-static inline struct orig_node *batadv_orig_hash_find(struct bat_priv =
*bat_priv,
-						      const void *data)
+static inline struct batadv_orig_node *
+batadv_orig_hash_find(struct batadv_priv *bat_priv, const void *data)
 {
 	struct batadv_hashtable *hash =3D bat_priv->orig_hash;
 	struct hlist_head *head;
 	struct hlist_node *node;
-	struct orig_node *orig_node, *orig_node_tmp =3D NULL;
+	struct batadv_orig_node *orig_node, *orig_node_tmp =3D NULL;
 	int index;
=20
 	if (!hash)
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index e157907..b79e42e 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -30,15 +30,15 @@
 #include "bridge_loop_avoidance.h"
=20
 static int batadv_route_unicast_packet(struct sk_buff *skb,
-				       struct hard_iface *recv_if);
+				       struct batadv_hard_iface *recv_if);
=20
-void batadv_slide_own_bcast_window(struct hard_iface *hard_iface)
+void batadv_slide_own_bcast_window(struct batadv_hard_iface *hard_ifac=
e)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
+	struct batadv_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
 	struct batadv_hashtable *hash =3D bat_priv->orig_hash;
 	struct hlist_node *node;
 	struct hlist_head *head;
-	struct orig_node *orig_node;
+	struct batadv_orig_node *orig_node;
 	unsigned long *word;
 	uint32_t i;
 	size_t word_index;
@@ -62,11 +62,11 @@ void batadv_slide_own_bcast_window(struct hard_ifac=
e *hard_iface)
 	}
 }
=20
-static void _batadv_update_route(struct bat_priv *bat_priv,
-				 struct orig_node *orig_node,
-				 struct neigh_node *neigh_node)
+static void _batadv_update_route(struct batadv_priv *bat_priv,
+				 struct batadv_orig_node *orig_node,
+				 struct batadv_neigh_node *neigh_node)
 {
-	struct neigh_node *curr_router;
+	struct batadv_neigh_node *curr_router;
=20
 	curr_router =3D batadv_orig_node_get_router(orig_node);
=20
@@ -107,10 +107,11 @@ static void _batadv_update_route(struct bat_priv =
*bat_priv,
 		batadv_neigh_node_free_ref(curr_router);
 }
=20
-void batadv_update_route(struct bat_priv *bat_priv, struct orig_node *=
orig_node,
-			 struct neigh_node *neigh_node)
+void batadv_update_route(struct batadv_priv *bat_priv,
+			 struct batadv_orig_node *orig_node,
+			 struct batadv_neigh_node *neigh_node)
 {
-	struct neigh_node *router =3D NULL;
+	struct batadv_neigh_node *router =3D NULL;
=20
 	if (!orig_node)
 		goto out;
@@ -126,8 +127,8 @@ out:
 }
=20
 /* caller must hold the neigh_list_lock */
-void batadv_bonding_candidate_del(struct orig_node *orig_node,
-				  struct neigh_node *neigh_node)
+void batadv_bonding_candidate_del(struct batadv_orig_node *orig_node,
+				  struct batadv_neigh_node *neigh_node)
 {
 	/* this neighbor is not part of our candidate list */
 	if (list_empty(&neigh_node->bonding_list))
@@ -142,11 +143,11 @@ out:
 	return;
 }
=20
-void batadv_bonding_candidate_add(struct orig_node *orig_node,
-				  struct neigh_node *neigh_node)
+void batadv_bonding_candidate_add(struct batadv_orig_node *orig_node,
+				  struct batadv_neigh_node *neigh_node)
 {
 	struct hlist_node *node;
-	struct neigh_node *tmp_neigh_node, *router =3D NULL;
+	struct batadv_neigh_node *tmp_neigh_node, *router =3D NULL;
 	uint8_t interference_candidate =3D 0;
=20
 	spin_lock_bh(&orig_node->neigh_list_lock);
@@ -215,8 +216,8 @@ out:
=20
 /* copy primary address for bonding */
 void
-batadv_bonding_save_primary(const struct orig_node *orig_node,
-			    struct orig_node *orig_neigh_node,
+batadv_bonding_save_primary(const struct batadv_orig_node *orig_node,
+			    struct batadv_orig_node *orig_neigh_node,
 			    const struct batadv_ogm_packet *batman_ogm_packet)
 {
 	if (!(batman_ogm_packet->flags & BATADV_PRIMARIES_FIRST_HOP))
@@ -230,7 +231,7 @@ batadv_bonding_save_primary(const struct orig_node =
*orig_node,
  *  0 if the packet is to be accepted
  *  1 if the packet is to be ignored.
  */
-int batadv_window_protected(struct bat_priv *bat_priv, int32_t seq_num=
_diff,
+int batadv_window_protected(struct batadv_priv *bat_priv, int32_t seq_=
num_diff,
 			    unsigned long *last_reset)
 {
 	if (seq_num_diff <=3D -BATADV_TQ_LOCAL_WINDOW_SIZE ||
@@ -248,7 +249,7 @@ int batadv_window_protected(struct bat_priv *bat_pr=
iv, int32_t seq_num_diff,
 }
=20
 bool batadv_check_management_packet(struct sk_buff *skb,
-				    struct hard_iface *hard_iface,
+				    struct batadv_hard_iface *hard_iface,
 				    int header_len)
 {
 	struct ethhdr *ethhdr;
@@ -278,12 +279,12 @@ bool batadv_check_management_packet(struct sk_buf=
f *skb,
 	return true;
 }
=20
-static int batadv_recv_my_icmp_packet(struct bat_priv *bat_priv,
+static int batadv_recv_my_icmp_packet(struct batadv_priv *bat_priv,
 				      struct sk_buff *skb, size_t icmp_len)
 {
-	struct hard_iface *primary_if =3D NULL;
-	struct orig_node *orig_node =3D NULL;
-	struct neigh_node *router =3D NULL;
+	struct batadv_hard_iface *primary_if =3D NULL;
+	struct batadv_orig_node *orig_node =3D NULL;
+	struct batadv_neigh_node *router =3D NULL;
 	struct batadv_icmp_packet_rr *icmp_packet;
 	int ret =3D NET_RX_DROP;
=20
@@ -333,12 +334,12 @@ out:
 	return ret;
 }
=20
-static int batadv_recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
+static int batadv_recv_icmp_ttl_exceeded(struct batadv_priv *bat_priv,
 					 struct sk_buff *skb)
 {
-	struct hard_iface *primary_if =3D NULL;
-	struct orig_node *orig_node =3D NULL;
-	struct neigh_node *router =3D NULL;
+	struct batadv_hard_iface *primary_if =3D NULL;
+	struct batadv_orig_node *orig_node =3D NULL;
+	struct batadv_neigh_node *router =3D NULL;
 	struct batadv_icmp_packet *icmp_packet;
 	int ret =3D NET_RX_DROP;
=20
@@ -389,13 +390,14 @@ out:
 }
=20
=20
-int batadv_recv_icmp_packet(struct sk_buff *skb, struct hard_iface *re=
cv_if)
+int batadv_recv_icmp_packet(struct sk_buff *skb,
+			    struct batadv_hard_iface *recv_if)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
+	struct batadv_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
 	struct batadv_icmp_packet_rr *icmp_packet;
 	struct ethhdr *ethhdr;
-	struct orig_node *orig_node =3D NULL;
-	struct neigh_node *router =3D NULL;
+	struct batadv_orig_node *orig_node =3D NULL;
+	struct batadv_neigh_node *router =3D NULL;
 	int hdr_size =3D sizeof(struct batadv_icmp_packet);
 	int ret =3D NET_RX_DROP;
=20
@@ -475,12 +477,12 @@ out:
  * This method rotates the bonding list and increases the
  * returned router's refcount.
  */
-static struct neigh_node *
-batadv_find_bond_router(struct orig_node *primary_orig,
-			const struct hard_iface *recv_if)
+static struct batadv_neigh_node *
+batadv_find_bond_router(struct batadv_orig_node *primary_orig,
+			const struct batadv_hard_iface *recv_if)
 {
-	struct neigh_node *tmp_neigh_node;
-	struct neigh_node *router =3D NULL, *first_candidate =3D NULL;
+	struct batadv_neigh_node *tmp_neigh_node;
+	struct batadv_neigh_node *router =3D NULL, *first_candidate =3D NULL;
=20
 	rcu_read_lock();
 	list_for_each_entry_rcu(tmp_neigh_node, &primary_orig->bond_list,
@@ -530,12 +532,12 @@ out:
  *
  * Increases the returned router's refcount
  */
-static struct neigh_node *
-batadv_find_ifalter_router(struct orig_node *primary_orig,
-			   const struct hard_iface *recv_if)
+static struct batadv_neigh_node *
+batadv_find_ifalter_router(struct batadv_orig_node *primary_orig,
+			   const struct batadv_hard_iface *recv_if)
 {
-	struct neigh_node *tmp_neigh_node;
-	struct neigh_node *router =3D NULL, *first_candidate =3D NULL;
+	struct batadv_neigh_node *tmp_neigh_node;
+	struct batadv_neigh_node *router =3D NULL, *first_candidate =3D NULL;
=20
 	rcu_read_lock();
 	list_for_each_entry_rcu(tmp_neigh_node, &primary_orig->bond_list,
@@ -577,9 +579,9 @@ batadv_find_ifalter_router(struct orig_node *primar=
y_orig,
 	return router;
 }
=20
-int batadv_recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_=
if)
+int batadv_recv_tt_query(struct sk_buff *skb, struct batadv_hard_iface=
 *recv_if)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
+	struct batadv_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
 	struct batadv_tt_query_packet *tt_query;
 	uint16_t tt_size;
 	struct ethhdr *ethhdr;
@@ -667,11 +669,11 @@ out:
 	return NET_RX_DROP;
 }
=20
-int batadv_recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_=
if)
+int batadv_recv_roam_adv(struct sk_buff *skb, struct batadv_hard_iface=
 *recv_if)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
+	struct batadv_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
 	struct batadv_roam_adv_packet *roam_adv_packet;
-	struct orig_node *orig_node;
+	struct batadv_orig_node *orig_node;
 	struct ethhdr *ethhdr;
=20
 	/* drop packet if it has not necessary minimum size */
@@ -731,13 +733,14 @@ out:
  * bonding if possible. increases the found neighbors
  * refcount.
  */
-struct neigh_node *batadv_find_router(struct bat_priv *bat_priv,
-				      struct orig_node *orig_node,
-				      const struct hard_iface *recv_if)
+struct batadv_neigh_node *
+batadv_find_router(struct batadv_priv *bat_priv,
+		   struct batadv_orig_node *orig_node,
+		   const struct batadv_hard_iface *recv_if)
 {
-	struct orig_node *primary_orig_node;
-	struct orig_node *router_orig;
-	struct neigh_node *router;
+	struct batadv_orig_node *primary_orig_node;
+	struct batadv_orig_node *router_orig;
+	struct batadv_neigh_node *router;
 	static uint8_t zero_mac[ETH_ALEN] =3D {0, 0, 0, 0, 0, 0};
 	int bonding_enabled;
 	uint8_t *primary_addr;
@@ -842,11 +845,11 @@ static int batadv_check_unicast_packet(struct sk_=
buff *skb, int hdr_size)
 }
=20
 static int batadv_route_unicast_packet(struct sk_buff *skb,
-				       struct hard_iface *recv_if)
+				       struct batadv_hard_iface *recv_if)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
-	struct orig_node *orig_node =3D NULL;
-	struct neigh_node *neigh_node =3D NULL;
+	struct batadv_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
+	struct batadv_orig_node *orig_node =3D NULL;
+	struct batadv_neigh_node *neigh_node =3D NULL;
 	struct batadv_unicast_packet *unicast_packet;
 	struct ethhdr *ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
 	int ret =3D NET_RX_DROP;
@@ -927,12 +930,12 @@ out:
 	return ret;
 }
=20
-static int batadv_check_unicast_ttvn(struct bat_priv *bat_priv,
+static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 				     struct sk_buff *skb) {
 	uint8_t curr_ttvn;
-	struct orig_node *orig_node;
+	struct batadv_orig_node *orig_node;
 	struct ethhdr *ethhdr;
-	struct hard_iface *primary_if;
+	struct batadv_hard_iface *primary_if;
 	struct batadv_unicast_packet *unicast_packet;
 	bool tt_poss_change;
 	int is_old_ttvn;
@@ -1006,9 +1009,10 @@ static int batadv_check_unicast_ttvn(struct bat_=
priv *bat_priv,
 	return 1;
 }
=20
-int batadv_recv_unicast_packet(struct sk_buff *skb, struct hard_iface =
*recv_if)
+int batadv_recv_unicast_packet(struct sk_buff *skb,
+			       struct batadv_hard_iface *recv_if)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
+	struct batadv_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
 	struct batadv_unicast_packet *unicast_packet;
 	int hdr_size =3D sizeof(*unicast_packet);
=20
@@ -1031,9 +1035,9 @@ int batadv_recv_unicast_packet(struct sk_buff *sk=
b, struct hard_iface *recv_if)
 }
=20
 int batadv_recv_ucast_frag_packet(struct sk_buff *skb,
-				  struct hard_iface *recv_if)
+				  struct batadv_hard_iface *recv_if)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
+	struct batadv_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
 	struct batadv_unicast_frag_packet *unicast_packet;
 	int hdr_size =3D sizeof(*unicast_packet);
 	struct sk_buff *new_skb =3D NULL;
@@ -1068,10 +1072,11 @@ int batadv_recv_ucast_frag_packet(struct sk_buf=
f *skb,
 }
=20
=20
-int batadv_recv_bcast_packet(struct sk_buff *skb, struct hard_iface *r=
ecv_if)
+int batadv_recv_bcast_packet(struct sk_buff *skb,
+			     struct batadv_hard_iface *recv_if)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
-	struct orig_node *orig_node =3D NULL;
+	struct batadv_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
+	struct batadv_orig_node *orig_node =3D NULL;
 	struct batadv_bcast_packet *bcast_packet;
 	struct ethhdr *ethhdr;
 	int hdr_size =3D sizeof(*bcast_packet);
@@ -1158,11 +1163,12 @@ out:
 	return ret;
 }
=20
-int batadv_recv_vis_packet(struct sk_buff *skb, struct hard_iface *rec=
v_if)
+int batadv_recv_vis_packet(struct sk_buff *skb,
+			   struct batadv_hard_iface *recv_if)
 {
 	struct batadv_vis_packet *vis_packet;
 	struct ethhdr *ethhdr;
-	struct bat_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
+	struct batadv_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
 	int hdr_size =3D sizeof(*vis_packet);
=20
 	/* keep skb linear */
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index ead4ae0..9262279 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -20,32 +20,40 @@
 #ifndef _NET_BATMAN_ADV_ROUTING_H_
 #define _NET_BATMAN_ADV_ROUTING_H_
=20
-void batadv_slide_own_bcast_window(struct hard_iface *hard_iface);
+void batadv_slide_own_bcast_window(struct batadv_hard_iface *hard_ifac=
e);
 bool batadv_check_management_packet(struct sk_buff *skb,
-				    struct hard_iface *hard_iface,
+				    struct batadv_hard_iface *hard_iface,
 				    int header_len);
-void batadv_update_route(struct bat_priv *bat_priv, struct orig_node *=
orig_node,
-			 struct neigh_node *neigh_node);
-int batadv_recv_icmp_packet(struct sk_buff *skb, struct hard_iface *re=
cv_if);
-int batadv_recv_unicast_packet(struct sk_buff *skb, struct hard_iface =
*recv_if);
+void batadv_update_route(struct batadv_priv *bat_priv,
+			 struct batadv_orig_node *orig_node,
+			 struct batadv_neigh_node *neigh_node);
+int batadv_recv_icmp_packet(struct sk_buff *skb,
+			    struct batadv_hard_iface *recv_if);
+int batadv_recv_unicast_packet(struct sk_buff *skb,
+			       struct batadv_hard_iface *recv_if);
 int batadv_recv_ucast_frag_packet(struct sk_buff *skb,
-				  struct hard_iface *recv_if);
-int batadv_recv_bcast_packet(struct sk_buff *skb, struct hard_iface *r=
ecv_if);
-int batadv_recv_vis_packet(struct sk_buff *skb, struct hard_iface *rec=
v_if);
-int batadv_recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_=
if);
-int batadv_recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_=
if);
-struct neigh_node *batadv_find_router(struct bat_priv *bat_priv,
-				      struct orig_node *orig_node,
-				      const struct hard_iface *recv_if);
-void batadv_bonding_candidate_del(struct orig_node *orig_node,
-				  struct neigh_node *neigh_node);
-void batadv_bonding_candidate_add(struct orig_node *orig_node,
-				  struct neigh_node *neigh_node);
-void batadv_bonding_save_primary(const struct orig_node *orig_node,
-				 struct orig_node *orig_neigh_node,
+				  struct batadv_hard_iface *recv_if);
+int batadv_recv_bcast_packet(struct sk_buff *skb,
+			     struct batadv_hard_iface *recv_if);
+int batadv_recv_vis_packet(struct sk_buff *skb,
+			   struct batadv_hard_iface *recv_if);
+int batadv_recv_tt_query(struct sk_buff *skb,
+			 struct batadv_hard_iface *recv_if);
+int batadv_recv_roam_adv(struct sk_buff *skb,
+			 struct batadv_hard_iface *recv_if);
+struct batadv_neigh_node *
+batadv_find_router(struct batadv_priv *bat_priv,
+		   struct batadv_orig_node *orig_node,
+		   const struct batadv_hard_iface *recv_if);
+void batadv_bonding_candidate_del(struct batadv_orig_node *orig_node,
+				  struct batadv_neigh_node *neigh_node);
+void batadv_bonding_candidate_add(struct batadv_orig_node *orig_node,
+				  struct batadv_neigh_node *neigh_node);
+void batadv_bonding_save_primary(const struct batadv_orig_node *orig_n=
ode,
+				 struct batadv_orig_node *orig_neigh_node,
 				 const struct batadv_ogm_packet
 				 *batman_ogm_packet);
-int batadv_window_protected(struct bat_priv *bat_priv, int32_t seq_num=
_diff,
+int batadv_window_protected(struct batadv_priv *bat_priv, int32_t seq_=
num_diff,
 			    unsigned long *last_reset);
=20
 #endif /* _NET_BATMAN_ADV_ROUTING_H_ */
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 67c1c6c..3b4b2da 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -32,7 +32,8 @@ static void batadv_send_outstanding_bcast_packet(stru=
ct work_struct *work);
 /* send out an already prepared packet to the given address via the
  * specified batman interface
  */
-int batadv_send_skb_packet(struct sk_buff *skb, struct hard_iface *har=
d_iface,
+int batadv_send_skb_packet(struct sk_buff *skb,
+			   struct batadv_hard_iface *hard_iface,
 			   const uint8_t *dst_addr)
 {
 	struct ethhdr *ethhdr;
@@ -76,9 +77,9 @@ send_skb_err:
 	return NET_XMIT_DROP;
 }
=20
-void batadv_schedule_bat_ogm(struct hard_iface *hard_iface)
+void batadv_schedule_bat_ogm(struct batadv_hard_iface *hard_iface)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
+	struct batadv_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
=20
 	if ((hard_iface->if_status =3D=3D BATADV_IF_NOT_IN_USE) ||
 	    (hard_iface->if_status =3D=3D BATADV_IF_TO_BE_REMOVED))
@@ -96,7 +97,7 @@ void batadv_schedule_bat_ogm(struct hard_iface *hard_=
iface)
 	bat_priv->bat_algo_ops->bat_ogm_schedule(hard_iface);
 }
=20
-static void batadv_forw_packet_free(struct forw_packet *forw_packet)
+static void batadv_forw_packet_free(struct batadv_forw_packet *forw_pa=
cket)
 {
 	if (forw_packet->skb)
 		kfree_skb(forw_packet->skb);
@@ -105,9 +106,10 @@ static void batadv_forw_packet_free(struct forw_pa=
cket *forw_packet)
 	kfree(forw_packet);
 }
=20
-static void _batadv_add_bcast_packet_to_list(struct bat_priv *bat_priv=
,
-					     struct forw_packet *forw_packet,
-					     unsigned long send_time)
+static void
+_batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
+				 struct batadv_forw_packet *forw_packet,
+				 unsigned long send_time)
 {
 	INIT_HLIST_NODE(&forw_packet->list);
=20
@@ -132,12 +134,12 @@ static void _batadv_add_bcast_packet_to_list(stru=
ct bat_priv *bat_priv,
  * The skb is not consumed, so the caller should make sure that the
  * skb is freed.
  */
-int batadv_add_bcast_packet_to_list(struct bat_priv *bat_priv,
+int batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 				    const struct sk_buff *skb,
 				    unsigned long delay)
 {
-	struct hard_iface *primary_if =3D NULL;
-	struct forw_packet *forw_packet;
+	struct batadv_hard_iface *primary_if =3D NULL;
+	struct batadv_forw_packet *forw_packet;
 	struct batadv_bcast_packet *bcast_packet;
 	struct sk_buff *newskb;
=20
@@ -187,14 +189,18 @@ out:
=20
 static void batadv_send_outstanding_bcast_packet(struct work_struct *w=
ork)
 {
-	struct hard_iface *hard_iface;
+	struct batadv_hard_iface *hard_iface;
 	struct delayed_work *delayed_work =3D
 		container_of(work, struct delayed_work, work);
-	struct forw_packet *forw_packet =3D
-		container_of(delayed_work, struct forw_packet, delayed_work);
+	struct batadv_forw_packet *forw_packet;
 	struct sk_buff *skb1;
-	struct net_device *soft_iface =3D forw_packet->if_incoming->soft_ifac=
e;
-	struct bat_priv *bat_priv =3D netdev_priv(soft_iface);
+	struct net_device *soft_iface;
+	struct batadv_priv *bat_priv;
+
+	forw_packet =3D container_of(delayed_work, struct batadv_forw_packet,
+				   delayed_work);
+	soft_iface =3D forw_packet->if_incoming->soft_iface;
+	bat_priv =3D netdev_priv(soft_iface);
=20
 	spin_lock_bh(&bat_priv->forw_bcast_list_lock);
 	hlist_del(&forw_packet->list);
@@ -235,10 +241,11 @@ void batadv_send_outstanding_bat_ogm_packet(struc=
t work_struct *work)
 {
 	struct delayed_work *delayed_work =3D
 		container_of(work, struct delayed_work, work);
-	struct forw_packet *forw_packet =3D
-		container_of(delayed_work, struct forw_packet, delayed_work);
-	struct bat_priv *bat_priv;
+	struct batadv_forw_packet *forw_packet;
+	struct batadv_priv *bat_priv;
=20
+	forw_packet =3D container_of(delayed_work, struct batadv_forw_packet,
+				   delayed_work);
 	bat_priv =3D netdev_priv(forw_packet->if_incoming->soft_iface);
 	spin_lock_bh(&bat_priv->forw_bat_list_lock);
 	hlist_del(&forw_packet->list);
@@ -264,10 +271,11 @@ out:
 	batadv_forw_packet_free(forw_packet);
 }
=20
-void batadv_purge_outstanding_packets(struct bat_priv *bat_priv,
-				      const struct hard_iface *hard_iface)
+void
+batadv_purge_outstanding_packets(struct batadv_priv *bat_priv,
+				 const struct batadv_hard_iface *hard_iface)
 {
-	struct forw_packet *forw_packet;
+	struct batadv_forw_packet *forw_packet;
 	struct hlist_node *tmp_node, *safe_tmp_node;
 	bool pending;
=20
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index e3ac75b..643329b 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -20,14 +20,16 @@
 #ifndef _NET_BATMAN_ADV_SEND_H_
 #define _NET_BATMAN_ADV_SEND_H_
=20
-int batadv_send_skb_packet(struct sk_buff *skb, struct hard_iface *har=
d_iface,
+int batadv_send_skb_packet(struct sk_buff *skb,
+			   struct batadv_hard_iface *hard_iface,
 			   const uint8_t *dst_addr);
-void batadv_schedule_bat_ogm(struct hard_iface *hard_iface);
-int batadv_add_bcast_packet_to_list(struct bat_priv *bat_priv,
+void batadv_schedule_bat_ogm(struct batadv_hard_iface *hard_iface);
+int batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 				    const struct sk_buff *skb,
 				    unsigned long delay);
 void batadv_send_outstanding_bat_ogm_packet(struct work_struct *work);
-void batadv_purge_outstanding_packets(struct bat_priv *bat_priv,
-				      const struct hard_iface *hard_iface);
+void
+batadv_purge_outstanding_packets(struct batadv_priv *bat_priv,
+				 const struct batadv_hard_iface *hard_iface);
=20
 #endif /* _NET_BATMAN_ADV_SEND_H_ */
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 0a5d73a..7a7d821 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -92,13 +92,13 @@ static int batadv_interface_release(struct net_devi=
ce *dev)
=20
 static struct net_device_stats *batadv_interface_stats(struct net_devi=
ce *dev)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(dev);
+	struct batadv_priv *bat_priv =3D netdev_priv(dev);
 	return &bat_priv->stats;
 }
=20
 static int batadv_interface_set_mac_addr(struct net_device *dev, void =
*p)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(dev);
+	struct batadv_priv *bat_priv =3D netdev_priv(dev);
 	struct sockaddr *addr =3D p;
=20
 	if (!is_valid_ether_addr(addr->sa_data))
@@ -131,8 +131,8 @@ static int batadv_interface_tx(struct sk_buff *skb,
 			       struct net_device *soft_iface)
 {
 	struct ethhdr *ethhdr =3D (struct ethhdr *)skb->data;
-	struct bat_priv *bat_priv =3D netdev_priv(soft_iface);
-	struct hard_iface *primary_if =3D NULL;
+	struct batadv_priv *bat_priv =3D netdev_priv(soft_iface);
+	struct batadv_hard_iface *primary_if =3D NULL;
 	struct batadv_bcast_packet *bcast_packet;
 	struct vlan_ethhdr *vhdr;
 	__be16 ethertype =3D __constant_htons(BATADV_ETH_P_BATMAN);
@@ -260,10 +260,10 @@ end:
 }
=20
 void batadv_interface_rx(struct net_device *soft_iface,
-			 struct sk_buff *skb, struct hard_iface *recv_if,
+			 struct sk_buff *skb, struct batadv_hard_iface *recv_if,
 			 int hdr_size)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(soft_iface);
+	struct batadv_priv *bat_priv =3D netdev_priv(soft_iface);
 	struct ethhdr *ethhdr;
 	struct vlan_ethhdr *vhdr;
 	short vid __maybe_unused =3D -1;
@@ -338,7 +338,7 @@ static const struct net_device_ops batadv_netdev_op=
s =3D {
=20
 static void batadv_interface_setup(struct net_device *dev)
 {
-	struct bat_priv *priv =3D netdev_priv(dev);
+	struct batadv_priv *priv =3D netdev_priv(dev);
=20
 	ether_setup(dev);
=20
@@ -364,7 +364,7 @@ static void batadv_interface_setup(struct net_devic=
e *dev)
 struct net_device *batadv_softif_create(const char *name)
 {
 	struct net_device *soft_iface;
-	struct bat_priv *bat_priv;
+	struct batadv_priv *bat_priv;
 	int ret;
 	size_t cnt_len =3D sizeof(uint64_t) * BATADV_CNT_NUM;
=20
@@ -539,7 +539,7 @@ static void batadv_get_ethtool_stats(struct net_dev=
ice *dev,
 				     struct ethtool_stats *stats,
 				     uint64_t *data)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(dev);
+	struct batadv_priv *bat_priv =3D netdev_priv(dev);
 	int i;
=20
 	for (i =3D 0; i < BATADV_CNT_NUM; i++)
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-inte=
rface.h
index 2711ba5..852c683 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -22,7 +22,7 @@
=20
 int batadv_skb_head_push(struct sk_buff *skb, unsigned int len);
 void batadv_interface_rx(struct net_device *soft_iface, struct sk_buff=
 *skb,
-			 struct hard_iface *recv_if, int hdr_size);
+			 struct batadv_hard_iface *recv_if, int hdr_size);
 struct net_device *batadv_softif_create(const char *name);
 void batadv_softif_destroy(struct net_device *soft_iface);
 int batadv_softif_is_valid(const struct net_device *net_dev);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/transl=
ation-table.c
index 48217cc..245cc9a 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -29,34 +29,35 @@
=20
 #include <linux/crc16.h>
=20
-static void batadv_send_roam_adv(struct bat_priv *bat_priv, uint8_t *c=
lient,
-				 struct orig_node *orig_node);
+static void batadv_send_roam_adv(struct batadv_priv *bat_priv, uint8_t=
 *client,
+				 struct batadv_orig_node *orig_node);
 static void batadv_tt_purge(struct work_struct *work);
 static void
-batadv_tt_global_del_orig_list(struct tt_global_entry *tt_global_entry=
);
+batadv_tt_global_del_orig_list(struct batadv_tt_global_entry *tt_globa=
l_entry);
=20
 /* returns 1 if they are the same mac addr */
 static int batadv_compare_tt(const struct hlist_node *node, const void=
 *data2)
 {
-	const void *data1 =3D container_of(node, struct tt_common_entry,
+	const void *data1 =3D container_of(node, struct batadv_tt_common_entr=
y,
 					 hash_entry);
=20
 	return (memcmp(data1, data2, ETH_ALEN) =3D=3D 0 ? 1 : 0);
 }
=20
-static void batadv_tt_start_timer(struct bat_priv *bat_priv)
+static void batadv_tt_start_timer(struct batadv_priv *bat_priv)
 {
 	INIT_DELAYED_WORK(&bat_priv->tt_work, batadv_tt_purge);
 	queue_delayed_work(batadv_event_workqueue, &bat_priv->tt_work,
 			   msecs_to_jiffies(5000));
 }
=20
-static struct tt_common_entry *
+static struct batadv_tt_common_entry *
 batadv_tt_hash_find(struct batadv_hashtable *hash, const void *data)
 {
 	struct hlist_head *head;
 	struct hlist_node *node;
-	struct tt_common_entry *tt_common_entry, *tt_common_entry_tmp =3D NUL=
L;
+	struct batadv_tt_common_entry *tt_common_entry;
+	struct batadv_tt_common_entry *tt_common_entry_tmp =3D NULL;
 	uint32_t index;
=20
 	if (!hash)
@@ -81,35 +82,37 @@ batadv_tt_hash_find(struct batadv_hashtable *hash, =
const void *data)
 	return tt_common_entry_tmp;
 }
=20
-static struct tt_local_entry *
-batadv_tt_local_hash_find(struct bat_priv *bat_priv, const void *data)
+static struct batadv_tt_local_entry *
+batadv_tt_local_hash_find(struct batadv_priv *bat_priv, const void *da=
ta)
 {
-	struct tt_common_entry *tt_common_entry;
-	struct tt_local_entry *tt_local_entry =3D NULL;
+	struct batadv_tt_common_entry *tt_common_entry;
+	struct batadv_tt_local_entry *tt_local_entry =3D NULL;
=20
 	tt_common_entry =3D batadv_tt_hash_find(bat_priv->tt_local_hash, data=
);
 	if (tt_common_entry)
 		tt_local_entry =3D container_of(tt_common_entry,
-					      struct tt_local_entry, common);
+					      struct batadv_tt_local_entry,
+					      common);
 	return tt_local_entry;
 }
=20
-static struct tt_global_entry *
-batadv_tt_global_hash_find(struct bat_priv *bat_priv, const void *data=
)
+static struct batadv_tt_global_entry *
+batadv_tt_global_hash_find(struct batadv_priv *bat_priv, const void *d=
ata)
 {
-	struct tt_common_entry *tt_common_entry;
-	struct tt_global_entry *tt_global_entry =3D NULL;
+	struct batadv_tt_common_entry *tt_common_entry;
+	struct batadv_tt_global_entry *tt_global_entry =3D NULL;
=20
 	tt_common_entry =3D batadv_tt_hash_find(bat_priv->tt_global_hash, dat=
a);
 	if (tt_common_entry)
 		tt_global_entry =3D container_of(tt_common_entry,
-					       struct tt_global_entry, common);
+					       struct batadv_tt_global_entry,
+					       common);
 	return tt_global_entry;
=20
 }
=20
 static void
-batadv_tt_local_entry_free_ref(struct tt_local_entry *tt_local_entry)
+batadv_tt_local_entry_free_ref(struct batadv_tt_local_entry *tt_local_=
entry)
 {
 	if (atomic_dec_and_test(&tt_local_entry->common.refcount))
 		kfree_rcu(tt_local_entry, common.rcu);
@@ -117,18 +120,18 @@ batadv_tt_local_entry_free_ref(struct tt_local_en=
try *tt_local_entry)
=20
 static void batadv_tt_global_entry_free_rcu(struct rcu_head *rcu)
 {
-	struct tt_common_entry *tt_common_entry;
-	struct tt_global_entry *tt_global_entry;
+	struct batadv_tt_common_entry *tt_common_entry;
+	struct batadv_tt_global_entry *tt_global_entry;
=20
-	tt_common_entry =3D container_of(rcu, struct tt_common_entry, rcu);
-	tt_global_entry =3D container_of(tt_common_entry, struct tt_global_en=
try,
-				       common);
+	tt_common_entry =3D container_of(rcu, struct batadv_tt_common_entry, =
rcu);
+	tt_global_entry =3D container_of(tt_common_entry,
+				       struct batadv_tt_global_entry, common);
=20
 	kfree(tt_global_entry);
 }
=20
 static void
-batadv_tt_global_entry_free_ref(struct tt_global_entry *tt_global_entr=
y)
+batadv_tt_global_entry_free_ref(struct batadv_tt_global_entry *tt_glob=
al_entry)
 {
 	if (atomic_dec_and_test(&tt_global_entry->common.refcount)) {
 		batadv_tt_global_del_orig_list(tt_global_entry);
@@ -139,25 +142,25 @@ batadv_tt_global_entry_free_ref(struct tt_global_=
entry *tt_global_entry)
=20
 static void batadv_tt_orig_list_entry_free_rcu(struct rcu_head *rcu)
 {
-	struct tt_orig_list_entry *orig_entry;
+	struct batadv_tt_orig_list_entry *orig_entry;
=20
-	orig_entry =3D container_of(rcu, struct tt_orig_list_entry, rcu);
+	orig_entry =3D container_of(rcu, struct batadv_tt_orig_list_entry, rc=
u);
 	batadv_orig_node_free_ref(orig_entry->orig_node);
 	kfree(orig_entry);
 }
=20
 static void
-batadv_tt_orig_list_entry_free_ref(struct tt_orig_list_entry *orig_ent=
ry)
+batadv_tt_orig_list_entry_free_ref(struct batadv_tt_orig_list_entry *o=
rig_entry)
 {
 	/* to avoid race conditions, immediately decrease the tt counter */
 	atomic_dec(&orig_entry->orig_node->tt_size);
 	call_rcu(&orig_entry->rcu, batadv_tt_orig_list_entry_free_rcu);
 }
=20
-static void batadv_tt_local_event(struct bat_priv *bat_priv,
+static void batadv_tt_local_event(struct batadv_priv *bat_priv,
 				  const uint8_t *addr, uint8_t flags)
 {
-	struct tt_change_node *tt_change_node, *entry, *safe;
+	struct batadv_tt_change_node *tt_change_node, *entry, *safe;
 	bool event_removed =3D false;
 	bool del_op_requested, del_op_entry;
=20
@@ -215,7 +218,7 @@ int batadv_tt_len(int changes_num)
 	return changes_num * sizeof(struct batadv_tt_change);
 }
=20
-static int batadv_tt_local_init(struct bat_priv *bat_priv)
+static int batadv_tt_local_init(struct batadv_priv *bat_priv)
 {
 	if (bat_priv->tt_local_hash)
 		return 0;
@@ -231,12 +234,12 @@ static int batadv_tt_local_init(struct bat_priv *=
bat_priv)
 void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t =
*addr,
 			 int ifindex)
 {
-	struct bat_priv *bat_priv =3D netdev_priv(soft_iface);
-	struct tt_local_entry *tt_local_entry =3D NULL;
-	struct tt_global_entry *tt_global_entry =3D NULL;
+	struct batadv_priv *bat_priv =3D netdev_priv(soft_iface);
+	struct batadv_tt_local_entry *tt_local_entry =3D NULL;
+	struct batadv_tt_global_entry *tt_global_entry =3D NULL;
 	struct hlist_head *head;
 	struct hlist_node *node;
-	struct tt_orig_list_entry *orig_entry;
+	struct batadv_tt_orig_list_entry *orig_entry;
 	int hash_added;
=20
 	tt_local_entry =3D batadv_tt_local_hash_find(bat_priv, addr);
@@ -333,12 +336,12 @@ static void batadv_tt_realloc_packet_buff(unsigne=
d char **packet_buff,
 	}
 }
=20
-static void batadv_tt_prepare_packet_buff(struct bat_priv *bat_priv,
+static void batadv_tt_prepare_packet_buff(struct batadv_priv *bat_priv=
,
 					  unsigned char **packet_buff,
 					  int *packet_buff_len,
 					  int min_packet_len)
 {
-	struct hard_iface *primary_if;
+	struct batadv_hard_iface *primary_if;
 	int req_len;
=20
 	primary_if =3D batadv_primary_if_get_selected(bat_priv);
@@ -359,12 +362,12 @@ static void batadv_tt_prepare_packet_buff(struct =
bat_priv *bat_priv,
 		batadv_hardif_free_ref(primary_if);
 }
=20
-static int batadv_tt_changes_fill_buff(struct bat_priv *bat_priv,
+static int batadv_tt_changes_fill_buff(struct batadv_priv *bat_priv,
 				       unsigned char **packet_buff,
 				       int *packet_buff_len,
 				       int min_packet_len)
 {
-	struct tt_change_node *entry, *safe;
+	struct batadv_tt_change_node *entry, *safe;
 	int count =3D 0, tot_changes =3D 0, new_len;
 	unsigned char *tt_buff;
=20
@@ -416,10 +419,10 @@ static int batadv_tt_changes_fill_buff(struct bat=
_priv *bat_priv,
 int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct net_device *net_dev =3D (struct net_device *)seq->private;
-	struct bat_priv *bat_priv =3D netdev_priv(net_dev);
+	struct batadv_priv *bat_priv =3D netdev_priv(net_dev);
 	struct batadv_hashtable *hash =3D bat_priv->tt_local_hash;
-	struct tt_common_entry *tt_common_entry;
-	struct hard_iface *primary_if;
+	struct batadv_tt_common_entry *tt_common_entry;
+	struct batadv_hard_iface *primary_if;
 	struct hlist_node *node;
 	struct hlist_head *head;
 	uint32_t i;
@@ -471,9 +474,10 @@ out:
 	return ret;
 }
=20
-static void batadv_tt_local_set_pending(struct bat_priv *bat_priv,
-					struct tt_local_entry *tt_local_entry,
-					uint16_t flags, const char *message)
+static void
+batadv_tt_local_set_pending(struct batadv_priv *bat_priv,
+			    struct batadv_tt_local_entry *tt_local_entry,
+			    uint16_t flags, const char *message)
 {
 	batadv_tt_local_event(bat_priv, tt_local_entry->common.addr,
 			      tt_local_entry->common.flags | flags);
@@ -489,10 +493,10 @@ static void batadv_tt_local_set_pending(struct ba=
t_priv *bat_priv,
 		   tt_local_entry->common.addr, message);
 }
=20
-void batadv_tt_local_remove(struct bat_priv *bat_priv, const uint8_t *=
addr,
+void batadv_tt_local_remove(struct batadv_priv *bat_priv, const uint8_=
t *addr,
 			    const char *message, bool roaming)
 {
-	struct tt_local_entry *tt_local_entry =3D NULL;
+	struct batadv_tt_local_entry *tt_local_entry =3D NULL;
 	uint16_t flags;
=20
 	tt_local_entry =3D batadv_tt_local_hash_find(bat_priv, addr);
@@ -509,17 +513,18 @@ out:
 		batadv_tt_local_entry_free_ref(tt_local_entry);
 }
=20
-static void batadv_tt_local_purge_list(struct bat_priv *bat_priv,
+static void batadv_tt_local_purge_list(struct batadv_priv *bat_priv,
 				       struct hlist_head *head)
 {
-	struct tt_local_entry *tt_local_entry;
-	struct tt_common_entry *tt_common_entry;
+	struct batadv_tt_local_entry *tt_local_entry;
+	struct batadv_tt_common_entry *tt_common_entry;
 	struct hlist_node *node, *node_tmp;
=20
 	hlist_for_each_entry_safe(tt_common_entry, node, node_tmp, head,
 				  hash_entry) {
 		tt_local_entry =3D container_of(tt_common_entry,
-					      struct tt_local_entry, common);
+					      struct batadv_tt_local_entry,
+					      common);
 		if (tt_local_entry->common.flags & BATADV_TT_CLIENT_NOPURGE)
 			continue;
=20
@@ -536,7 +541,7 @@ static void batadv_tt_local_purge_list(struct bat_p=
riv *bat_priv,
 	}
 }
=20
-static void batadv_tt_local_purge(struct bat_priv *bat_priv)
+static void batadv_tt_local_purge(struct batadv_priv *bat_priv)
 {
 	struct batadv_hashtable *hash =3D bat_priv->tt_local_hash;
 	struct hlist_head *head;
@@ -554,12 +559,12 @@ static void batadv_tt_local_purge(struct bat_priv=
 *bat_priv)
=20
 }
=20
-static void batadv_tt_local_table_free(struct bat_priv *bat_priv)
+static void batadv_tt_local_table_free(struct batadv_priv *bat_priv)
 {
 	struct batadv_hashtable *hash;
 	spinlock_t *list_lock; /* protects write access to the hash lists */
-	struct tt_common_entry *tt_common_entry;
-	struct tt_local_entry *tt_local_entry;
+	struct batadv_tt_common_entry *tt_common_entry;
+	struct batadv_tt_local_entry *tt_local;
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
 	uint32_t i;
@@ -577,10 +582,10 @@ static void batadv_tt_local_table_free(struct bat=
_priv *bat_priv)
 		hlist_for_each_entry_safe(tt_common_entry, node, node_tmp,
 					  head, hash_entry) {
 			hlist_del_rcu(node);
-			tt_local_entry =3D container_of(tt_common_entry,
-						      struct tt_local_entry,
-						      common);
-			batadv_tt_local_entry_free_ref(tt_local_entry);
+			tt_local =3D container_of(tt_common_entry,
+						struct batadv_tt_local_entry,
+						common);
+			batadv_tt_local_entry_free_ref(tt_local);
 		}
 		spin_unlock_bh(list_lock);
 	}
@@ -590,7 +595,7 @@ static void batadv_tt_local_table_free(struct bat_p=
riv *bat_priv)
 	bat_priv->tt_local_hash =3D NULL;
 }
=20
-static int batadv_tt_global_init(struct bat_priv *bat_priv)
+static int batadv_tt_global_init(struct batadv_priv *bat_priv)
 {
 	if (bat_priv->tt_global_hash)
 		return 0;
@@ -603,9 +608,9 @@ static int batadv_tt_global_init(struct bat_priv *b=
at_priv)
 	return 0;
 }
=20
-static void batadv_tt_changes_list_free(struct bat_priv *bat_priv)
+static void batadv_tt_changes_list_free(struct batadv_priv *bat_priv)
 {
-	struct tt_change_node *entry, *safe;
+	struct batadv_tt_change_node *entry, *safe;
=20
 	spin_lock_bh(&bat_priv->tt_changes_list_lock);
=20
@@ -622,10 +627,11 @@ static void batadv_tt_changes_list_free(struct ba=
t_priv *bat_priv)
 /* find out if an orig_node is already in the list of a tt_global_entr=
y.
  * returns 1 if found, 0 otherwise
  */
-static bool batadv_tt_global_entry_has_orig(const struct tt_global_ent=
ry *entry,
-					    const struct orig_node *orig_node)
+static bool
+batadv_tt_global_entry_has_orig(const struct batadv_tt_global_entry *e=
ntry,
+				const struct batadv_orig_node *orig_node)
 {
-	struct tt_orig_list_entry *tmp_orig_entry;
+	struct batadv_tt_orig_list_entry *tmp_orig_entry;
 	const struct hlist_head *head;
 	struct hlist_node *node;
 	bool found =3D false;
@@ -643,10 +649,10 @@ static bool batadv_tt_global_entry_has_orig(const=
 struct tt_global_entry *entry,
 }
=20
 static void
-batadv_tt_global_add_orig_entry(struct tt_global_entry *tt_global_entr=
y,
-				struct orig_node *orig_node, int ttvn)
+batadv_tt_global_add_orig_entry(struct batadv_tt_global_entry *tt_glob=
al_entry,
+				struct batadv_orig_node *orig_node, int ttvn)
 {
-	struct tt_orig_list_entry *orig_entry;
+	struct batadv_tt_orig_list_entry *orig_entry;
=20
 	orig_entry =3D kzalloc(sizeof(*orig_entry), GFP_ATOMIC);
 	if (!orig_entry)
@@ -665,14 +671,15 @@ batadv_tt_global_add_orig_entry(struct tt_global_=
entry *tt_global_entry,
 }
=20
 /* caller must hold orig_node refcount */
-int batadv_tt_global_add(struct bat_priv *bat_priv, struct orig_node *=
orig_node,
+int batadv_tt_global_add(struct batadv_priv *bat_priv,
+			 struct batadv_orig_node *orig_node,
 			 const unsigned char *tt_addr, uint8_t flags,
 			 uint8_t ttvn)
 {
-	struct tt_global_entry *tt_global_entry =3D NULL;
+	struct batadv_tt_global_entry *tt_global_entry =3D NULL;
 	int ret =3D 0;
 	int hash_added;
-	struct tt_common_entry *common;
+	struct batadv_tt_common_entry *common;
=20
 	tt_global_entry =3D batadv_tt_global_hash_find(bat_priv, tt_addr);
=20
@@ -746,13 +753,13 @@ out:
  * it is assumed that the caller holds rcu_read_lock();
  */
 static void
-batadv_tt_global_print_entry(struct tt_global_entry *tt_global_entry,
+batadv_tt_global_print_entry(struct batadv_tt_global_entry *tt_global_=
entry,
 			     struct seq_file *seq)
 {
 	struct hlist_head *head;
 	struct hlist_node *node;
-	struct tt_orig_list_entry *orig_entry;
-	struct tt_common_entry *tt_common_entry;
+	struct batadv_tt_orig_list_entry *orig_entry;
+	struct batadv_tt_common_entry *tt_common_entry;
 	uint16_t flags;
 	uint8_t last_ttvn;
=20
@@ -774,11 +781,11 @@ batadv_tt_global_print_entry(struct tt_global_ent=
ry *tt_global_entry,
 int batadv_tt_global_seq_print_text(struct seq_file *seq, void *offset=
)
 {
 	struct net_device *net_dev =3D (struct net_device *)seq->private;
-	struct bat_priv *bat_priv =3D netdev_priv(net_dev);
+	struct batadv_priv *bat_priv =3D netdev_priv(net_dev);
 	struct batadv_hashtable *hash =3D bat_priv->tt_global_hash;
-	struct tt_common_entry *tt_common_entry;
-	struct tt_global_entry *tt_global_entry;
-	struct hard_iface *primary_if;
+	struct batadv_tt_common_entry *tt_common_entry;
+	struct batadv_tt_global_entry *tt_global;
+	struct batadv_hard_iface *primary_if;
 	struct hlist_node *node;
 	struct hlist_head *head;
 	uint32_t i;
@@ -811,10 +818,10 @@ int batadv_tt_global_seq_print_text(struct seq_fi=
le *seq, void *offset)
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(tt_common_entry, node,
 					 head, hash_entry) {
-			tt_global_entry =3D container_of(tt_common_entry,
-						       struct tt_global_entry,
-						       common);
-			batadv_tt_global_print_entry(tt_global_entry, seq);
+			tt_global =3D container_of(tt_common_entry,
+						 struct batadv_tt_global_entry,
+						 common);
+			batadv_tt_global_print_entry(tt_global, seq);
 		}
 		rcu_read_unlock();
 	}
@@ -826,11 +833,11 @@ out:
=20
 /* deletes the orig list of a tt_global_entry */
 static void
-batadv_tt_global_del_orig_list(struct tt_global_entry *tt_global_entry=
)
+batadv_tt_global_del_orig_list(struct batadv_tt_global_entry *tt_globa=
l_entry)
 {
 	struct hlist_head *head;
 	struct hlist_node *node, *safe;
-	struct tt_orig_list_entry *orig_entry;
+	struct batadv_tt_orig_list_entry *orig_entry;
=20
 	spin_lock_bh(&tt_global_entry->list_lock);
 	head =3D &tt_global_entry->orig_list;
@@ -843,14 +850,14 @@ batadv_tt_global_del_orig_list(struct tt_global_e=
ntry *tt_global_entry)
 }
=20
 static void
-batadv_tt_global_del_orig_entry(struct bat_priv *bat_priv,
-				struct tt_global_entry *tt_global_entry,
-				struct orig_node *orig_node,
+batadv_tt_global_del_orig_entry(struct batadv_priv *bat_priv,
+				struct batadv_tt_global_entry *tt_global_entry,
+				struct batadv_orig_node *orig_node,
 				const char *message)
 {
 	struct hlist_head *head;
 	struct hlist_node *node, *safe;
-	struct tt_orig_list_entry *orig_entry;
+	struct batadv_tt_orig_list_entry *orig_entry;
=20
 	spin_lock_bh(&tt_global_entry->list_lock);
 	head =3D &tt_global_entry->orig_list;
@@ -867,9 +874,10 @@ batadv_tt_global_del_orig_entry(struct bat_priv *b=
at_priv,
 	spin_unlock_bh(&tt_global_entry->list_lock);
 }
=20
-static void batadv_tt_global_del_struct(struct bat_priv *bat_priv,
-					struct tt_global_entry *tt_global_entry,
-					const char *message)
+static void
+batadv_tt_global_del_struct(struct batadv_priv *bat_priv,
+			    struct batadv_tt_global_entry *tt_global_entry,
+			    const char *message)
 {
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Deleting global tt entry %pM: %s\n",
@@ -886,14 +894,15 @@ static void batadv_tt_global_del_struct(struct ba=
t_priv *bat_priv,
  * timer, otherwise we simply remove the originator scheduled for dele=
tion.
  */
 static void
-batadv_tt_global_del_roaming(struct bat_priv *bat_priv,
-			     struct tt_global_entry *tt_global_entry,
-			     struct orig_node *orig_node, const char *message)
+batadv_tt_global_del_roaming(struct batadv_priv *bat_priv,
+			     struct batadv_tt_global_entry *tt_global_entry,
+			     struct batadv_orig_node *orig_node,
+			     const char *message)
 {
 	bool last_entry =3D true;
 	struct hlist_head *head;
 	struct hlist_node *node;
-	struct tt_orig_list_entry *orig_entry;
+	struct batadv_tt_orig_list_entry *orig_entry;
=20
 	/* no local entry exists, case 1:
 	 * Check if this is the last one or if other entries exist.
@@ -923,13 +932,13 @@ batadv_tt_global_del_roaming(struct bat_priv *bat=
_priv,
=20
=20
=20
-static void batadv_tt_global_del(struct bat_priv *bat_priv,
-				 struct orig_node *orig_node,
+static void batadv_tt_global_del(struct batadv_priv *bat_priv,
+				 struct batadv_orig_node *orig_node,
 				 const unsigned char *addr,
 				 const char *message, bool roaming)
 {
-	struct tt_global_entry *tt_global_entry =3D NULL;
-	struct tt_local_entry *local_entry =3D NULL;
+	struct batadv_tt_global_entry *tt_global_entry =3D NULL;
+	struct batadv_tt_local_entry *local_entry =3D NULL;
=20
 	tt_global_entry =3D batadv_tt_global_hash_find(bat_priv, addr);
 	if (!tt_global_entry)
@@ -978,11 +987,12 @@ out:
 		batadv_tt_local_entry_free_ref(local_entry);
 }
=20
-void batadv_tt_global_del_orig(struct bat_priv *bat_priv,
-			       struct orig_node *orig_node, const char *message)
+void batadv_tt_global_del_orig(struct batadv_priv *bat_priv,
+			       struct batadv_orig_node *orig_node,
+			       const char *message)
 {
-	struct tt_global_entry *global_entry;
-	struct tt_common_entry *tt_common_entry;
+	struct batadv_tt_global_entry *tt_global;
+	struct batadv_tt_common_entry *tt_common_entry;
 	uint32_t i;
 	struct batadv_hashtable *hash =3D bat_priv->tt_global_hash;
 	struct hlist_node *node, *safe;
@@ -999,19 +1009,19 @@ void batadv_tt_global_del_orig(struct bat_priv *=
bat_priv,
 		spin_lock_bh(list_lock);
 		hlist_for_each_entry_safe(tt_common_entry, node, safe,
 					  head, hash_entry) {
-			global_entry =3D container_of(tt_common_entry,
-						    struct tt_global_entry,
-						    common);
+			tt_global =3D container_of(tt_common_entry,
+						 struct batadv_tt_global_entry,
+						 common);
=20
-			batadv_tt_global_del_orig_entry(bat_priv, global_entry,
+			batadv_tt_global_del_orig_entry(bat_priv, tt_global,
 							orig_node, message);
=20
-			if (hlist_empty(&global_entry->orig_list)) {
+			if (hlist_empty(&tt_global->orig_list)) {
 				batadv_dbg(BATADV_DBG_TT, bat_priv,
 					   "Deleting global tt entry %pM: %s\n",
-					   global_entry->common.addr, message);
+					   tt_global->common.addr, message);
 				hlist_del_rcu(node);
-				batadv_tt_global_entry_free_ref(global_entry);
+				batadv_tt_global_entry_free_ref(tt_global);
 			}
 		}
 		spin_unlock_bh(list_lock);
@@ -1019,17 +1029,18 @@ void batadv_tt_global_del_orig(struct bat_priv =
*bat_priv,
 	orig_node->tt_initialised =3D false;
 }
=20
-static void batadv_tt_global_roam_purge_list(struct bat_priv *bat_priv=
,
+static void batadv_tt_global_roam_purge_list(struct batadv_priv *bat_p=
riv,
 					     struct hlist_head *head)
 {
-	struct tt_common_entry *tt_common_entry;
-	struct tt_global_entry *tt_global_entry;
+	struct batadv_tt_common_entry *tt_common_entry;
+	struct batadv_tt_global_entry *tt_global_entry;
 	struct hlist_node *node, *node_tmp;
=20
 	hlist_for_each_entry_safe(tt_common_entry, node, node_tmp, head,
 				  hash_entry) {
 		tt_global_entry =3D container_of(tt_common_entry,
-					       struct tt_global_entry, common);
+					       struct batadv_tt_global_entry,
+					       common);
 		if (!(tt_global_entry->common.flags & BATADV_TT_CLIENT_ROAM))
 			continue;
 		if (!batadv_has_timed_out(tt_global_entry->roam_at,
@@ -1045,7 +1056,7 @@ static void batadv_tt_global_roam_purge_list(stru=
ct bat_priv *bat_priv,
 	}
 }
=20
-static void batadv_tt_global_roam_purge(struct bat_priv *bat_priv)
+static void batadv_tt_global_roam_purge(struct batadv_priv *bat_priv)
 {
 	struct batadv_hashtable *hash =3D bat_priv->tt_global_hash;
 	struct hlist_head *head;
@@ -1063,12 +1074,12 @@ static void batadv_tt_global_roam_purge(struct =
bat_priv *bat_priv)
=20
 }
=20
-static void batadv_tt_global_table_free(struct bat_priv *bat_priv)
+static void batadv_tt_global_table_free(struct batadv_priv *bat_priv)
 {
 	struct batadv_hashtable *hash;
 	spinlock_t *list_lock; /* protects write access to the hash lists */
-	struct tt_common_entry *tt_common_entry;
-	struct tt_global_entry *tt_global_entry;
+	struct batadv_tt_common_entry *tt_common_entry;
+	struct batadv_tt_global_entry *tt_global;
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
 	uint32_t i;
@@ -1086,10 +1097,10 @@ static void batadv_tt_global_table_free(struct =
bat_priv *bat_priv)
 		hlist_for_each_entry_safe(tt_common_entry, node, node_tmp,
 					  head, hash_entry) {
 			hlist_del_rcu(node);
-			tt_global_entry =3D container_of(tt_common_entry,
-						       struct tt_global_entry,
-						       common);
-			batadv_tt_global_entry_free_ref(tt_global_entry);
+			tt_global =3D container_of(tt_common_entry,
+						 struct batadv_tt_global_entry,
+						 common);
+			batadv_tt_global_entry_free_ref(tt_global);
 		}
 		spin_unlock_bh(list_lock);
 	}
@@ -1099,8 +1110,9 @@ static void batadv_tt_global_table_free(struct ba=
t_priv *bat_priv)
 	bat_priv->tt_global_hash =3D NULL;
 }
=20
-static bool _batadv_is_ap_isolated(struct tt_local_entry *tt_local_ent=
ry,
-				   struct tt_global_entry *tt_global_entry)
+static bool
+_batadv_is_ap_isolated(struct batadv_tt_local_entry *tt_local_entry,
+		       struct batadv_tt_global_entry *tt_global_entry)
 {
 	bool ret =3D false;
=20
@@ -1111,17 +1123,17 @@ static bool _batadv_is_ap_isolated(struct tt_lo=
cal_entry *tt_local_entry,
 	return ret;
 }
=20
-struct orig_node *batadv_transtable_search(struct bat_priv *bat_priv,
-					   const uint8_t *src,
-					   const uint8_t *addr)
+struct batadv_orig_node *batadv_transtable_search(struct batadv_priv *=
bat_priv,
+						  const uint8_t *src,
+						  const uint8_t *addr)
 {
-	struct tt_local_entry *tt_local_entry =3D NULL;
-	struct tt_global_entry *tt_global_entry =3D NULL;
-	struct orig_node *orig_node =3D NULL;
-	struct neigh_node *router =3D NULL;
+	struct batadv_tt_local_entry *tt_local_entry =3D NULL;
+	struct batadv_tt_global_entry *tt_global_entry =3D NULL;
+	struct batadv_orig_node *orig_node =3D NULL;
+	struct batadv_neigh_node *router =3D NULL;
 	struct hlist_head *head;
 	struct hlist_node *node;
-	struct tt_orig_list_entry *orig_entry;
+	struct batadv_tt_orig_list_entry *orig_entry;
 	int best_tq;
=20
 	if (src && atomic_read(&bat_priv->ap_isolation)) {
@@ -1170,13 +1182,13 @@ out:
 }
=20
 /* Calculates the checksum of the local table of a given orig_node */
-static uint16_t batadv_tt_global_crc(struct bat_priv *bat_priv,
-				     struct orig_node *orig_node)
+static uint16_t batadv_tt_global_crc(struct batadv_priv *bat_priv,
+				     struct batadv_orig_node *orig_node)
 {
 	uint16_t total =3D 0, total_one;
 	struct batadv_hashtable *hash =3D bat_priv->tt_global_hash;
-	struct tt_common_entry *tt_common;
-	struct tt_global_entry *tt_global_entry;
+	struct batadv_tt_common_entry *tt_common;
+	struct batadv_tt_global_entry *tt_global;
 	struct hlist_node *node;
 	struct hlist_head *head;
 	uint32_t i;
@@ -1187,9 +1199,9 @@ static uint16_t batadv_tt_global_crc(struct bat_p=
riv *bat_priv,
=20
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(tt_common, node, head, hash_entry) {
-			tt_global_entry =3D container_of(tt_common,
-						       struct tt_global_entry,
-						       common);
+			tt_global =3D container_of(tt_common,
+						 struct batadv_tt_global_entry,
+						 common);
 			/* Roaming clients are in the global table for
 			 * consistency only. They don't have to be
 			 * taken into account while computing the
@@ -1201,7 +1213,7 @@ static uint16_t batadv_tt_global_crc(struct bat_p=
riv *bat_priv,
 			/* find out if this global entry is announced by this
 			 * originator
 			 */
-			if (!batadv_tt_global_entry_has_orig(tt_global_entry,
+			if (!batadv_tt_global_entry_has_orig(tt_global,
 							     orig_node))
 				continue;
=20
@@ -1218,11 +1230,11 @@ static uint16_t batadv_tt_global_crc(struct bat=
_priv *bat_priv,
 }
=20
 /* Calculates the checksum of the local table */
-static uint16_t batadv_tt_local_crc(struct bat_priv *bat_priv)
+static uint16_t batadv_tt_local_crc(struct batadv_priv *bat_priv)
 {
 	uint16_t total =3D 0, total_one;
 	struct batadv_hashtable *hash =3D bat_priv->tt_local_hash;
-	struct tt_common_entry *tt_common;
+	struct batadv_tt_common_entry *tt_common;
 	struct hlist_node *node;
 	struct hlist_head *head;
 	uint32_t i;
@@ -1250,9 +1262,9 @@ static uint16_t batadv_tt_local_crc(struct bat_pr=
iv *bat_priv)
 	return total;
 }
=20
-static void batadv_tt_req_list_free(struct bat_priv *bat_priv)
+static void batadv_tt_req_list_free(struct batadv_priv *bat_priv)
 {
-	struct tt_req_node *node, *safe;
+	struct batadv_tt_req_node *node, *safe;
=20
 	spin_lock_bh(&bat_priv->tt_req_list_lock);
=20
@@ -1264,8 +1276,8 @@ static void batadv_tt_req_list_free(struct bat_pr=
iv *bat_priv)
 	spin_unlock_bh(&bat_priv->tt_req_list_lock);
 }
=20
-static void batadv_tt_save_orig_buffer(struct bat_priv *bat_priv,
-				       struct orig_node *orig_node,
+static void batadv_tt_save_orig_buffer(struct batadv_priv *bat_priv,
+				       struct batadv_orig_node *orig_node,
 				       const unsigned char *tt_buff,
 				       uint8_t tt_num_changes)
 {
@@ -1287,9 +1299,9 @@ static void batadv_tt_save_orig_buffer(struct bat=
_priv *bat_priv,
 	spin_unlock_bh(&orig_node->tt_buff_lock);
 }
=20
-static void batadv_tt_req_purge(struct bat_priv *bat_priv)
+static void batadv_tt_req_purge(struct batadv_priv *bat_priv)
 {
-	struct tt_req_node *node, *safe;
+	struct batadv_tt_req_node *node, *safe;
=20
 	spin_lock_bh(&bat_priv->tt_req_list_lock);
 	list_for_each_entry_safe(node, safe, &bat_priv->tt_req_list, list) {
@@ -1305,10 +1317,11 @@ static void batadv_tt_req_purge(struct bat_priv=
 *bat_priv)
 /* returns the pointer to the new tt_req_node struct if no request
  * has already been issued for this orig_node, NULL otherwise
  */
-static struct tt_req_node *batadv_new_tt_req_node(struct bat_priv *bat=
_priv,
-						  struct orig_node *orig_node)
+static struct batadv_tt_req_node *
+batadv_new_tt_req_node(struct batadv_priv *bat_priv,
+		       struct batadv_orig_node *orig_node)
 {
-	struct tt_req_node *tt_req_node_tmp, *tt_req_node =3D NULL;
+	struct batadv_tt_req_node *tt_req_node_tmp, *tt_req_node =3D NULL;
=20
 	spin_lock_bh(&bat_priv->tt_req_list_lock);
 	list_for_each_entry(tt_req_node_tmp, &bat_priv->tt_req_list, list) {
@@ -1335,7 +1348,7 @@ unlock:
 static int batadv_tt_local_valid_entry(const void *entry_ptr,
 				       const void *data_ptr)
 {
-	const struct tt_common_entry *tt_common_entry =3D entry_ptr;
+	const struct batadv_tt_common_entry *tt_common_entry =3D entry_ptr;
=20
 	if (tt_common_entry->flags & BATADV_TT_CLIENT_NEW)
 		return 0;
@@ -1345,14 +1358,15 @@ static int batadv_tt_local_valid_entry(const vo=
id *entry_ptr,
 static int batadv_tt_global_valid(const void *entry_ptr,
 				  const void *data_ptr)
 {
-	const struct tt_common_entry *tt_common_entry =3D entry_ptr;
-	const struct tt_global_entry *tt_global_entry;
-	const struct orig_node *orig_node =3D data_ptr;
+	const struct batadv_tt_common_entry *tt_common_entry =3D entry_ptr;
+	const struct batadv_tt_global_entry *tt_global_entry;
+	const struct batadv_orig_node *orig_node =3D data_ptr;
=20
 	if (tt_common_entry->flags & BATADV_TT_CLIENT_ROAM)
 		return 0;
=20
-	tt_global_entry =3D container_of(tt_common_entry, struct tt_global_en=
try,
+	tt_global_entry =3D container_of(tt_common_entry,
+				       struct batadv_tt_global_entry,
 				       common);
=20
 	return batadv_tt_global_entry_has_orig(tt_global_entry, orig_node);
@@ -1361,11 +1375,11 @@ static int batadv_tt_global_valid(const void *e=
ntry_ptr,
 static struct sk_buff *
 batadv_tt_response_fill_table(uint16_t tt_len, uint8_t ttvn,
 			      struct batadv_hashtable *hash,
-			      struct hard_iface *primary_if,
+			      struct batadv_hard_iface *primary_if,
 			      int (*valid_cb)(const void *, const void *),
 			      void *cb_data)
 {
-	struct tt_common_entry *tt_common_entry;
+	struct batadv_tt_common_entry *tt_common_entry;
 	struct batadv_tt_query_packet *tt_response;
 	struct batadv_tt_change *tt_change;
 	struct hlist_node *node;
@@ -1425,16 +1439,16 @@ out:
 	return skb;
 }
=20
-static int batadv_send_tt_request(struct bat_priv *bat_priv,
-				  struct orig_node *dst_orig_node,
+static int batadv_send_tt_request(struct batadv_priv *bat_priv,
+				  struct batadv_orig_node *dst_orig_node,
 				  uint8_t ttvn, uint16_t tt_crc,
 				  bool full_table)
 {
 	struct sk_buff *skb =3D NULL;
 	struct batadv_tt_query_packet *tt_request;
-	struct neigh_node *neigh_node =3D NULL;
-	struct hard_iface *primary_if;
-	struct tt_req_node *tt_req_node =3D NULL;
+	struct batadv_neigh_node *neigh_node =3D NULL;
+	struct batadv_hard_iface *primary_if;
+	struct batadv_tt_req_node *tt_req_node =3D NULL;
 	int ret =3D 1;
 	size_t tt_req_len;
=20
@@ -1501,12 +1515,13 @@ out:
 }
=20
 static bool
-batadv_send_other_tt_response(struct bat_priv *bat_priv,
+batadv_send_other_tt_response(struct batadv_priv *bat_priv,
 			      struct batadv_tt_query_packet *tt_request)
 {
-	struct orig_node *req_dst_orig_node =3D NULL, *res_dst_orig_node =3D =
NULL;
-	struct neigh_node *neigh_node =3D NULL;
-	struct hard_iface *primary_if =3D NULL;
+	struct batadv_orig_node *req_dst_orig_node =3D NULL;
+	struct batadv_orig_node *res_dst_orig_node =3D NULL;
+	struct batadv_neigh_node *neigh_node =3D NULL;
+	struct batadv_hard_iface *primary_if =3D NULL;
 	uint8_t orig_ttvn, req_ttvn, ttvn;
 	int ret =3D false;
 	unsigned char *tt_buff;
@@ -1634,12 +1649,12 @@ out:
 }
=20
 static bool
-batadv_send_my_tt_response(struct bat_priv *bat_priv,
+batadv_send_my_tt_response(struct batadv_priv *bat_priv,
 			   struct batadv_tt_query_packet *tt_request)
 {
-	struct orig_node *orig_node =3D NULL;
-	struct neigh_node *neigh_node =3D NULL;
-	struct hard_iface *primary_if =3D NULL;
+	struct batadv_orig_node *orig_node =3D NULL;
+	struct batadv_neigh_node *neigh_node =3D NULL;
+	struct batadv_hard_iface *primary_if =3D NULL;
 	uint8_t my_ttvn, req_ttvn, ttvn;
 	int ret =3D false;
 	unsigned char *tt_buff;
@@ -1754,7 +1769,7 @@ out:
 	return true;
 }
=20
-bool batadv_send_tt_response(struct bat_priv *bat_priv,
+bool batadv_send_tt_response(struct batadv_priv *bat_priv,
 			     struct batadv_tt_query_packet *tt_request)
 {
 	if (batadv_is_my_mac(tt_request->dst)) {
@@ -1768,8 +1783,8 @@ bool batadv_send_tt_response(struct bat_priv *bat=
_priv,
 	}
 }
=20
-static void _batadv_tt_update_changes(struct bat_priv *bat_priv,
-				      struct orig_node *orig_node,
+static void _batadv_tt_update_changes(struct batadv_priv *bat_priv,
+				      struct batadv_orig_node *orig_node,
 				      struct batadv_tt_change *tt_change,
 				      uint16_t tt_num_changes, uint8_t ttvn)
 {
@@ -1799,10 +1814,10 @@ static void _batadv_tt_update_changes(struct ba=
t_priv *bat_priv,
 	orig_node->tt_initialised =3D true;
 }
=20
-static void batadv_tt_fill_gtable(struct bat_priv *bat_priv,
+static void batadv_tt_fill_gtable(struct batadv_priv *bat_priv,
 				  struct batadv_tt_query_packet *tt_response)
 {
-	struct orig_node *orig_node =3D NULL;
+	struct batadv_orig_node *orig_node =3D NULL;
=20
 	orig_node =3D batadv_orig_hash_find(bat_priv, tt_response->src);
 	if (!orig_node)
@@ -1829,8 +1844,8 @@ out:
 		batadv_orig_node_free_ref(orig_node);
 }
=20
-static void batadv_tt_update_changes(struct bat_priv *bat_priv,
-				     struct orig_node *orig_node,
+static void batadv_tt_update_changes(struct batadv_priv *bat_priv,
+				     struct batadv_orig_node *orig_node,
 				     uint16_t tt_num_changes, uint8_t ttvn,
 				     struct batadv_tt_change *tt_change)
 {
@@ -1842,9 +1857,9 @@ static void batadv_tt_update_changes(struct bat_p=
riv *bat_priv,
 	atomic_set(&orig_node->last_ttvn, ttvn);
 }
=20
-bool batadv_is_my_client(struct bat_priv *bat_priv, const uint8_t *add=
r)
+bool batadv_is_my_client(struct batadv_priv *bat_priv, const uint8_t *=
addr)
 {
-	struct tt_local_entry *tt_local_entry =3D NULL;
+	struct batadv_tt_local_entry *tt_local_entry =3D NULL;
 	bool ret =3D false;
=20
 	tt_local_entry =3D batadv_tt_local_hash_find(bat_priv, addr);
@@ -1862,11 +1877,11 @@ out:
 	return ret;
 }
=20
-void batadv_handle_tt_response(struct bat_priv *bat_priv,
+void batadv_handle_tt_response(struct batadv_priv *bat_priv,
 			       struct batadv_tt_query_packet *tt_response)
 {
-	struct tt_req_node *node, *safe;
-	struct orig_node *orig_node =3D NULL;
+	struct batadv_tt_req_node *node, *safe;
+	struct batadv_orig_node *orig_node =3D NULL;
 	struct batadv_tt_change *tt_change;
=20
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
@@ -1913,7 +1928,7 @@ out:
 		batadv_orig_node_free_ref(orig_node);
 }
=20
-int batadv_tt_init(struct bat_priv *bat_priv)
+int batadv_tt_init(struct batadv_priv *bat_priv)
 {
 	int ret;
=20
@@ -1930,9 +1945,9 @@ int batadv_tt_init(struct bat_priv *bat_priv)
 	return 1;
 }
=20
-static void batadv_tt_roam_list_free(struct bat_priv *bat_priv)
+static void batadv_tt_roam_list_free(struct batadv_priv *bat_priv)
 {
-	struct tt_roam_node *node, *safe;
+	struct batadv_tt_roam_node *node, *safe;
=20
 	spin_lock_bh(&bat_priv->tt_roam_list_lock);
=20
@@ -1944,9 +1959,9 @@ static void batadv_tt_roam_list_free(struct bat_p=
riv *bat_priv)
 	spin_unlock_bh(&bat_priv->tt_roam_list_lock);
 }
=20
-static void batadv_tt_roam_purge(struct bat_priv *bat_priv)
+static void batadv_tt_roam_purge(struct batadv_priv *bat_priv)
 {
-	struct tt_roam_node *node, *safe;
+	struct batadv_tt_roam_node *node, *safe;
=20
 	spin_lock_bh(&bat_priv->tt_roam_list_lock);
 	list_for_each_entry_safe(node, safe, &bat_priv->tt_roam_list, list) {
@@ -1966,10 +1981,10 @@ static void batadv_tt_roam_purge(struct bat_pri=
v *bat_priv)
  *
  * returns true if the ROAMING_ADV can be sent, false otherwise
  */
-static bool batadv_tt_check_roam_count(struct bat_priv *bat_priv,
+static bool batadv_tt_check_roam_count(struct batadv_priv *bat_priv,
 				       uint8_t *client)
 {
-	struct tt_roam_node *tt_roam_node;
+	struct batadv_tt_roam_node *tt_roam_node;
 	bool ret =3D false;
=20
 	spin_lock_bh(&bat_priv->tt_roam_list_lock);
@@ -2010,14 +2025,14 @@ unlock:
 	return ret;
 }
=20
-static void batadv_send_roam_adv(struct bat_priv *bat_priv, uint8_t *c=
lient,
-				 struct orig_node *orig_node)
+static void batadv_send_roam_adv(struct batadv_priv *bat_priv, uint8_t=
 *client,
+				 struct batadv_orig_node *orig_node)
 {
-	struct neigh_node *neigh_node =3D NULL;
+	struct batadv_neigh_node *neigh_node =3D NULL;
 	struct sk_buff *skb =3D NULL;
 	struct batadv_roam_adv_packet *roam_adv_packet;
 	int ret =3D 1;
-	struct hard_iface *primary_if;
+	struct batadv_hard_iface *primary_if;
 	size_t len =3D sizeof(*roam_adv_packet);
=20
 	/* before going on we have to check whether the client has
@@ -2068,10 +2083,11 @@ out:
=20
 static void batadv_tt_purge(struct work_struct *work)
 {
-	struct delayed_work *delayed_work =3D
-		container_of(work, struct delayed_work, work);
-	struct bat_priv *bat_priv =3D
-		container_of(delayed_work, struct bat_priv, tt_work);
+	struct delayed_work *delayed_work;
+	struct batadv_priv *bat_priv;
+
+	delayed_work =3D container_of(work, struct delayed_work, work);
+	bat_priv =3D container_of(delayed_work, struct batadv_priv, tt_work);
=20
 	batadv_tt_local_purge(bat_priv);
 	batadv_tt_global_roam_purge(bat_priv);
@@ -2081,7 +2097,7 @@ static void batadv_tt_purge(struct work_struct *w=
ork)
 	batadv_tt_start_timer(bat_priv);
 }
=20
-void batadv_tt_free(struct bat_priv *bat_priv)
+void batadv_tt_free(struct batadv_priv *bat_priv)
 {
 	cancel_delayed_work_sync(&bat_priv->tt_work);
=20
@@ -2104,7 +2120,7 @@ static uint16_t batadv_tt_set_flags(struct batadv=
_hashtable *hash,
 	uint16_t changed_num =3D 0;
 	struct hlist_head *head;
 	struct hlist_node *node;
-	struct tt_common_entry *tt_common_entry;
+	struct batadv_tt_common_entry *tt_common_entry;
=20
 	if (!hash)
 		goto out;
@@ -2133,11 +2149,11 @@ out:
 }
=20
 /* Purge out all the tt local entries marked with BATADV_TT_CLIENT_PEN=
DING */
-static void batadv_tt_local_purge_pending_clients(struct bat_priv *bat=
_priv)
+static void batadv_tt_local_purge_pending_clients(struct batadv_priv *=
bat_priv)
 {
 	struct batadv_hashtable *hash =3D bat_priv->tt_local_hash;
-	struct tt_common_entry *tt_common;
-	struct tt_local_entry *tt_local_entry;
+	struct batadv_tt_common_entry *tt_common;
+	struct batadv_tt_local_entry *tt_local;
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
 	spinlock_t *list_lock; /* protects write access to the hash lists */
@@ -2162,17 +2178,17 @@ static void batadv_tt_local_purge_pending_clien=
ts(struct bat_priv *bat_priv)
=20
 			atomic_dec(&bat_priv->num_local_tt);
 			hlist_del_rcu(node);
-			tt_local_entry =3D container_of(tt_common,
-						      struct tt_local_entry,
-						      common);
-			batadv_tt_local_entry_free_ref(tt_local_entry);
+			tt_local =3D container_of(tt_common,
+						struct batadv_tt_local_entry,
+						common);
+			batadv_tt_local_entry_free_ref(tt_local);
 		}
 		spin_unlock_bh(list_lock);
 	}
=20
 }
=20
-static int batadv_tt_commit_changes(struct bat_priv *bat_priv,
+static int batadv_tt_commit_changes(struct batadv_priv *bat_priv,
 				    unsigned char **packet_buff,
 				    int *packet_buff_len, int packet_min_len)
 {
@@ -2204,7 +2220,7 @@ static int batadv_tt_commit_changes(struct bat_pr=
iv *bat_priv,
 }
=20
 /* when calling this function (hard_iface =3D=3D primary_if) has to be=
 true */
-int batadv_tt_append_diff(struct bat_priv *bat_priv,
+int batadv_tt_append_diff(struct batadv_priv *bat_priv,
 			  unsigned char **packet_buff, int *packet_buff_len,
 			  int packet_min_len)
 {
@@ -2226,11 +2242,11 @@ int batadv_tt_append_diff(struct bat_priv *bat_=
priv,
 	return tt_num_changes;
 }
=20
-bool batadv_is_ap_isolated(struct bat_priv *bat_priv, uint8_t *src,
+bool batadv_is_ap_isolated(struct batadv_priv *bat_priv, uint8_t *src,
 			   uint8_t *dst)
 {
-	struct tt_local_entry *tt_local_entry =3D NULL;
-	struct tt_global_entry *tt_global_entry =3D NULL;
+	struct batadv_tt_local_entry *tt_local_entry =3D NULL;
+	struct batadv_tt_global_entry *tt_global_entry =3D NULL;
 	bool ret =3D false;
=20
 	if (!atomic_read(&bat_priv->ap_isolation))
@@ -2257,8 +2273,8 @@ out:
 	return ret;
 }
=20
-void batadv_tt_update_orig(struct bat_priv *bat_priv,
-			   struct orig_node *orig_node,
+void batadv_tt_update_orig(struct batadv_priv *bat_priv,
+			   struct batadv_orig_node *orig_node,
 			   const unsigned char *tt_buff, uint8_t tt_num_changes,
 			   uint8_t ttvn, uint16_t tt_crc)
 {
@@ -2333,10 +2349,10 @@ request_table:
  * originator to another one. This entry is kept is still kept for con=
sistency
  * purposes
  */
-bool batadv_tt_global_client_is_roaming(struct bat_priv *bat_priv,
+bool batadv_tt_global_client_is_roaming(struct batadv_priv *bat_priv,
 					uint8_t *addr)
 {
-	struct tt_global_entry *tt_global_entry;
+	struct batadv_tt_global_entry *tt_global_entry;
 	bool ret =3D false;
=20
 	tt_global_entry =3D batadv_tt_global_hash_find(bat_priv, addr);
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/transl=
ation-table.h
index 4e83b29..ffa8735 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -21,42 +21,43 @@
 #define _NET_BATMAN_ADV_TRANSLATION_TABLE_H_
=20
 int batadv_tt_len(int changes_num);
-int batadv_tt_init(struct bat_priv *bat_priv);
+int batadv_tt_init(struct batadv_priv *bat_priv);
 void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t =
*addr,
 			 int ifindex);
-void batadv_tt_local_remove(struct bat_priv *bat_priv,
+void batadv_tt_local_remove(struct batadv_priv *bat_priv,
 			    const uint8_t *addr, const char *message,
 			    bool roaming);
 int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)=
;
-void batadv_tt_global_add_orig(struct bat_priv *bat_priv,
-			       struct orig_node *orig_node,
+void batadv_tt_global_add_orig(struct batadv_priv *bat_priv,
+			       struct batadv_orig_node *orig_node,
 			       const unsigned char *tt_buff, int tt_buff_len);
-int batadv_tt_global_add(struct bat_priv *bat_priv, struct orig_node *=
orig_node,
+int batadv_tt_global_add(struct batadv_priv *bat_priv,
+			 struct batadv_orig_node *orig_node,
 			 const unsigned char *addr, uint8_t flags,
 			 uint8_t ttvn);
 int batadv_tt_global_seq_print_text(struct seq_file *seq, void *offset=
);
-void batadv_tt_global_del_orig(struct bat_priv *bat_priv,
-			       struct orig_node *orig_node,
+void batadv_tt_global_del_orig(struct batadv_priv *bat_priv,
+			       struct batadv_orig_node *orig_node,
 			       const char *message);
-struct orig_node *batadv_transtable_search(struct bat_priv *bat_priv,
-					   const uint8_t *src,
-					   const uint8_t *addr);
-void batadv_tt_free(struct bat_priv *bat_priv);
-bool batadv_send_tt_response(struct bat_priv *bat_priv,
+struct batadv_orig_node *batadv_transtable_search(struct batadv_priv *=
bat_priv,
+						  const uint8_t *src,
+						  const uint8_t *addr);
+void batadv_tt_free(struct batadv_priv *bat_priv);
+bool batadv_send_tt_response(struct batadv_priv *bat_priv,
 			     struct batadv_tt_query_packet *tt_request);
-bool batadv_is_my_client(struct bat_priv *bat_priv, const uint8_t *add=
r);
-void batadv_handle_tt_response(struct bat_priv *bat_priv,
+bool batadv_is_my_client(struct batadv_priv *bat_priv, const uint8_t *=
addr);
+void batadv_handle_tt_response(struct batadv_priv *bat_priv,
 			       struct batadv_tt_query_packet *tt_response);
-bool batadv_is_ap_isolated(struct bat_priv *bat_priv, uint8_t *src,
+bool batadv_is_ap_isolated(struct batadv_priv *bat_priv, uint8_t *src,
 			   uint8_t *dst);
-void batadv_tt_update_orig(struct bat_priv *bat_priv,
-			   struct orig_node *orig_node,
+void batadv_tt_update_orig(struct batadv_priv *bat_priv,
+			   struct batadv_orig_node *orig_node,
 			   const unsigned char *tt_buff, uint8_t tt_num_changes,
 			   uint8_t ttvn, uint16_t tt_crc);
-int batadv_tt_append_diff(struct bat_priv *bat_priv,
+int batadv_tt_append_diff(struct batadv_priv *bat_priv,
 			  unsigned char **packet_buff, int *packet_buff_len,
 			  int packet_min_len);
-bool batadv_tt_global_client_is_roaming(struct bat_priv *bat_priv,
+bool batadv_tt_global_client_is_roaming(struct batadv_priv *bat_priv,
 					uint8_t *addr);
=20
=20
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index fb61d9c..2141c13 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -28,7 +28,7 @@
 	(ETH_HLEN + max(sizeof(struct batadv_unicast_packet), \
 			sizeof(struct batadv_bcast_packet)))
=20
-struct hard_iface {
+struct batadv_hard_iface {
 	struct list_head list;
 	int16_t if_num;
 	char if_status;
@@ -44,7 +44,7 @@ struct hard_iface {
 	struct rcu_head rcu;
 };
=20
-/*	orig_node - structure for orig_list maintaining nodes of mesh
+/*	batadv_orig_node - structure for orig_list maintaining nodes of mes=
h
  *	@primary_addr: hosts primary interface address
  *	@last_seen: when last packet from this node was received
  *	@bcast_seqno_reset: time when the broadcast seqno window was reset
@@ -58,10 +58,10 @@ struct hard_iface {
  *	@candidates: how many candidates are available
  *	@selected: next bonding candidate
  */
-struct orig_node {
+struct batadv_orig_node {
 	uint8_t orig[ETH_ALEN];
 	uint8_t primary_addr[ETH_ALEN];
-	struct neigh_node __rcu *router; /* rcu protected pointer */
+	struct batadv_neigh_node __rcu *router; /* rcu protected pointer */
 	unsigned long *bcast_own;
 	uint8_t *bcast_own_sum;
 	unsigned long last_seen;
@@ -93,7 +93,7 @@ struct orig_node {
 	atomic_t refcount;
 	struct rcu_head rcu;
 	struct hlist_node hash_entry;
-	struct bat_priv *bat_priv;
+	struct batadv_priv *bat_priv;
 	unsigned long last_frag_packet;
 	/* ogm_cnt_lock protects: bcast_own, bcast_own_sum,
 	 * neigh_node->real_bits, neigh_node->real_packet_count
@@ -106,18 +106,18 @@ struct orig_node {
 	struct list_head bond_list;
 };
=20
-struct gw_node {
+struct batadv_gw_node {
 	struct hlist_node list;
-	struct orig_node *orig_node;
+	struct batadv_orig_node *orig_node;
 	unsigned long deleted;
 	atomic_t refcount;
 	struct rcu_head rcu;
 };
=20
-/*	neigh_node
+/*	batadv_neigh_node
  *	@last_seen: when last packet via this neighbor was received
  */
-struct neigh_node {
+struct batadv_neigh_node {
 	struct hlist_node list;
 	uint8_t addr[ETH_ALEN];
 	uint8_t real_packet_count;
@@ -130,13 +130,13 @@ struct neigh_node {
 	DECLARE_BITMAP(real_bits, BATADV_TQ_LOCAL_WINDOW_SIZE);
 	atomic_t refcount;
 	struct rcu_head rcu;
-	struct orig_node *orig_node;
-	struct hard_iface *if_incoming;
+	struct batadv_orig_node *orig_node;
+	struct batadv_hard_iface *if_incoming;
 	spinlock_t lq_update_lock;	/* protects: tq_recv, tq_index */
 };
=20
 #ifdef CONFIG_BATMAN_ADV_BLA
-struct bcast_duplist_entry {
+struct batadv_bcast_duplist_entry {
 	uint8_t orig[ETH_ALEN];
 	uint16_t crc;
 	unsigned long entrytime;
@@ -159,7 +159,7 @@ enum batadv_counters {
 	BATADV_CNT_NUM,
 };
=20
-struct bat_priv {
+struct batadv_priv {
 	atomic_t mesh_state;
 	struct net_device_stats stats;
 	uint64_t __percpu *bat_counters; /* Per cpu counters */
@@ -190,7 +190,7 @@ struct bat_priv {
 	 */
 	bool tt_poss_change;
 	char num_ifaces;
-	struct debug_log *debug_log;
+	struct batadv_debug_log *debug_log;
 	struct kobject *mesh_obj;
 	struct dentry *debug_dir;
 	struct hlist_head forw_bat_list;
@@ -209,7 +209,7 @@ struct bat_priv {
 	struct list_head tt_roam_list;
 	struct batadv_hashtable *vis_hash;
 #ifdef CONFIG_BATMAN_ADV_BLA
-	struct bcast_duplist_entry bcast_duplist[BATADV_DUPLIST_SIZE];
+	struct batadv_bcast_duplist_entry bcast_duplist[BATADV_DUPLIST_SIZE];
 	int bcast_duplist_curr;
 	struct batadv_bla_claim_dst claim_dest;
 #endif
@@ -231,29 +231,29 @@ struct bat_priv {
 	struct delayed_work orig_work;
 	struct delayed_work vis_work;
 	struct delayed_work bla_work;
-	struct gw_node __rcu *curr_gw;  /* rcu protected pointer */
+	struct batadv_gw_node __rcu *curr_gw;  /* rcu protected pointer */
 	atomic_t gw_reselect;
-	struct hard_iface __rcu *primary_if;  /* rcu protected pointer */
-	struct vis_info *my_vis_info;
-	struct bat_algo_ops *bat_algo_ops;
+	struct batadv_hard_iface __rcu *primary_if;  /* rcu protected pointer=
 */
+	struct batadv_vis_info *my_vis_info;
+	struct batadv_algo_ops *bat_algo_ops;
 };
=20
-struct socket_client {
+struct batadv_socket_client {
 	struct list_head queue_list;
 	unsigned int queue_len;
 	unsigned char index;
 	spinlock_t lock; /* protects queue_list, queue_len, index */
 	wait_queue_head_t queue_wait;
-	struct bat_priv *bat_priv;
+	struct batadv_priv *bat_priv;
 };
=20
-struct socket_packet {
+struct batadv_socket_packet {
 	struct list_head list;
 	size_t icmp_len;
 	struct batadv_icmp_packet_rr icmp_packet;
 };
=20
-struct tt_common_entry {
+struct batadv_tt_common_entry {
 	uint8_t addr[ETH_ALEN];
 	struct hlist_node hash_entry;
 	uint16_t flags;
@@ -261,31 +261,31 @@ struct tt_common_entry {
 	struct rcu_head rcu;
 };
=20
-struct tt_local_entry {
-	struct tt_common_entry common;
+struct batadv_tt_local_entry {
+	struct batadv_tt_common_entry common;
 	unsigned long last_seen;
 };
=20
-struct tt_global_entry {
-	struct tt_common_entry common;
+struct batadv_tt_global_entry {
+	struct batadv_tt_common_entry common;
 	struct hlist_head orig_list;
 	spinlock_t list_lock;	/* protects the list */
 	unsigned long roam_at; /* time at which TT_GLOBAL_ROAM was set */
 };
=20
-struct tt_orig_list_entry {
-	struct orig_node *orig_node;
+struct batadv_tt_orig_list_entry {
+	struct batadv_orig_node *orig_node;
 	uint8_t ttvn;
 	struct rcu_head rcu;
 	struct hlist_node list;
 };
=20
 #ifdef CONFIG_BATMAN_ADV_BLA
-struct backbone_gw {
+struct batadv_backbone_gw {
 	uint8_t orig[ETH_ALEN];
 	short vid;		/* used VLAN ID */
 	struct hlist_node hash_entry;
-	struct bat_priv *bat_priv;
+	struct batadv_priv *bat_priv;
 	unsigned long lasttime;	/* last time we heard of this backbone gw */
 	atomic_t request_sent;
 	atomic_t refcount;
@@ -293,10 +293,10 @@ struct backbone_gw {
 	uint16_t crc;		/* crc checksum over all claims */
 };
=20
-struct claim {
+struct batadv_claim {
 	uint8_t addr[ETH_ALEN];
 	short vid;
-	struct backbone_gw *backbone_gw;
+	struct batadv_backbone_gw *backbone_gw;
 	unsigned long lasttime;	/* last time we heard of claim (locals only) =
*/
 	struct rcu_head rcu;
 	atomic_t refcount;
@@ -304,18 +304,18 @@ struct claim {
 };
 #endif
=20
-struct tt_change_node {
+struct batadv_tt_change_node {
 	struct list_head list;
 	struct batadv_tt_change change;
 };
=20
-struct tt_req_node {
+struct batadv_tt_req_node {
 	uint8_t addr[ETH_ALEN];
 	unsigned long issued_at;
 	struct list_head list;
 };
=20
-struct tt_roam_node {
+struct batadv_tt_roam_node {
 	uint8_t addr[ETH_ALEN];
 	atomic_t counter;
 	unsigned long first_time;
@@ -325,7 +325,7 @@ struct tt_roam_node {
 /*	forw_packet - structure for forw_list maintaining packets to be
  *	              send/forwarded
  */
-struct forw_packet {
+struct batadv_forw_packet {
 	struct hlist_node list;
 	unsigned long send_time;
 	uint8_t own;
@@ -334,20 +334,20 @@ struct forw_packet {
 	uint32_t direct_link_flags;
 	uint8_t num_packets;
 	struct delayed_work delayed_work;
-	struct hard_iface *if_incoming;
+	struct batadv_hard_iface *if_incoming;
 };
=20
 /* While scanning for vis-entries of a particular vis-originator
  * this list collects its interfaces to create a subgraph/cluster
  * out of them later
  */
-struct if_list_entry {
+struct batadv_if_list_entry {
 	uint8_t addr[ETH_ALEN];
 	bool primary;
 	struct hlist_node list;
 };
=20
-struct debug_log {
+struct batadv_debug_log {
 	char log_buff[BATADV_LOG_BUF_LEN];
 	unsigned long log_start;
 	unsigned long log_end;
@@ -355,13 +355,13 @@ struct debug_log {
 	wait_queue_head_t queue_wait;
 };
=20
-struct frag_packet_list_entry {
+struct batadv_frag_packet_list_entry {
 	struct list_head list;
 	uint16_t seqno;
 	struct sk_buff *skb;
 };
=20
-struct vis_info {
+struct batadv_vis_info {
 	unsigned long first_seen;
 	/* list of server-neighbors we received a vis-packet
 	 * from.  we should not reply to them.
@@ -370,40 +370,40 @@ struct vis_info {
 	struct list_head send_list;
 	struct kref refcount;
 	struct hlist_node hash_entry;
-	struct bat_priv *bat_priv;
+	struct batadv_priv *bat_priv;
 	/* this packet might be part of the vis send queue. */
 	struct sk_buff *skb_packet;
 	/* vis_info may follow here */
 } __packed;
=20
-struct vis_info_entry {
+struct batadv_vis_info_entry {
 	uint8_t  src[ETH_ALEN];
 	uint8_t  dest[ETH_ALEN];
 	uint8_t  quality;	/* quality =3D 0 client */
 } __packed;
=20
-struct recvlist_node {
+struct batadv_recvlist_node {
 	struct list_head list;
 	uint8_t mac[ETH_ALEN];
 };
=20
-struct bat_algo_ops {
+struct batadv_algo_ops {
 	struct hlist_node list;
 	char *name;
 	/* init routing info when hard-interface is enabled */
-	int (*bat_iface_enable)(struct hard_iface *hard_iface);
+	int (*bat_iface_enable)(struct batadv_hard_iface *hard_iface);
 	/* de-init routing info when hard-interface is disabled */
-	void (*bat_iface_disable)(struct hard_iface *hard_iface);
+	void (*bat_iface_disable)(struct batadv_hard_iface *hard_iface);
 	/* (re-)init mac addresses of the protocol information
 	 * belonging to this hard-interface
 	 */
-	void (*bat_iface_update_mac)(struct hard_iface *hard_iface);
+	void (*bat_iface_update_mac)(struct batadv_hard_iface *hard_iface);
 	/* called when primary interface is selected / changed */
-	void (*bat_primary_iface_set)(struct hard_iface *hard_iface);
+	void (*bat_primary_iface_set)(struct batadv_hard_iface *hard_iface);
 	/* prepare a new outgoing OGM for the send queue */
-	void (*bat_ogm_schedule)(struct hard_iface *hard_iface);
+	void (*bat_ogm_schedule)(struct batadv_hard_iface *hard_iface);
 	/* send scheduled OGM */
-	void (*bat_ogm_emit)(struct forw_packet *forw_packet);
+	void (*bat_ogm_emit)(struct batadv_forw_packet *forw_packet);
 };
=20
 #endif /* _NET_BATMAN_ADV_TYPES_H_ */
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 8a2a3df..c42b81d 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -31,7 +31,7 @@
=20
 static struct sk_buff *
 batadv_frag_merge_packet(struct list_head *head,
-			 struct frag_packet_list_entry *tfp,
+			 struct batadv_frag_packet_list_entry *tfp,
 			 struct sk_buff *skb)
 {
 	struct batadv_unicast_frag_packet *up;
@@ -80,7 +80,7 @@ err:
 static void batadv_frag_create_entry(struct list_head *head,
 				     struct sk_buff *skb)
 {
-	struct frag_packet_list_entry *tfp;
+	struct batadv_frag_packet_list_entry *tfp;
 	struct batadv_unicast_frag_packet *up;
=20
 	up =3D (struct batadv_unicast_frag_packet *)skb->data;
@@ -98,7 +98,7 @@ static void batadv_frag_create_entry(struct list_head=
 *head,
 static int batadv_frag_create_buffer(struct list_head *head)
 {
 	int i;
-	struct frag_packet_list_entry *tfp;
+	struct batadv_frag_packet_list_entry *tfp;
=20
 	for (i =3D 0; i < BATADV_FRAG_BUFFER_SIZE; i++) {
 		tfp =3D kmalloc(sizeof(*tfp), GFP_ATOMIC);
@@ -115,11 +115,11 @@ static int batadv_frag_create_buffer(struct list_=
head *head)
 	return 0;
 }
=20
-static struct frag_packet_list_entry *
+static struct batadv_frag_packet_list_entry *
 batadv_frag_search_packet(struct list_head *head,
 			  const struct batadv_unicast_frag_packet *up)
 {
-	struct frag_packet_list_entry *tfp;
+	struct batadv_frag_packet_list_entry *tfp;
 	struct batadv_unicast_frag_packet *tmp_up =3D NULL;
 	uint16_t search_seqno;
=20
@@ -156,7 +156,7 @@ mov_tail:
=20
 void batadv_frag_list_free(struct list_head *head)
 {
-	struct frag_packet_list_entry *pf, *tmp_pf;
+	struct batadv_frag_packet_list_entry *pf, *tmp_pf;
=20
 	if (!list_empty(head)) {
=20
@@ -175,11 +175,12 @@ void batadv_frag_list_free(struct list_head *head=
)
  * or the skb could be reassembled (skb_new will point to the new pack=
et and
  * skb was freed)
  */
-int batadv_frag_reassemble_skb(struct sk_buff *skb, struct bat_priv *b=
at_priv,
+int batadv_frag_reassemble_skb(struct sk_buff *skb,
+			       struct batadv_priv *bat_priv,
 			       struct sk_buff **new_skb)
 {
-	struct orig_node *orig_node;
-	struct frag_packet_list_entry *tmp_frag_entry;
+	struct batadv_orig_node *orig_node;
+	struct batadv_frag_packet_list_entry *tmp_frag_entry;
 	int ret =3D NET_RX_DROP;
 	struct batadv_unicast_frag_packet *unicast_packet;
=20
@@ -219,11 +220,12 @@ out:
 	return ret;
 }
=20
-int batadv_frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_pri=
v,
-			 struct hard_iface *hard_iface, const uint8_t dstaddr[])
+int batadv_frag_send_skb(struct sk_buff *skb, struct batadv_priv *bat_=
priv,
+			 struct batadv_hard_iface *hard_iface,
+			 const uint8_t dstaddr[])
 {
 	struct batadv_unicast_packet tmp_uc, *unicast_packet;
-	struct hard_iface *primary_if;
+	struct batadv_hard_iface *primary_if;
 	struct sk_buff *frag_skb;
 	struct batadv_unicast_frag_packet *frag1, *frag2;
 	int uc_hdr_len =3D sizeof(*unicast_packet);
@@ -286,12 +288,12 @@ out:
 	return ret;
 }
=20
-int batadv_unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_=
priv)
+int batadv_unicast_send_skb(struct sk_buff *skb, struct batadv_priv *b=
at_priv)
 {
 	struct ethhdr *ethhdr =3D (struct ethhdr *)skb->data;
 	struct batadv_unicast_packet *unicast_packet;
-	struct orig_node *orig_node;
-	struct neigh_node *neigh_node;
+	struct batadv_orig_node *orig_node;
+	struct batadv_neigh_node *neigh_node;
 	int data_len =3D skb->len;
 	int ret =3D 1;
=20
@@ -307,12 +309,14 @@ int batadv_unicast_send_skb(struct sk_buff *skb, =
struct bat_priv *bat_priv)
 	 */
 	orig_node =3D batadv_transtable_search(bat_priv, ethhdr->h_source,
 					     ethhdr->h_dest);
+
 find_router:
 	/* find_router():
 	 *  - if orig_node is NULL it returns NULL
 	 *  - increases neigh_nodes refcount if found.
 	 */
 	neigh_node =3D batadv_find_router(bat_priv, orig_node, NULL);
+
 	if (!neigh_node)
 		goto out;
=20
diff --git a/net/batman-adv/unicast.h b/net/batman-adv/unicast.h
index e0b6e33..1c46e2e 100644
--- a/net/batman-adv/unicast.h
+++ b/net/batman-adv/unicast.h
@@ -25,12 +25,13 @@
 #define BATADV_FRAG_TIMEOUT 10000 /* purge frag list entries after tim=
e in ms */
 #define BATADV_FRAG_BUFFER_SIZE 6 /* number of list elements in buffer=
 */
=20
-int batadv_frag_reassemble_skb(struct sk_buff *skb, struct bat_priv *b=
at_priv,
+int batadv_frag_reassemble_skb(struct sk_buff *skb,
+			       struct batadv_priv *bat_priv,
 			       struct sk_buff **new_skb);
 void batadv_frag_list_free(struct list_head *head);
-int batadv_unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_=
priv);
-int batadv_frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_pri=
v,
-			 struct hard_iface *hard_iface,
+int batadv_unicast_send_skb(struct sk_buff *skb, struct batadv_priv *b=
at_priv);
+int batadv_frag_send_skb(struct sk_buff *skb, struct batadv_priv *bat_=
priv,
+			 struct batadv_hard_iface *hard_iface,
 			 const uint8_t dstaddr[]);
=20
 static inline int batadv_frag_can_reassemble(const struct sk_buff *skb=
, int mtu)
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 309493d..f09cc9a 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -28,14 +28,17 @@
=20
 #define BATADV_MAX_VIS_PACKET_SIZE 1000
=20
-static void batadv_start_vis_timer(struct bat_priv *bat_priv);
+static void batadv_start_vis_timer(struct batadv_priv *bat_priv);
=20
 /* free the info */
 static void batadv_free_info(struct kref *ref)
 {
-	struct vis_info *info =3D container_of(ref, struct vis_info, refcount=
);
-	struct bat_priv *bat_priv =3D info->bat_priv;
-	struct recvlist_node *entry, *tmp;
+	struct batadv_vis_info *info;
+	struct batadv_priv *bat_priv;
+	struct batadv_recvlist_node *entry, *tmp;
+
+	info =3D container_of(ref, struct batadv_vis_info, refcount);
+	bat_priv =3D info->bat_priv;
=20
 	list_del_init(&info->send_list);
 	spin_lock_bh(&bat_priv->vis_list_lock);
@@ -52,10 +55,10 @@ static void batadv_free_info(struct kref *ref)
 /* Compare two vis packets, used by the hashing algorithm */
 static int batadv_vis_info_cmp(const struct hlist_node *node, const vo=
id *data2)
 {
-	const struct vis_info *d1, *d2;
+	const struct batadv_vis_info *d1, *d2;
 	const struct batadv_vis_packet *p1, *p2;
=20
-	d1 =3D container_of(node, struct vis_info, hash_entry);
+	d1 =3D container_of(node, struct batadv_vis_info, hash_entry);
 	d2 =3D data2;
 	p1 =3D (struct batadv_vis_packet *)d1->skb_packet->data;
 	p2 =3D (struct batadv_vis_packet *)d2->skb_packet->data;
@@ -67,7 +70,7 @@ static int batadv_vis_info_cmp(const struct hlist_nod=
e *node, const void *data2)
  */
 static uint32_t batadv_vis_info_choose(const void *data, uint32_t size=
)
 {
-	const struct vis_info *vis_info =3D data;
+	const struct batadv_vis_info *vis_info =3D data;
 	const struct batadv_vis_packet *packet;
 	const unsigned char *key;
 	uint32_t hash =3D 0;
@@ -88,13 +91,13 @@ static uint32_t batadv_vis_info_choose(const void *=
data, uint32_t size)
 	return hash % size;
 }
=20
-static struct vis_info *batadv_vis_hash_find(struct bat_priv *bat_priv=
,
-					     const void *data)
+static struct batadv_vis_info *
+batadv_vis_hash_find(struct batadv_priv *bat_priv, const void *data)
 {
 	struct batadv_hashtable *hash =3D bat_priv->vis_hash;
 	struct hlist_head *head;
 	struct hlist_node *node;
-	struct vis_info *vis_info, *vis_info_tmp =3D NULL;
+	struct batadv_vis_info *vis_info, *vis_info_tmp =3D NULL;
 	uint32_t index;
=20
 	if (!hash)
@@ -123,7 +126,7 @@ static void batadv_vis_data_insert_interface(const =
uint8_t *interface,
 					     struct hlist_head *if_list,
 					     bool primary)
 {
-	struct if_list_entry *entry;
+	struct batadv_if_list_entry *entry;
 	struct hlist_node *pos;
=20
 	hlist_for_each_entry(entry, pos, if_list, list) {
@@ -143,7 +146,7 @@ static void batadv_vis_data_insert_interface(const =
uint8_t *interface,
 static void batadv_vis_data_read_prim_sec(struct seq_file *seq,
 					  const struct hlist_head *if_list)
 {
-	struct if_list_entry *entry;
+	struct batadv_if_list_entry *entry;
 	struct hlist_node *pos;
=20
 	hlist_for_each_entry(entry, pos, if_list, list) {
@@ -155,9 +158,10 @@ static void batadv_vis_data_read_prim_sec(struct s=
eq_file *seq,
 }
=20
 /* read an entry  */
-static ssize_t batadv_vis_data_read_entry(struct seq_file *seq,
-					  const struct vis_info_entry *entry,
-					  const uint8_t *src, bool primary)
+static ssize_t
+batadv_vis_data_read_entry(struct seq_file *seq,
+			   const struct batadv_vis_info_entry *entry,
+			   const uint8_t *src, bool primary)
 {
 	if (primary && entry->quality =3D=3D 0)
 		return seq_printf(seq, "TT %pM, ", entry->dest);
@@ -168,9 +172,10 @@ static ssize_t batadv_vis_data_read_entry(struct s=
eq_file *seq,
 	return 0;
 }
=20
-static void batadv_vis_data_insert_interfaces(struct hlist_head *list,
-					      struct batadv_vis_packet *packet,
-					      struct vis_info_entry *entries)
+static void
+batadv_vis_data_insert_interfaces(struct hlist_head *list,
+				  struct batadv_vis_packet *packet,
+				  struct batadv_vis_info_entry *entries)
 {
 	int i;
=20
@@ -188,10 +193,10 @@ static void batadv_vis_data_insert_interfaces(str=
uct hlist_head *list,
 static void batadv_vis_data_read_entries(struct seq_file *seq,
 					 struct hlist_head *list,
 					 struct batadv_vis_packet *packet,
-					 struct vis_info_entry *entries)
+					 struct batadv_vis_info_entry *entries)
 {
 	int i;
-	struct if_list_entry *entry;
+	struct batadv_if_list_entry *entry;
 	struct hlist_node *pos;
=20
 	hlist_for_each_entry(entry, pos, list, list) {
@@ -213,11 +218,11 @@ static void batadv_vis_seq_print_text_bucket(stru=
ct seq_file *seq,
 					     const struct hlist_head *head)
 {
 	struct hlist_node *node;
-	struct vis_info *info;
+	struct batadv_vis_info *info;
 	struct batadv_vis_packet *packet;
 	uint8_t *entries_pos;
-	struct vis_info_entry *entries;
-	struct if_list_entry *entry;
+	struct batadv_vis_info_entry *entries;
+	struct batadv_if_list_entry *entry;
 	struct hlist_node *pos, *n;
=20
 	HLIST_HEAD(vis_if_list);
@@ -225,7 +230,7 @@ static void batadv_vis_seq_print_text_bucket(struct=
 seq_file *seq,
 	hlist_for_each_entry_rcu(info, node, head, hash_entry) {
 		packet =3D (struct batadv_vis_packet *)info->skb_packet->data;
 		entries_pos =3D (uint8_t *)packet + sizeof(*packet);
-		entries =3D (struct vis_info_entry *)entries_pos;
+		entries =3D (struct batadv_vis_info_entry *)entries_pos;
=20
 		batadv_vis_data_insert_interface(packet->vis_orig, &vis_if_list,
 						 true);
@@ -243,10 +248,10 @@ static void batadv_vis_seq_print_text_bucket(stru=
ct seq_file *seq,
=20
 int batadv_vis_seq_print_text(struct seq_file *seq, void *offset)
 {
-	struct hard_iface *primary_if;
+	struct batadv_hard_iface *primary_if;
 	struct hlist_head *head;
 	struct net_device *net_dev =3D (struct net_device *)seq->private;
-	struct bat_priv *bat_priv =3D netdev_priv(net_dev);
+	struct batadv_priv *bat_priv =3D netdev_priv(net_dev);
 	struct batadv_hashtable *hash =3D bat_priv->vis_hash;
 	uint32_t i;
 	int ret =3D 0;
@@ -275,8 +280,8 @@ out:
 /* add the info packet to the send list, if it was not
  * already linked in.
  */
-static void batadv_send_list_add(struct bat_priv *bat_priv,
-				 struct vis_info *info)
+static void batadv_send_list_add(struct batadv_priv *bat_priv,
+				 struct batadv_vis_info *info)
 {
 	if (list_empty(&info->send_list)) {
 		kref_get(&info->refcount);
@@ -287,7 +292,7 @@ static void batadv_send_list_add(struct bat_priv *b=
at_priv,
 /* delete the info packet from the send list, if it was
  * linked in.
  */
-static void batadv_send_list_del(struct vis_info *info)
+static void batadv_send_list_del(struct batadv_vis_info *info)
 {
 	if (!list_empty(&info->send_list)) {
 		list_del_init(&info->send_list);
@@ -296,10 +301,10 @@ static void batadv_send_list_del(struct vis_info =
*info)
 }
=20
 /* tries to add one entry to the receive list. */
-static void batadv_recv_list_add(struct bat_priv *bat_priv,
+static void batadv_recv_list_add(struct batadv_priv *bat_priv,
 				 struct list_head *recv_list, const char *mac)
 {
-	struct recvlist_node *entry;
+	struct batadv_recvlist_node *entry;
=20
 	entry =3D kmalloc(sizeof(*entry), GFP_ATOMIC);
 	if (!entry)
@@ -312,11 +317,11 @@ static void batadv_recv_list_add(struct bat_priv =
*bat_priv,
 }
=20
 /* returns 1 if this mac is in the recv_list */
-static int batadv_recv_list_is_in(struct bat_priv *bat_priv,
+static int batadv_recv_list_is_in(struct batadv_priv *bat_priv,
 				  const struct list_head *recv_list,
 				  const char *mac)
 {
-	const struct recvlist_node *entry;
+	const struct batadv_recvlist_node *entry;
=20
 	spin_lock_bh(&bat_priv->vis_list_lock);
 	list_for_each_entry(entry, recv_list, list) {
@@ -333,18 +338,19 @@ static int batadv_recv_list_is_in(struct bat_priv=
 *bat_priv,
  * broken.. ).	vis hash must be locked outside.  is_new is set when th=
e packet
  * is newer than old entries in the hash.
  */
-static struct vis_info *batadv_add_packet(struct bat_priv *bat_priv,
-					  struct batadv_vis_packet *vis_packet,
-					  int vis_info_len, int *is_new,
-					  int make_broadcast)
+static struct batadv_vis_info *
+batadv_add_packet(struct batadv_priv *bat_priv,
+		  struct batadv_vis_packet *vis_packet, int vis_info_len,
+		  int *is_new, int make_broadcast)
 {
-	struct vis_info *info, *old_info;
+	struct batadv_vis_info *info, *old_info;
 	struct batadv_vis_packet *search_packet, *old_packet;
-	struct vis_info search_elem;
+	struct batadv_vis_info search_elem;
 	struct batadv_vis_packet *packet;
 	struct sk_buff *tmp_skb;
 	int hash_added;
 	size_t len;
+	size_t max_entries;
=20
 	*is_new =3D 0;
 	/* sanity check */
@@ -413,8 +419,9 @@ static struct vis_info *batadv_add_packet(struct ba=
t_priv *bat_priv,
 		memcpy(packet->target_orig, batadv_broadcast_addr, ETH_ALEN);
=20
 	/* repair if entries is longer than packet. */
-	if (packet->entries * sizeof(struct vis_info_entry) > vis_info_len)
-		packet->entries =3D vis_info_len / sizeof(struct vis_info_entry);
+	max_entries =3D vis_info_len / sizeof(struct batadv_vis_info_entry);
+	if (packet->entries > max_entries)
+		packet->entries =3D max_entries;
=20
 	batadv_recv_list_add(bat_priv, &info->recv_list, packet->sender_orig)=
;
=20
@@ -432,11 +439,11 @@ static struct vis_info *batadv_add_packet(struct =
bat_priv *bat_priv,
 }
=20
 /* handle the server sync packet, forward if needed. */
-void batadv_receive_server_sync_packet(struct bat_priv *bat_priv,
+void batadv_receive_server_sync_packet(struct batadv_priv *bat_priv,
 				       struct batadv_vis_packet *vis_packet,
 				       int vis_info_len)
 {
-	struct vis_info *info;
+	struct batadv_vis_info *info;
 	int is_new, make_broadcast;
 	int vis_server =3D atomic_read(&bat_priv->vis_mode);
=20
@@ -458,11 +465,11 @@ end:
 }
=20
 /* handle an incoming client update packet and schedule forward if nee=
ded. */
-void batadv_receive_client_update_packet(struct bat_priv *bat_priv,
+void batadv_receive_client_update_packet(struct batadv_priv *bat_priv,
 					 struct batadv_vis_packet *vis_packet,
 					 int vis_info_len)
 {
-	struct vis_info *info;
+	struct batadv_vis_info *info;
 	struct batadv_vis_packet *packet;
 	int is_new;
 	int vis_server =3D atomic_read(&bat_priv->vis_mode);
@@ -506,14 +513,14 @@ end:
  *
  * Must be called with the originator hash locked
  */
-static int batadv_find_best_vis_server(struct bat_priv *bat_priv,
-				       struct vis_info *info)
+static int batadv_find_best_vis_server(struct batadv_priv *bat_priv,
+				       struct batadv_vis_info *info)
 {
 	struct batadv_hashtable *hash =3D bat_priv->orig_hash;
-	struct neigh_node *router;
+	struct batadv_neigh_node *router;
 	struct hlist_node *node;
 	struct hlist_head *head;
-	struct orig_node *orig_node;
+	struct batadv_orig_node *orig_node;
 	struct batadv_vis_packet *packet;
 	int best_tq =3D -1;
 	uint32_t i;
@@ -544,15 +551,15 @@ static int batadv_find_best_vis_server(struct bat=
_priv *bat_priv,
 }
=20
 /* Return true if the vis packet is full. */
-static bool batadv_vis_packet_full(const struct vis_info *info)
+static bool batadv_vis_packet_full(const struct batadv_vis_info *info)
 {
 	const struct batadv_vis_packet *packet;
-	size_t num_items;
+	size_t num;
=20
 	packet =3D (struct batadv_vis_packet *)info->skb_packet->data;
-	num_items =3D BATADV_MAX_VIS_PACKET_SIZE / sizeof(struct vis_info_ent=
ry);
+	num =3D BATADV_MAX_VIS_PACKET_SIZE / sizeof(struct batadv_vis_info_en=
try);
=20
-	if (num_items < packet->entries + 1)
+	if (num < packet->entries + 1)
 		return true;
 	return false;
 }
@@ -560,17 +567,17 @@ static bool batadv_vis_packet_full(const struct v=
is_info *info)
 /* generates a packet of own vis data,
  * returns 0 on success, -1 if no packet could be generated
  */
-static int batadv_generate_vis_packet(struct bat_priv *bat_priv)
+static int batadv_generate_vis_packet(struct batadv_priv *bat_priv)
 {
 	struct batadv_hashtable *hash =3D bat_priv->orig_hash;
 	struct hlist_node *node;
 	struct hlist_head *head;
-	struct orig_node *orig_node;
-	struct neigh_node *router;
-	struct vis_info *info =3D bat_priv->my_vis_info;
+	struct batadv_orig_node *orig_node;
+	struct batadv_neigh_node *router;
+	struct batadv_vis_info *info =3D bat_priv->my_vis_info;
 	struct batadv_vis_packet *packet;
-	struct vis_info_entry *entry;
-	struct tt_common_entry *tt_common_entry;
+	struct batadv_vis_info_entry *entry;
+	struct batadv_tt_common_entry *tt_common_entry;
 	int best_tq =3D -1;
 	uint32_t i;
=20
@@ -610,7 +617,7 @@ static int batadv_generate_vis_packet(struct bat_pr=
iv *bat_priv)
 				goto next;
=20
 			/* fill one entry into buffer. */
-			entry =3D (struct vis_info_entry *)
+			entry =3D (struct batadv_vis_info_entry *)
 				      skb_put(info->skb_packet, sizeof(*entry));
 			memcpy(entry->src,
 			       router->if_incoming->net_dev->dev_addr,
@@ -636,7 +643,7 @@ next:
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(tt_common_entry, node, head,
 					 hash_entry) {
-			entry =3D (struct vis_info_entry *)
+			entry =3D (struct batadv_vis_info_entry *)
 					skb_put(info->skb_packet,
 						sizeof(*entry));
 			memset(entry->src, 0, ETH_ALEN);
@@ -660,13 +667,13 @@ unlock:
 /* free old vis packets. Must be called with this vis_hash_lock
  * held
  */
-static void batadv_purge_vis_packets(struct bat_priv *bat_priv)
+static void batadv_purge_vis_packets(struct batadv_priv *bat_priv)
 {
 	uint32_t i;
 	struct batadv_hashtable *hash =3D bat_priv->vis_hash;
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
-	struct vis_info *info;
+	struct batadv_vis_info *info;
=20
 	for (i =3D 0; i < hash->size; i++) {
 		head =3D &hash->table[i];
@@ -687,17 +694,17 @@ static void batadv_purge_vis_packets(struct bat_p=
riv *bat_priv)
 	}
 }
=20
-static void batadv_broadcast_vis_packet(struct bat_priv *bat_priv,
-					struct vis_info *info)
+static void batadv_broadcast_vis_packet(struct batadv_priv *bat_priv,
+					struct batadv_vis_info *info)
 {
-	struct neigh_node *router;
+	struct batadv_neigh_node *router;
 	struct batadv_hashtable *hash =3D bat_priv->orig_hash;
 	struct hlist_node *node;
 	struct hlist_head *head;
-	struct orig_node *orig_node;
+	struct batadv_orig_node *orig_node;
 	struct batadv_vis_packet *packet;
 	struct sk_buff *skb;
-	struct hard_iface *hard_iface;
+	struct batadv_hard_iface *hard_iface;
 	uint8_t dstaddr[ETH_ALEN];
 	uint32_t i;
=20
@@ -743,11 +750,11 @@ static void batadv_broadcast_vis_packet(struct ba=
t_priv *bat_priv,
 	}
 }
=20
-static void batadv_unicast_vis_packet(struct bat_priv *bat_priv,
-				      struct vis_info *info)
+static void batadv_unicast_vis_packet(struct batadv_priv *bat_priv,
+				      struct batadv_vis_info *info)
 {
-	struct orig_node *orig_node;
-	struct neigh_node *router =3D NULL;
+	struct batadv_orig_node *orig_node;
+	struct batadv_neigh_node *router =3D NULL;
 	struct sk_buff *skb;
 	struct batadv_vis_packet *packet;
=20
@@ -773,10 +780,10 @@ out:
 }
=20
 /* only send one vis packet. called from batadv_send_vis_packets() */
-static void batadv_send_vis_packet(struct bat_priv *bat_priv,
-				   struct vis_info *info)
+static void batadv_send_vis_packet(struct batadv_priv *bat_priv,
+				   struct batadv_vis_info *info)
 {
-	struct hard_iface *primary_if;
+	struct batadv_hard_iface *primary_if;
 	struct batadv_vis_packet *packet;
=20
 	primary_if =3D batadv_primary_if_get_selected(bat_priv);
@@ -808,10 +815,10 @@ static void batadv_send_vis_packets(struct work_s=
truct *work)
 {
 	struct delayed_work *delayed_work =3D
 		container_of(work, struct delayed_work, work);
-	struct bat_priv *bat_priv =3D
-		container_of(delayed_work, struct bat_priv, vis_work);
-	struct vis_info *info;
+	struct batadv_priv *bat_priv;
+	struct batadv_vis_info *info;
=20
+	bat_priv =3D container_of(delayed_work, struct batadv_priv, vis_work)=
;
 	spin_lock_bh(&bat_priv->vis_hash_lock);
 	batadv_purge_vis_packets(bat_priv);
=20
@@ -840,7 +847,7 @@ static void batadv_send_vis_packets(struct work_str=
uct *work)
 /* init the vis server. this may only be called when if_list is alread=
y
  * initialized (e.g. bat0 is initialized, interfaces have been added)
  */
-int batadv_vis_init(struct bat_priv *bat_priv)
+int batadv_vis_init(struct batadv_priv *bat_priv)
 {
 	struct batadv_vis_packet *packet;
 	int hash_added;
@@ -914,15 +921,15 @@ err:
 /* Decrease the reference count on a hash item info */
 static void batadv_free_info_ref(struct hlist_node *node, void *arg)
 {
-	struct vis_info *info;
+	struct batadv_vis_info *info;
=20
-	info =3D container_of(node, struct vis_info, hash_entry);
+	info =3D container_of(node, struct batadv_vis_info, hash_entry);
 	batadv_send_list_del(info);
 	kref_put(&info->refcount, batadv_free_info);
 }
=20
 /* shutdown vis-server */
-void batadv_vis_quit(struct bat_priv *bat_priv)
+void batadv_vis_quit(struct batadv_priv *bat_priv)
 {
 	if (!bat_priv->vis_hash)
 		return;
@@ -938,7 +945,7 @@ void batadv_vis_quit(struct bat_priv *bat_priv)
 }
=20
 /* schedule packets for (re)transmission */
-static void batadv_start_vis_timer(struct bat_priv *bat_priv)
+static void batadv_start_vis_timer(struct batadv_priv *bat_priv)
 {
 	INIT_DELAYED_WORK(&bat_priv->vis_work, batadv_send_vis_packets);
 	queue_delayed_work(batadv_event_workqueue, &bat_priv->vis_work,
diff --git a/net/batman-adv/vis.h b/net/batman-adv/vis.h
index d6bfcc7..84e716e 100644
--- a/net/batman-adv/vis.h
+++ b/net/batman-adv/vis.h
@@ -24,13 +24,13 @@
 #define BATADV_VIS_TIMEOUT		200000
=20
 int batadv_vis_seq_print_text(struct seq_file *seq, void *offset);
-void batadv_receive_server_sync_packet(struct bat_priv *bat_priv,
+void batadv_receive_server_sync_packet(struct batadv_priv *bat_priv,
 				       struct batadv_vis_packet *vis_packet,
 				       int vis_info_len);
-void batadv_receive_client_update_packet(struct bat_priv *bat_priv,
+void batadv_receive_client_update_packet(struct batadv_priv *bat_priv,
 					 struct batadv_vis_packet *vis_packet,
 					 int vis_info_len);
-int batadv_vis_init(struct bat_priv *bat_priv);
-void batadv_vis_quit(struct bat_priv *bat_priv);
+int batadv_vis_init(struct batadv_priv *bat_priv);
+void batadv_vis_quit(struct batadv_priv *bat_priv);
=20
 #endif /* _NET_BATMAN_ADV_VIS_H_ */
--=20
1.7.9.4
