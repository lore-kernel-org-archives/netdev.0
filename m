From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 15/17] batman-adv: Use bool as return type for boolean functions
Date: Wed, 11 May 2016 03:30:03 +0800
Message-ID: <1462908605-27412-16-git-send-email-a@unstable.cc>
References: <1462908605-27412-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:25400 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752442AbcEJTjj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 15:39:39 -0400
In-Reply-To: <1462908605-27412-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

It is easier to understand that the returned value of a specific function
doesn't have to be 0 when the functions was successful when the actual
return type is bool. This is especially true when all surrounding functions
with return type int use negative values to return the error code.

Reported-by: Nicholas Krause <xerofoify@gmail.com>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bat_iv_ogm.c            |  23 ++---
 net/batman-adv/bitarray.c              |  16 +--
 net/batman-adv/bitarray.h              |  15 +--
 net/batman-adv/bridge_loop_avoidance.c | 175 +++++++++++++++++----------------
 net/batman-adv/bridge_loop_avoidance.h |  43 ++++----
 net/batman-adv/debugfs.c               |   2 +-
 net/batman-adv/distributed-arp-table.c |   6 +-
 net/batman-adv/hard-interface.c        |  15 ++-
 net/batman-adv/hash.h                  |   6 +-
 net/batman-adv/main.h                  |   2 +-
 net/batman-adv/network-coding.c        |  12 +--
 net/batman-adv/originator.c            |   4 +-
 net/batman-adv/originator.h            |   2 +-
 net/batman-adv/routing.c               |  37 +++----
 net/batman-adv/routing.h               |   6 +-
 net/batman-adv/soft-interface.c        |   6 +-
 net/batman-adv/soft-interface.h        |   3 +-
 net/batman-adv/translation-table.c     |  31 +++---
 18 files changed, 205 insertions(+), 199 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index eb3435de54b5..7f98a9d39883 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1168,13 +1168,13 @@ out:
  * @if_incoming: interface where the packet was received
  * @if_outgoing: interface for which the retransmission should be considered
  *
- * Return: 1 if the link can be considered bidirectional, 0 otherwise
+ * Return: true if the link can be considered bidirectional, false otherwise
  */
