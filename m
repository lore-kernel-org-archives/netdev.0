From: Ben Boeckel <mathstuf@gmail.com>
Subject: [PATCH net-next 1/6] epic100: replace printk with netdev_ calls
Date: Fri, 25 Oct 2013 02:26:57 -0400
Message-ID: <1382682422-22677-2-git-send-email-mathstuf@gmail.com>
References: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
Cc: Ben Boeckel <mathstuf@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f41.google.com ([209.85.216.41]:54652 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066Ab3JYG1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 02:27:13 -0400
Received: by mail-qa0-f41.google.com with SMTP id f11so349849qae.0
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 23:27:12 -0700 (PDT)
In-Reply-To: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Boeckel <mathstuf@gmail.com>
---
 drivers/net/ethernet/smsc/epic100.c | 57 ++++++++++++++++++-------------------
 1 file changed, 27 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
index 8c5c24a..578a773 100644
--- a/drivers/net/ethernet/smsc/epic100.c
+++ b/drivers/net/ethernet/smsc/epic100.c
@@ -91,9 +91,9 @@ static int rx_copybreak;
 
 /* These identify the driver base version and may not be removed. */
 static char version[] =
-DRV_NAME ".c:v1.11 1/7/2001 Written by Donald Becker <becker@scyld.com>\n";
+DRV_NAME ".c:v1.11 1/7/2001 Written by Donald Becker <becker@scyld.com>";
 static char version2[] =
-"  (unofficial 2.4.x kernel port, version " DRV_VERSION ", " DRV_RELDATE ")\n";
+"  (unofficial 2.4.x kernel port, version " DRV_VERSION ", " DRV_RELDATE ")";
 
 MODULE_AUTHOR("Donald Becker <becker@scyld.com>");
 MODULE_DESCRIPTION("SMC 83c170 EPIC series Ethernet driver");
@@ -332,9 +332,7 @@ static int epic_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 /* when built into the kernel, we only print version if device is found */
 #ifndef MODULE
-	static int printed_version;
-	if (!printed_version++)
-		printk(KERN_INFO "%s%s", version, version2);
+	pr_info_once("%s%s\n", version, version2);
 #endif
 
 	card_idx++;
@@ -490,7 +488,7 @@ static int epic_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (ret < 0)
 		goto err_out_unmap_rx;
 
-	printk(KERN_INFO "%s: %s at %lx, IRQ %d, %pM\n",
+	netdev_info(dev, "%s: %s at %lx, IRQ %d, %pM\n",
 	       dev->name, pci_id_tbl[chip_idx].name,
 	       (long)pci_resource_start(pdev, EPIC_BAR), pdev->irq,
 	       dev->dev_addr);
@@ -703,7 +701,7 @@ static int epic_open(struct net_device *dev)
 			mdio_write(dev, ep->phys[0], MII_BMCR, media2miictl[dev->if_port&15]);
 		if (dev->if_port == 1) {
 			if (debug > 1)
-				printk(KERN_INFO "%s: Using the 10base2 transceiver, MII "
+				netdev_info(dev, "%s: Using the 10base2 transceiver, MII "
 					   "status %4.4x.\n",
 					   dev->name, mdio_read(dev, ep->phys[0], MII_BMSR));
 		}
@@ -715,7 +713,7 @@ static int epic_open(struct net_device *dev)
 			else if (! (mii_lpa & LPA_LPACK))
 				mdio_write(dev, ep->phys[0], MII_BMCR, BMCR_ANENABLE|BMCR_ANRESTART);
 			if (debug > 1)
-				printk(KERN_INFO "%s: Setting %s-duplex based on MII xcvr %d"
+				netdev_info(dev, "%s: Setting %s-duplex based on MII xcvr %d"
 					   " register read of %4.4x.\n", dev->name,
 					   ep->mii.full_duplex ? "full" : "half",
 					   ep->phys[0], mii_lpa);
@@ -738,7 +736,7 @@ static int epic_open(struct net_device *dev)
 	     TxUnderrun);
 
 	if (debug > 1) {
-		printk(KERN_DEBUG "%s: epic_open() ioaddr %p IRQ %d "
+		netdev_dbg(dev, "%s: epic_open() ioaddr %p IRQ %d "
 		       "status %4.4x %s-duplex.\n",
 		       dev->name, ioaddr, irq, er32(GENCTL),
 		       ep->mii.full_duplex ? "full" : "half");
@@ -790,7 +788,7 @@ static void epic_restart(struct net_device *dev)
 	/* Soft reset the chip. */
 	ew32(GENCTL, 0x4001);
 
-	printk(KERN_DEBUG "%s: Restarting the EPIC chip, Rx %d/%d Tx %d/%d.\n",
+	netdev_dbg(dev, "%s: Restarting the EPIC chip, Rx %d/%d Tx %d/%d.\n",
 		   dev->name, ep->cur_rx, ep->dirty_rx, ep->dirty_tx, ep->cur_tx);
 	udelay(1);
 
@@ -827,7 +825,7 @@ static void epic_restart(struct net_device *dev)
 	     ((ep->chip_flags & TYPE2_INTR) ? PCIBusErr175 : PCIBusErr170) |
 	     TxUnderrun);
 
-	printk(KERN_DEBUG "%s: epic_restart() done, cmd status %4.4x, ctl %4.4x"
+	netdev_dbg(dev, "%s: epic_restart() done, cmd status %4.4x, ctl %4.4x"
 		   " interrupt %4.4x.\n",
 		   dev->name, er32(COMMAND), er32(GENCTL), er32(INTSTAT));
 }
@@ -846,7 +844,7 @@ static void check_media(struct net_device *dev)
 		return;
 	if (ep->mii.full_duplex != duplex) {
 		ep->mii.full_duplex = duplex;
-		printk(KERN_INFO "%s: Setting %s-duplex based on MII #%d link"
+		netdev_info(dev, "%s: Setting %s-duplex based on MII #%d link"
 			   " partner capability of %4.4x.\n", dev->name,
 			   ep->mii.full_duplex ? "full" : "half", ep->phys[0], mii_lpa);
 		ew32(TxCtrl, ep->mii.full_duplex ? 0x7F : 0x79);
@@ -861,9 +859,9 @@ static void epic_timer(unsigned long data)
 	int next_tick = 5*HZ;
 
 	if (debug > 3) {
-		printk(KERN_DEBUG "%s: Media monitor tick, Tx status %8.8x.\n",
+		netdev_dbg(dev, "%s: Media monitor tick, Tx status %8.8x.\n",
 		       dev->name, er32(TxSTAT));
-		printk(KERN_DEBUG "%s: Other registers are IntMask %4.4x "
+		netdev_dbg(dev, "%s: Other registers are IntMask %4.4x "
 		       "IntStatus %4.4x RxStatus %4.4x.\n", dev->name,
 		       er32(INTMASK), er32(INTSTAT), er32(RxSTAT));
 	}
@@ -880,10 +878,10 @@ static void epic_tx_timeout(struct net_device *dev)
 	void __iomem *ioaddr = ep->ioaddr;
 
 	if (debug > 0) {
-		printk(KERN_WARNING "%s: Transmit timeout using MII device, "
+		netdev_warn(dev, "%s: Transmit timeout using MII device, "
 		       "Tx status %4.4x.\n", dev->name, er16(TxSTAT));
 		if (debug > 1) {
-			printk(KERN_DEBUG "%s: Tx indices: dirty_tx %d, cur_tx %d.\n",
+			netdev_dbg(dev, "%s: Tx indices: dirty_tx %d, cur_tx %d.\n",
 				   dev->name, ep->dirty_tx, ep->cur_tx);
 		}
 	}
@@ -994,7 +992,7 @@ static netdev_tx_t epic_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	ew32(COMMAND, TxQueued);
 
 	if (debug > 4)
-		printk(KERN_DEBUG "%s: Queued Tx packet size %d to slot %d, "
+		netdev_dbg(dev, "%s: Queued Tx packet size %d to slot %d, "
 		       "flag %2.2x Tx status %8.8x.\n", dev->name, skb->len,
 		       entry, ctrl_word, er32(TxSTAT));
 
@@ -1009,7 +1007,7 @@ static void epic_tx_error(struct net_device *dev, struct epic_private *ep,
 #ifndef final_version
 	/* There was an major error, log it. */
 	if (debug > 1)
-		printk(KERN_DEBUG "%s: Transmit error, Tx status %8.8x.\n",
+		netdev_dbg(dev, "%s: Transmit error, Tx status %8.8x.\n",
 		       dev->name, status);
 #endif
 	stats->tx_errors++;
@@ -1057,7 +1055,7 @@ static void epic_tx(struct net_device *dev, struct epic_private *ep)
 
 #ifndef final_version
 	if (cur_tx - dirty_tx > TX_RING_SIZE) {
-		printk(KERN_WARNING
+		netdev_warn(dev,
 		       "%s: Out-of-sync dirty pointer, %d vs. %d, full=%d.\n",
 		       dev->name, dirty_tx, cur_tx, ep->tx_full);
 		dirty_tx += TX_RING_SIZE;
@@ -1086,7 +1084,7 @@ static irqreturn_t epic_interrupt(int irq, void *dev_instance)
 	ew32(INTSTAT, status & EpicNormalEvent);
 
 	if (debug > 4) {
-		printk(KERN_DEBUG "%s: Interrupt, status=%#8.8x new "
+		netdev_dbg(dev, "%s: Interrupt, status=%#8.8x new "
 		       "intstat=%#8.8x.\n", dev->name, status, er32(INTSTAT));
 	}
 
@@ -1125,7 +1123,7 @@ static irqreturn_t epic_interrupt(int irq, void *dev_instance)
 			ew32(COMMAND, RestartTx);
 		}
 		if (status & PCIBusErr170) {
-			printk(KERN_ERR "%s: PCI Bus Error! status %4.4x.\n",
+			netdev_err(dev, "%s: PCI Bus Error! status %4.4x.\n",
 					 dev->name, status);
 			epic_pause(dev);
 			epic_restart(dev);
@@ -1136,7 +1134,7 @@ static irqreturn_t epic_interrupt(int irq, void *dev_instance)
 
 out:
 	if (debug > 3) {
-		printk(KERN_DEBUG "%s: exit interrupt, intr_status=%#4.4x.\n",
+		netdev_dbg(dev, "%s: exit interrupt, intr_status=%#4.4x.\n",
 				   dev->name, status);
 	}
 
@@ -1151,7 +1149,7 @@ static int epic_rx(struct net_device *dev, int budget)
 	int work_done = 0;
 
 	if (debug > 4)
-		printk(KERN_DEBUG " In epic_rx(), entry %d %8.8x.\n", entry,
+		netdev_dbg(dev, " In epic_rx(), entry %d %8.8x.\n", entry,
 			   ep->rx_ring[entry].rxstatus);
 
 	if (rx_work_limit > budget)
@@ -1162,15 +1160,15 @@ static int epic_rx(struct net_device *dev, int budget)
 		int status = ep->rx_ring[entry].rxstatus;
 
 		if (debug > 4)
-			printk(KERN_DEBUG "  epic_rx() status was %8.8x.\n", status);
+			netdev_dbg(dev, "  epic_rx() status was %8.8x.\n", status);
 		if (--rx_work_limit < 0)
 			break;
 		if (status & 0x2006) {
 			if (debug > 2)
-				printk(KERN_DEBUG "%s: epic_rx() error status was %8.8x.\n",
+				netdev_dbg(dev, "%s: epic_rx() error status was %8.8x.\n",
 					   dev->name, status);
 			if (status & 0x2000) {
-				printk(KERN_WARNING "%s: Oversized Ethernet frame spanned "
+				netdev_warn(dev, "%s: Oversized Ethernet frame spanned "
 					   "multiple buffers, status %4.4x!\n", dev->name, status);
 				dev->stats.rx_length_errors++;
 			} else if (status & 0x0006)
@@ -1183,7 +1181,7 @@ static int epic_rx(struct net_device *dev, int budget)
 			struct sk_buff *skb;
 
 			if (pkt_len > PKT_BUF_SZ - 4) {
-				printk(KERN_ERR "%s: Oversized Ethernet frame, status %x "
+				netdev_err(dev, "%s: Oversized Ethernet frame, status %x "
 					   "%d bytes.\n",
 					   dev->name, status, pkt_len);
 				pkt_len = 1514;
@@ -1305,7 +1303,7 @@ static int epic_close(struct net_device *dev)
 	napi_disable(&ep->napi);
 
 	if (debug > 1)
-		printk(KERN_DEBUG "%s: Shutting down ethercard, status was %2.2x.\n",
+		netdev_dbg(dev, "%s: Shutting down ethercard, status was %2.2x.\n",
 		       dev->name, er32(INTSTAT));
 
 	del_timer_sync(&ep->timer);
@@ -1587,8 +1585,7 @@ static int __init epic_init (void)
 {
 /* when a module, this is printed whether or not devices are found in probe */
 #ifdef MODULE
-	printk (KERN_INFO "%s%s",
-		version, version2);
+	pr_info ("%s%s\n", version, version2);
 #endif
 
 	return pci_register_driver(&epic_driver);
-- 
1.8.3.1
