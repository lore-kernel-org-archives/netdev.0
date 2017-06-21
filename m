From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [net-next PATCH] hsr: fix coding style issues
Date: Wed, 21 Jun 2017 11:49:01 -0400
Message-ID: <1498060142-8925-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <arvid.brodin@alten.se>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:21710 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752460AbdFUSNm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 14:13:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fix coding style issues detected by running checkpatch.pl -f
option on files under net/hsr.

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 - applies to net-next/master
 - Test logs at http://pastebin.ubuntu.com/24917637/
 net/hsr/hsr_device.c   |  49 +++++++++------------
 net/hsr/hsr_forward.c  |  72 ++++++++++++++-----------------
 net/hsr/hsr_framereg.c | 113 +++++++++++++++++++++++--------------------------
 net/hsr/hsr_main.c     |  10 ++---
 net/hsr/hsr_main.h     |  36 +++++++---------
 net/hsr/hsr_netlink.c  |  55 +++++++++++-------------
 net/hsr/hsr_slave.c    |   9 ++--
 7 files changed, 150 insertions(+), 194 deletions(-)

diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
index 4e7bdb2..6a1d7a5 100644
--- a/net/hsr/hsr_device.c
+++ b/net/hsr/hsr_device.c
@@ -23,7 +23,6 @@
 #include "hsr_main.h"
 #include "hsr_forward.h"
 
-
 static bool is_admin_up(struct net_device *dev)
 {
 	return dev && (dev->flags & IFF_UP);
@@ -82,7 +81,6 @@ static bool hsr_check_carrier(struct hsr_port *master)
 	return has_carrier;
 }
 
