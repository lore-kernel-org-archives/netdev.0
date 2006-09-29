From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 1/8][ATM]: [lec] indent, comment and whitespace cleanup
Date: Fri, 29 Sep 2006 12:37:26 -0400
Message-ID: <200609291637.k8TGbQj6025493@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:43484 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S1161198AbWI2QiO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 12:38:14 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.19 -- thanks!

[ATM]: [lec] indent, comment and whitespace cleanup

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

---
commit e2ba85c2acb966a41127dbb72c37f91e82a0725a
tree c8d99c54d7a4d993dfbb4bf8e34689fda93f07d9
parent 888454c57a45511808d3fa52597b3d765df034a6
author chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Wed, 20 Sep 2006 18:17:28 -0400
committer chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Wed, 20 Sep 2006 18:17:28 -0400

 net/atm/lec.c | 1407 +++++++++++++++++++++++++++++----------------------------
 1 files changed, 715 insertions(+), 692 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index b4aa489..c981dbf 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -1,7 +1,7 @@
 /*
  * lec.c: Lan Emulation driver 
- * Marko Kiiskila mkiiskila@yahoo.com
  *
+ * Marko Kiiskila <mkiiskila@yahoo.com>
  */
 
 #include <linux/kernel.h>
@@ -38,7 +38,7 @@ #if defined(CONFIG_BRIDGE) || defined(CO
 #include <linux/if_bridge.h>
 #include "../bridge/br_private.h"
 
-static unsigned char bridge_ula_lec[] = {0x01, 0x80, 0xc2, 0x00, 0x00};
+static unsigned char bridge_ula_lec[] = { 0x01, 0x80, 0xc2, 0x00, 0x00 };
 #endif
 
 /* Modular too */
@@ -55,38 +55,41 @@ #else
 #define DPRINTK(format,args...)
 #endif
 
-#define DUMP_PACKETS 0 /* 0 = None,
-                        * 1 = 30 first bytes
-                        * 2 = Whole packet
-                        */
+#define DUMP_PACKETS 0		/*
+				 * 0 = None,
+				 * 1 = 30 first bytes
+				 * 2 = Whole packet
+				 */
 
-#define LEC_UNRES_QUE_LEN 8 /* number of tx packets to queue for a
-                               single destination while waiting for SVC */
+#define LEC_UNRES_QUE_LEN 8	/*
+				 * number of tx packets to queue for a
+				 * single destination while waiting for SVC
+				 */
 
 static int lec_open(struct net_device *dev);
 static int lec_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static int lec_close(struct net_device *dev);
 static struct net_device_stats *lec_get_stats(struct net_device *dev);
 static void lec_init(struct net_device *dev);
-static struct lec_arp_table* lec_arp_find(struct lec_priv *priv,
-                                                     unsigned char *mac_addr);
+static struct lec_arp_table *lec_arp_find(struct lec_priv *priv,
+					  unsigned char *mac_addr);
 static int lec_arp_remove(struct lec_priv *priv,
-				     struct lec_arp_table *to_remove);
+			  struct lec_arp_table *to_remove);
 /* LANE2 functions */
-static void lane2_associate_ind (struct net_device *dev, u8 *mac_address,
-                          u8 *tlvs, u32 sizeoftlvs);
+static void lane2_associate_ind(struct net_device *dev, u8 *mac_address,
+				u8 *tlvs, u32 sizeoftlvs);
 static int lane2_resolve(struct net_device *dev, u8 *dst_mac, int force,
-                  u8 **tlvs, u32 *sizeoftlvs);
-static int lane2_associate_req (struct net_device *dev, u8 *lan_dst,
-                         u8 *tlvs, u32 sizeoftlvs);
+			 u8 **tlvs, u32 *sizeoftlvs);
+static int lane2_associate_req(struct net_device *dev, u8 *lan_dst,
+			       u8 *tlvs, u32 sizeoftlvs);
 
