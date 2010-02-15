From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 6/7] drivers/net/pcnet32.c: Use (pr|netdev|netif)_<levels> macro helpers
Date: Mon, 15 Feb 2010 10:34:25 -0800
Message-ID: <8ea684dc5b9ea20d3cb26995a36324ee133c4c20.1266258417.git.joe@perches.com>
References: <cover.1266258417.git.joe@perches.com>
Cc: Don Fry <pcnet32@verizon.net>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1082 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756067Ab0BOSec (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2010 13:34:32 -0500
In-Reply-To: <cover.1266258417.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the output logging messages a bit more consistent.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/pcnet32.c |  347 ++++++++++++++++++------------------------------
 1 files changed, 130 insertions(+), 217 deletions(-)

diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 3522794..9194abc 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -21,6 +21,8 @@
  *
  *************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define DRV_NAME	"pcnet32"
 #define DRV_VERSION	"1.35"
 #define DRV_RELDATE	"21.Apr.2008"
@@ -487,10 +489,7 @@ static void pcnet32_realloc_tx_ring(struct net_device *dev,
 					   (1 << size),
 					   &new_ring_dma_addr);
 	if (new_tx_ring == NULL) {
-		if (netif_msg_drv(lp))
-			printk(KERN_ERR
-			       "%s: Consistent memory allocation failed.\n",
-			       dev->name);
+		netif_err(lp, drv, dev, "Consistent memory allocation failed\n");
 		return;
 	}
 	memset(new_tx_ring, 0, sizeof(struct pcnet32_tx_head) * (1 << size));
@@ -498,18 +497,14 @@ static void pcnet32_realloc_tx_ring(struct net_device *dev,
 	new_dma_addr_list = kcalloc((1 << size), sizeof(dma_addr_t),
 				GFP_ATOMIC);
 	if (!new_dma_addr_list) {
-		if (netif_msg_drv(lp))
-			printk(KERN_ERR
-			       "%s: Memory allocation failed.\n", dev->name);
+		netif_err(lp, drv, dev, "Memory allocation failed\n");
 		goto free_new_tx_ring;
 	}
 
 	new_skb_list = kcalloc((1 << size), sizeof(struct sk_buff *),
 				GFP_ATOMIC);
 	if (!new_skb_list) {
-		if (netif_msg_drv(lp))
-			printk(KERN_ERR
-			       "%s: Memory allocation failed.\n", dev->name);
+		netif_err(lp, drv, dev, "Memory allocation failed\n");
 		goto free_new_lists;
 	}
 
@@ -565,10 +560,7 @@ static void pcnet32_realloc_rx_ring(struct net_device *dev,
 					   (1 << size),
 					   &new_ring_dma_addr);
 	if (new_rx_ring == NULL) {
-		if (netif_msg_drv(lp))
-			printk(KERN_ERR
-			       "%s: Consistent memory allocation failed.\n",
-			       dev->name);
+		netif_err(lp, drv, dev, "Consistent memory allocation failed\n");
 		return;
 	}
 	memset(new_rx_ring, 0, sizeof(struct pcnet32_rx_head) * (1 << size));
@@ -576,18 +568,14 @@ static void pcnet32_realloc_rx_ring(struct net_device *dev,
 	new_dma_addr_list = kcalloc((1 << size), sizeof(dma_addr_t),
 				GFP_ATOMIC);
 	if (!new_dma_addr_list) {
-		if (netif_msg_drv(lp))
-			printk(KERN_ERR
-			       "%s: Memory allocation failed.\n", dev->name);
+		netif_err(lp, drv, dev, "Memory allocation failed\n");
 		goto free_new_rx_ring;
 	}
 
 	new_skb_list = kcalloc((1 << size), sizeof(struct sk_buff *),
 				GFP_ATOMIC);
 	if (!new_skb_list) {
-		if (netif_msg_drv(lp))
-			printk(KERN_ERR
-			       "%s: Memory allocation failed.\n", dev->name);
+		netif_err(lp, drv, dev, "Memory allocation failed\n");
 		goto free_new_lists;
 	}
 
@@ -604,10 +592,8 @@ static void pcnet32_realloc_rx_ring(struct net_device *dev,
 		new_skb_list[new] = dev_alloc_skb(PKT_BUF_SKB);
 		if (!(rx_skbuff = new_skb_list[new])) {
 			/* keep the original lists and buffers */
-			if (netif_msg_drv(lp))
-				printk(KERN_ERR
-				       "%s: pcnet32_realloc_rx_ring dev_alloc_skb failed.\n",
-				       dev->name);
+			netif_err(lp, drv, dev, "%s dev_alloc_skb failed\n",
+				  __func__);
 			goto free_all_new;
 		}
 		skb_reserve(rx_skbuff, NET_IP_ALIGN);
@@ -838,10 +824,8 @@ static int pcnet32_set_ringparam(struct net_device *dev,
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-	if (netif_msg_drv(lp))
-		printk(KERN_INFO
-		       "%s: Ring Param Settings: RX: %d, TX: %d\n", dev->name,
-		       lp->rx_ring_size, lp->tx_ring_size);
+	netif_info(lp, drv, dev, "Ring Param Settings: RX: %d, TX: %d\n",
+		   lp->rx_ring_size, lp->tx_ring_size);
 
 	return 0;
 }
@@ -871,17 +855,15 @@ static void pcnet32_ethtool_test(struct net_device *dev,
 	if (test->flags == ETH_TEST_FL_OFFLINE) {
 		rc = pcnet32_loopback_test(dev, data);
 		if (rc) {
-			if (netif_msg_hw(lp))
-				printk(KERN_DEBUG "%s: Loopback test failed.\n",
-				       dev->name);
+			netif_printk(lp, hw, KERN_DEBUG, dev,
+				     "Loopback test failed\n");
 			test->flags |= ETH_TEST_FL_FAILED;
-		} else if (netif_msg_hw(lp))
-			printk(KERN_DEBUG "%s: Loopback test passed.\n",
-			       dev->name);
-	} else if (netif_msg_hw(lp))
-		printk(KERN_DEBUG
-		       "%s: No tests to run (specify 'Offline' on ethtool).",
-		       dev->name);
+		} else
+			netif_printk(lp, hw, KERN_DEBUG, dev,
+				     "Loopback test passed\n");
+	} else
+		netif_printk(lp, hw, KERN_DEBUG, dev,
+			     "No tests to run (specify 'Offline' on ethtool)\n");
 }				/* end pcnet32_ethtool_test */
 
 static int pcnet32_loopback_test(struct net_device *dev, uint64_t * data1)
@@ -927,10 +909,9 @@ static int pcnet32_loopback_test(struct net_device *dev, uint64_t * data1)
 	size = data_len + 15;
 	for (x = 0; x < numbuffs; x++) {
 		if (!(skb = dev_alloc_skb(size))) {
-			if (netif_msg_hw(lp))
-				printk(KERN_DEBUG
-				       "%s: Cannot allocate skb at line: %d!\n",
-				       dev->name, __LINE__);
+			netif_printk(lp, hw, KERN_DEBUG, dev,
+				     "Cannot allocate skb at line: %d!\n",
+				     __LINE__);
 			goto clean_up;
 		} else {
 			packet = skb->data;
@@ -984,9 +965,7 @@ static int pcnet32_loopback_test(struct net_device *dev, uint64_t * data1)
 			ticks++;
 		}
 		if (ticks == 200) {
-			if (netif_msg_hw(lp))
-				printk("%s: Desc %d failed to reset!\n",
-				       dev->name, x);
+			netif_err(lp, hw, dev, "Desc %d failed to reset!\n", x);
 			break;
 		}
 	}
@@ -994,15 +973,15 @@ static int pcnet32_loopback_test(struct net_device *dev, uint64_t * data1)
 	lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);	/* Set STOP bit */
 	wmb();
 	if (netif_msg_hw(lp) && netif_msg_pktdata(lp)) {
-		printk(KERN_DEBUG "%s: RX loopback packets:\n", dev->name);
+		netdev_printk(KERN_DEBUG, dev, "RX loopback packets:\n");
 
 		for (x = 0; x < numbuffs; x++) {
-			printk(KERN_DEBUG "%s: Packet %d:\n", dev->name, x);
+			netdev_printk(KERN_DEBUG, dev, "Packet %d: ", x);
 			skb = lp->rx_skbuff[x];
 			for (i = 0; i < size; i++) {
-				printk("%02x ", *(skb->data + i));
+				pr_cont(" %02x", *(skb->data + i));
 			}
-			printk("\n");
+			pr_cont("\n");
 		}
 	}
 
@@ -1013,11 +992,9 @@ static int pcnet32_loopback_test(struct net_device *dev, uint64_t * data1)
 		packet = lp->tx_skbuff[x]->data;
 		for (i = 0; i < size; i++) {
 			if (*(skb->data + i) != packet[i]) {
-				if (netif_msg_hw(lp))
-					printk(KERN_DEBUG
-					       "%s: Error in compare! %2x - %02x %02x\n",
-					       dev->name, i, *(skb->data + i),
-					       packet[i]);
+				netif_printk(lp, hw, KERN_DEBUG, dev,
+					     "Error in compare! %2x - %02x %02x\n",
+					     i, *(skb->data + i), packet[i]);
 				rc = 1;
 				break;
 			}
@@ -1136,10 +1113,8 @@ static int pcnet32_suspend(struct net_device *dev, unsigned long *flags,
 		spin_lock_irqsave(&lp->lock, *flags);
 		ticks++;
 		if (ticks > 200) {
-			if (netif_msg_hw(lp))
-				printk(KERN_DEBUG
-				       "%s: Error getting into suspend!\n",
-				       dev->name);
+			netif_printk(lp, hw, KERN_DEBUG, dev,
+				     "Error getting into suspend!\n");
 			return 0;
 		}
 	}
@@ -1184,15 +1159,13 @@ static void pcnet32_rx_entry(struct net_device *dev,
 
 	/* Discard oversize frames. */
 	if (unlikely(pkt_len > PKT_BUF_SIZE)) {
-		if (netif_msg_drv(lp))
-			printk(KERN_ERR "%s: Impossible packet size %d!\n",
-			       dev->name, pkt_len);
+		netif_err(lp, drv, dev, "Impossible packet size %d!\n",
+			  pkt_len);
 		dev->stats.rx_errors++;
 		return;
 	}
 	if (pkt_len < 60) {
-		if (netif_msg_rx_err(lp))
-			printk(KERN_ERR "%s: Runt packet!\n", dev->name);
+		netif_err(lp, rx_err, dev, "Runt packet!\n");
 		dev->stats.rx_errors++;
 		return;
 	}
@@ -1223,10 +1196,7 @@ static void pcnet32_rx_entry(struct net_device *dev,
 	}
 
 	if (skb == NULL) {
-		if (netif_msg_drv(lp))
-			printk(KERN_ERR
-			       "%s: Memory squeeze, dropping packet.\n",
-			       dev->name);
+		netif_err(lp, drv, dev, "Memory squeeze, dropping packet\n");
 		dev->stats.rx_dropped++;
 		return;
 	}
@@ -1297,11 +1267,9 @@ static int pcnet32_tx(struct net_device *dev)
 			/* There was a major error, log it. */
 			int err_status = le32_to_cpu(lp->tx_ring[entry].misc);
 			dev->stats.tx_errors++;
-			if (netif_msg_tx_err(lp))
-				printk(KERN_ERR
-				       "%s: Tx error status=%04x err_status=%08x\n",
-				       dev->name, status,
-				       err_status);
+			netif_err(lp, tx_err, dev,
+				  "Tx error status=%04x err_status=%08x\n",
+				  status, err_status);
 			if (err_status & 0x04000000)
 				dev->stats.tx_aborted_errors++;
 			if (err_status & 0x08000000)
@@ -1313,10 +1281,7 @@ static int pcnet32_tx(struct net_device *dev)
 				dev->stats.tx_fifo_errors++;
 				/* Ackk!  On FIFO errors the Tx unit is turned off! */
 				/* Remove this verbosity later! */
-				if (netif_msg_tx_err(lp))
-					printk(KERN_ERR
-					       "%s: Tx FIFO error!\n",
-					       dev->name);
+				netif_err(lp, tx_err, dev, "Tx FIFO error!\n");
 				must_restart = 1;
 			}
 #else
@@ -1325,10 +1290,7 @@ static int pcnet32_tx(struct net_device *dev)
 				if (!lp->dxsuflo) {	/* If controller doesn't recover ... */
 					/* Ackk!  On FIFO errors the Tx unit is turned off! */
 					/* Remove this verbosity later! */
-					if (netif_msg_tx_err(lp))
-						printk(KERN_ERR
-						       "%s: Tx FIFO error!\n",
-						       dev->name);
+					netif_err(lp, tx_err, dev, "Tx FIFO error!\n");
 					must_restart = 1;
 				}
 			}
@@ -1354,11 +1316,8 @@ static int pcnet32_tx(struct net_device *dev)
 
 	delta = (lp->cur_tx - dirty_tx) & (lp->tx_mod_mask + lp->tx_ring_size);
 	if (delta > lp->tx_ring_size) {
-		if (netif_msg_drv(lp))
-			printk(KERN_ERR
-			       "%s: out-of-sync dirty pointer, %d vs. %d, full=%d.\n",
-			       dev->name, dirty_tx, lp->cur_tx,
-			       lp->tx_full);
+		netif_err(lp, drv, dev, "out-of-sync dirty pointer, %d vs. %d, full=%d\n",
+			  dirty_tx, lp->cur_tx, lp->tx_full);
 		dirty_tx += lp->tx_ring_size;
 		delta -= lp->tx_ring_size;
 	}
@@ -1535,8 +1494,7 @@ pcnet32_probe_pci(struct pci_dev *pdev, const struct pci_device_id *ent)
 	err = pci_enable_device(pdev);
 	if (err < 0) {
 		if (pcnet32_debug & NETIF_MSG_PROBE)
-			printk(KERN_ERR PFX
-			       "failed to enable device -- err=%d\n", err);
+			pr_err("failed to enable device -- err=%d\n", err);
 		return err;
 	}
 	pci_set_master(pdev);
@@ -1544,22 +1502,19 @@ pcnet32_probe_pci(struct pci_dev *pdev, const struct pci_device_id *ent)
 	ioaddr = pci_resource_start(pdev, 0);
 	if (!ioaddr) {
 		if (pcnet32_debug & NETIF_MSG_PROBE)
-			printk(KERN_ERR PFX
-			       "card has no PCI IO resources, aborting\n");
+			pr_err("card has no PCI IO resources, aborting\n");
 		return -ENODEV;
 	}
 
 	if (!pci_dma_supported(pdev, PCNET32_DMA_MASK)) {
 		if (pcnet32_debug & NETIF_MSG_PROBE)
-			printk(KERN_ERR PFX
-			       "architecture does not support 32bit PCI busmaster DMA\n");
+			pr_err("architecture does not support 32bit PCI busmaster DMA\n");
 		return -ENODEV;
 	}
 	if (request_region(ioaddr, PCNET32_TOTAL_SIZE, "pcnet32_probe_pci") ==
 	    NULL) {
 		if (pcnet32_debug & NETIF_MSG_PROBE)
-			printk(KERN_ERR PFX
-			       "io address range already allocated\n");
+			pr_err("io address range already allocated\n");
 		return -EBUSY;
 	}
 
@@ -1616,7 +1571,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 			a = &pcnet32_dwio;
 		} else {
 			if (pcnet32_debug & NETIF_MSG_PROBE)
-				printk(KERN_ERR PFX "No access methods\n");
+				pr_err("No access methods\n");
 			goto err_release_region;
 		}
 	}
