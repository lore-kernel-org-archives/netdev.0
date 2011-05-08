From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 6/8] batman-adv: rename everything from *hna*
	into *tt* (translation table)
Date: Sun,  8 May 2011 17:24:42 +0200
Message-ID: <1304868284-9364-7-git-send-email-sven@narfation.org>
References: <1304868284-9364-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1304868284-9364-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
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

From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>

To be coherent, all the functions/variables/constants have been renamed
to the TranslationTable style

Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 Documentation/networking/batman-adv.txt |   11 +-
 net/batman-adv/aggregation.c            |   16 +-
 net/batman-adv/aggregation.h            |    4 +-
 net/batman-adv/bat_debugfs.c            |    4 +-
 net/batman-adv/hard-interface.c         |    6 +-
 net/batman-adv/main.c                   |   14 +-
 net/batman-adv/main.h                   |    4 +-
 net/batman-adv/originator.c             |    8 +-
 net/batman-adv/packet.h                 |    2 +-
 net/batman-adv/routing.c                |   70 +++---
 net/batman-adv/routing.h                |    6 +-
 net/batman-adv/send.c                   |   16 +-
 net/batman-adv/send.h                   |    2 +-
 net/batman-adv/soft-interface.c         |   10 +-
 net/batman-adv/translation-table.c      |  415 ++++++++++++++++---------------
 net/batman-adv/translation-table.h      |   24 +-
 net/batman-adv/types.h                  |   24 +-
 net/batman-adv/unicast.c                |    2 +-
 net/batman-adv/vis.c                    |   18 +-
 19 files changed, 329 insertions(+), 327 deletions(-)

diff --git a/Documentation/networking/batman-adv.txt b/Documentation/networking/batman-adv.txt
index 18afcd8..713f7c0 100644
--- a/Documentation/networking/batman-adv.txt
+++ b/Documentation/networking/batman-adv.txt
@@ -1,4 +1,4 @@
-[state: 27-01-2011]
+[state: 17-04-2011]
 
 BATMAN-ADV
 ----------
@@ -19,6 +19,7 @@ duce the overhead to a minimum. It does not depend on any (other)
 network driver, and can be used on wifi as well as ethernet  lan,
 vpn,  etc ... (anything with ethernet-style layer 2).
 
+
 CONFIGURATION
 -------------
 
@@ -160,13 +161,13 @@ face.  Each  entry can/has to have the following values:
 -> "TQ mac  value"  -  src mac's link quality towards mac address
                        of a neighbor originator's interface which
                        is being used for routing
--> "HNA mac" - HNA announced by source mac
+-> "TT mac" - TT announced by source mac
 -> "PRIMARY" - this  is a primary interface
 -> "SEC mac" - secondary mac address of source
                (requires preceding PRIMARY)
 
 The TQ value has a range from 4 to 255 with 255 being  the  best.
-The HNA entries are showing which hosts are connected to the mesh
+The TT entries are showing which hosts are connected to the mesh
 via bat0 or being bridged into the mesh network.  The PRIMARY/SEC
 values are only applied on primary interfaces
 
@@ -199,7 +200,7 @@ abled  during run time. Following log_levels are defined:
 
 0 - All  debug  output  disabled
 1 - Enable messages related to routing / flooding / broadcasting
-2 - Enable route or hna added / changed / deleted
+2 - Enable route or tt entry added / changed / deleted
 3 - Enable all messages
 
 The debug output can be changed at runtime  using  the  file
@@ -207,7 +208,7 @@ The debug output can be changed at runtime  using  the  file
 
 # echo 2 > /sys/class/net/bat0/mesh/log_level
 
-will enable debug messages for when routes or HNAs change.
+will enable debug messages for when routes or TTs change.
 
 
 BATCTL
diff --git a/net/batman-adv/aggregation.c b/net/batman-adv/aggregation.c
index c11788c..9b94590 100644
--- a/net/batman-adv/aggregation.c
+++ b/net/batman-adv/aggregation.c
@@ -24,10 +24,10 @@
 #include "send.h"
 #include "routing.h"
 
-/* calculate the size of the hna information for a given packet */
-static int hna_len(struct batman_packet *batman_packet)
+/* calculate the size of the tt information for a given packet */
+static int tt_len(struct batman_packet *batman_packet)
 {
-	return batman_packet->num_hna * ETH_ALEN;
+	return batman_packet->num_tt * ETH_ALEN;
 }
 
 /* return true if new_packet can be aggregated with forw_packet */
@@ -250,7 +250,7 @@ void receive_aggr_bat_packet(struct ethhdr *ethhdr, unsigned char *packet_buff,
 {
 	struct batman_packet *batman_packet;
 	int buff_pos = 0;
-	unsigned char *hna_buff;
+	unsigned char *tt_buff;
 
 	batman_packet = (struct batman_packet *)packet_buff;
 
@@ -259,14 +259,14 @@ void receive_aggr_bat_packet(struct ethhdr *ethhdr, unsigned char *packet_buff,
 		   orig_interval. */
 		batman_packet->seqno = ntohl(batman_packet->seqno);
 
-		hna_buff = packet_buff + buff_pos + BAT_PACKET_LEN;
+		tt_buff = packet_buff + buff_pos + BAT_PACKET_LEN;
 		receive_bat_packet(ethhdr, batman_packet,
-				   hna_buff, hna_len(batman_packet),
+				   tt_buff, tt_len(batman_packet),
 				   if_incoming);
 
-		buff_pos += BAT_PACKET_LEN + hna_len(batman_packet);
+		buff_pos += BAT_PACKET_LEN + tt_len(batman_packet);
 		batman_packet = (struct batman_packet *)
 			(packet_buff + buff_pos);
 	} while (aggregated_packet(buff_pos, packet_len,
-				   batman_packet->num_hna));
+				   batman_packet->num_tt));
 }
diff --git a/net/batman-adv/aggregation.h b/net/batman-adv/aggregation.h
index 0622042..7e6d72f 100644
--- a/net/batman-adv/aggregation.h
+++ b/net/batman-adv/aggregation.h
@@ -25,9 +25,9 @@
 #include "main.h"
 
 /* is there another aggregated packet here? */
-static inline int aggregated_packet(int buff_pos, int packet_len, int num_hna)
+static inline int aggregated_packet(int buff_pos, int packet_len, int num_tt)
 {
-	int next_buff_pos = buff_pos + BAT_PACKET_LEN + (num_hna * ETH_ALEN);
+	int next_buff_pos = buff_pos + BAT_PACKET_LEN + (num_tt * ETH_ALEN);
 
 	return (next_buff_pos <= packet_len) &&
 		(next_buff_pos <= MAX_AGGREGATION_BYTES);
diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
index 0e9d435..abaeec5 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -241,13 +241,13 @@ static int softif_neigh_open(struct inode *inode, struct file *file)
 static int transtable_global_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
-	return single_open(file, hna_global_seq_print_text, net_dev);
+	return single_open(file, tt_global_seq_print_text, net_dev);
 }
 
 static int transtable_local_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
-	return single_open(file, hna_local_seq_print_text, net_dev);
+	return single_open(file, tt_local_seq_print_text, net_dev);
 }
 
 static int vis_data_open(struct inode *inode, struct file *file)
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 7e2f772..dfbfccc 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -154,10 +154,10 @@ static void primary_if_select(struct bat_priv *bat_priv,
 	primary_if_update_addr(bat_priv);
 
 	/***
-	 * hacky trick to make sure that we send the HNA information via
+	 * hacky trick to make sure that we send the TT information via
 	 * our new primary interface
 	 */
-	atomic_set(&bat_priv->hna_local_changed, 1);
+	atomic_set(&bat_priv->tt_local_changed, 1);
 }
 
 static bool hardif_is_iface_up(struct hard_iface *hard_iface)
@@ -339,7 +339,7 @@ int hardif_enable_interface(struct hard_iface *hard_iface, char *iface_name)
 	batman_packet->flags = 0;
 	batman_packet->ttl = 2;
 	batman_packet->tq = TQ_MAX_VALUE;
-	batman_packet->num_hna = 0;
+	batman_packet->num_tt = 0;
 
 	hard_iface->if_num = bat_priv->num_ifaces;
 	bat_priv->num_ifaces++;
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 7edf8d7..0a7cee0 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -84,8 +84,8 @@ int mesh_init(struct net_device *soft_iface)
 
 	spin_lock_init(&bat_priv->forw_bat_list_lock);
 	spin_lock_init(&bat_priv->forw_bcast_list_lock);
