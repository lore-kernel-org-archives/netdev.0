From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/3] forcedeth: coding style cleanups
Date: Thu, 27 Jul 2006 18:50:08 -0700
Message-ID: <20060728015054.223785963@localhost>
References: <20060728015007.625581647@localhost>
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:49334 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932112AbWG1B5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 21:57:01 -0400
To: Ayaz Abdulla <aabdulla@nvidia.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=forcedth-style.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Fix the coding style of the nForce Ethernet driver.
 - typedef's should not be used
 - variable names should not be capitialized
 - structure tags should be lower case
 - add whitespace near keywords
 - don't add paren's to switch cases
 - remove paren's from return
 - don't use __constant_ntohs unless necessary.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

 drivers/net/forcedeth.c |  246 ++++++++++++++++++++++++------------------------
 1 file changed, 123 insertions(+), 123 deletions(-)

--- linux-2.6.orig/drivers/net/forcedeth.c	2006-07-27 17:42:03.000000000 -0700
+++ linux-2.6/drivers/net/forcedeth.c	2006-07-27 17:43:52.000000000 -0700
@@ -381,21 +381,21 @@
 
 /* Big endian: should work, but is untested */
 struct ring_desc {
-	u32 PacketBuffer;
-	u32 FlagLen;
+	u32 buf;
+	u32 flaglen;
 };
 
 struct ring_desc_ex {
-	u32 PacketBufferHigh;
-	u32 PacketBufferLow;
-	u32 TxVlan;
-	u32 FlagLen;
+	u32 bufhigh;
+	u32 buflow;
+	u32 txvlan;
+	u32 flaglen;
 };
 
-typedef union _ring_type {
+union ring_type {
 	struct ring_desc* orig;
 	struct ring_desc_ex* ex;
-} ring_type;
+};
 
 #define FLAG_MASK_V1 0xffff0000
 #define FLAG_MASK_V2 0xffffc000
@@ -713,7 +713,7 @@
 	/* rx specific fields.
 	 * Locking: Within irq hander or disable_irq+spin_lock(&np->lock);
 	 */
-	ring_type rx_ring;
+	union ring_type rx_ring;
 	unsigned int cur_rx, refill_rx;
 	struct sk_buff **rx_skbuff;
 	dma_addr_t *rx_dma;
@@ -733,7 +733,7 @@
 	/*
 	 * tx specific fields.
 	 */
-	ring_type tx_ring;
+	union ring_type tx_ring;
 	unsigned int next_tx, nic_tx;
 	struct sk_buff **tx_skbuff;
 	dma_addr_t *tx_dma;