@@ -1624,11 +1579,10 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	chip_version =
 	    a->read_csr(ioaddr, 88) | (a->read_csr(ioaddr, 89) << 16);
 	if ((pcnet32_debug & NETIF_MSG_PROBE) && (pcnet32_debug & NETIF_MSG_HW))
-		printk(KERN_INFO "  PCnet chip version is %#x.\n",
-		       chip_version);
+		pr_info("  PCnet chip version is %#x\n", chip_version);
 	if ((chip_version & 0xfff) != 0x003) {
 		if (pcnet32_debug & NETIF_MSG_PROBE)
-			printk(KERN_INFO PFX "Unsupported chip version.\n");
+			pr_info("Unsupported chip version\n");
 		goto err_release_region;
 	}
 
@@ -1681,7 +1635,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 		if (cards_found < MAX_UNITS && homepna[cards_found])
 			media |= 1;	/* switch to home wiring mode */
 		if (pcnet32_debug & NETIF_MSG_PROBE)
-			printk(KERN_DEBUG PFX "media set to %sMbit mode.\n",
+			printk(KERN_DEBUG PFX "media set to %sMbit mode\n",
 			       (media & 1) ? "1" : "10");
 		a->write_bcr(ioaddr, 49, media);
 		break;
@@ -1697,9 +1651,8 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 		break;
 	default:
 		if (pcnet32_debug & NETIF_MSG_PROBE)
-			printk(KERN_INFO PFX
-			       "PCnet version %#x, no PCnet32 chip.\n",
-			       chip_version);
+			pr_info("PCnet version %#x, no PCnet32 chip\n",
+				chip_version);
 		goto err_release_region;
 	}
 
