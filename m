From: Ben Boeckel <mathstuf@gmail.com>
Subject: [PATCHv3 net-next 1/7] epic100: replace printk with netdev_ calls
Date: Fri,  1 Nov 2013 08:53:30 -0400
Message-ID: <1383310416-27177-2-git-send-email-mathstuf@gmail.com>
References: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
 <1383310416-27177-1-git-send-email-mathstuf@gmail.com>
Cc: Ben Boeckel <mathstuf@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:34419 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796Ab3KAMxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 08:53:45 -0400
Received: by mail-qc0-f178.google.com with SMTP id x19so2419383qcw.37
        for <netdev@vger.kernel.org>; Fri, 01 Nov 2013 05:53:44 -0700 (PDT)
In-Reply-To: <1383310416-27177-1-git-send-email-mathstuf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also snipes some whitespace errors.

Signed-off-by: Ben Boeckel <mathstuf@gmail.com>
---
 drivers/net/ethernet/smsc/epic100.c | 125 +++++++++++++++++-------------------
 1 file changed, 58 insertions(+), 67 deletions(-)

diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
index 8c5c24a..8ae1f8a7 100644
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
@@ -423,9 +421,9 @@ static int epic_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		((__le16 *)dev->dev_addr)[i] = cpu_to_le16(er16(LAN0 + i*4));
 
 	if (debug > 2) {
-		dev_printk(KERN_DEBUG, &pdev->dev, "EEPROM contents:\n");
+		dev_dbg(&pdev->dev, "EEPROM contents:\n");
 		for (i = 0; i < 64; i++)
-			printk(" %4.4x%s", read_eeprom(ep, i),
+			pr_cont(" %4.4x%s", read_eeprom(ep, i),
 				   i % 16 == 15 ? "\n" : "");
 	}
 
@@ -490,10 +488,10 @@ static int epic_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (ret < 0)
 		goto err_out_unmap_rx;
 
-	printk(KERN_INFO "%s: %s at %lx, IRQ %d, %pM\n",
-	       dev->name, pci_id_tbl[chip_idx].name,
-	       (long)pci_resource_start(pdev, EPIC_BAR), pdev->irq,
-	       dev->dev_addr);
+	netdev_info(dev, "%s at %lx, IRQ %d, %pM\n",
+		    pci_id_tbl[chip_idx].name,
+		    (long)pci_resource_start(pdev, EPIC_BAR), pdev->irq,
+		    dev->dev_addr);
 
 out:
 	return ret;
@@ -703,9 +701,8 @@ static int epic_open(struct net_device *dev)
 			mdio_write(dev, ep->phys[0], MII_BMCR, media2miictl[dev->if_port&15]);
 		if (dev->if_port == 1) {
 			if (debug > 1)
-				printk(KERN_INFO "%s: Using the 10base2 transceiver, MII "
-					   "status %4.4x.\n",
-					   dev->name, mdio_read(dev, ep->phys[0], MII_BMSR));
+				netdev_info(dev, "Using the 10base2 transceiver, MII status %4.4x.\n",
+					    mdio_read(dev, ep->phys[0], MII_BMSR));
 		}
 	} else {
 		int mii_lpa = mdio_read(dev, ep->phys[0], MII_LPA);
@@ -715,10 +712,10 @@ static int epic_open(struct net_device *dev)
 			else if (! (mii_lpa & LPA_LPACK))
 				mdio_write(dev, ep->phys[0], MII_BMCR, BMCR_ANENABLE|BMCR_ANRESTART);
 			if (debug > 1)
-				printk(KERN_INFO "%s: Setting %s-duplex based on MII xcvr %d"
-					   " register read of %4.4x.\n", dev->name,
-					   ep->mii.full_duplex ? "full" : "half",
-					   ep->phys[0], mii_lpa);
+				netdev_info(dev, "Setting %s-duplex based on MII xcvr %d register read of %4.4x.\n",
+					    ep->mii.full_duplex ? "full"
+								: "half",
+					    ep->phys[0], mii_lpa);
 		}
 	}
 