-static int batadv_iv_ogm_calc_tq(struct batadv_orig_node *orig_node,
-				 struct batadv_orig_node *orig_neigh_node,
-				 struct batadv_ogm_packet *batadv_ogm_packet,
-				 struct batadv_hard_iface *if_incoming,
-				 struct batadv_hard_iface *if_outgoing)
+static bool batadv_iv_ogm_calc_tq(struct batadv_orig_node *orig_node,
+				  struct batadv_orig_node *orig_neigh_node,
+				  struct batadv_ogm_packet *batadv_ogm_packet,
+				  struct batadv_hard_iface *if_incoming,
+				  struct batadv_hard_iface *if_outgoing)
 {
 	struct batadv_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct batadv_neigh_node *neigh_node = NULL, *tmp_neigh_node;
@@ -1182,9 +1182,10 @@ static int batadv_iv_ogm_calc_tq(struct batadv_orig_node *orig_node,
 	u8 total_count;
 	u8 orig_eq_count, neigh_rq_count, neigh_rq_inv, tq_own;
 	unsigned int neigh_rq_inv_cube, neigh_rq_max_cube;
-	int tq_asym_penalty, inv_asym_penalty, if_num, ret = 0;
+	int tq_asym_penalty, inv_asym_penalty, if_num;
 	unsigned int combined_tq;
 	int tq_iface_penalty;
+	bool ret = false;
 
 	/* find corresponding one hop neighbor */
 	rcu_read_lock();
@@ -1296,7 +1297,7 @@ static int batadv_iv_ogm_calc_tq(struct batadv_orig_node *orig_node,
 	 * consider it bidirectional
 	 */
 	if (batadv_ogm_packet->tq >= BATADV_TQ_TOTAL_BIDRECT_LIMIT)
-		ret = 1;
+		ret = true;
 
 out:
 	if (neigh_node)
@@ -1325,9 +1326,9 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 	struct batadv_orig_ifinfo *orig_ifinfo = NULL;
 	struct batadv_neigh_node *neigh_node;
 	struct batadv_neigh_ifinfo *neigh_ifinfo;
-	int is_dup;
+	bool is_dup;
 	s32 seq_diff;
-	int need_update = 0;
+	bool need_update = false;
 	int set_mark;
 	enum batadv_dup_status ret = BATADV_NO_DUP;
 	u32 seqno = ntohl(batadv_ogm_packet->seqno);
@@ -1437,7 +1438,7 @@ batadv_iv_ogm_process_per_outif(const struct sk_buff *skb, int ogm_offset,
 	struct sk_buff *skb_priv;
 	struct ethhdr *ethhdr;
 	u8 *prev_sender;
-	int is_bidirect;
+	bool is_bidirect;
 
 	/* create a private copy of the skb, as some functions change tq value
 	 * and/or flags.
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index b56bb000a0ab..a0c7913837a5 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -38,11 +38,11 @@ static void batadv_bitmap_shift_left(unsigned long *seq_bits, s32 n)
  *  the last sequence number
  * @set_mark: whether this packet should be marked in seq_bits
  *
- * Return: 1 if the window was moved (either new or very old),
- *  0 if the window was not moved/shifted.
+ * Return: true if the window was moved (either new or very old),
+ *  false if the window was not moved/shifted.
  */
-int batadv_bit_get_packet(void *priv, unsigned long *seq_bits, s32 seq_num_diff,
-			  int set_mark)
+bool batadv_bit_get_packet(void *priv, unsigned long *seq_bits,
+			   s32 seq_num_diff, int set_mark)
 {
 	struct batadv_priv *bat_priv = priv;
 
@@ -52,7 +52,7 @@ int batadv_bit_get_packet(void *priv, unsigned long *seq_bits, s32 seq_num_diff,
 	if (seq_num_diff <= 0 && seq_num_diff > -BATADV_TQ_LOCAL_WINDOW_SIZE) {
 		if (set_mark)
 			batadv_set_bit(seq_bits, -seq_num_diff);
-		return 0;
+		return false;
 	}
 
 	/* sequence number is slightly newer, so we shift the window and
@@ -63,7 +63,7 @@ int batadv_bit_get_packet(void *priv, unsigned long *seq_bits, s32 seq_num_diff,
 
 		if (set_mark)
 			batadv_set_bit(seq_bits, 0);
-		return 1;
+		return true;
 	}
 
 	/* sequence number is much newer, probably missed a lot of packets */
@@ -75,7 +75,7 @@ int batadv_bit_get_packet(void *priv, unsigned long *seq_bits, s32 seq_num_diff,
 		bitmap_zero(seq_bits, BATADV_TQ_LOCAL_WINDOW_SIZE);
 		if (set_mark)
 			batadv_set_bit(seq_bits, 0);
-		return 1;
+		return true;
 	}
 
 	/* received a much older packet. The other host either restarted
@@ -94,5 +94,5 @@ int batadv_bit_get_packet(void *priv, unsigned long *seq_bits, s32 seq_num_diff,
 	if (set_mark)
 		batadv_set_bit(seq_bits, 0);
 
-	return 1;
+	return true;
 }
diff --git a/net/batman-adv/bitarray.h b/net/batman-adv/bitarray.h
index 3e41bb80eb81..0e6e9d09078c 100644
--- a/net/batman-adv/bitarray.h
+++ b/net/batman-adv/bitarray.h
@@ -22,6 +22,7 @@
 
 #include <linux/bitops.h>
 #include <linux/compiler.h>
+#include <linux/stddef.h>
 #include <linux/types.h>
 
 /**
@@ -31,17 +32,17 @@
  * @last_seqno: latest sequence number in seq_bits
  * @curr_seqno: sequence number to test for
  *
- * Return: 1 if the corresponding bit in the given seq_bits indicates true
- * and curr_seqno is within range of last_seqno. Otherwise returns 0.
+ * Return: true if the corresponding bit in the given seq_bits indicates true
+ * and curr_seqno is within range of last_seqno. Otherwise returns false.
  */
-static inline int batadv_test_bit(const unsigned long *seq_bits,
-				  u32 last_seqno, u32 curr_seqno)
+static inline bool batadv_test_bit(const unsigned long *seq_bits,
+				   u32 last_seqno, u32 curr_seqno)
 {
 	s32 diff;
 
 	diff = last_seqno - curr_seqno;
 	if (diff < 0 || diff >= BATADV_TQ_LOCAL_WINDOW_SIZE)
-		return 0;
+		return false;
 	return test_bit(diff, seq_bits) != 0;
 }
 
@@ -55,7 +56,7 @@ static inline void batadv_set_bit(unsigned long *seq_bits, s32 n)
 	set_bit(n, seq_bits); /* turn the position on */
 }
 
-int batadv_bit_get_packet(void *priv, unsigned long *seq_bits, s32 seq_num_diff,
-			  int set_mark);
+bool batadv_bit_get_packet(void *priv, unsigned long *seq_bits,
+			   s32 seq_num_diff, int set_mark);
 
 #endif /* _NET_BATMAN_ADV_BITARRAY_H_ */
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 5064ae5e9b34..748a9ead7ce5 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -101,10 +101,10 @@ static inline u32 batadv_choose_backbone_gw(const void *data, u32 size)
  * @node: list node of the first entry to compare
  * @data2: pointer to the second backbone gateway
  *
- * Return: 1 if the backbones have the same data, 0 otherwise
+ * Return: true if the backbones have the same data, false otherwise
  */
-static int batadv_compare_backbone_gw(const struct hlist_node *node,
-				      const void *data2)
+static bool batadv_compare_backbone_gw(const struct hlist_node *node,
+				       const void *data2)
 {
 	const void *data1 = container_of(node, struct batadv_bla_backbone_gw,
 					 hash_entry);
@@ -112,12 +112,12 @@ static int batadv_compare_backbone_gw(const struct hlist_node *node,
 	const struct batadv_bla_backbone_gw *gw2 = data2;
 
 	if (!batadv_compare_eth(gw1->orig, gw2->orig))
-		return 0;
+		return false;
 
 	if (gw1->vid != gw2->vid)
-		return 0;
+		return false;
 
-	return 1;
+	return true;
 }
 
 /**
@@ -125,10 +125,10 @@ static int batadv_compare_backbone_gw(const struct hlist_node *node,
  * @node: list node of the first entry to compare
  * @data2: pointer to the second claims
  *
- * Return: 1 if the claim have the same data, 0 otherwise
+ * Return: true if the claim have the same data, 0 otherwise
  */
-static int batadv_compare_claim(const struct hlist_node *node,
-				const void *data2)
+static bool batadv_compare_claim(const struct hlist_node *node,
+				 const void *data2)
 {
 	const void *data1 = container_of(node, struct batadv_bla_claim,
 					 hash_entry);
@@ -136,12 +136,12 @@ static int batadv_compare_claim(const struct hlist_node *node,
 	const struct batadv_bla_claim *cl2 = data2;
 
 	if (!batadv_compare_eth(cl1->addr, cl2->addr))
-		return 0;
+		return false;
 
 	if (cl1->vid != cl2->vid)
-		return 0;
+		return false;
 
-	return 1;
+	return true;
 }
 
 /**
@@ -775,22 +775,22 @@ static void batadv_bla_del_claim(struct batadv_priv *bat_priv,
  * @backbone_addr: originator address of the sender (Ethernet source MAC)
  * @vid: the VLAN ID of the frame
  *
- * Return: 1 if handled
+ * Return: true if handled
  */
-static int batadv_handle_announce(struct batadv_priv *bat_priv, u8 *an_addr,
-				  u8 *backbone_addr, unsigned short vid)
+static bool batadv_handle_announce(struct batadv_priv *bat_priv, u8 *an_addr,
+				   u8 *backbone_addr, unsigned short vid)
 {
 	struct batadv_bla_backbone_gw *backbone_gw;
 	u16 backbone_crc, crc;
 
 	if (memcmp(an_addr, batadv_announce_mac, 4) != 0)
-		return 0;
+		return false;
 
 	backbone_gw = batadv_bla_get_backbone_gw(bat_priv, backbone_addr, vid,
 						 false);
 
 	if (unlikely(!backbone_gw))
-		return 1;
+		return true;
 
 	/* handle as ANNOUNCE frame */
 	backbone_gw->lasttime = jiffies;
@@ -823,7 +823,7 @@ static int batadv_handle_announce(struct batadv_priv *bat_priv, u8 *an_addr,
 	}
 
 	batadv_backbone_gw_put(backbone_gw);
-	return 1;
+	return true;
 }
 
 /**
@@ -834,29 +834,29 @@ static int batadv_handle_announce(struct batadv_priv *bat_priv, u8 *an_addr,
  * @ethhdr: ethernet header of a packet
  * @vid: the VLAN ID of the frame
  *
- * Return: 1 if handled
+ * Return: true if handled
  */
-static int batadv_handle_request(struct batadv_priv *bat_priv,
-				 struct batadv_hard_iface *primary_if,
-				 u8 *backbone_addr, struct ethhdr *ethhdr,
-				 unsigned short vid)
+static bool batadv_handle_request(struct batadv_priv *bat_priv,
+				  struct batadv_hard_iface *primary_if,
+				  u8 *backbone_addr, struct ethhdr *ethhdr,
+				  unsigned short vid)
 {
 	/* check for REQUEST frame */
 	if (!batadv_compare_eth(backbone_addr, ethhdr->h_dest))
-		return 0;
+		return false;
 
 	/* sanity check, this should not happen on a normal switch,
 	 * we ignore it in this case.
 	 */
 	if (!batadv_compare_eth(ethhdr->h_dest, primary_if->net_dev->dev_addr))
-		return 1;
+		return true;
 
 	batadv_dbg(BATADV_DBG_BLA, bat_priv,
 		   "handle_request(): REQUEST vid %d (sent by %pM)...\n",
 		   BATADV_PRINT_VID(vid), ethhdr->h_source);
 
 	batadv_bla_answer_request(bat_priv, primary_if, vid);
-	return 1;
+	return true;
 }
 
 /**
@@ -867,12 +867,12 @@ static int batadv_handle_request(struct batadv_priv *bat_priv,
  * @claim_addr: Client to be unclaimed (ARP sender HW MAC)
  * @vid: the VLAN ID of the frame
  *
- * Return: 1 if handled
+ * Return: true if handled
  */
-static int batadv_handle_unclaim(struct batadv_priv *bat_priv,
-				 struct batadv_hard_iface *primary_if,
-				 u8 *backbone_addr, u8 *claim_addr,
-				 unsigned short vid)
+static bool batadv_handle_unclaim(struct batadv_priv *bat_priv,
+				  struct batadv_hard_iface *primary_if,
+				  u8 *backbone_addr, u8 *claim_addr,
+				  unsigned short vid)
 {
 	struct batadv_bla_backbone_gw *backbone_gw;
 
@@ -885,7 +885,7 @@ static int batadv_handle_unclaim(struct batadv_priv *bat_priv,
 	backbone_gw = batadv_backbone_hash_find(bat_priv, backbone_addr, vid);
 
 	if (!backbone_gw)
-		return 1;
+		return true;
 
 	/* this must be an UNCLAIM frame */
 	batadv_dbg(BATADV_DBG_BLA, bat_priv,
@@ -894,7 +894,7 @@ static int batadv_handle_unclaim(struct batadv_priv *bat_priv,
 
 	batadv_bla_del_claim(bat_priv, claim_addr, vid);
 	batadv_backbone_gw_put(backbone_gw);
-	return 1;
+	return true;
 }
 
 /**
@@ -905,12 +905,12 @@ static int batadv_handle_unclaim(struct batadv_priv *bat_priv,
  * @claim_addr: client mac address to be claimed (ARP sender HW MAC)
  * @vid: the VLAN ID of the frame
  *
- * Return: 1 if handled
+ * Return: true if handled
  */
-static int batadv_handle_claim(struct batadv_priv *bat_priv,
-			       struct batadv_hard_iface *primary_if,
-			       u8 *backbone_addr, u8 *claim_addr,
-			       unsigned short vid)
+static bool batadv_handle_claim(struct batadv_priv *bat_priv,
+				struct batadv_hard_iface *primary_if,
+				u8 *backbone_addr, u8 *claim_addr,
+				unsigned short vid)
 {
 	struct batadv_bla_backbone_gw *backbone_gw;
 
@@ -920,7 +920,7 @@ static int batadv_handle_claim(struct batadv_priv *bat_priv,
 						 false);
 
 	if (unlikely(!backbone_gw))
-		return 1;
+		return true;
 
 	/* this must be a CLAIM frame */
 	batadv_bla_add_claim(bat_priv, claim_addr, vid, backbone_gw);
@@ -931,7 +931,7 @@ static int batadv_handle_claim(struct batadv_priv *bat_priv,
 	/* TODO: we could call something like tt_local_del() here. */
 
 	batadv_backbone_gw_put(backbone_gw);
-	return 1;
+	return true;
 }
 
 /**
@@ -1015,12 +1015,12 @@ static int batadv_check_claim_group(struct batadv_priv *bat_priv,
  * @primary_if: the primary hard interface of this batman soft interface
  * @skb: the frame to be checked
  *
- * Return: 1 if it was a claim frame, otherwise return 0 to
+ * Return: true if it was a claim frame, otherwise return false to
  * tell the callee that it can use the frame on its own.
  */
-static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
-				    struct batadv_hard_iface *primary_if,
-				    struct sk_buff *skb)
+static bool batadv_bla_process_claim(struct batadv_priv *bat_priv,
+				     struct batadv_hard_iface *primary_if,
+				     struct sk_buff *skb)
 {
 	struct batadv_bla_claim_dst *bla_dst, *bla_dst_own;
 	u8 *hw_src, *hw_dst;
@@ -1051,7 +1051,7 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 			vhdr = skb_header_pointer(skb, headlen, VLAN_HLEN,
 						  &vhdr_buf);
 			if (!vhdr)
-				return 0;
+				return false;
 
 			proto = vhdr->h_vlan_encapsulated_proto;
 			headlen += VLAN_HLEN;
@@ -1060,12 +1060,12 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 	}
 
 	if (proto != htons(ETH_P_ARP))
-		return 0; /* not a claim frame */
+		return false; /* not a claim frame */
 
 	/* this must be a ARP frame. check if it is a claim. */
 
 	if (unlikely(!pskb_may_pull(skb, headlen + arp_hdr_len(skb->dev))))
-		return 0;
+		return false;
 
 	/* pskb_may_pull() may have modified the pointers, get ethhdr again */
 	ethhdr = eth_hdr(skb);
@@ -1075,13 +1075,13 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 	 * IP information
 	 */
 	if (arphdr->ar_hrd != htons(ARPHRD_ETHER))
-		return 0;
+		return false;
 	if (arphdr->ar_pro != htons(ETH_P_IP))
-		return 0;
+		return false;
 	if (arphdr->ar_hln != ETH_ALEN)
-		return 0;
+		return false;
 	if (arphdr->ar_pln != 4)
-		return 0;
+		return false;
 
 	hw_src = (u8 *)arphdr + sizeof(struct arphdr);
 	hw_dst = hw_src + ETH_ALEN + 4;
@@ -1091,14 +1091,14 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 	/* check if it is a claim frame in general */
 	if (memcmp(bla_dst->magic, bla_dst_own->magic,
 		   sizeof(bla_dst->magic)) != 0)
-		return 0;
+		return false;
 
 	/* check if there is a claim frame encapsulated deeper in (QinQ) and
 	 * drop that, as this is not supported by BLA but should also not be
 	 * sent via the mesh.
 	 */
 	if (vlan_depth > 1)
-		return 1;
+		return true;
 
 	/* Let the loopdetect frames on the mesh in any case. */
 	if (bla_dst->type == BATADV_CLAIM_TYPE_LOOPDETECT)
@@ -1114,7 +1114,7 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 			   hw_dst);
 
 	if (ret < 2)
-		return ret;
+		return !!ret;
 
 	/* become a backbone gw ourselves on this vlan if not happened yet */
 	batadv_bla_update_own_backbone_gw(bat_priv, primary_if, vid);
@@ -1124,30 +1124,30 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 	case BATADV_CLAIM_TYPE_CLAIM:
 		if (batadv_handle_claim(bat_priv, primary_if, hw_src,
 					ethhdr->h_source, vid))
-			return 1;
+			return true;
 		break;
 	case BATADV_CLAIM_TYPE_UNCLAIM:
 		if (batadv_handle_unclaim(bat_priv, primary_if,
 					  ethhdr->h_source, hw_src, vid))
-			return 1;
+			return true;
 		break;
 
 	case BATADV_CLAIM_TYPE_ANNOUNCE:
 		if (batadv_handle_announce(bat_priv, hw_src, ethhdr->h_source,
 					   vid))
-			return 1;
+			return true;
 		break;
 	case BATADV_CLAIM_TYPE_REQUEST:
 		if (batadv_handle_request(bat_priv, primary_if, hw_src, ethhdr,
 					  vid))
-			return 1;
+			return true;
 		break;
 	}
 
 	batadv_dbg(BATADV_DBG_BLA, bat_priv,
 		   "bla_process_claim(): ERROR - this looks like a claim frame, but is useless. eth src %pM on vid %d ...(hw_src %pM, hw_dst %pM)\n",
 		   ethhdr->h_source, BATADV_PRINT_VID(vid), hw_src, hw_dst);
-	return 1;
+	return true;
 }
 
 /**
@@ -1529,15 +1529,16 @@ int batadv_bla_init(struct batadv_priv *bat_priv)
  * sent by another host, drop it. We allow equal packets from
  * the same host however as this might be intended.
  *
- * Return: 1 if a packet is in the duplicate list, 0 otherwise.
+ * Return: true if a packet is in the duplicate list, false otherwise.
  */
-int batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
-				   struct sk_buff *skb)
+bool batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
+				    struct sk_buff *skb)
 {
-	int i, curr, ret = 0;
+	int i, curr;
 	__be32 crc;
 	struct batadv_bcast_packet *bcast_packet;
 	struct batadv_bcast_duplist_entry *entry;
+	bool ret = false;
 
 	bcast_packet = (struct batadv_bcast_packet *)skb->data;
 
@@ -1565,9 +1566,9 @@ int batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
 			continue;
 
 		/* this entry seems to match: same crc, not too old,
-		 * and from another gw. therefore return 1 to forbid it.
+		 * and from another gw. therefore return true to forbid it.
 		 */
-		ret = 1;
+		ret = true;
 		goto out;
 	}
 	/* not found, add a new entry (overwrite the oldest entry)
@@ -1633,21 +1634,21 @@ bool batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv, u8 *orig,
  * @orig_node: the orig_node of the frame
  * @hdr_size: maximum length of the frame
  *
- * Return: 1 if the orig_node is also a gateway on the soft interface, otherwise
- * it returns 0.
+ * Return: true if the orig_node is also a gateway on the soft interface,
+ * otherwise it returns false.
  */
-int batadv_bla_is_backbone_gw(struct sk_buff *skb,
-			      struct batadv_orig_node *orig_node, int hdr_size)
+bool batadv_bla_is_backbone_gw(struct sk_buff *skb,
+			       struct batadv_orig_node *orig_node, int hdr_size)
 {
 	struct batadv_bla_backbone_gw *backbone_gw;
 	unsigned short vid;
 
 	if (!atomic_read(&orig_node->bat_priv->bridge_loop_avoidance))
-		return 0;
+		return false;
 
 	/* first, find out the vid. */
 	if (!pskb_may_pull(skb, hdr_size + ETH_HLEN))
-		return 0;
+		return false;
 
 	vid = batadv_get_vid(skb, hdr_size);
 
@@ -1655,10 +1656,10 @@ int batadv_bla_is_backbone_gw(struct sk_buff *skb,
 	backbone_gw = batadv_backbone_hash_find(orig_node->bat_priv,
 						orig_node->orig, vid);
 	if (!backbone_gw)
-		return 0;
+		return false;
 
 	batadv_backbone_gw_put(backbone_gw);
-	return 1;
+	return true;
 }
 
 /**
@@ -1750,16 +1751,16 @@ batadv_bla_loopdetect_check(struct batadv_priv *bat_priv, struct sk_buff *skb,
  *
  * in these cases, the skb is further handled by this function
  *
- * Return: 1 if handled, otherwise it returns 0 and the caller shall further
- * process the skb.
+ * Return: true if handled, otherwise it returns false and the caller shall
+ * further process the skb.
  */
-int batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb,
-		  unsigned short vid, bool is_bcast)
+bool batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb,
+		   unsigned short vid, bool is_bcast)
 {
 	struct ethhdr *ethhdr;
 	struct batadv_bla_claim search_claim, *claim = NULL;
 	struct batadv_hard_iface *primary_if;
-	int ret;
+	bool ret;
 
 	ethhdr = eth_hdr(skb);
 
@@ -1821,12 +1822,12 @@ int batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb,
 	}
 allow:
 	batadv_bla_update_own_backbone_gw(bat_priv, primary_if, vid);
-	ret = 0;
+	ret = false;
 	goto out;
 
 handled:
 	kfree_skb(skb);
-	ret = 1;
+	ret = true;
 
 out:
 	if (primary_if)
@@ -1850,16 +1851,16 @@ out:
  *
  * This call might reallocate skb data.
  *
- * Return: 1 if handled, otherwise it returns 0 and the caller shall further
- * process the skb.
+ * Return: true if handled, otherwise it returns false and the caller shall
+ * further process the skb.
  */
-int batadv_bla_tx(struct batadv_priv *bat_priv, struct sk_buff *skb,
-		  unsigned short vid)
+bool batadv_bla_tx(struct batadv_priv *bat_priv, struct sk_buff *skb,
+		   unsigned short vid)
 {
 	struct ethhdr *ethhdr;
 	struct batadv_bla_claim search_claim, *claim = NULL;
 	struct batadv_hard_iface *primary_if;
-	int ret = 0;
+	bool ret = false;
 
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
@@ -1913,10 +1914,10 @@ int batadv_bla_tx(struct batadv_priv *bat_priv, struct sk_buff *skb,
 	}
 allow:
 	batadv_bla_update_own_backbone_gw(bat_priv, primary_if, vid);
-	ret = 0;
+	ret = false;
 	goto out;
 handled:
-	ret = 1;
+	ret = true;
 out:
 	if (primary_if)
 		batadv_hardif_put(primary_if);
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
index 579f0fa6fe6a..0f01daeb359e 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -27,19 +27,20 @@ struct seq_file;
 struct sk_buff;
 
 #ifdef CONFIG_BATMAN_ADV_BLA
-int batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb,
-		  unsigned short vid, bool is_bcast);
-int batadv_bla_tx(struct batadv_priv *bat_priv, struct sk_buff *skb,
-		  unsigned short vid);
-int batadv_bla_is_backbone_gw(struct sk_buff *skb,
-			      struct batadv_orig_node *orig_node, int hdr_size);
+bool batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb,
+		   unsigned short vid, bool is_bcast);
+bool batadv_bla_tx(struct batadv_priv *bat_priv, struct sk_buff *skb,
+		   unsigned short vid);
+bool batadv_bla_is_backbone_gw(struct sk_buff *skb,
+			       struct batadv_orig_node *orig_node,
+			       int hdr_size);
 int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset);
 int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq,
 					     void *offset);
 bool batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv, u8 *orig,
 				    unsigned short vid);
