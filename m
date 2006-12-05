From: Andrew Victor <andrew@sanpeople.com>
Subject: [PATCH 2.6.19 1/4] AT91RM9200 Ethernet: Remove 'at91_dev' and use
	netdev_priv()
Date: 05 Dec 2006 15:09:16 +0200
Message-ID: <1165324155.12515.67.camel@fuzzie.sanpeople.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from za-gw.sanpeople.com ([196.211.225.226]:3600 "EHLO
	za-gw.sanpeople.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937529AbWLENTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 08:19:11 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the global 'at91_dev' variable.
Use netdev_priv() instead of casting dev->priv directly.

Signed-off-by: Andrew Victor <andrew@sanpeople.com>


diff -urN linux-2.6.19-final.orig/drivers/net/arm/at91_ether.c linux-2.6.19-final/drivers/net/arm/at91_ether.c
--- linux-2.6.19-final.orig/drivers/net/arm/at91_ether.c	Tue Dec  5 10:13:03 2006
+++ linux-2.6.19-final/drivers/net/arm/at91_ether.c	Tue Dec  5 10:41:45 2006
@@ -41,8 +41,6 @@
 #define DRV_NAME	"at91_ether"
 #define DRV_VERSION	"1.0"
 
-static struct net_device *at91_dev;
-
 static struct timer_list check_timer;
 #define LINK_POLL_INTERVAL	(HZ)
 
@@ -146,7 +144,7 @@
  */
 static void update_linkspeed(struct net_device *dev, int silent)
 {
-	struct at91_private *lp = (struct at91_private *) dev->priv;
+	struct at91_private *lp = netdev_priv(dev);
 	unsigned int bmsr, bmcr, lpa, mac_cfg;
 	unsigned int speed, duplex;
 
@@ -199,7 +197,7 @@
 static irqreturn_t at91ether_phy_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
-	struct at91_private *lp = (struct at91_private *) dev->priv;
+	struct at91_private *lp = netdev_priv(dev);
 	unsigned int phy;
 
 	/*
@@ -242,7 +240,7 @@
  */
 static void enable_phyirq(struct net_device *dev)
 {
-	struct at91_private *lp = (struct at91_private *) dev->priv;
+	struct at91_private *lp = netdev_priv(dev);
 	unsigned int dsintr, irq_number;
 	int status;
 
@@ -294,7 +292,7 @@
  */
 static void disable_phyirq(struct net_device *dev)
 {
-	struct at91_private *lp = (struct at91_private *) dev->priv;
+	struct at91_private *lp = netdev_priv(dev);
 	unsigned int dsintr;
 	unsigned int irq_number;
 
@@ -340,7 +338,7 @@
 #if 0
 static void reset_phy(struct net_device *dev)
 {
-	struct at91_private *lp = (struct at91_private *) dev->priv;
+	struct at91_private *lp = netdev_priv(dev);
 	unsigned int bmcr;
 
 	spin_lock_irq(&lp->lock);
@@ -590,7 +588,7 @@
 
 static int at91ether_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct at91_private *lp = (struct at91_private *) dev->priv;
+	struct at91_private *lp = netdev_priv(dev);
 	int ret;
 
 	spin_lock_irq(&lp->lock);
@@ -611,7 +609,7 @@
 
 static int at91ether_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct at91_private *lp = (struct at91_private *) dev->priv;
+	struct at91_private *lp = netdev_priv(dev);
 	int ret;
 
 	spin_lock_irq(&lp->lock);
@@ -627,7 +625,7 @@
 
 static int at91ether_nwayreset(struct net_device *dev)
 {
-	struct at91_private *lp = (struct at91_private *) dev->priv;
+	struct at91_private *lp = netdev_priv(dev);
 	int ret;
 
 	spin_lock_irq(&lp->lock);
@@ -658,7 +656,7 @@
 
 static int at91ether_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct at91_private *lp = (struct at91_private *) dev->priv;
+	struct at91_private *lp = netdev_priv(dev);
 	int res;
 
 	if (!netif_running(dev))
@@ -680,7 +678,7 @@
  */
 static void at91ether_start(struct net_device *dev)
 {
-	struct at91_private *lp = (struct at91_private *) dev->priv;
+	struct at91_private *lp = netdev_priv(dev);
 	struct recv_desc_bufs *dlist, *dlist_phys;
 	int i;
 	unsigned long ctl;
@@ -712,7 +710,7 @@
  */
 static int at91ether_open(struct net_device *dev)
 {
-	struct at91_private *lp = (struct at91_private *) dev->priv;
+	struct at91_private *lp = netdev_priv(dev);
 	unsigned long ctl;
 
 	if (!is_valid_ether_addr(dev->dev_addr))
@@ -752,7 +750,7 @@
  */
 static int at91ether_close(struct net_device *dev)
 {
-	struct at91_private *lp = (struct at91_private *) dev->priv;
+	struct at91_private *lp = netdev_priv(dev);
 	unsigned long ctl;
 
 	/* Disable Receiver and Transmitter */
@@ -779,7 +777,7 @@
  */
 static int at91ether_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct at91_private *lp = (struct at91_private *) dev->priv;
+	struct at91_private *lp = netdev_priv(dev);
 
 	if (at91_emac_read(AT91_EMAC_TSR) & AT91_EMAC_TSR_BNQ) {
 		netif_stop_queue(dev);
@@ -811,7 +809,7 @@
  */
 static struct net_device_stats *at91ether_stats(struct net_device *dev)
 {
-	struct at91_private *lp = (struct at91_private *) dev->priv;
+	struct at91_private *lp = netdev_priv(dev);
 	int ale, lenerr, seqe, lcol, ecol;
 
 	if (netif_running(dev)) {
@@ -847,7 +845,7 @@
  */
 static void at91ether_rx(struct net_device *dev)
 {
-	struct at91_private *lp = (struct at91_private *) dev->priv;
+	struct at91_private *lp = netdev_priv(dev);
 	struct recv_desc_bufs *dlist;
 	unsigned char *p_recv;
 	struct sk_buff *skb;
@@ -891,7 +889,7 @@
 static irqreturn_t at91ether_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
-	struct at91_private *lp = (struct at91_private *) dev->priv;
+	struct at91_private *lp = netdev_priv(dev);
 	unsigned long intstatus, ctl;
 
 	/* MAC Interrupt Status register indicates what interrupts are pending.
@@ -939,9 +937,6 @@
 	unsigned int val;
 	int res;
 
-	if (at91_dev)			/* already initialized */
-		return 0;
-
 	dev = alloc_etherdev(sizeof(struct at91_private));
 	if (!dev)
 		return -ENOMEM;
@@ -957,7 +952,7 @@
 	}
 
 	/* Allocate memory for DMA Receive descriptors */
-	lp = (struct at91_private *)dev->priv;
+	lp = netdev_priv(dev);
 	lp->dlist = (struct recv_desc_bufs *) dma_alloc_coherent(NULL, sizeof(struct recv_desc_bufs), (dma_addr_t *) &lp->dlist_phys, GFP_KERNEL);
 	if (lp->dlist == NULL) {
 		free_irq(dev->irq, dev);
@@ -1024,7 +1019,6 @@
 		dma_free_coherent(NULL, sizeof(struct recv_desc_bufs), lp->dlist, (dma_addr_t)lp->dlist_phys);
 		return res;
 	}
-	at91_dev = dev;
 
 	/* Determine current link speed */
 	spin_lock_irq(&lp->lock);
@@ -1115,15 +1109,16 @@
 
 static int __devexit at91ether_remove(struct platform_device *pdev)
 {
-	struct at91_private *lp = (struct at91_private *) at91_dev->priv;
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct at91_private *lp = netdev_priv(dev);
 
-	unregister_netdev(at91_dev);
-	free_irq(at91_dev->irq, at91_dev);
+	unregister_netdev(dev);
+	free_irq(dev->irq, dev);
 	dma_free_coherent(NULL, sizeof(struct recv_desc_bufs), lp->dlist, (dma_addr_t)lp->dlist_phys);
 	clk_put(lp->ether_clk);
 
-	free_netdev(at91_dev);
-	at91_dev = NULL;
+	platform_set_drvdata(pdev, NULL);
+	free_netdev(dev);
 	return 0;
 }
 
@@ -1131,8 +1126,8 @@
 
 static int at91ether_suspend(struct platform_device *pdev, pm_message_t mesg)
 {
-	struct at91_private *lp = (struct at91_private *) at91_dev->priv;
 	struct net_device *net_dev = platform_get_drvdata(pdev);
+	struct at91_private *lp = netdev_priv(net_dev);
 	int phy_irq = lp->board_data.phy_irq_pin;
 
 	if (netif_running(net_dev)) {
@@ -1149,8 +1144,8 @@
 
 static int at91ether_resume(struct platform_device *pdev)
 {
-	struct at91_private *lp = (struct at91_private *) at91_dev->priv;
 	struct net_device *net_dev = platform_get_drvdata(pdev);
+	struct at91_private *lp = netdev_priv(net_dev);
 	int phy_irq = lp->board_data.phy_irq_pin;
 
 	if (netif_running(net_dev)) {



