From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 04/12] batman-adv: Reduce usage of char
Date: Mon, 20 Jun 2011 12:16:57 +0200
Message-ID: <1308565025-21293-5-git-send-email-sven@narfation.org>
References: <1308565025-21293-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1308565025-21293-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
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

char was used in different places to store information without really
using the characteristics of that data type or by ignoring the fact that
char has not a well defined signedness.

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/aggregation.c    |    2 +-
 net/batman-adv/aggregation.h    |    2 +-
 net/batman-adv/bitarray.c       |    4 ++--
 net/batman-adv/bitarray.h       |    4 ++--
 net/batman-adv/gateway_client.c |    2 +-
 net/batman-adv/gateway_common.c |    6 +++---
 net/batman-adv/main.h           |    2 +-
 net/batman-adv/routing.c        |    8 ++++----
 net/batman-adv/send.c           |    6 +++---
 net/batman-adv/send.h           |    2 +-
 net/batman-adv/soft-interface.c |    2 +-
 11 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/net/batman-adv/aggregation.c b/net/batman-adv/aggregation.c
index 4080970..29c6740 100644
--- a/net/batman-adv/aggregation.c
+++ b/net/batman-adv/aggregation.c
@@ -195,7 +195,7 @@ static void aggregate(struct forw_packet *forw_packet_aggr,
 
 void add_bat_packet_to_list(struct bat_priv *bat_priv,
 			    unsigned char *packet_buff, int packet_len,
-			    struct hard_iface *if_incoming, char own_packet,
+			    struct hard_iface *if_incoming, int own_packet,
 			    unsigned long send_time)
 {
 	/**
diff --git a/net/batman-adv/aggregation.h b/net/batman-adv/aggregation.h
index fedeb8d..0547fd8 100644
--- a/net/batman-adv/aggregation.h
+++ b/net/batman-adv/aggregation.h
@@ -35,7 +35,7 @@ static inline int aggregated_packet(int buff_pos, int packet_len, int num_tt)
 
 void add_bat_packet_to_list(struct bat_priv *bat_priv,
 			    unsigned char *packet_buff, int packet_len,
-			    struct hard_iface *if_incoming, char own_packet,
+			    struct hard_iface *if_incoming, int own_packet,
 			    unsigned long send_time);
 void receive_aggr_bat_packet(const struct ethhdr *ethhdr,
 			     unsigned char *packet_buff, int packet_len,
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index 3659a25..c1f4bfc 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -127,8 +127,8 @@ static void bit_reset_window(unsigned long *seq_bits)
  *  1 if the window was moved (either new or very old)
  *  0 if the window was not moved/shifted.
  */
-char bit_get_packet(void *priv, unsigned long *seq_bits,
-		    int32_t seq_num_diff, int8_t set_mark)
+int bit_get_packet(void *priv, unsigned long *seq_bits,
+		    int32_t seq_num_diff, int set_mark)
 {
 	struct bat_priv *bat_priv = priv;
 
diff --git a/net/batman-adv/bitarray.h b/net/batman-adv/bitarray.h
index 277c037..9c04422 100644
--- a/net/batman-adv/bitarray.h
+++ b/net/batman-adv/bitarray.h
@@ -35,8 +35,8 @@ void bit_mark(unsigned long *seq_bits, int32_t n);
 
 /* receive and process one packet, returns 1 if received seq_num is considered
  * new, 0 if old  */
-char bit_get_packet(void *priv, unsigned long *seq_bits,
-		    int32_t seq_num_diff, int8_t set_mark);
+int bit_get_packet(void *priv, unsigned long *seq_bits,
+		   int32_t seq_num_diff, int set_mark);
 
 /* count the hamming weight, how many good packets did we receive? */
 int bit_packet_count(const unsigned long *seq_bits);
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 24aee56..7248de2 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -360,7 +360,7 @@ void gw_node_purge(struct bat_priv *bat_priv)
 	struct gw_node *gw_node, *curr_gw;
 	struct hlist_node *node, *node_tmp;
 	unsigned long timeout = 2 * PURGE_TIMEOUT * HZ;
-	char do_deselect = 0;
+	int do_deselect = 0;
 
 	curr_gw = gw_get_selected_gw_node(bat_priv);
 
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index e74307b..18661af 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -61,9 +61,9 @@ static void kbit_to_gw_bandwidth(int down, int up, long *gw_srv_class)
 /* returns the up and downspeeds in kbit, calculated from the class */
 void gw_bandwidth_to_kbit(uint8_t gw_srv_class, int *down, int *up)
 {
-	char sbit = (gw_srv_class & 0x80) >> 7;
-	char dpart = (gw_srv_class & 0x78) >> 3;
-	char upart = (gw_srv_class & 0x07);
+	int sbit = (gw_srv_class & 0x80) >> 7;
+	int dpart = (gw_srv_class & 0x78) >> 3;
+	int upart = (gw_srv_class & 0x07);
 
 	if (!gw_srv_class) {
 		*down = 0;
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index ed488cb..714a241 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -151,7 +151,7 @@ int debug_log(struct bat_priv *bat_priv, const char *fmt, ...) __printf(2, 3);
 	while (0)
 #else /* !CONFIG_BATMAN_ADV_DEBUG */
 __printf(3, 4)
-static inline void bat_dbg(char type __always_unused,
+static inline void bat_dbg(int type __always_unused,
 			   struct bat_priv *bat_priv __always_unused,
 			   const char *fmt __always_unused, ...)
 {
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index d5ce644..eb6fb7d 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -163,7 +163,7 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct neigh_node *neigh_node = NULL, *tmp_neigh_node;
 	struct hlist_node *node;
-	unsigned char total_count;
+	uint8_t total_count;
 	uint8_t orig_eq_count, neigh_rq_count, tq_own;
 	int tq_asym_penalty, ret = 0;
 
@@ -602,9 +602,9 @@ void receive_bat_packet(const struct ethhdr *ethhdr,
 	struct orig_node *orig_neigh_node, *orig_node;
 	struct neigh_node *router = NULL, *router_router = NULL;
 	struct neigh_node *orig_neigh_router = NULL;
-	char has_directlink_flag;
-	char is_my_addr = 0, is_my_orig = 0, is_my_oldorig = 0;
-	char is_broadcast = 0, is_bidirectional, is_single_hop_neigh;
+	int has_directlink_flag;
+	int is_my_addr = 0, is_my_orig = 0, is_my_oldorig = 0;
+	int is_broadcast = 0, is_bidirectional, is_single_hop_neigh;
 	int is_duplicate;
 	uint32_t if_incoming_seqno;
 
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index a1b8c31..be0d581 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -165,7 +165,7 @@ static void send_packet(struct forw_packet *forw_packet)
 	struct bat_priv *bat_priv;
 	struct batman_packet *batman_packet =
 		(struct batman_packet *)(forw_packet->skb->data);
-	unsigned char directlink = (batman_packet->flags & DIRECTLINK ? 1 : 0);
+	int directlink = (batman_packet->flags & DIRECTLINK ? 1 : 0);
 
 	if (!forw_packet->if_incoming) {
 		pr_err("Error - can't forward packet: incoming iface not "
@@ -307,12 +307,12 @@ void schedule_own_packet(struct hard_iface *hard_iface)
 void schedule_forward_packet(struct orig_node *orig_node,
 			     const struct ethhdr *ethhdr,
 			     struct batman_packet *batman_packet,
-			     uint8_t directlink, int tt_buff_len,
+			     int directlink, int tt_buff_len,
 			     struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct neigh_node *router;
-	unsigned char in_tq, in_ttl, tq_avg = 0;
+	uint8_t in_tq, in_ttl, tq_avg = 0;
 	unsigned long send_time;
 
 	if (batman_packet->ttl <= 1) {
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index eceab87..6d9c14d 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -28,7 +28,7 @@ void schedule_own_packet(struct hard_iface *hard_iface);
 void schedule_forward_packet(struct orig_node *orig_node,
 			     const struct ethhdr *ethhdr,
 			     struct batman_packet *batman_packet,
-			     uint8_t directlink, int tt_buff_len,
+			     int directlink, int tt_buff_len,
 			     struct hard_iface *if_outgoing);
 int add_bcast_packet_to_list(struct bat_priv *bat_priv,
 			     const struct sk_buff *skb);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 0fc997e..69c0022 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -380,7 +380,7 @@ void softif_neigh_purge(struct bat_priv *bat_priv)
 	struct softif_neigh *softif_neigh, *curr_softif_neigh;
 	struct softif_neigh_vid *softif_neigh_vid;
 	struct hlist_node *node, *node_tmp, *node_tmp2;
-	char do_deselect;
+	int do_deselect;
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(softif_neigh_vid, node,
-- 
1.7.5.3
