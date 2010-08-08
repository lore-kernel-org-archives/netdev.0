From: Wolfram Sang <w.sang@pengutronix.de>
Subject: [PATCH] pcnet_cs: Use proper netdev_*-printouts
Date: Sun,  8 Aug 2010 14:32:05 +0200
Message-ID: <1281270725-25282-1-git-send-email-w.sang@pengutronix.de>
Cc: linux-pcmcia@lists.infradead.org,
	Wolfram Sang <w.sang@pengutronix.de>,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	Joe Perches <joe@perches.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52924 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753612Ab0HHMdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Aug 2010 08:33:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To prevent broken messages like:

[  204.024291] eth%d: pcnet_reset_8390() did not complete.

Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>
Cc: Joe Perches <joe@perches.com>
Cc: David Miller <davem@davemloft.net>
---

There are 5 checkpatch-warnings regarding indentation. I did not fix them to
keep the style of the rest of the driver. The code looks correct to me.

 drivers/net/pcmcia/pcnet_cs.c |   58 +++++++++++++++++++----------------------
 1 files changed, 27 insertions(+), 31 deletions(-)

diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index bfdef72..e127923 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -646,12 +646,12 @@ static int pcnet_config(struct pcmcia_device *link)
 
     if (info->flags & (IS_DL10019|IS_DL10022)) {
 	u_char id = inb(dev->base_addr + 0x1a);
-	printk(KERN_INFO "%s: NE2000 (DL100%d rev %02x): ",
-	       dev->name, ((info->flags & IS_DL10022) ? 22 : 19), id);
+	netdev_info(dev, "NE2000 (DL100%d rev %02x): ",
+	       (info->flags & IS_DL10022) ? 22 : 19, id);
 	if (info->pna_phy)
 	    printk("PNA, ");
     } else {
-	printk(KERN_INFO "%s: NE2000 Compatible: ", dev->name);
+	netdev_info(dev, "NE2000 Compatible: ");
     }
     printk("io %#3lx, irq %d,", dev->base_addr, dev->irq);
     if (info->flags & USE_SHMEM)
@@ -932,7 +932,7 @@ static void mii_phy_probe(struct net_device *dev)
 	phyid = tmp << 16;
 	phyid |= mdio_read(mii_addr, i, MII_PHYID_REG2);
 	phyid &= MII_PHYID_REV_MASK;
-	pr_debug("%s: MII at %d is 0x%08x\n", dev->name, i, phyid);
+	netdev_dbg(dev, "MII at %d is 0x%08x\n", i, phyid);
 	if (phyid == AM79C9XX_HOME_PHY) {
 	    info->pna_phy = i;
 	} else if (phyid != AM79C9XX_ETH_PHY) {
@@ -1018,8 +1018,8 @@ static void pcnet_reset_8390(struct net_device *dev)
     outb_p(ENISR_RESET, nic_base + EN0_ISR); /* Ack intr. */
 
     if (i == 100)
-	printk(KERN_ERR "%s: pcnet_reset_8390() did not complete.\n",
-	       dev->name);
+	netdev_err(dev, "pcnet_reset_8390() did not complete.\n");
+
     set_misc_reg(dev);
 
 } /* pcnet_reset_8390 */
@@ -1035,8 +1035,7 @@ static int set_config(struct net_device *dev, struct ifmap *map)
 	else if ((map->port < 1) || (map->port > 2))
 	    return -EINVAL;
 	dev->if_port = map->port;
-	printk(KERN_INFO "%s: switched to %s port\n",
-	       dev->name, if_names[dev->if_port]);
+	netdev_info(dev, "switched to %s port\n", if_names[dev->if_port]);
 	NS8390_init(dev, 1);
     }
     return 0;
@@ -1071,7 +1070,7 @@ static void ei_watchdog(u_long arg)
        this, we can limp along even if the interrupt is blocked */
     if (info->stale++ && (inb_p(nic_base + EN0_ISR) & ENISR_ALL)) {
 	if (!info->fast_poll)
-	    printk(KERN_INFO "%s: interrupt(s) dropped!\n", dev->name);
+	    netdev_info(dev, "interrupt(s) dropped!\n");
 	ei_irq_wrapper(dev->irq, dev);
 	info->fast_poll = HZ;
     }
@@ -1091,7 +1090,7 @@ static void ei_watchdog(u_long arg)
 	if (info->eth_phy) {
 	    info->phy_id = info->eth_phy = 0;
 	} else {
-	    printk(KERN_INFO "%s: MII is missing!\n", dev->name);
+	    netdev_info(dev, "MII is missing!\n");
 	    info->flags &= ~HAS_MII;
 	}
 	goto reschedule;
