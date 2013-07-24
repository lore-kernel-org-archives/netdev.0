From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 1/2] gianfar: Fix data structure field comments in gianfar.h
Date: Wed, 24 Jul 2013 17:43:34 +0300
Message-ID: <1374677015-23127-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0249.outbound.messaging.microsoft.com ([213.199.154.249]:55264
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751904Ab3GXOoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 10:44:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Improve clarity of struct member comments for tx_q and and rx_q
(see cur_tx, dirty_tx, skb_curtx). Fix misleading comments (see
skb_currx, cur_rx) and remove outdated ones (txcount, txtime).
Make comments readable (and maintainable) by placing them above
the individual targeted members.
Fix checkpatch warnings (see __aligned()) and spacing issues
in the process.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.h | 115 ++++++++++++++-----------------
 1 file changed, 50 insertions(+), 65 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 04b552c..655951d 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -902,93 +902,83 @@ enum {
 	MQ_MG_MODE
 };
 
-/*
- * Per TX queue stats
- */
+/* per TX queue stats */
 struct tx_q_stats {
 	unsigned long tx_packets;
 	unsigned long tx_bytes;
 };
 
-/**
- *	struct gfar_priv_tx_q - per tx queue structure
- *	@txlock: per queue tx spin lock
- *	@tx_skbuff:skb pointers
- *	@skb_curtx: to be used skb pointer
- *	@skb_dirtytx:the last used skb pointer
- *	@stats: bytes/packets stats
- *	@qindex: index of this queue
- *	@dev: back pointer to the dev structure
- *	@grp: back pointer to the group to which this queue belongs
- *	@tx_bd_base: First tx buffer descriptor
- *	@cur_tx: Next free ring entry
- *	@dirty_tx: First buffer in line to be transmitted
- *	@tx_ring_size: Tx ring size
- *	@num_txbdfree: number of free TxBds
- *	@txcoalescing: enable/disable tx coalescing
- *	@txic: transmit interrupt coalescing value
- *	@txcount: coalescing value if based on tx frame count
- *	@txtime: coalescing value if based on time
- */
+/* TX queue data structure */
 struct gfar_priv_tx_q {
 	/* cacheline 1 */
-	spinlock_t txlock __attribute__ ((aligned (SMP_CACHE_BYTES)));
-	struct	txbd8 *tx_bd_base;
-	struct	txbd8 *cur_tx;
+	/* per tx queue spin lock */
+	spinlock_t txlock __aligned(SMP_CACHE_BYTES);
+	/* pointer to descriptor ring memory */
+	struct txbd8 *tx_bd_base;
+	/* next free descriptor to use */
+	struct txbd8 *cur_tx;
+	/* number of free descriptors in the ring */
 	unsigned int num_txbdfree;
+	/* next skb (index) to use */
 	unsigned short skb_curtx;
+	/* number of descriptors in the ring */
 	unsigned short tx_ring_size;
+	/* bytes/packets stats */
 	struct tx_q_stats stats;
+	/* backlink to the group owning this queue */
 	struct gfar_priv_grp *grp;
 	/* cacheline 2 */
+	/* backlink to net_device */
 	struct net_device *dev;
+	/* array of skb pointers for this ring */
 	struct sk_buff **tx_skbuff;
-	struct	txbd8 *dirty_tx;
+	/* first buff in line used for xmit, next to clean */
+	struct txbd8 *dirty_tx;
+	/* the last used skb (index), next to clean */
 	unsigned short skb_dirtytx;
+	/* index of this queue */
 	unsigned short qindex;
-	/* Configuration info for the coalescing features */
+	/* enable/disable tx int coalescing */
 	unsigned int txcoalescing;
+	/* transmit interrupt coalescing value */
 	unsigned long txic;
+	/* physical address of the descriptor ring */
 	dma_addr_t tx_bd_dma_base;
 };
 
-/*
- * Per RX queue stats
- */
+/* per RX queue stats */
 struct rx_q_stats {
 	unsigned long rx_packets;
 	unsigned long rx_bytes;
 	unsigned long rx_dropped;
 };
 
-/**
- *	struct gfar_priv_rx_q - per rx queue structure
- *	@rxlock: per queue rx spin lock
- *	@rx_skbuff: skb pointers
- *	@skb_currx: currently use skb pointer
- *	@rx_bd_base: First rx buffer descriptor
- *	@cur_rx: Next free rx ring entry
- *	@qindex: index of this queue
- *	@dev: back pointer to the dev structure
- *	@rx_ring_size: Rx ring size
- *	@rxcoalescing: enable/disable rx-coalescing
- *	@rxic: receive interrupt coalescing vlaue
- */
-
+/* RX queue data structure */
 struct gfar_priv_rx_q {
-	spinlock_t rxlock __attribute__ ((aligned (SMP_CACHE_BYTES)));
-	struct	sk_buff ** rx_skbuff;
+	/* per rx queue spin lock */
+	spinlock_t rxlock __aligned(SMP_CACHE_BYTES);
+	/* array of skb pointers for this ring */
+	struct sk_buff **rx_skbuff;
+	/* physical address of the descriptor ring */
 	dma_addr_t rx_bd_dma_base;
-	struct	rxbd8 *rx_bd_base;
-	struct	rxbd8 *cur_rx;
-	struct	net_device *dev;
+	/* pointer to descriptor ring memory */
+	struct rxbd8 *rx_bd_base;
+	/* next descriptor to clean */
+	struct rxbd8 *cur_rx;
+	/* backlink to net_device */
+	struct net_device *dev;
+	/* backlink to the group owning this queue */
 	struct gfar_priv_grp *grp;
 	struct rx_q_stats stats;
-	u16	skb_currx;
-	u16	qindex;
-	unsigned int	rx_ring_size;
-	/* RX Coalescing values */
+	/* next skb (index) to process */
+	u16 skb_currx;
+	/* index of this queue */
+	u16 qindex;
+	/* number of descriptors in the ring */
+	unsigned int rx_ring_size;
+	/* enable/disable rx int coalescing */
 	unsigned char rxcoalescing;
+	/* receive interrupt coalescing value */
 	unsigned long rxic;
 };
 
@@ -1004,19 +994,13 @@ struct gfar_irqinfo {
 	char name[GFAR_INT_NAME_MAX];
 };
 
-/**
- *	struct gfar_priv_grp - per group structure
- *	@napi: the napi poll function
- *	@priv: back pointer to the priv structure
- *	@regs: the ioremapped register space for this group
- *	@grp_id: group id for this group
- *	@irqinfo: TX/RX/ER irq data for this group
- */
-
+/* interrupt group data structure */
 struct gfar_priv_grp {
-	spinlock_t grplock __attribute__ ((aligned (SMP_CACHE_BYTES)));
-	struct	napi_struct napi;
+	spinlock_t grplock __aligned(SMP_CACHE_BYTES);
+	struct napi_struct napi;
+	/* backlink to priv */
 	struct gfar_private *priv;
+	/* register space for this group */
 	struct gfar __iomem *regs;
 	unsigned int grp_id;
 	unsigned long num_rx_queues;
@@ -1027,6 +1011,7 @@ struct gfar_priv_grp {
 	unsigned long num_tx_queues;
 	unsigned long tx_bit_map;
 
+	/* TX/RX/ER irq data for this group */
 	struct gfar_irqinfo *irqinfo[GFAR_NUM_IRQS];
 };
 
-- 
1.7.11.4