@@ -1721,7 +1674,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	dev = alloc_etherdev(sizeof(*lp));
 	if (!dev) {
 		if (pcnet32_debug & NETIF_MSG_PROBE)
-			printk(KERN_ERR PFX "Memory allocation failed.\n");
+			pr_err("Memory allocation failed\n");
 		ret = -ENOMEM;
 		goto err_release_region;
 	}
@@ -1730,7 +1683,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 		SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (pcnet32_debug & NETIF_MSG_PROBE)
-		printk(KERN_INFO PFX "%s at %#3lx,", chipname, ioaddr);
+		pr_info("%s at %#3lx,", chipname, ioaddr);
 
 	/* In most chips, after a chip reset, the ethernet address is read from the
 	 * station address PROM at the base address and programmed into the
@@ -1755,9 +1708,8 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	    !is_valid_ether_addr(dev->dev_addr)) {
 		if (is_valid_ether_addr(promaddr)) {
 			if (pcnet32_debug & NETIF_MSG_PROBE) {
-				printk(" warning: CSR address invalid,\n");
-				printk(KERN_INFO
-				       "    using instead PROM address of");
+				pr_cont(" warning: CSR address invalid,\n");
+				pr_info("    using instead PROM address of");
 			}
 			memcpy(dev->dev_addr, promaddr, 6);
 		}
@@ -1769,43 +1721,43 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 		memset(dev->dev_addr, 0, ETH_ALEN);
 
 	if (pcnet32_debug & NETIF_MSG_PROBE) {
-		printk(" %pM", dev->dev_addr);
+		pr_cont(" %pM", dev->dev_addr);
 
 		/* Version 0x2623 and 0x2624 */
 		if (((chip_version + 1) & 0xfffe) == 0x2624) {
 			i = a->read_csr(ioaddr, 80) & 0x0C00;	/* Check tx_start_pt */
-			printk(KERN_INFO "    tx_start_pt(0x%04x):", i);
+			pr_info("    tx_start_pt(0x%04x):", i);
 			switch (i >> 10) {
 			case 0:
-				printk(KERN_CONT "  20 bytes,");
+				pr_cont("  20 bytes,");
 				break;
 			case 1:
-				printk(KERN_CONT "  64 bytes,");
+				pr_cont("  64 bytes,");
 				break;
 			case 2:
-				printk(KERN_CONT " 128 bytes,");
+				pr_cont(" 128 bytes,");
 				break;
 			case 3:
-				printk(KERN_CONT "~220 bytes,");
+				pr_cont("~220 bytes,");
 				break;
 			}
 			i = a->read_bcr(ioaddr, 18);	/* Check Burst/Bus control */
-			printk(KERN_CONT " BCR18(%x):", i & 0xffff);
+			pr_cont(" BCR18(%x):", i & 0xffff);
 			if (i & (1 << 5))
-				printk(KERN_CONT "BurstWrEn ");
+				pr_cont("BurstWrEn ");
 			if (i & (1 << 6))
-				printk(KERN_CONT "BurstRdEn ");
+				pr_cont("BurstRdEn ");
 			if (i & (1 << 7))
-				printk(KERN_CONT "DWordIO ");
+				pr_cont("DWordIO ");
 			if (i & (1 << 11))
-				printk(KERN_CONT "NoUFlow ");
+				pr_cont("NoUFlow ");
 			i = a->read_bcr(ioaddr, 25);
-			printk(KERN_INFO "    SRAMSIZE=0x%04x,", i << 8);
+			pr_info("    SRAMSIZE=0x%04x,", i << 8);
 			i = a->read_bcr(ioaddr, 26);
-			printk(KERN_CONT " SRAM_BND=0x%04x,", i << 8);
+			pr_cont(" SRAM_BND=0x%04x,", i << 8);
 			i = a->read_bcr(ioaddr, 27);
 			if (i & (1 << 14))
-				printk(KERN_CONT "LowLatRx");
+				pr_cont("LowLatRx");
 		}
 	}
 