-int batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
-				   struct sk_buff *skb);
+bool batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
+				    struct sk_buff *skb);
 void batadv_bla_update_orig_address(struct batadv_priv *bat_priv,
 				    struct batadv_hard_iface *primary_if,
 				    struct batadv_hard_iface *oldif);
@@ -50,24 +51,24 @@ void batadv_bla_free(struct batadv_priv *bat_priv);
 #define BATADV_BLA_CRC_INIT	0
 #else /* ifdef CONFIG_BATMAN_ADV_BLA */
 
-static inline int batadv_bla_rx(struct batadv_priv *bat_priv,
-				struct sk_buff *skb, unsigned short vid,
-				bool is_bcast)
+static inline bool batadv_bla_rx(struct batadv_priv *bat_priv,
+				 struct sk_buff *skb, unsigned short vid,
+				 bool is_bcast)
 {
-	return 0;
+	return false;
 }
 
-static inline int batadv_bla_tx(struct batadv_priv *bat_priv,
-				struct sk_buff *skb, unsigned short vid)
+static inline bool batadv_bla_tx(struct batadv_priv *bat_priv,
+				 struct sk_buff *skb, unsigned short vid)
 {
-	return 0;
+	return false;
 }
 
-static inline int batadv_bla_is_backbone_gw(struct sk_buff *skb,
-					    struct batadv_orig_node *orig_node,
-					    int hdr_size)
+static inline bool batadv_bla_is_backbone_gw(struct sk_buff *skb,
+					     struct batadv_orig_node *orig_node,
+					     int hdr_size)
 {
-	return 0;
+	return false;
 }
 
 static inline int batadv_bla_claim_table_seq_print_text(struct seq_file *seq,
@@ -88,11 +89,11 @@ static inline bool batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv,
 	return false;
 }
 
