From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] ipg: Use current logging styles
Date: Fri, 29 Jul 2011 19:38:14 -0700
Message-ID: <2ee87bfccbbb5cf1776df6751b65e4a3110019f4.1311993468.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>,
	Sorbica Shieh <sorbica@icplus.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4377 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753345Ab1G3CiS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2011 22:38:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add and use pr_fmt, pr_<level> and netdev_<level>.
Convert printks with %[n].[n]x to %nx to be shorter
and clearer.
Consolidate printks to use a single printk rather
than continued printks without KERN_CONT.
Removed unnecessary trailing periods.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ipg.c |  191 ++++++++++++++++++++++++++---------------------------
 1 files changed, 95 insertions(+), 96 deletions(-)

diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index d4aa40a..3aefaad 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -20,6 +20,9 @@
  *   http://www.icplus.com.tw
  *   jesse@icplus.com.tw
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/crc32.h>
 #include <linux/ethtool.h>
 #include <linux/interrupt.h>
@@ -118,23 +121,23 @@ static void ipg_dump_rfdlist(struct net_device *dev)
 
 	IPG_DEBUG_MSG("_dump_rfdlist\n");
 
-	printk(KERN_INFO "rx_current = %2.2x\n", sp->rx_current);
-	printk(KERN_INFO "rx_dirty   = %2.2x\n", sp->rx_dirty);
-	printk(KERN_INFO "RFDList start address = %16.16lx\n",
-	       (unsigned long) sp->rxd_map);
-	printk(KERN_INFO "RFDListPtr register   = %8.8x%8.8x\n",
-	       ipg_r32(IPG_RFDLISTPTR1), ipg_r32(IPG_RFDLISTPTR0));
+	netdev_info(dev, "rx_current = %02x\n", sp->rx_current);
+	netdev_info(dev, "rx_dirty   = %02x\n", sp->rx_dirty);
+	netdev_info(dev, "RFDList start address = %016lx\n",
+		    (unsigned long)sp->rxd_map);
+	netdev_info(dev, "RFDListPtr register   = %08x%08x\n",
+		    ipg_r32(IPG_RFDLISTPTR1), ipg_r32(IPG_RFDLISTPTR0));
 
 	for (i = 0; i < IPG_RFDLIST_LENGTH; i++) {
 		offset = (u32) &sp->rxd[i].next_desc - (u32) sp->rxd;
-		printk(KERN_INFO "%2.2x %4.4x RFDNextPtr = %16.16lx\n", i,
-		       offset, (unsigned long) sp->rxd[i].next_desc);
+		netdev_info(dev, "%02x %04x RFDNextPtr = %016lx\n",
+			    i, offset, (unsigned long)sp->rxd[i].next_desc);
 		offset = (u32) &sp->rxd[i].rfs - (u32) sp->rxd;
-		printk(KERN_INFO "%2.2x %4.4x RFS        = %16.16lx\n", i,
-		       offset, (unsigned long) sp->rxd[i].rfs);
+		netdev_info(dev, "%02x %04x RFS        = %016lx\n",
+			    i, offset, (unsigned long)sp->rxd[i].rfs);
 		offset = (u32) &sp->rxd[i].frag_info - (u32) sp->rxd;
-		printk(KERN_INFO "%2.2x %4.4x frag_info   = %16.16lx\n", i,
-		       offset, (unsigned long) sp->rxd[i].frag_info);
+		netdev_info(dev, "%02x %04x frag_info   = %016lx\n",
+			    i, offset, (unsigned long)sp->rxd[i].frag_info);
 	}
 }
 
@@ -147,24 +150,24 @@ static void ipg_dump_tfdlist(struct net_device *dev)
 
 	IPG_DEBUG_MSG("_dump_tfdlist\n");
 