-	spin_lock_init(&bat_priv->hna_lhash_lock);
-	spin_lock_init(&bat_priv->hna_ghash_lock);
+	spin_lock_init(&bat_priv->tt_lhash_lock);
+	spin_lock_init(&bat_priv->tt_ghash_lock);
 	spin_lock_init(&bat_priv->gw_list_lock);
 	spin_lock_init(&bat_priv->vis_hash_lock);
 	spin_lock_init(&bat_priv->vis_list_lock);
@@ -100,13 +100,13 @@ int mesh_init(struct net_device *soft_iface)
 	if (originator_init(bat_priv) < 1)
 		goto err;
 
-	if (hna_local_init(bat_priv) < 1)
+	if (tt_local_init(bat_priv) < 1)
 		goto err;
 
-	if (hna_global_init(bat_priv) < 1)
+	if (tt_global_init(bat_priv) < 1)
 		goto err;
 
-	hna_local_add(soft_iface, soft_iface->dev_addr);
+	tt_local_add(soft_iface, soft_iface->dev_addr);
 
 	if (vis_init(bat_priv) < 1)
 		goto err;
@@ -137,8 +137,8 @@ void mesh_free(struct net_device *soft_iface)
 	gw_node_purge(bat_priv);
 	originator_free(bat_priv);
 
-	hna_local_free(bat_priv);
-	hna_global_free(bat_priv);
+	tt_local_free(bat_priv);
+	tt_global_free(bat_priv);
 
 	softif_neigh_purge(bat_priv);
 
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index ace7285..9ef6ef9 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -39,7 +39,7 @@
 #define PURGE_TIMEOUT 200	/* purge originators after time in seconds if no
 				   * valid packet comes in -> TODO: check
 				   * influence on TQ_LOCAL_WINDOW_SIZE */
-#define LOCAL_HNA_TIMEOUT 3600 /* in seconds */
+#define TT_LOCAL_TIMEOUT 3600 /* in seconds */
 
 #define TQ_LOCAL_WINDOW_SIZE 64	  /* sliding packet range of received originator
 				   * messages in squence numbers (should be a
@@ -89,7 +89,7 @@
 
 #define DBG_BATMAN 1	/* all messages related to routing / flooding /
 			 * broadcasting / etc */
-#define DBG_ROUTES 2	/* route or hna added / changed / deleted */
+#define DBG_ROUTES 2	/* route or tt entry added / changed / deleted */
 #define DBG_ALL 3
 
 
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 51af91b..080ec883 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -142,7 +142,7 @@ static void orig_node_free_rcu(struct rcu_head *rcu)
 	spin_unlock_bh(&orig_node->neigh_list_lock);
 
 	frag_list_free(&orig_node->frag_list);
-	hna_global_del_orig(orig_node->bat_priv, orig_node,
+	tt_global_del_orig(orig_node->bat_priv, orig_node,
 			    "originator timed out");
 
 	kfree(orig_node->bcast_own);
@@ -220,7 +220,7 @@ struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr)
 	orig_node->bat_priv = bat_priv;
 	memcpy(orig_node->orig, addr, ETH_ALEN);
 	orig_node->router = NULL;
-	orig_node->hna_buff = NULL;
+	orig_node->tt_buff = NULL;
 	orig_node->bcast_seqno_reset = jiffies - 1
 					- msecs_to_jiffies(RESET_PROTECTION_MS);
 	orig_node->batman_seqno_reset = jiffies - 1
@@ -331,8 +331,8 @@ static bool purge_orig_node(struct bat_priv *bat_priv,
 							&best_neigh_node)) {
 			update_routes(bat_priv, orig_node,
 				      best_neigh_node,
-				      orig_node->hna_buff,
-				      orig_node->hna_buff_len);
+				      orig_node->tt_buff,
+				      orig_node->tt_buff_len);
 		}
 	}
 
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index e757187..c225c3a 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -61,7 +61,7 @@ struct batman_packet {
 	uint8_t  orig[6];
 	uint8_t  prev_sender[6];
 	uint8_t  ttl;
-	uint8_t  num_hna;
+	uint8_t  num_tt;
 	uint8_t  gw_flags;  /* flags related to gateway class */
 	uint8_t  align;
 } __packed;
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index d8cde2b..7648b92 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -64,28 +64,28 @@ void slide_own_bcast_window(struct hard_iface *hard_iface)
 	}
 }
 