@@ -826,13 +826,13 @@
 
 static inline u32 nv_descr_getlength(struct ring_desc *prd, u32 v)
 {
-	return le32_to_cpu(prd->FlagLen)
+	return le32_to_cpu(prd->flaglen)
 		& ((v == DESC_VER_1) ? LEN_MASK_V1 : LEN_MASK_V2);
 }
 
 static inline u32 nv_descr_getlength_ex(struct ring_desc_ex *prd, u32 v)
 {
-	return le32_to_cpu(prd->FlagLen) & LEN_MASK_V2;
+	return le32_to_cpu(prd->flaglen) & LEN_MASK_V2;
 }
 
 static int reg_delay(struct net_device *dev, int offset, u32 mask, u32 target,
@@ -885,7 +885,7 @@
 	struct fe_priv *np = get_nvpriv(dev);
 
 	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-		if(np->rx_ring.orig)
+		if (np->rx_ring.orig)
 			pci_free_consistent(np->pci_dev, sizeof(struct ring_desc) * (np->rx_ring_size + np->tx_ring_size),
 					    np->rx_ring.orig, np->ring_addr);
 	} else {
@@ -1258,14 +1258,14 @@
 		np->rx_dma[nr] = pci_map_single(np->pci_dev, skb->data,
 					skb->end-skb->data, PCI_DMA_FROMDEVICE);
 		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-			np->rx_ring.orig[nr].PacketBuffer = cpu_to_le32(np->rx_dma[nr]);
+			np->rx_ring.orig[nr].buf = cpu_to_le32(np->rx_dma[nr]);
 			wmb();
-			np->rx_ring.orig[nr].FlagLen = cpu_to_le32(np->rx_buf_sz | NV_RX_AVAIL);
+			np->rx_ring.orig[nr].flaglen = cpu_to_le32(np->rx_buf_sz | NV_RX_AVAIL);
 		} else {
-			np->rx_ring.ex[nr].PacketBufferHigh = cpu_to_le64(np->rx_dma[nr]) >> 32;
-			np->rx_ring.ex[nr].PacketBufferLow = cpu_to_le64(np->rx_dma[nr]) & 0x0FFFFFFFF;
+			np->rx_ring.ex[nr].bufhigh = cpu_to_le64(np->rx_dma[nr]) >> 32;
+			np->rx_ring.ex[nr].buflow = cpu_to_le64(np->rx_dma[nr]) & 0x0FFFFFFFF;
 			wmb();
-			np->rx_ring.ex[nr].FlagLen = cpu_to_le32(np->rx_buf_sz | NV_RX2_AVAIL);
+			np->rx_ring.ex[nr].flaglen = cpu_to_le32(np->rx_buf_sz | NV_RX2_AVAIL);
 		}
 		dprintk(KERN_DEBUG "%s: nv_alloc_rx: Packet %d marked as Available\n",
 					dev->name, refill_rx);
@@ -1315,9 +1315,9 @@
 	np->refill_rx = 0;
 	for (i = 0; i < np->rx_ring_size; i++)
 		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
-			np->rx_ring.orig[i].FlagLen = 0;
+			np->rx_ring.orig[i].flaglen = 0;
 	        else
-			np->rx_ring.ex[i].FlagLen = 0;
+			np->rx_ring.ex[i].flaglen = 0;
 }
 
 static void nv_init_tx(struct net_device *dev)
@@ -1328,9 +1328,9 @@
 	np->next_tx = np->nic_tx = 0;
 	for (i = 0; i < np->tx_ring_size; i++) {
 		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
-			np->tx_ring.orig[i].FlagLen = 0;
+			np->tx_ring.orig[i].flaglen = 0;
 	        else
-			np->tx_ring.ex[i].FlagLen = 0;
+			np->tx_ring.ex[i].flaglen = 0;
 		np->tx_skbuff[i] = NULL;
 		np->tx_dma[i] = 0;
 	}
@@ -1373,9 +1373,9 @@
 
 	for (i = 0; i < np->tx_ring_size; i++) {
 		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
-			np->tx_ring.orig[i].FlagLen = 0;
+			np->tx_ring.orig[i].flaglen = 0;
 		else
-			np->tx_ring.ex[i].FlagLen = 0;
+			np->tx_ring.ex[i].flaglen = 0;
 		if (nv_release_txskb(dev, i))
 			np->stats.tx_dropped++;
 	}