-	printk(KERN_INFO "tx_current         = %2.2x\n", sp->tx_current);
-	printk(KERN_INFO "tx_dirty = %2.2x\n", sp->tx_dirty);
-	printk(KERN_INFO "TFDList start address = %16.16lx\n",
-	       (unsigned long) sp->txd_map);
-	printk(KERN_INFO "TFDListPtr register   = %8.8x%8.8x\n",
-	       ipg_r32(IPG_TFDLISTPTR1), ipg_r32(IPG_TFDLISTPTR0));
+	netdev_info(dev, "tx_current         = %02x\n", sp->tx_current);
+	netdev_info(dev, "tx_dirty = %02x\n", sp->tx_dirty);
+	netdev_info(dev, "TFDList start address = %016lx\n",
+		    (unsigned long) sp->txd_map);
+	netdev_info(dev, "TFDListPtr register   = %08x%08x\n",
+		    ipg_r32(IPG_TFDLISTPTR1), ipg_r32(IPG_TFDLISTPTR0));
 
 	for (i = 0; i < IPG_TFDLIST_LENGTH; i++) {
 		offset = (u32) &sp->txd[i].next_desc - (u32) sp->txd;
-		printk(KERN_INFO "%2.2x %4.4x TFDNextPtr = %16.16lx\n", i,
-		       offset, (unsigned long) sp->txd[i].next_desc);
+		netdev_info(dev, "%02x %04x TFDNextPtr = %016lx\n",
+			    i, offset, (unsigned long)sp->txd[i].next_desc);
 
 		offset = (u32) &sp->txd[i].tfc - (u32) sp->txd;
-		printk(KERN_INFO "%2.2x %4.4x TFC        = %16.16lx\n", i,
-		       offset, (unsigned long) sp->txd[i].tfc);
+		netdev_info(dev, "%02x %04x TFC        = %016lx\n",
+			    i, offset, (unsigned long) sp->txd[i].tfc);
 		offset = (u32) &sp->txd[i].frag_info - (u32) sp->txd;
-		printk(KERN_INFO "%2.2x %4.4x frag_info   = %16.16lx\n", i,
-		       offset, (unsigned long) sp->txd[i].frag_info);
+		netdev_info(dev, "%02x %04x frag_info   = %016lx\n",
+			    i, offset, (unsigned long) sp->txd[i].frag_info);
 	}
 }
 #endif
@@ -480,6 +483,10 @@ static int ipg_config_autoneg(struct net_device *dev)
 	u32 mac_ctrl_val;
 	u32 asicctrl;
 	u8 phyctrl;
+	const char *speed;
+	const char *duplex;
+	const char *tx_desc;
+	const char *rx_desc;
 
 	IPG_DEBUG_MSG("_config_autoneg\n");
 
@@ -499,27 +506,27 @@ static int ipg_config_autoneg(struct net_device *dev)
 	 */
 	sp->tenmbpsmode = 0;
 
-	printk(KERN_INFO "%s: Link speed = ", dev->name);
-
 	/* Determine actual speed of operation. */
 	switch (phyctrl & IPG_PC_LINK_SPEED) {
 	case IPG_PC_LINK_SPEED_10MBPS:
-		printk("10Mbps.\n");
-		printk(KERN_INFO "%s: 10Mbps operational mode enabled.\n",
-		       dev->name);
+		speed = "10Mbps";
 		sp->tenmbpsmode = 1;
 		break;
 	case IPG_PC_LINK_SPEED_100MBPS:
-		printk("100Mbps.\n");
+		speed = "100Mbps";
 		break;
 	case IPG_PC_LINK_SPEED_1000MBPS:
-		printk("1000Mbps.\n");
+		speed = "1000Mbps";
 		break;
 	default:
-		printk("undefined!\n");
+		speed = "undefined!";
 		return 0;
 	}
 