@@ -1815,8 +1767,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	if ((lp->init_block =
 	     pci_alloc_consistent(pdev, sizeof(*lp->init_block), &lp->init_dma_addr)) == NULL) {
 		if (pcnet32_debug & NETIF_MSG_PROBE)
-			printk(KERN_ERR PFX
-			       "Consistent memory allocation failed.\n");
+			pr_err("Consistent memory allocation failed\n");
 		ret = -ENOMEM;
 		goto err_free_netdev;
 	}
@@ -1890,7 +1841,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	if (pdev) {		/* use the IRQ provided by PCI */
 		dev->irq = pdev->irq;
 		if (pcnet32_debug & NETIF_MSG_PROBE)
-			printk(" assigned IRQ %d.\n", dev->irq);
+			pr_cont(" assigned IRQ %d\n", dev->irq);
 	} else {
 		unsigned long irq_mask = probe_irq_on();
 
@@ -1906,12 +1857,12 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 		dev->irq = probe_irq_off(irq_mask);
 		if (!dev->irq) {
 			if (pcnet32_debug & NETIF_MSG_PROBE)
-				printk(", failed to detect IRQ line.\n");
+				pr_cont(", failed to detect IRQ line\n");
 			ret = -ENODEV;
 			goto err_free_ring;
 		}
 		if (pcnet32_debug & NETIF_MSG_PROBE)
-			printk(", probed IRQ %d.\n", dev->irq);
+			pr_cont(", probed IRQ %d\n", dev->irq);
 	}
 
 	/* Set the mii phy_id so that we can query the link state */
