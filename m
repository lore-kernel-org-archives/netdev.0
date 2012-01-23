From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Subject: [PATCH/RESEND net 3/5][TRIVIAL 3/4] drivers/net/ethernet: dev_alloc_skb to netdev_alloc_skb
Date: Tue, 24 Jan 2012 03:24:42 +0530
Message-ID: <1327355682-7596-1-git-send-email-netdev@pradeepdalvi.com>
Mime-Version: 1.0
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/net/ethernet
  - Removed extra skb->dev = dev after netdev_alloc_skb

Signed-off-by: Pradeep A. Dalvi <netdev@pradeepdalvi.com>
---
 drivers/net/ethernet/fujitsu/eth16i.c      |    2 +-
 drivers/net/ethernet/fujitsu/fmvj18x_cs.c  |    2 +-
 drivers/net/ethernet/hp/hp100.c            |    5 ++---
 drivers/net/ethernet/i825xx/3c505.c        |    2 +-
 drivers/net/ethernet/i825xx/3c507.c        |    2 +-
 drivers/net/ethernet/i825xx/3c523.c        |    2 +-
 drivers/net/ethernet/i825xx/3c527.c        |    4 ++--
 drivers/net/ethernet/i825xx/82596.c        |    8 +++-----
 drivers/net/ethernet/i825xx/eepro.c        |    2 +-
 drivers/net/ethernet/i825xx/eexpress.c     |    2 +-
 drivers/net/ethernet/i825xx/ether1.c       |    2 +-
 drivers/net/ethernet/i825xx/lp486e.c       |    2 +-
 drivers/net/ethernet/i825xx/ni52.c         |    2 +-
 drivers/net/ethernet/i825xx/sun3_82586.c   |    2 +-
 drivers/net/ethernet/i825xx/znet.c         |    2 +-
 drivers/net/ethernet/icplus/ipg.c          |    3 ---
 drivers/net/ethernet/lantiq_etop.c         |    2 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c |    2 +-
 drivers/net/ethernet/marvell/pxa168_eth.c  |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |    3 +--
 drivers/net/ethernet/micrel/ks8695net.c    |    4 ++--
 drivers/net/ethernet/micrel/ks8851_mll.c   |    2 +-
 drivers/net/ethernet/micrel/ksz884x.c      |    6 +++---
 drivers/net/ethernet/microchip/enc28j60.c  |    3 +--
 drivers/net/ethernet/mipsnet.c             |    2 +-
 drivers/net/ethernet/natsemi/ibmlana.c     |    2 +-
 drivers/net/ethernet/natsemi/natsemi.c     |    5 ++---
 drivers/net/ethernet/natsemi/sonic.c       |    4 ++--
 drivers/net/ethernet/neterion/s2io.c       |    6 +++---
 29 files changed, 39 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/fujitsu/eth16i.c b/drivers/net/ethernet/fujitsu/eth16i.c