-static int lec_addr_delete(struct lec_priv *priv, unsigned char *atm_addr, 
+static int lec_addr_delete(struct lec_priv *priv, unsigned char *atm_addr,
 			   unsigned long permanent);
 static void lec_arp_check_empties(struct lec_priv *priv,
 				  struct atm_vcc *vcc, struct sk_buff *skb);
 static void lec_arp_destroy(struct lec_priv *priv);
 static void lec_arp_init(struct lec_priv *priv);
-static struct atm_vcc* lec_arp_resolve(struct lec_priv *priv,
+static struct atm_vcc *lec_arp_resolve(struct lec_priv *priv,
 				       unsigned char *mac_to_find,
 				       int is_rdesc,
 				       struct lec_arp_table **ret_entry);
@@ -100,16 +103,17 @@ static void lec_set_flush_tran_id(struct
 				  unsigned long tran_id);
 static void lec_vcc_added(struct lec_priv *priv, struct atmlec_ioc *ioc_data,
 			  struct atm_vcc *vcc,
-			  void (*old_push)(struct atm_vcc *vcc, struct sk_buff *skb));
+			  void (*old_push) (struct atm_vcc *vcc,
+					    struct sk_buff *skb));
 static void lec_vcc_close(struct lec_priv *priv, struct atm_vcc *vcc);
 
 static struct lane2_ops lane2_ops = {
-	lane2_resolve,         /* resolve,             spec 3.1.3 */
-	lane2_associate_req,   /* associate_req,       spec 3.1.4 */
-	NULL                  /* associate indicator, spec 3.1.5 */
+	lane2_resolve,		/* resolve,             spec 3.1.3 */
+	lane2_associate_req,	/* associate_req,       spec 3.1.4 */
+	NULL			/* associate indicator, spec 3.1.5 */
 };
 
-static unsigned char bus_mac[ETH_ALEN] = {0xff,0xff,0xff,0xff,0xff,0xff};
+static unsigned char bus_mac[ETH_ALEN] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
 
 /* Device structures */
 static struct net_device *dev_lec[MAX_LEC_ITF];
@@ -117,36 +121,39 @@ static struct net_device *dev_lec[MAX_LE
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
 static void lec_handle_bridge(struct sk_buff *skb, struct net_device *dev)
 {
-        struct ethhdr *eth;
-        char *buff;
-        struct lec_priv *priv;
-
-        /* Check if this is a BPDU. If so, ask zeppelin to send
-         * LE_TOPOLOGY_REQUEST with the same value of Topology Change bit
-         * as the Config BPDU has */
-        eth = (struct ethhdr *)skb->data;
-        buff = skb->data + skb->dev->hard_header_len;
-        if (*buff++ == 0x42 && *buff++ == 0x42 && *buff++ == 0x03) {
+	struct ethhdr *eth;
+	char *buff;
+	struct lec_priv *priv;
+
+	/*
+	 * Check if this is a BPDU. If so, ask zeppelin to send
+	 * LE_TOPOLOGY_REQUEST with the same value of Topology Change bit
+	 * as the Config BPDU has
+	 */
+	eth = (struct ethhdr *)skb->data;
+	buff = skb->data + skb->dev->hard_header_len;
+	if (*buff++ == 0x42 && *buff++ == 0x42 && *buff++ == 0x03) {
 		struct sock *sk;
-                struct sk_buff *skb2;
-                struct atmlec_msg *mesg;
-
-                skb2 = alloc_skb(sizeof(struct atmlec_msg), GFP_ATOMIC);
-                if (skb2 == NULL) return;
-                skb2->len = sizeof(struct atmlec_msg);
-                mesg = (struct atmlec_msg *)skb2->data;
-                mesg->type = l_topology_change;
-                buff += 4;
-                mesg->content.normal.flag = *buff & 0x01; /* 0x01 is topology change */
-
-                priv = (struct lec_priv *)dev->priv;
-                atm_force_charge(priv->lecd, skb2->truesize);
+		struct sk_buff *skb2;
+		struct atmlec_msg *mesg;
+
+		skb2 = alloc_skb(sizeof(struct atmlec_msg), GFP_ATOMIC);
+		if (skb2 == NULL)
+			return;
+		skb2->len = sizeof(struct atmlec_msg);
+		mesg = (struct atmlec_msg *)skb2->data;
+		mesg->type = l_topology_change;
+		buff += 4;
+		mesg->content.normal.flag = *buff & 0x01;	/* 0x01 is topology change */
+
+		priv = (struct lec_priv *)dev->priv;
+		atm_force_charge(priv->lecd, skb2->truesize);
 		sk = sk_atm(priv->lecd);
-                skb_queue_tail(&sk->sk_receive_queue, skb2);
-                sk->sk_data_ready(sk, skb2->len);
-        }
+		skb_queue_tail(&sk->sk_receive_queue, skb2);
+		sk->sk_data_ready(sk, skb2->len);
+	}
 
-        return;
+	return;
 }
 #endif /* defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE) */
 
@@ -162,36 +169,35 @@ #endif /* defined(CONFIG_BRIDGE) || defi
 #ifdef CONFIG_TR
 static unsigned char *get_tr_dst(unsigned char *packet, unsigned char *rdesc)
 {
-        struct trh_hdr *trh;
-        int riflen, num_rdsc;
-        
-        trh = (struct trh_hdr *)packet;
-        if (trh->daddr[0] & (uint8_t)0x80)
-                return bus_mac; /* multicast */
-
-        if (trh->saddr[0] & TR_RII) {
-                riflen = (ntohs(trh->rcf) & TR_RCF_LEN_MASK) >> 8;
-                if ((ntohs(trh->rcf) >> 13) != 0)
-                        return bus_mac; /* ARE or STE */
-        }
-        else
-                return trh->daddr; /* not source routed */
-
-        if (riflen < 6)
-                return trh->daddr; /* last hop, source routed */
-                
-        /* riflen is 6 or more, packet has more than one route descriptor */
-        num_rdsc = (riflen/2) - 1;
-        memset(rdesc, 0, ETH_ALEN);
-        /* offset 4 comes from LAN destination field in LE control frames */
-        if (trh->rcf & htons((uint16_t)TR_RCF_DIR_BIT))
-                memcpy(&rdesc[4], &trh->rseg[num_rdsc-2], sizeof(uint16_t));
-        else {
-                memcpy(&rdesc[4], &trh->rseg[1], sizeof(uint16_t));
-                rdesc[5] = ((ntohs(trh->rseg[0]) & 0x000f) | (rdesc[5] & 0xf0));
-        }
+	struct trh_hdr *trh;
+	int riflen, num_rdsc;
+
+	trh = (struct trh_hdr *)packet;
+	if (trh->daddr[0] & (uint8_t) 0x80)
+		return bus_mac;	/* multicast */
+
+	if (trh->saddr[0] & TR_RII) {
+		riflen = (ntohs(trh->rcf) & TR_RCF_LEN_MASK) >> 8;
+		if ((ntohs(trh->rcf) >> 13) != 0)
+			return bus_mac;	/* ARE or STE */
+	} else
+		return trh->daddr;	/* not source routed */
+
+	if (riflen < 6)
+		return trh->daddr;	/* last hop, source routed */
+
+	/* riflen is 6 or more, packet has more than one route descriptor */
+	num_rdsc = (riflen / 2) - 1;
+	memset(rdesc, 0, ETH_ALEN);
+	/* offset 4 comes from LAN destination field in LE control frames */
+	if (trh->rcf & htons((uint16_t) TR_RCF_DIR_BIT))
+		memcpy(&rdesc[4], &trh->rseg[num_rdsc - 2], sizeof(uint16_t));
+	else {
+		memcpy(&rdesc[4], &trh->rseg[1], sizeof(uint16_t));
+		rdesc[5] = ((ntohs(trh->rseg[0]) & 0x000f) | (rdesc[5] & 0xf0));
+	}
 
-        return NULL;
+	return NULL;
 }
 #endif /* CONFIG_TR */
 
@@ -204,15 +210,14 @@ #endif /* CONFIG_TR */
  * there is non-reboot way to recover if something goes wrong.
  */
 
-static int 
-lec_open(struct net_device *dev)
+static int lec_open(struct net_device *dev)
 {
-        struct lec_priv *priv = (struct lec_priv *)dev->priv;
-        
+	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+
 	netif_start_queue(dev);
-        memset(&priv->stats,0,sizeof(struct net_device_stats));
-        
-        return 0;
+	memset(&priv->stats, 0, sizeof(struct net_device_stats));
+
+	return 0;
 }
 
 static __inline__ void
@@ -231,160 +236,166 @@ lec_send(struct atm_vcc *vcc, struct sk_
 	priv->stats.tx_bytes += skb->len;
 }
 
-static void
-lec_tx_timeout(struct net_device *dev)
+static void lec_tx_timeout(struct net_device *dev)
 {
 	printk(KERN_INFO "%s: tx timeout\n", dev->name);
 	dev->trans_start = jiffies;
 	netif_wake_queue(dev);
 }
 
-static int 
-lec_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int lec_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-        struct sk_buff *skb2;
-        struct lec_priv *priv = (struct lec_priv *)dev->priv;
-        struct lecdatahdr_8023 *lec_h;
-        struct atm_vcc *vcc;
+	struct sk_buff *skb2;
+	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lecdatahdr_8023 *lec_h;
+	struct atm_vcc *vcc;
 	struct lec_arp_table *entry;
-        unsigned char *dst;
+	unsigned char *dst;
 	int min_frame_size;
 #ifdef CONFIG_TR
-        unsigned char rdesc[ETH_ALEN]; /* Token Ring route descriptor */
+	unsigned char rdesc[ETH_ALEN];	/* Token Ring route descriptor */
 #endif
-        int is_rdesc;
+	int is_rdesc;
 #if DUMP_PACKETS > 0
-        char buf[300];
-        int i=0;
+	char buf[300];
+	int i = 0;
 #endif /* DUMP_PACKETS >0 */
-        
-        DPRINTK("lec_start_xmit called\n");  
-        if (!priv->lecd) {
-                printk("%s:No lecd attached\n",dev->name);
-                priv->stats.tx_errors++;
-                netif_stop_queue(dev);
-                return -EUNATCH;
-        } 
-
-        DPRINTK("skbuff head:%lx data:%lx tail:%lx end:%lx\n",
-                (long)skb->head, (long)skb->data, (long)skb->tail,
-                (long)skb->end);
+
+	DPRINTK("lec_start_xmit called\n");
+	if (!priv->lecd) {
+		printk("%s:No lecd attached\n", dev->name);
+		priv->stats.tx_errors++;
+		netif_stop_queue(dev);
+		return -EUNATCH;
+	}
+
+	DPRINTK("skbuff head:%lx data:%lx tail:%lx end:%lx\n",
+		(long)skb->head, (long)skb->data, (long)skb->tail,
+		(long)skb->end);
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
-        if (memcmp(skb->data, bridge_ula_lec, sizeof(bridge_ula_lec)) == 0)
-                lec_handle_bridge(skb, dev);
+	if (memcmp(skb->data, bridge_ula_lec, sizeof(bridge_ula_lec)) == 0)
+		lec_handle_bridge(skb, dev);
 #endif
 
-        /* Make sure we have room for lec_id */
-        if (skb_headroom(skb) < 2) {
+	/* Make sure we have room for lec_id */
+	if (skb_headroom(skb) < 2) {
 
-                DPRINTK("lec_start_xmit: reallocating skb\n");
-                skb2 = skb_realloc_headroom(skb, LEC_HEADER_LEN);
-                kfree_skb(skb);
-                if (skb2 == NULL) return 0;
-                skb = skb2;
-        }
-        skb_push(skb, 2);
+		DPRINTK("lec_start_xmit: reallocating skb\n");
+		skb2 = skb_realloc_headroom(skb, LEC_HEADER_LEN);
+		kfree_skb(skb);
+		if (skb2 == NULL)
+			return 0;
+		skb = skb2;
+	}
+	skb_push(skb, 2);
 
-        /* Put le header to place, works for TokenRing too */
-        lec_h = (struct lecdatahdr_8023*)skb->data;
-        lec_h->le_header = htons(priv->lecid); 
+	/* Put le header to place, works for TokenRing too */
+	lec_h = (struct lecdatahdr_8023 *)skb->data;
+	lec_h->le_header = htons(priv->lecid);
 
 #ifdef CONFIG_TR
-        /* Ugly. Use this to realign Token Ring packets for
-         * e.g. PCA-200E driver. */
-        if (priv->is_trdev) {
-                skb2 = skb_realloc_headroom(skb, LEC_HEADER_LEN);
-                kfree_skb(skb);
-                if (skb2 == NULL) return 0;
-                skb = skb2;
-        }
+	/*
+	 * Ugly. Use this to realign Token Ring packets for
+	 * e.g. PCA-200E driver.
+	 */
+	if (priv->is_trdev) {
+		skb2 = skb_realloc_headroom(skb, LEC_HEADER_LEN);
+		kfree_skb(skb);
+		if (skb2 == NULL)
+			return 0;
+		skb = skb2;
+	}
 #endif
 
 #if DUMP_PACKETS > 0
-        printk("%s: send datalen:%ld lecid:%4.4x\n", dev->name,
-               skb->len, priv->lecid);
+	printk("%s: send datalen:%ld lecid:%4.4x\n", dev->name,
+	       skb->len, priv->lecid);
 #if DUMP_PACKETS >= 2
-        for(i=0;i<skb->len && i <99;i++) {
-                sprintf(buf+i*3,"%2.2x ",0xff&skb->data[i]);
-        }
+	for (i = 0; i < skb->len && i < 99; i++) {
+		sprintf(buf + i * 3, "%2.2x ", 0xff & skb->data[i]);
+	}
 #elif DUMP_PACKETS >= 1
-        for(i=0;i<skb->len && i < 30;i++) {
-                sprintf(buf+i*3,"%2.2x ", 0xff&skb->data[i]);
-        }
+	for (i = 0; i < skb->len && i < 30; i++) {
+		sprintf(buf + i * 3, "%2.2x ", 0xff & skb->data[i]);
+	}
 #endif /* DUMP_PACKETS >= 1 */
-        if (i==skb->len)
-                printk("%s\n",buf);
-        else
-                printk("%s...\n",buf);
+	if (i == skb->len)
+		printk("%s\n", buf);
+	else
+		printk("%s...\n", buf);
 #endif /* DUMP_PACKETS > 0 */
 
-        /* Minimum ethernet-frame size */
+	/* Minimum ethernet-frame size */
 #ifdef CONFIG_TR
-        if (priv->is_trdev)
-                min_frame_size = LEC_MINIMUM_8025_SIZE;
+	if (priv->is_trdev)
+		min_frame_size = LEC_MINIMUM_8025_SIZE;
 	else
 #endif
-        min_frame_size = LEC_MINIMUM_8023_SIZE;
-        if (skb->len < min_frame_size) {
-                if ((skb->len + skb_tailroom(skb)) < min_frame_size) {
-                        skb2 = skb_copy_expand(skb, 0,
-                            min_frame_size - skb->truesize, GFP_ATOMIC);
-                                dev_kfree_skb(skb);
-                        if (skb2 == NULL) {
-                                priv->stats.tx_dropped++;
-                                return 0;
-                        }
-                        skb = skb2;
-                }
+		min_frame_size = LEC_MINIMUM_8023_SIZE;
+	if (skb->len < min_frame_size) {
+		if ((skb->len + skb_tailroom(skb)) < min_frame_size) {
+			skb2 = skb_copy_expand(skb, 0,
+					       min_frame_size - skb->truesize,
+					       GFP_ATOMIC);
+			dev_kfree_skb(skb);
+			if (skb2 == NULL) {
+				priv->stats.tx_dropped++;
+				return 0;
+			}
+			skb = skb2;
+		}
 		skb_put(skb, min_frame_size - skb->len);
-        }
-        
-        /* Send to right vcc */
-        is_rdesc = 0;
-        dst = lec_h->h_dest;
+	}
+
+	/* Send to right vcc */
+	is_rdesc = 0;
+	dst = lec_h->h_dest;
 #ifdef CONFIG_TR
-        if (priv->is_trdev) {
-                dst = get_tr_dst(skb->data+2, rdesc);
-                if (dst == NULL) {
-                        dst = rdesc;
-                        is_rdesc = 1;
-                }
-        }
+	if (priv->is_trdev) {
+		dst = get_tr_dst(skb->data + 2, rdesc);
+		if (dst == NULL) {
+			dst = rdesc;
+			is_rdesc = 1;
+		}
+	}
 #endif
-        entry = NULL;
-        vcc = lec_arp_resolve(priv, dst, is_rdesc, &entry);
-        DPRINTK("%s:vcc:%p vcc_flags:%x, entry:%p\n", dev->name,
-                vcc, vcc?vcc->flags:0, entry);
-        if (!vcc || !test_bit(ATM_VF_READY,&vcc->flags)) {    
-                if (entry && (entry->tx_wait.qlen < LEC_UNRES_QUE_LEN)) {
-                        DPRINTK("%s:lec_start_xmit: queuing packet, ", dev->name);
-                        DPRINTK("MAC address 0x%02x:%02x:%02x:%02x:%02x:%02x\n",
-                                lec_h->h_dest[0], lec_h->h_dest[1], lec_h->h_dest[2],
-                                lec_h->h_dest[3], lec_h->h_dest[4], lec_h->h_dest[5]);
-                        skb_queue_tail(&entry->tx_wait, skb);
-                } else {
-                        DPRINTK("%s:lec_start_xmit: tx queue full or no arp entry, dropping, ", dev->name);
-                        DPRINTK("MAC address 0x%02x:%02x:%02x:%02x:%02x:%02x\n",
-                                lec_h->h_dest[0], lec_h->h_dest[1], lec_h->h_dest[2],
-                                lec_h->h_dest[3], lec_h->h_dest[4], lec_h->h_dest[5]);
-                        priv->stats.tx_dropped++;
-                        dev_kfree_skb(skb);
-                }
-                return 0;
-        }
-                
-#if DUMP_PACKETS > 0                    
-        printk("%s:sending to vpi:%d vci:%d\n", dev->name,
-               vcc->vpi, vcc->vci);       
+	entry = NULL;
+	vcc = lec_arp_resolve(priv, dst, is_rdesc, &entry);
+	DPRINTK("%s:vcc:%p vcc_flags:%x, entry:%p\n", dev->name,
+		vcc, vcc ? vcc->flags : 0, entry);
+	if (!vcc || !test_bit(ATM_VF_READY, &vcc->flags)) {
+		if (entry && (entry->tx_wait.qlen < LEC_UNRES_QUE_LEN)) {
+			DPRINTK("%s:lec_start_xmit: queuing packet, ",
+				dev->name);
+			DPRINTK("MAC address 0x%02x:%02x:%02x:%02x:%02x:%02x\n",
+				lec_h->h_dest[0], lec_h->h_dest[1],
+				lec_h->h_dest[2], lec_h->h_dest[3],
+				lec_h->h_dest[4], lec_h->h_dest[5]);
+			skb_queue_tail(&entry->tx_wait, skb);
+		} else {
+			DPRINTK
+			    ("%s:lec_start_xmit: tx queue full or no arp entry, dropping, ",
+			     dev->name);
+			DPRINTK("MAC address 0x%02x:%02x:%02x:%02x:%02x:%02x\n",
+				lec_h->h_dest[0], lec_h->h_dest[1],
+				lec_h->h_dest[2], lec_h->h_dest[3],
+				lec_h->h_dest[4], lec_h->h_dest[5]);
+			priv->stats.tx_dropped++;
+			dev_kfree_skb(skb);
+		}
+		return 0;
+	}
+#if DUMP_PACKETS > 0
+	printk("%s:sending to vpi:%d vci:%d\n", dev->name, vcc->vpi, vcc->vci);
 #endif /* DUMP_PACKETS > 0 */
-                
-        while (entry && (skb2 = skb_dequeue(&entry->tx_wait))) {
-                DPRINTK("lec.c: emptying tx queue, ");
-                DPRINTK("MAC address 0x%02x:%02x:%02x:%02x:%02x:%02x\n",
-                        lec_h->h_dest[0], lec_h->h_dest[1], lec_h->h_dest[2],
-                        lec_h->h_dest[3], lec_h->h_dest[4], lec_h->h_dest[5]);
+
+	while (entry && (skb2 = skb_dequeue(&entry->tx_wait))) {
+		DPRINTK("lec.c: emptying tx queue, ");
+		DPRINTK("MAC address 0x%02x:%02x:%02x:%02x:%02x:%02x\n",
+			lec_h->h_dest[0], lec_h->h_dest[1], lec_h->h_dest[2],
+			lec_h->h_dest[3], lec_h->h_dest[4], lec_h->h_dest[5]);
 		lec_send(vcc, skb2, priv);
-        }
+	}
 
 	lec_send(vcc, skb, priv);
 
@@ -405,209 +416,215 @@ #endif /* DUMP_PACKETS > 0 */
 	}
 
 	dev->trans_start = jiffies;
-        return 0;
+	return 0;
 }
 
 /* The inverse routine to net_open(). */