@@ -1935,9 +1886,8 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 			lp->phymask |= (1 << i);
 			lp->mii_if.phy_id = i;
 			if (pcnet32_debug & NETIF_MSG_PROBE)
-				printk(KERN_INFO PFX
-				       "Found PHY %04x:%04x at address %d.\n",
-				       id1, id2, i);
+				pr_info("Found PHY %04x:%04x at address %d\n",
+					id1, id2, i);
 		}
 		lp->a.write_bcr(ioaddr, 33, (lp->mii_if.phy_id) << 5);
 		if (lp->phycount > 1) {
@@ -1966,7 +1916,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	}
 
 	if (pcnet32_debug & NETIF_MSG_PROBE)
-		printk(KERN_INFO "%s: registered as %s\n", dev->name, lp->name);
+		pr_info("%s: registered as %s\n", dev->name, lp->name);
 	cards_found++;
 
 	/* enable LED writes */
@@ -1995,10 +1945,7 @@ static int pcnet32_alloc_ring(struct net_device *dev, const char *name)
 					   lp->tx_ring_size,
 					   &lp->tx_ring_dma_addr);
 	if (lp->tx_ring == NULL) {
-		if (netif_msg_drv(lp))
-			printk(KERN_ERR PFX
-			       "%s: Consistent memory allocation failed.\n",
-			       name);
+		netif_err(lp, drv, dev, "Consistent memory allocation failed\n");
 		return -ENOMEM;
 	}
 