-
 static void hsr_check_announce(struct net_device *hsr_dev,
 			       unsigned char old_operstate)
 {
@@ -90,8 +88,8 @@ static void hsr_check_announce(struct net_device *hsr_dev,
 
 	hsr = netdev_priv(hsr_dev);
 
-	if ((hsr_dev->operstate == IF_OPER_UP)
-			&& (old_operstate != IF_OPER_UP)) {
+	if ((hsr_dev->operstate == IF_OPER_UP) &&
+	    (old_operstate != IF_OPER_UP)) {
 		/* Went up */
 		hsr->announce_count = 0;
 		hsr->announce_timer.expires = jiffies +
@@ -137,7 +135,6 @@ int hsr_get_max_mtu(struct hsr_priv *hsr)
 	return mtu_max - HSR_HLEN;
 }
 
-
 static int hsr_dev_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct hsr_priv *hsr;
@@ -192,14 +189,12 @@ static int hsr_dev_open(struct net_device *dev)
 	return 0;
 }
 
-
 static int hsr_dev_close(struct net_device *dev)
 {
 	/* Nothing to do here. */
 	return 0;
 }
 
-
 static netdev_features_t hsr_features_recompute(struct hsr_priv *hsr,
 						netdev_features_t features)
 {
@@ -232,7 +227,6 @@ static netdev_features_t hsr_fix_features(struct net_device *dev,
 	return hsr_features_recompute(hsr, features);
 }
 
-
 static int hsr_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct hsr_priv *hsr = netdev_priv(dev);
@@ -245,14 +239,13 @@ static int hsr_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-
 static const struct header_ops hsr_header_ops = {
 	.create	 = eth_header,
 	.parse	 = eth_header_parse,
 };
 
 static void send_hsr_supervision_frame(struct hsr_port *master,
-		u8 type, u8 hsrVer)
+				       u8 type, u8 hsr_ver)
 {
 	struct sk_buff *skb;
 	int hlen, tlen;
@@ -268,34 +261,34 @@ static void send_hsr_supervision_frame(struct hsr_port *master,
 			sizeof(struct hsr_sup_tag) +
 			sizeof(struct hsr_sup_payload) + hlen + tlen);
 
-	if (skb == NULL)
+	if (!skb)
 		return;
 
 	skb_reserve(skb, hlen);
 
 	skb->dev = master->dev;
-	skb->protocol = htons(hsrVer ? ETH_P_HSR : ETH_P_PRP);
+	skb->protocol = htons(hsr_ver ? ETH_P_HSR : ETH_P_PRP);
 	skb->priority = TC_PRIO_CONTROL;
 
-	if (dev_hard_header(skb, skb->dev, (hsrVer ? ETH_P_HSR : ETH_P_PRP),
+	if (dev_hard_header(skb, skb->dev, (hsr_ver ? ETH_P_HSR : ETH_P_PRP),
 			    master->hsr->sup_multicast_addr,
 			    skb->dev->dev_addr, skb->len) <= 0)
 		goto out;
 	skb_reset_mac_header(skb);
 
-	if (hsrVer > 0) {
+	if (hsr_ver > 0) {
 		hsr_tag = skb_put(skb, sizeof(struct hsr_tag));
 		hsr_tag->encap_proto = htons(ETH_P_PRP);
 		set_hsr_tag_LSDU_size(hsr_tag, HSR_V1_SUP_LSDUSIZE);
 	}
 
 	hsr_stag = skb_put(skb, sizeof(struct hsr_sup_tag));
-	set_hsr_stag_path(hsr_stag, (hsrVer ? 0x0 : 0xf));
-	set_hsr_stag_HSR_Ver(hsr_stag, hsrVer);
+	set_hsr_stag_path(hsr_stag, (hsr_ver ? 0x0 : 0xf));
+	set_hsr_stag_HSR_ver(hsr_stag, hsr_ver);
 
 	/* From HSRv1 on we have separate supervision sequence numbers. */
 	spin_lock_irqsave(&master->hsr->seqnr_lock, irqflags);
-	if (hsrVer > 0) {
+	if (hsr_ver > 0) {
 		hsr_stag->sequence_nr = htons(master->hsr->sup_sequence_nr);
 		hsr_tag->sequence_nr = htons(master->hsr->sequence_nr);
 		master->hsr->sup_sequence_nr++;
@@ -306,13 +299,14 @@ static void send_hsr_supervision_frame(struct hsr_port *master,
 	}
 	spin_unlock_irqrestore(&master->hsr->seqnr_lock, irqflags);
 
-	hsr_stag->HSR_TLV_Type = type;
+	hsr_stag->HSR_TLV_type = type;
 	/* TODO: Why 12 in HSRv0? */
-	hsr_stag->HSR_TLV_Length = hsrVer ? sizeof(struct hsr_sup_payload) : 12;
+	hsr_stag->HSR_TLV_length = hsr_ver ?
+			sizeof(struct hsr_sup_payload) : 12;
 
-	/* Payload: MacAddressA */
+	/* Payload: mac_address_A */
 	hsr_sp = skb_put(skb, sizeof(struct hsr_sup_payload));
-	ether_addr_copy(hsr_sp->MacAddressA, master->dev->dev_addr);
+	ether_addr_copy(hsr_sp->mac_address_A, master->dev->dev_addr);
 
 	skb_put_padto(skb, ETH_ZLEN + HSR_HLEN);
 
@@ -324,7 +318,6 @@ static void send_hsr_supervision_frame(struct hsr_port *master,
 	kfree_skb(skb);
 }
 
-
 /* Announce (supervision frame) timer function
  */
 static void hsr_announce(unsigned long data)
@@ -332,21 +325,21 @@ static void hsr_announce(unsigned long data)
 	struct hsr_priv *hsr;
 	struct hsr_port *master;
 
-	hsr = (struct hsr_priv *) data;
+	hsr = (struct hsr_priv *)data;
 
 	rcu_read_lock();
 	master = hsr_port_get_hsr(hsr, HSR_PT_MASTER);
 
-	if (hsr->announce_count < 3 && hsr->protVersion == 0) {
+	if (hsr->announce_count < 3 && hsr->prot_version == 0) {
 		send_hsr_supervision_frame(master, HSR_TLV_ANNOUNCE,
-				hsr->protVersion);
+					   hsr->prot_version);
 		hsr->announce_count++;
 
 		hsr->announce_timer.expires = jiffies +
 				msecs_to_jiffies(HSR_ANNOUNCE_INTERVAL);
 	} else {
 		send_hsr_supervision_frame(master, HSR_TLV_LIFE_CHECK,
-				hsr->protVersion);
+					   hsr->prot_version);
 
 		hsr->announce_timer.expires = jiffies +
 				msecs_to_jiffies(HSR_LIFE_CHECK_INTERVAL);
@@ -358,7 +351,6 @@ static void hsr_announce(unsigned long data)
 	rcu_read_unlock();
 }
 
-
 /* According to comments in the declaration of struct net_device, this function
  * is "Called from unregister, can be used to call free_netdev". Ok then...
  */
@@ -424,7 +416,6 @@ void hsr_dev_setup(struct net_device *dev)
 	dev->features |= NETIF_F_NETNS_LOCAL;
 }
 
-
 /* Return true if dev is a HSR master; return false otherwise.
  */
 inline bool is_hsr_master(struct net_device *dev)
@@ -469,7 +460,7 @@ int hsr_dev_finalize(struct net_device *hsr_dev, struct net_device *slave[2],
 	ether_addr_copy(hsr->sup_multicast_addr, def_multicast_addr);
 	hsr->sup_multicast_addr[ETH_ALEN - 1] = multicast_spec;
 
-	hsr->protVersion = protocol_version;
+	hsr->prot_version = protocol_version;
 
 	/* FIXME: should I modify the value of these?
 	 *
diff --git a/net/hsr/hsr_forward.c b/net/hsr/hsr_forward.c
index 04b5450..2b994eb 100644
--- a/net/hsr/hsr_forward.c
+++ b/net/hsr/hsr_forward.c
@@ -17,7 +17,6 @@
 #include "hsr_main.h"
 #include "hsr_framereg.h"
 
-
 struct hsr_node;
 
 struct hsr_frame_info {
@@ -32,7 +31,6 @@ struct hsr_frame_info {
 	bool is_local_exclusive;
 };
 
-
 /* The uses I can see for these HSR supervision frames are:
  * 1) Use the frames that are sent after node initialization ("HSR_TLV.Type =
  *    22") to reset any sequence_nr counters belonging to that node. Useful if
@@ -46,50 +44,49 @@ struct hsr_frame_info {
  *    We just register these (as with normal frames) and throw them away.
  *
  * 3) Allow different MAC addresses for the two slave interfaces, using the
- *    MacAddressA field.
+ *    mac_address_A field.
  */
 static bool is_supervision_frame(struct hsr_priv *hsr, struct sk_buff *skb)
 {
-	struct ethhdr *ethHdr;
-	struct hsr_sup_tag *hsrSupTag;
-	struct hsrv1_ethhdr_sp *hsrV1Hdr;
+	struct ethhdr *eth_hdr;
+	struct hsr_sup_tag *hsr_sup_tag;
+	struct hsrv1_ethhdr_sp *hsr_v1_hdr;
 
 	WARN_ON_ONCE(!skb_mac_header_was_set(skb));
-	ethHdr = (struct ethhdr *) skb_mac_header(skb);
+	eth_hdr = (struct ethhdr *)skb_mac_header(skb);
 
 	/* Correct addr? */
-	if (!ether_addr_equal(ethHdr->h_dest,
+	if (!ether_addr_equal(eth_hdr->h_dest,
 			      hsr->sup_multicast_addr))
 		return false;
 
 	/* Correct ether type?. */
-	if (!(ethHdr->h_proto == htons(ETH_P_PRP)
-			|| ethHdr->h_proto == htons(ETH_P_HSR)))
+	if (!(eth_hdr->h_proto == htons(ETH_P_PRP) ||
+	      eth_hdr->h_proto == htons(ETH_P_HSR)))
 		return false;
 
 	/* Get the supervision header from correct location. */
-	if (ethHdr->h_proto == htons(ETH_P_HSR)) { /* Okay HSRv1. */
-		hsrV1Hdr = (struct hsrv1_ethhdr_sp *) skb_mac_header(skb);
-		if (hsrV1Hdr->hsr.encap_proto != htons(ETH_P_PRP))
+	if (eth_hdr->h_proto == htons(ETH_P_HSR)) { /* Okay HSRv1. */
+		hsr_v1_hdr = (struct hsrv1_ethhdr_sp *)skb_mac_header(skb);
+		if (hsr_v1_hdr->hsr.encap_proto != htons(ETH_P_PRP))
 			return false;
 
-		hsrSupTag = &hsrV1Hdr->hsr_sup;
+		hsr_sup_tag = &hsr_v1_hdr->hsr_sup;
 	} else {
-		hsrSupTag = &((struct hsrv0_ethhdr_sp *) skb_mac_header(skb))->hsr_sup;
+		hsr_sup_tag =
+		&((struct hsrv0_ethhdr_sp *)skb_mac_header(skb))->hsr_sup;
 	}
 
-	if ((hsrSupTag->HSR_TLV_Type != HSR_TLV_ANNOUNCE) &&
-	    (hsrSupTag->HSR_TLV_Type != HSR_TLV_LIFE_CHECK))
+	if ((hsr_sup_tag->HSR_TLV_type != HSR_TLV_ANNOUNCE) &&
+	    (hsr_sup_tag->HSR_TLV_type != HSR_TLV_LIFE_CHECK))
 		return false;
-	if ((hsrSupTag->HSR_TLV_Length != 12) &&
-			(hsrSupTag->HSR_TLV_Length !=
-					sizeof(struct hsr_sup_payload)))
+	if ((hsr_sup_tag->HSR_TLV_length != 12) &&
+	    (hsr_sup_tag->HSR_TLV_length != sizeof(struct hsr_sup_payload)))
 		return false;
 
 	return true;
 }
 
-
 static struct sk_buff *create_stripped_skb(struct sk_buff *skb_in,
 					   struct hsr_frame_info *frame)
 {
@@ -100,7 +97,7 @@ static struct sk_buff *create_stripped_skb(struct sk_buff *skb_in,
 	skb_pull(skb_in, HSR_HLEN);
 	skb = __pskb_copy(skb_in, skb_headroom(skb_in) - HSR_HLEN, GFP_ATOMIC);
 	skb_push(skb_in, HSR_HLEN);
-	if (skb == NULL)
+	if (!skb)
 		return NULL;
 
 	skb_reset_mac_header(skb);
@@ -108,7 +105,7 @@ static struct sk_buff *create_stripped_skb(struct sk_buff *skb_in,
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		skb->csum_start -= HSR_HLEN;
 
-	copylen = 2*ETH_ALEN;
+	copylen = 2 * ETH_ALEN;
 	if (frame->is_vlan)
 		copylen += VLAN_HLEN;
 	src = skb_mac_header(skb_in);
@@ -127,9 +124,8 @@ static struct sk_buff *frame_get_stripped_skb(struct hsr_frame_info *frame,
 	return skb_clone(frame->skb_std, GFP_ATOMIC);
 }
 
-
 static void hsr_fill_tag(struct sk_buff *skb, struct hsr_frame_info *frame,
-			 struct hsr_port *port, u8 protoVersion)
+			 struct hsr_port *port, u8 prot_version)
 {
 	struct hsr_ethhdr *hsr_ethhdr;
 	int lane_id;
@@ -144,13 +140,13 @@ static void hsr_fill_tag(struct sk_buff *skb, struct hsr_frame_info *frame,
 	if (frame->is_vlan)
 		lsdu_size -= 4;
 
-	hsr_ethhdr = (struct hsr_ethhdr *) skb_mac_header(skb);
+	hsr_ethhdr = (struct hsr_ethhdr *)skb_mac_header(skb);
 
 	set_hsr_tag_path(&hsr_ethhdr->hsr_tag, lane_id);
 	set_hsr_tag_LSDU_size(&hsr_ethhdr->hsr_tag, lsdu_size);
 	hsr_ethhdr->hsr_tag.sequence_nr = htons(frame->sequence_nr);
 	hsr_ethhdr->hsr_tag.encap_proto = hsr_ethhdr->ethhdr.h_proto;
-	hsr_ethhdr->ethhdr.h_proto = htons(protoVersion ?
+	hsr_ethhdr->ethhdr.h_proto = htons(prot_version ?
 			ETH_P_HSR : ETH_P_PRP);
 }
 
@@ -164,7 +160,7 @@ static struct sk_buff *create_tagged_skb(struct sk_buff *skb_o,
 
 	/* Create the new skb with enough headroom to fit the HSR tag */
 	skb = __pskb_copy(skb_o, skb_headroom(skb_o) + HSR_HLEN, GFP_ATOMIC);
-	if (skb == NULL)
+	if (!skb)
 		return NULL;
 	skb_reset_mac_header(skb);
 
@@ -180,7 +176,7 @@ static struct sk_buff *create_tagged_skb(struct sk_buff *skb_o,
 	memmove(dst, src, movelen);
 	skb_reset_mac_header(skb);
 
-	hsr_fill_tag(skb, frame, port, port->hsr->protVersion);
+	hsr_fill_tag(skb, frame, port, port->hsr->prot_version);
 
 	return skb;
 }
@@ -202,7 +198,6 @@ static struct sk_buff *frame_get_tagged_skb(struct hsr_frame_info *frame,
 	return create_tagged_skb(frame->skb_std, frame, port);
 }
 
-
 static void hsr_deliver_master(struct sk_buff *skb, struct net_device *dev,
 			       struct hsr_node *node_src)
 {
@@ -237,7 +232,6 @@ static int hsr_xmit(struct sk_buff *skb, struct hsr_port *port,
 	return dev_queue_xmit(skb);
 }
 
-
 /* Forward the frame through all devices except:
  * - Back through the receiving device
  * - If it's a HSR frame: through a device where it has passed before
@@ -283,7 +277,7 @@ static void hsr_forward_do(struct hsr_frame_info *frame)
 			skb = frame_get_tagged_skb(frame, port);
 		else
 			skb = frame_get_stripped_skb(frame, port);
-		if (skb == NULL) {
+		if (!skb) {
 			/* FIXME: Record the dropped frame? */
 			continue;
 		}
@@ -296,7 +290,6 @@ static void hsr_forward_do(struct hsr_frame_info *frame)
 	}
 }
 
-
 static void check_local_dest(struct hsr_priv *hsr, struct sk_buff *skb,
 			     struct hsr_frame_info *frame)
 {
@@ -316,7 +309,6 @@ static void check_local_dest(struct hsr_priv *hsr, struct sk_buff *skb,
 	}
 }
 
-
 static int hsr_fill_frame_info(struct hsr_frame_info *frame,
 			       struct sk_buff *skb, struct hsr_port *port)
 {
@@ -325,18 +317,18 @@ static int hsr_fill_frame_info(struct hsr_frame_info *frame,
 
 	frame->is_supervision = is_supervision_frame(port->hsr, skb);
 	frame->node_src = hsr_get_node(port, skb, frame->is_supervision);
-	if (frame->node_src == NULL)
+	if (!frame->node_src)
 		return -1; /* Unknown node and !is_supervision, or no mem */
 
-	ethhdr = (struct ethhdr *) skb_mac_header(skb);
+	ethhdr = (struct ethhdr *)skb_mac_header(skb);
 	frame->is_vlan = false;
 	if (ethhdr->h_proto == htons(ETH_P_8021Q)) {
 		frame->is_vlan = true;
 		/* FIXME: */
 		WARN_ONCE(1, "HSR: VLAN not yet supported");
 	}
-	if (ethhdr->h_proto == htons(ETH_P_PRP)
-			|| ethhdr->h_proto == htons(ETH_P_HSR)) {
+	if (ethhdr->h_proto == htons(ETH_P_PRP) ||
+	    ethhdr->h_proto == htons(ETH_P_HSR)) {
 		frame->skb_std = NULL;
 		frame->skb_hsr = skb;
 		frame->sequence_nr = hsr_get_skb_sequence_nr(skb);
@@ -372,9 +364,9 @@ void hsr_forward_skb(struct sk_buff *skb, struct hsr_port *port)
 	hsr_register_frame_in(frame.node_src, port, frame.sequence_nr);
 	hsr_forward_do(&frame);
 
-	if (frame.skb_hsr != NULL)
+	if (frame.skb_hsr)
 		kfree_skb(frame.skb_hsr);
-	if (frame.skb_std != NULL)
+	if (frame.skb_std)
 		kfree_skb(frame.skb_std);
 	return;
 
diff --git a/net/hsr/hsr_framereg.c b/net/hsr/hsr_framereg.c
index 284a9b8..de0eb8b 100644
--- a/net/hsr/hsr_framereg.c
+++ b/net/hsr/hsr_framereg.c
@@ -22,23 +22,20 @@
 #include "hsr_framereg.h"
 #include "hsr_netlink.h"
 
-
 struct hsr_node {
 	struct list_head	mac_list;
-	unsigned char		MacAddressA[ETH_ALEN];
-	unsigned char		MacAddressB[ETH_ALEN];
+	unsigned char		mac_address_A[ETH_ALEN];
+	unsigned char		mac_address_B[ETH_ALEN];
 	/* Local slave through which AddrB frames are received from this node */
-	enum hsr_port_type	AddrB_port;
+	enum hsr_port_type	addr_B_port;
 	unsigned long		time_in[HSR_PT_PORTS];
 	bool			time_in_stale[HSR_PT_PORTS];
 	u16			seq_out[HSR_PT_PORTS];
 	struct rcu_head		rcu_head;
 };
 
-
 /*	TODO: use hash lists for mac addresses (linux/jhash.h)?    */
 
-
 /* seq_nr_after(a, b) - return true if a is after (higher in sequence than) b,
  * false otherwise.
  */
@@ -47,16 +44,16 @@ static bool seq_nr_after(u16 a, u16 b)
 	/* Remove inconsistency where
 	 * seq_nr_after(a, b) == seq_nr_before(a, b)
 	 */
-	if ((int) b - a == 32768)
+	if ((int)b - a == 32768)
 		return false;
 
-	return (((s16) (b - a)) < 0);
+	return (((s16)(b - a)) < 0);
 }
+
 #define seq_nr_before(a, b)		seq_nr_after((b), (a))
 #define seq_nr_after_or_eq(a, b)	(!seq_nr_before((a), (b)))
 #define seq_nr_before_or_eq(a, b)	(!seq_nr_after((a), (b)))
 
-
 bool hsr_addr_is_self(struct hsr_priv *hsr, unsigned char *addr)
 {
 	struct hsr_node *node;
@@ -68,9 +65,9 @@ bool hsr_addr_is_self(struct hsr_priv *hsr, unsigned char *addr)
 		return false;
 	}
 
-	if (ether_addr_equal(addr, node->MacAddressA))
+	if (ether_addr_equal(addr, node->mac_address_A))
 		return true;
-	if (ether_addr_equal(addr, node->MacAddressB))
+	if (ether_addr_equal(addr, node->mac_address_B))
 		return true;
 
 	return false;
@@ -78,20 +75,19 @@ bool hsr_addr_is_self(struct hsr_priv *hsr, unsigned char *addr)
 
 /* Search for mac entry. Caller must hold rcu read lock.
  */
-static struct hsr_node *find_node_by_AddrA(struct list_head *node_db,
-					   const unsigned char addr[ETH_ALEN])
+static struct hsr_node *find_node_by_addr_A(struct list_head *node_db,
+					    const unsigned char addr[ETH_ALEN])
 {
 	struct hsr_node *node;
 
 	list_for_each_entry_rcu(node, node_db, mac_list) {
-		if (ether_addr_equal(node->MacAddressA, addr))
+		if (ether_addr_equal(node->mac_address_A, addr))
 			return node;
 	}
 
 	return NULL;
 }
 
-
 /* Helper for device init; the self_node_db is used in hsr_rcv() to recognize
  * frames from self that's been looped over the HSR ring.
  */
@@ -105,12 +101,12 @@ int hsr_create_self_node(struct list_head *self_node_db,
 	if (!node)
 		return -ENOMEM;
 
-	ether_addr_copy(node->MacAddressA, addr_a);
-	ether_addr_copy(node->MacAddressB, addr_b);
+	ether_addr_copy(node->mac_address_A, addr_a);
+	ether_addr_copy(node->mac_address_B, addr_b);
 
 	rcu_read_lock();
 	oldnode = list_first_or_null_rcu(self_node_db,
-						struct hsr_node, mac_list);
+					 struct hsr_node, mac_list);
 	if (oldnode) {
 		list_replace_rcu(&oldnode->mac_list, &node->mac_list);
 		rcu_read_unlock();
@@ -124,7 +120,6 @@ int hsr_create_self_node(struct list_head *self_node_db,
 	return 0;
 }
 
-
 /* Allocate an hsr_node and add it to node_db. 'addr' is the node's AddressA;
  * seq_out is used to initialize filtering of outgoing duplicate frames
  * originating from the newly added node.
@@ -140,7 +135,7 @@ struct hsr_node *hsr_add_node(struct list_head *node_db, unsigned char addr[],
 	if (!node)
 		return NULL;
 
-	ether_addr_copy(node->MacAddressA, addr);
+	ether_addr_copy(node->mac_address_A, addr);
 
 	/* We are only interested in time diffs here, so use current jiffies
 	 * as initialization. (0 could trigger an spurious ring error warning).
@@ -169,19 +164,19 @@ struct hsr_node *hsr_get_node(struct hsr_port *port, struct sk_buff *skb,
 	if (!skb_mac_header_was_set(skb))
 		return NULL;
 
-	ethhdr = (struct ethhdr *) skb_mac_header(skb);
+	ethhdr = (struct ethhdr *)skb_mac_header(skb);
 
 	list_for_each_entry_rcu(node, node_db, mac_list) {
-		if (ether_addr_equal(node->MacAddressA, ethhdr->h_source))
+		if (ether_addr_equal(node->mac_address_A, ethhdr->h_source))
 			return node;
-		if (ether_addr_equal(node->MacAddressB, ethhdr->h_source))
+		if (ether_addr_equal(node->mac_address_B, ethhdr->h_source))
 			return node;
 	}
 
 	/* Everyone may create a node entry, connected node to a HSR device. */
 
-	if (ethhdr->h_proto == htons(ETH_P_PRP)
-			|| ethhdr->h_proto == htons(ETH_P_HSR)) {
+	if (ethhdr->h_proto == htons(ETH_P_PRP) ||
+	    ethhdr->h_proto == htons(ETH_P_HSR)) {
 		/* Use the existing sequence_nr from the tag as starting point
 		 * for filtering duplicate frames.
 		 */
@@ -198,8 +193,8 @@ struct hsr_node *hsr_get_node(struct hsr_port *port, struct sk_buff *skb,
 	return hsr_add_node(node_db, ethhdr->h_source, seq_out);
 }
 
-/* Use the Supervision frame's info about an eventual MacAddressB for merging
- * nodes that has previously had their MacAddressB registered as a separate
+/* Use the Supervision frame's info about an eventual mac_address_B for merging
+ * nodes that has previously had their mac_address_B registered as a separate
  * node.
  */
 void hsr_handle_sup_frame(struct sk_buff *skb, struct hsr_node *node_curr,
@@ -211,7 +206,7 @@ void hsr_handle_sup_frame(struct sk_buff *skb, struct hsr_node *node_curr,
 	struct list_head *node_db;
 	int i;
 
-	ethhdr = (struct ethhdr *) skb_mac_header(skb);
+	ethhdr = (struct ethhdr *)skb_mac_header(skb);
 
 	/* Leave the ethernet header. */
 	skb_pull(skb, sizeof(struct ethhdr));
@@ -223,14 +218,14 @@ void hsr_handle_sup_frame(struct sk_buff *skb, struct hsr_node *node_curr,
 	/* And leave the HSR sup tag. */
 	skb_pull(skb, sizeof(struct hsr_sup_tag));
 
-	hsr_sp = (struct hsr_sup_payload *) skb->data;
+	hsr_sp = (struct hsr_sup_payload *)skb->data;
 
-	/* Merge node_curr (registered on MacAddressB) into node_real */
+	/* Merge node_curr (registered on mac_address_B) into node_real */
 	node_db = &port_rcv->hsr->node_db;
-	node_real = find_node_by_AddrA(node_db, hsr_sp->MacAddressA);
+	node_real = find_node_by_addr_A(node_db, hsr_sp->mac_address_A);
 	if (!node_real)
 		/* No frame received from AddrA of this node yet */
-		node_real = hsr_add_node(node_db, hsr_sp->MacAddressA,
+		node_real = hsr_add_node(node_db, hsr_sp->mac_address_A,
 					 HSR_SEQNR_START - 1);
 	if (!node_real)
 		goto done; /* No mem */
@@ -238,17 +233,18 @@ void hsr_handle_sup_frame(struct sk_buff *skb, struct hsr_node *node_curr,
 		/* Node has already been merged */
 		goto done;
 
-	ether_addr_copy(node_real->MacAddressB, ethhdr->h_source);
+	ether_addr_copy(node_real->mac_address_B, ethhdr->h_source);
 	for (i = 0; i < HSR_PT_PORTS; i++) {
 		if (!node_curr->time_in_stale[i] &&
 		    time_after(node_curr->time_in[i], node_real->time_in[i])) {
 			node_real->time_in[i] = node_curr->time_in[i];
-			node_real->time_in_stale[i] = node_curr->time_in_stale[i];
+			node_real->time_in_stale[i] =
+				node_curr->time_in_stale[i];
 		}
 		if (seq_nr_after(node_curr->seq_out[i], node_real->seq_out[i]))
 			node_real->seq_out[i] = node_curr->seq_out[i];
 	}
-	node_real->AddrB_port = port_rcv->type;
+	node_real->addr_B_port = port_rcv->type;
 
 	list_del_rcu(&node_curr->mac_list);
 	kfree_rcu(node_curr, rcu_head);
@@ -257,11 +253,10 @@ void hsr_handle_sup_frame(struct sk_buff *skb, struct hsr_node *node_curr,
 	skb_push(skb, sizeof(struct hsrv1_ethhdr_sp));
 }
 
-
 /* 'skb' is a frame meant for this host, that is to be passed to upper layers.
  *
  * If the frame was sent by a node's B interface, replace the source
- * address with that node's "official" address (MacAddressA) so that upper
+ * address with that node's "official" address (mac_address_A) so that upper
  * layers recognize where it came from.
  */
 void hsr_addr_subst_source(struct hsr_node *node, struct sk_buff *skb)
@@ -271,7 +266,7 @@ void hsr_addr_subst_source(struct hsr_node *node, struct sk_buff *skb)
 		return;
 	}
 
-	memcpy(&eth_hdr(skb)->h_source, node->MacAddressA, ETH_ALEN);
+	memcpy(&eth_hdr(skb)->h_source, node->mac_address_A, ETH_ALEN);
 }
 
 /* 'skb' is a frame meant for another host.
@@ -296,18 +291,18 @@ void hsr_addr_subst_dest(struct hsr_node *node_src, struct sk_buff *skb,
 	if (!is_unicast_ether_addr(eth_hdr(skb)->h_dest))
 		return;
 
-	node_dst = find_node_by_AddrA(&port->hsr->node_db, eth_hdr(skb)->h_dest);
+	node_dst = find_node_by_addr_A(&port->hsr->node_db,
+				       eth_hdr(skb)->h_dest);
 	if (!node_dst) {
 		WARN_ONCE(1, "%s: Unknown node\n", __func__);
 		return;
 	}
-	if (port->type != node_dst->AddrB_port)
+	if (port->type != node_dst->addr_B_port)
 		return;
 
-	ether_addr_copy(eth_hdr(skb)->h_dest, node_dst->MacAddressB);
+	ether_addr_copy(eth_hdr(skb)->h_dest, node_dst->mac_address_B);
 }
 
-
 void hsr_register_frame_in(struct hsr_node *node, struct hsr_port *port,
 			   u16 sequence_nr)
 {
@@ -340,7 +335,6 @@ int hsr_register_frame_out(struct hsr_port *port, struct hsr_node *node,
 	return 0;
 }
 
-
 static struct hsr_port *get_late_port(struct hsr_priv *hsr,
 				      struct hsr_node *node)
 {
@@ -361,7 +355,6 @@ static struct hsr_port *get_late_port(struct hsr_priv *hsr,
 	return NULL;
 }
 
-
 /* Remove stale sequence_nr records. Called by timer every
  * HSR_LIFE_CHECK_INTERVAL (two seconds or so).
  */
@@ -373,7 +366,7 @@ void hsr_prune_nodes(unsigned long data)
 	unsigned long timestamp;
 	unsigned long time_a, time_b;
 
-	hsr = (struct hsr_priv *) data;
+	hsr = (struct hsr_priv *)data;
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(node, &hsr->node_db, mac_list) {
@@ -382,9 +375,9 @@ void hsr_prune_nodes(unsigned long data)
 		time_b = node->time_in[HSR_PT_SLAVE_B];
 
 		/* Check for timestamps old enough to risk wrap-around */
-		if (time_after(jiffies, time_a + MAX_JIFFY_OFFSET/2))
+		if (time_after(jiffies, time_a + MAX_JIFFY_OFFSET / 2))
 			node->time_in_stale[HSR_PT_SLAVE_A] = true;
-		if (time_after(jiffies, time_b + MAX_JIFFY_OFFSET/2))
+		if (time_after(jiffies, time_b + MAX_JIFFY_OFFSET / 2))
 			node->time_in_stale[HSR_PT_SLAVE_B] = true;
 
 		/* Get age of newest frame from node.
@@ -399,18 +392,19 @@ void hsr_prune_nodes(unsigned long data)
 
 		/* Warn of ring error only as long as we get frames at all */
 		if (time_is_after_jiffies(timestamp +
-					msecs_to_jiffies(1.5*MAX_SLAVE_DIFF))) {
+				msecs_to_jiffies(1.5 * MAX_SLAVE_DIFF))) {
 			rcu_read_lock();
 			port = get_late_port(hsr, node);
-			if (port != NULL)
-				hsr_nl_ringerror(hsr, node->MacAddressA, port);
+			if (port)
+				hsr_nl_ringerror(hsr, node->mac_address_A,
+						 port);
 			rcu_read_unlock();
 		}
 
 		/* Prune old entries */
 		if (time_is_before_jiffies(timestamp +
-					msecs_to_jiffies(HSR_NODE_FORGET_TIME))) {
-			hsr_nl_nodedown(hsr, node->MacAddressA);
+				msecs_to_jiffies(HSR_NODE_FORGET_TIME))) {
+			hsr_nl_nodedown(hsr, node->mac_address_A);
 			list_del_rcu(&node->mac_list);
 			/* Note that we need to free this entry later: */
 			kfree_rcu(node, rcu_head);
@@ -419,7 +413,6 @@ void hsr_prune_nodes(unsigned long data)
 	rcu_read_unlock();
 }
 
-
 void *hsr_get_next_node(struct hsr_priv *hsr, void *_pos,
 			unsigned char addr[ETH_ALEN])
 {
@@ -429,20 +422,19 @@ void *hsr_get_next_node(struct hsr_priv *hsr, void *_pos,
 		node = list_first_or_null_rcu(&hsr->node_db,
 					      struct hsr_node, mac_list);
 		if (node)
-			ether_addr_copy(addr, node->MacAddressA);
+			ether_addr_copy(addr, node->mac_address_A);
 		return node;
 	}
 
 	node = _pos;
 	list_for_each_entry_continue_rcu(node, &hsr->node_db, mac_list) {
-		ether_addr_copy(addr, node->MacAddressA);
+		ether_addr_copy(addr, node->mac_address_A);
 		return node;
 	}
 
 	return NULL;
 }
 
-
 int hsr_get_node_data(struct hsr_priv *hsr,
 		      const unsigned char *addr,
 		      unsigned char addr_b[ETH_ALEN],
@@ -456,15 +448,14 @@ int hsr_get_node_data(struct hsr_priv *hsr,
 	struct hsr_port *port;
 	unsigned long tdiff;
 
-
 	rcu_read_lock();
-	node = find_node_by_AddrA(&hsr->node_db, addr);
+	node = find_node_by_addr_A(&hsr->node_db, addr);
 	if (!node) {
 		rcu_read_unlock();
 		return -ENOENT;	/* No such entry */
 	}
 
-	ether_addr_copy(addr_b, node->MacAddressB);
+	ether_addr_copy(addr_b, node->mac_address_B);
 
 	tdiff = jiffies - node->time_in[HSR_PT_SLAVE_A];
 	if (node->time_in_stale[HSR_PT_SLAVE_A])
@@ -490,8 +481,8 @@ int hsr_get_node_data(struct hsr_priv *hsr,
 	*if1_seq = node->seq_out[HSR_PT_SLAVE_B];
 	*if2_seq = node->seq_out[HSR_PT_SLAVE_A];
 
-	if (node->AddrB_port != HSR_PT_NONE) {
-		port = hsr_port_get_hsr(hsr, node->AddrB_port);
+	if (node->addr_B_port != HSR_PT_NONE) {
+		port = hsr_port_get_hsr(hsr, node->addr_B_port);
 		*addr_b_ifindex = port->dev->ifindex;
 	} else {
 		*addr_b_ifindex = -1;
diff --git a/net/hsr/hsr_main.c b/net/hsr/hsr_main.c
index cd37d00..84cacf8 100644
--- a/net/hsr/hsr_main.c
+++ b/net/hsr/hsr_main.c
@@ -19,7 +19,6 @@
 #include "hsr_framereg.h"
 #include "hsr_slave.h"
 
-
 static int hsr_netdev_notify(struct notifier_block *nb, unsigned long event,
 			     void *ptr)
 {
@@ -31,12 +30,12 @@ static int hsr_netdev_notify(struct notifier_block *nb, unsigned long event,
 
 	dev = netdev_notifier_info_to_dev(ptr);
 	port = hsr_port_get_rtnl(dev);
-	if (port == NULL) {
+	if (!port) {
 		if (!is_hsr_master(dev))
 			return NOTIFY_DONE;	/* Not an HSR device */
 		hsr = netdev_priv(dev);
 		port = hsr_port_get_hsr(hsr, HSR_PT_MASTER);
-		if (port == NULL) {
+		if (!port) {
 			/* Resend of notification concerning removed device? */
 			return NOTIFY_DONE;
 		}
@@ -63,7 +62,8 @@ static int hsr_netdev_notify(struct notifier_block *nb, unsigned long event,
 
 		if (port->type == HSR_PT_SLAVE_A) {
 			ether_addr_copy(master->dev->dev_addr, dev->dev_addr);
-			call_netdevice_notifiers(NETDEV_CHANGEADDR, master->dev);
+			call_netdevice_notifiers(NETDEV_CHANGEADDR,
+						 master->dev);
 		}
 
 		/* Make sure we recognize frames from ourselves in hsr_rcv() */
@@ -97,7 +97,6 @@ static int hsr_netdev_notify(struct notifier_block *nb, unsigned long event,
 	return NOTIFY_DONE;
 }
 
-
 struct hsr_port *hsr_port_get_hsr(struct hsr_priv *hsr, enum hsr_port_type pt)
 {
 	struct hsr_port *port;
@@ -112,7 +111,6 @@ struct hsr_port *hsr_port_get_hsr(struct hsr_priv *hsr, enum hsr_port_type pt)
 	.notifier_call = hsr_netdev_notify,	/* Slave event notifications */
 };
 
-
 static int __init hsr_init(void)
 {
 	int res;
diff --git a/net/hsr/hsr_main.h b/net/hsr/hsr_main.h
index 9b9909e8..d1adbaf 100644
--- a/net/hsr/hsr_main.h
+++ b/net/hsr/hsr_main.h
@@ -15,7 +15,6 @@
 #include <linux/netdevice.h>
 #include <linux/list.h>
 
-
 /* Time constants as specified in the HSR specification (IEC-62439-3 2010)
  * Table 8.
  * All values in milliseconds.
@@ -24,7 +23,6 @@
 #define HSR_NODE_FORGET_TIME		60000 /* ms */
 #define HSR_ANNOUNCE_INTERVAL		  100 /* ms */
 
-
 /* By how much may slave1 and slave2 timestamps of latest received frame from
  * each node differ before we notify of communication problem?
  */
@@ -32,17 +30,14 @@
 #define HSR_SEQNR_START			(USHRT_MAX - 1024)
 #define HSR_SUP_SEQNR_START		(HSR_SEQNR_START / 2)
 
-
 /* How often shall we check for broken ring and remove node entries older than
  * HSR_NODE_FORGET_TIME?
  */
 #define PRUNE_PERIOD			 3000 /* ms */
 
-
 #define HSR_TLV_ANNOUNCE		   22
 #define HSR_TLV_LIFE_CHECK		   23
 
-
 /* HSR Tag.
  * As defined in IEC-62439-3:2010, the HSR tag is really { ethertype = 0x88FB,
  * path, LSDU_size, sequence Nr }. But we let eth_header() create { h_dest,
@@ -84,7 +79,8 @@ static inline u16 get_hsr_tag_LSDU_size(struct hsr_tag *ht)
 static inline void set_hsr_tag_path(struct hsr_tag *ht, u16 path)
 {
 	ht->path_and_LSDU_size = htons(
-			(ntohs(ht->path_and_LSDU_size) & 0x0FFF) | (path << 12));
+			(ntohs(ht->path_and_LSDU_size) & 0x0FFF) |
+			(path << 12));
 }
 
 static inline void set_hsr_tag_LSDU_size(struct hsr_tag *ht, u16 LSDU_size)
@@ -99,39 +95,38 @@ struct hsr_ethhdr {
 	struct hsr_tag	hsr_tag;
 } __packed;
 
-
 /* HSR Supervision Frame data types.
  * Field names as defined in the IEC:2010 standard for HSR.
  */
 struct hsr_sup_tag {
-	__be16		path_and_HSR_Ver;
+	__be16		path_and_HSR_ver;
 	__be16		sequence_nr;
-	__u8		HSR_TLV_Type;
-	__u8		HSR_TLV_Length;
+	__u8		HSR_TLV_type;
+	__u8		HSR_TLV_length;
 } __packed;
 
 struct hsr_sup_payload {
-	unsigned char	MacAddressA[ETH_ALEN];
+	unsigned char	mac_address_A[ETH_ALEN];
 } __packed;
 
 static inline u16 get_hsr_stag_path(struct hsr_sup_tag *hst)
 {
-	return get_hsr_tag_path((struct hsr_tag *) hst);
+	return get_hsr_tag_path((struct hsr_tag *)hst);
 }
 
 static inline u16 get_hsr_stag_HSR_ver(struct hsr_sup_tag *hst)
 {
-	return get_hsr_tag_LSDU_size((struct hsr_tag *) hst);
+	return get_hsr_tag_LSDU_size((struct hsr_tag *)hst);
 }
 
 static inline void set_hsr_stag_path(struct hsr_sup_tag *hst, u16 path)
 {
-	set_hsr_tag_path((struct hsr_tag *) hst, path);
+	set_hsr_tag_path((struct hsr_tag *)hst, path);
 }
 
-static inline void set_hsr_stag_HSR_Ver(struct hsr_sup_tag *hst, u16 HSR_Ver)
+static inline void set_hsr_stag_HSR_ver(struct hsr_sup_tag *hst, u16 HSR_ver)
 {
-	set_hsr_tag_LSDU_size((struct hsr_tag *) hst, HSR_Ver);
+	set_hsr_tag_LSDU_size((struct hsr_tag *)hst, HSR_ver);
 }
 
 struct hsrv0_ethhdr_sp {
@@ -145,7 +140,6 @@ struct hsrv1_ethhdr_sp {
 	struct hsr_sup_tag	hsr_sup;
 } __packed;
 
-
 enum hsr_port_type {
 	HSR_PT_NONE = 0,	/* Must be 0, used by framereg */
 	HSR_PT_SLAVE_A,
@@ -171,9 +165,9 @@ struct hsr_priv {
 	struct timer_list	prune_timer;
 	int announce_count;
 	u16 sequence_nr;
-	u16 sup_sequence_nr;			/* For HSRv1 separate seq_nr for supervision */
-	u8 protVersion;					/* Indicate if HSRv0 or HSRv1. */
-	spinlock_t seqnr_lock;			/* locking for sequence_nr */
+	u16 sup_sequence_nr;	/* For HSRv1 separate seq_nr for supervision */
+	u8 prot_version;	/* Indicate if HSRv0 or HSRv1. */
+	spinlock_t seqnr_lock;	/* locking for sequence_nr */
 	unsigned char		sup_multicast_addr[ETH_ALEN];
 };
 
@@ -187,7 +181,7 @@ static inline u16 hsr_get_skb_sequence_nr(struct sk_buff *skb)
 {
 	struct hsr_ethhdr *hsr_ethhdr;
 
-	hsr_ethhdr = (struct hsr_ethhdr *) skb_mac_header(skb);
+	hsr_ethhdr = (struct hsr_ethhdr *)skb_mac_header(skb);
 	return ntohs(hsr_ethhdr->hsr_tag.sequence_nr);
 }
 
diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
index 81dac16..242c6ec 100644
--- a/net/hsr/hsr_netlink.c
+++ b/net/hsr/hsr_netlink.c
@@ -28,7 +28,6 @@
 	[IFLA_HSR_SEQ_NR]		= { .type = NLA_U16 },
 };
 
-
 /* Here, it seems a netdevice has already been allocated for us, and the
  * hsr_dev_setup routine has been executed. Nice!
  */
@@ -46,12 +45,14 @@ static int hsr_newlink(struct net *src_net, struct net_device *dev,
 		netdev_info(dev, "HSR: Slave1 device not specified\n");
 		return -EINVAL;
 	}
-	link[0] = __dev_get_by_index(src_net, nla_get_u32(data[IFLA_HSR_SLAVE1]));
+	link[0] = __dev_get_by_index(src_net,
+				     nla_get_u32(data[IFLA_HSR_SLAVE1]));
 	if (!data[IFLA_HSR_SLAVE2]) {
 		netdev_info(dev, "HSR: Slave2 device not specified\n");
 		return -EINVAL;
 	}
-	link[1] = __dev_get_by_index(src_net, nla_get_u32(data[IFLA_HSR_SLAVE2]));
+	link[1] = __dev_get_by_index(src_net,
+				     nla_get_u32(data[IFLA_HSR_SLAVE2]));
 
 	if (!link[0] || !link[1])
 		return -ENODEV;
@@ -118,8 +119,6 @@ static int hsr_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	.fill_info	= hsr_fill_info,
 };
 
-
-
 /* attribute policy */
 static const struct nla_policy hsr_genl_policy[HSR_A_MAX + 1] = {
 	[HSR_A_NODE_ADDR] = { .len = ETH_ALEN },
@@ -137,8 +136,6 @@ static int hsr_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	{ .name = "hsr-network", },
 };
 
-
-
 /* This is called if for some node with MAC address addr, we only get frames
  * over one of the slave interfaces. This would indicate an open network ring
  * (i.e. a link has failed somewhere).
@@ -155,7 +152,8 @@ void hsr_nl_ringerror(struct hsr_priv *hsr, unsigned char addr[ETH_ALEN],
 	if (!skb)
 		goto fail;
 
-	msg_head = genlmsg_put(skb, 0, 0, &hsr_genl_family, 0, HSR_C_RING_ERROR);
+	msg_head = genlmsg_put(skb,
+			       0, 0, &hsr_genl_family, 0, HSR_C_RING_ERROR);
 	if (!msg_head)
 		goto nla_put_failure;
 
@@ -200,7 +198,6 @@ void hsr_nl_nodedown(struct hsr_priv *hsr, unsigned char addr[ETH_ALEN])
 	if (!msg_head)
 		goto nla_put_failure;
 
-
 	res = nla_put(skb, HSR_A_NODE_ADDR, ETH_ALEN, addr);
 	if (res < 0)
 		goto nla_put_failure;
@@ -220,7 +217,6 @@ void hsr_nl_nodedown(struct hsr_priv *hsr, unsigned char addr[ETH_ALEN])
 	rcu_read_unlock();
 }
 
-
 /* HSR_C_GET_NODE_STATUS lets userspace query the internal HSR node table
  * about the status of a specific node in the network, defined by its MAC
  * address.
@@ -259,15 +255,13 @@ static int hsr_get_node_status(struct sk_buff *skb_in, struct genl_info *info)
 		goto invalid;
 
 	hsr_dev = __dev_get_by_index(genl_info_net(info),
-					nla_get_u32(info->attrs[HSR_A_IFINDEX]));
+				     nla_get_u32(info->attrs[HSR_A_IFINDEX]));
 	if (!hsr_dev)
 		goto invalid;
 	if (!is_hsr_master(hsr_dev))
 		goto invalid;
 
-
 	/* Send reply */
-
 	skb_out = genlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!skb_out) {
 		res = -ENOMEM;
@@ -275,8 +269,8 @@ static int hsr_get_node_status(struct sk_buff *skb_in, struct genl_info *info)
 	}
 
 	msg_head = genlmsg_put(skb_out, NETLINK_CB(skb_in).portid,
-				info->snd_seq, &hsr_genl_family, 0,
-				HSR_C_SET_NODE_STATUS);
+			       info->snd_seq, &hsr_genl_family, 0,
+			       HSR_C_SET_NODE_STATUS);
 	if (!msg_head) {
 		res = -ENOMEM;
 		goto nla_put_failure;
@@ -288,28 +282,30 @@ static int hsr_get_node_status(struct sk_buff *skb_in, struct genl_info *info)
 
 	hsr = netdev_priv(hsr_dev);
 	res = hsr_get_node_data(hsr,
-			(unsigned char *) nla_data(info->attrs[HSR_A_NODE_ADDR]),
-			hsr_node_addr_b,
-			&addr_b_ifindex,
-			&hsr_node_if1_age,
-			&hsr_node_if1_seq,
-			&hsr_node_if2_age,
-			&hsr_node_if2_seq);
+				(unsigned char *)
+				nla_data(info->attrs[HSR_A_NODE_ADDR]),
+				hsr_node_addr_b,
+				&addr_b_ifindex,
+				&hsr_node_if1_age,
+				&hsr_node_if1_seq,
+				&hsr_node_if2_age,
+				&hsr_node_if2_seq);
 	if (res < 0)
 		goto nla_put_failure;
 
 	res = nla_put(skb_out, HSR_A_NODE_ADDR, ETH_ALEN,
-					nla_data(info->attrs[HSR_A_NODE_ADDR]));
+		      nla_data(info->attrs[HSR_A_NODE_ADDR]));
 	if (res < 0)
 		goto nla_put_failure;
 
 	if (addr_b_ifindex > -1) {
 		res = nla_put(skb_out, HSR_A_NODE_ADDR_B, ETH_ALEN,
-								hsr_node_addr_b);
+			      hsr_node_addr_b);
 		if (res < 0)
 			goto nla_put_failure;
 
-		res = nla_put_u32(skb_out, HSR_A_ADDR_B_IFINDEX, addr_b_ifindex);
+		res = nla_put_u32(skb_out, HSR_A_ADDR_B_IFINDEX,
+				  addr_b_ifindex);
 		if (res < 0)
 			goto nla_put_failure;
 	}
@@ -361,7 +357,7 @@ static int hsr_get_node_status(struct sk_buff *skb_in, struct genl_info *info)
 	return res;
 }
 
-/* Get a list of MacAddressA of all nodes known to this node (including self).
+/* Get a list of mac_address_A of all nodes known to this node (including self).
  */
 static int hsr_get_node_list(struct sk_buff *skb_in, struct genl_info *info)
 {
@@ -391,9 +387,7 @@ static int hsr_get_node_list(struct sk_buff *skb_in, struct genl_info *info)
 	if (!is_hsr_master(hsr_dev))
 		goto invalid;
 
-
 	/* Send reply */
-
 	skb_out = genlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!skb_out) {
 		res = -ENOMEM;
@@ -401,8 +395,8 @@ static int hsr_get_node_list(struct sk_buff *skb_in, struct genl_info *info)
 	}
 
 	msg_head = genlmsg_put(skb_out, NETLINK_CB(skb_in).portid,
-				info->snd_seq, &hsr_genl_family, 0,
-				HSR_C_SET_NODE_LIST);
+			       info->snd_seq, &hsr_genl_family, 0,
+			       HSR_C_SET_NODE_LIST);
 	if (!msg_head) {
 		res = -ENOMEM;
 		goto nla_put_failure;
@@ -443,7 +437,6 @@ static int hsr_get_node_list(struct sk_buff *skb_in, struct genl_info *info)
 	return res;
 }
 
-
 static const struct genl_ops hsr_ops[] = {
 	{
 		.cmd = HSR_C_GET_NODE_STATUS,
diff --git a/net/hsr/hsr_slave.c b/net/hsr/hsr_slave.c
index 56080da..0cf7870 100644
--- a/net/hsr/hsr_slave.c
+++ b/net/hsr/hsr_slave.c
@@ -18,7 +18,6 @@
 #include "hsr_forward.h"
 #include "hsr_framereg.h"
 
-
 static rx_handler_result_t hsr_handle_frame(struct sk_buff **pskb)
 {
 	struct sk_buff *skb = *pskb;
@@ -61,7 +60,6 @@ bool hsr_port_exists(const struct net_device *dev)
 	return rcu_access_pointer(dev->rx_handler) == hsr_handle_frame;
 }
 
-
 static int hsr_check_dev_ok(struct net_device *dev)
 {
 	/* Don't allow HSR on non-ethernet like devices */
@@ -99,7 +97,6 @@ static int hsr_check_dev_ok(struct net_device *dev)
 	return 0;
 }
 
-
 /* Setup device to be added to the HSR bridge. */
 static int hsr_portdev_setup(struct net_device *dev, struct hsr_port *port)
 {
@@ -143,11 +140,11 @@ int hsr_add_port(struct hsr_priv *hsr, struct net_device *dev,
 	}
 
 	port = hsr_port_get_hsr(hsr, type);
-	if (port != NULL)
+	if (port)
 		return -EBUSY;	/* This port already exists */
 
 	port = kzalloc(sizeof(*port), GFP_KERNEL);
-	if (port == NULL)
+	if (!port)
 		return -ENOMEM;
 
 	if (type != HSR_PT_MASTER) {
@@ -184,7 +181,7 @@ void hsr_del_port(struct hsr_port *port)
 	list_del_rcu(&port->port_list);
 
 	if (port != master) {
-		if (master != NULL) {
+		if (master) {
 			netdev_update_features(master->dev);
 			dev_set_mtu(master->dev, hsr_get_max_mtu(hsr));
 		}
-- 
1.9.1