-static int 
-lec_close(struct net_device *dev) 
+static int lec_close(struct net_device *dev)
 {
-        netif_stop_queue(dev);
-        return 0;
+	netif_stop_queue(dev);
+	return 0;
 }
 
 /*
  * Get the current statistics.
  * This may be called with the card open or closed.
  */
-static struct net_device_stats *
-lec_get_stats(struct net_device *dev)
+static struct net_device_stats *lec_get_stats(struct net_device *dev)
 {
-        return &((struct lec_priv *)dev->priv)->stats;
+	return &((struct lec_priv *)dev->priv)->stats;
 }
 
-static int 
-lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
+static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	unsigned long flags;
-        struct net_device *dev = (struct net_device*)vcc->proto_data;
-        struct lec_priv *priv = (struct lec_priv*)dev->priv;
-        struct atmlec_msg *mesg;
-        struct lec_arp_table *entry;
-        int i;
-        char *tmp; /* FIXME */
+	struct net_device *dev = (struct net_device *)vcc->proto_data;
+	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct atmlec_msg *mesg;
+	struct lec_arp_table *entry;
+	int i;
+	char *tmp;		/* FIXME */
 
 	atomic_sub(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
-        mesg = (struct atmlec_msg *)skb->data;
-        tmp = skb->data;
-        tmp += sizeof(struct atmlec_msg);
-        DPRINTK("%s: msg from zeppelin:%d\n", dev->name, mesg->type);
-        switch(mesg->type) {
-        case l_set_mac_addr:
-                for (i=0;i<6;i++) {
-                        dev->dev_addr[i] = mesg->content.normal.mac_addr[i];
-                }    
-                break;
-        case l_del_mac_addr:
-                for(i=0;i<6;i++) {
-                        dev->dev_addr[i] = 0;
-                }
-                break;
-        case l_addr_delete:
-                lec_addr_delete(priv, mesg->content.normal.atm_addr, 
-                                mesg->content.normal.flag);
-                break;
-        case l_topology_change:
-                priv->topology_change = mesg->content.normal.flag;  
-                break;
-        case l_flush_complete:
-                lec_flush_complete(priv, mesg->content.normal.flag);
-                break;
-        case l_narp_req: /* LANE2: see 7.1.35 in the lane2 spec */
+	mesg = (struct atmlec_msg *)skb->data;
+	tmp = skb->data;
+	tmp += sizeof(struct atmlec_msg);
+	DPRINTK("%s: msg from zeppelin:%d\n", dev->name, mesg->type);
+	switch (mesg->type) {
+	case l_set_mac_addr:
+		for (i = 0; i < 6; i++) {
+			dev->dev_addr[i] = mesg->content.normal.mac_addr[i];
+		}
+		break;
+	case l_del_mac_addr:
+		for (i = 0; i < 6; i++) {
+			dev->dev_addr[i] = 0;
+		}
+		break;
+	case l_addr_delete:
+		lec_addr_delete(priv, mesg->content.normal.atm_addr,
+				mesg->content.normal.flag);
+		break;
+	case l_topology_change:
+		priv->topology_change = mesg->content.normal.flag;
+		break;
+	case l_flush_complete:
+		lec_flush_complete(priv, mesg->content.normal.flag);
+		break;
+	case l_narp_req:	/* LANE2: see 7.1.35 in the lane2 spec */
 		spin_lock_irqsave(&priv->lec_arp_lock, flags);
-                entry = lec_arp_find(priv, mesg->content.normal.mac_addr);
-                lec_arp_remove(priv, entry);
+		entry = lec_arp_find(priv, mesg->content.normal.mac_addr);
+		lec_arp_remove(priv, entry);
 		spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 
-                if (mesg->content.normal.no_source_le_narp)
-                        break;
-                /* FALL THROUGH */
-        case l_arp_update:
-                lec_arp_update(priv, mesg->content.normal.mac_addr,
-                               mesg->content.normal.atm_addr,
-                               mesg->content.normal.flag,
-                               mesg->content.normal.targetless_le_arp);
-                DPRINTK("lec: in l_arp_update\n");
-                if (mesg->sizeoftlvs != 0) { /* LANE2 3.1.5 */
-                        DPRINTK("lec: LANE2 3.1.5, got tlvs, size %d\n", mesg->sizeoftlvs);
-                        lane2_associate_ind(dev,
-                                            mesg->content.normal.mac_addr,
-                                            tmp, mesg->sizeoftlvs);
-                }
-                break;
-        case l_config:
-                priv->maximum_unknown_frame_count = 
-                        mesg->content.config.maximum_unknown_frame_count;
-                priv->max_unknown_frame_time = 
-                        (mesg->content.config.max_unknown_frame_time*HZ);
-                priv->max_retry_count = 
-                        mesg->content.config.max_retry_count;
-                priv->aging_time = (mesg->content.config.aging_time*HZ);
-                priv->forward_delay_time = 
-                        (mesg->content.config.forward_delay_time*HZ);
-                priv->arp_response_time = 
-                        (mesg->content.config.arp_response_time*HZ);
-                priv->flush_timeout = (mesg->content.config.flush_timeout*HZ);
-                priv->path_switching_delay = 
-                        (mesg->content.config.path_switching_delay*HZ);
-                priv->lane_version = mesg->content.config.lane_version; /* LANE2 */
+		if (mesg->content.normal.no_source_le_narp)
+			break;
+		/* FALL THROUGH */
+	case l_arp_update:
+		lec_arp_update(priv, mesg->content.normal.mac_addr,
+			       mesg->content.normal.atm_addr,
+			       mesg->content.normal.flag,
+			       mesg->content.normal.targetless_le_arp);
+		DPRINTK("lec: in l_arp_update\n");
+		if (mesg->sizeoftlvs != 0) {	/* LANE2 3.1.5 */
+			DPRINTK("lec: LANE2 3.1.5, got tlvs, size %d\n",
+				mesg->sizeoftlvs);
+			lane2_associate_ind(dev, mesg->content.normal.mac_addr,
+					    tmp, mesg->sizeoftlvs);
+		}
+		break;
+	case l_config:
+		priv->maximum_unknown_frame_count =
+		    mesg->content.config.maximum_unknown_frame_count;
+		priv->max_unknown_frame_time =
+		    (mesg->content.config.max_unknown_frame_time * HZ);
+		priv->max_retry_count = mesg->content.config.max_retry_count;
+		priv->aging_time = (mesg->content.config.aging_time * HZ);
+		priv->forward_delay_time =
+		    (mesg->content.config.forward_delay_time * HZ);
+		priv->arp_response_time =
+		    (mesg->content.config.arp_response_time * HZ);
+		priv->flush_timeout = (mesg->content.config.flush_timeout * HZ);
+		priv->path_switching_delay =
+		    (mesg->content.config.path_switching_delay * HZ);
+		priv->lane_version = mesg->content.config.lane_version;	/* LANE2 */
 		priv->lane2_ops = NULL;
 		if (priv->lane_version > 1)
 			priv->lane2_ops = &lane2_ops;
 		if (dev->change_mtu(dev, mesg->content.config.mtu))
 			printk("%s: change_mtu to %d failed\n", dev->name,
-			    mesg->content.config.mtu);
+			       mesg->content.config.mtu);
 		priv->is_proxy = mesg->content.config.is_proxy;
-                break;
-        case l_flush_tran_id:
-                lec_set_flush_tran_id(priv, mesg->content.normal.atm_addr,
-                                      mesg->content.normal.flag);
-                break;
-        case l_set_lecid:
-                priv->lecid=(unsigned short)(0xffff&mesg->content.normal.flag);
-                break;
-        case l_should_bridge: {
+		break;
+	case l_flush_tran_id:
+		lec_set_flush_tran_id(priv, mesg->content.normal.atm_addr,
+				      mesg->content.normal.flag);
+		break;
+	case l_set_lecid:
+		priv->lecid =
+		    (unsigned short)(0xffff & mesg->content.normal.flag);
+		break;
+	case l_should_bridge:
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
-                struct net_bridge_fdb_entry *f;
-
-                DPRINTK("%s: bridge zeppelin asks about 0x%02x:%02x:%02x:%02x:%02x:%02x\n",
-                        dev->name,
-                        mesg->content.proxy.mac_addr[0], mesg->content.proxy.mac_addr[1],
-                        mesg->content.proxy.mac_addr[2], mesg->content.proxy.mac_addr[3],
-                        mesg->content.proxy.mac_addr[4], mesg->content.proxy.mac_addr[5]);
-
-                if (br_fdb_get_hook == NULL || dev->br_port == NULL)
-                        break;
-
-                f = br_fdb_get_hook(dev->br_port->br, mesg->content.proxy.mac_addr);
-                if (f != NULL &&
-                    f->dst->dev != dev &&
-                    f->dst->state == BR_STATE_FORWARDING) {
-                                /* hit from bridge table, send LE_ARP_RESPONSE */
-                        struct sk_buff *skb2;
-			struct sock *sk;
-
-                        DPRINTK("%s: entry found, responding to zeppelin\n", dev->name);
-                        skb2 = alloc_skb(sizeof(struct atmlec_msg), GFP_ATOMIC);
-                        if (skb2 == NULL) {
-                                br_fdb_put_hook(f);
-                                break;
-                        }
-                        skb2->len = sizeof(struct atmlec_msg);
-                        memcpy(skb2->data, mesg, sizeof(struct atmlec_msg));
-                        atm_force_charge(priv->lecd, skb2->truesize);
-			sk = sk_atm(priv->lecd);
-                        skb_queue_tail(&sk->sk_receive_queue, skb2);
-                        sk->sk_data_ready(sk, skb2->len);
-                }
-                if (f != NULL) br_fdb_put_hook(f);
+		{
+			struct net_bridge_fdb_entry *f;
+
+			DPRINTK
+			    ("%s: bridge zeppelin asks about 0x%02x:%02x:%02x:%02x:%02x:%02x\n",
+			     dev->name, mesg->content.proxy.mac_addr[0],
+			     mesg->content.proxy.mac_addr[1],
+			     mesg->content.proxy.mac_addr[2],
+			     mesg->content.proxy.mac_addr[3],
+			     mesg->content.proxy.mac_addr[4],
+			     mesg->content.proxy.mac_addr[5]);
+
+			if (br_fdb_get_hook == NULL || dev->br_port == NULL)
+				break;
+
+			f = br_fdb_get_hook(dev->br_port->br,
+					    mesg->content.proxy.mac_addr);
+			if (f != NULL && f->dst->dev != dev
+			    && f->dst->state == BR_STATE_FORWARDING) {
+				/* hit from bridge table, send LE_ARP_RESPONSE */
+				struct sk_buff *skb2;
+				struct sock *sk;
+
+				DPRINTK
+				    ("%s: entry found, responding to zeppelin\n",
+				     dev->name);
+				skb2 =
+				    alloc_skb(sizeof(struct atmlec_msg),
+					      GFP_ATOMIC);
+				if (skb2 == NULL) {
+					br_fdb_put_hook(f);
+					break;
+				}
+				skb2->len = sizeof(struct atmlec_msg);
+				memcpy(skb2->data, mesg,
+				       sizeof(struct atmlec_msg));
+				atm_force_charge(priv->lecd, skb2->truesize);
+				sk = sk_atm(priv->lecd);
+				skb_queue_tail(&sk->sk_receive_queue, skb2);
+				sk->sk_data_ready(sk, skb2->len);
+			}
+			if (f != NULL)
+				br_fdb_put_hook(f);
+		}
 #endif /* defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE) */
-                }
-                break;
-        default:
-                printk("%s: Unknown message type %d\n", dev->name, mesg->type);
-                dev_kfree_skb(skb);
-                return -EINVAL;
-        }
-        dev_kfree_skb(skb);
-        return 0;
+		break;
+	default:
+		printk("%s: Unknown message type %d\n", dev->name, mesg->type);
+		dev_kfree_skb(skb);
+		return -EINVAL;
+	}
+	dev_kfree_skb(skb);
+	return 0;
 }
 