-static inline int
+static inline bool
 batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
 			       struct sk_buff *skb)
 {
-	return 0;
+	return false;
 }
 
 static inline void
diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index aa315da83429..952900466d88 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -134,7 +134,7 @@ static int batadv_log_release(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static int batadv_log_empty(struct batadv_priv_debug_log *debug_log)
+static bool batadv_log_empty(struct batadv_priv_debug_log *debug_log)
 {
 	return !(debug_log->log_start - debug_log->log_end);
 }
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 67f44f5d630b..278800a99c69 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -165,14 +165,14 @@ static void batadv_dat_purge(struct work_struct *work)
  * @node: node in the local table
  * @data2: second object to compare the node to
  *
- * Return: 1 if the two entries are the same, 0 otherwise.
+ * Return: true if the two entries are the same, false otherwise.
  */
-static int batadv_compare_dat(const struct hlist_node *node, const void *data2)
+static bool batadv_compare_dat(const struct hlist_node *node, const void *data2)
 {
 	const void *data1 = container_of(node, struct batadv_dat_entry,
 					 hash_entry);
 
-	return memcmp(data1, data2, sizeof(__be32)) == 0 ? 1 : 0;
+	return memcmp(data1, data2, sizeof(__be32)) == 0;
 }
 
 /**
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 7c1d8d7ac548..8c2f39962fa5 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -146,22 +146,22 @@ static bool batadv_is_on_batman_iface(const struct net_device *net_dev)
 	return ret;
 }
 
-static int batadv_is_valid_iface(const struct net_device *net_dev)
+static bool batadv_is_valid_iface(const struct net_device *net_dev)
 {
 	if (net_dev->flags & IFF_LOOPBACK)
-		return 0;
+		return false;
 
 	if (net_dev->type != ARPHRD_ETHER)
-		return 0;
+		return false;
 
 	if (net_dev->addr_len != ETH_ALEN)
-		return 0;
+		return false;
 
 	/* no batman over batman */
 	if (batadv_is_on_batman_iface(net_dev))
-		return 0;
+		return false;
 
-	return 1;
+	return true;
 }
 
 /**
@@ -653,8 +653,7 @@ batadv_hardif_add_interface(struct net_device *net_dev)
 
 	ASSERT_RTNL();
 
-	ret = batadv_is_valid_iface(net_dev);
-	if (ret != 1)
+	if (!batadv_is_valid_iface(net_dev))
 		goto out;
 
 	dev_hold(net_dev);
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index 9bb57b87447c..cbbf87075f06 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -32,10 +32,10 @@ struct lock_class_key;
 /* callback to a compare function.  should compare 2 element datas for their
  * keys
  *
- * Return: 0 if same and not 0 if not same
+ * Return: true if same and false if not same
  */