+	netdev_info(dev, "Link speed = %s\n", speed);
+	if (sp->tenmbpsmode == 1)
+		netdev_info(dev, "10Mbps operational mode enabled\n");
+
 	if (phyctrl & IPG_PC_DUPLEX_STATUS) {
 		fullduplex = 1;
 		txflowcontrol = 1;
@@ -528,38 +535,41 @@ static int ipg_config_autoneg(struct net_device *dev)
 
 	/* Configure full duplex, and flow control. */
 	if (fullduplex == 1) {
+
 		/* Configure IPG for full duplex operation. */
-		printk(KERN_INFO "%s: setting full duplex, ", dev->name);
+
+		duplex = "full";
 
 		mac_ctrl_val |= IPG_MC_DUPLEX_SELECT_FD;
 
 		if (txflowcontrol == 1) {
-			printk("TX flow control");
+			tx_desc  = "";
 			mac_ctrl_val |= IPG_MC_TX_FLOW_CONTROL_ENABLE;
 		} else {
-			printk("no TX flow control");
+			tx_desc = "no ";
 			mac_ctrl_val &= ~IPG_MC_TX_FLOW_CONTROL_ENABLE;
 		}
 
 		if (rxflowcontrol == 1) {
-			printk(", RX flow control.");
+			rx_desc = "";
 			mac_ctrl_val |= IPG_MC_RX_FLOW_CONTROL_ENABLE;
 		} else {
-			printk(", no RX flow control.");
+			rx_desc = "no ";
 			mac_ctrl_val &= ~IPG_MC_RX_FLOW_CONTROL_ENABLE;
 		}
-
-		printk("\n");
 	} else {
-		/* Configure IPG for half duplex operation. */
-		printk(KERN_INFO "%s: setting half duplex, "
-		       "no TX flow control, no RX flow control.\n", dev->name);
-
-		mac_ctrl_val &= ~IPG_MC_DUPLEX_SELECT_FD &
-			~IPG_MC_TX_FLOW_CONTROL_ENABLE &
-			~IPG_MC_RX_FLOW_CONTROL_ENABLE;
+		duplex = "half";
+		tx_desc = "no ";
+		rx_desc = "no ";
+		mac_ctrl_val &= (~IPG_MC_DUPLEX_SELECT_FD &
+				 ~IPG_MC_TX_FLOW_CONTROL_ENABLE &
+				 ~IPG_MC_RX_FLOW_CONTROL_ENABLE);
 	}
+
+	netdev_info(dev, "setting %s duplex, %sTX, %sRX flow control\n",
+		    duplex, tx_desc, rx_desc);
 	ipg_w32(mac_ctrl_val, MAC_CTRL);
+
 	return 0;
 }
 
@@ -784,14 +794,13 @@ static int init_rfdlist(struct net_device *dev)
 			 * A receive buffer was not ready, break the
 			 * RFD list here.
 			 */
-			IPG_DEBUG_MSG("Cannot allocate Rx buffer.\n");
+			IPG_DEBUG_MSG("Cannot allocate Rx buffer\n");
 
 			/* Just in case we cannot allocate a single RFD.
 			 * Should not occur.
 			 */
 			if (i == 0) {
-				printk(KERN_ERR "%s: No memory available"
-					" for RFD list.\n", dev->name);
+				netdev_err(dev, "No memory available for RFD list\n");
 				return -ENOMEM;
 			}
 		}
@@ -838,7 +847,7 @@ static void init_tfdlist(struct net_device *dev)
 	sp->tx_dirty = 0;
 
 	/* Write the location of the TFDList to the IPG. */