@@ -1387,9 +1387,9 @@
 	int i;
 	for (i = 0; i < np->rx_ring_size; i++) {
 		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
-			np->rx_ring.orig[i].FlagLen = 0;
+			np->rx_ring.orig[i].flaglen = 0;
 		else
-			np->rx_ring.ex[i].FlagLen = 0;
+			np->rx_ring.ex[i].flaglen = 0;
 		wmb();
 		if (np->rx_skbuff[i]) {
 			pci_unmap_single(np->pci_dev, np->rx_dma[i],
@@ -1450,17 +1450,17 @@
 		np->tx_dma_len[nr] = bcnt;
 
 		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-			np->tx_ring.orig[nr].PacketBuffer = cpu_to_le32(np->tx_dma[nr]);
-			np->tx_ring.orig[nr].FlagLen = cpu_to_le32((bcnt-1) | tx_flags);
+			np->tx_ring.orig[nr].buf = cpu_to_le32(np->tx_dma[nr]);
+			np->tx_ring.orig[nr].flaglen = cpu_to_le32((bcnt-1) | tx_flags);
 		} else {
-			np->tx_ring.ex[nr].PacketBufferHigh = cpu_to_le64(np->tx_dma[nr]) >> 32;
-			np->tx_ring.ex[nr].PacketBufferLow = cpu_to_le64(np->tx_dma[nr]) & 0x0FFFFFFFF;
-			np->tx_ring.ex[nr].FlagLen = cpu_to_le32((bcnt-1) | tx_flags);
+			np->tx_ring.ex[nr].bufhigh = cpu_to_le64(np->tx_dma[nr]) >> 32;
+			np->tx_ring.ex[nr].buflow = cpu_to_le64(np->tx_dma[nr]) & 0x0FFFFFFFF;
+			np->tx_ring.ex[nr].flaglen = cpu_to_le32((bcnt-1) | tx_flags);
 		}
 		tx_flags = np->tx_flags;
 		offset += bcnt;
 		size -= bcnt;
-	} while(size);
+	} while (size);
 
 	/* setup the fragments */
 	for (i = 0; i < fragments; i++) {
@@ -1477,12 +1477,12 @@
 			np->tx_dma_len[nr] = bcnt;
 
 			if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-				np->tx_ring.orig[nr].PacketBuffer = cpu_to_le32(np->tx_dma[nr]);
-				np->tx_ring.orig[nr].FlagLen = cpu_to_le32((bcnt-1) | tx_flags);
+				np->tx_ring.orig[nr].buf = cpu_to_le32(np->tx_dma[nr]);
+				np->tx_ring.orig[nr].flaglen = cpu_to_le32((bcnt-1) | tx_flags);
 			} else {
-				np->tx_ring.ex[nr].PacketBufferHigh = cpu_to_le64(np->tx_dma[nr]) >> 32;
-				np->tx_ring.ex[nr].PacketBufferLow = cpu_to_le64(np->tx_dma[nr]) & 0x0FFFFFFFF;
-				np->tx_ring.ex[nr].FlagLen = cpu_to_le32((bcnt-1) | tx_flags);
+				np->tx_ring.ex[nr].bufhigh = cpu_to_le64(np->tx_dma[nr]) >> 32;
+				np->tx_ring.ex[nr].buflow = cpu_to_le64(np->tx_dma[nr]) & 0x0FFFFFFFF;
+				np->tx_ring.ex[nr].flaglen = cpu_to_le32((bcnt-1) | tx_flags);
 			}
 			offset += bcnt;
 			size -= bcnt;
@@ -1491,9 +1491,9 @@
 
 	/* set last fragment flag  */
 	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-		np->tx_ring.orig[nr].FlagLen |= cpu_to_le32(tx_flags_extra);
+		np->tx_ring.orig[nr].flaglen |= cpu_to_le32(tx_flags_extra);
 	} else {
-		np->tx_ring.ex[nr].FlagLen |= cpu_to_le32(tx_flags_extra);
+		np->tx_ring.ex[nr].flaglen |= cpu_to_le32(tx_flags_extra);
 	}
 
 	np->tx_skbuff[nr] = skb;
@@ -1512,10 +1512,10 @@
 
 	/* set tx flags */
 	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-		np->tx_ring.orig[start_nr].FlagLen |= cpu_to_le32(tx_flags | tx_flags_extra);