@@ -2007,46 +1954,35 @@ static int pcnet32_alloc_ring(struct net_device *dev, const char *name)
 					   lp->rx_ring_size,
 					   &lp->rx_ring_dma_addr);
 	if (lp->rx_ring == NULL) {
-		if (netif_msg_drv(lp))
-			printk(KERN_ERR PFX
-			       "%s: Consistent memory allocation failed.\n",
-			       name);
+		netif_err(lp, drv, dev, "Consistent memory allocation failed\n");
 		return -ENOMEM;
 	}
 
 	lp->tx_dma_addr = kcalloc(lp->tx_ring_size, sizeof(dma_addr_t),
 				  GFP_ATOMIC);
 	if (!lp->tx_dma_addr) {
-		if (netif_msg_drv(lp))
-			printk(KERN_ERR PFX
-			       "%s: Memory allocation failed.\n", name);
+		netif_err(lp, drv, dev, "Memory allocation failed\n");
 		return -ENOMEM;
 	}
 
 	lp->rx_dma_addr = kcalloc(lp->rx_ring_size, sizeof(dma_addr_t),
 				  GFP_ATOMIC);
 	if (!lp->rx_dma_addr) {
-		if (netif_msg_drv(lp))
-			printk(KERN_ERR PFX
-			       "%s: Memory allocation failed.\n", name);
+		netif_err(lp, drv, dev, "Memory allocation failed\n");
 		return -ENOMEM;
 	}
 
 	lp->tx_skbuff = kcalloc(lp->tx_ring_size, sizeof(struct sk_buff *),
 				GFP_ATOMIC);
 	if (!lp->tx_skbuff) {
-		if (netif_msg_drv(lp))
-			printk(KERN_ERR PFX
-			       "%s: Memory allocation failed.\n", name);
+		netif_err(lp, drv, dev, "Memory allocation failed\n");
 		return -ENOMEM;
 	}
 
 	lp->rx_skbuff = kcalloc(lp->rx_ring_size, sizeof(struct sk_buff *),
 				GFP_ATOMIC);
 	if (!lp->rx_skbuff) {
-		if (netif_msg_drv(lp))
-			printk(KERN_ERR PFX
-			       "%s: Memory allocation failed.\n", name);
+		netif_err(lp, drv, dev, "Memory allocation failed\n");
 		return -ENOMEM;
 	}
 
@@ -2115,12 +2051,11 @@ static int pcnet32_open(struct net_device *dev)
 	/* switch pcnet32 to 32bit mode */
 	lp->a.write_bcr(ioaddr, 20, 2);
 
-	if (netif_msg_ifup(lp))
-		printk(KERN_DEBUG
-		       "%s: pcnet32_open() irq %d tx/rx rings %#x/%#x init %#x.\n",
-		       dev->name, dev->irq, (u32) (lp->tx_ring_dma_addr),
-		       (u32) (lp->rx_ring_dma_addr),
-		       (u32) (lp->init_dma_addr));
+	netif_printk(lp, ifup, KERN_DEBUG, dev,
+		     "%s() irq %d tx/rx rings %#x/%#x init %#x\n",
+		     __func__, dev->irq, (u32) (lp->tx_ring_dma_addr),
+		     (u32) (lp->rx_ring_dma_addr),
+		     (u32) (lp->init_dma_addr));
 
 	/* set/reset autoselect bit */
 	val = lp->a.read_bcr(ioaddr, 2) & ~2;
@@ -2155,10 +2090,8 @@ static int pcnet32_open(struct net_device *dev)
 	     pdev->subsystem_device == PCI_SUBDEVICE_ID_AT_2701FX)) {
 		if (lp->options & PCNET32_PORT_ASEL) {
 			lp->options = PCNET32_PORT_FD | PCNET32_PORT_100;
-			if (netif_msg_link(lp))
-				printk(KERN_DEBUG
-				       "%s: Setting 100Mb-Full Duplex.\n",
-				       dev->name);
+			netif_printk(lp, link, KERN_DEBUG, dev,
+				     "Setting 100Mb-Full Duplex\n");
 		}
 	}
 	if (lp->phycount < 2) {
@@ -2246,9 +2179,7 @@ static int pcnet32_open(struct net_device *dev)
 			}
 		}
 		lp->mii_if.phy_id = first_phy;
-		if (netif_msg_link(lp))
-			printk(KERN_INFO "%s: Using PHY number %d.\n",
-			       dev->name, first_phy);
+		netif_info(lp, link, dev, "Using PHY number %d\n", first_phy);
 	}
 
 #ifdef DO_DXSUFLO
@@ -2295,12 +2226,11 @@ static int pcnet32_open(struct net_device *dev)
 	 */
 	lp->a.write_csr(ioaddr, CSR0, CSR0_NORMAL);
 