-static void 
-lec_atm_close(struct atm_vcc *vcc)
+static void lec_atm_close(struct atm_vcc *vcc)
 {
-        struct sk_buff *skb;
-        struct net_device *dev = (struct net_device *)vcc->proto_data;
-        struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct sk_buff *skb;
+	struct net_device *dev = (struct net_device *)vcc->proto_data;
+	struct lec_priv *priv = (struct lec_priv *)dev->priv;
 
-        priv->lecd = NULL;
-        /* Do something needful? */
+	priv->lecd = NULL;
+	/* Do something needful? */
 
-        netif_stop_queue(dev);
-        lec_arp_destroy(priv);
+	netif_stop_queue(dev);
+	lec_arp_destroy(priv);
 
-        if (skb_peek(&sk_atm(vcc)->sk_receive_queue))
+	if (skb_peek(&sk_atm(vcc)->sk_receive_queue))
 		printk("%s lec_atm_close: closing with messages pending\n",
-                       dev->name);
-        while ((skb = skb_dequeue(&sk_atm(vcc)->sk_receive_queue)) != NULL) {
-                atm_return(vcc, skb->truesize);
+		       dev->name);
+	while ((skb = skb_dequeue(&sk_atm(vcc)->sk_receive_queue)) != NULL) {
+		atm_return(vcc, skb->truesize);
 		dev_kfree_skb(skb);
-        }
-  
+	}
+
 	printk("%s: Shut down!\n", dev->name);