@@ -738,10 +735,9 @@ static int epic_open(struct net_device *dev)
 	     TxUnderrun);
 
 	if (debug > 1) {
-		printk(KERN_DEBUG "%s: epic_open() ioaddr %p IRQ %d "
-		       "status %4.4x %s-duplex.\n",
-		       dev->name, ioaddr, irq, er32(GENCTL),
-		       ep->mii.full_duplex ? "full" : "half");
+		netdev_dbg(dev, "epic_open() ioaddr %p IRQ %d status %4.4x %s-duplex.\n",
+			   ioaddr, irq, er32(GENCTL),
+			   ep->mii.full_duplex ? "full" : "half");
 	}
 
 	/* Set the timer to switch to check for link beat and perhaps switch
@@ -790,8 +786,8 @@ static void epic_restart(struct net_device *dev)
 	/* Soft reset the chip. */
 	ew32(GENCTL, 0x4001);
 
-	printk(KERN_DEBUG "%s: Restarting the EPIC chip, Rx %d/%d Tx %d/%d.\n",
-		   dev->name, ep->cur_rx, ep->dirty_rx, ep->dirty_tx, ep->cur_tx);
+	netdev_dbg(dev, "Restarting the EPIC chip, Rx %d/%d Tx %d/%d.\n",
+		   ep->cur_rx, ep->dirty_rx, ep->dirty_tx, ep->cur_tx);
 	udelay(1);
 
 	/* This magic is documented in SMSC app note 7.15 */
@@ -827,9 +823,8 @@ static void epic_restart(struct net_device *dev)
 	     ((ep->chip_flags & TYPE2_INTR) ? PCIBusErr175 : PCIBusErr170) |
 	     TxUnderrun);
 
-	printk(KERN_DEBUG "%s: epic_restart() done, cmd status %4.4x, ctl %4.4x"
-		   " interrupt %4.4x.\n",
-		   dev->name, er32(COMMAND), er32(GENCTL), er32(INTSTAT));
+	netdev_dbg(dev, "epic_restart() done, cmd status %4.4x, ctl %4.4x interrupt %4.4x.\n",
+		   er32(COMMAND), er32(GENCTL), er32(INTSTAT));
 }
 
 static void check_media(struct net_device *dev)
@@ -846,9 +841,9 @@ static void check_media(struct net_device *dev)
 		return;
 	if (ep->mii.full_duplex != duplex) {
 		ep->mii.full_duplex = duplex;
-		printk(KERN_INFO "%s: Setting %s-duplex based on MII #%d link"
-			   " partner capability of %4.4x.\n", dev->name,
-			   ep->mii.full_duplex ? "full" : "half", ep->phys[0], mii_lpa);
+		netdev_info(dev, "Setting %s-duplex based on MII #%d link partner capability of %4.4x.\n",
+			    ep->mii.full_duplex ? "full" : "half",
+			    ep->phys[0], mii_lpa);
 		ew32(TxCtrl, ep->mii.full_duplex ? 0x7F : 0x79);
 	}
 }
@@ -861,11 +856,10 @@ static void epic_timer(unsigned long data)
 	int next_tick = 5*HZ;
 
 	if (debug > 3) {
-		printk(KERN_DEBUG "%s: Media monitor tick, Tx status %8.8x.\n",
-		       dev->name, er32(TxSTAT));
-		printk(KERN_DEBUG "%s: Other registers are IntMask %4.4x "
-		       "IntStatus %4.4x RxStatus %4.4x.\n", dev->name,
-		       er32(INTMASK), er32(INTSTAT), er32(RxSTAT));
+		netdev_dbg(dev, "Media monitor tick, Tx status %8.8x.\n",
+			   er32(TxSTAT));
+		netdev_dbg(dev, "Other registers are IntMask %4.4x IntStatus %4.4x RxStatus %4.4x.\n",
+			   er32(INTMASK), er32(INTSTAT), er32(RxSTAT));
 	}
 
 	check_media(dev);