-	if (netif_msg_ifup(lp))
-		printk(KERN_DEBUG
-		       "%s: pcnet32 open after %d ticks, init block %#x csr0 %4.4x.\n",
-		       dev->name, i,
-		       (u32) (lp->init_dma_addr),
-		       lp->a.read_csr(ioaddr, CSR0));
+	netif_printk(lp, ifup, KERN_DEBUG, dev,
+		     "pcnet32 open after %d ticks, init block %#x csr0 %4.4x\n",
+		     i,
+		     (u32) (lp->init_dma_addr),
+		     lp->a.read_csr(ioaddr, CSR0));
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 
@@ -2371,10 +2301,8 @@ static int pcnet32_init_ring(struct net_device *dev)
 			    (rx_skbuff = lp->rx_skbuff[i] =
 			     dev_alloc_skb(PKT_BUF_SKB))) {
 				/* there is not much, we can do at this point */
-				if (netif_msg_drv(lp))
-					printk(KERN_ERR
-					       "%s: pcnet32_init_ring dev_alloc_skb failed.\n",
-					       dev->name);
+				netif_err(lp, drv, dev, "%s dev_alloc_skb failed\n",
+					  __func__);
 				return -1;
 			}
 			skb_reserve(rx_skbuff, NET_IP_ALIGN);
@@ -2424,10 +2352,9 @@ static void pcnet32_restart(struct net_device *dev, unsigned int csr0_bits)
 		if (lp->a.read_csr(ioaddr, CSR0) & CSR0_STOP)
 			break;
 
-	if (i >= 100 && netif_msg_drv(lp))
-		printk(KERN_ERR
-		       "%s: pcnet32_restart timed out waiting for stop.\n",
-		       dev->name);
+	if (i >= 100)
+		netif_err(lp, drv, dev, "%s timed out waiting for stop\n",
+			  __func__);
 
 	pcnet32_purge_tx_ring(dev);
 	if (pcnet32_init_ring(dev))
@@ -2451,8 +2378,7 @@ static void pcnet32_tx_timeout(struct net_device *dev)
 	spin_lock_irqsave(&lp->lock, flags);
 	/* Transmitter timeout, serious problems. */
 	if (pcnet32_debug & NETIF_MSG_DRV)
-		printk(KERN_ERR
-		       "%s: transmit timed out, status %4.4x, resetting.\n",
+		pr_err("%s: transmit timed out, status %4.4x, resetting\n",
 		       dev->name, lp->a.read_csr(ioaddr, CSR0));
 	lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);
 	dev->stats.tx_errors++;
@@ -2495,11 +2421,9 @@ static netdev_tx_t pcnet32_start_xmit(struct sk_buff *skb,
 
 	spin_lock_irqsave(&lp->lock, flags);
 
-	if (netif_msg_tx_queued(lp)) {
-		printk(KERN_DEBUG
-		       "%s: pcnet32_start_xmit() called, csr0 %4.4x.\n",
-		       dev->name, lp->a.read_csr(ioaddr, CSR0));
-	}
+	netif_printk(lp, tx_queued, KERN_DEBUG, dev,
+		     "%s() called, csr0 %4.4x\n",
+		     __func__, lp->a.read_csr(ioaddr, CSR0));
 
 	/* Default status -- will not enable Successful-TxDone
 	 * interrupt when that option is available to us.
@@ -2564,10 +2488,9 @@ pcnet32_interrupt(int irq, void *dev_id)
 		/* Acknowledge all of the current interrupt sources ASAP. */
 		lp->a.write_csr(ioaddr, CSR0, csr0 & ~0x004f);
 
-		if (netif_msg_intr(lp))
-			printk(KERN_DEBUG
-			       "%s: interrupt  csr0=%#2.2x new csr=%#2.2x.\n",
-			       dev->name, csr0, lp->a.read_csr(ioaddr, CSR0));
+		netif_printk(lp, intr, KERN_DEBUG, dev,
+			     "interrupt  csr0=%#2.2x new csr=%#2.2x\n",
+			     csr0, lp->a.read_csr(ioaddr, CSR0));
 
 		/* Log misc errors. */
 		if (csr0 & 0x4000)
@@ -2587,10 +2510,8 @@ pcnet32_interrupt(int irq, void *dev_id)
 			dev->stats.rx_errors++;	/* Missed a Rx frame. */
 		}
 		if (csr0 & 0x0800) {
-			if (netif_msg_drv(lp))
-				printk(KERN_ERR
-				       "%s: Bus master arbitration failure, status %4.4x.\n",
-				       dev->name, csr0);
+			netif_err(lp, drv, dev, "Bus master arbitration failure, status %4.4x\n",
+				  csr0);
 			/* unlike for the lance, there is no restart needed */
 		}
 		if (napi_schedule_prep(&lp->napi)) {
@@ -2606,9 +2527,9 @@ pcnet32_interrupt(int irq, void *dev_id)
 		csr0 = lp->a.read_csr(ioaddr, CSR0);
 	}
 