-typedef int (*batadv_hashdata_compare_cb)(const struct hlist_node *,
-					  const void *);
+typedef bool (*batadv_hashdata_compare_cb)(const struct hlist_node *,
+					   const void *);
 
 /* the hashfunction
  *
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 090c6f0f2398..76925266deed 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -292,7 +292,7 @@ static inline void _batadv_dbg(int type __always_unused,
  *
  * note: can't use ether_addr_equal() as it requires aligned memory
  *
- * Return: 1 if they are the same ethernet addr
+ * Return: true if they are the same ethernet addr
  */
 static inline bool batadv_compare_eth(const void *data1, const void *data2)
 {
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 953dff1ad43b..df5ae9c7e507 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -510,10 +510,10 @@ static u32 batadv_nc_hash_choose(const void *data, u32 size)
  * @node: node in the local table
  * @data2: second object to compare the node to
  *
- * Return: 1 if the two entry are the same, 0 otherwise
+ * Return: true if the two entry are the same, false otherwise
  */
-static int batadv_nc_hash_compare(const struct hlist_node *node,
-				  const void *data2)
+static bool batadv_nc_hash_compare(const struct hlist_node *node,
+				   const void *data2)
 {
 	const struct batadv_nc_path *nc_path1, *nc_path2;
 
@@ -523,13 +523,13 @@ static int batadv_nc_hash_compare(const struct hlist_node *node,
 	/* Return 1 if the two keys are identical */
 	if (memcmp(nc_path1->prev_hop, nc_path2->prev_hop,
 		   sizeof(nc_path1->prev_hop)) != 0)
-		return 0;
+		return false;
 
 	if (memcmp(nc_path1->next_hop, nc_path2->next_hop,
 		   sizeof(nc_path1->next_hop)) != 0)
-		return 0;
+		return false;
 
-	return 1;
+	return true;
 }
 
 /**
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 04fa139911c3..1ff4ee473966 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -54,9 +54,9 @@ static void batadv_purge_orig(struct work_struct *work);
  * @node: node in the local table
  * @data2: second object to compare the node to
  *
- * Return: 1 if they are the same originator
+ * Return: true if they are the same originator
  */
-int batadv_compare_orig(const struct hlist_node *node, const void *data2)
+bool batadv_compare_orig(const struct hlist_node *node, const void *data2)
 {
 	const void *data1 = container_of(node, struct batadv_orig_node,
 					 hash_entry);
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 4e8b67f11051..64a8951e5844 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -33,7 +33,7 @@
 
 struct seq_file;
 
-int batadv_compare_orig(const struct hlist_node *node, const void *data2);
+bool batadv_compare_orig(const struct hlist_node *node, const void *data2);
 int batadv_originator_init(struct batadv_priv *bat_priv);
 void batadv_originator_free(struct batadv_priv *bat_priv);
 void batadv_purge_orig_ref(struct batadv_priv *bat_priv);
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index b494e435686f..ae850f2d11cb 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -163,18 +163,18 @@ out:
  *   doesn't change otherwise.
  *
  * Return:
- *  0 if the packet is to be accepted.
- *  1 if the packet is to be ignored.
+ *  false if the packet is to be accepted.
+ *  true if the packet is to be ignored.
  */
-int batadv_window_protected(struct batadv_priv *bat_priv, s32 seq_num_diff,
-			    s32 seq_old_max_diff, unsigned long *last_reset,
-			    bool *protection_started)
+bool batadv_window_protected(struct batadv_priv *bat_priv, s32 seq_num_diff,
+			     s32 seq_old_max_diff, unsigned long *last_reset,
+			     bool *protection_started)
 {
 	if (seq_num_diff <= -seq_old_max_diff ||
 	    seq_num_diff >= BATADV_EXPECTED_SEQNO_RANGE) {
 		if (!batadv_has_timed_out(*last_reset,
 					  BATADV_RESET_PROTECTION_MS))
-			return 1;
+			return true;
 
 		*last_reset = jiffies;
 		if (protection_started)
@@ -183,7 +183,7 @@ int batadv_window_protected(struct batadv_priv *bat_priv, s32 seq_num_diff,
 			   "old packet received, start protection\n");
 	}
 
-	return 0;
+	return false;
 }
 
 bool batadv_check_management_packet(struct sk_buff *skb,
@@ -718,8 +718,9 @@ out:
 	return ret;
 }
 
-static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
-				     struct sk_buff *skb, int hdr_len) {
+static bool batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
+				      struct sk_buff *skb, int hdr_len)
+{
 	struct batadv_unicast_packet *unicast_packet;
 	struct batadv_hard_iface *primary_if;
 	struct batadv_orig_node *orig_node;
@@ -730,11 +731,11 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 
 	/* check if there is enough data before accessing it */
 	if (!pskb_may_pull(skb, hdr_len + ETH_HLEN))
-		return 0;
+		return false;
 
 	/* create a copy of the skb (in case of for re-routing) to modify it. */
 	if (skb_cow(skb, sizeof(*unicast_packet)) < 0)
-		return 0;
+		return false;
 
 	unicast_packet = (struct batadv_unicast_packet *)skb->data;
 	vid = batadv_get_vid(skb, hdr_len);
@@ -758,7 +759,7 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 		 * table. If not, let the packet go untouched anyway because
 		 * there is nothing the node can do
 		 */
-		return 1;
+		return true;
 	}
 
 	/* retrieve the TTVN known by this node for the packet destination. This
@@ -774,7 +775,7 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 		 * not be possible to deliver it
 		 */
 		if (!orig_node)
-			return 0;
+			return false;
 
 		curr_ttvn = (u8)atomic_read(&orig_node->last_ttvn);
 		batadv_orig_node_put(orig_node);
@@ -785,7 +786,7 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 	 */
 	is_old_ttvn = batadv_seq_before(unicast_packet->ttvn, curr_ttvn);
 	if (!is_old_ttvn)
-		return 1;
+		return true;
 
 	old_ttvn = unicast_packet->ttvn;
 	/* the packet was forged based on outdated network information. Its
@@ -798,7 +799,7 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 				       "Rerouting unicast packet to %pM (dst=%pM): TTVN mismatch old_ttvn=%u new_ttvn=%u\n",
 				       unicast_packet->dest, ethhdr->h_dest,
 				       old_ttvn, curr_ttvn);
-		return 1;
+		return true;
 	}
 
 	/* the packet has not been re-routed: either the destination is
@@ -806,14 +807,14 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 	 * it is possible to drop the packet
 	 */
 	if (!batadv_is_my_client(bat_priv, ethhdr->h_dest, vid))
-		return 0;
+		return false;
 
 	/* update the header in order to let the packet be delivered to this
 	 * node's soft interface
 	 */
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
-		return 0;
+		return false;
 
 	ether_addr_copy(unicast_packet->dest, primary_if->net_dev->dev_addr);
 
@@ -821,7 +822,7 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 
 	unicast_packet->ttvn = curr_ttvn;
 
-	return 1;
+	return true;
 }
 
 /**
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 02a5caa84127..05c3ff42e181 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -51,8 +51,8 @@ struct batadv_neigh_node *
 batadv_find_router(struct batadv_priv *bat_priv,
 		   struct batadv_orig_node *orig_node,
 		   struct batadv_hard_iface *recv_if);
-int batadv_window_protected(struct batadv_priv *bat_priv, s32 seq_num_diff,
-			    s32 seq_old_max_diff, unsigned long *last_reset,
-			    bool *protection_started);
+bool batadv_window_protected(struct batadv_priv *bat_priv, s32 seq_num_diff,
+			     s32 seq_old_max_diff, unsigned long *last_reset,
+			     bool *protection_started);
 
 #endif /* _NET_BATMAN_ADV_ROUTING_H_ */
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 04866c9b860a..3a0fc3c18444 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -1045,12 +1045,12 @@ static void batadv_softif_destroy_netlink(struct net_device *soft_iface,
 	unregister_netdevice_queue(soft_iface, head);
 }
 
-int batadv_softif_is_valid(const struct net_device *net_dev)
+bool batadv_softif_is_valid(const struct net_device *net_dev)
 {
 	if (net_dev->netdev_ops->ndo_start_xmit == batadv_interface_tx)
-		return 1;
+		return true;
 
-	return 0;
+	return false;
 }
 
 struct rtnl_link_ops batadv_link_ops __read_mostly = {
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index b0966342a986..ec303ddbf647 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -20,6 +20,7 @@
 
 #include "main.h"
 
+#include <linux/types.h>
 #include <net/rtnetlink.h>
 
 struct net_device;
@@ -32,7 +33,7 @@ void batadv_interface_rx(struct net_device *soft_iface,
 			 struct batadv_orig_node *orig_node);
 struct net_device *batadv_softif_create(struct net *net, const char *name);
 void batadv_softif_destroy_sysfs(struct net_device *soft_iface);
-int batadv_softif_is_valid(const struct net_device *net_dev);
+bool batadv_softif_is_valid(const struct net_device *net_dev);
 extern struct rtnl_link_ops batadv_link_ops;
 int batadv_softif_create_vlan(struct batadv_priv *bat_priv, unsigned short vid);
 void batadv_softif_vlan_put(struct batadv_softif_vlan *softif_vlan);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 6ea6e9bf9a8c..feaf492b01ca 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -75,9 +75,9 @@ static void batadv_tt_global_del(struct batadv_priv *bat_priv,
  *
  * Compare the MAC address and the VLAN ID of the two TT entries and check if
  * they are the same TT client.
- * Return: 1 if the two TT clients are the same, 0 otherwise
+ * Return: true if the two TT clients are the same, false otherwise
  */
-static int batadv_compare_tt(const struct hlist_node *node, const void *data2)
+static bool batadv_compare_tt(const struct hlist_node *node, const void *data2)
 {
 	const void *data1 = container_of(node, struct batadv_tt_common_entry,
 					 hash_entry);
@@ -2361,19 +2361,19 @@ unlock:
  * @entry_ptr: to be checked local tt entry
  * @data_ptr: not used but definition required to satisfy the callback prototype
  *
- * Return: 1 if the entry is a valid, 0 otherwise.
+ * Return: true if the entry is a valid, false otherwise.
  */
-static int batadv_tt_local_valid(const void *entry_ptr, const void *data_ptr)
+static bool batadv_tt_local_valid(const void *entry_ptr, const void *data_ptr)
 {
 	const struct batadv_tt_common_entry *tt_common_entry = entry_ptr;
 
 	if (tt_common_entry->flags & BATADV_TT_CLIENT_NEW)
-		return 0;
-	return 1;
+		return false;
+	return true;
 }
 
-static int batadv_tt_global_valid(const void *entry_ptr,
-				  const void *data_ptr)
+static bool batadv_tt_global_valid(const void *entry_ptr,
+				   const void *data_ptr)
 {
 	const struct batadv_tt_common_entry *tt_common_entry = entry_ptr;
 	const struct batadv_tt_global_entry *tt_global_entry;
@@ -2381,7 +2381,7 @@ static int batadv_tt_global_valid(const void *entry_ptr,
 
 	if (tt_common_entry->flags & BATADV_TT_CLIENT_ROAM ||
 	    tt_common_entry->flags & BATADV_TT_CLIENT_TEMP)
-		return 0;
+		return false;
 
 	tt_global_entry = container_of(tt_common_entry,
 				       struct batadv_tt_global_entry,
@@ -2403,7 +2403,8 @@ static int batadv_tt_global_valid(const void *entry_ptr,
 static void batadv_tt_tvlv_generate(struct batadv_priv *bat_priv,
 				    struct batadv_hashtable *hash,
 				    void *tvlv_buff, u16 tt_len,
-				    int (*valid_cb)(const void *, const void *),
+				    bool (*valid_cb)(const void *,
+						     const void *),
 				    void *cb_data)
 {
 	struct batadv_tt_common_entry *tt_common_entry;
@@ -2552,11 +2553,11 @@ static void batadv_tt_global_update_crc(struct batadv_priv *bat_priv,
  *
  * Return: true if the TT Request was sent, false otherwise
  */
-static int batadv_send_tt_request(struct batadv_priv *bat_priv,
-				  struct batadv_orig_node *dst_orig_node,
-				  u8 ttvn,
-				  struct batadv_tvlv_tt_vlan_data *tt_vlan,
-				  u16 num_vlan, bool full_table)
+static bool batadv_send_tt_request(struct batadv_priv *bat_priv,
+				   struct batadv_orig_node *dst_orig_node,
+				   u8 ttvn,
+				   struct batadv_tvlv_tt_vlan_data *tt_vlan,
+				   u16 num_vlan, bool full_table)
 {
 	struct batadv_tvlv_tt_data *tvlv_tt_data = NULL;
 	struct batadv_tt_req_node *tt_req_node = NULL;
-- 
2.8.2