@@ -880,11 +874,11 @@ static void epic_tx_timeout(struct net_device *dev)
 	void __iomem *ioaddr = ep->ioaddr;
 
 	if (debug > 0) {
-		printk(KERN_WARNING "%s: Transmit timeout using MII device, "
-		       "Tx status %4.4x.\n", dev->name, er16(TxSTAT));
+		netdev_warn(dev, "Transmit timeout using MII device, Tx status %4.4x.\n",
+			    er16(TxSTAT));
 		if (debug > 1) {
-			printk(KERN_DEBUG "%s: Tx indices: dirty_tx %d, cur_tx %d.\n",
-				   dev->name, ep->dirty_tx, ep->cur_tx);
+			netdev_dbg(dev, "Tx indices: dirty_tx %d, cur_tx %d.\n",
+				   ep->dirty_tx, ep->cur_tx);
 		}
 	}
 	if (er16(TxSTAT) & 0x10) {		/* Tx FIFO underflow. */
@@ -994,9 +988,8 @@ static netdev_tx_t epic_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	ew32(COMMAND, TxQueued);
 
 	if (debug > 4)
-		printk(KERN_DEBUG "%s: Queued Tx packet size %d to slot %d, "
-		       "flag %2.2x Tx status %8.8x.\n", dev->name, skb->len,
-		       entry, ctrl_word, er32(TxSTAT));
+		netdev_dbg(dev, "Queued Tx packet size %d to slot %d, flag %2.2x Tx status %8.8x.\n",
+			   skb->len, entry, ctrl_word, er32(TxSTAT));
 
 	return NETDEV_TX_OK;
 }
@@ -1009,8 +1002,8 @@ static void epic_tx_error(struct net_device *dev, struct epic_private *ep,
 #ifndef final_version
 	/* There was an major error, log it. */
 	if (debug > 1)
-		printk(KERN_DEBUG "%s: Transmit error, Tx status %8.8x.\n",
-		       dev->name, status);
+		netdev_dbg(dev, "Transmit error, Tx status %8.8x.\n",
+			   status);
 #endif
 	stats->tx_errors++;
 	if (status & 0x1050)
@@ -1057,9 +1050,8 @@ static void epic_tx(struct net_device *dev, struct epic_private *ep)
 
 #ifndef final_version
 	if (cur_tx - dirty_tx > TX_RING_SIZE) {
-		printk(KERN_WARNING
-		       "%s: Out-of-sync dirty pointer, %d vs. %d, full=%d.\n",
-		       dev->name, dirty_tx, cur_tx, ep->tx_full);
+		netdev_warn(dev, "Out-of-sync dirty pointer, %d vs. %d, full=%d.\n",
+			    dirty_tx, cur_tx, ep->tx_full);
 		dirty_tx += TX_RING_SIZE;
 	}
 #endif
@@ -1086,8 +1078,8 @@ static irqreturn_t epic_interrupt(int irq, void *dev_instance)
 	ew32(INTSTAT, status & EpicNormalEvent);
 
 	if (debug > 4) {
-		printk(KERN_DEBUG "%s: Interrupt, status=%#8.8x new "
-		       "intstat=%#8.8x.\n", dev->name, status, er32(INTSTAT));
+		netdev_dbg(dev, "Interrupt, status=%#8.8x new intstat=%#8.8x.\n",
+			   status, er32(INTSTAT));
 	}
 
 	if ((status & IntrSummary) == 0)
@@ -1125,8 +1117,8 @@ static irqreturn_t epic_interrupt(int irq, void *dev_instance)
 			ew32(COMMAND, RestartTx);
 		}
 		if (status & PCIBusErr170) {
-			printk(KERN_ERR "%s: PCI Bus Error! status %4.4x.\n",
-					 dev->name, status);
+			netdev_err(dev, "PCI Bus Error! status %4.4x.\n",
+				   status);
 			epic_pause(dev);
 			epic_restart(dev);
 		}
