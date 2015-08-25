From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 01/15] batman-adv: Replace C99 int types with kernel type
Date: Tue, 25 Aug 2015 13:02:25 +0200
Message-ID: <1440500559-28368-2-git-send-email-antonio__42364.4439936199$1440500673$gmane$org@meshcoding.com>
References: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:5070 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754183AbbHYLDw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 07:03:52 -0400
In-Reply-To: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

(s|u)(8|16|32|64) are the preferred types in the kernel. The use of the
standard C99 types u?int(8|16|32|64)_t are objected by some people and even
checkpatch now warns about using them.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c            |  94 +++++++-------
 net/batman-adv/bitarray.c              |   6 +-
 net/batman-adv/bitarray.h              |  10 +-
 net/batman-adv/bridge_loop_avoidance.c |  72 ++++++-----
 net/batman-adv/bridge_loop_avoidance.h |   5 +-
 net/batman-adv/distributed-arp-table.c |  59 +++++----
 net/batman-adv/distributed-arp-table.h |   8 +-
 net/batman-adv/fragmentation.c         |  10 +-
 net/batman-adv/gateway_client.c        |  14 +--
 net/batman-adv/gateway_client.h        |   2 +-
 net/batman-adv/gateway_common.c        |  11 +-
 net/batman-adv/hash.c                  |   6 +-
 net/batman-adv/hash.h                  |  12 +-
 net/batman-adv/icmp_socket.c           |   2 +-
 net/batman-adv/main.c                  |  69 +++++-----
 net/batman-adv/main.h                  |  48 ++++---
 net/batman-adv/multicast.c             |  16 +--
 net/batman-adv/network-coding.c        |  44 ++++---
 net/batman-adv/originator.c            |  15 ++-
 net/batman-adv/originator.h            |  11 +-
 net/batman-adv/packet.h                | 204 +++++++++++++++---------------
 net/batman-adv/routing.c               |  24 ++--
 net/batman-adv/routing.h               |   2 +-
 net/batman-adv/send.c                  |   8 +-
 net/batman-adv/send.h                  |   8 +-
 net/batman-adv/soft-interface.c        |  26 ++--
 net/batman-adv/sysfs.c                 |   4 +-
 net/batman-adv/translation-table.c     | 224 ++++++++++++++++-----------------
 net/batman-adv/translation-table.h     |  29 +++--
 net/batman-adv/types.h                 | 105 ++++++++--------
 30 files changed, 563 insertions(+), 585 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 753383c..f550a6a 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -77,8 +77,7 @@ enum batadv_dup_status {
  * @lq_index: index to store the value at
  * @value: value to store in the ring buffer
  */
-static void batadv_ring_buffer_set(uint8_t lq_recv[], uint8_t *lq_index,
-				   uint8_t value)
+static void batadv_ring_buffer_set(u8 lq_recv[], u8 *lq_index, u8 value)
 {
 	lq_recv[*lq_index] = value;
 	*lq_index = (*lq_index + 1) % BATADV_TQ_GLOBAL_WINDOW_SIZE;
@@ -91,12 +90,12 @@ static void batadv_ring_buffer_set(uint8_t lq_recv[], uint8_t *lq_index,
  *
  * Returns computed average value.
  */
-static uint8_t batadv_ring_buffer_avg(const uint8_t lq_recv[])
+static u8 batadv_ring_buffer_avg(const u8 lq_recv[])
 {
-	const uint8_t *ptr;
-	uint16_t count = 0;
-	uint16_t i = 0;
-	uint16_t sum = 0;
+	const u8 *ptr;
+	u16 count = 0;
+	u16 i = 0;
+	u16 sum = 0;
 
 	ptr = lq_recv;
 
@@ -113,7 +112,7 @@ static uint8_t batadv_ring_buffer_avg(const uint8_t lq_recv[])
 	if (count == 0)
 		return 0;
 
-	return (uint8_t)(sum / count);
+	return (u8)(sum / count);
 }
 
 /**
@@ -155,14 +154,14 @@ static int batadv_iv_ogm_orig_add_if(struct batadv_orig_node *orig_node,
 	kfree(orig_node->bat_iv.bcast_own);
 	orig_node->bat_iv.bcast_own = data_ptr;
 
-	data_ptr = kmalloc_array(max_if_num, sizeof(uint8_t), GFP_ATOMIC);
+	data_ptr = kmalloc_array(max_if_num, sizeof(u8), GFP_ATOMIC);
 	if (!data_ptr) {
 		kfree(orig_node->bat_iv.bcast_own);
 		goto unlock;
 	}
 
 	memcpy(data_ptr, orig_node->bat_iv.bcast_own_sum,
-	       (max_if_num - 1) * sizeof(uint8_t));
+	       (max_if_num - 1) * sizeof(u8));
 	kfree(orig_node->bat_iv.bcast_own_sum);
 	orig_node->bat_iv.bcast_own_sum = data_ptr;
 
@@ -215,19 +214,19 @@ free_bcast_own:
 	if (max_if_num == 0)
 		goto free_own_sum;
 
-	data_ptr = kmalloc_array(max_if_num, sizeof(uint8_t), GFP_ATOMIC);
+	data_ptr = kmalloc_array(max_if_num, sizeof(u8), GFP_ATOMIC);
 	if (!data_ptr) {
 		kfree(orig_node->bat_iv.bcast_own);
 		goto unlock;
 	}
 
 	memcpy(data_ptr, orig_node->bat_iv.bcast_own_sum,
-	       del_if_num * sizeof(uint8_t));
+	       del_if_num * sizeof(u8));
 
-	if_offset = (del_if_num + 1) * sizeof(uint8_t);
-	memcpy((char *)data_ptr + del_if_num * sizeof(uint8_t),
+	if_offset = (del_if_num + 1) * sizeof(u8);
+	memcpy((char *)data_ptr + del_if_num * sizeof(u8),
 	       orig_node->bat_iv.bcast_own_sum + if_offset,
-	       (max_if_num - del_if_num) * sizeof(uint8_t));
+	       (max_if_num - del_if_num) * sizeof(u8));
 
 free_own_sum:
 	kfree(orig_node->bat_iv.bcast_own_sum);
@@ -250,7 +249,7 @@ unlock:
  * If the object does not exists it is created an initialised.
  */
 static struct batadv_orig_node *
-batadv_iv_ogm_orig_get(struct batadv_priv *bat_priv, const uint8_t *addr)
+batadv_iv_ogm_orig_get(struct batadv_priv *bat_priv, const u8 *addr)
 {
 	struct batadv_orig_node *orig_node;
 	int size, hash_added;
@@ -270,7 +269,7 @@ batadv_iv_ogm_orig_get(struct batadv_priv *bat_priv, const uint8_t *addr)
 	if (!orig_node->bat_iv.bcast_own)
 		goto free_orig_node;
 
-	size = bat_priv->num_ifaces * sizeof(uint8_t);
+	size = bat_priv->num_ifaces * sizeof(u8);
 	orig_node->bat_iv.bcast_own_sum = kzalloc(size, GFP_ATOMIC);
 	if (!orig_node->bat_iv.bcast_own_sum)
 		goto free_orig_node;
@@ -293,7 +292,7 @@ free_orig_node:
 
 static struct batadv_neigh_node *
 batadv_iv_ogm_neigh_new(struct batadv_hard_iface *hard_iface,
-			const uint8_t *neigh_addr,
+			const u8 *neigh_addr,
 			struct batadv_orig_node *orig_node,
 			struct batadv_orig_node *orig_neigh)
 {
@@ -339,7 +338,7 @@ static int batadv_iv_ogm_iface_enable(struct batadv_hard_iface *hard_iface)
 {
 	struct batadv_ogm_packet *batadv_ogm_packet;
 	unsigned char *ogm_buff;
-	uint32_t random_seqno;
+	u32 random_seqno;
 
 	/* randomize initial seqno to avoid collision */
 	get_random_bytes(&random_seqno, sizeof(random_seqno));
@@ -411,8 +410,7 @@ static unsigned long batadv_iv_ogm_fwd_send_time(void)
 }
 
 /* apply hop penalty for a normal link */
-static uint8_t batadv_hop_penalty(uint8_t tq,
-				  const struct batadv_priv *bat_priv)
+static u8 batadv_hop_penalty(u8 tq, const struct batadv_priv *bat_priv)
 {
 	int hop_penalty = atomic_read(&bat_priv->hop_penalty);
 	int new_tq;
@@ -442,11 +440,11 @@ static void batadv_iv_ogm_send_to_if(struct batadv_forw_packet *forw_packet,
 {
 	struct batadv_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	const char *fwd_str;
-	uint8_t packet_num;
-	int16_t buff_pos;
+	u8 packet_num;
+	s16 buff_pos;
 	struct batadv_ogm_packet *batadv_ogm_packet;
 	struct sk_buff *skb;
-	uint8_t *packet_pos;
+	u8 *packet_pos;
 
 	if (hard_iface->if_status != BATADV_IF_ACTIVE)
 		return;
@@ -837,7 +835,7 @@ static void batadv_iv_ogm_forward(struct batadv_orig_node *orig_node,
 				  struct batadv_hard_iface *if_outgoing)
 {
 	struct batadv_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
-	uint16_t tvlv_len;
+	u16 tvlv_len;
 
 	if (batadv_ogm_packet->ttl <= 1) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv, "ttl exceeded\n");
@@ -896,9 +894,9 @@ batadv_iv_ogm_slide_own_bcast_window(struct batadv_hard_iface *hard_iface)
 	struct hlist_head *head;
 	struct batadv_orig_node *orig_node;
 	unsigned long *word;
-	uint32_t i;
+	u32 i;
 	size_t word_index;
-	uint8_t *w;
+	u8 *w;
 	int if_num;
 
 	for (i = 0; i < hash->size; i++) {
@@ -927,8 +925,8 @@ static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 	struct batadv_ogm_packet *batadv_ogm_packet;
 	struct batadv_hard_iface *primary_if, *tmp_hard_iface;
 	int *ogm_buff_len = &hard_iface->bat_iv.ogm_buff_len;
-	uint32_t seqno;
-	uint16_t tvlv_len = 0;
+	u32 seqno;
+	u16 tvlv_len = 0;
 	unsigned long send_time;
 
 	primary_if = batadv_primary_if_get_selected(bat_priv);
@@ -947,7 +945,7 @@ static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 	batadv_ogm_packet->tvlv_len = htons(tvlv_len);
 
 	/* change sequence number to network order */
-	seqno = (uint32_t)atomic_read(&hard_iface->bat_iv.ogm_seqno);
+	seqno = (u32)atomic_read(&hard_iface->bat_iv.ogm_seqno);
 	batadv_ogm_packet->seqno = htonl(seqno);
 	atomic_inc(&hard_iface->bat_iv.ogm_seqno);
 
@@ -1010,9 +1008,9 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 	struct batadv_neigh_node *router = NULL;
 	struct batadv_orig_node *orig_node_tmp;
 	int if_num;
-	uint8_t sum_orig, sum_neigh;
-	uint8_t *neigh_addr;
-	uint8_t tq_avg;
+	u8 sum_orig, sum_neigh;
+	u8 *neigh_addr;
+	u8 tq_avg;
 
 	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 		   "update_originator(): Searching and updating originator entry of received packet\n");
@@ -1164,8 +1162,8 @@ static int batadv_iv_ogm_calc_tq(struct batadv_orig_node *orig_node,
 	struct batadv_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct batadv_neigh_node *neigh_node = NULL, *tmp_neigh_node;
 	struct batadv_neigh_ifinfo *neigh_ifinfo;
-	uint8_t total_count;
-	uint8_t orig_eq_count, neigh_rq_count, neigh_rq_inv, tq_own;
+	u8 total_count;
+	u8 orig_eq_count, neigh_rq_count, neigh_rq_inv, tq_own;
 	unsigned int neigh_rq_inv_cube, neigh_rq_max_cube;
 	int tq_asym_penalty, inv_asym_penalty, if_num, ret = 0;
 	unsigned int combined_tq;
@@ -1311,13 +1309,13 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 	struct batadv_neigh_node *neigh_node;
 	struct batadv_neigh_ifinfo *neigh_ifinfo;
 	int is_dup;
-	int32_t seq_diff;
+	s32 seq_diff;
 	int need_update = 0;
 	int set_mark;
 	enum batadv_dup_status ret = BATADV_NO_DUP;
-	uint32_t seqno = ntohl(batadv_ogm_packet->seqno);
-	uint8_t *neigh_addr;
-	uint8_t packet_count;
+	u32 seqno = ntohl(batadv_ogm_packet->seqno);
+	u8 *neigh_addr;
+	u8 packet_count;
 	unsigned long *bitmap;
 
 	orig_node = batadv_iv_ogm_orig_get(bat_priv, batadv_ogm_packet->orig);
@@ -1418,7 +1416,7 @@ batadv_iv_ogm_process_per_outif(const struct sk_buff *skb, int ogm_offset,
 	bool sameseq, similar_ttl;
 	struct sk_buff *skb_priv;
 	struct ethhdr *ethhdr;
-	uint8_t *prev_sender;
+	u8 *prev_sender;
 	int is_bidirect;
 
 	/* create a private copy of the skb, as some functions change tq value
@@ -1600,7 +1598,7 @@ static void batadv_iv_ogm_process(const struct sk_buff *skb, int ogm_offset,
 	struct batadv_orig_node *orig_neigh_node, *orig_node;
 	struct batadv_hard_iface *hard_iface;
 	struct batadv_ogm_packet *ogm_packet;
-	uint32_t if_incoming_seqno;
+	u32 if_incoming_seqno;
 	bool has_directlink_flag;
 	struct ethhdr *ethhdr;
 	bool is_my_oldorig = false;
@@ -1673,9 +1671,9 @@ static void batadv_iv_ogm_process(const struct sk_buff *skb, int ogm_offset,
 	if (is_my_orig) {
 		unsigned long *word;
 		int offset;
-		int32_t bit_pos;
-		int16_t if_num;
-		uint8_t *weight;
+		s32 bit_pos;
+		s16 if_num;
+		u8 *weight;
 
 		orig_neigh_node = batadv_iv_ogm_orig_get(bat_priv,
 							 ethhdr->h_source);
@@ -1751,7 +1749,7 @@ static int batadv_iv_ogm_receive(struct sk_buff *skb,
 {
 	struct batadv_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct batadv_ogm_packet *ogm_packet;
-	uint8_t *packet_pos;
+	u8 *packet_pos;
 	int ogm_offset;
 	bool ret;
 
@@ -1835,7 +1833,7 @@ static void batadv_iv_ogm_orig_print(struct batadv_priv *bat_priv,
 	unsigned long last_seen_jiffies;
 	struct hlist_head *head;
 	int batman_count = 0;
-	uint32_t i;
+	u32 i;
 
 	seq_printf(seq, "  %-15s %s (%s/%i) %17s [%10s]: %20s ...\n",
 		   "Originator", "last-seen", "#", BATADV_TQ_MAX_VALUE,
@@ -1903,7 +1901,7 @@ static int batadv_iv_ogm_neigh_cmp(struct batadv_neigh_node *neigh1,
 				   struct batadv_hard_iface *if_outgoing2)
 {
 	struct batadv_neigh_ifinfo *neigh1_ifinfo, *neigh2_ifinfo;
-	uint8_t tq1, tq2;
+	u8 tq1, tq2;
 	int diff;
 
 	neigh1_ifinfo = batadv_neigh_ifinfo_get(neigh1, if_outgoing1);
@@ -1945,7 +1943,7 @@ batadv_iv_ogm_neigh_is_eob(struct batadv_neigh_node *neigh1,
 			   struct batadv_hard_iface *if_outgoing2)
 {
 	struct batadv_neigh_ifinfo *neigh1_ifinfo, *neigh2_ifinfo;
-	uint8_t tq1, tq2;
+	u8 tq1, tq2;
 	bool ret;
 
 	neigh1_ifinfo = batadv_neigh_ifinfo_get(neigh1, if_outgoing1);
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index cf68c32..25cbc36 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -21,7 +21,7 @@
 #include <linux/bitmap.h>
 
 /* shift the packet array by n places. */
-static void batadv_bitmap_shift_left(unsigned long *seq_bits, int32_t n)
+static void batadv_bitmap_shift_left(unsigned long *seq_bits, s32 n)
 {
 	if (n <= 0 || n >= BATADV_TQ_LOCAL_WINDOW_SIZE)
 		return;
@@ -35,8 +35,8 @@ static void batadv_bitmap_shift_left(unsigned long *seq_bits, int32_t n)
  *  1 if the window was moved (either new or very old)
  *  0 if the window was not moved/shifted.
  */
-int batadv_bit_get_packet(void *priv, unsigned long *seq_bits,
-			  int32_t seq_num_diff, int set_mark)
+int batadv_bit_get_packet(void *priv, unsigned long *seq_bits, s32 seq_num_diff,
+			  int set_mark)
 {
 	struct batadv_priv *bat_priv = priv;
 
diff --git a/net/batman-adv/bitarray.h b/net/batman-adv/bitarray.h
index 0c24562..0226b22 100644
--- a/net/batman-adv/bitarray.h
+++ b/net/batman-adv/bitarray.h
@@ -28,9 +28,9 @@
  * and curr_seqno is within range of last_seqno. Otherwise returns 0.
  */
 static inline int batadv_test_bit(const unsigned long *seq_bits,
-				  uint32_t last_seqno, uint32_t curr_seqno)
+				  u32 last_seqno, u32 curr_seqno)
 {
-	int32_t diff;
+	s32 diff;
 
 	diff = last_seqno - curr_seqno;
 	if (diff < 0 || diff >= BATADV_TQ_LOCAL_WINDOW_SIZE)
@@ -39,7 +39,7 @@ static inline int batadv_test_bit(const unsigned long *seq_bits,
 }
 
 /* turn corresponding bit on, so we can remember that we got the packet */
-static inline void batadv_set_bit(unsigned long *seq_bits, int32_t n)
+static inline void batadv_set_bit(unsigned long *seq_bits, s32 n)
 {
 	/* if too old, just drop it */
 	if (n < 0 || n >= BATADV_TQ_LOCAL_WINDOW_SIZE)
@@ -51,7 +51,7 @@ static inline void batadv_set_bit(unsigned long *seq_bits, int32_t n)
 /* receive and process one packet, returns 1 if received seq_num is considered
  * new, 0 if old
  */
-int batadv_bit_get_packet(void *priv, unsigned long *seq_bits,
-			  int32_t seq_num_diff, int set_mark);
+int batadv_bit_get_packet(void *priv, unsigned long *seq_bits, s32 seq_num_diff,
+			  int set_mark);
 
 #endif /* _NET_BATMAN_ADV_BITARRAY_H_ */
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index ba06092..8f9059f 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -51,7 +51,7 @@
 #include "packet.h"
 #include "translation-table.h"
 
-static const uint8_t batadv_announce_mac[4] = {0x43, 0x05, 0x43, 0x05};
+static const u8 batadv_announce_mac[4] = {0x43, 0x05, 0x43, 0x05};
 
 static void batadv_bla_periodic_work(struct work_struct *work);
 static void
@@ -59,10 +59,10 @@ batadv_bla_send_announce(struct batadv_priv *bat_priv,
 			 struct batadv_bla_backbone_gw *backbone_gw);
 
 /* return the index of the claim */
-static inline uint32_t batadv_choose_claim(const void *data, uint32_t size)
+static inline u32 batadv_choose_claim(const void *data, u32 size)
 {
 	struct batadv_bla_claim *claim = (struct batadv_bla_claim *)data;
-	uint32_t hash = 0;
+	u32 hash = 0;
 
 	hash = jhash(&claim->addr, sizeof(claim->addr), hash);
 	hash = jhash(&claim->vid, sizeof(claim->vid), hash);
@@ -71,11 +71,10 @@ static inline uint32_t batadv_choose_claim(const void *data, uint32_t size)
 }
 
 /* return the index of the backbone gateway */
-static inline uint32_t batadv_choose_backbone_gw(const void *data,
-						 uint32_t size)
+static inline u32 batadv_choose_backbone_gw(const void *data, u32 size)
 {
 	const struct batadv_bla_claim *claim = (struct batadv_bla_claim *)data;
-	uint32_t hash = 0;
+	u32 hash = 0;
 
 	hash = jhash(&claim->addr, sizeof(claim->addr), hash);
 	hash = jhash(&claim->vid, sizeof(claim->vid), hash);
@@ -192,8 +191,8 @@ static struct batadv_bla_claim
  * Returns claim if found or NULL otherwise.
  */
 static struct batadv_bla_backbone_gw *
-batadv_backbone_hash_find(struct batadv_priv *bat_priv,
-			  uint8_t *addr, unsigned short vid)
+batadv_backbone_hash_find(struct batadv_priv *bat_priv, u8 *addr,
+			  unsigned short vid)
 {
 	struct batadv_hashtable *hash = bat_priv->bla.backbone_hash;
 	struct hlist_head *head;
@@ -269,14 +268,14 @@ batadv_bla_del_backbone_claims(struct batadv_bla_backbone_gw *backbone_gw)
  * @vid: the VLAN ID
  * @claimtype: the type of the claim (CLAIM, UNCLAIM, ANNOUNCE, ...)
  */
-static void batadv_bla_send_claim(struct batadv_priv *bat_priv, uint8_t *mac,
+static void batadv_bla_send_claim(struct batadv_priv *bat_priv, u8 *mac,
 				  unsigned short vid, int claimtype)
 {
 	struct sk_buff *skb;
 	struct ethhdr *ethhdr;
 	struct batadv_hard_iface *primary_if;
 	struct net_device *soft_iface;
-	uint8_t *hw_src;
+	u8 *hw_src;
 	struct batadv_bla_claim_dst local_claim_dest;
 	__be32 zeroip = 0;
 
@@ -304,13 +303,13 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, uint8_t *mac,
 			  * with XX   = claim type
 			  * and YY:YY = group id
 			  */
-			 (uint8_t *)&local_claim_dest);
+			 (u8 *)&local_claim_dest);
 
 	if (!skb)
 		goto out;
 
 	ethhdr = (struct ethhdr *)skb->data;
-	hw_src = (uint8_t *)ethhdr + ETH_HLEN + sizeof(struct arphdr);
+	hw_src = (u8 *)ethhdr + ETH_HLEN + sizeof(struct arphdr);
 
 	/* now we pretend that the client would have sent this ... */
 	switch (claimtype) {
@@ -383,7 +382,7 @@ out:
  * be found.
  */
 static struct batadv_bla_backbone_gw *
-batadv_bla_get_backbone_gw(struct batadv_priv *bat_priv, uint8_t *orig,
+batadv_bla_get_backbone_gw(struct batadv_priv *bat_priv, u8 *orig,
 			   unsigned short vid, bool own_backbone)
 {
 	struct batadv_bla_backbone_gw *entry;
@@ -552,7 +551,7 @@ static void batadv_bla_send_request(struct batadv_bla_backbone_gw *backbone_gw)
 static void batadv_bla_send_announce(struct batadv_priv *bat_priv,
 				     struct batadv_bla_backbone_gw *backbone_gw)
 {
-	uint8_t mac[ETH_ALEN];
+	u8 mac[ETH_ALEN];
 	__be16 crc;
 
 	memcpy(mac, batadv_announce_mac, 4);
@@ -571,7 +570,7 @@ static void batadv_bla_send_announce(struct batadv_priv *bat_priv,
  * @backbone_gw: the backbone gateway which claims it
  */
 static void batadv_bla_add_claim(struct batadv_priv *bat_priv,
-				 const uint8_t *mac, const unsigned short vid,
+				 const u8 *mac, const unsigned short vid,
 				 struct batadv_bla_backbone_gw *backbone_gw)
 {
 	struct batadv_bla_claim *claim;
@@ -635,7 +634,7 @@ claim_free_ref:
  * given mac address and vid.
  */
 static void batadv_bla_del_claim(struct batadv_priv *bat_priv,
-				 const uint8_t *mac, const unsigned short vid)
+				 const u8 *mac, const unsigned short vid)
 {
 	struct batadv_bla_claim search_claim, *claim;
 
@@ -659,12 +658,11 @@ static void batadv_bla_del_claim(struct batadv_priv *bat_priv,
 }
 
 /* check for ANNOUNCE frame, return 1 if handled */
-static int batadv_handle_announce(struct batadv_priv *bat_priv,
-				  uint8_t *an_addr, uint8_t *backbone_addr,
-				  unsigned short vid)
+static int batadv_handle_announce(struct batadv_priv *bat_priv, u8 *an_addr,
+				  u8 *backbone_addr, unsigned short vid)
 {
 	struct batadv_bla_backbone_gw *backbone_gw;
-	uint16_t crc;
+	u16 crc;
 
 	if (memcmp(an_addr, batadv_announce_mac, 4) != 0)
 		return 0;
@@ -708,8 +706,8 @@ static int batadv_handle_announce(struct batadv_priv *bat_priv,
 /* check for REQUEST frame, return 1 if handled */
 static int batadv_handle_request(struct batadv_priv *bat_priv,
 				 struct batadv_hard_iface *primary_if,
-				 uint8_t *backbone_addr,
-				 struct ethhdr *ethhdr, unsigned short vid)
+				 u8 *backbone_addr, struct ethhdr *ethhdr,
+				 unsigned short vid)
 {
 	/* check for REQUEST frame */
 	if (!batadv_compare_eth(backbone_addr, ethhdr->h_dest))
@@ -732,8 +730,8 @@ static int batadv_handle_request(struct batadv_priv *bat_priv,
 /* check for UNCLAIM frame, return 1 if handled */
 static int batadv_handle_unclaim(struct batadv_priv *bat_priv,
 				 struct batadv_hard_iface *primary_if,
-				 uint8_t *backbone_addr,
-				 uint8_t *claim_addr, unsigned short vid)
+				 u8 *backbone_addr, u8 *claim_addr,
+				 unsigned short vid)
 {
 	struct batadv_bla_backbone_gw *backbone_gw;
 
@@ -761,7 +759,7 @@ static int batadv_handle_unclaim(struct batadv_priv *bat_priv,
 /* check for CLAIM frame, return 1 if handled */
 static int batadv_handle_claim(struct batadv_priv *bat_priv,
 			       struct batadv_hard_iface *primary_if,
-			       uint8_t *backbone_addr, uint8_t *claim_addr,
+			       u8 *backbone_addr, u8 *claim_addr,
 			       unsigned short vid)
 {
 	struct batadv_bla_backbone_gw *backbone_gw;
@@ -805,10 +803,10 @@ static int batadv_handle_claim(struct batadv_priv *bat_priv,
  */
 static int batadv_check_claim_group(struct batadv_priv *bat_priv,
 				    struct batadv_hard_iface *primary_if,
-				    uint8_t *hw_src, uint8_t *hw_dst,
+				    u8 *hw_src, u8 *hw_dst,
 				    struct ethhdr *ethhdr)
 {
-	uint8_t *backbone_addr;
+	u8 *backbone_addr;
 	struct batadv_orig_node *orig_node;
 	struct batadv_bla_claim_dst *bla_dst, *bla_dst_own;
 
@@ -877,7 +875,7 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 				    struct sk_buff *skb)
 {
 	struct batadv_bla_claim_dst *bla_dst, *bla_dst_own;
-	uint8_t *hw_src, *hw_dst;
+	u8 *hw_src, *hw_dst;
 	struct vlan_hdr *vhdr, vhdr_buf;
 	struct ethhdr *ethhdr;
 	struct arphdr *arphdr;
@@ -923,7 +921,7 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 
 	/* pskb_may_pull() may have modified the pointers, get ethhdr again */
 	ethhdr = eth_hdr(skb);
-	arphdr = (struct arphdr *)((uint8_t *)ethhdr + headlen);
+	arphdr = (struct arphdr *)((u8 *)ethhdr + headlen);
 
 	/* Check whether the ARP frame carries a valid
 	 * IP information
@@ -937,7 +935,7 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 	if (arphdr->ar_pln != 4)
 		return 0;
 
-	hw_src = (uint8_t *)arphdr + sizeof(struct arphdr);
+	hw_src = (u8 *)arphdr + sizeof(struct arphdr);
 	hw_dst = hw_src + ETH_ALEN + 4;
 	bla_dst = (struct batadv_bla_claim_dst *)hw_dst;
 	bla_dst_own = &bat_priv->bla.claim_dest;
@@ -1238,9 +1236,9 @@ static struct lock_class_key batadv_backbone_hash_lock_class_key;
 int batadv_bla_init(struct batadv_priv *bat_priv)
 {
 	int i;
-	uint8_t claim_dest[ETH_ALEN] = {0xff, 0x43, 0x05, 0x00, 0x00, 0x00};
+	u8 claim_dest[ETH_ALEN] = {0xff, 0x43, 0x05, 0x00, 0x00, 0x00};
 	struct batadv_hard_iface *primary_if;
-	uint16_t crc;
+	u16 crc;
 	unsigned long entrytime;
 
 	spin_lock_init(&bat_priv->bla.bcast_duplist_lock);
@@ -1368,7 +1366,7 @@ out:
  *
  * Returns true if orig is a backbone for this vid, false otherwise.
  */
-bool batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv, uint8_t *orig,
+bool batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv, u8 *orig,
 				    unsigned short vid)
 {
 	struct batadv_hashtable *hash = bat_priv->bla.backbone_hash;
@@ -1647,9 +1645,9 @@ int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset)
 	struct batadv_bla_claim *claim;
 	struct batadv_hard_iface *primary_if;
 	struct hlist_head *head;
-	uint32_t i;
+	u32 i;
 	bool is_own;
-	uint8_t *primary_addr;
+	u8 *primary_addr;
 
 	primary_if = batadv_seq_print_text_primary_if_get(seq);
 	if (!primary_if)
@@ -1692,9 +1690,9 @@ int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq, void *offset)
 	struct batadv_hard_iface *primary_if;
 	struct hlist_head *head;
 	int secs, msecs;
-	uint32_t i;
+	u32 i;
 	bool is_own;
-	uint8_t *primary_addr;
+	u8 *primary_addr;
 
 	primary_if = batadv_seq_print_text_primary_if_get(seq);
 	if (!primary_if)
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
index 0282690..449f2f1 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -38,7 +38,7 @@ int batadv_bla_is_backbone_gw(struct sk_buff *skb,
 int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset);
 int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq,
 					     void *offset);
-bool batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv, uint8_t *orig,
+bool batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv, u8 *orig,
 				    unsigned short vid);
 int batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
 				   struct sk_buff *skb);
@@ -84,8 +84,7 @@ static inline int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq,
 }
 
 static inline bool batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv,
-						  uint8_t *orig,
-						  unsigned short vid)
+						  u8 *orig, unsigned short vid)
 {
 	return false;
 }
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index cc7d87d..a63ea27 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -102,7 +102,7 @@ static void __batadv_dat_purge(struct batadv_priv *bat_priv,
 	struct batadv_dat_entry *dat_entry;
 	struct hlist_node *node_tmp;
 	struct hlist_head *head;
-	uint32_t i;
+	u32 i;
 
 	if (!bat_priv->dat.hash)
 		return;
@@ -168,11 +168,11 @@ static int batadv_compare_dat(const struct hlist_node *node, const void *data2)
  *
  * Returns the value of the hw_src field in the ARP packet.
  */
-static uint8_t *batadv_arp_hw_src(struct sk_buff *skb, int hdr_size)
+static u8 *batadv_arp_hw_src(struct sk_buff *skb, int hdr_size)
 {
-	uint8_t *addr;
+	u8 *addr;
 
-	addr = (uint8_t *)(skb->data + hdr_size);
+	addr = (u8 *)(skb->data + hdr_size);
 	addr += ETH_HLEN + sizeof(struct arphdr);
 
 	return addr;
@@ -197,7 +197,7 @@ static __be32 batadv_arp_ip_src(struct sk_buff *skb, int hdr_size)
  *
  * Returns the value of the hw_dst field in the ARP packet.
  */
-static uint8_t *batadv_arp_hw_dst(struct sk_buff *skb, int hdr_size)
+static u8 *batadv_arp_hw_dst(struct sk_buff *skb, int hdr_size)
 {
 	return batadv_arp_hw_src(skb, hdr_size) + ETH_ALEN + 4;
 }
@@ -221,12 +221,12 @@ static __be32 batadv_arp_ip_dst(struct sk_buff *skb, int hdr_size)
  *
  * Returns the selected index in the hash table for the given data.
  */
-static uint32_t batadv_hash_dat(const void *data, uint32_t size)
+static u32 batadv_hash_dat(const void *data, u32 size)
 {
-	uint32_t hash = 0;
+	u32 hash = 0;
 	const struct batadv_dat_entry *dat = data;
 	const unsigned char *key;
-	uint32_t i;
+	u32 i;
 
 	key = (const unsigned char *)&dat->ip;
 	for (i = 0; i < sizeof(dat->ip); i++) {
@@ -265,7 +265,7 @@ batadv_dat_entry_hash_find(struct batadv_priv *bat_priv, __be32 ip,
 	struct hlist_head *head;
 	struct batadv_dat_entry to_find, *dat_entry, *dat_entry_tmp = NULL;
 	struct batadv_hashtable *hash = bat_priv->dat.hash;
-	uint32_t index;
+	u32 index;
 
 	if (!hash)
 		return NULL;
@@ -300,7 +300,7 @@ batadv_dat_entry_hash_find(struct batadv_priv *bat_priv, __be32 ip,
  * @vid: VLAN identifier
  */
 static void batadv_dat_entry_add(struct batadv_priv *bat_priv, __be32 ip,
-				 uint8_t *mac_addr, unsigned short vid)
+				 u8 *mac_addr, unsigned short vid)
 {
 	struct batadv_dat_entry *dat_entry;
 	int hash_added;
@@ -357,11 +357,11 @@ out:
  * @msg: message to print together with the debugging information
  */
 static void batadv_dbg_arp(struct batadv_priv *bat_priv, struct sk_buff *skb,
-			   uint16_t type, int hdr_size, char *msg)
+			   u16 type, int hdr_size, char *msg)
 {
 	struct batadv_unicast_4addr_packet *unicast_4addr_packet;
 	struct batadv_bcast_packet *bcast_pkt;
-	uint8_t *orig_addr;
+	u8 *orig_addr;
 	__be32 ip_src, ip_dst;
 
 	if (msg)
@@ -424,7 +424,7 @@ static void batadv_dbg_arp(struct batadv_priv *bat_priv, struct sk_buff *skb,
 #else
 
 static void batadv_dbg_arp(struct batadv_priv *bat_priv, struct sk_buff *skb,
-			   uint16_t type, int hdr_size, char *msg)
+			   u16 type, int hdr_size, char *msg)
 {
 }
 
@@ -709,9 +709,8 @@ void batadv_dat_status_update(struct net_device *net_dev)
  */
 static void batadv_dat_tvlv_ogm_handler_v1(struct batadv_priv *bat_priv,
 					   struct batadv_orig_node *orig,
-					   uint8_t flags,
-					   void *tvlv_value,
-					   uint16_t tvlv_value_len)
+					   u8 flags,
+					   void *tvlv_value, u16 tvlv_value_len)
 {
 	if (flags & BATADV_TVLV_HANDLER_OGM_CIFNOTFND)
 		clear_bit(BATADV_ORIG_CAPA_HAS_DAT, &orig->capabilities);
@@ -787,7 +786,7 @@ int batadv_dat_cache_seq_print_text(struct seq_file *seq, void *offset)
 	struct hlist_head *head;
 	unsigned long last_seen_jiffies;
 	int last_seen_msecs, last_seen_secs, last_seen_mins;
-	uint32_t i;
+	u32 i;
 
 	primary_if = batadv_seq_print_text_primary_if_get(seq);
 	if (!primary_if)
@@ -830,14 +829,14 @@ out:
  *
  * Returns the ARP type if the skb contains a valid ARP packet, 0 otherwise.
  */
-static uint16_t batadv_arp_get_type(struct batadv_priv *bat_priv,
-				    struct sk_buff *skb, int hdr_size)
+static u16 batadv_arp_get_type(struct batadv_priv *bat_priv,
+			       struct sk_buff *skb, int hdr_size)
 {
 	struct arphdr *arphdr;
 	struct ethhdr *ethhdr;
 	__be32 ip_src, ip_dst;
-	uint8_t *hw_src, *hw_dst;
-	uint16_t type = 0;
+	u8 *hw_src, *hw_dst;
+	u16 type = 0;
 
 	/* pull the ethernet header */
 	if (unlikely(!pskb_may_pull(skb, hdr_size + ETH_HLEN)))
@@ -934,9 +933,9 @@ static unsigned short batadv_dat_get_vid(struct sk_buff *skb, int *hdr_size)
 bool batadv_dat_snoop_outgoing_arp_request(struct batadv_priv *bat_priv,
 					   struct sk_buff *skb)
 {
-	uint16_t type = 0;
+	u16 type = 0;
 	__be32 ip_dst, ip_src;
-	uint8_t *hw_src;
+	u8 *hw_src;
 	bool ret = false;
 	struct batadv_dat_entry *dat_entry = NULL;
 	struct sk_buff *skb_new;
@@ -1022,9 +1021,9 @@ out:
 bool batadv_dat_snoop_incoming_arp_request(struct batadv_priv *bat_priv,
 					   struct sk_buff *skb, int hdr_size)
 {
-	uint16_t type;
+	u16 type;
 	__be32 ip_src, ip_dst;
-	uint8_t *hw_src;
+	u8 *hw_src;
 	struct sk_buff *skb_new;
 	struct batadv_dat_entry *dat_entry = NULL;
 	bool ret = false;
@@ -1100,9 +1099,9 @@ out:
 void batadv_dat_snoop_outgoing_arp_reply(struct batadv_priv *bat_priv,
 					 struct sk_buff *skb)
 {
-	uint16_t type;
+	u16 type;
 	__be32 ip_src, ip_dst;
-	uint8_t *hw_src, *hw_dst;
+	u8 *hw_src, *hw_dst;
 	int hdr_size = 0;
 	unsigned short vid;
 
@@ -1146,9 +1145,9 @@ void batadv_dat_snoop_outgoing_arp_reply(struct batadv_priv *bat_priv,
 bool batadv_dat_snoop_incoming_arp_reply(struct batadv_priv *bat_priv,
 					 struct sk_buff *skb, int hdr_size)
 {
-	uint16_t type;
+	u16 type;
 	__be32 ip_src, ip_dst;
-	uint8_t *hw_src, *hw_dst;
+	u8 *hw_src, *hw_dst;
 	bool dropped = false;
 	unsigned short vid;
 
@@ -1202,7 +1201,7 @@ out:
 bool batadv_dat_drop_broadcast_packet(struct batadv_priv *bat_priv,
 				      struct batadv_forw_packet *forw_packet)
 {
-	uint16_t type;
+	u16 type;
 	__be32 ip_dst;
 	struct batadv_dat_entry *dat_entry = NULL;
 	bool ret = false;
diff --git a/net/batman-adv/distributed-arp-table.h b/net/batman-adv/distributed-arp-table.h
index 3181507..26d4a52 100644
--- a/net/batman-adv/distributed-arp-table.h
+++ b/net/batman-adv/distributed-arp-table.h
@@ -54,7 +54,7 @@ bool batadv_dat_drop_broadcast_packet(struct batadv_priv *bat_priv,
 static inline void
 batadv_dat_init_orig_node_addr(struct batadv_orig_node *orig_node)
 {
-	uint32_t addr;
+	u32 addr;
 
 	addr = batadv_choose_orig(orig_node->orig, BATADV_DAT_ADDR_MAX);
 	orig_node->dat_addr = (batadv_dat_addr_t)addr;
@@ -69,7 +69,7 @@ static inline void
 batadv_dat_init_own_addr(struct batadv_priv *bat_priv,
 			 struct batadv_hard_iface *primary_if)
 {
-	uint32_t addr;
+	u32 addr;
 
 	addr = batadv_choose_orig(primary_if->net_dev->dev_addr,
 				  BATADV_DAT_ADDR_MAX);
@@ -89,7 +89,7 @@ int batadv_dat_cache_seq_print_text(struct seq_file *seq, void *offset);
  * Updates the ethtool statistics for the received packet if it is a DAT subtype
  */
 static inline void batadv_dat_inc_counter(struct batadv_priv *bat_priv,
-					  uint8_t subtype)
+					  u8 subtype)
 {
 	switch (subtype) {
 	case BATADV_P_DAT_DHT_GET:
@@ -169,7 +169,7 @@ static inline void batadv_dat_free(struct batadv_priv *bat_priv)
 }
 
 static inline void batadv_dat_inc_counter(struct batadv_priv *bat_priv,
-					  uint8_t subtype)
+					  u8 subtype)
 {
 }
 
diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index c0f0d01..ec5f7bc 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -66,7 +66,7 @@ void batadv_frag_purge_orig(struct batadv_orig_node *orig_node,
 			    bool (*check_cb)(struct batadv_frag_table_entry *))
 {
 	struct batadv_frag_table_entry *chain;
-	uint8_t i;
+	u8 i;
 
 	for (i = 0; i < BATADV_FRAG_BUFFER_COUNT; i++) {
 		chain = &orig_node->fragments[i];
@@ -110,7 +110,7 @@ static int batadv_frag_size_limit(void)
  * without searching for the right position.
  */
 static bool batadv_frag_init_chain(struct batadv_frag_table_entry *chain,
-				   uint16_t seqno)
+				   u16 seqno)
 {
 	if (chain->seqno == seqno)
 		return false;
@@ -145,8 +145,8 @@ static bool batadv_frag_insert_packet(struct batadv_orig_node *orig_node,
 	struct batadv_frag_list_entry *frag_entry_new = NULL, *frag_entry_curr;
 	struct batadv_frag_list_entry *frag_entry_last = NULL;
 	struct batadv_frag_packet *frag_packet;
-	uint8_t bucket;
-	uint16_t seqno, hdr_size = sizeof(struct batadv_frag_packet);
+	u8 bucket;
+	u16 seqno, hdr_size = sizeof(struct batadv_frag_packet);
 	bool ret = false;
 
 	/* Linearize packet to avoid linearizing 16 packets in a row when doing
@@ -351,7 +351,7 @@ bool batadv_frag_skb_fwd(struct sk_buff *skb,
 	struct batadv_orig_node *orig_node_dst = NULL;
 	struct batadv_neigh_node *neigh_node = NULL;
 	struct batadv_frag_packet *packet;
-	uint16_t total_size;
+	u16 total_size;
 	bool ret = false;
 
 	packet = (struct batadv_frag_packet *)skb->data;
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 6012e2b..6269c75 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -153,9 +153,9 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 	struct batadv_neigh_node *router;
 	struct batadv_neigh_ifinfo *router_ifinfo;
 	struct batadv_gw_node *gw_node, *curr_gw = NULL;
-	uint64_t max_gw_factor = 0, tmp_gw_factor = 0;
-	uint8_t max_tq = 0;
-	uint8_t tq_avg;
+	u64 max_gw_factor = 0, tmp_gw_factor = 0;
+	u8 max_tq = 0;
+	u8 tq_avg;
 	struct batadv_orig_node *orig_node;
 
 	rcu_read_lock();
@@ -348,7 +348,7 @@ void batadv_gw_check_election(struct batadv_priv *bat_priv,
 	struct batadv_neigh_ifinfo *router_gw_tq = NULL;
 	struct batadv_orig_node *curr_gw_orig;
 	struct batadv_neigh_node *router_gw = NULL, *router_orig = NULL;
-	uint8_t gw_tq_avg, orig_tq_avg;
+	u8 gw_tq_avg, orig_tq_avg;
 
 	curr_gw_orig = batadv_gw_get_selected_orig(bat_priv);
 	if (!curr_gw_orig)
@@ -688,7 +688,7 @@ out:
  */
 enum batadv_dhcp_recipient
 batadv_gw_dhcp_recipient_get(struct sk_buff *skb, unsigned int *header_len,
-			     uint8_t *chaddr)
+			     u8 *chaddr)
 {
 	enum batadv_dhcp_recipient ret = BATADV_DHCP_NO;
 	struct ethhdr *ethhdr;
@@ -698,7 +698,7 @@ batadv_gw_dhcp_recipient_get(struct sk_buff *skb, unsigned int *header_len,
 	struct vlan_ethhdr *vhdr;
 	int chaddr_offset;
 	__be16 proto;
-	uint8_t *p;
+	u8 *p;
 
 	/* check for ethernet header */
 	if (!pskb_may_pull(skb, *header_len + ETH_HLEN))
@@ -814,7 +814,7 @@ bool batadv_gw_out_of_range(struct batadv_priv *bat_priv,
 	struct batadv_neigh_ifinfo *curr_ifinfo, *old_ifinfo;
 	struct ethhdr *ethhdr = (struct ethhdr *)skb->data;
 	bool out_of_range = false;
-	uint8_t curr_tq_avg;
+	u8 curr_tq_avg;
 	unsigned short vid;
 
 	vid = batadv_get_vid(skb, 0);
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_client.h
index 89565b4..ef4d7e3 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -43,6 +43,6 @@ int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset);
 bool batadv_gw_out_of_range(struct batadv_priv *bat_priv, struct sk_buff *skb);
 enum batadv_dhcp_recipient
 batadv_gw_dhcp_recipient_get(struct sk_buff *skb, unsigned int *header_len,
-			     uint8_t *chaddr);
+			     u8 *chaddr);
 
 #endif /* _NET_BATMAN_ADV_GATEWAY_CLIENT_H_ */
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index 39cf44c..9e32c8e 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -39,7 +39,7 @@
  * Returns false on parse error and true otherwise.
  */
 static bool batadv_parse_gw_bandwidth(struct net_device *net_dev, char *buff,
-				      uint32_t *down, uint32_t *up)
+				      u32 *down, u32 *up)
 {
 	enum batadv_bandwidth_units bw_unit_type = BATADV_BW_UNIT_KBIT;
 	char *slash_ptr, *tmp_ptr;
@@ -124,7 +124,7 @@ static bool batadv_parse_gw_bandwidth(struct net_device *net_dev, char *buff,
 void batadv_gw_tvlv_container_update(struct batadv_priv *bat_priv)
 {
 	struct batadv_tvlv_gateway_data gw;
-	uint32_t down, up;
+	u32 down, up;
 	char gw_mode;
 
 	gw_mode = atomic_read(&bat_priv->gw_mode);
@@ -149,7 +149,7 @@ ssize_t batadv_gw_bandwidth_set(struct net_device *net_dev, char *buff,
 				size_t count)
 {
 	struct batadv_priv *bat_priv = netdev_priv(net_dev);
-	uint32_t down_curr, up_curr, down_new = 0, up_new = 0;
+	u32 down_curr, up_curr, down_new = 0, up_new = 0;
 	bool ret;
 
 	down_curr = (unsigned int)atomic_read(&bat_priv->gw.bandwidth_down);
@@ -195,9 +195,8 @@ end:
  */
 static void batadv_gw_tvlv_ogm_handler_v1(struct batadv_priv *bat_priv,
 					  struct batadv_orig_node *orig,
-					  uint8_t flags,
-					  void *tvlv_value,
-					  uint16_t tvlv_value_len)
+					  u8 flags,
+					  void *tvlv_value, u16 tvlv_value_len)
 {
 	struct batadv_tvlv_gateway_data gateway, *gateway_ptr;
 
diff --git a/net/batman-adv/hash.c b/net/batman-adv/hash.c
index e89f314..2ea6a18 100644
--- a/net/batman-adv/hash.c
+++ b/net/batman-adv/hash.c
@@ -25,7 +25,7 @@
 /* clears the hash */
 static void batadv_hash_init(struct batadv_hashtable *hash)
 {
-	uint32_t i;
+	u32 i;
 
 	for (i = 0; i < hash->size; i++) {
 		INIT_HLIST_HEAD(&hash->table[i]);
@@ -42,7 +42,7 @@ void batadv_hash_destroy(struct batadv_hashtable *hash)
 }
 
 /* allocates and clears the hash */
-struct batadv_hashtable *batadv_hash_new(uint32_t size)
+struct batadv_hashtable *batadv_hash_new(u32 size)
 {
 	struct batadv_hashtable *hash;
 
@@ -73,7 +73,7 @@ free_hash:
 void batadv_hash_set_lock_class(struct batadv_hashtable *hash,
 				struct lock_class_key *key)
 {
-	uint32_t i;
+	u32 i;
 
 	for (i = 0; i < hash->size; i++)
 		lockdep_set_class(&hash->list_locks[i], key);
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index 5065f50..3776262 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -39,17 +39,17 @@ typedef int (*batadv_hashdata_compare_cb)(const struct hlist_node *,
  * based on the key in the data of the first
  * argument and the size the second
  */
-typedef uint32_t (*batadv_hashdata_choose_cb)(const void *, uint32_t);
+typedef u32 (*batadv_hashdata_choose_cb)(const void *, u32);
 typedef void (*batadv_hashdata_free_cb)(struct hlist_node *, void *);
 
 struct batadv_hashtable {
 	struct hlist_head *table;   /* the hashtable itself with the buckets */
 	spinlock_t *list_locks;     /* spinlock for each hash list entry */
-	uint32_t size;		    /* size of hashtable */
+	u32 size;		    /* size of hashtable */
 };
 
 /* allocates and clears the hash */
-struct batadv_hashtable *batadv_hash_new(uint32_t size);
+struct batadv_hashtable *batadv_hash_new(u32 size);
 
 /* set class key for all locks */
 void batadv_hash_set_lock_class(struct batadv_hashtable *hash,
@@ -69,7 +69,7 @@ static inline void batadv_hash_delete(struct batadv_hashtable *hash,
 	struct hlist_head *head;
 	struct hlist_node *node, *node_tmp;
 	spinlock_t *list_lock; /* spinlock to protect write access */
-	uint32_t i;
+	u32 i;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -105,7 +105,7 @@ static inline int batadv_hash_add(struct batadv_hashtable *hash,
 				  const void *data,
 				  struct hlist_node *data_node)
 {
-	uint32_t index;
+	u32 index;
 	int ret = -1;
 	struct hlist_head *head;
 	struct hlist_node *node;
@@ -149,7 +149,7 @@ static inline void *batadv_hash_remove(struct batadv_hashtable *hash,
 				       batadv_hashdata_choose_cb choose,
 				       void *data)
 {
-	uint32_t index;
+	u32 index;
 	struct hlist_node *node;
 	struct hlist_head *head;
 	void *data_save = NULL;
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 07061bc..5a70b7e 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -183,7 +183,7 @@ static ssize_t batadv_socket_write(struct file *file, const char __user *buff,
 	struct batadv_orig_node *orig_node = NULL;
 	struct batadv_neigh_node *neigh_node = NULL;
 	size_t packet_len = sizeof(struct batadv_icmp_packet);
-	uint8_t *addr;
+	u8 *addr;
 
 	if (len < sizeof(struct batadv_icmp_header)) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 8457097..40750cb 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -234,7 +234,7 @@ void batadv_mesh_free(struct net_device *soft_iface)
  *
  * Returns 'true' if the mac address was found, false otherwise.
  */
-bool batadv_is_my_mac(struct batadv_priv *bat_priv, const uint8_t *addr)
+bool batadv_is_my_mac(struct batadv_priv *bat_priv, const u8 *addr)
 {
 	const struct batadv_hard_iface *hard_iface;
 	bool is_my_mac = false;
@@ -387,7 +387,7 @@ int batadv_batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	struct batadv_priv *bat_priv;
 	struct batadv_ogm_packet *batadv_ogm_packet;
 	struct batadv_hard_iface *hard_iface;
-	uint8_t idx;
+	u8 idx;
 	int ret;
 
 	hard_iface = container_of(ptype, struct batadv_hard_iface,
@@ -496,7 +496,7 @@ static void batadv_recv_handler_init(void)
 }
 
 int
-batadv_recv_handler_register(uint8_t packet_type,
+batadv_recv_handler_register(u8 packet_type,
 			     int (*recv_handler)(struct sk_buff *,
 						 struct batadv_hard_iface *))
 {
@@ -512,7 +512,7 @@ batadv_recv_handler_register(uint8_t packet_type,
 	return 0;
 }
 
-void batadv_recv_handler_unregister(uint8_t packet_type)
+void batadv_recv_handler_unregister(u8 packet_type)
 {
 	batadv_rx_handler[packet_type] = batadv_recv_unhandled_packet;
 }
@@ -642,8 +642,7 @@ batadv_tvlv_handler_free_ref(struct batadv_tvlv_handler *tvlv_handler)
  * Returns tvlv handler if found or NULL otherwise.
  */
 static struct batadv_tvlv_handler
-*batadv_tvlv_handler_get(struct batadv_priv *bat_priv,
-			 uint8_t type, uint8_t version)
+*batadv_tvlv_handler_get(struct batadv_priv *bat_priv, u8 type, u8 version)
 {
 	struct batadv_tvlv_handler *tvlv_handler_tmp, *tvlv_handler = NULL;
 
@@ -691,8 +690,7 @@ static void batadv_tvlv_container_free_ref(struct batadv_tvlv_container *tvlv)
  * Returns tvlv container if found or NULL otherwise.
  */
 static struct batadv_tvlv_container
-*batadv_tvlv_container_get(struct batadv_priv *bat_priv,
-			   uint8_t type, uint8_t version)
+*batadv_tvlv_container_get(struct batadv_priv *bat_priv, u8 type, u8 version)
 {
 	struct batadv_tvlv_container *tvlv_tmp, *tvlv = NULL;
 
@@ -723,10 +721,10 @@ static struct batadv_tvlv_container
  *
  * Returns size of all currently registered tvlv containers in bytes.
  */
-static uint16_t batadv_tvlv_container_list_size(struct batadv_priv *bat_priv)
+static u16 batadv_tvlv_container_list_size(struct batadv_priv *bat_priv)
 {
 	struct batadv_tvlv_container *tvlv;
-	uint16_t tvlv_len = 0;
+	u16 tvlv_len = 0;
 
 	hlist_for_each_entry(tvlv, &bat_priv->tvlv.container_list, list) {
 		tvlv_len += sizeof(struct batadv_tvlv_hdr);
@@ -764,7 +762,7 @@ static void batadv_tvlv_container_remove(struct batadv_tvlv_container *tvlv)
  * @version: tvlv container type to unregister
  */
 void batadv_tvlv_container_unregister(struct batadv_priv *bat_priv,
-				      uint8_t type, uint8_t version)
+				      u8 type, u8 version)
 {
 	struct batadv_tvlv_container *tvlv;
 
@@ -787,8 +785,8 @@ void batadv_tvlv_container_unregister(struct batadv_priv *bat_priv,
  * content is going to replace the old one.
  */
 void batadv_tvlv_container_register(struct batadv_priv *bat_priv,
-				    uint8_t type, uint8_t version,
-				    void *tvlv_value, uint16_t tvlv_value_len)
+				    u8 type, u8 version,
+				    void *tvlv_value, u16 tvlv_value_len)
 {
 	struct batadv_tvlv_container *tvlv_old, *tvlv_new;
 
@@ -861,14 +859,13 @@ static bool batadv_tvlv_realloc_packet_buff(unsigned char **packet_buff,
  *
  * Returns size of all appended tvlv containers in bytes.
  */
-uint16_t batadv_tvlv_container_ogm_append(struct batadv_priv *bat_priv,
-					  unsigned char **packet_buff,
-					  int *packet_buff_len,
-					  int packet_min_len)
+u16 batadv_tvlv_container_ogm_append(struct batadv_priv *bat_priv,
+				     unsigned char **packet_buff,
+				     int *packet_buff_len, int packet_min_len)
 {
 	struct batadv_tvlv_container *tvlv;
 	struct batadv_tvlv_hdr *tvlv_hdr;
-	uint16_t tvlv_value_len;
+	u16 tvlv_value_len;
 	void *tvlv_value;
 	bool ret;
 
@@ -893,7 +890,7 @@ uint16_t batadv_tvlv_container_ogm_append(struct batadv_priv *bat_priv,
 		tvlv_hdr->len = tvlv->tvlv_hdr.len;
 		tvlv_value = tvlv_hdr + 1;
 		memcpy(tvlv_value, tvlv + 1, ntohs(tvlv->tvlv_hdr.len));
-		tvlv_value = (uint8_t *)tvlv_value + ntohs(tvlv->tvlv_hdr.len);
+		tvlv_value = (u8 *)tvlv_value + ntohs(tvlv->tvlv_hdr.len);
 	}
 
 end:
@@ -920,8 +917,8 @@ static int batadv_tvlv_call_handler(struct batadv_priv *bat_priv,
 				    struct batadv_tvlv_handler *tvlv_handler,
 				    bool ogm_source,
 				    struct batadv_orig_node *orig_node,
-				    uint8_t *src, uint8_t *dst,
-				    void *tvlv_value, uint16_t tvlv_value_len)
+				    u8 *src, u8 *dst,
+				    void *tvlv_value, u16 tvlv_value_len)
 {
 	if (!tvlv_handler)
 		return NET_RX_SUCCESS;
@@ -972,13 +969,13 @@ static int batadv_tvlv_call_handler(struct batadv_priv *bat_priv,
 int batadv_tvlv_containers_process(struct batadv_priv *bat_priv,
 				   bool ogm_source,
 				   struct batadv_orig_node *orig_node,
-				   uint8_t *src, uint8_t *dst,
-				   void *tvlv_value, uint16_t tvlv_value_len)
+				   u8 *src, u8 *dst,
+				   void *tvlv_value, u16 tvlv_value_len)
 {
 	struct batadv_tvlv_handler *tvlv_handler;
 	struct batadv_tvlv_hdr *tvlv_hdr;
-	uint16_t tvlv_value_cont_len;
-	uint8_t cifnotfound = BATADV_TVLV_HANDLER_OGM_CIFNOTFND;
+	u16 tvlv_value_cont_len;
+	u8 cifnotfound = BATADV_TVLV_HANDLER_OGM_CIFNOTFND;
 	int ret = NET_RX_SUCCESS;
 
 	while (tvlv_value_len >= sizeof(*tvlv_hdr)) {
@@ -1000,7 +997,7 @@ int batadv_tvlv_containers_process(struct batadv_priv *bat_priv,
 						tvlv_value_cont_len);
 		if (tvlv_handler)
 			batadv_tvlv_handler_free_ref(tvlv_handler);
-		tvlv_value = (uint8_t *)tvlv_value + tvlv_value_cont_len;
+		tvlv_value = (u8 *)tvlv_value + tvlv_value_cont_len;
 		tvlv_value_len -= tvlv_value_cont_len;
 	}
 
@@ -1034,7 +1031,7 @@ void batadv_tvlv_ogm_receive(struct batadv_priv *bat_priv,
 			     struct batadv_orig_node *orig_node)
 {
 	void *tvlv_value;
-	uint16_t tvlv_value_len;
+	u16 tvlv_value_len;
 
 	if (!batadv_ogm_packet)
 		return;
@@ -1066,14 +1063,14 @@ void batadv_tvlv_ogm_receive(struct batadv_priv *bat_priv,
 void batadv_tvlv_handler_register(struct batadv_priv *bat_priv,
 				  void (*optr)(struct batadv_priv *bat_priv,
 					       struct batadv_orig_node *orig,
-					       uint8_t flags,
+					       u8 flags,
 					       void *tvlv_value,
-					       uint16_t tvlv_value_len),
+					       u16 tvlv_value_len),
 				  int (*uptr)(struct batadv_priv *bat_priv,
-					      uint8_t *src, uint8_t *dst,
+					      u8 *src, u8 *dst,
 					      void *tvlv_value,
-					      uint16_t tvlv_value_len),
-				  uint8_t type, uint8_t version, uint8_t flags)
+					      u16 tvlv_value_len),
+				  u8 type, u8 version, u8 flags)
 {
 	struct batadv_tvlv_handler *tvlv_handler;
 
@@ -1108,7 +1105,7 @@ void batadv_tvlv_handler_register(struct batadv_priv *bat_priv,
  * @version: tvlv handler version to be unregistered
  */
 void batadv_tvlv_handler_unregister(struct batadv_priv *bat_priv,
-				    uint8_t type, uint8_t version)
+				    u8 type, u8 version)
 {
 	struct batadv_tvlv_handler *tvlv_handler;
 
@@ -1134,9 +1131,9 @@ void batadv_tvlv_handler_unregister(struct batadv_priv *bat_priv,
  * @tvlv_value: tvlv content
  * @tvlv_value_len: tvlv content length
  */
-void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, uint8_t *src,
-			      uint8_t *dst, uint8_t type, uint8_t version,
-			      void *tvlv_value, uint16_t tvlv_value_len)
+void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, u8 *src,
+			      u8 *dst, u8 type, u8 version,
+			      void *tvlv_value, u16 tvlv_value_len)
 {
 	struct batadv_unicast_tvlv_packet *unicast_tvlv_packet;
 	struct batadv_tvlv_hdr *tvlv_hdr;
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 41d27c7..78500ac 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -193,7 +193,7 @@ extern struct workqueue_struct *batadv_event_workqueue;
 
 int batadv_mesh_init(struct net_device *soft_iface);
 void batadv_mesh_free(struct net_device *soft_iface);
-bool batadv_is_my_mac(struct batadv_priv *bat_priv, const uint8_t *addr);
+bool batadv_is_my_mac(struct batadv_priv *bat_priv, const u8 *addr);
 struct batadv_hard_iface *
 batadv_seq_print_text_primary_if_get(struct seq_file *seq);
 int batadv_max_header_len(void);
@@ -202,10 +202,10 @@ int batadv_batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 			   struct packet_type *ptype,
 			   struct net_device *orig_dev);
 int
-batadv_recv_handler_register(uint8_t packet_type,
+batadv_recv_handler_register(u8 packet_type,
 			     int (*recv_handler)(struct sk_buff *,
 						 struct batadv_hard_iface *));
-void batadv_recv_handler_unregister(uint8_t packet_type);
+void batadv_recv_handler_unregister(u8 packet_type);
 int batadv_algo_register(struct batadv_algo_ops *bat_algo_ops);
 int batadv_algo_select(struct batadv_priv *bat_priv, char *name);
 int batadv_algo_seq_print_text(struct seq_file *seq, void *offset);
@@ -304,7 +304,7 @@ static inline bool batadv_has_timed_out(unsigned long timestamp,
  * they handle overflows/underflows and can correctly check for a
  * predecessor/successor unless the variable sequence number has grown by
  * more then 2**(bitwidth(x)-1)-1.
- * This means that for a uint8_t with the maximum value 255, it would think:
+ * This means that for a u8 with the maximum value 255, it would think:
  *  - when adding nothing - it is neither a predecessor nor a successor
  *  - before adding more than 127 to the starting value - it is a predecessor,
  *  - when adding 128 - it is neither a predecessor nor a successor,
@@ -327,10 +327,9 @@ static inline void batadv_add_counter(struct batadv_priv *bat_priv, size_t idx,
 #define batadv_inc_counter(b, i) batadv_add_counter(b, i, 1)
 
 /* Sum and return the cpu-local counters for index 'idx' */
-static inline uint64_t batadv_sum_counter(struct batadv_priv *bat_priv,
-					  size_t idx)
+static inline u64 batadv_sum_counter(struct batadv_priv *bat_priv,  size_t idx)
 {
-	uint64_t *counters, sum = 0;
+	u64 *counters, sum = 0;
 	int cpu;
 
 	for_each_possible_cpu(cpu) {
@@ -348,39 +347,38 @@ static inline uint64_t batadv_sum_counter(struct batadv_priv *bat_priv,
 #define BATADV_SKB_CB(__skb)       ((struct batadv_skb_cb *)&((__skb)->cb[0]))
 
 void batadv_tvlv_container_register(struct batadv_priv *bat_priv,
-				    uint8_t type, uint8_t version,
-				    void *tvlv_value, uint16_t tvlv_value_len);
-uint16_t batadv_tvlv_container_ogm_append(struct batadv_priv *bat_priv,
-					  unsigned char **packet_buff,
-					  int *packet_buff_len,
-					  int packet_min_len);
+				    u8 type, u8 version,
+				    void *tvlv_value, u16 tvlv_value_len);
+u16 batadv_tvlv_container_ogm_append(struct batadv_priv *bat_priv,
+				     unsigned char **packet_buff,
+				     int *packet_buff_len, int packet_min_len);
 void batadv_tvlv_ogm_receive(struct batadv_priv *bat_priv,
 			     struct batadv_ogm_packet *batadv_ogm_packet,
 			     struct batadv_orig_node *orig_node);
 void batadv_tvlv_container_unregister(struct batadv_priv *bat_priv,
-				      uint8_t type, uint8_t version);
+				      u8 type, u8 version);
 
 void batadv_tvlv_handler_register(struct batadv_priv *bat_priv,
 				  void (*optr)(struct batadv_priv *bat_priv,
 					       struct batadv_orig_node *orig,
-					       uint8_t flags,
+					       u8 flags,
 					       void *tvlv_value,
-					       uint16_t tvlv_value_len),
+					       u16 tvlv_value_len),
 				  int (*uptr)(struct batadv_priv *bat_priv,
-					      uint8_t *src, uint8_t *dst,
+					      u8 *src, u8 *dst,
 					      void *tvlv_value,
-					      uint16_t tvlv_value_len),
-				  uint8_t type, uint8_t version, uint8_t flags);
+					      u16 tvlv_value_len),
+				  u8 type, u8 version, u8 flags);
 void batadv_tvlv_handler_unregister(struct batadv_priv *bat_priv,
-				    uint8_t type, uint8_t version);
+				    u8 type, u8 version);
 int batadv_tvlv_containers_process(struct batadv_priv *bat_priv,
 				   bool ogm_source,
 				   struct batadv_orig_node *orig_node,
-				   uint8_t *src, uint8_t *dst,
-				   void *tvlv_buff, uint16_t tvlv_buff_len);
-void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, uint8_t *src,
-			      uint8_t *dst, uint8_t type, uint8_t version,
-			      void *tvlv_value, uint16_t tvlv_value_len);
+				   u8 *src, u8 *dst,
+				   void *tvlv_buff, u16 tvlv_buff_len);
+void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, u8 *src,
+			      u8 *dst, u8 type, u8 version,
+			      void *tvlv_value, u16 tvlv_value_len);
 unsigned short batadv_get_vid(struct sk_buff *skb, size_t header_len);
 bool batadv_vlan_ap_isola_get(struct batadv_priv *bat_priv, unsigned short vid);
 
diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index 68a9554..2593f0f 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -89,7 +89,7 @@ static int batadv_mcast_mla_softif_get(struct net_device *dev,
  * Returns true if the given address is already in the given list.
  * Otherwise returns false.
  */
-static bool batadv_mcast_mla_is_duplicate(uint8_t *mcast_addr,
+static bool batadv_mcast_mla_is_duplicate(u8 *mcast_addr,
 					  struct hlist_head *mcast_list)
 {
 	struct batadv_hw_addr *mcast_entry;
@@ -595,7 +595,7 @@ batadv_mcast_forw_mode(struct batadv_priv *bat_priv, struct sk_buff *skb,
  */
 static void batadv_mcast_want_unsnoop_update(struct batadv_priv *bat_priv,
 					     struct batadv_orig_node *orig,
-					     uint8_t mcast_flags)
+					     u8 mcast_flags)
 {
 	struct hlist_node *node = &orig->mcast_want_all_unsnoopables_node;
 	struct hlist_head *head = &bat_priv->mcast.want_all_unsnoopables_list;
@@ -638,7 +638,7 @@ static void batadv_mcast_want_unsnoop_update(struct batadv_priv *bat_priv,
  */
 static void batadv_mcast_want_ipv4_update(struct batadv_priv *bat_priv,
 					  struct batadv_orig_node *orig,
-					  uint8_t mcast_flags)
+					  u8 mcast_flags)
 {
 	struct hlist_node *node = &orig->mcast_want_all_ipv4_node;
 	struct hlist_head *head = &bat_priv->mcast.want_all_ipv4_list;
@@ -681,7 +681,7 @@ static void batadv_mcast_want_ipv4_update(struct batadv_priv *bat_priv,
  */
 static void batadv_mcast_want_ipv6_update(struct batadv_priv *bat_priv,
 					  struct batadv_orig_node *orig,
-					  uint8_t mcast_flags)
+					  u8 mcast_flags)
 {
 	struct hlist_node *node = &orig->mcast_want_all_ipv6_node;
 	struct hlist_head *head = &bat_priv->mcast.want_all_ipv6_list;
@@ -721,17 +721,17 @@ static void batadv_mcast_want_ipv6_update(struct batadv_priv *bat_priv,
  */
 static void batadv_mcast_tvlv_ogm_handler_v1(struct batadv_priv *bat_priv,
 					     struct batadv_orig_node *orig,
-					     uint8_t flags,
+					     u8 flags,
 					     void *tvlv_value,
-					     uint16_t tvlv_value_len)
+					     u16 tvlv_value_len)
 {
 	bool orig_mcast_enabled = !(flags & BATADV_TVLV_HANDLER_OGM_CIFNOTFND);
-	uint8_t mcast_flags = BATADV_NO_FLAGS;
+	u8 mcast_flags = BATADV_NO_FLAGS;
 	bool orig_initialized;
 
 	if (orig_mcast_enabled && tvlv_value &&
 	    (tvlv_value_len >= sizeof(mcast_flags)))
-		mcast_flags = *(uint8_t *)tvlv_value;
+		mcast_flags = *(u8 *)tvlv_value;
 
 	spin_lock_bh(&orig->mcast_handler_lock);
 	orig_initialized = test_bit(BATADV_ORIG_CAPA_HAS_MCAST,
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 4660401..60dc7a6 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -130,9 +130,8 @@ void batadv_nc_status_update(struct net_device *net_dev)
  */
 static void batadv_nc_tvlv_ogm_handler_v1(struct batadv_priv *bat_priv,
 					  struct batadv_orig_node *orig,
-					  uint8_t flags,
-					  void *tvlv_value,
-					  uint16_t tvlv_value_len)
+					  u8 flags,
+					  void *tvlv_value, u16 tvlv_value_len)
 {
 	if (flags & BATADV_TVLV_HANDLER_OGM_CIFNOTFND)
 		clear_bit(BATADV_ORIG_CAPA_HAS_NC, &orig->capabilities);
@@ -382,7 +381,7 @@ static void batadv_nc_purge_orig_hash(struct batadv_priv *bat_priv)
 	struct batadv_hashtable *hash = bat_priv->orig_hash;
 	struct hlist_head *head;
 	struct batadv_orig_node *orig_node;
-	uint32_t i;
+	u32 i;
 
 	if (!hash)
 		return;
@@ -418,7 +417,7 @@ static void batadv_nc_purge_paths(struct batadv_priv *bat_priv,
 	struct hlist_node *node_tmp;
 	struct batadv_nc_path *nc_path;
 	spinlock_t *lock; /* Protects lists in hash */
-	uint32_t i;
+	u32 i;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -478,10 +477,10 @@ static void batadv_nc_hash_key_gen(struct batadv_nc_path *key, const char *src,
  *
  * Returns the selected index in the hash table for the given data.
  */
-static uint32_t batadv_nc_hash_choose(const void *data, uint32_t size)
+static u32 batadv_nc_hash_choose(const void *data, u32 size)
 {
 	const struct batadv_nc_path *nc_path = data;
-	uint32_t hash = 0;
+	u32 hash = 0;
 
 	hash = jhash(&nc_path->prev_hop, sizeof(nc_path->prev_hop), hash);
 	hash = jhash(&nc_path->next_hop, sizeof(nc_path->next_hop), hash);
@@ -744,8 +743,8 @@ static bool batadv_can_nc_with_orig(struct batadv_priv *bat_priv,
 				    struct batadv_ogm_packet *ogm_packet)
 {
 	struct batadv_orig_ifinfo *orig_ifinfo;
-	uint32_t last_real_seqno;
-	uint8_t last_ttl;
+	u32 last_real_seqno;
+	u8 last_ttl;
 
 	orig_ifinfo = batadv_orig_ifinfo_get(orig_node, BATADV_IF_DEFAULT);
 	if (!orig_ifinfo)
@@ -938,8 +937,8 @@ out:
  */
 static struct batadv_nc_path *batadv_nc_get_path(struct batadv_priv *bat_priv,
 						 struct batadv_hashtable *hash,
-						 uint8_t *src,
-						 uint8_t *dst)
+						 u8 *src,
+						 u8 *dst)
 {
 	int hash_added;
 	struct batadv_nc_path *nc_path, nc_path_key;
@@ -991,9 +990,9 @@ static struct batadv_nc_path *batadv_nc_get_path(struct batadv_priv *bat_priv,
  *  selection of a receiver with slightly lower TQ than the other
  * @tq: to be weighted tq value
  */
-static uint8_t batadv_nc_random_weight_tq(uint8_t tq)
+static u8 batadv_nc_random_weight_tq(u8 tq)
 {
-	uint8_t rand_val, rand_tq;
+	u8 rand_val, rand_tq;
 
 	get_random_bytes(&rand_val, sizeof(rand_val));
 
@@ -1038,7 +1037,7 @@ static bool batadv_nc_code_packets(struct batadv_priv *bat_priv,
 				   struct batadv_nc_packet *nc_packet,
 				   struct batadv_neigh_node *neigh_node)
 {
-	uint8_t tq_weighted_neigh, tq_weighted_coding, tq_tmp;
+	u8 tq_weighted_neigh, tq_weighted_coding, tq_tmp;
 	struct sk_buff *skb_dest, *skb_src;
 	struct batadv_unicast_packet *packet1;
 	struct batadv_unicast_packet *packet2;
@@ -1047,7 +1046,7 @@ static bool batadv_nc_code_packets(struct batadv_priv *bat_priv,
 	struct batadv_neigh_node *router_coding = NULL;
 	struct batadv_neigh_ifinfo *router_neigh_ifinfo = NULL;
 	struct batadv_neigh_ifinfo *router_coding_ifinfo = NULL;
-	uint8_t *first_source, *first_dest, *second_source, *second_dest;
+	u8 *first_source, *first_dest, *second_source, *second_dest;
 	__be32 packet_id1, packet_id2;
 	size_t count;
 	bool res = false;
@@ -1231,8 +1230,7 @@ out:
  *
  * Returns true if coding of a decoded packet is allowed.
  */
-static bool batadv_nc_skb_coding_possible(struct sk_buff *skb,
-					  uint8_t *dst, uint8_t *src)
+static bool batadv_nc_skb_coding_possible(struct sk_buff *skb, u8 *dst, u8 *src)
 {
 	if (BATADV_SKB_CB(skb)->decoded && !batadv_compare_eth(dst, src))
 		return false;
@@ -1255,7 +1253,7 @@ batadv_nc_path_search(struct batadv_priv *bat_priv,
 		      struct batadv_nc_node *in_nc_node,
 		      struct batadv_nc_node *out_nc_node,
 		      struct sk_buff *skb,
-		      uint8_t *eth_dst)
+		      u8 *eth_dst)
 {
 	struct batadv_nc_path *nc_path, nc_path_key;
 	struct batadv_nc_packet *nc_packet_out = NULL;
@@ -1321,8 +1319,8 @@ batadv_nc_path_search(struct batadv_priv *bat_priv,
 static struct batadv_nc_packet *
 batadv_nc_skb_src_search(struct batadv_priv *bat_priv,
 			 struct sk_buff *skb,
-			 uint8_t *eth_dst,
-			 uint8_t *eth_src,
+			 u8 *eth_dst,
+			 u8 *eth_src,
 			 struct batadv_nc_node *in_nc_node)
 {
 	struct batadv_orig_node *orig_node;
@@ -1362,7 +1360,7 @@ batadv_nc_skb_src_search(struct batadv_priv *bat_priv,
  */
 static void batadv_nc_skb_store_before_coding(struct batadv_priv *bat_priv,
 					      struct sk_buff *skb,
-					      uint8_t *eth_dst_new)
+					      u8 *eth_dst_new)
 {
 	struct ethhdr *ethhdr;
 
@@ -1638,7 +1636,7 @@ batadv_nc_skb_decode_packet(struct batadv_priv *bat_priv, struct sk_buff *skb,
 	struct batadv_unicast_packet *unicast_packet;
 	struct batadv_coded_packet coded_packet_tmp;
 	struct ethhdr *ethhdr, ethhdr_tmp;
-	uint8_t *orig_dest, ttl, ttvn;
+	u8 *orig_dest, ttl, ttvn;
 	unsigned int coding_len;
 	int err;
 
@@ -1730,7 +1728,7 @@ batadv_nc_find_decoding_packet(struct batadv_priv *bat_priv,
 	struct batadv_hashtable *hash = bat_priv->nc.decoding_hash;
 	struct batadv_nc_packet *tmp_nc_packet, *nc_packet = NULL;
 	struct batadv_nc_path *nc_path, nc_path_key;
-	uint8_t *dest, *source;
+	u8 *dest, *source;
 	__be32 packet_id;
 	int index;
 
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 32a0fcf..4500e3a 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -452,8 +452,7 @@ out:
  */
 struct batadv_neigh_node *
 batadv_neigh_node_new(struct batadv_hard_iface *hard_iface,
-		      const uint8_t *neigh_addr,
-		      struct batadv_orig_node *orig_node)
+		      const u8 *neigh_addr, struct batadv_orig_node *orig_node)
 {
 	struct batadv_neigh_node *neigh_node;
 
@@ -489,7 +488,7 @@ out:
 struct batadv_neigh_node *
 batadv_neigh_node_get(const struct batadv_orig_node *orig_node,
 		      const struct batadv_hard_iface *hard_iface,
-		      const uint8_t *addr)
+		      const u8 *addr)
 {
 	struct batadv_neigh_node *tmp_neigh_node, *res = NULL;
 
@@ -624,7 +623,7 @@ void batadv_originator_free(struct batadv_priv *bat_priv)
 	struct hlist_head *head;
 	spinlock_t *list_lock; /* spinlock to protect write access */
 	struct batadv_orig_node *orig_node;
-	uint32_t i;
+	u32 i;
 
 	if (!hash)
 		return;
@@ -659,7 +658,7 @@ void batadv_originator_free(struct batadv_priv *bat_priv)
  * Returns the newly created object or NULL on failure.
  */
 struct batadv_orig_node *batadv_orig_node_new(struct batadv_priv *bat_priv,
-					      const uint8_t *addr)
+					      const u8 *addr)
 {
 	struct batadv_orig_node *orig_node;
 	struct batadv_orig_node_vlan *vlan;
@@ -981,7 +980,7 @@ static void _batadv_purge_orig(struct batadv_priv *bat_priv)
 	struct hlist_head *head;
 	spinlock_t *list_lock; /* spinlock to protect write access */
 	struct batadv_orig_node *orig_node;
-	uint32_t i;
+	u32 i;
 
 	if (!hash)
 		return;
@@ -1115,7 +1114,7 @@ int batadv_orig_hash_add_if(struct batadv_hard_iface *hard_iface,
 	struct batadv_hashtable *hash = bat_priv->orig_hash;
 	struct hlist_head *head;
 	struct batadv_orig_node *orig_node;
-	uint32_t i;
+	u32 i;
 	int ret;
 
 	/* resize all orig nodes because orig_node->bcast_own(_sum) depend on
@@ -1152,7 +1151,7 @@ int batadv_orig_hash_del_if(struct batadv_hard_iface *hard_iface,
 	struct batadv_hard_iface *hard_iface_tmp;
 	struct batadv_orig_node *orig_node;
 	struct batadv_algo_ops *bao = bat_priv->bat_algo_ops;
-	uint32_t i;
+	u32 i;
 	int ret;
 
 	/* resize all orig nodes because orig_node->bcast_own(_sum) depend on
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 79734d3..3fc76f6 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -40,15 +40,14 @@ void batadv_purge_orig_ref(struct batadv_priv *bat_priv);
 void batadv_orig_node_free_ref(struct batadv_orig_node *orig_node);
 void batadv_orig_node_free_ref_now(struct batadv_orig_node *orig_node);
 struct batadv_orig_node *batadv_orig_node_new(struct batadv_priv *bat_priv,
-					      const uint8_t *addr);
+					      const u8 *addr);
 struct batadv_neigh_node *
 batadv_neigh_node_get(const struct batadv_orig_node *orig_node,
 		      const struct batadv_hard_iface *hard_iface,
-		      const uint8_t *addr);
+		      const u8 *addr);
 struct batadv_neigh_node *
 batadv_neigh_node_new(struct batadv_hard_iface *hard_iface,
-		      const uint8_t *neigh_addr,
-		      struct batadv_orig_node *orig_node);
+		      const u8 *neigh_addr, struct batadv_orig_node *orig_node);
 void batadv_neigh_node_free_ref(struct batadv_neigh_node *neigh_node);
 struct batadv_neigh_node *
 batadv_orig_router_get(struct batadv_orig_node *orig_node,
@@ -86,9 +85,9 @@ void batadv_orig_node_vlan_free_ref(struct batadv_orig_node_vlan *orig_vlan);
 /* hashfunction to choose an entry in a hash table of given size
  * hash algorithm from http://en.wikipedia.org/wiki/Hash_table
  */
-static inline uint32_t batadv_choose_orig(const void *data, uint32_t size)
+static inline u32 batadv_choose_orig(const void *data, u32 size)
 {
-	uint32_t hash = 0;
+	u32 hash = 0;
 
 	hash = jhash(data, ETH_ALEN, hash);
 	return hash % size;
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 9e747c0..11f996b 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -197,8 +197,8 @@ enum batadv_tvlv_type {
  * transport the claim type and the group id
  */
 struct batadv_bla_claim_dst {
-	uint8_t magic[3];	/* FF:43:05 */
-	uint8_t type;		/* bla_claimframe */
+	u8     magic[3];	/* FF:43:05 */
+	u8     type;		/* bla_claimframe */
 	__be16 group;		/* group id */
 };
 
@@ -213,16 +213,16 @@ struct batadv_bla_claim_dst {
  * @tvlv_len: length of tvlv data following the ogm header
  */
 struct batadv_ogm_packet {
-	uint8_t  packet_type;
-	uint8_t  version;
-	uint8_t  ttl;
-	uint8_t  flags;
-	__be32   seqno;
-	uint8_t  orig[ETH_ALEN];
-	uint8_t  prev_sender[ETH_ALEN];
-	uint8_t  reserved;
-	uint8_t  tq;
-	__be16   tvlv_len;
+	u8     packet_type;
+	u8     version;
+	u8     ttl;
+	u8     flags;
+	__be32 seqno;
+	u8     orig[ETH_ALEN];
+	u8     prev_sender[ETH_ALEN];
+	u8     reserved;
+	u8     tq;
+	__be16 tvlv_len;
 	/* __packed is not needed as the struct size is divisible by 4,
 	 * and the largest data type in this struct has a size of 4.
 	 */
@@ -246,14 +246,14 @@ struct batadv_ogm_packet {
  * members are padded the same way as they are in real packets.
  */
 struct batadv_icmp_header {
-	uint8_t  packet_type;
-	uint8_t  version;
-	uint8_t  ttl;
-	uint8_t  msg_type; /* see ICMP message types above */
-	uint8_t  dst[ETH_ALEN];
-	uint8_t  orig[ETH_ALEN];
-	uint8_t  uid;
-	uint8_t  align[3];
+	u8 packet_type;
+	u8 version;
+	u8 ttl;
+	u8 msg_type; /* see ICMP message types above */
+	u8 dst[ETH_ALEN];
+	u8 orig[ETH_ALEN];
+	u8 uid;
+	u8 align[3];
 };
 
 /**
@@ -269,15 +269,15 @@ struct batadv_icmp_header {
  * @seqno: ICMP sequence number
  */
 struct batadv_icmp_packet {
-	uint8_t  packet_type;
-	uint8_t  version;
-	uint8_t  ttl;
-	uint8_t  msg_type; /* see ICMP message types above */
-	uint8_t  dst[ETH_ALEN];
-	uint8_t  orig[ETH_ALEN];
-	uint8_t  uid;
-	uint8_t  reserved;
-	__be16   seqno;
+	u8     packet_type;
+	u8     version;
+	u8     ttl;
+	u8     msg_type; /* see ICMP message types above */
+	u8     dst[ETH_ALEN];
+	u8     orig[ETH_ALEN];
+	u8     uid;
+	u8     reserved;
+	__be16 seqno;
 };
 
 #define BATADV_RR_LEN 16
@@ -296,16 +296,16 @@ struct batadv_icmp_packet {
  * @rr: route record array
  */
 struct batadv_icmp_packet_rr {
-	uint8_t  packet_type;
-	uint8_t  version;
-	uint8_t  ttl;
-	uint8_t  msg_type; /* see ICMP message types above */
-	uint8_t  dst[ETH_ALEN];
-	uint8_t  orig[ETH_ALEN];
-	uint8_t  uid;
-	uint8_t  rr_cur;
-	__be16   seqno;
-	uint8_t  rr[BATADV_RR_LEN][ETH_ALEN];
+	u8     packet_type;
+	u8     version;
+	u8     ttl;
+	u8     msg_type; /* see ICMP message types above */
+	u8     dst[ETH_ALEN];
+	u8     orig[ETH_ALEN];
+	u8     uid;
+	u8     rr_cur;
+	__be16 seqno;
+	u8     rr[BATADV_RR_LEN][ETH_ALEN];
 };
 
 #define BATADV_ICMP_MAX_PACKET_SIZE	sizeof(struct batadv_icmp_packet_rr)
@@ -331,11 +331,11 @@ struct batadv_icmp_packet_rr {
  * @dest: originator destination of the unicast packet
  */
 struct batadv_unicast_packet {
-	uint8_t  packet_type;
-	uint8_t  version;
-	uint8_t  ttl;
-	uint8_t  ttvn; /* destination translation table version number */
-	uint8_t  dest[ETH_ALEN];
+	u8 packet_type;
+	u8 version;
+	u8 ttl;
+	u8 ttvn; /* destination translation table version number */
+	u8 dest[ETH_ALEN];
 	/* "4 bytes boundary + 2 bytes" long to make the payload after the
 	 * following ethernet header again 4 bytes boundary aligned
 	 */
@@ -349,9 +349,9 @@ struct batadv_unicast_packet {
  */
 struct batadv_unicast_4addr_packet {
 	struct batadv_unicast_packet u;
-	uint8_t src[ETH_ALEN];
-	uint8_t subtype;
-	uint8_t reserved;
+	u8 src[ETH_ALEN];
+	u8 subtype;
+	u8 reserved;
 	/* "4 bytes boundary + 2 bytes" long to make the payload after the
 	 * following ethernet header again 4 bytes boundary aligned
 	 */
@@ -370,22 +370,22 @@ struct batadv_unicast_4addr_packet {
  * @total_size: size of the merged packet
  */
 struct batadv_frag_packet {
-	uint8_t packet_type;
-	uint8_t version;  /* batman version field */
-	uint8_t ttl;
+	u8     packet_type;
+	u8     version;  /* batman version field */
+	u8     ttl;
 #if defined(__BIG_ENDIAN_BITFIELD)
-	uint8_t no:4;
-	uint8_t reserved:4;
+	u8     no:4;
+	u8     reserved:4;
 #elif defined(__LITTLE_ENDIAN_BITFIELD)
-	uint8_t reserved:4;
-	uint8_t no:4;
+	u8     reserved:4;
+	u8     no:4;
 #else
 #error "unknown bitfield endianness"
 #endif
-	uint8_t dest[ETH_ALEN];
-	uint8_t orig[ETH_ALEN];
-	__be16  seqno;
-	__be16  total_size;
+	u8     dest[ETH_ALEN];
+	u8     orig[ETH_ALEN];
+	__be16 seqno;
+	__be16 total_size;
 };
 
 /**
@@ -398,12 +398,12 @@ struct batadv_frag_packet {
  * @orig: originator of the broadcast packet
  */
 struct batadv_bcast_packet {
-	uint8_t  packet_type;
-	uint8_t  version;  /* batman version field */
-	uint8_t  ttl;
-	uint8_t  reserved;
-	__be32   seqno;
-	uint8_t  orig[ETH_ALEN];
+	u8     packet_type;
+	u8     version;  /* batman version field */
+	u8     ttl;
+	u8     reserved;
+	__be32 seqno;
+	u8     orig[ETH_ALEN];
 	/* "4 bytes boundary + 2 bytes" long to make the payload after the
 	 * following ethernet header again 4 bytes boundary aligned
 	 */
@@ -428,21 +428,21 @@ struct batadv_bcast_packet {
  * @coded_len: length of network coded part of the payload
  */
 struct batadv_coded_packet {
-	uint8_t  packet_type;
-	uint8_t  version;  /* batman version field */
-	uint8_t  ttl;
-	uint8_t  first_ttvn;
-	/* uint8_t  first_dest[ETH_ALEN]; - saved in mac header destination */
-	uint8_t  first_source[ETH_ALEN];
-	uint8_t  first_orig_dest[ETH_ALEN];
-	__be32   first_crc;
-	uint8_t  second_ttl;
-	uint8_t  second_ttvn;
-	uint8_t  second_dest[ETH_ALEN];
-	uint8_t  second_source[ETH_ALEN];
-	uint8_t  second_orig_dest[ETH_ALEN];
-	__be32   second_crc;
-	__be16   coded_len;
+	u8     packet_type;
+	u8     version;  /* batman version field */
+	u8     ttl;
+	u8     first_ttvn;
+	/* u8  first_dest[ETH_ALEN]; - saved in mac header destination */
+	u8     first_source[ETH_ALEN];
+	u8     first_orig_dest[ETH_ALEN];
+	__be32 first_crc;
+	u8     second_ttl;
+	u8     second_ttvn;
+	u8     second_dest[ETH_ALEN];
+	u8     second_source[ETH_ALEN];
+	u8     second_orig_dest[ETH_ALEN];
+	__be32 second_crc;
+	__be16 coded_len;
 };
 
 #pragma pack()
@@ -459,14 +459,14 @@ struct batadv_coded_packet {
  * @align: 2 bytes to align the header to a 4 byte boundary
  */
 struct batadv_unicast_tvlv_packet {
-	uint8_t  packet_type;
-	uint8_t  version;  /* batman version field */
-	uint8_t  ttl;
-	uint8_t  reserved;
-	uint8_t  dst[ETH_ALEN];
-	uint8_t  src[ETH_ALEN];
-	__be16   tvlv_len;
-	uint16_t align;
+	u8     packet_type;
+	u8     version;  /* batman version field */
+	u8     ttl;
+	u8     reserved;
+	u8     dst[ETH_ALEN];
+	u8     src[ETH_ALEN];
+	__be16 tvlv_len;
+	u16    align;
 };
 
 /**
@@ -476,9 +476,9 @@ struct batadv_unicast_tvlv_packet {
  * @len: tvlv container length
  */
 struct batadv_tvlv_hdr {
-	uint8_t type;
-	uint8_t version;
-	__be16  len;
+	u8     type;
+	u8     version;
+	__be16 len;
 };
 
 /**
@@ -500,9 +500,9 @@ struct batadv_tvlv_gateway_data {
  *  one batadv_tvlv_tt_vlan_data object per announced vlan
  */
 struct batadv_tvlv_tt_data {
-	uint8_t flags;
-	uint8_t ttvn;
-	__be16  num_vlan;
+	u8     flags;
+	u8     ttvn;
+	__be16 num_vlan;
 };
 
 /**
@@ -513,9 +513,9 @@ struct batadv_tvlv_tt_data {
  * @reserved: unused, useful for alignment purposes
  */
 struct batadv_tvlv_tt_vlan_data {
-	__be32	crc;
-	__be16	vid;
-	uint16_t reserved;
+	__be32 crc;
+	__be16 vid;
+	u16    reserved;
 };
 
 /**
@@ -527,9 +527,9 @@ struct batadv_tvlv_tt_vlan_data {
  * @vid: VLAN identifier
  */
 struct batadv_tvlv_tt_change {
-	uint8_t flags;
-	uint8_t reserved[3];
-	uint8_t addr[ETH_ALEN];
+	u8     flags;
+	u8     reserved[3];
+	u8     addr[ETH_ALEN];
 	__be16 vid;
 };
 
@@ -539,7 +539,7 @@ struct batadv_tvlv_tt_change {
  * @vid: VLAN identifier
  */
 struct batadv_tvlv_roam_adv {
-	uint8_t  client[ETH_ALEN];
+	u8     client[ETH_ALEN];
 	__be16 vid;
 };
 
@@ -549,8 +549,8 @@ struct batadv_tvlv_roam_adv {
  * @reserved: reserved field
  */
 struct batadv_tvlv_mcast_data {
-	uint8_t	flags;
-	uint8_t reserved[3];
+	u8 flags;
+	u8 reserved[3];
 };
 
 #endif /* _NET_BATMAN_ADV_PACKET_H_ */
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index c360c0c..8d990b0 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -145,7 +145,7 @@ out:
  *  0 if the packet is to be accepted
  *  1 if the packet is to be ignored.
  */
-int batadv_window_protected(struct batadv_priv *bat_priv, int32_t seq_num_diff,
+int batadv_window_protected(struct batadv_priv *bat_priv, s32 seq_num_diff,
 			    unsigned long *last_reset)
 {
 	if (seq_num_diff <= -BATADV_TQ_LOCAL_WINDOW_SIZE ||
@@ -653,19 +653,19 @@ out:
 static bool
 batadv_reroute_unicast_packet(struct batadv_priv *bat_priv,
 			      struct batadv_unicast_packet *unicast_packet,
-			      uint8_t *dst_addr, unsigned short vid)
+			      u8 *dst_addr, unsigned short vid)
 {
 	struct batadv_orig_node *orig_node = NULL;
 	struct batadv_hard_iface *primary_if = NULL;
 	bool ret = false;
-	uint8_t *orig_addr, orig_ttvn;
+	u8 *orig_addr, orig_ttvn;
 
 	if (batadv_is_my_client(bat_priv, dst_addr, vid)) {
 		primary_if = batadv_primary_if_get_selected(bat_priv);
 		if (!primary_if)
 			goto out;
 		orig_addr = primary_if->net_dev->dev_addr;
-		orig_ttvn = (uint8_t)atomic_read(&bat_priv->tt.vn);
+		orig_ttvn = (u8)atomic_read(&bat_priv->tt.vn);
 	} else {
 		orig_node = batadv_transtable_search(bat_priv, NULL, dst_addr,
 						     vid);
@@ -676,7 +676,7 @@ batadv_reroute_unicast_packet(struct batadv_priv *bat_priv,
 			goto out;
 
 		orig_addr = orig_node->orig;
-		orig_ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
+		orig_ttvn = (u8)atomic_read(&orig_node->last_ttvn);
 	}
 
 	/* update the packet header */
@@ -698,7 +698,7 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 	struct batadv_unicast_packet *unicast_packet;
 	struct batadv_hard_iface *primary_if;
 	struct batadv_orig_node *orig_node;
-	uint8_t curr_ttvn, old_ttvn;
+	u8 curr_ttvn, old_ttvn;
 	struct ethhdr *ethhdr;
 	unsigned short vid;
 	int is_old_ttvn;
@@ -740,7 +740,7 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 	 * value is used later to check if the node which sent (or re-routed
 	 * last time) the packet had an updated information or not
 	 */
-	curr_ttvn = (uint8_t)atomic_read(&bat_priv->tt.vn);
+	curr_ttvn = (u8)atomic_read(&bat_priv->tt.vn);
 	if (!batadv_is_my_mac(bat_priv, unicast_packet->dest)) {
 		orig_node = batadv_orig_hash_find(bat_priv,
 						  unicast_packet->dest);
@@ -751,7 +751,7 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 		if (!orig_node)
 			return 0;
 
-		curr_ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
+		curr_ttvn = (u8)atomic_read(&orig_node->last_ttvn);
 		batadv_orig_node_free_ref(orig_node);
 	}
 
@@ -833,7 +833,7 @@ int batadv_recv_unicast_packet(struct sk_buff *skb,
 	struct batadv_priv *bat_priv = netdev_priv(recv_if->soft_iface);
 	struct batadv_unicast_packet *unicast_packet;
 	struct batadv_unicast_4addr_packet *unicast_4addr_packet;
-	uint8_t *orig_addr;
+	u8 *orig_addr;
 	struct batadv_orig_node *orig_node = NULL;
 	int check, hdr_size = sizeof(*unicast_packet);
 	bool is4addr;
@@ -904,7 +904,7 @@ int batadv_recv_unicast_tvlv(struct sk_buff *skb,
 	struct batadv_priv *bat_priv = netdev_priv(recv_if->soft_iface);
 	struct batadv_unicast_tvlv_packet *unicast_tvlv_packet;
 	unsigned char *tvlv_buff;
-	uint16_t tvlv_buff_len;
+	u16 tvlv_buff_len;
 	int hdr_size = sizeof(*unicast_tvlv_packet);
 	int ret = NET_RX_DROP;
 
@@ -1007,8 +1007,8 @@ int batadv_recv_bcast_packet(struct sk_buff *skb,
 	struct ethhdr *ethhdr;
 	int hdr_size = sizeof(*bcast_packet);
 	int ret = NET_RX_DROP;
-	int32_t seq_diff;
-	uint32_t seqno;
+	s32 seq_diff;
+	u32 seqno;
 
 	/* drop packet if it has not necessary minimum size */
 	if (unlikely(!pskb_may_pull(skb, hdr_size)))
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 6bc29d3..3c185a1f 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -55,7 +55,7 @@ struct batadv_neigh_node *
 batadv_find_router(struct batadv_priv *bat_priv,
 		   struct batadv_orig_node *orig_node,
 		   struct batadv_hard_iface *recv_if);
-int batadv_window_protected(struct batadv_priv *bat_priv, int32_t seq_num_diff,
+int batadv_window_protected(struct batadv_priv *bat_priv, s32 seq_num_diff,
 			    unsigned long *last_reset);
 
 #endif /* _NET_BATMAN_ADV_ROUTING_H_ */
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 191076e..f664324 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -54,7 +54,7 @@ static void batadv_send_outstanding_bcast_packet(struct work_struct *work);
  */
 int batadv_send_skb_packet(struct sk_buff *skb,
 			   struct batadv_hard_iface *hard_iface,
-			   const uint8_t *dst_addr)
+			   const u8 *dst_addr)
 {
 	struct batadv_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	struct ethhdr *ethhdr;
@@ -172,7 +172,7 @@ batadv_send_skb_push_fill_unicast(struct sk_buff *skb, int hdr_size,
 				  struct batadv_orig_node *orig_node)
 {
 	struct batadv_unicast_packet *unicast_packet;
-	uint8_t ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
+	u8 ttvn = (u8)atomic_read(&orig_node->last_ttvn);
 
 	if (batadv_skb_head_push(skb, hdr_size) < 0)
 		return false;
@@ -343,12 +343,12 @@ out:
  */
 int batadv_send_skb_via_tt_generic(struct batadv_priv *bat_priv,
 				   struct sk_buff *skb, int packet_type,
-				   int packet_subtype, uint8_t *dst_hint,
+				   int packet_subtype, u8 *dst_hint,
 				   unsigned short vid)
 {
 	struct ethhdr *ethhdr = (struct ethhdr *)skb->data;
 	struct batadv_orig_node *orig_node;
-	uint8_t *src, *dst;
+	u8 *src, *dst;
 
 	src = ethhdr->h_source;
 	dst = ethhdr->h_dest;
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 0536835..33ef6fc 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -33,7 +33,7 @@ struct work_struct;
 
 int batadv_send_skb_packet(struct sk_buff *skb,
 			   struct batadv_hard_iface *hard_iface,
-			   const uint8_t *dst_addr);
+			   const u8 *dst_addr);
 int batadv_send_skb_to_orig(struct sk_buff *skb,
 			    struct batadv_orig_node *orig_node,
 			    struct batadv_hard_iface *recv_if);
@@ -56,7 +56,7 @@ int batadv_send_skb_unicast(struct batadv_priv *bat_priv,
 			    unsigned short vid);
 int batadv_send_skb_via_tt_generic(struct batadv_priv *bat_priv,
 				   struct sk_buff *skb, int packet_type,
-				   int packet_subtype, uint8_t *dst_hint,
+				   int packet_subtype, u8 *dst_hint,
 				   unsigned short vid);
 int batadv_send_skb_via_gw(struct batadv_priv *bat_priv, struct sk_buff *skb,
 			   unsigned short vid);
@@ -75,7 +75,7 @@ int batadv_send_skb_via_gw(struct batadv_priv *bat_priv, struct sk_buff *skb,
  * Returns NET_XMIT_DROP in case of error or NET_XMIT_SUCCESS otherwise.
  */
 static inline int batadv_send_skb_via_tt(struct batadv_priv *bat_priv,
-					 struct sk_buff *skb, uint8_t *dst_hint,
+					 struct sk_buff *skb, u8 *dst_hint,
 					 unsigned short vid)
 {
 	return batadv_send_skb_via_tt_generic(bat_priv, skb, BATADV_UNICAST, 0,
@@ -100,7 +100,7 @@ static inline int batadv_send_skb_via_tt(struct batadv_priv *bat_priv,
 static inline int batadv_send_skb_via_tt_4addr(struct batadv_priv *bat_priv,
 					       struct sk_buff *skb,
 					       int packet_subtype,
-					       uint8_t *dst_hint,
+					       u8 *dst_hint,
 					       unsigned short vid)
 {
 	return batadv_send_skb_via_tt_generic(bat_priv, skb,
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 49d3d3a..d5c5ad9 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -131,7 +131,7 @@ static int batadv_interface_set_mac_addr(struct net_device *dev, void *p)
 	struct batadv_priv *bat_priv = netdev_priv(dev);
 	struct batadv_softif_vlan *vlan;
 	struct sockaddr *addr = p;
-	uint8_t old_addr[ETH_ALEN];
+	u8 old_addr[ETH_ALEN];
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
@@ -186,19 +186,19 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	struct batadv_hard_iface *primary_if = NULL;
 	struct batadv_bcast_packet *bcast_packet;
 	__be16 ethertype = htons(ETH_P_BATMAN);
-	static const uint8_t stp_addr[ETH_ALEN] = {0x01, 0x80, 0xC2, 0x00,
-						   0x00, 0x00};
-	static const uint8_t ectp_addr[ETH_ALEN] = {0xCF, 0x00, 0x00, 0x00,
-						    0x00, 0x00};
+	static const u8 stp_addr[ETH_ALEN] = {0x01, 0x80, 0xC2, 0x00,
+					      0x00, 0x00};
+	static const u8 ectp_addr[ETH_ALEN] = {0xCF, 0x00, 0x00, 0x00,
+					       0x00, 0x00};
 	enum batadv_dhcp_recipient dhcp_rcp = BATADV_DHCP_NO;
-	uint8_t *dst_hint = NULL, chaddr[ETH_ALEN];
+	u8 *dst_hint = NULL, chaddr[ETH_ALEN];
 	struct vlan_ethhdr *vhdr;
 	unsigned int header_len = 0;
 	int data_len = skb->len, ret;
 	unsigned long brd_delay = 1;
 	bool do_bcast = false, client_added;
 	unsigned short vid;
-	uint32_t seqno;
+	u32 seqno;
 	int gw_mode;
 	enum batadv_forw_mode forw_mode;
 	struct batadv_orig_node *mcast_single_orig = NULL;
@@ -750,9 +750,9 @@ static void batadv_softif_destroy_finish(struct work_struct *work)
 static int batadv_softif_init_late(struct net_device *dev)
 {
 	struct batadv_priv *bat_priv;
-	uint32_t random_seqno;
+	u32 random_seqno;
 	int ret;
-	size_t cnt_len = sizeof(uint64_t) * BATADV_CNT_NUM;
+	size_t cnt_len = sizeof(u64) * BATADV_CNT_NUM;
 
 	batadv_set_lockdep_class(dev);
 
@@ -763,7 +763,7 @@ static int batadv_softif_init_late(struct net_device *dev)
 	/* batadv_interface_stats() needs to be available as soon as
 	 * register_netdevice() has been called
 	 */
-	bat_priv->bat_counters = __alloc_percpu(cnt_len, __alignof__(uint64_t));
+	bat_priv->bat_counters = __alloc_percpu(cnt_len, __alignof__(u64));
 	if (!bat_priv->bat_counters)
 		return -ENOMEM;
 
@@ -1117,8 +1117,7 @@ static const struct {
 #endif
 };
 
-static void batadv_get_strings(struct net_device *dev, uint32_t stringset,
-			       uint8_t *data)
+static void batadv_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 {
 	if (stringset == ETH_SS_STATS)
 		memcpy(data, batadv_counters_strings,
@@ -1126,8 +1125,7 @@ static void batadv_get_strings(struct net_device *dev, uint32_t stringset,
 }
 
 static void batadv_get_ethtool_stats(struct net_device *dev,
-				     struct ethtool_stats *stats,
-				     uint64_t *data)
+				     struct ethtool_stats *stats, u64 *data)
 {
 	struct batadv_priv *bat_priv = netdev_priv(dev);
 	int i;
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index d6a312a..9de3c88 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -457,7 +457,7 @@ static ssize_t batadv_show_gw_bwidth(struct kobject *kobj,
 				     struct attribute *attr, char *buff)
 {
 	struct batadv_priv *bat_priv = batadv_kobj_to_batpriv(kobj);
-	uint32_t down, up;
+	u32 down, up;
 
 	down = atomic_read(&bat_priv->gw.bandwidth_down);
 	up = atomic_read(&bat_priv->gw.bandwidth_up);
@@ -512,7 +512,7 @@ static ssize_t batadv_store_isolation_mark(struct kobject *kobj,
 {
 	struct net_device *net_dev = batadv_kobj_to_netdev(kobj);
 	struct batadv_priv *bat_priv = netdev_priv(net_dev);
-	uint32_t mark, mask;
+	u32 mark, mask;
 	char *mask_ptr;
 
 	/* parse the mask if it has been specified, otherwise assume the mask is
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index c1eb7b7..f908988 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -56,7 +56,7 @@
 static struct lock_class_key batadv_tt_local_hash_lock_class_key;
 static struct lock_class_key batadv_tt_global_hash_lock_class_key;
 
-static void batadv_send_roam_adv(struct batadv_priv *bat_priv, uint8_t *client,
+static void batadv_send_roam_adv(struct batadv_priv *bat_priv, u8 *client,
 				 unsigned short vid,
 				 struct batadv_orig_node *orig_node);
 static void batadv_tt_purge(struct work_struct *work);
@@ -85,10 +85,10 @@ static int batadv_compare_tt(const struct hlist_node *node, const void *data2)
  * Returns the hash index where the object represented by 'data' should be
  * stored at.
  */
-static inline uint32_t batadv_choose_tt(const void *data, uint32_t size)
+static inline u32 batadv_choose_tt(const void *data, u32 size)
 {
 	struct batadv_tt_common_entry *tt;
-	uint32_t hash = 0;
+	u32 hash = 0;
 
 	tt = (struct batadv_tt_common_entry *)data;
 	hash = jhash(&tt->addr, ETH_ALEN, hash);
@@ -107,12 +107,12 @@ static inline uint32_t batadv_choose_tt(const void *data, uint32_t size)
  * found, NULL otherwise.
  */
 static struct batadv_tt_common_entry *
-batadv_tt_hash_find(struct batadv_hashtable *hash, const uint8_t *addr,
+batadv_tt_hash_find(struct batadv_hashtable *hash, const u8 *addr,
 		    unsigned short vid)
 {
 	struct hlist_head *head;
 	struct batadv_tt_common_entry to_search, *tt, *tt_tmp = NULL;
-	uint32_t index;
+	u32 index;
 
 	if (!hash)
 		return NULL;
@@ -152,7 +152,7 @@ batadv_tt_hash_find(struct batadv_hashtable *hash, const uint8_t *addr,
  * found, NULL otherwise.
  */
 static struct batadv_tt_local_entry *
-batadv_tt_local_hash_find(struct batadv_priv *bat_priv, const uint8_t *addr,
+batadv_tt_local_hash_find(struct batadv_priv *bat_priv, const u8 *addr,
 			  unsigned short vid)
 {
 	struct batadv_tt_common_entry *tt_common_entry;
@@ -177,7 +177,7 @@ batadv_tt_local_hash_find(struct batadv_priv *bat_priv, const uint8_t *addr,
  * is found, NULL otherwise.
  */
 static struct batadv_tt_global_entry *
-batadv_tt_global_hash_find(struct batadv_priv *bat_priv, const uint8_t *addr,
+batadv_tt_global_hash_find(struct batadv_priv *bat_priv, const u8 *addr,
 			   unsigned short vid)
 {
 	struct batadv_tt_common_entry *tt_common_entry;
@@ -223,7 +223,7 @@ batadv_tt_global_entry_free_ref(struct batadv_tt_global_entry *tt_global_entry)
  * (excluding ourself).
  */
 int batadv_tt_global_hash_count(struct batadv_priv *bat_priv,
-				const uint8_t *addr, unsigned short vid)
+				const u8 *addr, unsigned short vid)
 {
 	struct batadv_tt_global_entry *tt_global_entry;
 	int count;
@@ -364,11 +364,11 @@ batadv_tt_orig_list_entry_free_ref(struct batadv_tt_orig_list_entry *orig_entry)
  */
 static void batadv_tt_local_event(struct batadv_priv *bat_priv,
 				  struct batadv_tt_local_entry *tt_local_entry,
-				  uint8_t event_flags)
+				  u8 event_flags)
 {
 	struct batadv_tt_change_node *tt_change_node, *entry, *safe;
 	struct batadv_tt_common_entry *common = &tt_local_entry->common;
-	uint8_t flags = common->flags | event_flags;
+	u8 flags = common->flags | event_flags;
 	bool event_removed = false;
 	bool del_op_requested, del_op_entry;
 
@@ -448,7 +448,7 @@ static int batadv_tt_len(int changes_num)
  *
  * Returns the number of entries.
  */
-static uint16_t batadv_tt_entries(uint16_t tt_len)
+static u16 batadv_tt_entries(u16 tt_len)
 {
 	return tt_len / batadv_tt_len(1);
 }
@@ -462,7 +462,7 @@ static uint16_t batadv_tt_entries(uint16_t tt_len)
  */
 static int batadv_tt_local_table_transmit_size(struct batadv_priv *bat_priv)
 {
-	uint16_t num_vlan = 0, tt_local_entries = 0;
+	u16 num_vlan = 0, tt_local_entries = 0;
 	struct batadv_softif_vlan *vlan;
 	int hdr_size;
 
@@ -525,8 +525,8 @@ static void batadv_tt_global_free(struct batadv_priv *bat_priv,
  *
  * Returns true if the client was successfully added, false otherwise.
  */
-bool batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
-			 unsigned short vid, int ifindex, uint32_t mark)
+bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
+			 unsigned short vid, int ifindex, u32 mark)
 {
 	struct batadv_priv *bat_priv = netdev_priv(soft_iface);
 	struct batadv_tt_local_entry *tt_local;
@@ -537,8 +537,8 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	struct batadv_tt_orig_list_entry *orig_entry;
 	int hash_added, table_size, packet_size_max;
 	bool ret = false, roamed_back = false;
-	uint8_t remote_flags;
-	uint32_t match_mark;
+	u8 remote_flags;
+	u32 match_mark;
 
 	if (ifindex != BATADV_NULL_IFINDEX)
 		in_dev = dev_get_by_index(&init_net, ifindex);
@@ -605,7 +605,7 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Creating new local tt entry: %pM (vid: %d, ttvn: %d)\n",
 		   addr, BATADV_PRINT_VID(vid),
-		   (uint8_t)atomic_read(&bat_priv->tt.vn));
+		   (u8)atomic_read(&bat_priv->tt.vn));
 
 	ether_addr_copy(tt_local->common.addr, addr);
 	/* The local entry has to be marked as NEW to avoid to send it in
@@ -724,16 +724,16 @@ out:
  *
  * Return the size of the allocated buffer or 0 in case of failure.
  */
-static uint16_t
+static u16
 batadv_tt_prepare_tvlv_global_data(struct batadv_orig_node *orig_node,
 				   struct batadv_tvlv_tt_data **tt_data,
 				   struct batadv_tvlv_tt_change **tt_change,
-				   int32_t *tt_len)
+				   s32 *tt_len)
 {
-	uint16_t num_vlan = 0, num_entries = 0, change_offset, tvlv_len;
+	u16 num_vlan = 0, num_entries = 0, change_offset, tvlv_len;
 	struct batadv_tvlv_tt_vlan_data *tt_vlan;
 	struct batadv_orig_node_vlan *vlan;
-	uint8_t *tt_change_ptr;
+	u8 *tt_change_ptr;
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(vlan, &orig_node->vlan_list, list) {
@@ -769,7 +769,7 @@ batadv_tt_prepare_tvlv_global_data(struct batadv_orig_node *orig_node,
 		tt_vlan++;
 	}
 
-	tt_change_ptr = (uint8_t *)*tt_data + change_offset;
+	tt_change_ptr = (u8 *)*tt_data + change_offset;
 	*tt_change = (struct batadv_tvlv_tt_change *)tt_change_ptr;
 
 out:
@@ -795,16 +795,16 @@ out:
  *
  * Return the size of the allocated buffer or 0 in case of failure.
  */
-static uint16_t
+static u16
 batadv_tt_prepare_tvlv_local_data(struct batadv_priv *bat_priv,
 				  struct batadv_tvlv_tt_data **tt_data,
 				  struct batadv_tvlv_tt_change **tt_change,
-				  int32_t *tt_len)
+				  s32 *tt_len)
 {
 	struct batadv_tvlv_tt_vlan_data *tt_vlan;
 	struct batadv_softif_vlan *vlan;
-	uint16_t num_vlan = 0, num_entries = 0, tvlv_len;
-	uint8_t *tt_change_ptr;
+	u16 num_vlan = 0, num_entries = 0, tvlv_len;
+	u8 *tt_change_ptr;
 	int change_offset;
 
 	rcu_read_lock();
@@ -841,7 +841,7 @@ batadv_tt_prepare_tvlv_local_data(struct batadv_priv *bat_priv,
 		tt_vlan++;
 	}
 
-	tt_change_ptr = (uint8_t *)*tt_data + change_offset;
+	tt_change_ptr = (u8 *)*tt_data + change_offset;
 	*tt_change = (struct batadv_tvlv_tt_change *)tt_change_ptr;
 
 out:
@@ -861,7 +861,7 @@ static void batadv_tt_tvlv_container_update(struct batadv_priv *bat_priv)
 	struct batadv_tvlv_tt_change *tt_change;
 	int tt_diff_len, tt_change_len = 0;
 	int tt_diff_entries_num = 0, tt_diff_entries_count = 0;
-	uint16_t tvlv_len;
+	u16 tvlv_len;
 
 	tt_diff_entries_num = atomic_read(&bat_priv->tt.local_changes);
 	tt_diff_len = batadv_tt_len(tt_diff_entries_num);
@@ -935,12 +935,12 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 	struct batadv_softif_vlan *vlan;
 	struct hlist_head *head;
 	unsigned short vid;
-	uint32_t i;
+	u32 i;
 	int last_seen_secs;
 	int last_seen_msecs;
 	unsigned long last_seen_jiffies;
 	bool no_purge;
-	uint16_t np_flag = BATADV_TT_CLIENT_NOPURGE;
+	u16 np_flag = BATADV_TT_CLIENT_NOPURGE;
 
 	primary_if = batadv_seq_print_text_primary_if_get(seq);
 	if (!primary_if)
@@ -948,7 +948,7 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 
 	seq_printf(seq,
 		   "Locally retrieved addresses (from %s) announced via TT (TTVN: %u):\n",
-		   net_dev->name, (uint8_t)atomic_read(&bat_priv->tt.vn));
+		   net_dev->name, (u8)atomic_read(&bat_priv->tt.vn));
 	seq_printf(seq, "       %-13s  %s %-8s %-9s (%-10s)\n", "Client", "VID",
 		   "Flags", "Last seen", "CRC");
 
@@ -1008,7 +1008,7 @@ out:
 static void
 batadv_tt_local_set_pending(struct batadv_priv *bat_priv,
 			    struct batadv_tt_local_entry *tt_local_entry,
-			    uint16_t flags, const char *message)
+			    u16 flags, const char *message)
 {
 	batadv_tt_local_event(bat_priv, tt_local_entry, flags);
 
@@ -1034,12 +1034,12 @@ batadv_tt_local_set_pending(struct batadv_priv *bat_priv,
  *
  * Returns the flags assigned to the local entry before being deleted
  */
-uint16_t batadv_tt_local_remove(struct batadv_priv *bat_priv,
-				const uint8_t *addr, unsigned short vid,
-				const char *message, bool roaming)
+u16 batadv_tt_local_remove(struct batadv_priv *bat_priv, const u8 *addr,
+			   unsigned short vid, const char *message,
+			   bool roaming)
 {
 	struct batadv_tt_local_entry *tt_local_entry;
-	uint16_t flags, curr_flags = BATADV_NO_FLAGS;
+	u16 flags, curr_flags = BATADV_NO_FLAGS;
 	struct batadv_softif_vlan *vlan;
 	void *tt_entry_exists;
 
@@ -1142,7 +1142,7 @@ static void batadv_tt_local_purge(struct batadv_priv *bat_priv,
 	struct batadv_hashtable *hash = bat_priv->tt.local_hash;
 	struct hlist_head *head;
 	spinlock_t *list_lock; /* protects write access to the hash lists */
-	uint32_t i;
+	u32 i;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -1163,7 +1163,7 @@ static void batadv_tt_local_table_free(struct batadv_priv *bat_priv)
 	struct batadv_softif_vlan *vlan;
 	struct hlist_node *node_tmp;
 	struct hlist_head *head;
-	uint32_t i;
+	u32 i;
 
 	if (!bat_priv->tt.local_hash)
 		return;
@@ -1338,15 +1338,14 @@ out:
 static bool batadv_tt_global_add(struct batadv_priv *bat_priv,
 				 struct batadv_orig_node *orig_node,
 				 const unsigned char *tt_addr,
-				 unsigned short vid, uint16_t flags,
-				 uint8_t ttvn)
+				 unsigned short vid, u16 flags, u8 ttvn)
 {
 	struct batadv_tt_global_entry *tt_global_entry;
 	struct batadv_tt_local_entry *tt_local_entry;
 	bool ret = false;
 	int hash_added;
 	struct batadv_tt_common_entry *common;
-	uint16_t local_flags;
+	u16 local_flags;
 
 	/* ignore global entries from backbone nodes */
 	if (batadv_bla_is_backbone_gw_orig(bat_priv, orig_node->orig, vid))
@@ -1543,8 +1542,8 @@ batadv_tt_global_print_entry(struct batadv_priv *bat_priv,
 	struct batadv_tt_common_entry *tt_common_entry;
 	struct batadv_orig_node_vlan *vlan;
 	struct hlist_head *head;
-	uint8_t last_ttvn;
-	uint16_t flags;
+	u8 last_ttvn;
+	u16 flags;
 
 	tt_common_entry = &tt_global_entry->common;
 	flags = tt_common_entry->flags;
@@ -1618,7 +1617,7 @@ int batadv_tt_global_seq_print_text(struct seq_file *seq, void *offset)
 	struct batadv_tt_global_entry *tt_global;
 	struct batadv_hard_iface *primary_if;
 	struct hlist_head *head;
-	uint32_t i;
+	u32 i;
 
 	primary_if = batadv_seq_print_text_primary_if_get(seq);
 	if (!primary_if)
@@ -1838,12 +1837,12 @@ out:
  */
 void batadv_tt_global_del_orig(struct batadv_priv *bat_priv,
 			       struct batadv_orig_node *orig_node,
-			       int32_t match_vid,
+			       s32 match_vid,
 			       const char *message)
 {
 	struct batadv_tt_global_entry *tt_global;
 	struct batadv_tt_common_entry *tt_common_entry;
-	uint32_t i;
+	u32 i;
 	struct batadv_hashtable *hash = bat_priv->tt.global_hash;
 	struct hlist_node *safe;
 	struct hlist_head *head;
@@ -1914,7 +1913,7 @@ static void batadv_tt_global_purge(struct batadv_priv *bat_priv)
 	struct hlist_head *head;
 	struct hlist_node *node_tmp;
 	spinlock_t *list_lock; /* protects write access to the hash lists */
-	uint32_t i;
+	u32 i;
 	char *msg = NULL;
 	struct batadv_tt_common_entry *tt_common;
 	struct batadv_tt_global_entry *tt_global;
@@ -1955,7 +1954,7 @@ static void batadv_tt_global_table_free(struct batadv_priv *bat_priv)
 	struct batadv_tt_global_entry *tt_global;
 	struct hlist_node *node_tmp;
 	struct hlist_head *head;
-	uint32_t i;
+	u32 i;
 
 	if (!bat_priv->tt.global_hash)
 		return;
@@ -2016,8 +2015,8 @@ _batadv_is_ap_isolated(struct batadv_tt_local_entry *tt_local_entry,
  * If the two clients are AP isolated the function returns NULL.
  */
 struct batadv_orig_node *batadv_transtable_search(struct batadv_priv *bat_priv,
-						  const uint8_t *src,
-						  const uint8_t *addr,
+						  const u8 *src,
+						  const u8 *addr,
 						  unsigned short vid)
 {
 	struct batadv_tt_local_entry *tt_local_entry = NULL;
@@ -2085,16 +2084,16 @@ out:
  *
  * Returns the checksum of the global table of a given originator.
  */
-static uint32_t batadv_tt_global_crc(struct batadv_priv *bat_priv,
-				     struct batadv_orig_node *orig_node,
-				     unsigned short vid)
+static u32 batadv_tt_global_crc(struct batadv_priv *bat_priv,
+				struct batadv_orig_node *orig_node,
+				unsigned short vid)
 {
 	struct batadv_hashtable *hash = bat_priv->tt.global_hash;
 	struct batadv_tt_common_entry *tt_common;
 	struct batadv_tt_global_entry *tt_global;
 	struct hlist_head *head;
-	uint32_t i, crc_tmp, crc = 0;
-	uint8_t flags;
+	u32 i, crc_tmp, crc = 0;
+	u8 flags;
 	__be16 tmp_vid;
 
 	for (i = 0; i < hash->size; i++) {
@@ -2162,14 +2161,14 @@ static uint32_t batadv_tt_global_crc(struct batadv_priv *bat_priv,
  *
  * Returns the checksum of the local table
  */
-static uint32_t batadv_tt_local_crc(struct batadv_priv *bat_priv,
-				    unsigned short vid)
+static u32 batadv_tt_local_crc(struct batadv_priv *bat_priv,
+			       unsigned short vid)
 {
 	struct batadv_hashtable *hash = bat_priv->tt.local_hash;
 	struct batadv_tt_common_entry *tt_common;
 	struct hlist_head *head;
-	uint32_t i, crc_tmp, crc = 0;
-	uint8_t flags;
+	u32 i, crc_tmp, crc = 0;
+	u8 flags;
 	__be16 tmp_vid;
 
 	for (i = 0; i < hash->size; i++) {
@@ -2226,7 +2225,7 @@ static void batadv_tt_req_list_free(struct batadv_priv *bat_priv)
 static void batadv_tt_save_orig_buffer(struct batadv_priv *bat_priv,
 				       struct batadv_orig_node *orig_node,
 				       const void *tt_buff,
-				       uint16_t tt_buff_len)
+				       u16 tt_buff_len)
 {
 	/* Replace the old buffer only if I received something in the
 	 * last OGM (the OGM could carry no changes)
@@ -2335,15 +2334,15 @@ static int batadv_tt_global_valid(const void *entry_ptr,
  */
 static void batadv_tt_tvlv_generate(struct batadv_priv *bat_priv,
 				    struct batadv_hashtable *hash,
-				    void *tvlv_buff, uint16_t tt_len,
+				    void *tvlv_buff, u16 tt_len,
 				    int (*valid_cb)(const void *, const void *),
 				    void *cb_data)
 {
 	struct batadv_tt_common_entry *tt_common_entry;
 	struct batadv_tvlv_tt_change *tt_change;
 	struct hlist_head *head;
-	uint16_t tt_tot, tt_num_entries = 0;
-	uint32_t i;
+	u16 tt_tot, tt_num_entries = 0;
+	u32 i;
 
 	tt_tot = batadv_tt_entries(tt_len);
 	tt_change = (struct batadv_tvlv_tt_change *)tvlv_buff;
@@ -2385,11 +2384,11 @@ static void batadv_tt_tvlv_generate(struct batadv_priv *bat_priv,
  */
 static bool batadv_tt_global_check_crc(struct batadv_orig_node *orig_node,
 				       struct batadv_tvlv_tt_vlan_data *tt_vlan,
-				       uint16_t num_vlan)
+				       u16 num_vlan)
 {
 	struct batadv_tvlv_tt_vlan_data *tt_vlan_tmp;
 	struct batadv_orig_node_vlan *vlan;
-	uint32_t crc;
+	u32 crc;
 	int i;
 
 	/* check if each received CRC matches the locally stored one */
@@ -2444,7 +2443,7 @@ static void batadv_tt_global_update_crc(struct batadv_priv *bat_priv,
 					struct batadv_orig_node *orig_node)
 {
 	struct batadv_orig_node_vlan *vlan;
-	uint32_t crc;
+	u32 crc;
 
 	/* recompute the global CRC for each VLAN */
 	rcu_read_lock();
@@ -2474,9 +2473,9 @@ static void batadv_tt_global_update_crc(struct batadv_priv *bat_priv,
  */
 static int batadv_send_tt_request(struct batadv_priv *bat_priv,
 				  struct batadv_orig_node *dst_orig_node,
-				  uint8_t ttvn,
+				  u8 ttvn,
 				  struct batadv_tvlv_tt_vlan_data *tt_vlan,
-				  uint16_t num_vlan, bool full_table)
+				  u16 num_vlan, bool full_table)
 {
 	struct batadv_tvlv_tt_data *tvlv_tt_data = NULL;
 	struct batadv_tt_req_node *tt_req_node = NULL;
@@ -2555,7 +2554,7 @@ out:
  */
 static bool batadv_send_other_tt_response(struct batadv_priv *bat_priv,
 					  struct batadv_tvlv_tt_data *tt_data,
-					  uint8_t *req_src, uint8_t *req_dst)
+					  u8 *req_src, u8 *req_dst)
 {
 	struct batadv_orig_node *req_dst_orig_node;
 	struct batadv_orig_node *res_dst_orig_node = NULL;
@@ -2563,9 +2562,9 @@ static bool batadv_send_other_tt_response(struct batadv_priv *bat_priv,
 	struct batadv_tvlv_tt_data *tvlv_tt_data = NULL;
 	struct batadv_tvlv_tt_vlan_data *tt_vlan;
 	bool ret = false, full_table;
-	uint8_t orig_ttvn, req_ttvn;
-	uint16_t tvlv_len;
-	int32_t tt_len;
+	u8 orig_ttvn, req_ttvn;
+	u16 tvlv_len;
+	s32 tt_len;
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Received TT_REQUEST from %pM for ttvn: %u (%pM) [%c]\n",
@@ -2581,7 +2580,7 @@ static bool batadv_send_other_tt_response(struct batadv_priv *bat_priv,
 	if (!res_dst_orig_node)
 		goto out;
 
-	orig_ttvn = (uint8_t)atomic_read(&req_dst_orig_node->last_ttvn);
+	orig_ttvn = (u8)atomic_read(&req_dst_orig_node->last_ttvn);
 	req_ttvn = tt_data->ttvn;
 
 	tt_vlan = (struct batadv_tvlv_tt_vlan_data *)(tt_data + 1);
@@ -2687,16 +2686,16 @@ out:
  */
 static bool batadv_send_my_tt_response(struct batadv_priv *bat_priv,
 				       struct batadv_tvlv_tt_data *tt_data,
-				       uint8_t *req_src)
+				       u8 *req_src)
 {
 	struct batadv_tvlv_tt_data *tvlv_tt_data = NULL;
 	struct batadv_hard_iface *primary_if = NULL;
 	struct batadv_tvlv_tt_change *tt_change;
 	struct batadv_orig_node *orig_node;
-	uint8_t my_ttvn, req_ttvn;
-	uint16_t tvlv_len;
+	u8 my_ttvn, req_ttvn;
+	u16 tvlv_len;
 	bool full_table;
-	int32_t tt_len;
+	s32 tt_len;
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Received TT_REQUEST from %pM for ttvn: %u (me) [%c]\n",
@@ -2705,7 +2704,7 @@ static bool batadv_send_my_tt_response(struct batadv_priv *bat_priv,
 
 	spin_lock_bh(&bat_priv->tt.commit_lock);
 
-	my_ttvn = (uint8_t)atomic_read(&bat_priv->tt.vn);
+	my_ttvn = (u8)atomic_read(&bat_priv->tt.vn);
 	req_ttvn = tt_data->ttvn;
 
 	orig_node = batadv_orig_hash_find(bat_priv, req_src);
@@ -2744,7 +2743,7 @@ static bool batadv_send_my_tt_response(struct batadv_priv *bat_priv,
 		       bat_priv->tt.last_changeset_len);
 		spin_unlock_bh(&bat_priv->tt.last_changeset_lock);
 	} else {
-		req_ttvn = (uint8_t)atomic_read(&bat_priv->tt.vn);
+		req_ttvn = (u8)atomic_read(&bat_priv->tt.vn);
 
 		/* allocate the tvlv, put the tt_data and all the tt_vlan_data
 		 * in the initial part
@@ -2805,7 +2804,7 @@ out:
  */
 static bool batadv_send_tt_response(struct batadv_priv *bat_priv,
 				    struct batadv_tvlv_tt_data *tt_data,
-				    uint8_t *req_src, uint8_t *req_dst)
+				    u8 *req_src, u8 *req_dst)
 {
 	if (batadv_is_my_mac(bat_priv, req_dst))
 		return batadv_send_my_tt_response(bat_priv, tt_data, req_src);
@@ -2816,7 +2815,7 @@ static bool batadv_send_tt_response(struct batadv_priv *bat_priv,
 static void _batadv_tt_update_changes(struct batadv_priv *bat_priv,
 				      struct batadv_orig_node *orig_node,
 				      struct batadv_tvlv_tt_change *tt_change,
-				      uint16_t tt_num_changes, uint8_t ttvn)
+				      u16 tt_num_changes, u8 ttvn)
 {
 	int i;
 	int roams;
@@ -2848,8 +2847,8 @@ static void _batadv_tt_update_changes(struct batadv_priv *bat_priv,
 
 static void batadv_tt_fill_gtable(struct batadv_priv *bat_priv,
 				  struct batadv_tvlv_tt_change *tt_change,
-				  uint8_t ttvn, uint8_t *resp_src,
-				  uint16_t num_entries)
+				  u8 ttvn, u8 *resp_src,
+				  u16 num_entries)
 {
 	struct batadv_orig_node *orig_node;
 
@@ -2879,7 +2878,7 @@ out:
 
 static void batadv_tt_update_changes(struct batadv_priv *bat_priv,
 				     struct batadv_orig_node *orig_node,
-				     uint16_t tt_num_changes, uint8_t ttvn,
+				     u16 tt_num_changes, u8 ttvn,
 				     struct batadv_tvlv_tt_change *tt_change)
 {
 	_batadv_tt_update_changes(bat_priv, orig_node, tt_change,
@@ -2898,7 +2897,7 @@ static void batadv_tt_update_changes(struct batadv_priv *bat_priv,
  *
  * Returns true if the client is served by this node, false otherwise.
  */
-bool batadv_is_my_client(struct batadv_priv *bat_priv, const uint8_t *addr,
+bool batadv_is_my_client(struct batadv_priv *bat_priv, const u8 *addr,
 			 unsigned short vid)
 {
 	struct batadv_tt_local_entry *tt_local_entry;
@@ -2929,13 +2928,13 @@ out:
  */
 static void batadv_handle_tt_response(struct batadv_priv *bat_priv,
 				      struct batadv_tvlv_tt_data *tt_data,
-				      uint8_t *resp_src, uint16_t num_entries)
+				      u8 *resp_src, u16 num_entries)
 {
 	struct batadv_tt_req_node *node, *safe;
 	struct batadv_orig_node *orig_node = NULL;
 	struct batadv_tvlv_tt_change *tt_change;
-	uint8_t *tvlv_ptr = (uint8_t *)tt_data;
-	uint16_t change_offset;
+	u8 *tvlv_ptr = (u8 *)tt_data;
+	u16 change_offset;
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Received TT_RESPONSE from %pM for ttvn %d t_size: %d [%c]\n",
@@ -3018,8 +3017,7 @@ static void batadv_tt_roam_purge(struct batadv_priv *bat_priv)
  *
  * returns true if the ROAMING_ADV can be sent, false otherwise
  */
-static bool batadv_tt_check_roam_count(struct batadv_priv *bat_priv,
-				       uint8_t *client)
+static bool batadv_tt_check_roam_count(struct batadv_priv *bat_priv, u8 *client)
 {
 	struct batadv_tt_roam_node *tt_roam_node;
 	bool ret = false;
@@ -3074,7 +3072,7 @@ unlock:
  * for this particular roamed client has to be forwarded to the sender of the
  * roaming message.
  */
-static void batadv_send_roam_adv(struct batadv_priv *bat_priv, uint8_t *client,
+static void batadv_send_roam_adv(struct batadv_priv *bat_priv, u8 *client,
 				 unsigned short vid,
 				 struct batadv_orig_node *orig_node)
 {
@@ -3152,14 +3150,14 @@ void batadv_tt_free(struct batadv_priv *bat_priv)
  * @enable: whether to set or unset the flag
  * @count: whether to increase the TT size by the number of changed entries
  */
-static void batadv_tt_local_set_flags(struct batadv_priv *bat_priv,
-				      uint16_t flags, bool enable, bool count)
+static void batadv_tt_local_set_flags(struct batadv_priv *bat_priv, u16 flags,
+				      bool enable, bool count)
 {
 	struct batadv_hashtable *hash = bat_priv->tt.local_hash;
 	struct batadv_tt_common_entry *tt_common_entry;
-	uint16_t changed_num = 0;
+	u16 changed_num = 0;
 	struct hlist_head *head;
-	uint32_t i;
+	u32 i;
 
 	if (!hash)
 		return;
@@ -3201,7 +3199,7 @@ static void batadv_tt_local_purge_pending_clients(struct batadv_priv *bat_priv)
 	struct hlist_node *node_tmp;
 	struct hlist_head *head;
 	spinlock_t *list_lock; /* protects write access to the hash lists */
-	uint32_t i;
+	u32 i;
 
 	if (!hash)
 		return;
@@ -3267,7 +3265,7 @@ static void batadv_tt_local_commit_changes_nolock(struct batadv_priv *bat_priv)
 	atomic_inc(&bat_priv->tt.vn);
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Local changes committed, updating to ttvn %u\n",
-		   (uint8_t)atomic_read(&bat_priv->tt.vn));
+		   (u8)atomic_read(&bat_priv->tt.vn));
 
 	/* reset the sending counter */
 	atomic_set(&bat_priv->tt.ogm_append_cnt, BATADV_TT_OGM_APPEND_MAX);
@@ -3286,8 +3284,8 @@ void batadv_tt_local_commit_changes(struct batadv_priv *bat_priv)
 	spin_unlock_bh(&bat_priv->tt.commit_lock);
 }
 
-bool batadv_is_ap_isolated(struct batadv_priv *bat_priv, uint8_t *src,
-			   uint8_t *dst, unsigned short vid)
+bool batadv_is_ap_isolated(struct batadv_priv *bat_priv, u8 *src, u8 *dst,
+			   unsigned short vid)
 {
 	struct batadv_tt_local_entry *tt_local_entry = NULL;
 	struct batadv_tt_global_entry *tt_global_entry = NULL;
@@ -3335,11 +3333,11 @@ out:
  */
 static void batadv_tt_update_orig(struct batadv_priv *bat_priv,
 				  struct batadv_orig_node *orig_node,
-				  const void *tt_buff, uint16_t tt_num_vlan,
+				  const void *tt_buff, u16 tt_num_vlan,
 				  struct batadv_tvlv_tt_change *tt_change,
-				  uint16_t tt_num_changes, uint8_t ttvn)
+				  u16 tt_num_changes, u8 ttvn)
 {
-	uint8_t orig_ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
+	u8 orig_ttvn = (u8)atomic_read(&orig_node->last_ttvn);
 	struct batadv_tvlv_tt_vlan_data *tt_vlan;
 	bool full_table = true;
 	bool has_tt_init;
@@ -3418,7 +3416,7 @@ request_table:
  * deleted later by a DEL or because of timeout
  */
 bool batadv_tt_global_client_is_roaming(struct batadv_priv *bat_priv,
-					uint8_t *addr, unsigned short vid)
+					u8 *addr, unsigned short vid)
 {
 	struct batadv_tt_global_entry *tt_global_entry;
 	bool ret = false;
@@ -3444,7 +3442,7 @@ out:
  * to keep the latter consistent with the node TTVN
  */
 bool batadv_tt_local_client_is_roaming(struct batadv_priv *bat_priv,
-				       uint8_t *addr, unsigned short vid)
+				       u8 *addr, unsigned short vid)
 {
 	struct batadv_tt_local_entry *tt_local_entry;
 	bool ret = false;
@@ -3530,13 +3528,13 @@ void batadv_tt_local_resize_to_mtu(struct net_device *soft_iface)
  */
 static void batadv_tt_tvlv_ogm_handler_v1(struct batadv_priv *bat_priv,
 					  struct batadv_orig_node *orig,
-					  uint8_t flags, void *tvlv_value,
-					  uint16_t tvlv_value_len)
+					  u8 flags, void *tvlv_value,
+					  u16 tvlv_value_len)
 {
 	struct batadv_tvlv_tt_vlan_data *tt_vlan;
 	struct batadv_tvlv_tt_change *tt_change;
 	struct batadv_tvlv_tt_data *tt_data;
-	uint16_t num_entries, num_vlan;
+	u16 num_entries, num_vlan;
 
 	if (tvlv_value_len < sizeof(*tt_data))
 		return;
@@ -3572,12 +3570,12 @@ static void batadv_tt_tvlv_ogm_handler_v1(struct batadv_priv *bat_priv,
  * otherwise.
  */
 static int batadv_tt_tvlv_unicast_handler_v1(struct batadv_priv *bat_priv,
-					     uint8_t *src, uint8_t *dst,
+					     u8 *src, u8 *dst,
 					     void *tvlv_value,
-					     uint16_t tvlv_value_len)
+					     u16 tvlv_value_len)
 {
 	struct batadv_tvlv_tt_data *tt_data;
-	uint16_t tt_vlan_len, tt_num_entries;
+	u16 tt_vlan_len, tt_num_entries;
 	char tt_flag;
 	bool ret;
 
@@ -3653,9 +3651,9 @@ static int batadv_tt_tvlv_unicast_handler_v1(struct batadv_priv *bat_priv,
  * otherwise.
  */
 static int batadv_roam_tvlv_unicast_handler_v1(struct batadv_priv *bat_priv,
-					       uint8_t *src, uint8_t *dst,
+					       u8 *src, u8 *dst,
 					       void *tvlv_value,
-					       uint16_t tvlv_value_len)
+					       u16 tvlv_value_len)
 {
 	struct batadv_tvlv_roam_adv *roaming_adv;
 	struct batadv_orig_node *orig_node = NULL;
@@ -3737,7 +3735,7 @@ int batadv_tt_init(struct batadv_priv *bat_priv)
  * otherwise
  */
 bool batadv_tt_global_is_isolated(struct batadv_priv *bat_priv,
-				  const uint8_t *addr, unsigned short vid)
+				  const u8 *addr, unsigned short vid)
 {
 	struct batadv_tt_global_entry *tt;
 	bool ret;
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 6acc25d..9b82d5d 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -28,38 +28,37 @@ struct net_device;
 struct seq_file;
 
 int batadv_tt_init(struct batadv_priv *bat_priv);
-bool batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
-			 unsigned short vid, int ifindex, uint32_t mark);
-uint16_t batadv_tt_local_remove(struct batadv_priv *bat_priv,
-				const uint8_t *addr, unsigned short vid,
-				const char *message, bool roaming);
+bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
+			 unsigned short vid, int ifindex, u32 mark);
+u16 batadv_tt_local_remove(struct batadv_priv *bat_priv,
+			   const u8 *addr, unsigned short vid,
+			   const char *message, bool roaming);
 int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset);
 int batadv_tt_global_seq_print_text(struct seq_file *seq, void *offset);
 void batadv_tt_global_del_orig(struct batadv_priv *bat_priv,
 			       struct batadv_orig_node *orig_node,
-			       int32_t match_vid, const char *message);
+			       s32 match_vid, const char *message);
 int batadv_tt_global_hash_count(struct batadv_priv *bat_priv,
-				const uint8_t *addr, unsigned short vid);
+				const u8 *addr, unsigned short vid);
 struct batadv_orig_node *batadv_transtable_search(struct batadv_priv *bat_priv,
-						  const uint8_t *src,
-						  const uint8_t *addr,
+						  const u8 *src, const u8 *addr,
 						  unsigned short vid);
 void batadv_tt_free(struct batadv_priv *bat_priv);
-bool batadv_is_my_client(struct batadv_priv *bat_priv, const uint8_t *addr,
+bool batadv_is_my_client(struct batadv_priv *bat_priv, const u8 *addr,
 			 unsigned short vid);
-bool batadv_is_ap_isolated(struct batadv_priv *bat_priv, uint8_t *src,
-			   uint8_t *dst, unsigned short vid);
+bool batadv_is_ap_isolated(struct batadv_priv *bat_priv, u8 *src, u8 *dst,
+			   unsigned short vid);
 void batadv_tt_local_commit_changes(struct batadv_priv *bat_priv);
 bool batadv_tt_global_client_is_roaming(struct batadv_priv *bat_priv,
-					uint8_t *addr, unsigned short vid);
+					u8 *addr, unsigned short vid);
 bool batadv_tt_local_client_is_roaming(struct batadv_priv *bat_priv,
-				       uint8_t *addr, unsigned short vid);
+				       u8 *addr, unsigned short vid);
 void batadv_tt_local_resize_to_mtu(struct net_device *soft_iface);
 bool batadv_tt_add_temporary_global_entry(struct batadv_priv *bat_priv,
 					  struct batadv_orig_node *orig_node,
 					  const unsigned char *addr,
 					  unsigned short vid);
 bool batadv_tt_global_is_isolated(struct batadv_priv *bat_priv,
-				  const uint8_t *addr, unsigned short vid);
+				  const u8 *addr, unsigned short vid);
 
 #endif /* _NET_BATMAN_ADV_TRANSLATION_TABLE_H_ */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 55610a8..f2ebe33 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -44,7 +44,7 @@ struct seq_file;
  *
  * *Please be careful: batadv_dat_addr_t must be UNSIGNED*
  */
-#define batadv_dat_addr_t uint16_t
+#define batadv_dat_addr_t u16
 
 #endif /* CONFIG_BATMAN_ADV_DAT */
 
@@ -103,10 +103,10 @@ struct batadv_hard_iface_bat_iv {
  */
 struct batadv_hard_iface {
 	struct list_head list;
-	int16_t if_num;
+	s16 if_num;
 	char if_status;
 	struct net_device *net_dev;
-	uint8_t num_bcasts;
+	u8 num_bcasts;
 	struct kobject *hardif_obj;
 	atomic_t refcount;
 	struct packet_type batman_adv_ptype;
@@ -132,8 +132,8 @@ struct batadv_orig_ifinfo {
 	struct hlist_node list;
 	struct batadv_hard_iface *if_outgoing;
 	struct batadv_neigh_node __rcu *router; /* rcu protected pointer */
-	uint32_t last_real_seqno;
-	uint8_t last_ttl;
+	u32 last_real_seqno;
+	u8 last_ttl;
 	unsigned long batman_seqno_reset;
 	atomic_t refcount;
 	struct rcu_head rcu;
@@ -152,9 +152,9 @@ struct batadv_frag_table_entry {
 	struct hlist_head head;
 	spinlock_t lock; /* protects head */
 	unsigned long timestamp;
-	uint16_t seqno;
-	uint16_t size;
-	uint16_t total_size;
+	u16 seqno;
+	u16 size;
+	u16 total_size;
 };
 
 /**
@@ -166,7 +166,7 @@ struct batadv_frag_table_entry {
 struct batadv_frag_list_entry {
 	struct hlist_node list;
 	struct sk_buff *skb;
-	uint8_t no;
+	u8 no;
 };
 
 /**
@@ -175,7 +175,7 @@ struct batadv_frag_list_entry {
  * @num_entries: number of TT entries for this VLAN
  */
 struct batadv_vlan_tt {
-	uint32_t crc;
+	u32 crc;
 	atomic_t num_entries;
 };
 
@@ -206,7 +206,7 @@ struct batadv_orig_node_vlan {
  */
 struct batadv_orig_bat_iv {
 	unsigned long *bcast_own;
-	uint8_t *bcast_own_sum;
+	u8 *bcast_own_sum;
 	/* ogm_cnt_lock protects: bcast_own, bcast_own_sum,
 	 * neigh_node->bat_iv.real_bits & neigh_node->bat_iv.real_packet_count
 	 */
@@ -260,7 +260,7 @@ struct batadv_orig_bat_iv {
  * @bat_iv: B.A.T.M.A.N. IV private structure
  */
 struct batadv_orig_node {
-	uint8_t orig[ETH_ALEN];
+	u8 orig[ETH_ALEN];
 	struct hlist_head ifinfo_list;
 	struct batadv_orig_ifinfo *last_bonding_candidate;
 #ifdef CONFIG_BATMAN_ADV_DAT
@@ -271,7 +271,7 @@ struct batadv_orig_node {
 #ifdef CONFIG_BATMAN_ADV_MCAST
 	/* synchronizes mcast tvlv specific orig changes */
 	spinlock_t mcast_handler_lock;
-	uint8_t mcast_flags;
+	u8 mcast_flags;
 	struct hlist_node mcast_want_all_unsnoopables_node;
 	struct hlist_node mcast_want_all_ipv4_node;
 	struct hlist_node mcast_want_all_ipv6_node;
@@ -280,12 +280,12 @@ struct batadv_orig_node {
 	unsigned long capa_initialized;
 	atomic_t last_ttvn;
 	unsigned char *tt_buff;
-	int16_t tt_buff_len;
+	s16 tt_buff_len;
 	spinlock_t tt_buff_lock; /* protects tt_buff & tt_buff_len */
 	/* prevents from changing the table while reading it */
 	spinlock_t tt_lock;
 	DECLARE_BITMAP(bcast_bits, BATADV_TQ_LOCAL_WINDOW_SIZE);
-	uint32_t last_bcast_seqno;
+	u32 last_bcast_seqno;
 	struct hlist_head neigh_list;
 	/* neigh_list_lock protects: neigh_list and router */
 	spinlock_t neigh_list_lock;
@@ -335,8 +335,8 @@ enum batadv_orig_capabilities {
 struct batadv_gw_node {
 	struct hlist_node list;
 	struct batadv_orig_node *orig_node;
-	uint32_t bandwidth_down;
-	uint32_t bandwidth_up;
+	u32 bandwidth_down;
+	u32 bandwidth_up;
 	unsigned long deleted;
 	atomic_t refcount;
 	struct rcu_head rcu;
@@ -358,7 +358,7 @@ struct batadv_gw_node {
 struct batadv_neigh_node {
 	struct hlist_node list;
 	struct batadv_orig_node *orig_node;
-	uint8_t addr[ETH_ALEN];
+	u8 addr[ETH_ALEN];
 	struct hlist_head ifinfo_list;
 	spinlock_t ifinfo_lock;	/* protects ifinfo_list and its members */
 	struct batadv_hard_iface *if_incoming;
@@ -378,11 +378,11 @@ struct batadv_neigh_node {
  * @real_packet_count: counted result of real_bits
  */
 struct batadv_neigh_ifinfo_bat_iv {
-	uint8_t tq_recv[BATADV_TQ_GLOBAL_WINDOW_SIZE];
-	uint8_t tq_index;
-	uint8_t tq_avg;
+	u8 tq_recv[BATADV_TQ_GLOBAL_WINDOW_SIZE];
+	u8 tq_index;
+	u8 tq_avg;
 	DECLARE_BITMAP(real_bits, BATADV_TQ_LOCAL_WINDOW_SIZE);
-	uint8_t real_packet_count;
+	u8 real_packet_count;
 };
 
 /**
@@ -398,7 +398,7 @@ struct batadv_neigh_ifinfo {
 	struct hlist_node list;
 	struct batadv_hard_iface *if_outgoing;
 	struct batadv_neigh_ifinfo_bat_iv bat_iv;
-	uint8_t last_ttl;
+	u8 last_ttl;
 	atomic_t refcount;
 	struct rcu_head rcu;
 };
@@ -411,7 +411,7 @@ struct batadv_neigh_ifinfo {
  */
 #ifdef CONFIG_BATMAN_ADV_BLA
 struct batadv_bcast_duplist_entry {
-	uint8_t orig[ETH_ALEN];
+	u8 orig[ETH_ALEN];
 	__be32 crc;
 	unsigned long entrytime;
 };
@@ -543,7 +543,7 @@ struct batadv_priv_tt {
 	spinlock_t req_list_lock; /* protects req_list */
 	spinlock_t roam_list_lock; /* protects roam_list */
 	unsigned char *last_changeset;
-	int16_t last_changeset_len;
+	s16 last_changeset_len;
 	/* protects last_changeset & last_changeset_len */
 	spinlock_t last_changeset_lock;
 	/* prevents from executing a commit while reading the table */
@@ -663,7 +663,7 @@ struct batadv_priv_mcast {
 	struct hlist_head want_all_unsnoopables_list;
 	struct hlist_head want_all_ipv4_list;
 	struct hlist_head want_all_ipv6_list;
-	uint8_t flags;
+	u8 flags;
 	bool enabled;
 	atomic_t num_disabled;
 	atomic_t num_want_all_unsnoopables;
@@ -781,7 +781,7 @@ struct batadv_priv {
 	atomic_t mesh_state;
 	struct net_device *soft_iface;
 	struct net_device_stats stats;
-	uint64_t __percpu *bat_counters; /* Per cpu counters */
+	u64 __percpu *bat_counters; /* Per cpu counters */
 	atomic_t aggregated_ogms;
 	atomic_t bonding;
 	atomic_t fragmentation;
@@ -803,8 +803,8 @@ struct batadv_priv {
 #ifdef CONFIG_BATMAN_ADV_DEBUG
 	atomic_t log_level;
 #endif
-	uint32_t isolation_mark;
-	uint32_t isolation_mark_mask;
+	u32 isolation_mark;
+	u32 isolation_mark_mask;
 	atomic_t bcast_seqno;
 	atomic_t bcast_queue_left;
 	atomic_t batman_queue_left;
@@ -870,7 +870,7 @@ struct batadv_socket_client {
 struct batadv_socket_packet {
 	struct list_head list;
 	size_t icmp_len;
-	uint8_t icmp_packet[BATADV_ICMP_MAX_PACKET_SIZE];
+	u8 icmp_packet[BATADV_ICMP_MAX_PACKET_SIZE];
 };
 
 /**
@@ -891,14 +891,14 @@ struct batadv_socket_packet {
  */
 #ifdef CONFIG_BATMAN_ADV_BLA
 struct batadv_bla_backbone_gw {
-	uint8_t orig[ETH_ALEN];
+	u8 orig[ETH_ALEN];
 	unsigned short vid;
 	struct hlist_node hash_entry;
 	struct batadv_priv *bat_priv;
 	unsigned long lasttime;
 	atomic_t wait_periods;
 	atomic_t request_sent;
-	uint16_t crc;
+	u16 crc;
 	atomic_t refcount;
 	struct rcu_head rcu;
 };
@@ -914,7 +914,7 @@ struct batadv_bla_backbone_gw {
  * @rcu: struct used for freeing in an RCU-safe manner
  */
 struct batadv_bla_claim {
-	uint8_t addr[ETH_ALEN];
+	u8 addr[ETH_ALEN];
 	unsigned short vid;
 	struct batadv_bla_backbone_gw *backbone_gw;
 	unsigned long lasttime;
@@ -936,10 +936,10 @@ struct batadv_bla_claim {
  * @rcu: struct used for freeing in an RCU-safe manner
  */
 struct batadv_tt_common_entry {
-	uint8_t addr[ETH_ALEN];
+	u8 addr[ETH_ALEN];
 	unsigned short vid;
 	struct hlist_node hash_entry;
-	uint16_t flags;
+	u16 flags;
 	unsigned long added_at;
 	atomic_t refcount;
 	struct rcu_head rcu;
@@ -981,7 +981,7 @@ struct batadv_tt_global_entry {
  */
 struct batadv_tt_orig_list_entry {
 	struct batadv_orig_node *orig_node;
-	uint8_t ttvn;
+	u8 ttvn;
 	struct hlist_node list;
 	atomic_t refcount;
 	struct rcu_head rcu;
@@ -1004,7 +1004,7 @@ struct batadv_tt_change_node {
  * @list: list node for batadv_priv_tt::req_list
  */
 struct batadv_tt_req_node {
-	uint8_t addr[ETH_ALEN];
+	u8 addr[ETH_ALEN];
 	unsigned long issued_at;
 	struct list_head list;
 };
@@ -1018,7 +1018,7 @@ struct batadv_tt_req_node {
  * @list: list node for batadv_priv_tt::roam_list
  */
 struct batadv_tt_roam_node {
-	uint8_t addr[ETH_ALEN];
+	u8 addr[ETH_ALEN];
 	atomic_t counter;
 	unsigned long first_time;
 	struct list_head list;
@@ -1035,7 +1035,7 @@ struct batadv_tt_roam_node {
  */
 struct batadv_nc_node {
 	struct list_head list;
-	uint8_t addr[ETH_ALEN];
+	u8 addr[ETH_ALEN];
 	atomic_t refcount;
 	struct rcu_head rcu;
 	struct batadv_orig_node *orig_node;
@@ -1059,8 +1059,8 @@ struct batadv_nc_path {
 	atomic_t refcount;
 	struct list_head packet_list;
 	spinlock_t packet_list_lock; /* Protects packet_list */
-	uint8_t next_hop[ETH_ALEN];
-	uint8_t prev_hop[ETH_ALEN];
+	u8 next_hop[ETH_ALEN];
+	u8 prev_hop[ETH_ALEN];
 	unsigned long last_valid;
 };
 
@@ -1112,11 +1112,11 @@ struct batadv_skb_cb {
 struct batadv_forw_packet {
 	struct hlist_node list;
 	unsigned long send_time;
-	uint8_t own;
+	u8 own;
 	struct sk_buff *skb;
-	uint16_t packet_len;
-	uint32_t direct_link_flags;
-	uint8_t num_packets;
+	u16 packet_len;
+	u32 direct_link_flags;
+	u8 num_packets;
 	struct delayed_work delayed_work;
 	struct batadv_hard_iface *if_incoming;
 	struct batadv_hard_iface *if_outgoing;
@@ -1191,7 +1191,7 @@ struct batadv_algo_ops {
  */
 struct batadv_dat_entry {
 	__be32 ip;
-	uint8_t mac_addr[ETH_ALEN];
+	u8 mac_addr[ETH_ALEN];
 	unsigned short vid;
 	unsigned long last_update;
 	struct hlist_node hash_entry;
@@ -1253,14 +1253,13 @@ struct batadv_tvlv_handler {
 	struct hlist_node list;
 	void (*ogm_handler)(struct batadv_priv *bat_priv,
 			    struct batadv_orig_node *orig,
-			    uint8_t flags,
-			    void *tvlv_value, uint16_t tvlv_value_len);
+			    u8 flags, void *tvlv_value, u16 tvlv_value_len);
 	int (*unicast_handler)(struct batadv_priv *bat_priv,
-			       uint8_t *src, uint8_t *dst,
-			       void *tvlv_value, uint16_t tvlv_value_len);
-	uint8_t type;
-	uint8_t version;
-	uint8_t flags;
+			       u8 *src, u8 *dst,
+			       void *tvlv_value, u16 tvlv_value_len);
+	u8 type;
+	u8 version;
+	u8 flags;
 	atomic_t refcount;
 	struct rcu_head rcu;
 };
-- 
2.5.0