-        module_put(THIS_MODULE);
+	module_put(THIS_MODULE);
 }
 
 static struct atmdev_ops lecdev_ops = {
-        .close	= lec_atm_close,
-        .send	= lec_atm_send
+	.close = lec_atm_close,
+	.send = lec_atm_send
 };
 
 static struct atm_dev lecatm_dev = {
-	.ops	= &lecdev_ops,
-	.type	= "lec",
-	.number	= 999,	/* dummy device number */
-	.lock	= SPIN_LOCK_UNLOCKED
+	.ops = &lecdev_ops,
+	.type = "lec",
+	.number = 999,		/* dummy device number */
+	.lock = SPIN_LOCK_UNLOCKED
 };
 
 /*
  * LANE2: new argument struct sk_buff *data contains
  * the LE_ARP based TLVs introduced in the LANE2 spec
  */
-static int 
-send_to_lecd(struct lec_priv *priv, atmlec_msg_type type, 
-             unsigned char *mac_addr, unsigned char *atm_addr,
-             struct sk_buff *data)
+static int
+send_to_lecd(struct lec_priv *priv, atmlec_msg_type type,
+	     unsigned char *mac_addr, unsigned char *atm_addr,
+	     struct sk_buff *data)
 {
 	struct sock *sk;
 	struct sk_buff *skb;
@@ -621,154 +638,160 @@ send_to_lecd(struct lec_priv *priv, atml
 		return -1;
 	skb->len = sizeof(struct atmlec_msg);
 	mesg = (struct atmlec_msg *)skb->data;
-        memset(mesg, 0, sizeof(struct atmlec_msg));
+	memset(mesg, 0, sizeof(struct atmlec_msg));
 	mesg->type = type;
-        if (data != NULL)
-                mesg->sizeoftlvs = data->len;
+	if (data != NULL)
+		mesg->sizeoftlvs = data->len;
 	if (mac_addr)
 		memcpy(&mesg->content.normal.mac_addr, mac_addr, ETH_ALEN);
-        else
-                mesg->content.normal.targetless_le_arp = 1;
+	else
+		mesg->content.normal.targetless_le_arp = 1;
 	if (atm_addr)
 		memcpy(&mesg->content.normal.atm_addr, atm_addr, ATM_ESA_LEN);
 
-        atm_force_charge(priv->lecd, skb->truesize);
+	atm_force_charge(priv->lecd, skb->truesize);
 	sk = sk_atm(priv->lecd);
 	skb_queue_tail(&sk->sk_receive_queue, skb);
-        sk->sk_data_ready(sk, skb->len);
+	sk->sk_data_ready(sk, skb->len);
 
-        if (data != NULL) {
-                DPRINTK("lec: about to send %d bytes of data\n", data->len);
-                atm_force_charge(priv->lecd, data->truesize);
-                skb_queue_tail(&sk->sk_receive_queue, data);
-                sk->sk_data_ready(sk, skb->len);
-        }
+	if (data != NULL) {
+		DPRINTK("lec: about to send %d bytes of data\n", data->len);
+		atm_force_charge(priv->lecd, data->truesize);
+		skb_queue_tail(&sk->sk_receive_queue, data);
+		sk->sk_data_ready(sk, skb->len);
+	}
 
-        return 0;
+	return 0;
 }
 
 /* shamelessly stolen from drivers/net/net_init.c */
 static int lec_change_mtu(struct net_device *dev, int new_mtu)
 {
-        if ((new_mtu < 68) || (new_mtu > 18190))
-                return -EINVAL;
-        dev->mtu = new_mtu;
-        return 0;
+	if ((new_mtu < 68) || (new_mtu > 18190))
+		return -EINVAL;
+	dev->mtu = new_mtu;
+	return 0;
 }
 
 static void lec_set_multicast_list(struct net_device *dev)
 {
-	/* by default, all multicast frames arrive over the bus.
-         * eventually support selective multicast service
-         */
-        return;
+	/*
+	 * by default, all multicast frames arrive over the bus.
+	 * eventually support selective multicast service
+	 */
+	return;
 }
 
-static void 
-lec_init(struct net_device *dev)
+static void lec_init(struct net_device *dev)
 {
-        dev->change_mtu = lec_change_mtu;
-        dev->open = lec_open;
-        dev->stop = lec_close;
-        dev->hard_start_xmit = lec_start_xmit;
+	dev->change_mtu = lec_change_mtu;
+	dev->open = lec_open;
+	dev->stop = lec_close;
+	dev->hard_start_xmit = lec_start_xmit;
 	dev->tx_timeout = lec_tx_timeout;
 
-        dev->get_stats = lec_get_stats;
-        dev->set_multicast_list = lec_set_multicast_list;
-        dev->do_ioctl  = NULL;
-        printk("%s: Initialized!\n",dev->name);
-        return;
+	dev->get_stats = lec_get_stats;
+	dev->set_multicast_list = lec_set_multicast_list;
+	dev->do_ioctl = NULL;
+	printk("%s: Initialized!\n", dev->name);
+	return;
 }
 
 static unsigned char lec_ctrl_magic[] = {
-        0xff,
-        0x00,
-        0x01,
-        0x01 };
+	0xff,
+	0x00,
+	0x01,
+	0x01
+};
 
 #define LEC_DATA_DIRECT_8023  2
 #define LEC_DATA_DIRECT_8025  3
 
 static int lec_is_data_direct(struct atm_vcc *vcc)
-{ 
+{
 	return ((vcc->sap.blli[0].l3.tr9577.snap[4] == LEC_DATA_DIRECT_8023) ||
 		(vcc->sap.blli[0].l3.tr9577.snap[4] == LEC_DATA_DIRECT_8025));
-} 
+}
 
