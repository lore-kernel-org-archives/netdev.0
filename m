From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 04/20] batman-adv: Prefix bitarray non-static
	functions with batadv_
Date: Thu, 21 Jun 2012 18:57:40 +0200
Message-ID: <1340297876-29923-5-git-send-email-ordex@autistici.org>
References: <1340297876-29923-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1340297876-29923-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
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

batman-adv can be compiled as part of the kernel instead of an module. In that
case the linker will see all non-static symbols of batman-adv and all other
non-static symbols of the kernel. This could lead to symbol collisions. A
prefix for the batman-adv symbols that defines their private namespace avoids
such a problem.

Reported-by: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/bat_iv_ogm.c |    6 +++---
 net/batman-adv/bitarray.c   |    8 ++++----
 net/batman-adv/bitarray.h   |    4 ++--
 net/batman-adv/routing.c    |    4 ++--
 4 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index b445739..53bce95 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -903,9 +903,9 @@ static int bat_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 			set_mark = 0;
 
 		/* if the window moved, set the update flag. */
-		need_update |= bit_get_packet(bat_priv,
-					      tmp_neigh_node->real_bits,
-					      seq_diff, set_mark);
+		need_update |= batadv_bit_get_packet(bat_priv,
+						     tmp_neigh_node->real_bits,
+						     seq_diff, set_mark);
 
 		tmp_neigh_node->real_packet_count =
 			bitmap_weight(tmp_neigh_node->real_bits,
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index 07ae6e1..99ed991 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -25,7 +25,7 @@
 #include <linux/bitops.h>
 
 /* shift the packet array by n places. */
-static void bat_bitmap_shift_left(unsigned long *seq_bits, int32_t n)
+static void batadv_bitmap_shift_left(unsigned long *seq_bits, int32_t n)
 {
 	if (n <= 0 || n >= TQ_LOCAL_WINDOW_SIZE)
 		return;
@@ -40,8 +40,8 @@ static void bat_bitmap_shift_left(unsigned long *seq_bits, int32_t n)
  *  1 if the window was moved (either new or very old)
  *  0 if the window was not moved/shifted.
  */
-int bit_get_packet(void *priv, unsigned long *seq_bits,
-		    int32_t seq_num_diff, int set_mark)
+int batadv_bit_get_packet(void *priv, unsigned long *seq_bits,
+			  int32_t seq_num_diff, int set_mark)
 {
 	struct bat_priv *bat_priv = priv;
 
@@ -58,7 +58,7 @@ int bit_get_packet(void *priv, unsigned long *seq_bits,
 	 * set the mark if required */
 
 	if ((seq_num_diff > 0) && (seq_num_diff < TQ_LOCAL_WINDOW_SIZE)) {
-		bat_bitmap_shift_left(seq_bits, seq_num_diff);
+		batadv_bitmap_shift_left(seq_bits, seq_num_diff);
 
 		if (set_mark)
 			bat_set_bit(seq_bits, 0);
diff --git a/net/batman-adv/bitarray.h b/net/batman-adv/bitarray.h
index 1835c15..e855ddd3 100644
--- a/net/batman-adv/bitarray.h
+++ b/net/batman-adv/bitarray.h
@@ -48,7 +48,7 @@ static inline void bat_set_bit(unsigned long *seq_bits, int32_t n)
 
 /* receive and process one packet, returns 1 if received seq_num is considered
  * new, 0 if old  */
-int bit_get_packet(void *priv, unsigned long *seq_bits,
-		   int32_t seq_num_diff, int set_mark);
+int batadv_bit_get_packet(void *priv, unsigned long *seq_bits,
+			  int32_t seq_num_diff, int set_mark);
 
 #endif /* _NET_BATMAN_ADV_BITARRAY_H_ */
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 9cfd23c..e573c32 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -54,7 +54,7 @@ void slide_own_bcast_window(struct hard_iface *hard_iface)
 			word_index = hard_iface->if_num * NUM_WORDS;
 			word = &(orig_node->bcast_own[word_index]);
 
-			bit_get_packet(bat_priv, word, 1, 0);
+			batadv_bit_get_packet(bat_priv, word, 1, 0);
 			orig_node->bcast_own_sum[hard_iface->if_num] =
 				bitmap_weight(word, TQ_LOCAL_WINDOW_SIZE);
 			spin_unlock_bh(&orig_node->ogm_cnt_lock);
@@ -1083,7 +1083,7 @@ int recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 
 	/* mark broadcast in flood history, update window position
 	 * if required. */
-	if (bit_get_packet(bat_priv, orig_node->bcast_bits, seq_diff, 1))
+	if (batadv_bit_get_packet(bat_priv, orig_node->bcast_bits, seq_diff, 1))
 		orig_node->last_bcast_seqno = ntohl(bcast_packet->seqno);
 
 	spin_unlock_bh(&orig_node->bcast_seqno_lock);
-- 
1.7.9.4