+		np->tx_ring.orig[start_nr].flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
 	} else {
-		np->tx_ring.ex[start_nr].TxVlan = cpu_to_le32(tx_flags_vlan);
-		np->tx_ring.ex[start_nr].FlagLen |= cpu_to_le32(tx_flags | tx_flags_extra);
+		np->tx_ring.ex[start_nr].txvlan = cpu_to_le32(tx_flags_vlan);
+		np->tx_ring.ex[start_nr].flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
 	}
 
 	dprintk(KERN_DEBUG "%s: nv_start_xmit: packet %d (entries %d) queued for transmission. tx_flags_extra: %x\n",
@@ -1547,7 +1547,7 @@
 static void nv_tx_done(struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
-	u32 Flags;
+	u32 flags;
 	unsigned int i;
 	struct sk_buff *skb;
 
@@ -1555,22 +1555,22 @@
 		i = np->nic_tx % np->tx_ring_size;
 
 		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
-			Flags = le32_to_cpu(np->tx_ring.orig[i].FlagLen);
+			flags = le32_to_cpu(np->tx_ring.orig[i].flaglen);
 		else
-			Flags = le32_to_cpu(np->tx_ring.ex[i].FlagLen);
+			flags = le32_to_cpu(np->tx_ring.ex[i].flaglen);
 
-		dprintk(KERN_DEBUG "%s: nv_tx_done: looking at packet %d, Flags 0x%x.\n",
-					dev->name, np->nic_tx, Flags);
-		if (Flags & NV_TX_VALID)
+		dprintk(KERN_DEBUG "%s: nv_tx_done: looking at packet %d, flags 0x%x.\n",
+					dev->name, np->nic_tx, flags);
+		if (flags & NV_TX_VALID)
 			break;
 		if (np->desc_ver == DESC_VER_1) {
-			if (Flags & NV_TX_LASTPACKET) {
+			if (flags & NV_TX_LASTPACKET) {
 				skb = np->tx_skbuff[i];
-				if (Flags & (NV_TX_RETRYERROR|NV_TX_CARRIERLOST|NV_TX_LATECOLLISION|
+				if (flags & (NV_TX_RETRYERROR|NV_TX_CARRIERLOST|NV_TX_LATECOLLISION|
 					     NV_TX_UNDERFLOW|NV_TX_ERROR)) {
-					if (Flags & NV_TX_UNDERFLOW)
+					if (flags & NV_TX_UNDERFLOW)
 						np->stats.tx_fifo_errors++;
-					if (Flags & NV_TX_CARRIERLOST)
+					if (flags & NV_TX_CARRIERLOST)
 						np->stats.tx_carrier_errors++;
 					np->stats.tx_errors++;
 				} else {
@@ -1579,13 +1579,13 @@
 				}
 			}
 		} else {
-			if (Flags & NV_TX2_LASTPACKET) {
+			if (flags & NV_TX2_LASTPACKET) {
 				skb = np->tx_skbuff[i];
-				if (Flags & (NV_TX2_RETRYERROR|NV_TX2_CARRIERLOST|NV_TX2_LATECOLLISION|
+				if (flags & (NV_TX2_RETRYERROR|NV_TX2_CARRIERLOST|NV_TX2_LATECOLLISION|
 					     NV_TX2_UNDERFLOW|NV_TX2_ERROR)) {
-					if (Flags & NV_TX2_UNDERFLOW)
+					if (flags & NV_TX2_UNDERFLOW)
 						np->stats.tx_fifo_errors++;
-					if (Flags & NV_TX2_CARRIERLOST)
+					if (flags & NV_TX2_CARRIERLOST)
 						np->stats.tx_carrier_errors++;
 					np->stats.tx_errors++;
 				} else {
@@ -1638,29 +1638,29 @@
 			if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
 				printk(KERN_INFO "%03x: %08x %08x // %08x %08x // %08x %08x // %08x %08x\n",
 				       i,
-				       le32_to_cpu(np->tx_ring.orig[i].PacketBuffer),
-				       le32_to_cpu(np->tx_ring.orig[i].FlagLen),
-				       le32_to_cpu(np->tx_ring.orig[i+1].PacketBuffer),
-				       le32_to_cpu(np->tx_ring.orig[i+1].FlagLen),
-				       le32_to_cpu(np->tx_ring.orig[i+2].PacketBuffer),
-				       le32_to_cpu(np->tx_ring.orig[i+2].FlagLen),
-				       le32_to_cpu(np->tx_ring.orig[i+3].PacketBuffer),
-				       le32_to_cpu(np->tx_ring.orig[i+3].FlagLen));
+				       le32_to_cpu(np->tx_ring.orig[i].buf),
+				       le32_to_cpu(np->tx_ring.orig[i].flaglen),
+				       le32_to_cpu(np->tx_ring.orig[i+1].buf),
+				       le32_to_cpu(np->tx_ring.orig[i+1].flaglen),
+				       le32_to_cpu(np->tx_ring.orig[i+2].buf),
+				       le32_to_cpu(np->tx_ring.orig[i+2].flaglen),
+				       le32_to_cpu(np->tx_ring.orig[i+3].buf),
+				       le32_to_cpu(np->tx_ring.orig[i+3].flaglen));
 			} else {
 				printk(KERN_INFO "%03x: %08x %08x %08x // %08x %08x %08x // %08x %08x %08x // %08x %08x %08x\n",
 				       i,
-				       le32_to_cpu(np->tx_ring.ex[i].PacketBufferHigh),
-				       le32_to_cpu(np->tx_ring.ex[i].PacketBufferLow),
-				       le32_to_cpu(np->tx_ring.ex[i].FlagLen),
-				       le32_to_cpu(np->tx_ring.ex[i+1].PacketBufferHigh),
-				       le32_to_cpu(np->tx_ring.ex[i+1].PacketBufferLow),
-				       le32_to_cpu(np->tx_ring.ex[i+1].FlagLen),
-				       le32_to_cpu(np->tx_ring.ex[i+2].PacketBufferHigh),
-				       le32_to_cpu(np->tx_ring.ex[i+2].PacketBufferLow),
-				       le32_to_cpu(np->tx_ring.ex[i+2].FlagLen),
-				       le32_to_cpu(np->tx_ring.ex[i+3].PacketBufferHigh),
-				       le32_to_cpu(np->tx_ring.ex[i+3].PacketBufferLow),
-				       le32_to_cpu(np->tx_ring.ex[i+3].FlagLen));
+				       le32_to_cpu(np->tx_ring.ex[i].bufhigh),
+				       le32_to_cpu(np->tx_ring.ex[i].buflow),
+				       le32_to_cpu(np->tx_ring.ex[i].flaglen),
+				       le32_to_cpu(np->tx_ring.ex[i+1].bufhigh),
+				       le32_to_cpu(np->tx_ring.ex[i+1].buflow),
+				       le32_to_cpu(np->tx_ring.ex[i+1].flaglen),
+				       le32_to_cpu(np->tx_ring.ex[i+2].bufhigh),
+				       le32_to_cpu(np->tx_ring.ex[i+2].buflow),
+				       le32_to_cpu(np->tx_ring.ex[i+2].flaglen),
+				       le32_to_cpu(np->tx_ring.ex[i+3].bufhigh),
+				       le32_to_cpu(np->tx_ring.ex[i+3].buflow),
+				       le32_to_cpu(np->tx_ring.ex[i+3].flaglen));
 			}
 		}
 	}
@@ -1697,7 +1697,7 @@
 	int protolen;	/* length as stored in the proto field */
 
 	/* 1) calculate len according to header */
-	if ( ((struct vlan_ethhdr *)packet)->h_vlan_proto == __constant_htons(ETH_P_8021Q)) {
+	if ( ((struct vlan_ethhdr *)packet)->h_vlan_proto == htons(ETH_P_8021Q)) {
 		protolen = ntohs( ((struct vlan_ethhdr *)packet)->h_vlan_encapsulated_proto );
 		hdrlen = VLAN_HLEN;
 	} else {
@@ -1743,7 +1743,7 @@
 static void nv_rx_process(struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
-	u32 Flags;
+	u32 flags;
 	u32 vlanflags = 0;
 
 	for (;;) {
@@ -1755,18 +1755,18 @@
 
 		i = np->cur_rx % np->rx_ring_size;
 		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-			Flags = le32_to_cpu(np->rx_ring.orig[i].FlagLen);
+			flags = le32_to_cpu(np->rx_ring.orig[i].flaglen);
 			len = nv_descr_getlength(&np->rx_ring.orig[i], np->desc_ver);
 		} else {
-			Flags = le32_to_cpu(np->rx_ring.ex[i].FlagLen);
+			flags = le32_to_cpu(np->rx_ring.ex[i].flaglen);
 			len = nv_descr_getlength_ex(&np->rx_ring.ex[i], np->desc_ver);
-			vlanflags = le32_to_cpu(np->rx_ring.ex[i].PacketBufferLow);
+			vlanflags = le32_to_cpu(np->rx_ring.ex[i].buflow);
 		}
 
-		dprintk(KERN_DEBUG "%s: nv_rx_process: looking at packet %d, Flags 0x%x.\n",
-					dev->name, np->cur_rx, Flags);
+		dprintk(KERN_DEBUG "%s: nv_rx_process: looking at packet %d, flags 0x%x.\n",
+					dev->name, np->cur_rx, flags);
 
-		if (Flags & NV_RX_AVAIL)
+		if (flags & NV_RX_AVAIL)
 			break;	/* still owned by hardware, */
 
 		/*
@@ -1780,7 +1780,7 @@
 
 		{
 			int j;
-			dprintk(KERN_DEBUG "Dumping packet (flags 0x%x).",Flags);
+			dprintk(KERN_DEBUG "Dumping packet (flags 0x%x).",flags);
 			for (j=0; j<64; j++) {
 				if ((j%16) == 0)
 					dprintk("\n%03x:", j);
@@ -1790,30 +1790,30 @@
 		}
 		/* look at what we actually got: */
 		if (np->desc_ver == DESC_VER_1) {
-			if (!(Flags & NV_RX_DESCRIPTORVALID))
+			if (!(flags & NV_RX_DESCRIPTORVALID))
 				goto next_pkt;
 
-			if (Flags & NV_RX_ERROR) {
-				if (Flags & NV_RX_MISSEDFRAME) {
+			if (flags & NV_RX_ERROR) {
+				if (flags & NV_RX_MISSEDFRAME) {
 					np->stats.rx_missed_errors++;
 					np->stats.rx_errors++;
 					goto next_pkt;
 				}
-				if (Flags & (NV_RX_ERROR1|NV_RX_ERROR2|NV_RX_ERROR3)) {
+				if (flags & (NV_RX_ERROR1|NV_RX_ERROR2|NV_RX_ERROR3)) {
 					np->stats.rx_errors++;
 					goto next_pkt;
 				}
-				if (Flags & NV_RX_CRCERR) {
+				if (flags & NV_RX_CRCERR) {
 					np->stats.rx_crc_errors++;
 					np->stats.rx_errors++;
 					goto next_pkt;
 				}
-				if (Flags & NV_RX_OVERFLOW) {
+				if (flags & NV_RX_OVERFLOW) {
 					np->stats.rx_over_errors++;
 					np->stats.rx_errors++;
 					goto next_pkt;
 				}
-				if (Flags & NV_RX_ERROR4) {
+				if (flags & NV_RX_ERROR4) {
 					len = nv_getlen(dev, np->rx_skbuff[i]->data, len);
 					if (len < 0) {
 						np->stats.rx_errors++;
@@ -1821,32 +1821,32 @@
 					}
 				}
 				/* framing errors are soft errors. */
-				if (Flags & NV_RX_FRAMINGERR) {
-					if (Flags & NV_RX_SUBSTRACT1) {
+				if (flags & NV_RX_FRAMINGERR) {
+					if (flags & NV_RX_SUBSTRACT1) {
 						len--;
 					}
 				}
 			}
 		} else {
-			if (!(Flags & NV_RX2_DESCRIPTORVALID))
+			if (!(flags & NV_RX2_DESCRIPTORVALID))
 				goto next_pkt;
 
-			if (Flags & NV_RX2_ERROR) {
-				if (Flags & (NV_RX2_ERROR1|NV_RX2_ERROR2|NV_RX2_ERROR3)) {
+			if (flags & NV_RX2_ERROR) {
+				if (flags & (NV_RX2_ERROR1|NV_RX2_ERROR2|NV_RX2_ERROR3)) {
 					np->stats.rx_errors++;
 					goto next_pkt;
 				}
-				if (Flags & NV_RX2_CRCERR) {
+				if (flags & NV_RX2_CRCERR) {
 					np->stats.rx_crc_errors++;
 					np->stats.rx_errors++;
 					goto next_pkt;
 				}
-				if (Flags & NV_RX2_OVERFLOW) {
+				if (flags & NV_RX2_OVERFLOW) {
 					np->stats.rx_over_errors++;
 					np->stats.rx_errors++;
 					goto next_pkt;
 				}
-				if (Flags & NV_RX2_ERROR4) {
+				if (flags & NV_RX2_ERROR4) {
 					len = nv_getlen(dev, np->rx_skbuff[i]->data, len);
 					if (len < 0) {
 						np->stats.rx_errors++;
@@ -1854,17 +1854,17 @@
 					}
 				}
 				/* framing errors are soft errors */
-				if (Flags & NV_RX2_FRAMINGERR) {
-					if (Flags & NV_RX2_SUBSTRACT1) {
+				if (flags & NV_RX2_FRAMINGERR) {
+					if (flags & NV_RX2_SUBSTRACT1) {
 						len--;
 					}
 				}
 			}
 			if (np->txrxctl_bits & NVREG_TXRXCTL_RXCHECK) {
-				Flags &= NV_RX2_CHECKSUMMASK;
-				if (Flags == NV_RX2_CHECKSUMOK1 ||
-				    Flags == NV_RX2_CHECKSUMOK2 ||
-				    Flags == NV_RX2_CHECKSUMOK3) {
+				flags &= NV_RX2_CHECKSUMMASK;
+				if (flags == NV_RX2_CHECKSUMOK1 ||
+				    flags == NV_RX2_CHECKSUMOK2 ||
+				    flags == NV_RX2_CHECKSUMOK3) {
 					dprintk(KERN_DEBUG "%s: hw checksum hit!.\n", dev->name);
 					np->rx_skbuff[i]->ip_summed = CHECKSUM_UNNECESSARY;
 				} else {
@@ -1990,7 +1990,7 @@
 	struct fe_priv *np = netdev_priv(dev);
 	struct sockaddr *macaddr = (struct sockaddr*)addr;
 
-	if(!is_valid_ether_addr(macaddr->sa_data))
+	if (!is_valid_ether_addr(macaddr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	/* synchronized against open : rtnl_lock() held by caller */
@@ -2283,20 +2283,20 @@
 			lpa_pause = lpa & (LPA_PAUSE_CAP| LPA_PAUSE_ASYM);
 
 			switch (adv_pause) {
-			case (ADVERTISE_PAUSE_CAP):
+			case ADVERTISE_PAUSE_CAP:
 				if (lpa_pause & LPA_PAUSE_CAP) {
 					pause_flags |= NV_PAUSEFRAME_RX_ENABLE;
 					if (np->pause_flags & NV_PAUSEFRAME_TX_REQ)
 						pause_flags |= NV_PAUSEFRAME_TX_ENABLE;
 				}
 				break;
-			case (ADVERTISE_PAUSE_ASYM):
+			case ADVERTISE_PAUSE_ASYM:
 				if (lpa_pause == (LPA_PAUSE_CAP| LPA_PAUSE_ASYM))
 				{
 					pause_flags |= NV_PAUSEFRAME_TX_ENABLE;
 				}
 				break;
-			case (ADVERTISE_PAUSE_CAP| ADVERTISE_PAUSE_ASYM):
+			case ADVERTISE_PAUSE_CAP| ADVERTISE_PAUSE_ASYM:
 				if (lpa_pause & LPA_PAUSE_CAP)
 				{
 					pause_flags |=  NV_PAUSEFRAME_RX_ENABLE;
@@ -3245,7 +3245,7 @@
 	if (!rxtx_ring || !rx_skbuff || !rx_dma || !tx_skbuff || !tx_dma || !tx_dma_len) {
 		/* fall back to old rings */
 		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-			if(rxtx_ring)
+			if (rxtx_ring)
 				pci_free_consistent(np->pci_dev, sizeof(struct ring_desc) * (ring->rx_pending + ring->tx_pending),
 						    rxtx_ring, ring_addr);
 		} else {
@@ -3481,7 +3481,7 @@
 	struct fe_priv *np = netdev_priv(dev);
 
 	if (np->driver_data & DEV_HAS_STATISTICS)
-		return (sizeof(struct nv_ethtool_stats)/sizeof(u64));
+		return sizeof(struct nv_ethtool_stats)/sizeof(u64);
 	else
 		return 0;
 }
@@ -3619,7 +3619,7 @@
 	struct sk_buff *tx_skb, *rx_skb;
 	dma_addr_t test_dma_addr;
 	u32 tx_flags_extra = (np->desc_ver == DESC_VER_1 ? NV_TX_LASTPACKET : NV_TX2_LASTPACKET);
-	u32 Flags;
+	u32 flags;
 	int len, i, pkt_len;
 	u8 *pkt_data;
 	u32 filter_flags = 0;
@@ -3663,12 +3663,12 @@
 				       tx_skb->end-tx_skb->data, PCI_DMA_FROMDEVICE);
 
 	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-		np->tx_ring.orig[0].PacketBuffer = cpu_to_le32(test_dma_addr);
-		np->tx_ring.orig[0].FlagLen = cpu_to_le32((pkt_len-1) | np->tx_flags | tx_flags_extra);
+		np->tx_ring.orig[0].buf = cpu_to_le32(test_dma_addr);
+		np->tx_ring.orig[0].flaglen = cpu_to_le32((pkt_len-1) | np->tx_flags | tx_flags_extra);
 	} else {
-		np->tx_ring.ex[0].PacketBufferHigh = cpu_to_le64(test_dma_addr) >> 32;
-		np->tx_ring.ex[0].PacketBufferLow = cpu_to_le64(test_dma_addr) & 0x0FFFFFFFF;
-		np->tx_ring.ex[0].FlagLen = cpu_to_le32((pkt_len-1) | np->tx_flags | tx_flags_extra);
+		np->tx_ring.ex[0].bufhigh = cpu_to_le64(test_dma_addr) >> 32;
+		np->tx_ring.ex[0].buflow = cpu_to_le64(test_dma_addr) & 0x0FFFFFFFF;
+		np->tx_ring.ex[0].flaglen = cpu_to_le32((pkt_len-1) | np->tx_flags | tx_flags_extra);
 	}
 	writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
 	pci_push(get_hwbase(dev));
@@ -3677,21 +3677,21 @@
 
 	/* check for rx of the packet */
 	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-		Flags = le32_to_cpu(np->rx_ring.orig[0].FlagLen);
+		flags = le32_to_cpu(np->rx_ring.orig[0].flaglen);
 		len = nv_descr_getlength(&np->rx_ring.orig[0], np->desc_ver);
 
 	} else {
-		Flags = le32_to_cpu(np->rx_ring.ex[0].FlagLen);
+		flags = le32_to_cpu(np->rx_ring.ex[0].flaglen);
 		len = nv_descr_getlength_ex(&np->rx_ring.ex[0], np->desc_ver);
 	}
 
-	if (Flags & NV_RX_AVAIL) {
+	if (flags & NV_RX_AVAIL) {
 		ret = 0;
 	} else if (np->desc_ver == DESC_VER_1) {
-		if (Flags & NV_RX_ERROR)
+		if (flags & NV_RX_ERROR)
 			ret = 0;
 	} else {
-		if (Flags & NV_RX2_ERROR) {
+		if (flags & NV_RX2_ERROR) {
 			ret = 0;
 		}
 	}

--

