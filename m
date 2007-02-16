From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NET] Convert meth to netdev_priv
Date: Fri, 16 Feb 2007 12:52:17 +0000
Message-ID: <20070216125217.GA21747@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:54801 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964787AbXBPMwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Feb 2007 07:52:19 -0500
Received: from localhost.localdomain ([127.0.0.1]:54157 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20038828AbXBPMwS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 12:52:18 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

And while at it loose plenty of useless casts.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/drivers/net/meth.c b/drivers/net/meth.c
index d38b7c7..7e69ca6 100644
--- a/drivers/net/meth.c
+++ b/drivers/net/meth.c
@@ -170,7 +170,7 @@ static int mdio_probe(struct meth_private *priv)
 
 static void meth_check_link(struct net_device *dev)
 {
-	struct meth_private *priv = (struct meth_private *) dev->priv;
+	struct meth_private *priv = netdev_priv(dev);
 	unsigned long mii_advertising = mdio_read(priv, 4);
 	unsigned long mii_partner = mdio_read(priv, 5);
 	unsigned long negotiated = mii_advertising & mii_partner;
@@ -268,7 +268,7 @@ static void meth_free_rx_ring(struct meth_private *priv)
 
 int meth_reset(struct net_device *dev)
 {
-	struct meth_private *priv = (struct meth_private *) dev->priv;
+	struct meth_private *priv = netdev_priv(dev);
 
 	/* Reset card */
 	mace->eth.mac_ctrl = SGI_MAC_RESET;
@@ -310,7 +310,7 @@ int meth_reset(struct net_device *dev)
  */
 static int meth_open(struct net_device *dev)
 {
-	struct meth_private *priv = dev->priv;
+	struct meth_private *priv = netdev_priv(dev);
 	int ret;
 
 	priv->phy_addr = -1;    /* No PHY is known yet... */
@@ -354,7 +354,7 @@ out_free_tx_ring:
 
 static int meth_release(struct net_device *dev)
 {
-	struct meth_private *priv = dev->priv;
+	struct meth_private *priv = netdev_priv(dev);
 
 	DPRINTK("Stopping queue\n");
 	netif_stop_queue(dev); /* can't transmit any more */
@@ -376,7 +376,7 @@ static void meth_rx(struct net_device* dev, unsigned long int_status)
 {
 	struct sk_buff *skb;
 	unsigned long status;
-	struct meth_private *priv = (struct meth_private *) dev->priv;
+	struct meth_private *priv = netdev_priv(dev);
 	unsigned long fifo_rptr = (int_status & METH_INT_RX_RPTR_MASK) >> 8;
 
 	spin_lock(&priv->meth_lock);
@@ -466,14 +466,14 @@ static void meth_rx(struct net_device* dev, unsigned long int_status)
 
 static int meth_tx_full(struct net_device *dev)
 {
-	struct meth_private *priv = (struct meth_private *) dev->priv;
+	struct meth_private *priv = netdev_priv(dev);
 
 	return (priv->tx_count >= TX_RING_ENTRIES - 1);
 }
 
 static void meth_tx_cleanup(struct net_device* dev, unsigned long int_status)
 {
-	struct meth_private *priv = dev->priv;
+	struct meth_private *priv = netdev_priv(dev);
 	unsigned long status;
 	struct sk_buff *skb;
 	unsigned long rptr = (int_status&TX_INFO_RPTR) >> 16;
@@ -536,7 +536,7 @@ static void meth_tx_cleanup(struct net_device* dev, unsigned long int_status)
 
 static void meth_error(struct net_device* dev, unsigned status)
 {
-	struct meth_private *priv = (struct meth_private *) dev->priv;
+	struct meth_private *priv = netdev_priv(dev);
 
 	printk(KERN_WARNING "meth: error status: 0x%08x\n",status);
 	/* check for errors too... */
@@ -570,7 +570,7 @@ static void meth_error(struct net_device* dev, unsigned status)
 static irqreturn_t meth_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
-	struct meth_private *priv = (struct meth_private *) dev->priv;
+	struct meth_private *priv = netdev_priv(dev);
 	unsigned long status;
 
 	status = mace->eth.int_stat;
@@ -695,7 +695,7 @@ static void meth_add_to_tx_ring(struct meth_private *priv, struct sk_buff *skb)
  */
 static int meth_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct meth_private *priv = (struct meth_private *) dev->priv;
+	struct meth_private *priv = netdev_priv(dev);
 	unsigned long flags;
 
 	spin_lock_irqsave(&priv->meth_lock, flags);
@@ -726,7 +726,7 @@ static int meth_tx(struct sk_buff *skb, struct net_device *dev)
  */
 static void meth_tx_timeout(struct net_device *dev)
 {
-	struct meth_private *priv = (struct meth_private *) dev->priv;
+	struct meth_private *priv = netdev_priv(dev);
 	unsigned long flags;
 
 	printk(KERN_WARNING "%s: transmit timed out\n", dev->name);
@@ -778,7 +778,7 @@ static int meth_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
  */
 static struct net_device_stats *meth_stats(struct net_device *dev)
 {
-	struct meth_private *priv = (struct meth_private *) dev->priv;
+	struct meth_private *priv = netdev_priv(dev);
 	return &priv->stats;
 }
 
@@ -807,7 +807,7 @@ static struct net_device *meth_init(void)
 	dev->irq	     = MACE_ETHERNET_IRQ;
 	dev->base_addr	     = (unsigned long)&mace->eth;
 
-	priv = (struct meth_private *) dev->priv;
+	priv = netdev_priv(dev);
 	spin_lock_init(&priv->meth_lock);
 
 	ret = register_netdev(dev);
