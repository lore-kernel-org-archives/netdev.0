From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: [PATCH] Use netdev_priv in the 3c515 driver
Date: Sat, 22 Jan 2005 11:21:20 +0100
Message-ID: <20050122102120.GA6476@bayes.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use netdev_priv in the 3c515 driver.

Signed-off-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>

--- vanilla-2.6.11-rc1/drivers/net/3c515.c	Wed Jan 12 11:56:16 2005
+++ linux-2.6.11-rc1/drivers/net/3c515.c	Wed Jan 19 21:08:20 2005
@@ -472,7 +472,7 @@
 
 static void cleanup_card(struct net_device *dev)
 {
-	struct corkscrew_private *vp = (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	list_del_init(&vp->list);
 	if (dev->dma)
 		free_dma(dev->dma);
@@ -570,7 +570,7 @@
 static void corkscrew_setup(struct net_device *dev, int ioaddr,
 			    struct pnp_dev *idev, int card_number)
 {
-	struct corkscrew_private *vp = (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	unsigned int eeprom[0x40], checksum = 0;	/* EEPROM contents */
 	int i;
 	int irq;
@@ -696,8 +696,7 @@
 static int corkscrew_open(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
-	struct corkscrew_private *vp =
-	    (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	union wn3_config config;
 	int i;
 
@@ -862,7 +861,7 @@
 {
 #ifdef AUTOMEDIA
 	struct net_device *dev = (struct net_device *) data;
-	struct corkscrew_private *vp = (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	unsigned long flags;
 	int ok = 0;
@@ -954,8 +953,7 @@
 static void corkscrew_timeout(struct net_device *dev)
 {
 	int i;
-	struct corkscrew_private *vp =
-	    (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	printk(KERN_WARNING
@@ -994,8 +992,7 @@
 static int corkscrew_start_xmit(struct sk_buff *skb,
 				struct net_device *dev)
 {
-	struct corkscrew_private *vp =
-	    (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	/* Block a timer-based transmit from overlapping. */
@@ -1123,14 +1120,13 @@
 {
 	/* Use the now-standard shared IRQ implementation. */
 	struct net_device *dev = dev_id;
-	struct corkscrew_private *lp;
+	struct corkscrew_private *lp = netdev_priv(dev);
 	int ioaddr, status;
 	int latency;
 	int i = max_interrupt_work;
 
 	ioaddr = dev->base_addr;
 	latency = inb(ioaddr + Timer);
-	lp = (struct corkscrew_private *) dev->priv;
 
 	spin_lock(&lp->lock);
 	
@@ -1262,7 +1258,7 @@
 
 static int corkscrew_rx(struct net_device *dev)
 {
-	struct corkscrew_private *vp = (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int i;
 	short rx_status;
@@ -1329,8 +1325,7 @@
 
 static int boomerang_rx(struct net_device *dev)
 {
-	struct corkscrew_private *vp =
-	    (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	int entry = vp->cur_rx % RX_RING_SIZE;
 	int ioaddr = dev->base_addr;
 	int rx_status;
@@ -1420,8 +1415,7 @@
 
 static int corkscrew_close(struct net_device *dev)
 {
-	struct corkscrew_private *vp =
-	    (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int i;
 
@@ -1476,7 +1470,7 @@
 
 static struct net_device_stats *corkscrew_get_stats(struct net_device *dev)
 {
-	struct corkscrew_private *vp = (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	unsigned long flags;
 
 	if (netif_running(dev)) {
@@ -1496,8 +1490,7 @@
 	*/
 static void update_stats(int ioaddr, struct net_device *dev)
 {
-	struct corkscrew_private *vp =
-	    (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 
 	/* Unlike the 3c5x9 we need not turn off stats updates while reading. */
 	/* Switch to the stats window, and read everything. */
