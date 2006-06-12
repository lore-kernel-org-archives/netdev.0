From: Herbert Valerio Riedel <hvr@gnu.org>
Subject: [PATCH netdev-2.6#upstream] net: au1000_eth: netdev_priv() conversion
Date: Mon, 12 Jun 2006 07:52:48 +0200
Message-ID: <E1FpfPQ-0005lv-Ej@fencepost.gnu.org>
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	ppopov@embeddedalley.com, sshtylyov@ru.mvista.com,
	ralf@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:10638 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S1750910AbWFLF4Z
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 01:56:25 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

convert driver to use netdev_priv(net_device*) instead of accessing ->priv
directly; where applicable, declare the resulting local pointer to be 'const'

Signed-off-by: Herbert Valerio Riedel <hvr@gnu.org>
---

 drivers/net/au1000_eth.c |   51 +++++++++++++++++++++++-----------------------
 1 files changed, 25 insertions(+), 26 deletions(-)

505c73271046495d4948bf7b5adc7c4e3b88835d
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 038d5fc..558aae3 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -199,7 +199,7 @@ #endif
  */
 static int mdio_read(struct net_device *dev, int phy_addr, int reg)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 	volatile u32 *const mii_control_reg = &aup->mac->mii_control;
 	volatile u32 *const mii_data_reg = &aup->mac->mii_data;
 	u32 timedout = 20;
@@ -233,7 +233,7 @@ static int mdio_read(struct net_device *
 
 static void mdio_write(struct net_device *dev, int phy_addr, int reg, u16 value)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 	volatile u32 *const mii_control_reg = &aup->mac->mii_control;
 	volatile u32 *const mii_data_reg = &aup->mac->mii_data;
 	u32 timedout = 20;
@@ -288,7 +288,7 @@ static int mdiobus_reset(struct mii_bus 
 
 static int mii_probe (struct net_device *dev)
 {
-	struct au1000_private *const aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 	struct phy_device *phydev = NULL;
 
 #if defined(AU1XXX_PHY_STATIC_CONFIG)
@@ -419,7 +419,7 @@ void ReleaseDB(struct au1000_private *au
 
 static void enable_rx_tx(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 
 	if (au1000_debug > 4)
 		printk(KERN_INFO "%s: enable_rx_tx\n", dev->name);
@@ -430,7 +430,7 @@ static void enable_rx_tx(struct net_devi
 
 static void hard_stop(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 
 	if (au1000_debug > 4)
 		printk(KERN_INFO "%s: hard stop\n", dev->name);
@@ -442,7 +442,7 @@ static void hard_stop(struct net_device 
 static void enable_mac(struct net_device *dev, int force_reset)
 {
 	unsigned long flags;
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 
 	spin_lock_irqsave(&aup->lock, flags);
 
@@ -461,7 +461,7 @@ static void enable_mac(struct net_device
 
 static void reset_mac_unlocked(struct net_device *dev)
 {
-	struct au1000_private *const aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 	int i;
 
 	hard_stop(dev);
@@ -487,7 +487,7 @@ static void reset_mac_unlocked(struct ne
 
 static void reset_mac(struct net_device *dev)
 {
-	struct au1000_private *const aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 	unsigned long flags;
 
 	if (au1000_debug > 4)
@@ -576,7 +576,7 @@ static int __init au1000_init_module(voi
 
 static int au1000_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 
 	if (aup->phy_dev)
 		return phy_ethtool_gset(aup->phy_dev, cmd);
@@ -586,7 +586,7 @@ static int au1000_get_settings(struct ne
 
 static int au1000_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -600,7 +600,7 @@ static int au1000_set_settings(struct ne
 static void
 au1000_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
@@ -657,7 +657,7 @@ static struct net_device * au1000_probe(
 	printk("%s: Au1xx0 Ethernet found at 0x%x, irq %d\n",
 		dev->name, base, irq);
 
-	aup = dev->priv;
+	aup = netdev_priv(dev);
 
 	/* Allocate the data buffers */
 	/* Snooping works fine with eth on all au1xxx */
@@ -822,7 +822,7 @@ err_out:
  */
 static int au1000_init(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 	u32 flags;
 	int i;
 	u32 control;
@@ -873,7 +873,7 @@ #endif
 static void
 au1000_adjust_link(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 	struct phy_device *phydev = aup->phy_dev;
 	unsigned long flags;
 
@@ -953,7 +953,7 @@ au1000_adjust_link(struct net_device *de
 static int au1000_open(struct net_device *dev)
 {
 	int retval;
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 
 	if (au1000_debug > 4)
 		printk("%s: open: dev=%p\n", dev->name, dev);
@@ -988,7 +988,7 @@ static int au1000_open(struct net_device
 static int au1000_close(struct net_device *dev)
 {
 	unsigned long flags;
-	struct au1000_private *const aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 
 	if (au1000_debug > 4)
 		printk("%s: close: dev=%p\n", dev->name, dev);
@@ -1014,12 +1014,11 @@ static void __exit au1000_cleanup_module
 {
 	int i, j;
 	struct net_device *dev;
-	struct au1000_private *aup;
 
 	for (i = 0; i < num_ifs; i++) {
 		dev = iflist[i].dev;
 		if (dev) {
-			aup = (struct au1000_private *) dev->priv;
+			struct au1000_private *const aup = netdev_priv(dev);
 			unregister_netdev(dev);
 			for (j = 0; j < NUM_RX_DMA; j++)
 				if (aup->rx_db_inuse[j])
@@ -1039,7 +1038,7 @@ static void __exit au1000_cleanup_module
 
 static void update_tx_stats(struct net_device *dev, u32 status)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 	struct net_device_stats *ps = &aup->stats;
 
 	if (status & TX_FRAME_ABORTED) {
@@ -1068,7 +1067,7 @@ static void update_tx_stats(struct net_d
  */
 static void au1000_tx_ack(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 	volatile tx_dma_t *ptxd;
 
 	ptxd = aup->tx_dma_ring[aup->tx_tail];
@@ -1095,7 +1094,7 @@ static void au1000_tx_ack(struct net_dev
  */
 static int au1000_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 	struct net_device_stats *ps = &aup->stats;
 	volatile tx_dma_t *ptxd;
 	u32 buff_stat;
@@ -1149,7 +1148,7 @@ static int au1000_tx(struct sk_buff *skb
 
 static inline void update_rx_stats(struct net_device *dev, u32 status)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 	struct net_device_stats *ps = &aup->stats;
 
 	ps->rx_packets++;
@@ -1177,7 +1176,7 @@ static inline void update_rx_stats(struc
  */
 static int au1000_rx(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 	struct sk_buff *skb;
 	volatile rx_dma_t *prxd;
 	u32 buff_stat, status;
@@ -1286,7 +1285,7 @@ static void au1000_tx_timeout(struct net
 
 static void set_rx_mode(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 
 	if (au1000_debug > 4) 
 		printk("%s: set_rx_mode: flags=%x\n", dev->name, dev->flags);
@@ -1319,7 +1318,7 @@ static void set_rx_mode(struct net_devic
 
 static int au1000_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 
 	if (!netif_running(dev)) return -EINVAL;
 
@@ -1330,7 +1329,7 @@ static int au1000_ioctl(struct net_devic
 
 static struct net_device_stats *au1000_get_stats(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 
 	if (au1000_debug > 4)
 		printk("%s: au1000_get_stats: dev=%p\n", dev->name, dev);
-- 
1.3.2

