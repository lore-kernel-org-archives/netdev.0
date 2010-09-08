From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/7 v3] au1000-eth: typedefs removal
Date: Wed, 8 Sep 2010 23:11:25 +0200
Message-ID: <201009082311.26522.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:41455 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755128Ab0IHVKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 17:10:17 -0400
Received: by eyb6 with SMTP id 6so460640eyb.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 14:10:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 15ae6df..b8ae85c 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -452,9 +452,9 @@ static int au1000_mii_probe (struct net_device *dev)
  * has the virtual and dma address of a buffer suitable for
  * both, receive and transmit operations.
  */
-static db_dest_t *au1000_GetFreeDB(struct au1000_private *aup)
+static struct db_dest *au1000_GetFreeDB(struct au1000_private *aup)
 {
-	db_dest_t *pDB;
+	struct db_dest *pDB;
 	pDB = aup->pDBfree;
 
 	if (pDB) {
@@ -463,9 +463,9 @@ static db_dest_t *au1000_GetFreeDB(struct au1000_private *aup)
 	return pDB;
 }
 
-void au1000_ReleaseDB(struct au1000_private *aup, db_dest_t *pDB)
+void au1000_ReleaseDB(struct au1000_private *aup, struct db_dest *pDB)
 {
-	db_dest_t *pDBfree = aup->pDBfree;
+	struct db_dest *pDBfree = aup->pDBfree;
 	if (pDBfree)
 		pDBfree->pnext = pDB;
 	aup->pDBfree = pDB;
@@ -524,11 +524,11 @@ au1000_setup_hw_rings(struct au1000_private *aup, u32 rx_base, u32 tx_base)
 
 	for (i = 0; i < NUM_RX_DMA; i++) {
 		aup->rx_dma_ring[i] =
-			(volatile rx_dma_t *) (rx_base + sizeof(rx_dma_t)*i);
+			(volatile struct rx_dma *) (rx_base + sizeof(struct rx_dma)*i);
 	}
 	for (i = 0; i < NUM_TX_DMA; i++) {
 		aup->tx_dma_ring[i] =
-			(volatile tx_dma_t *) (tx_base + sizeof(tx_dma_t)*i);
+			(volatile struct tx_dma *) (tx_base + sizeof(struct tx_dma)*i);
 	}
 }
 
@@ -681,9 +681,9 @@ static int au1000_rx(struct net_device *dev)
 {
 	struct au1000_private *aup = netdev_priv(dev);
 	struct sk_buff *skb;
-	volatile rx_dma_t *prxd;
+	volatile struct rx_dma *prxd;
 	u32 buff_stat, status;
-	db_dest_t *pDB;
+	struct db_dest *pDB;
 	u32	frmlen;
 
 	netif_dbg(aup, rx_status, dev, "au1000_rx head %d\n", aup->rx_head);
@@ -774,7 +774,7 @@ static void au1000_update_tx_stats(struct net_device *dev, u32 status)
 static void au1000_tx_ack(struct net_device *dev)
 {
 	struct au1000_private *aup = netdev_priv(dev);
-	volatile tx_dma_t *ptxd;
+	volatile struct tx_dma *ptxd;
 
 	ptxd = aup->tx_dma_ring[aup->tx_tail];
 
@@ -873,9 +873,9 @@ static netdev_tx_t au1000_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct au1000_private *aup = netdev_priv(dev);
 	struct net_device_stats *ps = &dev->stats;
-	volatile tx_dma_t *ptxd;
+	volatile struct tx_dma *ptxd;
 	u32 buff_stat;
-	db_dest_t *pDB;
+	struct db_dest *pDB;
 	int i;
 
 	netif_dbg(aup, tx_queued, dev, "tx: aup %x len=%d, data=%p, head %d\n",
@@ -991,7 +991,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	struct au1000_private *aup = NULL;
 	struct au1000_eth_platform_data *pd;
 	struct net_device *dev = NULL;
-	db_dest_t *pDB, *pDBfree;
+	struct db_dest *pDB, *pDBfree;
 	int irq, i, err = 0;
 	struct resource *base, *macen;
 
@@ -1054,7 +1054,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	}
 
 	/* aup->mac is the base address of the MAC's registers */
-	aup->mac = (volatile mac_reg_t *)ioremap_nocache(base->start, resource_size(base));
+	aup->mac = (volatile struct mac_reg *)ioremap_nocache(base->start, resource_size(base));
 	if (!aup->mac) {
 		dev_err(&pdev->dev, "failed to ioremap MAC registers\n");
 		err = -ENXIO;
diff --git a/drivers/net/au1000_eth.h b/drivers/net/au1000_eth.h
index d06ec00..44003e4 100644
--- a/drivers/net/au1000_eth.h
+++ b/drivers/net/au1000_eth.h
@@ -44,34 +44,34 @@
  * Data Buffer Descriptor. Data buffers must be aligned on 32 byte
  * boundary for both, receive and transmit.
  */
-typedef struct db_dest {
+struct db_dest {
 	struct db_dest *pnext;
 	volatile u32 *vaddr;
 	dma_addr_t dma_addr;
-} db_dest_t;
+};
 
 /*
  * The transmit and receive descriptors are memory
  * mapped registers.
  */
-typedef struct tx_dma {
+struct tx_dma {
 	u32 status;
 	u32 buff_stat;
 	u32 len;
 	u32 pad;
-} tx_dma_t;
+};
 
-typedef struct rx_dma {
+struct rx_dma {
 	u32 status;
 	u32 buff_stat;
 	u32 pad[2];
-} rx_dma_t;
+};
 
 
 /*
  * MAC control registers, memory mapped.
  */
-typedef struct mac_reg {
+struct mac_reg {
 	u32 control;
 	u32 mac_addr_high;
 	u32 mac_addr_low;
@@ -82,16 +82,16 @@ typedef struct mac_reg {
 	u32 flow_control;
 	u32 vlan1_tag;
 	u32 vlan2_tag;
-} mac_reg_t;
+};
 
 
 struct au1000_private {
-	db_dest_t *pDBfree;
-	db_dest_t db[NUM_RX_BUFFS+NUM_TX_BUFFS];
-	volatile rx_dma_t *rx_dma_ring[NUM_RX_DMA];
-	volatile tx_dma_t *tx_dma_ring[NUM_TX_DMA];
-	db_dest_t *rx_db_inuse[NUM_RX_DMA];
-	db_dest_t *tx_db_inuse[NUM_TX_DMA];
+	struct db_dest *pDBfree;
+	struct db_dest db[NUM_RX_BUFFS+NUM_TX_BUFFS];
+	volatile struct rx_dma *rx_dma_ring[NUM_RX_DMA];
+	volatile struct tx_dma *tx_dma_ring[NUM_TX_DMA];
+	struct db_dest *rx_db_inuse[NUM_RX_DMA];
+	struct db_dest *tx_db_inuse[NUM_TX_DMA];
 	u32 rx_head;
 	u32 tx_head;
 	u32 tx_tail;
@@ -118,7 +118,7 @@ struct au1000_private {
 	int phy_irq;
 
 	/* These variables are just for quick access to certain regs addresses. */
-	volatile mac_reg_t *mac;  /* mac registers                      */
+	volatile struct mac_reg *mac;  /* mac registers                      */
 	volatile u32 *enable;     /* address of MAC Enable Register     */
 
 	u32 vaddr;                /* virtual address of rx/tx buffers   */


