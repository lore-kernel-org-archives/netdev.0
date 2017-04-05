From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 02/13] ftgmac100: Remove "banner" comments
Date: Wed,  5 Apr 2017 12:28:42 +1000
Message-ID: <20170405022853.8238-3-benh@kernel.crashing.org>
References: <20170405022853.8238-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:33673 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752822AbdDEDny (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 23:43:54 -0400
In-Reply-To: <20170405022853.8238-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The divisions they represent are not particularily meaningful
and things are going to be moving around with upcoming changes
making these comments more a burden than anything else.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 42 --------------------------------
 1 file changed, 42 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index bf7b1c0..6501aa7 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -44,9 +44,6 @@
 #define MAX_PKT_SIZE		1518
 #define RX_BUF_SIZE		PAGE_SIZE	/* must be smaller than 0x3fff */
 
-/******************************************************************************
- * private data
- *****************************************************************************/
 struct ftgmac100_descs {
 	struct ftgmac100_rxdes rxdes[RX_QUEUE_ENTRIES];
 	struct ftgmac100_txdes txdes[TX_QUEUE_ENTRIES];
@@ -86,9 +83,6 @@ struct ftgmac100 {
 static int ftgmac100_alloc_rx_page(struct ftgmac100 *priv,
 				   struct ftgmac100_rxdes *rxdes, gfp_t gfp);
 
-/******************************************************************************
- * internal functions (hardware register access)
- *****************************************************************************/
 static void ftgmac100_set_rx_ring_base(struct ftgmac100 *priv, dma_addr_t addr)
 {
 	iowrite32(addr, priv->base + FTGMAC100_OFFSET_RXR_BADR);
@@ -243,9 +237,6 @@ static void ftgmac100_stop_hw(struct ftgmac100 *priv)
 	iowrite32(0, priv->base + FTGMAC100_OFFSET_MACCR);
 }
 
-/******************************************************************************
- * internal functions (receive descriptor)
- *****************************************************************************/
 static bool ftgmac100_rxdes_first_segment(struct ftgmac100_rxdes *rxdes)
 {
 	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_FRS);
@@ -370,9 +361,6 @@ static struct page *ftgmac100_rxdes_get_page(struct ftgmac100 *priv,
 	return *ftgmac100_rxdes_page_slot(priv, rxdes);
 }
 
-/******************************************************************************
- * internal functions (receive)
- *****************************************************************************/
 static int ftgmac100_next_rx_pointer(int pointer)
 {
 	return (pointer + 1) & (RX_QUEUE_ENTRIES - 1);
@@ -557,9 +545,6 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 	return true;
 }
 
-/******************************************************************************
- * internal functions (transmit descriptor)
- *****************************************************************************/
 static void ftgmac100_txdes_reset(const struct ftgmac100 *priv,
 				  struct ftgmac100_txdes *txdes)
 {
@@ -653,9 +638,6 @@ static struct sk_buff *ftgmac100_txdes_get_skb(struct ftgmac100_txdes *txdes)
 	return (struct sk_buff *)txdes->txdes2;
 }
 
-/******************************************************************************
- * internal functions (transmit)
- *****************************************************************************/
 static int ftgmac100_next_tx_pointer(int pointer)
 {
 	return (pointer + 1) & (TX_QUEUE_ENTRIES - 1);
@@ -771,9 +753,6 @@ static int ftgmac100_xmit(struct ftgmac100 *priv, struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
-/******************************************************************************
- * internal functions (buffer)
- *****************************************************************************/
 static int ftgmac100_alloc_rx_page(struct ftgmac100 *priv,
 				   struct ftgmac100_rxdes *rxdes, gfp_t gfp)
 {
@@ -865,9 +844,6 @@ static int ftgmac100_alloc_buffers(struct ftgmac100 *priv)
 	return -ENOMEM;
 }
 
-/******************************************************************************
- * internal functions (mdio)
- *****************************************************************************/
 static void ftgmac100_adjust_link(struct net_device *netdev)
 {
 	struct ftgmac100 *priv = netdev_priv(netdev);
@@ -917,9 +893,6 @@ static int ftgmac100_mii_probe(struct ftgmac100 *priv)
 	return 0;
 }
 
-/******************************************************************************
- * struct mii_bus functions
- *****************************************************************************/
 static int ftgmac100_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
 {
 	struct net_device *netdev = bus->priv;
@@ -991,9 +964,6 @@ static int ftgmac100_mdiobus_write(struct mii_bus *bus, int phy_addr,
 	return -EIO;
 }
 
-/******************************************************************************
- * struct ethtool_ops functions
- *****************************************************************************/
 static void ftgmac100_get_drvinfo(struct net_device *netdev,
 				  struct ethtool_drvinfo *info)
 {
@@ -1009,9 +979,6 @@ static const struct ethtool_ops ftgmac100_ethtool_ops = {
 	.set_link_ksettings	= phy_ethtool_set_link_ksettings,
 };
 
-/******************************************************************************
- * interrupt handler
- *****************************************************************************/
 static irqreturn_t ftgmac100_interrupt(int irq, void *dev_id)
 {
 	struct net_device *netdev = dev_id;
@@ -1029,9 +996,6 @@ static irqreturn_t ftgmac100_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-/******************************************************************************
- * struct napi_struct functions
- *****************************************************************************/
 static int ftgmac100_poll(struct napi_struct *napi, int budget)
 {
 	struct ftgmac100 *priv = container_of(napi, struct ftgmac100, napi);
@@ -1103,9 +1067,6 @@ static int ftgmac100_poll(struct napi_struct *napi, int budget)
 	return rx;
 }
 
-/******************************************************************************
- * struct net_device_ops functions
- *****************************************************************************/
 static int ftgmac100_open(struct net_device *netdev)
 {
 	struct ftgmac100 *priv = netdev_priv(netdev);
@@ -1318,9 +1279,6 @@ static void ftgmac100_ncsi_handler(struct ncsi_dev *nd)
 		    nd->link_up ? "up" : "down");
 }
 
-/******************************************************************************
- * struct platform_driver functions
- *****************************************************************************/
 static int ftgmac100_probe(struct platform_device *pdev)
 {
 	struct resource *res;
-- 
2.9.3