-	IPG_DDEBUG_MSG("Starting TFDListPtr = %8.8x\n",
+	IPG_DDEBUG_MSG("Starting TFDListPtr = %08x\n",
 		       (u32) sp->txd_map);
 	ipg_w32((u32) sp->txd_map, TFD_LIST_PTR_0);
 	ipg_w32(0x00000000, TFD_LIST_PTR_1);
@@ -864,7 +873,7 @@ static void ipg_nic_txfree(struct net_device *dev)
 		struct sk_buff *skb = sp->tx_buff[dirty];
 		struct ipg_tx *txfd = sp->txd + dirty;
 
-		IPG_DEBUG_MSG("TFC = %16.16lx\n", (unsigned long) txfd->tfc);
+		IPG_DEBUG_MSG("TFC = %016lx\n", (unsigned long) txfd->tfc);
 
 		/* Look at each TFD's TFC field beginning
 		 * at the last freed TFD up to the current TFD.
@@ -906,10 +915,8 @@ static void ipg_tx_timeout(struct net_device *dev)
 	spin_lock_irq(&sp->lock);
 
 	/* Re-configure after DMA reset. */
-	if (ipg_io_config(dev) < 0) {
-		printk(KERN_INFO "%s: Error during re-configuration.\n",
-		       dev->name);
-	}
+	if (ipg_io_config(dev) < 0)
+		netdev_info(dev, "Error during re-configuration\n");
 
 	init_tfdlist(dev);
 
@@ -938,7 +945,7 @@ static void ipg_nic_txcleanup(struct net_device *dev)
 		 */
 		u32 txstatusdword = ipg_r32(TX_STATUS);
 
-		IPG_DEBUG_MSG("TxStatus = %8.8x\n", txstatusdword);
+		IPG_DEBUG_MSG("TxStatus = %08x\n", txstatusdword);
 
 		/* Check for Transmit errors. Error bits only valid if
 		 * TX_COMPLETE bit in the TXSTATUS register is a 1.
@@ -953,20 +960,20 @@ static void ipg_nic_txcleanup(struct net_device *dev)
 
 		/* Transmit error, increment stat counters. */
 		if (txstatusdword & IPG_TS_TX_ERROR) {
-			IPG_DEBUG_MSG("Transmit error.\n");
+			IPG_DEBUG_MSG("Transmit error\n");
 			sp->stats.tx_errors++;
 		}
 
 		/* Late collision, re-enable transmitter. */
 		if (txstatusdword & IPG_TS_LATE_COLLISION) {
-			IPG_DEBUG_MSG("Late collision on transmit.\n");
+			IPG_DEBUG_MSG("Late collision on transmit\n");
 			ipg_w32((ipg_r32(MAC_CTRL) | IPG_MC_TX_ENABLE) &
 				IPG_MC_RSVD_MASK, MAC_CTRL);
 		}
 
 		/* Maximum collisions, re-enable transmitter. */
 		if (txstatusdword & IPG_TS_TX_MAX_COLL) {
-			IPG_DEBUG_MSG("Maximum collisions on transmit.\n");
+			IPG_DEBUG_MSG("Maximum collisions on transmit\n");
 			ipg_w32((ipg_r32(MAC_CTRL) | IPG_MC_TX_ENABLE) &
 				IPG_MC_RSVD_MASK, MAC_CTRL);
 		}
@@ -975,16 +982,14 @@ static void ipg_nic_txcleanup(struct net_device *dev)
 		 * transmitter.
 		 */
 		if (txstatusdword & IPG_TS_TX_UNDERRUN) {
-			IPG_DEBUG_MSG("Transmitter underrun.\n");
+			IPG_DEBUG_MSG("Transmitter underrun\n");
 			sp->stats.tx_fifo_errors++;
 			ipg_reset(dev, IPG_AC_TX_RESET | IPG_AC_DMA |
 				  IPG_AC_NETWORK | IPG_AC_FIFO);
 
 			/* Re-configure after DMA reset. */
 			if (ipg_io_config(dev) < 0) {
-				printk(KERN_INFO
-				       "%s: Error during re-configuration.\n",
-				       dev->name);
+				netdev_info(dev, "Error during re-configuration\n");
 			}
 			init_tfdlist(dev);
 
@@ -1063,7 +1068,7 @@ static int ipg_nic_rxrestore(struct net_device *dev)
 		 * Linux system).
 		 */
 		if (ipg_get_rxbuff(dev, entry) < 0) {
-			IPG_DEBUG_MSG("Cannot allocate new Rx buffer.\n");
+			IPG_DEBUG_MSG("Cannot allocate new Rx buffer\n");
 
 			break;
 		}
@@ -1134,7 +1139,7 @@ static int ipg_nic_rx_check_error(struct net_device *dev)
 	     (IPG_RFS_RXFIFOOVERRUN | IPG_RFS_RXRUNTFRAME |
 	      IPG_RFS_RXALIGNMENTERROR | IPG_RFS_RXFCSERROR |
 	      IPG_RFS_RXOVERSIZEDFRAME | IPG_RFS_RXLENGTHERROR))) {
-		IPG_DEBUG_MSG("Rx error, RFS = %16.16lx\n",
+		IPG_DEBUG_MSG("Rx error, RFS = %016lx\n",
 			      (unsigned long) rxfd->rfs);
 
 		/* Increment general receive error statistic. */
@@ -1142,13 +1147,13 @@ static int ipg_nic_rx_check_error(struct net_device *dev)
 
 		/* Increment detailed receive error statistics. */
 		if (le64_to_cpu(rxfd->rfs) & IPG_RFS_RXFIFOOVERRUN) {
-			IPG_DEBUG_MSG("RX FIFO overrun occurred.\n");
+			IPG_DEBUG_MSG("RX FIFO overrun occurred\n");
 
 			sp->stats.rx_fifo_errors++;
 		}
 
 		if (le64_to_cpu(rxfd->rfs) & IPG_RFS_RXRUNTFRAME) {
-			IPG_DEBUG_MSG("RX runt occurred.\n");
+			IPG_DEBUG_MSG("RX runt occurred\n");
 			sp->stats.rx_length_errors++;
 		}
 
@@ -1157,7 +1162,7 @@ static int ipg_nic_rx_check_error(struct net_device *dev)
 		 */
 
 		if (le64_to_cpu(rxfd->rfs) & IPG_RFS_RXALIGNMENTERROR) {
-			IPG_DEBUG_MSG("RX alignment error occurred.\n");
+			IPG_DEBUG_MSG("RX alignment error occurred\n");
 			sp->stats.rx_frame_errors++;
 		}
 
@@ -1404,7 +1409,7 @@ static int ipg_nic_rx(struct net_device *dev)
 		 */
 		if (framelen > sp->rxfrag_size) {
 			IPG_DEBUG_MSG
-			    ("RFS FrameLen > allocated fragment size.\n");
+			    ("RFS FrameLen > allocated fragment size\n");
 
 			framelen = sp->rxfrag_size;
 		}
@@ -1414,7 +1419,7 @@ static int ipg_nic_rx(struct net_device *dev)
 			IPG_RFS_RXALIGNMENTERROR | IPG_RFS_RXFCSERROR |
 			IPG_RFS_RXOVERSIZEDFRAME | IPG_RFS_RXLENGTHERROR)))) {
 
-			IPG_DEBUG_MSG("Rx error, RFS = %16.16lx\n",
+			IPG_DEBUG_MSG("Rx error, RFS = %016lx\n",
 				      (unsigned long int) rxfd->rfs);
 
 			/* Increment general receive error statistic. */
@@ -1422,12 +1427,12 @@ static int ipg_nic_rx(struct net_device *dev)
 
 			/* Increment detailed receive error statistics. */
 			if (le64_to_cpu(rxfd->rfs) & IPG_RFS_RXFIFOOVERRUN) {
-				IPG_DEBUG_MSG("RX FIFO overrun occurred.\n");
+				IPG_DEBUG_MSG("RX FIFO overrun occurred\n");
 				sp->stats.rx_fifo_errors++;
 			}
 
 			if (le64_to_cpu(rxfd->rfs) & IPG_RFS_RXRUNTFRAME) {
-				IPG_DEBUG_MSG("RX runt occurred.\n");
+				IPG_DEBUG_MSG("RX runt occurred\n");
 				sp->stats.rx_length_errors++;
 			}
 
@@ -1437,7 +1442,7 @@ static int ipg_nic_rx(struct net_device *dev)
 			 */
 
 			if (le64_to_cpu(rxfd->rfs) & IPG_RFS_RXALIGNMENTERROR) {
-				IPG_DEBUG_MSG("RX alignment error occurred.\n");
+				IPG_DEBUG_MSG("RX alignment error occurred\n");
 				sp->stats.rx_frame_errors++;
 			}
 
@@ -1508,7 +1513,7 @@ static int ipg_nic_rx(struct net_device *dev)
 
 		rxfd = sp->rxd + entry;
 
-		IPG_DEBUG_MSG("Frame requires multiple RFDs.\n");
+		IPG_DEBUG_MSG("Frame requires multiple RFDs\n");
 
 		/* An unexpected event, additional code needed to handle
 		 * properly. So for the time being, just disregard the
@@ -1557,8 +1562,7 @@ static void ipg_reset_after_host_error(struct work_struct *work)
 	init_tfdlist(dev);
 
 	if (ipg_io_config(dev) < 0) {
-		printk(KERN_INFO "%s: Cannot recover from PCI error.\n",
-		       dev->name);
+		netdev_info(dev, "Cannot recover from PCI error\n");
 		schedule_delayed_work(&sp->task, HZ);
 	}
 }
@@ -1586,7 +1590,7 @@ static irqreturn_t ipg_interrupt_handler(int irq, void *dev_inst)
 	 */
 	status = ipg_r16(INT_STATUS_ACK);
 
-	IPG_DEBUG_MSG("IntStatusAck = %4.4x\n", status);
+	IPG_DEBUG_MSG("IntStatusAck = %04x\n", status);
 
 	/* Shared IRQ of remove event. */
 	if (!(status & IPG_IS_RSVD_MASK))
@@ -1599,7 +1603,7 @@ static irqreturn_t ipg_interrupt_handler(int irq, void *dev_inst)
 
 	/* If RFDListEnd interrupt, restore all used RFDs. */
 	if (status & IPG_IS_RFD_LIST_END) {
-		IPG_DEBUG_MSG("RFDListEnd Interrupt.\n");
+		IPG_DEBUG_MSG("RFDListEnd Interrupt\n");
 
 		/* The RFD list end indicates an RFD was encountered
 		 * with a 0 NextPtr, or with an RFDDone bit set to 1
@@ -1661,21 +1665,20 @@ static irqreturn_t ipg_interrupt_handler(int irq, void *dev_inst)
 	/* If LinkEvent interrupt, resolve autonegotiation. */
 	if (status & IPG_IS_LINK_EVENT) {
 		if (ipg_config_autoneg(dev) < 0)
-			printk(KERN_INFO "%s: Auto-negotiation error.\n",
-			       dev->name);
+			netdev_info(dev, "Auto-negotiation error\n");
 	}
 
 	/* If MACCtrlFrame interrupt, do nothing. */
 	if (status & IPG_IS_MAC_CTRL_FRAME)
-		IPG_DEBUG_MSG("MACCtrlFrame interrupt.\n");
+		IPG_DEBUG_MSG("MACCtrlFrame interrupt\n");
 
 	/* If RxComplete interrupt, do nothing. */
 	if (status & IPG_IS_RX_COMPLETE)
-		IPG_DEBUG_MSG("RxComplete interrupt.\n");
+		IPG_DEBUG_MSG("RxComplete interrupt\n");
 
 	/* If RxEarly interrupt, do nothing. */
 	if (status & IPG_IS_RX_EARLY)
-		IPG_DEBUG_MSG("RxEarly interrupt.\n");
+		IPG_DEBUG_MSG("RxEarly interrupt\n");
 
 out_enable:
 	/* Re-enable IPG interrupts. */
@@ -1749,8 +1752,7 @@ static int ipg_nic_open(struct net_device *dev)
 	rc = request_irq(pdev->irq, ipg_interrupt_handler, IRQF_SHARED,
 			 dev->name, dev);
 	if (rc < 0) {
-		printk(KERN_INFO "%s: Error when requesting interrupt.\n",
-		       dev->name);
+		netdev_info(dev, "Error when requesting interrupt\n");
 		goto out;
 	}
 
@@ -1770,8 +1772,7 @@ static int ipg_nic_open(struct net_device *dev)
 
 	rc = init_rfdlist(dev);
 	if (rc < 0) {
-		printk(KERN_INFO "%s: Error during configuration.\n",
-		       dev->name);
+		netdev_info(dev, "Error during configuration\n");
 		goto err_free_tx_2;
 	}
 
@@ -1779,14 +1780,13 @@ static int ipg_nic_open(struct net_device *dev)
 
 	rc = ipg_io_config(dev);
 	if (rc < 0) {
-		printk(KERN_INFO "%s: Error during configuration.\n",
-		       dev->name);
+		netdev_info(dev, "Error during configuration\n");
 		goto err_release_tfdlist_3;
 	}
 
 	/* Resolve autonegotiation. */
 	if (ipg_config_autoneg(dev) < 0)
-		printk(KERN_INFO "%s: Auto-negotiation error.\n", dev->name);
+		netdev_info(dev, "Auto-negotiation error\n");
 
 	/* initialize JUMBO Frame control variable */
 	sp->jumbo.found_start = 0;
@@ -2222,7 +2222,7 @@ static int __devinit ipg_probe(struct pci_dev *pdev,
 	if (rc < 0)
 		goto out;
 
-	printk(KERN_INFO "%s: %s\n", pci_name(pdev), ipg_brand_name[i]);
+	pr_info("%s: %s\n", pci_name(pdev), ipg_brand_name[i]);
 
 	pci_set_master(pdev);
 
@@ -2230,8 +2230,7 @@ static int __devinit ipg_probe(struct pci_dev *pdev,
 	if (rc < 0) {
 		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc < 0) {
-			printk(KERN_ERR "%s: DMA config failed.\n",
-			       pci_name(pdev));
+			pr_err("%s: DMA config failed\n", pci_name(pdev));
 			goto err_disable_0;
 		}
 	}
@@ -2241,7 +2240,7 @@ static int __devinit ipg_probe(struct pci_dev *pdev,
 	 */
 	dev = alloc_etherdev(sizeof(struct ipg_nic_private));
 	if (!dev) {
-		printk(KERN_ERR "%s: alloc_etherdev failed\n", pci_name(pdev));
+		pr_err("%s: alloc_etherdev failed\n", pci_name(pdev));
 		rc = -ENOMEM;
 		goto err_disable_0;
 	}
@@ -2267,7 +2266,7 @@ static int __devinit ipg_probe(struct pci_dev *pdev,
 
 	ioaddr = pci_iomap(pdev, 1, pci_resource_len(pdev, 1));
 	if (!ioaddr) {
-		printk(KERN_ERR "%s cannot map MMIO\n", pci_name(pdev));
+		pr_err("%s: cannot map MMIO\n", pci_name(pdev));
 		rc = -EIO;
 		goto err_release_regions_2;
 	}
@@ -2289,7 +2288,7 @@ static int __devinit ipg_probe(struct pci_dev *pdev,
 	if (rc < 0)
 		goto err_unmap_3;
 
-	printk(KERN_INFO "Ethernet device registered as: %s\n", dev->name);
+	netdev_info(dev, "Ethernet device registered\n");
 out:
 	return rc;
 
-- 
1.7.6.131.g99019

