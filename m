From: "Jike Song" <albcamus@gmail.com>
Subject: [PATCH] pci-skeleton: Misc fixes to build neatly
Date: Tue, 22 Jan 2008 14:16:34 +0800
Message-ID: <df9815e70801212216v79ff8137kccc6a94ddb96c818@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:14152 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbYAVGQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 01:16:36 -0500
Received: by py-out-1112.google.com with SMTP id u52so3407402pyb.10
        for <netdev@vger.kernel.org>; Mon, 21 Jan 2008 22:16:35 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jeff,

The pci-skeleton.c has several problems with compilation, such as missing args
when calling synchronize_irq(). Fix it.

Signed-off-by: Jike Song <albcamus@gmail.com>
---
 drivers/net/pci-skeleton.c |   49 ++++++++++++++++++++++---------------------
 1 files changed, 25 insertions(+), 24 deletions(-)

diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index ed402e0..fffc49b 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -541,7 +541,7 @@ static void netdrv_hw_start (struct net_device *dev);
 #define NETDRV_W32_F(reg, val32)	do { writel ((val32), ioaddr +
(reg)); readl (ioaddr + (reg)); } while (0)


-#if MMIO_FLUSH_AUDIT_COMPLETE
+#ifdef MMIO_FLUSH_AUDIT_COMPLETE

 /* write MMIO register */
 #define NETDRV_W8(reg, val8)	writeb ((val8), ioaddr + (reg))
@@ -603,7 +603,7 @@ static int __devinit netdrv_init_board (struct
pci_dev *pdev,
 		return -ENOMEM;
 	}
 	SET_NETDEV_DEV(dev, &pdev->dev);
-	tp = dev->priv;
+	tp = netdev_priv(dev);

 	/* enable device (incl. PCI PM wakeup), and bus-mastering */
 	rc = pci_enable_device (pdev);
@@ -759,7 +759,7 @@ static int __devinit netdrv_init_one (struct pci_dev *pdev,
 		return i;
 	}

-	tp = dev->priv;
+	tp = netdev_priv(dev);

 	assert (ioaddr != NULL);
 	assert (dev != NULL);