@@ -1136,8 +1128,8 @@ static irqreturn_t epic_interrupt(int irq, void *dev_instance)
 
 out:
 	if (debug > 3) {
-		printk(KERN_DEBUG "%s: exit interrupt, intr_status=%#4.4x.\n",
-				   dev->name, status);
+		netdev_dbg(dev, "exit interrupt, intr_status=%#4.4x.\n",
+			   status);
 	}
 
 	return IRQ_RETVAL(handled);
@@ -1151,7 +1143,7 @@ static int epic_rx(struct net_device *dev, int budget)
 	int work_done = 0;
 
 	if (debug > 4)
-		printk(KERN_DEBUG " In epic_rx(), entry %d %8.8x.\n", entry,
+		netdev_dbg(dev, " In epic_rx(), entry %d %8.8x.\n", entry,
 			   ep->rx_ring[entry].rxstatus);
 
 	if (rx_work_limit > budget)
@@ -1162,16 +1154,17 @@ static int epic_rx(struct net_device *dev, int budget)
 		int status = ep->rx_ring[entry].rxstatus;
 
 		if (debug > 4)
-			printk(KERN_DEBUG "  epic_rx() status was %8.8x.\n", status);
+			netdev_dbg(dev, "  epic_rx() status was %8.8x.\n",
+				   status);
 		if (--rx_work_limit < 0)
 			break;
 		if (status & 0x2006) {
 			if (debug > 2)
-				printk(KERN_DEBUG "%s: epic_rx() error status was %8.8x.\n",
-					   dev->name, status);
+				netdev_dbg(dev, "epic_rx() error status was %8.8x.\n",
+					   status);
 			if (status & 0x2000) {
-				printk(KERN_WARNING "%s: Oversized Ethernet frame spanned "
-					   "multiple buffers, status %4.4x!\n", dev->name, status);
+				netdev_warn(dev, "Oversized Ethernet frame spanned multiple buffers, status %4.4x!\n",
+					    status);
 				dev->stats.rx_length_errors++;
 			} else if (status & 0x0006)
 				/* Rx Frame errors are counted in hardware. */
@@ -1183,9 +1176,8 @@ static int epic_rx(struct net_device *dev, int budget)
 			struct sk_buff *skb;
 
 			if (pkt_len > PKT_BUF_SZ - 4) {
-				printk(KERN_ERR "%s: Oversized Ethernet frame, status %x "
-					   "%d bytes.\n",
-					   dev->name, status, pkt_len);
+				netdev_err(dev, "Oversized Ethernet frame, status %x %d bytes.\n",
+					   status, pkt_len);
 				pkt_len = 1514;
 			}
 			/* Check if the packet is long enough to accept without copying
@@ -1305,8 +1297,8 @@ static int epic_close(struct net_device *dev)
 	napi_disable(&ep->napi);
 
 	if (debug > 1)
-		printk(KERN_DEBUG "%s: Shutting down ethercard, status was %2.2x.\n",
-		       dev->name, er32(INTSTAT));
+		netdev_dbg(dev, "Shutting down ethercard, status was %2.2x.\n",
+			   er32(INTSTAT));
 
 	del_timer_sync(&ep->timer);
 
@@ -1324,7 +1316,7 @@ static int epic_close(struct net_device *dev)
 		ep->rx_ring[i].buflength = 0;
 		if (skb) {
 			pci_unmap_single(pdev, ep->rx_ring[i].bufaddr,
-				 	 ep->rx_buf_sz, PCI_DMA_FROMDEVICE);
+					 ep->rx_buf_sz, PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(skb);
 		}
 		ep->rx_ring[i].bufaddr = 0xBADF00D0; /* An invalid address. */
@@ -1587,8 +1579,7 @@ static int __init epic_init (void)
 {
 /* when a module, this is printed whether or not devices are found in probe */
 #ifdef MODULE
-	printk (KERN_INFO "%s%s",
-		version, version2);
+	pr_info("%s%s\n", version, version2);
 #endif
 
 	return pci_register_driver(&epic_driver);
-- 
1.8.4.2