-static void update_HNA(struct bat_priv *bat_priv, struct orig_node *orig_node,
-		       unsigned char *hna_buff, int hna_buff_len)
+static void update_TT(struct bat_priv *bat_priv, struct orig_node *orig_node,
+		       unsigned char *tt_buff, int tt_buff_len)
 {
-	if ((hna_buff_len != orig_node->hna_buff_len) ||
-	    ((hna_buff_len > 0) &&
-	     (orig_node->hna_buff_len > 0) &&
-	     (memcmp(orig_node->hna_buff, hna_buff, hna_buff_len) != 0))) {
+	if ((tt_buff_len != orig_node->tt_buff_len) ||
+	    ((tt_buff_len > 0) &&
+	     (orig_node->tt_buff_len > 0) &&
+	     (memcmp(orig_node->tt_buff, tt_buff, tt_buff_len) != 0))) {
 
-		if (orig_node->hna_buff_len > 0)
-			hna_global_del_orig(bat_priv, orig_node,
-					    "originator changed hna");
+		if (orig_node->tt_buff_len > 0)
+			tt_global_del_orig(bat_priv, orig_node,
+					    "originator changed tt");
 
-		if ((hna_buff_len > 0) && (hna_buff))
-			hna_global_add_orig(bat_priv, orig_node,
-					    hna_buff, hna_buff_len);
+		if ((tt_buff_len > 0) && (tt_buff))
+			tt_global_add_orig(bat_priv, orig_node,
+					    tt_buff, tt_buff_len);
 	}
 }
 
 static void update_route(struct bat_priv *bat_priv,
 			 struct orig_node *orig_node,
 			 struct neigh_node *neigh_node,
-			 unsigned char *hna_buff, int hna_buff_len)
+			 unsigned char *tt_buff, int tt_buff_len)
 {
 	struct neigh_node *curr_router;
 
@@ -96,7 +96,7 @@ static void update_route(struct bat_priv *bat_priv,
 
 		bat_dbg(DBG_ROUTES, bat_priv, "Deleting route towards: %pM\n",
 			orig_node->orig);
-		hna_global_del_orig(bat_priv, orig_node,
+		tt_global_del_orig(bat_priv, orig_node,
 				    "originator timed out");
 
 	/* route added */
@@ -105,8 +105,8 @@ static void update_route(struct bat_priv *bat_priv,
 		bat_dbg(DBG_ROUTES, bat_priv,
 			"Adding route towards: %pM (via %pM)\n",
 			orig_node->orig, neigh_node->addr);
-		hna_global_add_orig(bat_priv, orig_node,
-				    hna_buff, hna_buff_len);
+		tt_global_add_orig(bat_priv, orig_node,
+				    tt_buff, tt_buff_len);
 
 	/* route changed */
 	} else {
@@ -135,8 +135,8 @@ static void update_route(struct bat_priv *bat_priv,
 
 
 void update_routes(struct bat_priv *bat_priv, struct orig_node *orig_node,
-		   struct neigh_node *neigh_node, unsigned char *hna_buff,
-		   int hna_buff_len)
+		   struct neigh_node *neigh_node, unsigned char *tt_buff,
+		   int tt_buff_len)
 {
 	struct neigh_node *router = NULL;
 
@@ -147,10 +147,10 @@ void update_routes(struct bat_priv *bat_priv, struct orig_node *orig_node,
 
 	if (router != neigh_node)
 		update_route(bat_priv, orig_node, neigh_node,
-			     hna_buff, hna_buff_len);
-	/* may be just HNA changed */
+			     tt_buff, tt_buff_len);
+	/* may be just TT changed */
 	else
-		update_HNA(bat_priv, orig_node, hna_buff, hna_buff_len);
+		update_TT(bat_priv, orig_node, tt_buff, tt_buff_len);
 
 out:
 	if (router)
@@ -387,14 +387,14 @@ static void update_orig(struct bat_priv *bat_priv,
 			struct ethhdr *ethhdr,
 			struct batman_packet *batman_packet,
 			struct hard_iface *if_incoming,
-			unsigned char *hna_buff, int hna_buff_len,
+			unsigned char *tt_buff, int tt_buff_len,
 			char is_duplicate)
 {
 	struct neigh_node *neigh_node = NULL, *tmp_neigh_node = NULL;
 	struct neigh_node *router = NULL;
 	struct orig_node *orig_node_tmp;
 	struct hlist_node *node;
-	int tmp_hna_buff_len;
+	int tmp_tt_buff_len;
 	uint8_t bcast_own_sum_orig, bcast_own_sum_neigh;
 
 	bat_dbg(DBG_BATMAN, bat_priv, "update_originator(): "
@@ -459,18 +459,18 @@ static void update_orig(struct bat_priv *bat_priv,
 
 	bonding_candidate_add(orig_node, neigh_node);
 
-	tmp_hna_buff_len = (hna_buff_len > batman_packet->num_hna * ETH_ALEN ?
-			    batman_packet->num_hna * ETH_ALEN : hna_buff_len);
+	tmp_tt_buff_len = (tt_buff_len > batman_packet->num_tt * ETH_ALEN ?
+			    batman_packet->num_tt * ETH_ALEN : tt_buff_len);
 
 	/* if this neighbor already is our next hop there is nothing
 	 * to change */
 	router = orig_node_get_router(orig_node);
 	if (router == neigh_node)
-		goto update_hna;
+		goto update_tt;
 
 	/* if this neighbor does not offer a better TQ we won't consider it */
 	if (router && (router->tq_avg > neigh_node->tq_avg))
-		goto update_hna;
+		goto update_tt;
 
 	/* if the TQ is the same and the link not more symetric we
 	 * won't consider it either */
@@ -488,16 +488,16 @@ static void update_orig(struct bat_priv *bat_priv,
 		spin_unlock_bh(&orig_node_tmp->ogm_cnt_lock);
 
 		if (bcast_own_sum_orig >= bcast_own_sum_neigh)
-			goto update_hna;
+			goto update_tt;
 	}
 
 	update_routes(bat_priv, orig_node, neigh_node,
-		      hna_buff, tmp_hna_buff_len);
+		      tt_buff, tmp_tt_buff_len);
 	goto update_gw;
 
-update_hna:
+update_tt:
 	update_routes(bat_priv, orig_node, router,
-		      hna_buff, tmp_hna_buff_len);
+		      tt_buff, tmp_tt_buff_len);
 
 update_gw:
 	if (orig_node->gw_flags != batman_packet->gw_flags)
@@ -621,7 +621,7 @@ out:
 
 void receive_bat_packet(struct ethhdr *ethhdr,
 			struct batman_packet *batman_packet,
-			unsigned char *hna_buff, int hna_buff_len,
+			unsigned char *tt_buff, int tt_buff_len,
 			struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
@@ -818,14 +818,14 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 	     ((orig_node->last_real_seqno == batman_packet->seqno) &&
 	      (orig_node->last_ttl - 3 <= batman_packet->ttl))))
 		update_orig(bat_priv, orig_node, ethhdr, batman_packet,
-			    if_incoming, hna_buff, hna_buff_len, is_duplicate);
+			    if_incoming, tt_buff, tt_buff_len, is_duplicate);
 
 	/* is single hop (direct) neighbor */
 	if (is_single_hop_neigh) {
 
 		/* mark direct link on incoming interface */
 		schedule_forward_packet(orig_node, ethhdr, batman_packet,
-					1, hna_buff_len, if_incoming);
+					1, tt_buff_len, if_incoming);
 
 		bat_dbg(DBG_BATMAN, bat_priv, "Forwarding packet: "
 			"rebroadcast neighbor packet with direct link flag\n");
@@ -848,7 +848,7 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 	bat_dbg(DBG_BATMAN, bat_priv,
 		"Forwarding packet: rebroadcast originator packet\n");
 	schedule_forward_packet(orig_node, ethhdr, batman_packet,
-				0, hna_buff_len, if_incoming);
+				0, tt_buff_len, if_incoming);
 
 out_neigh:
 	if ((orig_neigh_node) && (!is_single_hop_neigh))
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index b5a064c..870f298 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -25,11 +25,11 @@
 void slide_own_bcast_window(struct hard_iface *hard_iface);
 void receive_bat_packet(struct ethhdr *ethhdr,
 				struct batman_packet *batman_packet,
-				unsigned char *hna_buff, int hna_buff_len,
+				unsigned char *tt_buff, int tt_buff_len,
 				struct hard_iface *if_incoming);
 void update_routes(struct bat_priv *bat_priv, struct orig_node *orig_node,
-		   struct neigh_node *neigh_node, unsigned char *hna_buff,
-		   int hna_buff_len);
+		   struct neigh_node *neigh_node, unsigned char *tt_buff,
+		   int tt_buff_len);
 int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if);
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 02b541a..f30d0c6 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -121,7 +121,7 @@ static void send_packet_to_if(struct forw_packet *forw_packet,
 	/* adjust all flags and log packets */
 	while (aggregated_packet(buff_pos,
 				 forw_packet->packet_len,
-				 batman_packet->num_hna)) {
+				 batman_packet->num_tt)) {
 
 		/* we might have aggregated direct link packets with an
 		 * ordinary base packet */
@@ -146,7 +146,7 @@ static void send_packet_to_if(struct forw_packet *forw_packet,
 			hard_iface->net_dev->dev_addr);
 
 		buff_pos += sizeof(struct batman_packet) +
-			(batman_packet->num_hna * ETH_ALEN);
+			(batman_packet->num_tt * ETH_ALEN);
 		packet_num++;
 		batman_packet = (struct batman_packet *)
 			(forw_packet->skb->data + buff_pos);
@@ -222,7 +222,7 @@ static void rebuild_batman_packet(struct bat_priv *bat_priv,
 	struct batman_packet *batman_packet;
 
 	new_len = sizeof(struct batman_packet) +
-			(bat_priv->num_local_hna * ETH_ALEN);
+			(bat_priv->num_local_tt * ETH_ALEN);
 	new_buff = kmalloc(new_len, GFP_ATOMIC);
 
 	/* keep old buffer if kmalloc should fail */
@@ -231,7 +231,7 @@ static void rebuild_batman_packet(struct bat_priv *bat_priv,
 		       sizeof(struct batman_packet));
 		batman_packet = (struct batman_packet *)new_buff;
 
-		batman_packet->num_hna = hna_local_fill_buffer(bat_priv,
+		batman_packet->num_tt = tt_local_fill_buffer(bat_priv,
 				new_buff + sizeof(struct batman_packet),
 				new_len - sizeof(struct batman_packet));
 
@@ -266,8 +266,8 @@ void schedule_own_packet(struct hard_iface *hard_iface)
 	if (hard_iface->if_status == IF_TO_BE_ACTIVATED)
 		hard_iface->if_status = IF_ACTIVE;
 
-	/* if local hna has changed and interface is a primary interface */
-	if ((atomic_read(&bat_priv->hna_local_changed)) &&
+	/* if local tt has changed and interface is a primary interface */
+	if ((atomic_read(&bat_priv->tt_local_changed)) &&
 	    (hard_iface == primary_if))
 		rebuild_batman_packet(bat_priv, hard_iface);
 
@@ -309,7 +309,7 @@ void schedule_own_packet(struct hard_iface *hard_iface)
 void schedule_forward_packet(struct orig_node *orig_node,
 			     struct ethhdr *ethhdr,
 			     struct batman_packet *batman_packet,
-			     uint8_t directlink, int hna_buff_len,
+			     uint8_t directlink, int tt_buff_len,
 			     struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
@@ -369,7 +369,7 @@ void schedule_forward_packet(struct orig_node *orig_node,
 	send_time = forward_send_time();
 	add_bat_packet_to_list(bat_priv,
 			       (unsigned char *)batman_packet,
-			       sizeof(struct batman_packet) + hna_buff_len,
+			       sizeof(struct batman_packet) + tt_buff_len,
 			       if_incoming, 0, send_time);
 }
 
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 7b2ff19..247172d 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -29,7 +29,7 @@ void schedule_own_packet(struct hard_iface *hard_iface);
 void schedule_forward_packet(struct orig_node *orig_node,
 			     struct ethhdr *ethhdr,
 			     struct batman_packet *batman_packet,
-			     uint8_t directlink, int hna_buff_len,
+			     uint8_t directlink, int tt_buff_len,
 			     struct hard_iface *if_outgoing);
 int add_bcast_packet_to_list(struct bat_priv *bat_priv, struct sk_buff *skb);
 void send_outstanding_bat_packet(struct work_struct *work);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 9301e21..d6aaf9f 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -543,11 +543,11 @@ static int interface_set_mac_addr(struct net_device *dev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
-	/* only modify hna-table if it has been initialised before */
+	/* only modify transtable if it has been initialised before */
 	if (atomic_read(&bat_priv->mesh_state) == MESH_ACTIVE) {
-		hna_local_remove(bat_priv, dev->dev_addr,
+		tt_local_remove(bat_priv, dev->dev_addr,
 				 "mac address changed");
-		hna_local_add(dev, addr->sa_data);
+		tt_local_add(dev, addr->sa_data);
 	}
 
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
@@ -605,7 +605,7 @@ int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 		goto dropped;
 
 	/* TODO: check this for locks */
-	hna_local_add(soft_iface, ethhdr->h_source);
+	tt_local_add(soft_iface, ethhdr->h_source);
 
 	if (is_multicast_ether_addr(ethhdr->h_dest)) {
 		ret = gw_is_target(bat_priv, skb);
@@ -843,7 +843,7 @@ struct net_device *softif_create(char *name)
 
 	atomic_set(&bat_priv->mesh_state, MESH_INACTIVE);
 	atomic_set(&bat_priv->bcast_seqno, 1);
-	atomic_set(&bat_priv->hna_local_changed, 0);
+	atomic_set(&bat_priv->tt_local_changed, 0);
 
 	bat_priv->primary_if = NULL;
 	bat_priv->num_ifaces = 0;
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index f931830..7b72966 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -26,40 +26,40 @@
 #include "hash.h"
 #include "originator.h"
 
-static void hna_local_purge(struct work_struct *work);
-static void _hna_global_del_orig(struct bat_priv *bat_priv,
-				 struct hna_global_entry *hna_global_entry,
+static void tt_local_purge(struct work_struct *work);
+static void _tt_global_del_orig(struct bat_priv *bat_priv,
+				 struct tt_global_entry *tt_global_entry,
 				 char *message);
 
 /* returns 1 if they are the same mac addr */
-static int compare_lhna(struct hlist_node *node, void *data2)
+static int compare_ltt(struct hlist_node *node, void *data2)
 {
-	void *data1 = container_of(node, struct hna_local_entry, hash_entry);
+	void *data1 = container_of(node, struct tt_local_entry, hash_entry);
 
 	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
 }
 
 /* returns 1 if they are the same mac addr */
-static int compare_ghna(struct hlist_node *node, void *data2)
+static int compare_gtt(struct hlist_node *node, void *data2)
 {
-	void *data1 = container_of(node, struct hna_global_entry, hash_entry);
+	void *data1 = container_of(node, struct tt_global_entry, hash_entry);
 
 	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
 }
 
-static void hna_local_start_timer(struct bat_priv *bat_priv)
+static void tt_local_start_timer(struct bat_priv *bat_priv)
 {
-	INIT_DELAYED_WORK(&bat_priv->hna_work, hna_local_purge);
-	queue_delayed_work(bat_event_workqueue, &bat_priv->hna_work, 10 * HZ);
+	INIT_DELAYED_WORK(&bat_priv->tt_work, tt_local_purge);
+	queue_delayed_work(bat_event_workqueue, &bat_priv->tt_work, 10 * HZ);
 }
 
-static struct hna_local_entry *hna_local_hash_find(struct bat_priv *bat_priv,
+static struct tt_local_entry *tt_local_hash_find(struct bat_priv *bat_priv,
 						   void *data)
 {
-	struct hashtable_t *hash = bat_priv->hna_local_hash;
+	struct hashtable_t *hash = bat_priv->tt_local_hash;
 	struct hlist_head *head;
 	struct hlist_node *node;
-	struct hna_local_entry *hna_local_entry, *hna_local_entry_tmp = NULL;
+	struct tt_local_entry *tt_local_entry, *tt_local_entry_tmp = NULL;
 	int index;
 
 	if (!hash)
@@ -69,26 +69,26 @@ static struct hna_local_entry *hna_local_hash_find(struct bat_priv *bat_priv,
 	head = &hash->table[index];
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(hna_local_entry, node, head, hash_entry) {
-		if (!compare_eth(hna_local_entry, data))
+	hlist_for_each_entry_rcu(tt_local_entry, node, head, hash_entry) {
+		if (!compare_eth(tt_local_entry, data))
 			continue;
 
-		hna_local_entry_tmp = hna_local_entry;
+		tt_local_entry_tmp = tt_local_entry;
 		break;
 	}
 	rcu_read_unlock();
 
-	return hna_local_entry_tmp;
+	return tt_local_entry_tmp;
 }
 
-static struct hna_global_entry *hna_global_hash_find(struct bat_priv *bat_priv,
+static struct tt_global_entry *tt_global_hash_find(struct bat_priv *bat_priv,
 						     void *data)
 {
-	struct hashtable_t *hash = bat_priv->hna_global_hash;
+	struct hashtable_t *hash = bat_priv->tt_global_hash;
 	struct hlist_head *head;
 	struct hlist_node *node;
-	struct hna_global_entry *hna_global_entry;
-	struct hna_global_entry *hna_global_entry_tmp = NULL;
+	struct tt_global_entry *tt_global_entry;
+	struct tt_global_entry *tt_global_entry_tmp = NULL;
 	int index;
 
 	if (!hash)
@@ -98,125 +98,125 @@ static struct hna_global_entry *hna_global_hash_find(struct bat_priv *bat_priv,
 	head = &hash->table[index];
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(hna_global_entry, node, head, hash_entry) {
-		if (!compare_eth(hna_global_entry, data))
+	hlist_for_each_entry_rcu(tt_global_entry, node, head, hash_entry) {
+		if (!compare_eth(tt_global_entry, data))
 			continue;
 
-		hna_global_entry_tmp = hna_global_entry;
+		tt_global_entry_tmp = tt_global_entry;
 		break;
 	}
 	rcu_read_unlock();
 
-	return hna_global_entry_tmp;
+	return tt_global_entry_tmp;
 }
 
-int hna_local_init(struct bat_priv *bat_priv)
+int tt_local_init(struct bat_priv *bat_priv)
 {
-	if (bat_priv->hna_local_hash)
+	if (bat_priv->tt_local_hash)
 		return 1;
 
-	bat_priv->hna_local_hash = hash_new(1024);
+	bat_priv->tt_local_hash = hash_new(1024);
 
-	if (!bat_priv->hna_local_hash)
+	if (!bat_priv->tt_local_hash)
 		return 0;
 
-	atomic_set(&bat_priv->hna_local_changed, 0);
-	hna_local_start_timer(bat_priv);
+	atomic_set(&bat_priv->tt_local_changed, 0);
+	tt_local_start_timer(bat_priv);
 
 	return 1;
 }
 
-void hna_local_add(struct net_device *soft_iface, uint8_t *addr)
+void tt_local_add(struct net_device *soft_iface, uint8_t *addr)
 {
 	struct bat_priv *bat_priv = netdev_priv(soft_iface);
-	struct hna_local_entry *hna_local_entry;
-	struct hna_global_entry *hna_global_entry;
+	struct tt_local_entry *tt_local_entry;
+	struct tt_global_entry *tt_global_entry;
 	int required_bytes;
 
-	spin_lock_bh(&bat_priv->hna_lhash_lock);
-	hna_local_entry = hna_local_hash_find(bat_priv, addr);
-	spin_unlock_bh(&bat_priv->hna_lhash_lock);
+	spin_lock_bh(&bat_priv->tt_lhash_lock);
+	tt_local_entry = tt_local_hash_find(bat_priv, addr);
+	spin_unlock_bh(&bat_priv->tt_lhash_lock);
 
-	if (hna_local_entry) {
-		hna_local_entry->last_seen = jiffies;
+	if (tt_local_entry) {
+		tt_local_entry->last_seen = jiffies;
 		return;
 	}
 
 	/* only announce as many hosts as possible in the batman-packet and
-	   space in batman_packet->num_hna That also should give a limit to
+	   space in batman_packet->num_tt That also should give a limit to
 	   MAC-flooding. */
-	required_bytes = (bat_priv->num_local_hna + 1) * ETH_ALEN;
+	required_bytes = (bat_priv->num_local_tt + 1) * ETH_ALEN;
 	required_bytes += BAT_PACKET_LEN;
 
 	if ((required_bytes > ETH_DATA_LEN) ||
 	    (atomic_read(&bat_priv->aggregated_ogms) &&
 	     required_bytes > MAX_AGGREGATION_BYTES) ||
-	    (bat_priv->num_local_hna + 1 > 255)) {
+	    (bat_priv->num_local_tt + 1 > 255)) {
 		bat_dbg(DBG_ROUTES, bat_priv,
-			"Can't add new local hna entry (%pM): "
-			"number of local hna entries exceeds packet size\n",
+			"Can't add new local tt entry (%pM): "
+			"number of local tt entries exceeds packet size\n",
 			addr);
 		return;
 	}
 
 	bat_dbg(DBG_ROUTES, bat_priv,
-		"Creating new local hna entry: %pM\n", addr);
+		"Creating new local tt entry: %pM\n", addr);
 
-	hna_local_entry = kmalloc(sizeof(struct hna_local_entry), GFP_ATOMIC);
-	if (!hna_local_entry)
+	tt_local_entry = kmalloc(sizeof(struct tt_local_entry), GFP_ATOMIC);
+	if (!tt_local_entry)
 		return;
 
-	memcpy(hna_local_entry->addr, addr, ETH_ALEN);
-	hna_local_entry->last_seen = jiffies;
+	memcpy(tt_local_entry->addr, addr, ETH_ALEN);
+	tt_local_entry->last_seen = jiffies;
 
 	/* the batman interface mac address should never be purged */
 	if (compare_eth(addr, soft_iface->dev_addr))
-		hna_local_entry->never_purge = 1;
+		tt_local_entry->never_purge = 1;
 	else
-		hna_local_entry->never_purge = 0;
+		tt_local_entry->never_purge = 0;
 
-	spin_lock_bh(&bat_priv->hna_lhash_lock);
+	spin_lock_bh(&bat_priv->tt_lhash_lock);
 
-	hash_add(bat_priv->hna_local_hash, compare_lhna, choose_orig,
-		 hna_local_entry, &hna_local_entry->hash_entry);
-	bat_priv->num_local_hna++;
-	atomic_set(&bat_priv->hna_local_changed, 1);
+	hash_add(bat_priv->tt_local_hash, compare_ltt, choose_orig,
+		 tt_local_entry, &tt_local_entry->hash_entry);
+	bat_priv->num_local_tt++;
+	atomic_set(&bat_priv->tt_local_changed, 1);
 
-	spin_unlock_bh(&bat_priv->hna_lhash_lock);
+	spin_unlock_bh(&bat_priv->tt_lhash_lock);
 
 	/* remove address from global hash if present */
-	spin_lock_bh(&bat_priv->hna_ghash_lock);
+	spin_lock_bh(&bat_priv->tt_ghash_lock);
 
-	hna_global_entry = hna_global_hash_find(bat_priv, addr);
+	tt_global_entry = tt_global_hash_find(bat_priv, addr);
 
-	if (hna_global_entry)
-		_hna_global_del_orig(bat_priv, hna_global_entry,
-				     "local hna received");
+	if (tt_global_entry)
+		_tt_global_del_orig(bat_priv, tt_global_entry,
+				     "local tt received");
 
-	spin_unlock_bh(&bat_priv->hna_ghash_lock);
+	spin_unlock_bh(&bat_priv->tt_ghash_lock);
 }
 
-int hna_local_fill_buffer(struct bat_priv *bat_priv,
+int tt_local_fill_buffer(struct bat_priv *bat_priv,
 			  unsigned char *buff, int buff_len)
 {
-	struct hashtable_t *hash = bat_priv->hna_local_hash;
-	struct hna_local_entry *hna_local_entry;
+	struct hashtable_t *hash = bat_priv->tt_local_hash;
+	struct tt_local_entry *tt_local_entry;
 	struct hlist_node *node;
 	struct hlist_head *head;
 	int i, count = 0;
 
-	spin_lock_bh(&bat_priv->hna_lhash_lock);
+	spin_lock_bh(&bat_priv->tt_lhash_lock);
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
 		rcu_read_lock();
-		hlist_for_each_entry_rcu(hna_local_entry, node,
+		hlist_for_each_entry_rcu(tt_local_entry, node,
 					 head, hash_entry) {
 			if (buff_len < (count + 1) * ETH_ALEN)
 				break;
 
-			memcpy(buff + (count * ETH_ALEN), hna_local_entry->addr,
+			memcpy(buff + (count * ETH_ALEN), tt_local_entry->addr,
 			       ETH_ALEN);
 
 			count++;
@@ -224,20 +224,20 @@ int hna_local_fill_buffer(struct bat_priv *bat_priv,
 		rcu_read_unlock();
 	}
 
-	/* if we did not get all new local hnas see you next time  ;-) */
-	if (count == bat_priv->num_local_hna)
-		atomic_set(&bat_priv->hna_local_changed, 0);
+	/* if we did not get all new local tts see you next time  ;-) */
+	if (count == bat_priv->num_local_tt)
+		atomic_set(&bat_priv->tt_local_changed, 0);
 
-	spin_unlock_bh(&bat_priv->hna_lhash_lock);
+	spin_unlock_bh(&bat_priv->tt_lhash_lock);
 	return count;
 }
 
-int hna_local_seq_print_text(struct seq_file *seq, void *offset)
+int tt_local_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct net_device *net_dev = (struct net_device *)seq->private;
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
-	struct hashtable_t *hash = bat_priv->hna_local_hash;
-	struct hna_local_entry *hna_local_entry;
+	struct hashtable_t *hash = bat_priv->tt_local_hash;
+	struct tt_local_entry *tt_local_entry;
 	struct hard_iface *primary_if;
 	struct hlist_node *node;
 	struct hlist_head *head;
@@ -261,10 +261,10 @@ int hna_local_seq_print_text(struct seq_file *seq, void *offset)
 	}
 
 	seq_printf(seq, "Locally retrieved addresses (from %s) "
-		   "announced via HNA:\n",
+		   "announced via TT:\n",
 		   net_dev->name);
 
-	spin_lock_bh(&bat_priv->hna_lhash_lock);
+	spin_lock_bh(&bat_priv->tt_lhash_lock);
 
 	buf_size = 1;
 	/* Estimate length for: " * xx:xx:xx:xx:xx:xx\n" */
@@ -279,7 +279,7 @@ int hna_local_seq_print_text(struct seq_file *seq, void *offset)
 
 	buff = kmalloc(buf_size, GFP_ATOMIC);
 	if (!buff) {
-		spin_unlock_bh(&bat_priv->hna_lhash_lock);
+		spin_unlock_bh(&bat_priv->tt_lhash_lock);
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -291,15 +291,15 @@ int hna_local_seq_print_text(struct seq_file *seq, void *offset)
 		head = &hash->table[i];
 
 		rcu_read_lock();
-		hlist_for_each_entry_rcu(hna_local_entry, node,
+		hlist_for_each_entry_rcu(tt_local_entry, node,
 					 head, hash_entry) {
 			pos += snprintf(buff + pos, 22, " * %pM\n",
-					hna_local_entry->addr);
+					tt_local_entry->addr);
 		}
 		rcu_read_unlock();
 	}
 
-	spin_unlock_bh(&bat_priv->hna_lhash_lock);
+	spin_unlock_bh(&bat_priv->tt_lhash_lock);
 
 	seq_printf(seq, "%s", buff);
 	kfree(buff);
@@ -309,180 +309,180 @@ out:
 	return ret;
 }
 
-static void _hna_local_del(struct hlist_node *node, void *arg)
+static void _tt_local_del(struct hlist_node *node, void *arg)
 {
 	struct bat_priv *bat_priv = (struct bat_priv *)arg;
-	void *data = container_of(node, struct hna_local_entry, hash_entry);
+	void *data = container_of(node, struct tt_local_entry, hash_entry);
 
 	kfree(data);
-	bat_priv->num_local_hna--;
-	atomic_set(&bat_priv->hna_local_changed, 1);
+	bat_priv->num_local_tt--;
+	atomic_set(&bat_priv->tt_local_changed, 1);
 }
 
-static void hna_local_del(struct bat_priv *bat_priv,
-			  struct hna_local_entry *hna_local_entry,
+static void tt_local_del(struct bat_priv *bat_priv,
+			  struct tt_local_entry *tt_local_entry,
 			  char *message)
 {
-	bat_dbg(DBG_ROUTES, bat_priv, "Deleting local hna entry (%pM): %s\n",
-		hna_local_entry->addr, message);
+	bat_dbg(DBG_ROUTES, bat_priv, "Deleting local tt entry (%pM): %s\n",
+		tt_local_entry->addr, message);
 
-	hash_remove(bat_priv->hna_local_hash, compare_lhna, choose_orig,
-		    hna_local_entry->addr);
-	_hna_local_del(&hna_local_entry->hash_entry, bat_priv);
+	hash_remove(bat_priv->tt_local_hash, compare_ltt, choose_orig,
+		    tt_local_entry->addr);
+	_tt_local_del(&tt_local_entry->hash_entry, bat_priv);
 }
 
-void hna_local_remove(struct bat_priv *bat_priv,
+void tt_local_remove(struct bat_priv *bat_priv,
 		      uint8_t *addr, char *message)
 {
-	struct hna_local_entry *hna_local_entry;
+	struct tt_local_entry *tt_local_entry;
 
-	spin_lock_bh(&bat_priv->hna_lhash_lock);
+	spin_lock_bh(&bat_priv->tt_lhash_lock);
 
-	hna_local_entry = hna_local_hash_find(bat_priv, addr);
+	tt_local_entry = tt_local_hash_find(bat_priv, addr);
 
-	if (hna_local_entry)
-		hna_local_del(bat_priv, hna_local_entry, message);
+	if (tt_local_entry)
+		tt_local_del(bat_priv, tt_local_entry, message);
 
-	spin_unlock_bh(&bat_priv->hna_lhash_lock);
+	spin_unlock_bh(&bat_priv->tt_lhash_lock);
 }
 
-static void hna_local_purge(struct work_struct *work)
+static void tt_local_purge(struct work_struct *work)
 {
 	struct delayed_work *delayed_work =
 		container_of(work, struct delayed_work, work);
 	struct bat_priv *bat_priv =
-		container_of(delayed_work, struct bat_priv, hna_work);
-	struct hashtable_t *hash = bat_priv->hna_local_hash;
-	struct hna_local_entry *hna_local_entry;
+		container_of(delayed_work, struct bat_priv, tt_work);
+	struct hashtable_t *hash = bat_priv->tt_local_hash;
+	struct tt_local_entry *tt_local_entry;
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
 	unsigned long timeout;
 	int i;
 
-	spin_lock_bh(&bat_priv->hna_lhash_lock);
+	spin_lock_bh(&bat_priv->tt_lhash_lock);
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
-		hlist_for_each_entry_safe(hna_local_entry, node, node_tmp,
+		hlist_for_each_entry_safe(tt_local_entry, node, node_tmp,
 					  head, hash_entry) {
-			if (hna_local_entry->never_purge)
+			if (tt_local_entry->never_purge)
 				continue;
 
-			timeout = hna_local_entry->last_seen;
-			timeout += LOCAL_HNA_TIMEOUT * HZ;
+			timeout = tt_local_entry->last_seen;
+			timeout += TT_LOCAL_TIMEOUT * HZ;
 
 			if (time_before(jiffies, timeout))
 				continue;
 
-			hna_local_del(bat_priv, hna_local_entry,
+			tt_local_del(bat_priv, tt_local_entry,
 				      "address timed out");
 		}
 	}
 
-	spin_unlock_bh(&bat_priv->hna_lhash_lock);
-	hna_local_start_timer(bat_priv);
+	spin_unlock_bh(&bat_priv->tt_lhash_lock);
+	tt_local_start_timer(bat_priv);
 }
 
-void hna_local_free(struct bat_priv *bat_priv)
+void tt_local_free(struct bat_priv *bat_priv)
 {
-	if (!bat_priv->hna_local_hash)
+	if (!bat_priv->tt_local_hash)
 		return;
 
-	cancel_delayed_work_sync(&bat_priv->hna_work);
-	hash_delete(bat_priv->hna_local_hash, _hna_local_del, bat_priv);
-	bat_priv->hna_local_hash = NULL;
+	cancel_delayed_work_sync(&bat_priv->tt_work);
+	hash_delete(bat_priv->tt_local_hash, _tt_local_del, bat_priv);
+	bat_priv->tt_local_hash = NULL;
 }
 
-int hna_global_init(struct bat_priv *bat_priv)
+int tt_global_init(struct bat_priv *bat_priv)
 {
-	if (bat_priv->hna_global_hash)
+	if (bat_priv->tt_global_hash)
 		return 1;
 
-	bat_priv->hna_global_hash = hash_new(1024);
+	bat_priv->tt_global_hash = hash_new(1024);
 
-	if (!bat_priv->hna_global_hash)
+	if (!bat_priv->tt_global_hash)
 		return 0;
 
 	return 1;
 }
 
-void hna_global_add_orig(struct bat_priv *bat_priv,
+void tt_global_add_orig(struct bat_priv *bat_priv,
 			 struct orig_node *orig_node,
-			 unsigned char *hna_buff, int hna_buff_len)
+			 unsigned char *tt_buff, int tt_buff_len)
 {
-	struct hna_global_entry *hna_global_entry;
-	struct hna_local_entry *hna_local_entry;
-	int hna_buff_count = 0;
-	unsigned char *hna_ptr;
+	struct tt_global_entry *tt_global_entry;
+	struct tt_local_entry *tt_local_entry;
+	int tt_buff_count = 0;
+	unsigned char *tt_ptr;
 
-	while ((hna_buff_count + 1) * ETH_ALEN <= hna_buff_len) {
-		spin_lock_bh(&bat_priv->hna_ghash_lock);
+	while ((tt_buff_count + 1) * ETH_ALEN <= tt_buff_len) {
+		spin_lock_bh(&bat_priv->tt_ghash_lock);
 
-		hna_ptr = hna_buff + (hna_buff_count * ETH_ALEN);
-		hna_global_entry = hna_global_hash_find(bat_priv, hna_ptr);
+		tt_ptr = tt_buff + (tt_buff_count * ETH_ALEN);
+		tt_global_entry = tt_global_hash_find(bat_priv, tt_ptr);
 
-		if (!hna_global_entry) {
-			spin_unlock_bh(&bat_priv->hna_ghash_lock);
+		if (!tt_global_entry) {
+			spin_unlock_bh(&bat_priv->tt_ghash_lock);
 
-			hna_global_entry =
-				kmalloc(sizeof(struct hna_global_entry),
+			tt_global_entry =
+				kmalloc(sizeof(struct tt_global_entry),
 					GFP_ATOMIC);
 
-			if (!hna_global_entry)
+			if (!tt_global_entry)
 				break;
 
-			memcpy(hna_global_entry->addr, hna_ptr, ETH_ALEN);
+			memcpy(tt_global_entry->addr, tt_ptr, ETH_ALEN);
 
 			bat_dbg(DBG_ROUTES, bat_priv,
-				"Creating new global hna entry: "
+				"Creating new global tt entry: "
 				"%pM (via %pM)\n",
-				hna_global_entry->addr, orig_node->orig);
+				tt_global_entry->addr, orig_node->orig);
 
-			spin_lock_bh(&bat_priv->hna_ghash_lock);
-			hash_add(bat_priv->hna_global_hash, compare_ghna,
-				 choose_orig, hna_global_entry,
-				 &hna_global_entry->hash_entry);
+			spin_lock_bh(&bat_priv->tt_ghash_lock);
+			hash_add(bat_priv->tt_global_hash, compare_gtt,
+				 choose_orig, tt_global_entry,
+				 &tt_global_entry->hash_entry);
 
 		}
 
-		hna_global_entry->orig_node = orig_node;
-		spin_unlock_bh(&bat_priv->hna_ghash_lock);
+		tt_global_entry->orig_node = orig_node;
+		spin_unlock_bh(&bat_priv->tt_ghash_lock);
 
 		/* remove address from local hash if present */
-		spin_lock_bh(&bat_priv->hna_lhash_lock);
+		spin_lock_bh(&bat_priv->tt_lhash_lock);
 
-		hna_ptr = hna_buff + (hna_buff_count * ETH_ALEN);
-		hna_local_entry = hna_local_hash_find(bat_priv, hna_ptr);
+		tt_ptr = tt_buff + (tt_buff_count * ETH_ALEN);
+		tt_local_entry = tt_local_hash_find(bat_priv, tt_ptr);
 
-		if (hna_local_entry)
-			hna_local_del(bat_priv, hna_local_entry,
-				      "global hna received");
+		if (tt_local_entry)
+			tt_local_del(bat_priv, tt_local_entry,
+				      "global tt received");
 
-		spin_unlock_bh(&bat_priv->hna_lhash_lock);
+		spin_unlock_bh(&bat_priv->tt_lhash_lock);
 
-		hna_buff_count++;
+		tt_buff_count++;
 	}
 
 	/* initialize, and overwrite if malloc succeeds */
-	orig_node->hna_buff = NULL;
-	orig_node->hna_buff_len = 0;
+	orig_node->tt_buff = NULL;
+	orig_node->tt_buff_len = 0;
 
-	if (hna_buff_len > 0) {
-		orig_node->hna_buff = kmalloc(hna_buff_len, GFP_ATOMIC);
-		if (orig_node->hna_buff) {
-			memcpy(orig_node->hna_buff, hna_buff, hna_buff_len);
-			orig_node->hna_buff_len = hna_buff_len;
+	if (tt_buff_len > 0) {
+		orig_node->tt_buff = kmalloc(tt_buff_len, GFP_ATOMIC);
+		if (orig_node->tt_buff) {
+			memcpy(orig_node->tt_buff, tt_buff, tt_buff_len);
+			orig_node->tt_buff_len = tt_buff_len;
 		}
 	}
 }
 
-int hna_global_seq_print_text(struct seq_file *seq, void *offset)
+int tt_global_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct net_device *net_dev = (struct net_device *)seq->private;
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
-	struct hashtable_t *hash = bat_priv->hna_global_hash;
-	struct hna_global_entry *hna_global_entry;
+	struct hashtable_t *hash = bat_priv->tt_global_hash;
+	struct tt_global_entry *tt_global_entry;
 	struct hard_iface *primary_if;
 	struct hlist_node *node;
 	struct hlist_head *head;
@@ -505,10 +505,11 @@ int hna_global_seq_print_text(struct seq_file *seq, void *offset)
 		goto out;
 	}
 
-	seq_printf(seq, "Globally announced HNAs received via the mesh %s\n",
+	seq_printf(seq,
+		   "Globally announced TT entries received via the mesh %s\n",
 		   net_dev->name);
 
-	spin_lock_bh(&bat_priv->hna_ghash_lock);
+	spin_lock_bh(&bat_priv->tt_ghash_lock);
 
 	buf_size = 1;
 	/* Estimate length for: " * xx:xx:xx:xx:xx:xx via xx:xx:xx:xx:xx:xx\n"*/
@@ -523,7 +524,7 @@ int hna_global_seq_print_text(struct seq_file *seq, void *offset)
 
 	buff = kmalloc(buf_size, GFP_ATOMIC);
 	if (!buff) {
-		spin_unlock_bh(&bat_priv->hna_ghash_lock);
+		spin_unlock_bh(&bat_priv->tt_ghash_lock);
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -534,17 +535,17 @@ int hna_global_seq_print_text(struct seq_file *seq, void *offset)
 		head = &hash->table[i];
 
 		rcu_read_lock();
-		hlist_for_each_entry_rcu(hna_global_entry, node,
+		hlist_for_each_entry_rcu(tt_global_entry, node,
 					 head, hash_entry) {
 			pos += snprintf(buff + pos, 44,
 					" * %pM via %pM\n",
-					hna_global_entry->addr,
-					hna_global_entry->orig_node->orig);
+					tt_global_entry->addr,
+					tt_global_entry->orig_node->orig);
 		}
 		rcu_read_unlock();
 	}
 
-	spin_unlock_bh(&bat_priv->hna_ghash_lock);
+	spin_unlock_bh(&bat_priv->tt_ghash_lock);
 
 	seq_printf(seq, "%s", buff);
 	kfree(buff);
@@ -554,84 +555,84 @@ out:
 	return ret;
 }
 
-static void _hna_global_del_orig(struct bat_priv *bat_priv,
-				 struct hna_global_entry *hna_global_entry,
+static void _tt_global_del_orig(struct bat_priv *bat_priv,
+				 struct tt_global_entry *tt_global_entry,
 				 char *message)
 {
 	bat_dbg(DBG_ROUTES, bat_priv,
-		"Deleting global hna entry %pM (via %pM): %s\n",
-		hna_global_entry->addr, hna_global_entry->orig_node->orig,
+		"Deleting global tt entry %pM (via %pM): %s\n",
+		tt_global_entry->addr, tt_global_entry->orig_node->orig,
 		message);
 
-	hash_remove(bat_priv->hna_global_hash, compare_ghna, choose_orig,
-		    hna_global_entry->addr);
-	kfree(hna_global_entry);
+	hash_remove(bat_priv->tt_global_hash, compare_gtt, choose_orig,
+		    tt_global_entry->addr);
+	kfree(tt_global_entry);
 }
 
-void hna_global_del_orig(struct bat_priv *bat_priv,
+void tt_global_del_orig(struct bat_priv *bat_priv,
 			 struct orig_node *orig_node, char *message)
 {
-	struct hna_global_entry *hna_global_entry;
-	int hna_buff_count = 0;
-	unsigned char *hna_ptr;
+	struct tt_global_entry *tt_global_entry;
+	int tt_buff_count = 0;
+	unsigned char *tt_ptr;
 
-	if (orig_node->hna_buff_len == 0)
+	if (orig_node->tt_buff_len == 0)
 		return;
 
-	spin_lock_bh(&bat_priv->hna_ghash_lock);
+	spin_lock_bh(&bat_priv->tt_ghash_lock);
 
-	while ((hna_buff_count + 1) * ETH_ALEN <= orig_node->hna_buff_len) {
-		hna_ptr = orig_node->hna_buff + (hna_buff_count * ETH_ALEN);
-		hna_global_entry = hna_global_hash_find(bat_priv, hna_ptr);
+	while ((tt_buff_count + 1) * ETH_ALEN <= orig_node->tt_buff_len) {
+		tt_ptr = orig_node->tt_buff + (tt_buff_count * ETH_ALEN);
+		tt_global_entry = tt_global_hash_find(bat_priv, tt_ptr);
 
-		if ((hna_global_entry) &&
-		    (hna_global_entry->orig_node == orig_node))
-			_hna_global_del_orig(bat_priv, hna_global_entry,
+		if ((tt_global_entry) &&
+		    (tt_global_entry->orig_node == orig_node))
+			_tt_global_del_orig(bat_priv, tt_global_entry,
 					     message);
 
-		hna_buff_count++;
+		tt_buff_count++;
 	}
 
-	spin_unlock_bh(&bat_priv->hna_ghash_lock);
+	spin_unlock_bh(&bat_priv->tt_ghash_lock);
 
-	orig_node->hna_buff_len = 0;
-	kfree(orig_node->hna_buff);
-	orig_node->hna_buff = NULL;
+	orig_node->tt_buff_len = 0;
+	kfree(orig_node->tt_buff);
+	orig_node->tt_buff = NULL;
 }
 
-static void hna_global_del(struct hlist_node *node, void *arg)
+static void tt_global_del(struct hlist_node *node, void *arg)
 {
-	void *data = container_of(node, struct hna_global_entry, hash_entry);
+	void *data = container_of(node, struct tt_global_entry, hash_entry);
 
 	kfree(data);
 }
 
-void hna_global_free(struct bat_priv *bat_priv)
+void tt_global_free(struct bat_priv *bat_priv)
 {
-	if (!bat_priv->hna_global_hash)
+	if (!bat_priv->tt_global_hash)
 		return;
 
-	hash_delete(bat_priv->hna_global_hash, hna_global_del, NULL);
-	bat_priv->hna_global_hash = NULL;
+	hash_delete(bat_priv->tt_global_hash, tt_global_del, NULL);
+	bat_priv->tt_global_hash = NULL;
 }
 
 struct orig_node *transtable_search(struct bat_priv *bat_priv, uint8_t *addr)
 {
-	struct hna_global_entry *hna_global_entry;
+	struct tt_global_entry *tt_global_entry;
 	struct orig_node *orig_node = NULL;
 
-	spin_lock_bh(&bat_priv->hna_ghash_lock);
-	hna_global_entry = hna_global_hash_find(bat_priv, addr);
+	spin_lock_bh(&bat_priv->tt_ghash_lock);
+	tt_global_entry = tt_global_hash_find(bat_priv, addr);
 
-	if (!hna_global_entry)
+	if (!tt_global_entry)
 		goto out;
 
-	if (!atomic_inc_not_zero(&hna_global_entry->orig_node->refcount))
+	if (!atomic_inc_not_zero(&tt_global_entry->orig_node->refcount))
 		goto out;
 
-	orig_node = hna_global_entry->orig_node;
+	orig_node = tt_global_entry->orig_node;
 
 out:
-	spin_unlock_bh(&bat_priv->hna_ghash_lock);
+	spin_unlock_bh(&bat_priv->tt_ghash_lock);
 	return orig_node;
 }
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index f19931c..46152c3 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -22,22 +22,22 @@
 #ifndef _NET_BATMAN_ADV_TRANSLATION_TABLE_H_
 #define _NET_BATMAN_ADV_TRANSLATION_TABLE_H_
 
-int hna_local_init(struct bat_priv *bat_priv);
-void hna_local_add(struct net_device *soft_iface, uint8_t *addr);
-void hna_local_remove(struct bat_priv *bat_priv,
+int tt_local_init(struct bat_priv *bat_priv);
+void tt_local_add(struct net_device *soft_iface, uint8_t *addr);
+void tt_local_remove(struct bat_priv *bat_priv,
 		      uint8_t *addr, char *message);
-int hna_local_fill_buffer(struct bat_priv *bat_priv,
+int tt_local_fill_buffer(struct bat_priv *bat_priv,
 			  unsigned char *buff, int buff_len);
-int hna_local_seq_print_text(struct seq_file *seq, void *offset);
-void hna_local_free(struct bat_priv *bat_priv);
-int hna_global_init(struct bat_priv *bat_priv);
-void hna_global_add_orig(struct bat_priv *bat_priv,
+int tt_local_seq_print_text(struct seq_file *seq, void *offset);
+void tt_local_free(struct bat_priv *bat_priv);
+int tt_global_init(struct bat_priv *bat_priv);
+void tt_global_add_orig(struct bat_priv *bat_priv,
 			 struct orig_node *orig_node,
-			 unsigned char *hna_buff, int hna_buff_len);
-int hna_global_seq_print_text(struct seq_file *seq, void *offset);
-void hna_global_del_orig(struct bat_priv *bat_priv,
+			 unsigned char *tt_buff, int tt_buff_len);
+int tt_global_seq_print_text(struct seq_file *seq, void *offset);
+void tt_global_del_orig(struct bat_priv *bat_priv,
 			 struct orig_node *orig_node, char *message);
-void hna_global_free(struct bat_priv *bat_priv);
+void tt_global_free(struct bat_priv *bat_priv);
 struct orig_node *transtable_search(struct bat_priv *bat_priv, uint8_t *addr);
 
 #endif /* _NET_BATMAN_ADV_TRANSLATION_TABLE_H_ */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 9ae507a..6b6c32e 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -75,8 +75,8 @@ struct orig_node {
 	unsigned long batman_seqno_reset;
 	uint8_t gw_flags;
 	uint8_t flags;
-	unsigned char *hna_buff;
-	int16_t hna_buff_len;
+	unsigned char *tt_buff;
+	int16_t tt_buff_len;
 	uint32_t last_real_seqno;
 	uint8_t last_ttl;
 	unsigned long bcast_bits[NUM_WORDS];
@@ -155,21 +155,21 @@ struct bat_priv {
 	struct hlist_head softif_neigh_vids;
 	struct list_head vis_send_list;
 	struct hashtable_t *orig_hash;
-	struct hashtable_t *hna_local_hash;
-	struct hashtable_t *hna_global_hash;
+	struct hashtable_t *tt_local_hash;
+	struct hashtable_t *tt_global_hash;
 	struct hashtable_t *vis_hash;
 	spinlock_t forw_bat_list_lock; /* protects forw_bat_list */
 	spinlock_t forw_bcast_list_lock; /* protects  */
-	spinlock_t hna_lhash_lock; /* protects hna_local_hash */
-	spinlock_t hna_ghash_lock; /* protects hna_global_hash */
+	spinlock_t tt_lhash_lock; /* protects tt_local_hash */
+	spinlock_t tt_ghash_lock; /* protects tt_global_hash */
 	spinlock_t gw_list_lock; /* protects gw_list and curr_gw */
 	spinlock_t vis_hash_lock; /* protects vis_hash */
 	spinlock_t vis_list_lock; /* protects vis_info::recv_list */
 	spinlock_t softif_neigh_lock; /* protects soft-interface neigh list */
 	spinlock_t softif_neigh_vid_lock; /* protects soft-interface vid list */
-	int16_t num_local_hna;
-	atomic_t hna_local_changed;
-	struct delayed_work hna_work;
+	int16_t num_local_tt;
+	atomic_t tt_local_changed;
+	struct delayed_work tt_work;
 	struct delayed_work orig_work;
 	struct delayed_work vis_work;
 	struct gw_node __rcu *curr_gw;  /* rcu protected pointer */
@@ -192,14 +192,14 @@ struct socket_packet {
 	struct icmp_packet_rr icmp_packet;
 };
 
-struct hna_local_entry {
+struct tt_local_entry {
 	uint8_t addr[ETH_ALEN];
 	unsigned long last_seen;
 	char never_purge;
 	struct hlist_node hash_entry;
 };
 
-struct hna_global_entry {
+struct tt_global_entry {
 	uint8_t addr[ETH_ALEN];
 	struct orig_node *orig_node;
 	struct hlist_node hash_entry;
@@ -262,7 +262,7 @@ struct vis_info {
 struct vis_info_entry {
 	uint8_t  src[ETH_ALEN];
 	uint8_t  dest[ETH_ALEN];
-	uint8_t  quality;	/* quality = 0 means HNA */
+	uint8_t  quality;	/* quality = 0 client */
 } __packed;
 
 struct recvlist_node {
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index b46cbf1..19c3daf 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -300,7 +300,7 @@ int unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv)
 			goto find_router;
 	}
 
-	/* check for hna host - increases orig_node refcount */
+	/* check for tt host - increases orig_node refcount */
 	orig_node = transtable_search(bat_priv, ethhdr->h_dest);
 
 find_router:
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index c8f571d..c39f20c 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -194,7 +194,7 @@ static ssize_t vis_data_read_entry(char *buff, struct vis_info_entry *entry,
 {
 	/* maximal length: max(4+17+2, 3+17+1+3+2) == 26 */
 	if (primary && entry->quality == 0)
-		return sprintf(buff, "HNA %pM, ", entry->dest);
+		return sprintf(buff, "TT %pM, ", entry->dest);
 	else if (compare_eth(entry->src, src))
 		return sprintf(buff, "TQ %pM %d, ", entry->dest,
 			       entry->quality);
@@ -622,7 +622,7 @@ static int generate_vis_packet(struct bat_priv *bat_priv)
 	struct vis_info *info = (struct vis_info *)bat_priv->my_vis_info;
 	struct vis_packet *packet = (struct vis_packet *)info->skb_packet->data;
 	struct vis_info_entry *entry;
-	struct hna_local_entry *hna_local_entry;
+	struct tt_local_entry *tt_local_entry;
 	int best_tq = -1, i;
 
 	info->first_seen = jiffies;
@@ -678,29 +678,29 @@ next:
 		rcu_read_unlock();
 	}
 
-	hash = bat_priv->hna_local_hash;
+	hash = bat_priv->tt_local_hash;
 
-	spin_lock_bh(&bat_priv->hna_lhash_lock);
+	spin_lock_bh(&bat_priv->tt_lhash_lock);
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
-		hlist_for_each_entry(hna_local_entry, node, head, hash_entry) {
+		hlist_for_each_entry(tt_local_entry, node, head, hash_entry) {
 			entry = (struct vis_info_entry *)
 					skb_put(info->skb_packet,
 						sizeof(*entry));
 			memset(entry->src, 0, ETH_ALEN);
-			memcpy(entry->dest, hna_local_entry->addr, ETH_ALEN);
-			entry->quality = 0; /* 0 means HNA */
+			memcpy(entry->dest, tt_local_entry->addr, ETH_ALEN);
+			entry->quality = 0; /* 0 means TT */
 			packet->entries++;
 
 			if (vis_packet_full(info)) {
-				spin_unlock_bh(&bat_priv->hna_lhash_lock);
+				spin_unlock_bh(&bat_priv->tt_lhash_lock);
 				return 0;
 			}
 		}
 	}
 
-	spin_unlock_bh(&bat_priv->hna_lhash_lock);
+	spin_unlock_bh(&bat_priv->tt_lhash_lock);
 	return 0;
 
 unlock:
-- 
1.7.5.1