@@ -783,7 +783,7 @@ static int __devinit netdrv_init_one (struct pci_dev *pdev,
 	dev->base_addr = (unsigned long) ioaddr;

 	/* dev->priv/tp zeroed and aligned in alloc_etherdev */
-	tp = dev->priv;
+	tp = netdev_priv(dev);

 	/* note: tp->chipset set in netdrv_init_board */
 	tp->drv_flags = PCI_COMMAND_IO | PCI_COMMAND_MEMORY |
@@ -841,7 +841,7 @@ static void __devexit netdrv_remove_one (struct
pci_dev *pdev)

 	assert (dev != NULL);

-	np = dev->priv;
+	np = netdev_priv(dev);
 	assert (np != NULL);

 	unregister_netdev (dev);
@@ -974,7 +974,7 @@ static void mdio_sync (void *mdio_addr)

 static int mdio_read (struct net_device *dev, int phy_id, int location)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *mdio_addr = tp->mmio_addr + Config4;
 	int mii_cmd = (0xf6 << 10) | (phy_id << 5) | location;
 	int retval = 0;
@@ -1017,7 +1017,7 @@ static int mdio_read (struct net_device *dev,
int phy_id, int location)
 static void mdio_write (struct net_device *dev, int phy_id, int location,
 			int value)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *mdio_addr = tp->mmio_addr + Config4;
 	int mii_cmd =
 	    (0x5002 << 16) | (phy_id << 23) | (location << 18) | value;
@@ -1060,7 +1060,7 @@ static void mdio_write (struct net_device *dev,
int phy_id, int location,

 static int netdrv_open (struct net_device *dev)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	int retval;
 #ifdef NETDRV_DEBUG
 	void *ioaddr = tp->mmio_addr;
@@ -1121,7 +1121,7 @@ static int netdrv_open (struct net_device *dev)
 /* Start the hardware at open or resume. */
 static void netdrv_hw_start (struct net_device *dev)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	u32 i;

@@ -1191,7 +1191,7 @@ static void netdrv_hw_start (struct net_device *dev)
 /* Initialize the Rx and Tx rings, along with various 'dev' bits. */
 static void netdrv_init_ring (struct net_device *dev)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	int i;

 	DPRINTK ("ENTER\n");
@@ -1213,7 +1213,7 @@ static void netdrv_init_ring (struct net_device *dev)
 static void netdrv_timer (unsigned long data)
 {
 	struct net_device *dev = (struct net_device *) data;
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	int next_tick = 60 * HZ;
 	int mii_lpa;
@@ -1252,9 +1252,10 @@ static void netdrv_timer (unsigned long data)
 }


-static void netdrv_tx_clear (struct netdrv_private *tp)
+static void netdrv_tx_clear (struct net_device *dev)
 {
 	int i;
+	struct netdrv_private *tp = netdev_priv(dev);

 	atomic_set (&tp->cur_tx, 0);
 	atomic_set (&tp->dirty_tx, 0);
@@ -1278,7 +1279,7 @@ static void netdrv_tx_clear (struct netdrv_private *tp)

 static void netdrv_tx_timeout (struct net_device *dev)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	int i;
 	u8 tmp8;
@@ -1311,7 +1312,7 @@ static void netdrv_tx_timeout (struct net_device *dev)
 	/* Stop a shared interrupt from scavenging while we are. */
 	spin_lock_irqsave (&tp->lock, flags);

-	netdrv_tx_clear (tp);
+	netdrv_tx_clear (dev);

 	spin_unlock_irqrestore (&tp->lock, flags);

@@ -1325,7 +1326,7 @@ static void netdrv_tx_timeout (struct net_device *dev)

 static int netdrv_start_xmit (struct sk_buff *skb, struct net_device *dev)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	int entry;

@@ -1525,7 +1526,7 @@ static void netdrv_rx_interrupt (struct net_device *dev,
 		DPRINTK ("%s:  netdrv_rx() status %4.4x, size %4.4x,"
 			 " cur %4.4x.\n", dev->name, rx_status,
 			 rx_size, cur_rx);
-#if NETDRV_DEBUG > 2
+#if defined(NETDRV_DEBUG) && (NETDRV_DEBUG > 2)
 		{
 			int i;
 			DPRINTK ("%s: Frame contents ", dev->name);
@@ -1648,7 +1649,7 @@ static void netdrv_weird_interrupt (struct
net_device *dev,
 static irqreturn_t netdrv_interrupt (int irq, void *dev_instance)
 {
 	struct net_device *dev = (struct net_device *) dev_instance;
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	int boguscnt = max_interrupt_work;
 	void *ioaddr = tp->mmio_addr;
 	int status = 0, link_changed = 0; /* avoid bogus "uninit" warning */
@@ -1711,7 +1712,7 @@ static irqreturn_t netdrv_interrupt (int irq,
void *dev_instance)

 static int netdrv_close (struct net_device *dev)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	unsigned long flags;

@@ -1738,10 +1739,10 @@ static int netdrv_close (struct net_device *dev)

 	spin_unlock_irqrestore (&tp->lock, flags);

-	synchronize_irq ();
+	synchronize_irq (dev->irq);
 	free_irq (dev->irq, dev);

-	netdrv_tx_clear (tp);
+	netdrv_tx_clear (dev);

 	pci_free_consistent(tp->pci_dev, RX_BUF_TOT_LEN,
 			    tp->rx_ring, tp->rx_ring_dma);
@@ -1762,7 +1763,7 @@ static int netdrv_close (struct net_device *dev)

 static int netdrv_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	struct mii_ioctl_data *data = if_mii(rq);
 	unsigned long flags;
 	int rc = 0;
@@ -1805,7 +1806,7 @@ static int netdrv_ioctl (struct net_device *dev,
struct ifreq *rq, int cmd)

 static void netdrv_set_rx_mode (struct net_device *dev)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	u32 mc_filter[2];	/* Multicast hash filter */
 	int i, rx_mode;
@@ -1862,7 +1863,7 @@ static void netdrv_set_rx_mode (struct net_device *dev)
 static int netdrv_suspend (struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	unsigned long flags;

@@ -1892,7 +1893,7 @@ static int netdrv_suspend (struct pci_dev *pdev,
pm_message_t state)
 static int netdrv_resume (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct netdrv_private *tp = dev->priv;
+	/*struct netdrv_private *tp = netdev_priv(dev);*/

 	if (!netif_running(dev))
 		return 0;
-- 
1.5.3.4