@@ -1100,8 +1099,7 @@ static void ei_watchdog(u_long arg)
     link &= 0x0004;
     if (link != info->link_status) {
 	u_short p = mdio_read(mii_addr, info->phy_id, 5);
-	printk(KERN_INFO "%s: %s link beat\n", dev->name,
-	       (link) ? "found" : "lost");
+	netdev_info(dev, "%s link beat\n", link ? "found" : "lost");
 	if (link && (info->flags & IS_DL10022)) {
 	    /* Disable collision detection on full duplex links */
 	    outb((p & 0x0140) ? 4 : 0, nic_base + DLINK_DIAG);
@@ -1112,13 +1110,12 @@ static void ei_watchdog(u_long arg)
 	if (link) {
 	    if (info->phy_id == info->eth_phy) {
 		if (p)
-		    printk(KERN_INFO "%s: autonegotiation complete: "
-			   "%sbaseT-%cD selected\n", dev->name,
+		    netdev_info(dev, "autonegotiation complete: "
+			   "%sbaseT-%cD selected\n",
 			   ((p & 0x0180) ? "100" : "10"),
 			   ((p & 0x0140) ? 'F' : 'H'));
 		else
-		    printk(KERN_INFO "%s: link partner did not "
-			   "autonegotiate\n", dev->name);
+		    netdev_info(dev, "link partner did not autonegotiate\n");
 	    }
 	    NS8390_init(dev, 1);
 	}
@@ -1131,7 +1128,7 @@ static void ei_watchdog(u_long arg)
 	    /* isolate this MII and try flipping to the other one */
 	    mdio_write(mii_addr, info->phy_id, 0, 0x0400);
 	    info->phy_id ^= info->pna_phy ^ info->eth_phy;
-	    printk(KERN_INFO "%s: switched to %s transceiver\n", dev->name,
+	    netdev_info(dev, "switched to %s transceiver\n",
 		   (info->phy_id == info->eth_phy) ? "ethernet" : "PNA");
 	    mdio_write(mii_addr, info->phy_id, 0,
 		       (info->phy_id == info->eth_phy) ? 0x1000 : 0);
@@ -1191,9 +1188,9 @@ static void dma_get_8390_hdr(struct net_device *dev,
     unsigned int nic_base = dev->base_addr;
 
     if (ei_status.dmaing) {
-	printk(KERN_NOTICE "%s: DMAing conflict in dma_block_input."
+	netdev_notice(dev, "DMAing conflict in dma_block_input."
 	       "[DMAstat:%1x][irqlock:%1x]\n",
-	       dev->name, ei_status.dmaing, ei_status.irqlock);
+	       ei_status.dmaing, ei_status.irqlock);
 	return;
     }
 
@@ -1224,11 +1221,11 @@ static void dma_block_input(struct net_device *dev, int count,
     char *buf = skb->data;
 
     if ((ei_debug > 4) && (count != 4))
-	pr_debug("%s: [bi=%d]\n", dev->name, count+4);
+	netdev_dbg(dev, "[bi=%d]\n", count+4);
     if (ei_status.dmaing) {
-	printk(KERN_NOTICE "%s: DMAing conflict in dma_block_input."
+	netdev_notice(dev, "DMAing conflict in dma_block_input."
 	       "[DMAstat:%1x][irqlock:%1x]\n",
-	       dev->name, ei_status.dmaing, ei_status.irqlock);
+	       ei_status.dmaing, ei_status.irqlock);
 	return;
     }
     ei_status.dmaing |= 0x01;
@@ -1258,9 +1255,9 @@ static void dma_block_input(struct net_device *dev, int count,
 		break;
 	} while (--tries > 0);
 	if (tries <= 0)
-	    printk(KERN_NOTICE "%s: RX transfer address mismatch,"
+	    netdev_notice(dev, "RX transfer address mismatch,"
 		   "%#4.4x (expected) vs. %#4.4x (actual).\n",
-		   dev->name, ring_offset + xfer_count, addr);
+		   ring_offset + xfer_count, addr);
     }
 #endif
     outb_p(ENISR_RDC, nic_base + EN0_ISR);	/* Ack intr. */
@@ -1281,7 +1278,7 @@ static void dma_block_output(struct net_device *dev, int count,
 
 #ifdef PCMCIA_DEBUG
     if (ei_debug > 4)
-	printk(KERN_DEBUG "%s: [bo=%d]\n", dev->name, count);
+	netdev_dbg(dev, "[bo=%d]\n", count);
 #endif
 
     /* Round the count up for word writes.  Do we need to do this?
@@ -1290,9 +1287,9 @@ static void dma_block_output(struct net_device *dev, int count,
     if (count & 0x01)
 	count++;
     if (ei_status.dmaing) {
-	printk(KERN_NOTICE "%s: DMAing conflict in dma_block_output."
+	netdev_notice(dev, "DMAing conflict in dma_block_output."
 	       "[DMAstat:%1x][irqlock:%1x]\n",
-	       dev->name, ei_status.dmaing, ei_status.irqlock);
+	       ei_status.dmaing, ei_status.irqlock);
 	return;
     }
     ei_status.dmaing |= 0x01;
@@ -1329,9 +1326,9 @@ static void dma_block_output(struct net_device *dev, int count,
 		break;
 	} while (--tries > 0);
 	if (tries <= 0) {
-	    printk(KERN_NOTICE "%s: Tx packet transfer address mismatch,"
+	    netdev_notice(dev, "Tx packet transfer address mismatch,"
 		   "%#4.4x (expected) vs. %#4.4x (actual).\n",
-		   dev->name, (start_page << 8) + count, addr);
+		   (start_page << 8) + count, addr);
 	    if (retries++ == 0)
 		goto retry;
 	}
@@ -1340,8 +1337,7 @@ static void dma_block_output(struct net_device *dev, int count,
 
     while ((inb_p(nic_base + EN0_ISR) & ENISR_RDC) == 0)
 	if (time_after(jiffies, dma_start + PCNET_RDC_TIMEOUT)) {
-	    printk(KERN_NOTICE "%s: timeout waiting for Tx RDC.\n",
-		   dev->name);
+	    netdev_notice(dev, "timeout waiting for Tx RDC.\n");
 	    pcnet_reset_8390(dev);
 	    NS8390_init(dev, 1);
 	    break;
-- 
1.7.1