-static void 
-lec_push(struct atm_vcc *vcc, struct sk_buff *skb)
+static void lec_push(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	unsigned long flags;
-        struct net_device *dev = (struct net_device *)vcc->proto_data;
-        struct lec_priv *priv = (struct lec_priv *)dev->priv; 
+	struct net_device *dev = (struct net_device *)vcc->proto_data;
+	struct lec_priv *priv = (struct lec_priv *)dev->priv;
 
 #if DUMP_PACKETS >0
-        int i=0;
-        char buf[300];
+	int i = 0;
+	char buf[300];
 
-        printk("%s: lec_push vcc vpi:%d vci:%d\n", dev->name,
-               vcc->vpi, vcc->vci);
+	printk("%s: lec_push vcc vpi:%d vci:%d\n", dev->name,
+	       vcc->vpi, vcc->vci);
 #endif
-        if (!skb) {
-                DPRINTK("%s: null skb\n",dev->name);
-                lec_vcc_close(priv, vcc);
-                return;
-        }
+	if (!skb) {
+		DPRINTK("%s: null skb\n", dev->name);
+		lec_vcc_close(priv, vcc);
+		return;
+	}
 #if DUMP_PACKETS > 0
-        printk("%s: rcv datalen:%ld lecid:%4.4x\n", dev->name,
-               skb->len, priv->lecid);
+	printk("%s: rcv datalen:%ld lecid:%4.4x\n", dev->name,
+	       skb->len, priv->lecid);
 #if DUMP_PACKETS >= 2
-        for(i=0;i<skb->len && i <99;i++) {
-                sprintf(buf+i*3,"%2.2x ",0xff&skb->data[i]);
-        }
+	for (i = 0; i < skb->len && i < 99; i++) {
+		sprintf(buf + i * 3, "%2.2x ", 0xff & skb->data[i]);
+	}
 #elif DUMP_PACKETS >= 1
-        for(i=0;i<skb->len && i < 30;i++) {
-                sprintf(buf+i*3,"%2.2x ", 0xff&skb->data[i]);
-        }
+	for (i = 0; i < skb->len && i < 30; i++) {
+		sprintf(buf + i * 3, "%2.2x ", 0xff & skb->data[i]);
+	}
 #endif /* DUMP_PACKETS >= 1 */
-        if (i==skb->len)
-                printk("%s\n",buf);
-        else
-                printk("%s...\n",buf);
+	if (i == skb->len)
+		printk("%s\n", buf);
+	else
+		printk("%s...\n", buf);
 #endif /* DUMP_PACKETS > 0 */
-        if (memcmp(skb->data, lec_ctrl_magic, 4) ==0) { /* Control frame, to daemon*/
+	if (memcmp(skb->data, lec_ctrl_magic, 4) == 0) {	/* Control frame, to daemon */
 		struct sock *sk = sk_atm(vcc);
 
-                DPRINTK("%s: To daemon\n",dev->name);
-                skb_queue_tail(&sk->sk_receive_queue, skb);
-                sk->sk_data_ready(sk, skb->len);
-        } else { /* Data frame, queue to protocol handlers */
+		DPRINTK("%s: To daemon\n", dev->name);
+		skb_queue_tail(&sk->sk_receive_queue, skb);
+		sk->sk_data_ready(sk, skb->len);
+	} else {		/* Data frame, queue to protocol handlers */
 		struct lec_arp_table *entry;
-                unsigned char *src, *dst;
-
-                atm_return(vcc,skb->truesize);
-                if (*(uint16_t *)skb->data == htons(priv->lecid) ||
-                    !priv->lecd ||
-                    !(dev->flags & IFF_UP)) { 
-                        /* Probably looping back, or if lecd is missing,
-                           lecd has gone down */
-                        DPRINTK("Ignoring frame...\n");
-                        dev_kfree_skb(skb);
-                        return;
-                }
+		unsigned char *src, *dst;
+
+		atm_return(vcc, skb->truesize);
+		if (*(uint16_t *) skb->data == htons(priv->lecid) ||
+		    !priv->lecd || !(dev->flags & IFF_UP)) {
+			/*
+			 * Probably looping back, or if lecd is missing,
+			 * lecd has gone down
+			 */
+			DPRINTK("Ignoring frame...\n");
+			dev_kfree_skb(skb);
+			return;
+		}
 #ifdef CONFIG_TR
-                if (priv->is_trdev)
-			dst = ((struct lecdatahdr_8025 *) skb->data)->h_dest;
-                else
+		if (priv->is_trdev)
+			dst = ((struct lecdatahdr_8025 *)skb->data)->h_dest;
+		else
 #endif
-		dst = ((struct lecdatahdr_8023 *) skb->data)->h_dest;
+			dst = ((struct lecdatahdr_8023 *)skb->data)->h_dest;
 
-		/* If this is a Data Direct VCC, and the VCC does not match
+		/*
+		 * If this is a Data Direct VCC, and the VCC does not match
 		 * the LE_ARP cache entry, delete the LE_ARP cache entry.
 		 */
 		spin_lock_irqsave(&priv->lec_arp_lock, flags);
 		if (lec_is_data_direct(vcc)) {
 #ifdef CONFIG_TR
 			if (priv->is_trdev)
-				src = ((struct lecdatahdr_8025 *) skb->data)->h_source;
+				src =
+				    ((struct lecdatahdr_8025 *)skb->data)->
+				    h_source;
 			else
 #endif
-			src = ((struct lecdatahdr_8023 *) skb->data)->h_source;
+				src =
+				    ((struct lecdatahdr_8023 *)skb->data)->
+				    h_source;
 			entry = lec_arp_find(priv, src);
 			if (entry && entry->vcc != vcc) {
 				lec_arp_remove(priv, entry);
@@ -777,31 +800,31 @@ #endif
 		}
 		spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 
-                if (!(dst[0]&0x01) &&   /* Never filter Multi/Broadcast */
-                    !priv->is_proxy &&  /* Proxy wants all the packets */
+		if (!(dst[0] & 0x01) &&	/* Never filter Multi/Broadcast */
+		    !priv->is_proxy &&	/* Proxy wants all the packets */
 		    memcmp(dst, dev->dev_addr, dev->addr_len)) {
-                        dev_kfree_skb(skb);
-                        return;
-                }
-                if (priv->lec_arp_empty_ones) {
-                        lec_arp_check_empties(priv, vcc, skb);
-                }
-                skb->dev = dev;
-                skb_pull(skb, 2); /* skip lec_id */
+			dev_kfree_skb(skb);
+			return;
+		}
+		if (priv->lec_arp_empty_ones) {
+			lec_arp_check_empties(priv, vcc, skb);
+		}
+		skb->dev = dev;
+		skb_pull(skb, 2);	/* skip lec_id */
 #ifdef CONFIG_TR
-                if (priv->is_trdev) skb->protocol = tr_type_trans(skb, dev);
-                else
+		if (priv->is_trdev)
+			skb->protocol = tr_type_trans(skb, dev);
+		else
 #endif
-                skb->protocol = eth_type_trans(skb, dev);
-                priv->stats.rx_packets++;
-                priv->stats.rx_bytes += skb->len;
-                memset(ATM_SKB(skb), 0, sizeof(struct atm_skb_data));
-                netif_rx(skb);
-        }
+			skb->protocol = eth_type_trans(skb, dev);
+		priv->stats.rx_packets++;
+		priv->stats.rx_bytes += skb->len;
+		memset(ATM_SKB(skb), 0, sizeof(struct atm_skb_data));
+		netif_rx(skb);
+	}
 }
 
-static void
-lec_pop(struct atm_vcc *vcc, struct sk_buff *skb)
+static void lec_pop(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	struct lec_vcc_priv *vpriv = LEC_VCC_PRIV(vcc);
 	struct net_device *dev = skb->dev;
@@ -820,123 +843,121 @@ lec_pop(struct atm_vcc *vcc, struct sk_b
 	}
 }
 
-static int 
-lec_vcc_attach(struct atm_vcc *vcc, void __user *arg)
+static int lec_vcc_attach(struct atm_vcc *vcc, void __user *arg)
 {
 	struct lec_vcc_priv *vpriv;
-        int bytes_left;
-        struct atmlec_ioc ioc_data;
-
-        /* Lecd must be up in this case */
-        bytes_left = copy_from_user(&ioc_data, arg, sizeof(struct atmlec_ioc));
-        if (bytes_left != 0) {
-                printk("lec: lec_vcc_attach, copy from user failed for %d bytes\n",
-                       bytes_left);
-        }
-        if (ioc_data.dev_num < 0 || ioc_data.dev_num >= MAX_LEC_ITF || 
-            !dev_lec[ioc_data.dev_num])
-                return -EINVAL;
+	int bytes_left;
+	struct atmlec_ioc ioc_data;
+
+	/* Lecd must be up in this case */
+	bytes_left = copy_from_user(&ioc_data, arg, sizeof(struct atmlec_ioc));
+	if (bytes_left != 0) {
+		printk
+		    ("lec: lec_vcc_attach, copy from user failed for %d bytes\n",
+		     bytes_left);
+	}
+	if (ioc_data.dev_num < 0 || ioc_data.dev_num >= MAX_LEC_ITF ||
+	    !dev_lec[ioc_data.dev_num])
+		return -EINVAL;
 	if (!(vpriv = kmalloc(sizeof(struct lec_vcc_priv), GFP_KERNEL)))
 		return -ENOMEM;
 	vpriv->xoff = 0;
 	vpriv->old_pop = vcc->pop;
 	vcc->user_back = vpriv;
 	vcc->pop = lec_pop;
-        lec_vcc_added(dev_lec[ioc_data.dev_num]->priv, 
-                      &ioc_data, vcc, vcc->push);
-        vcc->proto_data = dev_lec[ioc_data.dev_num];
-        vcc->push = lec_push;
-        return 0;
+	lec_vcc_added(dev_lec[ioc_data.dev_num]->priv,
+		      &ioc_data, vcc, vcc->push);
+	vcc->proto_data = dev_lec[ioc_data.dev_num];
+	vcc->push = lec_push;
+	return 0;
 }
 
-static int 
-lec_mcast_attach(struct atm_vcc *vcc, int arg)
+static int lec_mcast_attach(struct atm_vcc *vcc, int arg)
 {
-        if (arg <0 || arg >= MAX_LEC_ITF || !dev_lec[arg])
-                return -EINVAL;
-        vcc->proto_data = dev_lec[arg];
-        return (lec_mcast_make((struct lec_priv*)dev_lec[arg]->priv, vcc));
+	if (arg < 0 || arg >= MAX_LEC_ITF || !dev_lec[arg])
+		return -EINVAL;
+	vcc->proto_data = dev_lec[arg];
+	return (lec_mcast_make((struct lec_priv *)dev_lec[arg]->priv, vcc));
 }
 
 /* Initialize device. */
-static int 
-lecd_attach(struct atm_vcc *vcc, int arg)
-{  
-        int i;
-        struct lec_priv *priv;
+static int lecd_attach(struct atm_vcc *vcc, int arg)
+{
+	int i;
+	struct lec_priv *priv;
 
-        if (arg<0)
-                i = 0;
-        else
-                i = arg;
+	if (arg < 0)
+		i = 0;
+	else
+		i = arg;
 #ifdef CONFIG_TR
-        if (arg >= MAX_LEC_ITF)
-                return -EINVAL;
-#else /* Reserve the top NUM_TR_DEVS for TR */
-        if (arg >= (MAX_LEC_ITF-NUM_TR_DEVS))
-                return -EINVAL;
+	if (arg >= MAX_LEC_ITF)
+		return -EINVAL;
+#else				/* Reserve the top NUM_TR_DEVS for TR */
+	if (arg >= (MAX_LEC_ITF - NUM_TR_DEVS))
+		return -EINVAL;
 #endif
-        if (!dev_lec[i]) {
-                int is_trdev, size;
+	if (!dev_lec[i]) {
+		int is_trdev, size;
 
-                is_trdev = 0;
-                if (i >= (MAX_LEC_ITF - NUM_TR_DEVS))
-                        is_trdev = 1;
+		is_trdev = 0;
+		if (i >= (MAX_LEC_ITF - NUM_TR_DEVS))
+			is_trdev = 1;
 
-                size = sizeof(struct lec_priv);
+		size = sizeof(struct lec_priv);
 #ifdef CONFIG_TR
-                if (is_trdev)
-                        dev_lec[i] = alloc_trdev(size);
-                else
+		if (is_trdev)
+			dev_lec[i] = alloc_trdev(size);
+		else
 #endif
-                dev_lec[i] = alloc_etherdev(size);
-                if (!dev_lec[i])
-                        return -ENOMEM;
-                snprintf(dev_lec[i]->name, IFNAMSIZ, "lec%d", i);
-                if (register_netdev(dev_lec[i])) {
-                        free_netdev(dev_lec[i]);
-                        return -EINVAL;
-                }
+			dev_lec[i] = alloc_etherdev(size);
+		if (!dev_lec[i])
+			return -ENOMEM;
+		snprintf(dev_lec[i]->name, IFNAMSIZ, "lec%d", i);
+		if (register_netdev(dev_lec[i])) {
+			free_netdev(dev_lec[i]);
+			return -EINVAL;
+		}
 
-                priv = dev_lec[i]->priv;
-                priv->is_trdev = is_trdev;
-                lec_init(dev_lec[i]);
-        } else {
-                priv = dev_lec[i]->priv;
-                if (priv->lecd)
-                        return -EADDRINUSE;
-        }
-        lec_arp_init(priv);
-	priv->itfnum = i;  /* LANE2 addition */
-        priv->lecd = vcc;
-        vcc->dev = &lecatm_dev;
-        vcc_insert_socket(sk_atm(vcc));
-        
-        vcc->proto_data = dev_lec[i];
-	set_bit(ATM_VF_META,&vcc->flags);
-	set_bit(ATM_VF_READY,&vcc->flags);
-
-        /* Set default values to these variables */
-        priv->maximum_unknown_frame_count = 1;
-        priv->max_unknown_frame_time = (1*HZ);
-        priv->vcc_timeout_period = (1200*HZ);
-        priv->max_retry_count = 1;
-        priv->aging_time = (300*HZ);
-        priv->forward_delay_time = (15*HZ);
-        priv->topology_change = 0;
-        priv->arp_response_time = (1*HZ);
-        priv->flush_timeout = (4*HZ);
-        priv->path_switching_delay = (6*HZ);
-
-        if (dev_lec[i]->flags & IFF_UP) {
-                netif_start_queue(dev_lec[i]);
-        }
-        __module_get(THIS_MODULE);
-        return i;
+		priv = dev_lec[i]->priv;
+		priv->is_trdev = is_trdev;
+		lec_init(dev_lec[i]);
+	} else {
+		priv = dev_lec[i]->priv;
+		if (priv->lecd)
+			return -EADDRINUSE;
+	}
+	lec_arp_init(priv);
+	priv->itfnum = i;	/* LANE2 addition */
+	priv->lecd = vcc;
+	vcc->dev = &lecatm_dev;
+	vcc_insert_socket(sk_atm(vcc));
+
+	vcc->proto_data = dev_lec[i];
+	set_bit(ATM_VF_META, &vcc->flags);
+	set_bit(ATM_VF_READY, &vcc->flags);
+
+	/* Set default values to these variables */
+	priv->maximum_unknown_frame_count = 1;
+	priv->max_unknown_frame_time = (1 * HZ);
+	priv->vcc_timeout_period = (1200 * HZ);
+	priv->max_retry_count = 1;
+	priv->aging_time = (300 * HZ);
+	priv->forward_delay_time = (15 * HZ);
+	priv->topology_change = 0;
+	priv->arp_response_time = (1 * HZ);
+	priv->flush_timeout = (4 * HZ);
+	priv->path_switching_delay = (6 * HZ);
+
+	if (dev_lec[i]->flags & IFF_UP) {
+		netif_start_queue(dev_lec[i]);
+	}
+	__module_get(THIS_MODULE);
+	return i;
 }
 
 #ifdef CONFIG_PROC_FS
-static char* lec_arp_get_status_string(unsigned char status)
+static char *lec_arp_get_status_string(unsigned char status)
 {
 	static char *lec_arp_status_string[] = {
 		"ESI_UNKNOWN       ",
@@ -966,15 +987,14 @@ static void lec_info(struct seq_file *se
 	if (entry->vcc)
 		seq_printf(seq, "%3d %3d ", entry->vcc->vpi, entry->vcc->vci);
 	else
-	        seq_printf(seq, "        ");
+		seq_printf(seq, "        ");
 	if (entry->recv_vcc) {
 		seq_printf(seq, "     %3d %3d", entry->recv_vcc->vpi,
 			   entry->recv_vcc->vci);
-        }
-        seq_putc(seq, '\n');
+	}
+	seq_putc(seq, '\n');
 }
 
-
 struct lec_state {
 	unsigned long flags;
 	struct lec_priv *locked;
@@ -1005,7 +1025,7 @@ static void *lec_tbl_walk(struct lec_sta
 }
 
 static void *lec_arp_walk(struct lec_state *state, loff_t *l,
-			      struct lec_priv *priv)
+			  struct lec_priv *priv)
 {
 	void *v = NULL;
 	int p;
@@ -1046,8 +1066,7 @@ static void *lec_priv_walk(struct lec_st
 		state->locked = priv;
 		spin_lock_irqsave(&priv->lec_arp_lock, state->flags);
 	}
-	if (!lec_arp_walk(state, l, priv) &&
-	    !lec_misc_walk(state, l, priv)) {
+	if (!lec_arp_walk(state, l, priv) && !lec_misc_walk(state, l, priv)) {
 		spin_unlock_irqrestore(&priv->lec_arp_lock, state->flags);
 		state->locked = NULL;
 		/* Partial state reset for the next time we get called */
@@ -1081,7 +1100,7 @@ static void *lec_get_idx(struct lec_stat
 		if (v)
 			break;
 	}
-	return v; 
+	return v;
 }
 
 static void *lec_seq_start(struct seq_file *seq, loff_t *pos)
@@ -1095,7 +1114,7 @@ static void *lec_seq_start(struct seq_fi
 	state->misc_table = 0;
 	state->entry = (void *)1;
 
-	return *pos ? lec_get_idx(state, *pos) : (void*)1;
+	return *pos ? lec_get_idx(state, *pos) : (void *)1;
 }
 
 static void lec_seq_stop(struct seq_file *seq, void *v)
@@ -1120,15 +1139,15 @@ static void *lec_seq_next(struct seq_fil
 
 static int lec_seq_show(struct seq_file *seq, void *v)
 {
-	static char lec_banner[] = "Itf  MAC          ATM destination" 
-		"                          Status            Flags "
-		"VPI/VCI Recv VPI/VCI\n";
+	static char lec_banner[] = "Itf  MAC          ATM destination"
+	    "                          Status            Flags "
+	    "VPI/VCI Recv VPI/VCI\n";
 
 	if (v == (void *)1)
 		seq_puts(seq, lec_banner);
 	else {
 		struct lec_state *state = seq->private;
-		struct net_device *dev = state->dev; 
+		struct net_device *dev = state->dev;
 
 		seq_printf(seq, "%s ", dev->name);
 		lec_info(seq, state->entry);
@@ -1137,10 +1156,10 @@ static int lec_seq_show(struct seq_file 
 }
 
 static struct seq_operations lec_seq_ops = {
-	.start	= lec_seq_start,
-	.next	= lec_seq_next,
-	.stop	= lec_seq_stop,
-	.show	= lec_seq_show,
+	.start = lec_seq_start,
+	.next = lec_seq_next,
+	.stop = lec_seq_stop,
+	.show = lec_seq_show,
 };
 
 static int lec_seq_open(struct inode *inode, struct file *file)
@@ -1174,11 +1193,11 @@ static int lec_seq_release(struct inode 
 }
 
 static struct file_operations lec_seq_fops = {
-	.owner		= THIS_MODULE,
-	.open		= lec_seq_open,
-	.read		= seq_read,
-	.llseek		= seq_lseek,
-	.release	= lec_seq_release,
+	.owner = THIS_MODULE,
+	.open = lec_seq_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = lec_seq_release,
 };
 #endif
 
@@ -1186,38 +1205,38 @@ static int lane_ioctl(struct socket *soc
 {
 	struct atm_vcc *vcc = ATM_SD(sock);
 	int err = 0;
-	
+
 	switch (cmd) {
-		case ATMLEC_CTRL: 
-		case ATMLEC_MCAST:
-		case ATMLEC_DATA:
-			if (!capable(CAP_NET_ADMIN))
-				return -EPERM;
-			break;
-		default:
-			return -ENOIOCTLCMD;
+	case ATMLEC_CTRL:
+	case ATMLEC_MCAST:
+	case ATMLEC_DATA:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+		break;
+	default:
+		return -ENOIOCTLCMD;
 	}
 
 	switch (cmd) {
-		case ATMLEC_CTRL:
-			err = lecd_attach(vcc, (int) arg);
-			if (err >= 0)
-				sock->state = SS_CONNECTED;
-			break;
-		case ATMLEC_MCAST:
-			err = lec_mcast_attach(vcc, (int) arg);
-			break;
-		case ATMLEC_DATA:
-			err = lec_vcc_attach(vcc, (void __user *) arg);
-			break;
+	case ATMLEC_CTRL:
+		err = lecd_attach(vcc, (int)arg);
+		if (err >= 0)
+			sock->state = SS_CONNECTED;
+		break;
+	case ATMLEC_MCAST:
+		err = lec_mcast_attach(vcc, (int)arg);
+		break;
+	case ATMLEC_DATA:
+		err = lec_vcc_attach(vcc, (void __user *)arg);
+		break;
 	}
 
 	return err;
 }
 
 static struct atm_ioctl lane_ioctl_ops = {
-	.owner  = THIS_MODULE,
-	.ioctl  = lane_ioctl,
+	.owner = THIS_MODULE,
+	.ioctl = lane_ioctl,
 };
 
 static int __init lane_module_init(void)
@@ -1231,29 +1250,29 @@ #ifdef CONFIG_PROC_FS
 #endif
 
 	register_atm_ioctl(&lane_ioctl_ops);
-        printk("lec.c: " __DATE__ " " __TIME__ " initialized\n");
-        return 0;
+	printk("lec.c: " __DATE__ " " __TIME__ " initialized\n");
+	return 0;
 }
 
 static void __exit lane_module_cleanup(void)
 {
-        int i;
-        struct lec_priv *priv;
+	int i;
+	struct lec_priv *priv;
 
 	remove_proc_entry("lec", atm_proc_root);
 
 	deregister_atm_ioctl(&lane_ioctl_ops);
 
-        for (i = 0; i < MAX_LEC_ITF; i++) {
-                if (dev_lec[i] != NULL) {
-                        priv = (struct lec_priv *)dev_lec[i]->priv;
+	for (i = 0; i < MAX_LEC_ITF; i++) {
+		if (dev_lec[i] != NULL) {
+			priv = (struct lec_priv *)dev_lec[i]->priv;
 			unregister_netdev(dev_lec[i]);
-                        free_netdev(dev_lec[i]);
-                        dev_lec[i] = NULL;
-                }
-        }
+			free_netdev(dev_lec[i]);
+			dev_lec[i] = NULL;
+		}
+	}
 
-        return;                                    
+	return;
 }
 
 module_init(lane_module_init);
@@ -1267,34 +1286,34 @@ module_exit(lane_module_cleanup);
  * If dst_mac == NULL, targetless LE_ARP will be sent
  */
 static int lane2_resolve(struct net_device *dev, u8 *dst_mac, int force,
-    u8 **tlvs, u32 *sizeoftlvs)
+			 u8 **tlvs, u32 *sizeoftlvs)
 {
 	unsigned long flags;
-        struct lec_priv *priv = (struct lec_priv *)dev->priv;
-        struct lec_arp_table *table;
-        struct sk_buff *skb;
-        int retval;
+	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_arp_table *table;
+	struct sk_buff *skb;
+	int retval;
 
-        if (force == 0) {
+	if (force == 0) {
 		spin_lock_irqsave(&priv->lec_arp_lock, flags);
-                table = lec_arp_find(priv, dst_mac);
+		table = lec_arp_find(priv, dst_mac);
 		spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
-                if(table == NULL)
-                        return -1;
-                
-                *tlvs = kmalloc(table->sizeoftlvs, GFP_ATOMIC);
-                if (*tlvs == NULL)
-                        return -1;
-                
-                memcpy(*tlvs, table->tlvs, table->sizeoftlvs);
-                *sizeoftlvs = table->sizeoftlvs;
-                
-                return 0;
-        }
+		if (table == NULL)
+			return -1;
+
+		*tlvs = kmalloc(table->sizeoftlvs, GFP_ATOMIC);
+		if (*tlvs == NULL)
+			return -1;
+
+		memcpy(*tlvs, table->tlvs, table->sizeoftlvs);
+		*sizeoftlvs = table->sizeoftlvs;
+
+		return 0;
+	}
 
 	if (sizeoftlvs == NULL)
 		retval = send_to_lecd(priv, l_arp_xmt, dst_mac, NULL, NULL);
-		
+
 	else {
 		skb = alloc_skb(*sizeoftlvs, GFP_ATOMIC);
 		if (skb == NULL)
@@ -1303,9 +1322,8 @@ static int lane2_resolve(struct net_devi
 		memcpy(skb->data, *tlvs, *sizeoftlvs);
 		retval = send_to_lecd(priv, l_arp_xmt, dst_mac, NULL, skb);
 	}
-        return retval;
-}        
-
+	return retval;
+}
 
 /*
  * LANE2: 3.1.4, LE_ASSOCIATE.request
@@ -1314,80 +1332,85 @@ static int lane2_resolve(struct net_devi
  * Returns 1 for success, 0 for failure (out of memory)
  *
  */
-static int lane2_associate_req (struct net_device *dev, u8 *lan_dst,
-                         u8 *tlvs, u32 sizeoftlvs)
+static int lane2_associate_req(struct net_device *dev, u8 *lan_dst,
+			       u8 *tlvs, u32 sizeoftlvs)
 {
-        int retval;
-        struct sk_buff *skb;
-        struct lec_priv *priv = (struct lec_priv*)dev->priv;
-
-        if (compare_ether_addr(lan_dst, dev->dev_addr))
-                return (0);       /* not our mac address */
-
-        kfree(priv->tlvs); /* NULL if there was no previous association */
-
-        priv->tlvs = kmalloc(sizeoftlvs, GFP_KERNEL);
-        if (priv->tlvs == NULL)
-                return (0);
-        priv->sizeoftlvs = sizeoftlvs;
-        memcpy(priv->tlvs, tlvs, sizeoftlvs);
-
-        skb = alloc_skb(sizeoftlvs, GFP_ATOMIC);
-        if (skb == NULL)
-                return 0;
-        skb->len = sizeoftlvs;
-        memcpy(skb->data, tlvs, sizeoftlvs);
-        retval = send_to_lecd(priv, l_associate_req, NULL, NULL, skb);
-        if (retval != 0)
-                printk("lec.c: lane2_associate_req() failed\n");
-        /* If the previous association has changed we must
-         * somehow notify other LANE entities about the change
-         */
-        return (1);
+	int retval;
+	struct sk_buff *skb;
+	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+
+	if (compare_ether_addr(lan_dst, dev->dev_addr))
+		return (0);	/* not our mac address */
+
+	kfree(priv->tlvs);	/* NULL if there was no previous association */
+
+	priv->tlvs = kmalloc(sizeoftlvs, GFP_KERNEL);
+	if (priv->tlvs == NULL)
+		return (0);
+	priv->sizeoftlvs = sizeoftlvs;
+	memcpy(priv->tlvs, tlvs, sizeoftlvs);
+
+	skb = alloc_skb(sizeoftlvs, GFP_ATOMIC);
+	if (skb == NULL)
+		return 0;
+	skb->len = sizeoftlvs;
+	memcpy(skb->data, tlvs, sizeoftlvs);
+	retval = send_to_lecd(priv, l_associate_req, NULL, NULL, skb);
+	if (retval != 0)
+		printk("lec.c: lane2_associate_req() failed\n");
+	/*
+	 * If the previous association has changed we must
+	 * somehow notify other LANE entities about the change
+	 */
+	return (1);
 }
 
 /*
  * LANE2: 3.1.5, LE_ASSOCIATE.indication
  *
  */
-static void lane2_associate_ind (struct net_device *dev, u8 *mac_addr,
-    u8 *tlvs, u32 sizeoftlvs)
+static void lane2_associate_ind(struct net_device *dev, u8 *mac_addr,
+				u8 *tlvs, u32 sizeoftlvs)
 {
 #if 0
-        int i = 0;
+	int i = 0;
 #endif
 	struct lec_priv *priv = (struct lec_priv *)dev->priv;
-#if 0 /* Why have the TLVs in LE_ARP entries since we do not use them? When you
-         uncomment this code, make sure the TLVs get freed when entry is killed */
-        struct lec_arp_table *entry = lec_arp_find(priv, mac_addr);
+#if 0				/* 
+				 * Why have the TLVs in LE_ARP entries
+				 * since we do not use them? When you
+				 * uncomment this code, make sure the
+				 * TLVs get freed when entry is killed
+				 */
+	struct lec_arp_table *entry = lec_arp_find(priv, mac_addr);
 
-        if (entry == NULL)
-                return;     /* should not happen */
+	if (entry == NULL)
+		return;		/* should not happen */
 
-        kfree(entry->tlvs);
+	kfree(entry->tlvs);
 
-        entry->tlvs = kmalloc(sizeoftlvs, GFP_KERNEL);
-        if (entry->tlvs == NULL)
-                return;
+	entry->tlvs = kmalloc(sizeoftlvs, GFP_KERNEL);
+	if (entry->tlvs == NULL)
+		return;
 
-        entry->sizeoftlvs = sizeoftlvs;
-        memcpy(entry->tlvs, tlvs, sizeoftlvs);
+	entry->sizeoftlvs = sizeoftlvs;
+	memcpy(entry->tlvs, tlvs, sizeoftlvs);
 #endif
 #if 0
-        printk("lec.c: lane2_associate_ind()\n");
-        printk("dump of tlvs, sizeoftlvs=%d\n", sizeoftlvs);
-        while (i < sizeoftlvs)
-                printk("%02x ", tlvs[i++]);
-        
-        printk("\n");
+	printk("lec.c: lane2_associate_ind()\n");
+	printk("dump of tlvs, sizeoftlvs=%d\n", sizeoftlvs);
+	while (i < sizeoftlvs)
+		printk("%02x ", tlvs[i++]);
+
+	printk("\n");
 #endif
 
-        /* tell MPOA about the TLVs we saw */
-        if (priv->lane2_ops && priv->lane2_ops->associate_indicator) {
-                priv->lane2_ops->associate_indicator(dev, mac_addr,
-                                                     tlvs, sizeoftlvs);
-        }
-        return;
+	/* tell MPOA about the TLVs we saw */
+	if (priv->lane2_ops && priv->lane2_ops->associate_indicator) {
+		priv->lane2_ops->associate_indicator(dev, mac_addr,
+						     tlvs, sizeoftlvs);
+	}
+	return;
 }
 
 /*