index b0e2313..c3f0178 100644
--- a/drivers/net/ethernet/fujitsu/eth16i.c
+++ b/drivers/net/ethernet/fujitsu/eth16i.c
@@ -1164,7 +1164,7 @@ static void eth16i_rx(struct net_device *dev)
 		else {   /* Ok so now we should have a good packet */
 			struct sk_buff *skb;
 
-			skb = dev_alloc_skb(pkt_len + 3);
+			skb = netdev_alloc_skb(dev, pkt_len + 3);
 			if( skb == NULL ) {
 				printk(KERN_WARNING "%s: Could'n allocate memory for packet (len %d)\n",
 				       dev->name, pkt_len);
diff --git a/drivers/net/ethernet/fujitsu/fmvj18x_cs.c b/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
index ee84b47..0230319 100644
--- a/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
+++ b/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
@@ -1002,7 +1002,7 @@ static void fjn_rx(struct net_device *dev)
 		dev->stats.rx_errors++;
 		break;
 	    }
-	    skb = dev_alloc_skb(pkt_len+2);
+	    skb = netdev_alloc_skb(dev, pkt_len + 2);
 	    if (skb == NULL) {
 		netdev_notice(dev, "Memory squeeze, dropping packet (len %d)\n",
 			      pkt_len);
diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index 6a5ee07..fc9e4b5 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -1274,7 +1274,7 @@ static int hp100_build_rx_pdl(hp100_ring_t * ringptr,
 	/* Note: This depends on the alloc_skb functions allocating more
 	 * space than requested, i.e. aligning to 16bytes */
 
-	ringptr->skb = dev_alloc_skb(roundup(MAX_ETHER_SIZE + 2, 4));
+	ringptr->skb = netdev_alloc_skb(dev, roundup(MAX_ETHER_SIZE + 2, 4));
 
 	if (NULL != ringptr->skb) {
 		/*
@@ -1284,7 +1284,6 @@ static int hp100_build_rx_pdl(hp100_ring_t * ringptr,
 		 */
 		skb_reserve(ringptr->skb, 2);
 
-		ringptr->skb->dev = dev;
 		ringptr->skb->data = (u_char *) skb_put(ringptr->skb, MAX_ETHER_SIZE);
 
 		/* ringptr->pdl points to the beginning of the PDL, i.e. the PDH */
@@ -1817,7 +1816,7 @@ static void hp100_rx(struct net_device *dev)
 #endif
 
 		/* Now we allocate the skb and transfer the data into it. */
-		skb = dev_alloc_skb(pkt_len+2);
+		skb = netdev_alloc_skb(dev, pkt_len + 2);
 		if (skb == NULL) {	/* Not enough memory->drop packet */
 #ifdef HP100_DEBUG
 			printk("hp100: %s: rx: couldn't allocate a sk_buff of size %d\n",
diff --git a/drivers/net/ethernet/i825xx/3c505.c b/drivers/net/ethernet/i825xx/3c505.c
index ba82a26..6a5c21b 100644
--- a/drivers/net/ethernet/i825xx/3c505.c
+++ b/drivers/net/ethernet/i825xx/3c505.c
@@ -583,7 +583,7 @@ static void receive_packet(struct net_device *dev, int len)
 	unsigned long flags;
 
 	rlen = (len + 1) & ~1;
-	skb = dev_alloc_skb(rlen + 2);
+	skb = netdev_alloc_skb(dev, rlen + 2);
 
 	if (!skb) {
 		pr_warning("%s: memory squeeze, dropping packet\n", dev->name);
diff --git a/drivers/net/ethernet/i825xx/3c507.c b/drivers/net/ethernet/i825xx/3c507.c
index 1e94555..ed6925f 100644
--- a/drivers/net/ethernet/i825xx/3c507.c
+++ b/drivers/net/ethernet/i825xx/3c507.c
@@ -851,7 +851,7 @@ static void el16_rx(struct net_device *dev)
 			struct sk_buff *skb;
 
 			pkt_len &= 0x3fff;
-			skb = dev_alloc_skb(pkt_len+2);
+			skb = netdev_alloc_skb(dev, pkt_len + 2);
 			if (skb == NULL) {
 				pr_err("%s: Memory squeeze, dropping packet.\n",
 				       dev->name);
diff --git a/drivers/net/ethernet/i825xx/3c523.c b/drivers/net/ethernet/i825xx/3c523.c
index d70d3df..8451ecd 100644
--- a/drivers/net/ethernet/i825xx/3c523.c
+++ b/drivers/net/ethernet/i825xx/3c523.c
@@ -983,7 +983,7 @@ static void elmc_rcv_int(struct net_device *dev)
 			if ((totlen = rbd->status) & RBD_LAST) {	/* the first and the last buffer? */
 				totlen &= RBD_MASK;	/* length of this frame */
 				rbd->status = 0;
-				skb = (struct sk_buff *) dev_alloc_skb(totlen + 2);
+				skb = netdev_alloc_skb(dev, totlen + 2);
 				if (skb != NULL) {
 					skb_reserve(skb, 2);	/* 16 byte alignment */
 					skb_put(skb,totlen);
diff --git a/drivers/net/ethernet/i825xx/3c527.c b/drivers/net/ethernet/i825xx/3c527.c
index 474b5e7..ef43f3e 100644
--- a/drivers/net/ethernet/i825xx/3c527.c
+++ b/drivers/net/ethernet/i825xx/3c527.c
@@ -1169,7 +1169,7 @@ static void mc32_rx_ring(struct net_device *dev)
 			/* Try to save time by avoiding a copy on big frames */
 
 			if ((length > RX_COPYBREAK) &&
-			    ((newskb=dev_alloc_skb(1532)) != NULL))
+			    ((newskb = netdev_alloc_skb(dev, 1532)) != NULL))
 			{
 				skb=lp->rx_ring[rx_ring_tail].skb;
 				skb_put(skb, length);
@@ -1180,7 +1180,7 @@ static void mc32_rx_ring(struct net_device *dev)
 			}
 			else
 			{
-				skb=dev_alloc_skb(length+2);
+				skb = netdev_alloc_skb(dev, length + 2);
 
 				if(skb==NULL) {
 					dev->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/i825xx/82596.c b/drivers/net/ethernet/i825xx/82596.c
index f2408a4..6aa927a 100644
--- a/drivers/net/ethernet/i825xx/82596.c
+++ b/drivers/net/ethernet/i825xx/82596.c
@@ -549,14 +549,13 @@ static inline int init_rx_bufs(struct net_device *dev)
 	/* First build the Receive Buffer Descriptor List */
 
 	for (i = 0, rbd = lp->rbds; i < rx_ring_size; i++, rbd++) {
-		struct sk_buff *skb = dev_alloc_skb(PKT_BUF_SZ);
+		struct sk_buff *skb = netdev_alloc_skb(dev, PKT_BUF_SZ);
 
 		if (skb == NULL) {
 			remove_rx_bufs(dev);
 			return -ENOMEM;
 		}
 
-		skb->dev = dev;
 		rbd->v_next = rbd+1;
 		rbd->b_next = WSWAPrbd(virt_to_bus(rbd+1));
 		rbd->b_addr = WSWAPrbd(virt_to_bus(rbd));
@@ -810,7 +809,7 @@ static inline int i596_rx(struct net_device *dev)
 				struct sk_buff *newskb;
 
 				/* Get fresh skbuff to replace filled one. */
-				newskb = dev_alloc_skb(PKT_BUF_SZ);
+				newskb = netdev_alloc_skb(dev, PKT_BUF_SZ);
 				if (newskb == NULL) {
 					skb = NULL;	/* drop pkt */
 					goto memory_squeeze;
@@ -819,7 +818,6 @@ static inline int i596_rx(struct net_device *dev)
 				skb_put(skb, pkt_len);
 				rx_in_place = 1;
 				rbd->skb = newskb;
-				newskb->dev = dev;
 				rbd->v_data = newskb->data;
 				rbd->b_data = WSWAPchar(virt_to_bus(newskb->data));
 #ifdef __mc68000__
@@ -827,7 +825,7 @@ static inline int i596_rx(struct net_device *dev)
 #endif
 			}
 			else
-				skb = dev_alloc_skb(pkt_len + 2);
+				skb = netdev_alloc_skb(dev, pkt_len + 2);
 memory_squeeze:
 			if (skb == NULL) {
 				/* XXX tulip.c can defer packets here!! */
diff --git a/drivers/net/ethernet/i825xx/eepro.c b/drivers/net/ethernet/i825xx/eepro.c
index 114cda77..7a4ad4a 100644
--- a/drivers/net/ethernet/i825xx/eepro.c
+++ b/drivers/net/ethernet/i825xx/eepro.c
@@ -1563,7 +1563,7 @@ eepro_rx(struct net_device *dev)
 
 			dev->stats.rx_bytes+=rcv_size;
 			rcv_size &= 0x3fff;
-			skb = dev_alloc_skb(rcv_size+5);
+			skb = netdev_alloc_skb(dev, rcv_size + 5);
 			if (skb == NULL) {
 				printk(KERN_NOTICE "%s: Memory squeeze, dropping packet.\n", dev->name);
 				dev->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/i825xx/eexpress.c b/drivers/net/ethernet/i825xx/eexpress.c
index 3a9580f..3fc649e 100644
--- a/drivers/net/ethernet/i825xx/eexpress.c
+++ b/drivers/net/ethernet/i825xx/eexpress.c
@@ -955,7 +955,7 @@ static void eexp_hw_rx_pio(struct net_device *dev)
 			{
 				struct sk_buff *skb;
 				pkt_len &= 0x3fff;
-				skb = dev_alloc_skb(pkt_len+16);
+				skb = netdev_alloc_skb(dev, pkt_len + 16);
 				if (skb == NULL)
 				{
 					printk(KERN_WARNING "%s: Memory squeeze, dropping packet\n",dev->name);
diff --git a/drivers/net/ethernet/i825xx/ether1.c b/drivers/net/ethernet/i825xx/ether1.c
index 42e90a9..406a12b 100644
--- a/drivers/net/ethernet/i825xx/ether1.c
+++ b/drivers/net/ethernet/i825xx/ether1.c
@@ -867,7 +867,7 @@ ether1_recv_done (struct net_device *dev)
 			struct sk_buff *skb;
 
 			length = (length + 1) & ~1;
-			skb = dev_alloc_skb (length + 2);
+			skb = netdev_alloc_skb(dev, length + 2);
 
 			if (skb) {
 				skb_reserve (skb, 2);
diff --git a/drivers/net/ethernet/i825xx/lp486e.c b/drivers/net/ethernet/i825xx/lp486e.c
index 414044b..2ad5f10 100644
--- a/drivers/net/ethernet/i825xx/lp486e.c
+++ b/drivers/net/ethernet/i825xx/lp486e.c
@@ -658,7 +658,7 @@ i596_rx_one(struct net_device *dev, struct i596_private *lp,
 	if (rfd->stat & RFD_STAT_OK) {
 		/* a good frame */
 		int pkt_len = (rfd->count & 0x3fff);
-		struct sk_buff *skb = dev_alloc_skb(pkt_len);
+		struct sk_buff *skb = netdev_alloc_skb(dev, pkt_len);
 
 		(*frames)++;
 
diff --git a/drivers/net/ethernet/i825xx/ni52.c b/drivers/net/ethernet/i825xx/ni52.c
index c089371..272976e 100644
--- a/drivers/net/ethernet/i825xx/ni52.c
+++ b/drivers/net/ethernet/i825xx/ni52.c
@@ -964,7 +964,7 @@ static void ni52_rcv_int(struct net_device *dev)
 				/* the first and the last buffer? */
 				totlen &= RBD_MASK; /* length of this frame */
 				writew(0x00, &rbd->status);
-				skb = (struct sk_buff *)dev_alloc_skb(totlen+2);
+				skb = netdev_alloc_skb(dev, totlen + 2);
 				if (skb != NULL) {
 					skb_reserve(skb, 2);
 					skb_put(skb, totlen);
diff --git a/drivers/net/ethernet/i825xx/sun3_82586.c b/drivers/net/ethernet/i825xx/sun3_82586.c
index 6ef5e11..5a523dc 100644
--- a/drivers/net/ethernet/i825xx/sun3_82586.c
+++ b/drivers/net/ethernet/i825xx/sun3_82586.c
@@ -779,7 +779,7 @@ static void sun3_82586_rcv_int(struct net_device *dev)
 				{
 					totlen &= RBD_MASK; /* length of this frame */
 					rbd->status = 0;
-					skb = (struct sk_buff *) dev_alloc_skb(totlen+2);
+					skb = netdev_alloc_skb(dev, totlen + 2);
 					if(skb != NULL)
 					{
 						skb_reserve(skb,2);
diff --git a/drivers/net/ethernet/i825xx/znet.c b/drivers/net/ethernet/i825xx/znet.c
index 962b4c4..a436497 100644
--- a/drivers/net/ethernet/i825xx/znet.c
+++ b/drivers/net/ethernet/i825xx/znet.c
@@ -762,7 +762,7 @@ static void znet_rx(struct net_device *dev)
 			/* Malloc up new buffer. */
 			struct sk_buff *skb;
 
-			skb = dev_alloc_skb(pkt_len);
+			skb = netdev_alloc_skb(dev, pkt_len);
 			if (skb == NULL) {
 				if (znet_debug)
 				  printk(KERN_WARNING "%s: Memory squeeze, dropping packet.\n", dev->name);
diff --git a/drivers/net/ethernet/icplus/ipg.c b/drivers/net/ethernet/icplus/ipg.c
index 075451d..2e6c756 100644
--- a/drivers/net/ethernet/icplus/ipg.c
+++ b/drivers/net/ethernet/icplus/ipg.c
@@ -744,9 +744,6 @@ static int ipg_get_rxbuff(struct net_device *dev, int entry)
 		return -ENOMEM;
 	}
 
-	/* Associate the receive buffer with the IPG NIC. */
-	skb->dev = dev;
-
 	/* Save the address of the sk_buff structure. */
 	sp->rx_buff[entry] = skb;
 
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 85e2c6c..ce54778 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -114,7 +114,7 @@ struct ltq_etop_priv {
 static int
 ltq_etop_alloc_skb(struct ltq_etop_chan *ch)
 {
-	ch->skb[ch->dma.desc] = dev_alloc_skb(MAX_DMA_DATA_LEN);
+	ch->skb[ch->dma.desc] = netdev_alloc_skb(ch->netdev, MAX_DMA_DATA_LEN);
 	if (!ch->skb[ch->dma.desc])
 		return -ENOMEM;
 	ch->dma.desc_base[ch->dma.desc].addr = dma_map_single(NULL,
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 9c049d2..e3eea0e 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -662,7 +662,7 @@ static int rxq_refill(struct rx_queue *rxq, int budget)
 
 		skb = __skb_dequeue(&mp->rx_recycle);
 		if (skb == NULL)
-			skb = dev_alloc_skb(mp->skb_size);
+			skb = netdev_alloc_skb(mp->dev, mp->skb_size);
 
 		if (skb == NULL) {
 			mp->oom = 1;
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 953ba58..a76bf553 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -350,7 +350,7 @@ static void rxq_refill(struct net_device *dev)
 	while (pep->rx_desc_count < pep->rx_ring_size) {
 		int size;
 
-		skb = dev_alloc_skb(pep->skb_size);
+		skb = netdev_alloc_skb(dev, pep->skb_size);
 		if (!skb)
 			break;
 		if (SKB_DMA_REALIGN)
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 971d4b6..700f802 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -464,12 +464,11 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 	int used_frags;
 	dma_addr_t dma;
 
-	skb = dev_alloc_skb(SMALL_PACKET_SIZE + NET_IP_ALIGN);
+	skb = netdev_alloc_skb(priv->dev, SMALL_PACKET_SIZE + NET_IP_ALIGN);
 	if (!skb) {
 		en_dbg(RX_ERR, priv, "Failed allocating skb\n");
 		return NULL;
 	}
-	skb->dev = priv->dev;
 	skb_reserve(skb, NET_IP_ALIGN);
 	skb->len = length;
 
diff --git a/drivers/net/ethernet/micrel/ks8695net.c b/drivers/net/ethernet/micrel/ks8695net.c
index ab81c0d..bce9acc 100644
--- a/drivers/net/ethernet/micrel/ks8695net.c
+++ b/drivers/net/ethernet/micrel/ks8695net.c
@@ -278,7 +278,8 @@ ks8695_refill_rxbuffers(struct ks8695_priv *ksp)
 
 	for (buff_n = 0; buff_n < MAX_RX_DESC; ++buff_n) {
 		if (!ksp->rx_buffers[buff_n].skb) {
-			struct sk_buff *skb = dev_alloc_skb(MAX_RXBUF_SIZE);
+			struct sk_buff *skb =
+				netdev_alloc_skb(ksp->ndev, MAX_RXBUF_SIZE);
 			dma_addr_t mapping;
 
 			ksp->rx_buffers[buff_n].skb = skb;
@@ -299,7 +300,6 @@ ks8695_refill_rxbuffers(struct ks8695_priv *ksp)
 				break;
 			}
 			ksp->rx_buffers[buff_n].dma_ptr = mapping;
-			skb->dev = ksp->ndev;
 			ksp->rx_buffers[buff_n].length = MAX_RXBUF_SIZE;
 
 			/* Record this into the DMA ring */
diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index e58e78e..076996f 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -796,7 +796,7 @@ static void ks_rcv(struct ks_net *ks, struct net_device *netdev)
 
 	frame_hdr = ks->frame_head_info;
 	while (ks->frame_cnt--) {
-		skb = dev_alloc_skb(frame_hdr->len + 16);
+		skb = netdev_alloc_skb(netdev, frame_hdr->len + 16);
 		if (likely(skb && (frame_hdr->sts & RXFSHR_RXFV) &&
 			(frame_hdr->len < RX_BUF_SIZE) && frame_hdr->len)) {
 			skb_reserve(skb, 2);
diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index e52cd31..04276c9 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -4863,7 +4863,7 @@ static netdev_tx_t netdev_tx(struct sk_buff *skb, struct net_device *dev)
 				memset(&skb->data[skb->len], 0, 50 - skb->len);
 				skb->len = 50;
 			} else {
-				skb = dev_alloc_skb(50);
+				skb = netdev_alloc_skb(dev, 50);
 				if (!skb)
 					return NETDEV_TX_BUSY;
 				memcpy(skb->data, org_skb->data, org_skb->len);
@@ -4885,7 +4885,7 @@ static netdev_tx_t netdev_tx(struct sk_buff *skb, struct net_device *dev)
 				(ETH_P_IPV6 == htons(skb->protocol)))) {
 			struct sk_buff *org_skb = skb;
 
-			skb = dev_alloc_skb(org_skb->len);
+			skb = netdev_alloc_skb(dev, org_skb->len);
 			if (!skb) {
 				rc = NETDEV_TX_BUSY;
 				goto unlock;
@@ -5019,7 +5019,7 @@ static inline int rx_proc(struct net_device *dev, struct ksz_hw* hw,
 
 	do {
 		/* skb->data != skb->head */
-		skb = dev_alloc_skb(packet_len + 2);
+		skb = netdev_alloc_skb(dev, packet_len + 2);
 		if (!skb) {
 			dev->stats.rx_dropped++;
 			return -ENOMEM;
diff --git a/drivers/net/ethernet/microchip/enc28j60.c b/drivers/net/ethernet/microchip/enc28j60.c
index 50055e0..4125478 100644
--- a/drivers/net/ethernet/microchip/enc28j60.c
+++ b/drivers/net/ethernet/microchip/enc28j60.c
@@ -954,14 +954,13 @@ static void enc28j60_hw_rx(struct net_device *ndev)
 		if (len > MAX_FRAMELEN)
 			ndev->stats.rx_over_errors++;
 	} else {
-		skb = dev_alloc_skb(len + NET_IP_ALIGN);
+		skb = netdev_alloc_skb(ndev, len + NET_IP_ALIGN);
 		if (!skb) {
 			if (netif_msg_rx_err(priv))
 				dev_err(&ndev->dev,
 					"out of memory for Rx'd frame\n");
 			ndev->stats.rx_dropped++;
 		} else {
-			skb->dev = ndev;
 			skb_reserve(skb, NET_IP_ALIGN);
 			/* copy the packet from the receive buffer */
 			enc28j60_mem_read(priv,
diff --git a/drivers/net/ethernet/mipsnet.c b/drivers/net/ethernet/mipsnet.c
index d05b0c9..dbc666a 100644
--- a/drivers/net/ethernet/mipsnet.c
+++ b/drivers/net/ethernet/mipsnet.c
@@ -152,7 +152,7 @@ static inline ssize_t mipsnet_get_fromdev(struct net_device *dev, size_t len)
 	if (!len)
 		return len;
 
-	skb = dev_alloc_skb(len + NET_IP_ALIGN);
+	skb = netdev_alloc_skb(dev, len + NET_IP_ALIGN);
 	if (!skb) {
 		dev->stats.rx_dropped++;
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/natsemi/ibmlana.c b/drivers/net/ethernet/natsemi/ibmlana.c
index 999407f..3f94ddb 100644
--- a/drivers/net/ethernet/natsemi/ibmlana.c
+++ b/drivers/net/ethernet/natsemi/ibmlana.c
@@ -589,7 +589,7 @@ static void irqrx_handler(struct net_device *dev)
 
 			/* fetch buffer */
 
-			skb = dev_alloc_skb(rda.length + 2);
+			skb = netdev_alloc_skb(dev, rda.length + 2);
 			if (skb == NULL)
 				dev->stats.rx_dropped++;
 			else {
diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index ac7b16b..d38e48d 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -1934,11 +1934,10 @@ static void refill_rx(struct net_device *dev)
 		int entry = np->dirty_rx % RX_RING_SIZE;
 		if (np->rx_skbuff[entry] == NULL) {
 			unsigned int buflen = np->rx_buf_sz+NATSEMI_PADDING;
-			skb = dev_alloc_skb(buflen);
+			skb = netdev_alloc_skb(dev, buflen);
 			np->rx_skbuff[entry] = skb;
 			if (skb == NULL)
 				break; /* Better luck next round. */
-			skb->dev = dev; /* Mark as being used by this device. */
 			np->rx_dma[entry] = pci_map_single(np->pci_dev,
 				skb->data, buflen, PCI_DMA_FROMDEVICE);
 			np->rx_ring[entry].addr = cpu_to_le32(np->rx_dma[entry]);
@@ -2344,7 +2343,7 @@ static void netdev_rx(struct net_device *dev, int *work_done, int work_to_do)
 			/* Check if the packet is long enough to accept
 			 * without copying to a minimally-sized skbuff. */
 			if (pkt_len < rx_copybreak &&
-			    (skb = dev_alloc_skb(pkt_len + RX_OFFSET)) != NULL) {
+			    (skb = netdev_alloc_skb(dev, pkt_len + RX_OFFSET)) != NULL) {
 				/* 16 byte align the IP header */
 				skb_reserve(skb, RX_OFFSET);
 				pci_dma_sync_single_for_cpu(np->pci_dev,
diff --git a/drivers/net/ethernet/natsemi/sonic.c b/drivers/net/ethernet/natsemi/sonic.c
index 26e25d7..0452e296 100644
--- a/drivers/net/ethernet/natsemi/sonic.c
+++ b/drivers/net/ethernet/natsemi/sonic.c
@@ -51,7 +51,7 @@ static int sonic_open(struct net_device *dev)
 		printk("sonic_open: initializing sonic driver.\n");
 
 	for (i = 0; i < SONIC_NUM_RRS; i++) {
-		struct sk_buff *skb = dev_alloc_skb(SONIC_RBSIZE + 2);
+		struct sk_buff *skb = netdev_alloc_skb(dev, SONIC_RBSIZE + 2);
 		if (skb == NULL) {
 			while(i > 0) { /* free any that were allocated successfully */
 				i--;
@@ -422,7 +422,7 @@ static void sonic_rx(struct net_device *dev)
 		status = sonic_rda_get(dev, entry, SONIC_RD_STATUS);
 		if (status & SONIC_RCR_PRX) {
 			/* Malloc up new buffer. */
-			new_skb = dev_alloc_skb(SONIC_RBSIZE + 2);
+			new_skb = netdev_alloc_skb(SONIC_RBSIZE + 2);
 			if (new_skb == NULL) {
 				printk(KERN_ERR "%s: Memory squeeze, dropping packet.\n", dev->name);
 				lp->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 97f63e1..4ef38ed 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -2524,7 +2524,7 @@ static int fill_rx_buffers(struct s2io_nic *nic, struct ring_info *ring,
 			size = ring->mtu + ALIGN_SIZE + BUF0_LEN + 4;
 
 		/* allocate skb */
-		skb = dev_alloc_skb(size);
+		skb = netdev_alloc_skb(nic->dev, size);
 		if (!skb) {
 			DBG_PRINT(INFO_DBG, "%s: Could not allocate skb\n",
 				  ring->dev->name);
@@ -6820,7 +6820,7 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 			 */
 			rxdp1->Buffer0_ptr = *temp0;
 		} else {
-			*skb = dev_alloc_skb(size);
+			*skb = netdev_alloc_skb(dev, size);
 			if (!(*skb)) {
 				DBG_PRINT(INFO_DBG,
 					  "%s: Out of memory to allocate %s\n",
@@ -6849,7 +6849,7 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 			rxdp3->Buffer0_ptr = *temp0;
 			rxdp3->Buffer1_ptr = *temp1;
 		} else {
-			*skb = dev_alloc_skb(size);
+			*skb = netdev_alloc_skb(dev, size);
 			if (!(*skb)) {
 				DBG_PRINT(INFO_DBG,
 					  "%s: Out of memory to allocate %s\n",