-	if (netif_msg_intr(lp))
-		printk(KERN_DEBUG "%s: exiting interrupt, csr0=%#4.4x.\n",
-		       dev->name, lp->a.read_csr(ioaddr, CSR0));
+	netif_printk(lp, intr, KERN_DEBUG, dev,
+		     "exiting interrupt, csr0=%#4.4x\n",
+		     lp->a.read_csr(ioaddr, CSR0));
 
 	spin_unlock(&lp->lock);
 
@@ -2630,10 +2551,9 @@ static int pcnet32_close(struct net_device *dev)
 
 	dev->stats.rx_missed_errors = lp->a.read_csr(ioaddr, 112);
 
-	if (netif_msg_ifdown(lp))
-		printk(KERN_DEBUG
-		       "%s: Shutting down ethercard, status was %2.2x.\n",
-		       dev->name, lp->a.read_csr(ioaddr, CSR0));
+	netif_printk(lp, ifdown, KERN_DEBUG, dev,
+		     "Shutting down ethercard, status was %2.2x\n",
+		     lp->a.read_csr(ioaddr, CSR0));
 
 	/* We stop the PCNET32 here -- it occasionally polls memory if we don't. */
 	lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);
@@ -2730,9 +2650,7 @@ static void pcnet32_set_multicast_list(struct net_device *dev)
 	csr15 = lp->a.read_csr(ioaddr, CSR15);
 	if (dev->flags & IFF_PROMISC) {
 		/* Log any net taps. */
-		if (netif_msg_hw(lp))
-			printk(KERN_INFO "%s: Promiscuous mode enabled.\n",
-			       dev->name);
+		netif_info(lp, hw, dev, "Promiscuous mode enabled\n");
 		lp->init_block->mode =
 		    cpu_to_le16(0x8000 | (lp->options & PCNET32_PORT_PORTSEL) <<
 				7);
@@ -2819,10 +2737,8 @@ static int pcnet32_check_otherphy(struct net_device *dev)
 			mii.phy_id = i;
 			if (mii_link_ok(&mii)) {
 				/* found PHY with active link */
-				if (netif_msg_link(lp))
-					printk(KERN_INFO
-					       "%s: Using PHY number %d.\n",
-					       dev->name, i);
+				netif_info(lp, link, dev, "Using PHY number %d\n",
+					   i);
 
 				/* isolate inactive phy */
 				bmcr =
@@ -2868,8 +2784,7 @@ static void pcnet32_check_media(struct net_device *dev, int verbose)
 	if (!curr_link) {
 		if (prev_link || verbose) {
 			netif_carrier_off(dev);
-			if (netif_msg_link(lp))
-				printk(KERN_INFO "%s: link down\n", dev->name);
+			netif_info(lp, link, dev, "link down\n");
 		}
 		if (lp->phycount > 1) {
 			curr_link = pcnet32_check_otherphy(dev);
@@ -2881,12 +2796,11 @@ static void pcnet32_check_media(struct net_device *dev, int verbose)
 			if (netif_msg_link(lp)) {
 				struct ethtool_cmd ecmd;
 				mii_ethtool_gset(&lp->mii_if, &ecmd);
-				printk(KERN_INFO
-				       "%s: link up, %sMbps, %s-duplex\n",
-				       dev->name,
-				       (ecmd.speed == SPEED_100) ? "100" : "10",
-				       (ecmd.duplex ==
-					DUPLEX_FULL) ? "full" : "half");
+				netdev_info(dev, "link up, %sMbps, %s-duplex\n",
+					    (ecmd.speed == SPEED_100)
+					    ? "100" : "10",
+					    (ecmd.duplex == DUPLEX_FULL)
+					    ? "full" : "half");
 			}
 			bcr9 = lp->a.read_bcr(dev->base_addr, 9);
 			if ((bcr9 & (1 << 0)) != lp->mii_if.full_duplex) {
@@ -2897,8 +2811,7 @@ static void pcnet32_check_media(struct net_device *dev, int verbose)
 				lp->a.write_bcr(dev->base_addr, 9, bcr9);
 			}
 		} else {
-			if (netif_msg_link(lp))
-				printk(KERN_INFO "%s: link up\n", dev->name);
+			netif_info(lp, link, dev, "link up\n");
 		}
 	}
 }
@@ -3010,7 +2923,7 @@ MODULE_LICENSE("GPL");
 
 static int __init pcnet32_init_module(void)
 {
-	printk(KERN_INFO "%s", version);
+	pr_info("%s", version);
 
 	pcnet32_debug = netif_msg_init(debug, PCNET32_MSG_DEFAULT);
 
@@ -3026,7 +2939,7 @@ static int __init pcnet32_init_module(void)
 		pcnet32_probe_vlbus(pcnet32_portlist);
 
 	if (cards_found && (pcnet32_debug & NETIF_MSG_PROBE))
-		printk(KERN_INFO PFX "%d cards_found.\n", cards_found);
+		pr_info("%d cards_found\n", cards_found);
 
 	return (pcnet32_have_pci + cards_found) ? 0 : -ENODEV;
 }
-- 
1.7.0.14.g7e948

