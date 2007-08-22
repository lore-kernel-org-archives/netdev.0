From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
Date: Wed, 22 Aug 2007 20:46:48 +0200
Message-ID: <1187808408.4314.15.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:37056 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313AbXHWOMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 10:12:54 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The two different wireless code bases both define macros to ease
printing MAC addresses:

printk(KERN_INFO "MAC address is " MAC_FMT "\n", MAC_ARG(addr));

This patch moves those macros to if_ether.h and uses them all over the
tree.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---
 drivers/net/3c505.c         |    4 +---
 drivers/net/8139cp.c        |   11 ++---------
 drivers/net/82596.c         |    4 ++--
 drivers/net/a2065.c         |    4 +---
 drivers/net/acenic.c        |    6 ++----
 drivers/net/ariadne.c       |    4 +---
 drivers/net/dl2k.c          |    6 ++----
 drivers/net/forcedeth.c     |   11 ++++-------
 drivers/net/hp100.c         |    5 ++---
 drivers/net/hydra.c         |    6 ++----
 drivers/net/ibmlana.c       |    6 ++----
 drivers/net/ioc3-eth.c      |    5 ++---
 drivers/net/lguest_net.c    |    3 +--
 drivers/net/lib82596.c      |    4 ++--
 drivers/net/macb.c          |    6 ++----
 drivers/net/meth.c          |    4 +---
 drivers/net/mv643xx_eth.c   |    5 ++---
 drivers/net/mvme147.c       |    7 ++-----
 drivers/net/myri_sbus.c     |    6 ++----
 drivers/net/ns83820.c       |    9 +++------
 drivers/net/pasemi_mac.c    |    5 ++---
 drivers/net/ps3_gelic_net.c |    6 ++----
 drivers/net/qla3xxx.c       |    6 ++----
 drivers/net/rionet.c        |    5 ++---
 drivers/net/s2io.c          |   10 ++--------
 drivers/net/skge.c          |    6 ++----
 drivers/net/sky2.c          |    6 ++----
 drivers/net/tsi108_eth.c    |    6 ++----
 drivers/net/zorro8390.c     |    6 ++----
 include/linux/etherdevice.h |    1 +
 include/linux/if_ether.h    |    5 +++++
 include/net/ieee80211.h     |    5 -----
 include/net/mac80211.h      |    4 ----
 33 files changed, 62 insertions(+), 125 deletions(-)

--- netdev-2.6.orig/drivers/net/3c505.c	2007-08-22 20:33:10.921906163 +0200
+++ netdev-2.6/drivers/net/3c505.c	2007-08-22 20:40:01.011906163 +0200
@@ -1540,9 +1540,7 @@ static int __init elplus_setup(struct ne
 	 */
 	printk(KERN_INFO "%s: 3c505 at %#lx, irq %d, dma %d, ",
 	       dev->name, dev->base_addr, dev->irq, dev->dma);
-	printk("addr %02x:%02x:%02x:%02x:%02x:%02x, ",
-	       dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-	       dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+	printk("addr " MAC_FMT ", ", MAC_ARG(dev->dev_addr));
 
 	/*
 	 * read more information from the adapter
--- netdev-2.6.orig/drivers/net/8139cp.c	2007-08-22 20:33:10.931906163 +0200
+++ netdev-2.6/drivers/net/8139cp.c	2007-08-22 20:40:01.011906163 +0200
@@ -1961,15 +1961,8 @@ static int cp_init_one (struct pci_dev *
 	if (rc)
 		goto err_out_iomap;
 
-	printk (KERN_INFO "%s: RTL-8139C+ at 0x%lx, "
-		"%02x:%02x:%02x:%02x:%02x:%02x, "
-		"IRQ %d\n",
-		dev->name,
-		dev->base_addr,
-		dev->dev_addr[0], dev->dev_addr[1],
-		dev->dev_addr[2], dev->dev_addr[3],
-		dev->dev_addr[4], dev->dev_addr[5],
-		dev->irq);
+	printk (KERN_INFO "%s: RTL-8139C+ at 0x%lx, " MAC_FMT ", IRQ %d\n",
+		dev->name, dev->base_addr, MAC_ARG(dev->dev_addr), dev->irq);
 
 	pci_set_drvdata(pdev, dev);
 
--- netdev-2.6.orig/drivers/net/82596.c	2007-08-22 20:33:10.941906163 +0200
+++ netdev-2.6/drivers/net/82596.c	2007-08-22 20:40:01.021906163 +0200
@@ -1561,8 +1561,8 @@ static void set_multicast_list(struct ne
 		for (dmi = dev->mc_list; cnt && dmi != NULL; dmi = dmi->next, cnt--, cp += 6) {
 			memcpy(cp, dmi->dmi_addr, 6);
 			if (i596_debug > 1)
-				DEB(DEB_MULTI,printk(KERN_INFO "%s: Adding address %02x:%02x:%02x:%02x:%02x:%02x\n",
-						dev->name, cp[0],cp[1],cp[2],cp[3],cp[4],cp[5]));
+				DEB(DEB_MULTI,printk(KERN_INFO "%s: Adding address " MAC_FMT "\n",
+						dev->name, MAC_ARG(cp));
 		}
 		i596_add_cmd(dev, &cmd->cmd);
 	}
--- netdev-2.6.orig/drivers/net/a2065.c	2007-08-22 20:33:10.991906163 +0200
+++ netdev-2.6/drivers/net/a2065.c	2007-08-22 20:40:01.031906163 +0200
@@ -802,9 +802,7 @@ static int __devinit a2065_init_one(stru
 	zorro_set_drvdata(z, dev);
 
 	printk(KERN_INFO "%s: A2065 at 0x%08lx, Ethernet Address "
-	       "%02x:%02x:%02x:%02x:%02x:%02x\n", dev->name, board,
-	       dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-	       dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+	       MAC_FMT "\n", dev->name, board, MAC_ARG(dev->dev_addr));
 
 	return 0;
 }
--- netdev-2.6.orig/drivers/net/acenic.c	2007-08-22 20:33:10.991906163 +0200
+++ netdev-2.6/drivers/net/acenic.c	2007-08-22 20:40:01.031906163 +0200
@@ -1013,10 +1013,6 @@ static int __devinit ace_init(struct net
 	writel(mac1, &regs->MacAddrHi);
 	writel(mac2, &regs->MacAddrLo);
 
-	printk("MAC: %02x:%02x:%02x:%02x:%02x:%02x\n",
-	       (mac1 >> 8) & 0xff, mac1 & 0xff, (mac2 >> 24) &0xff,
-	       (mac2 >> 16) & 0xff, (mac2 >> 8) & 0xff, mac2 & 0xff);
-
 	dev->dev_addr[0] = (mac1 >> 8) & 0xff;
 	dev->dev_addr[1] = mac1 & 0xff;
 	dev->dev_addr[2] = (mac2 >> 24) & 0xff;
@@ -1024,6 +1020,8 @@ static int __devinit ace_init(struct net
 	dev->dev_addr[4] = (mac2 >> 8) & 0xff;
 	dev->dev_addr[5] = mac2 & 0xff;
 
+	printk("MAC: " MAC_FMT "\n", MAC_ARG(dev->dev_addr));
+
 	/*
 	 * Looks like this is necessary to deal with on all architectures,
 	 * even this %$#%$# N440BX Intel based thing doesn't get it right.
--- netdev-2.6.orig/drivers/net/ariadne.c	2007-08-22 20:33:11.661906163 +0200
+++ netdev-2.6/drivers/net/ariadne.c	2007-08-22 20:40:01.041906163 +0200
@@ -217,9 +217,7 @@ static int __devinit ariadne_init_one(st
     zorro_set_drvdata(z, dev);
 
     printk(KERN_INFO "%s: Ariadne at 0x%08lx, Ethernet Address "
-	   "%02x:%02x:%02x:%02x:%02x:%02x\n", dev->name, board,
-	   dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-	   dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+	   MAC_FMT "\n", dev->name, board, MAC_ARG(dev->dev_addr));
 
     return 0;
 }
--- netdev-2.6.orig/drivers/net/dl2k.c	2007-08-22 20:33:12.181906163 +0200
+++ netdev-2.6/drivers/net/dl2k.c	2007-08-22 20:40:01.041906163 +0200
@@ -257,10 +257,8 @@ rio_probe1 (struct pci_dev *pdev, const 
 
 	card_idx++;
 
-	printk (KERN_INFO "%s: %s, %02x:%02x:%02x:%02x:%02x:%02x, IRQ %d\n",
-		dev->name, np->name,
-		dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-		dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5], irq);
+	printk (KERN_INFO "%s: %s, " MAC_FMT ", IRQ %d\n",
+		dev->name, np->name, MAC_ARG(dev->dev_addr));
 	if (tx_coalesce > 1)
 		printk(KERN_INFO "tx_coalesce:\t%d packets\n",
 				tx_coalesce);
--- netdev-2.6.orig/drivers/net/forcedeth.c	2007-08-22 20:33:12.461906163 +0200
+++ netdev-2.6/drivers/net/forcedeth.c	2007-08-22 20:40:01.051906163 +0200
@@ -5201,10 +5201,8 @@ static int __devinit nv_probe(struct pci
 		 * Bad mac address. At least one bios sets the mac address
 		 * to 01:23:45:67:89:ab
 		 */
-		printk(KERN_ERR "%s: Invalid Mac address detected: %02x:%02x:%02x:%02x:%02x:%02x\n",
-			pci_name(pci_dev),
-			dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-			dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+		printk(KERN_ERR "%s: Invalid Mac address detected: " MAC_FMT "\n",
+			pci_name(pci_dev), MAC_ARG(dev->dev_addr));
 		printk(KERN_ERR "Please complain to your hardware vendor. Switching to a random MAC.\n");
 		dev->dev_addr[0] = 0x00;
 		dev->dev_addr[1] = 0x00;
@@ -5212,9 +5210,8 @@ static int __devinit nv_probe(struct pci
 		get_random_bytes(&dev->dev_addr[3], 3);
 	}
 
-	dprintk(KERN_DEBUG "%s: MAC Address %02x:%02x:%02x:%02x:%02x:%02x\n", pci_name(pci_dev),
-			dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-			dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+	dprintk(KERN_DEBUG "%s: MAC Address " MAC_FMT "\n", pci_name(pci_dev),
+			MAC_ARG(dev->dev_addr));
 
 	/* set mac address */
 	nv_copy_mac_to_hw(dev);
--- netdev-2.6.orig/drivers/net/hp100.c	2007-08-22 20:33:12.751906163 +0200
+++ netdev-2.6/drivers/net/hp100.c	2007-08-22 20:40:01.061906163 +0200
@@ -2095,9 +2095,8 @@ static void hp100_set_multicast_list(str
 				addrs = dmi->dmi_addr;
 				if ((*addrs & 0x01) == 0x01) {	/* multicast address? */
 #ifdef HP100_DEBUG
-					printk("hp100: %s: multicast = %02x:%02x:%02x:%02x:%02x:%02x, ",
-						     dev->name, addrs[0], addrs[1], addrs[2],
-						     addrs[3], addrs[4], addrs[5]);
+					printk("hp100: %s: multicast = " MAC_FMT ", ",
+						     dev->name, MAC_ARG(addrs));
 #endif
 					for (j = idx = 0; j < 6; j++) {
 						idx ^= *addrs++ & 0x3f;
--- netdev-2.6.orig/drivers/net/hydra.c	2007-08-22 20:33:12.761906163 +0200
+++ netdev-2.6/drivers/net/hydra.c	2007-08-22 20:40:01.061906163 +0200
@@ -163,10 +163,8 @@ static int __devinit hydra_init(struct z
     zorro_set_drvdata(z, dev);
 
     printk(KERN_INFO "%s: Hydra at 0x%08lx, address "
-	   "%02x:%02x:%02x:%02x:%02x:%02x (hydra.c " HYDRA_VERSION ")\n",
-	   dev->name, z->resource.start, dev->dev_addr[0], dev->dev_addr[1],
-	   dev->dev_addr[2], dev->dev_addr[3], dev->dev_addr[4],
-	   dev->dev_addr[5]);
+	   MAC_FMT " (hydra.c " HYDRA_VERSION ")\n",
+	   dev->name, z->resource.start, MAC_ARG(dev->dev_addr));
 
     return 0;
 }
--- netdev-2.6.orig/drivers/net/ibmlana.c	2007-08-22 20:33:12.791906163 +0200
+++ netdev-2.6/drivers/net/ibmlana.c	2007-08-22 20:40:01.071906163 +0200
@@ -992,11 +992,9 @@ static int ibmlana_probe(struct net_devi
 	/* print config */
 
 	printk(KERN_INFO "%s: IRQ %d, I/O %#lx, memory %#lx-%#lx, "
-	       "MAC address %02x:%02x:%02x:%02x:%02x:%02x.\n",
+	       "MAC address " MAC_FMT ".\n",
 	       dev->name, priv->realirq, dev->base_addr,
-	       dev->mem_start, dev->mem_end - 1,
-	       dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-	       dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+	       dev->mem_start, dev->mem_end - 1, MAC_ARG(dev->dev_addr));
 	printk(KERN_INFO "%s: %s medium\n", dev->name, MediaNames[priv->medium]);
 
 	/* reset board */
--- netdev-2.6.orig/drivers/net/ioc3-eth.c	2007-08-22 20:33:12.801906163 +0200
+++ netdev-2.6/drivers/net/ioc3-eth.c	2007-08-22 20:40:01.071906163 +0200
@@ -392,9 +392,8 @@ static int nic_init(struct ioc3 *ioc3)
 
 	printk("Found %s NIC", type);
 	if (type != unknown) {
-		printk (" registration number %02x:%02x:%02x:%02x:%02x:%02x,"
-			" CRC %02x", serial[0], serial[1], serial[2],
-			serial[3], serial[4], serial[5], crc);
+		printk (" registration number " MAC_FMT ", CRC %02x",
+			MAC_ARG(serial), crc);
 	}
 	printk(".\n");
 
--- netdev-2.6.orig/drivers/net/lguest_net.c	2007-08-22 20:33:12.921906163 +0200
+++ netdev-2.6/drivers/net/lguest_net.c	2007-08-22 20:40:01.081906163 +0200
@@ -236,8 +236,7 @@ static int lguestnet_start_xmit(struct s
 	/* Extract the destination ethernet address from the packet. */
 	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
 
-	pr_debug("%s: xmit %02x:%02x:%02x:%02x:%02x:%02x\n",
-		 dev->name, dest[0],dest[1],dest[2],dest[3],dest[4],dest[5]);
+	pr_debug("%s: xmit " MAC_FMT "\n", dev->name, MAC_ARG(dest));
 
 	/* If it's a multicast packet, we broadcast to everyone.  That's not
 	 * very efficient, but there are very few applications which actually
--- netdev-2.6.orig/drivers/net/lib82596.c	2007-08-22 20:33:12.931906163 +0200
+++ netdev-2.6/drivers/net/lib82596.c	2007-08-22 20:40:01.081906163 +0200
@@ -1425,8 +1425,8 @@ static void set_multicast_list(struct ne
 			if (i596_debug > 1)
 				DEB(DEB_MULTI,
 				    printk(KERN_DEBUG
-					   "%s: Adding address %02x:%02x:%02x:%02x:%02x:%02x\n",
-					   dev->name, cp[0], cp[1], cp[2], cp[3], cp[4], cp[5]));
+					   "%s: Adding address " MAC_FMT "\n",
+					   dev->name, MAC_ARG(cp));
 		}
 		DMA_WBACK_INV(dev, &dma->mc_cmd, sizeof(struct mc_cmd));
 		i596_add_cmd(dev, &cmd->cmd);
--- netdev-2.6.orig/drivers/net/macb.c	2007-08-22 20:33:12.931906163 +0200
+++ netdev-2.6/drivers/net/macb.c	2007-08-22 20:40:01.081906163 +0200
@@ -1189,10 +1189,8 @@ static int __devinit macb_probe(struct p
 	platform_set_drvdata(pdev, dev);
 
 	printk(KERN_INFO "%s: Atmel MACB at 0x%08lx irq %d "
-	       "(%02x:%02x:%02x:%02x:%02x:%02x)\n",
-	       dev->name, dev->base_addr, dev->irq,
-	       dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-	       dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+	       "(" MAC_FMT ")\n",
+	       dev->name, dev->base_addr, dev->irq, MAC_ARG(dev->dev_addr));
 
 	phydev = bp->phy_dev;
 	printk(KERN_INFO "%s: attached PHY driver [%s] "
--- netdev-2.6.orig/drivers/net/meth.c	2007-08-22 20:33:12.941906163 +0200
+++ netdev-2.6/drivers/net/meth.c	2007-08-22 20:40:01.101906163 +0200
@@ -96,11 +96,9 @@ char o2meth_eaddr[8]={0,0,0,0,0,0,0,0};
 static inline void load_eaddr(struct net_device *dev)
 {
 	int i;
-	DPRINTK("Loading MAC Address: %02x:%02x:%02x:%02x:%02x:%02x\n",
-		(int)o2meth_eaddr[0]&0xFF,(int)o2meth_eaddr[1]&0xFF,(int)o2meth_eaddr[2]&0xFF,
-		(int)o2meth_eaddr[3]&0xFF,(int)o2meth_eaddr[4]&0xFF,(int)o2meth_eaddr[5]&0xFF);
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = o2meth_eaddr[i];
+	DPRINTK("Loading MAC Address: " MAC_FMT "\n", MAC_ARG(dev->dev_addr));
 	mace->eth.mac_addr = (*(unsigned long*)o2meth_eaddr) >> 16;
 }
 
--- netdev-2.6.orig/drivers/net/mv643xx_eth.c	2007-08-22 20:33:12.981906163 +0200
+++ netdev-2.6/drivers/net/mv643xx_eth.c	2007-08-22 20:40:01.111906163 +0200
@@ -1429,9 +1429,8 @@ static int mv643xx_eth_probe(struct plat
 		goto out;
 
 	p = dev->dev_addr;
-	printk(KERN_NOTICE
-		"%s: port %d with MAC address %02x:%02x:%02x:%02x:%02x:%02x\n",
-		dev->name, port_num, p[0], p[1], p[2], p[3], p[4], p[5]);
+	printk(KERN_NOTICE "%s: port %d with MAC address " MAC_FMT "\n",
+		dev->name, port_num, MAC_ARG(p));
 
 	if (dev->features & NETIF_F_SG)
 		printk(KERN_NOTICE "%s: Scatter Gather Enabled\n", dev->name);
--- netdev-2.6.orig/drivers/net/mvme147.c	2007-08-22 20:33:12.991906163 +0200
+++ netdev-2.6/drivers/net/mvme147.c	2007-08-22 20:40:01.111906163 +0200
@@ -103,12 +103,9 @@ struct net_device * __init mvme147lance_
 	address=address>>8;
 	dev->dev_addr[3]=address&0xff;
 
-	printk("%s: MVME147 at 0x%08lx, irq %d, Hardware Address %02x:%02x:%02x:%02x:%02x:%02x\n",
+	printk("%s: MVME147 at 0x%08lx, irq %d, Hardware Address " MAC_FMT "\n",
 		dev->name, dev->base_addr, MVME147_LANCE_IRQ,
-		dev->dev_addr[0],
-		dev->dev_addr[1], dev->dev_addr[2],
-		dev->dev_addr[3], dev->dev_addr[4],
-		dev->dev_addr[5]);
+		MAC_ARG(dev->dev_addr));
 
 	lp = (struct m147lance_private *)dev->priv;
 	lp->ram = __get_dma_pages(GFP_ATOMIC, 3);	/* 16K */
--- netdev-2.6.orig/drivers/net/ns83820.c	2007-08-22 20:33:16.621906163 +0200
+++ netdev-2.6/drivers/net/ns83820.c	2007-08-22 20:40:01.111906163 +0200
@@ -2082,14 +2082,11 @@ static int __devinit ns83820_init_one(st
 		ndev->features |= NETIF_F_HIGHDMA;
 	}
 
-	printk(KERN_INFO "%s: ns83820 v" VERSION ": DP83820 v%u.%u: %02x:%02x:%02x:%02x:%02x:%02x io=0x%08lx irq=%d f=%s\n",
-		ndev->name,
+	printk(KERN_INFO "%s: ns83820 v" VERSION ": DP83820 v%u.%u: " MAC_FMT
+		" io=0x%08lx irq=%d f=%s\n", ndev->name,
 		(unsigned)readl(dev->base + SRR) >> 8,
 		(unsigned)readl(dev->base + SRR) & 0xff,
-		ndev->dev_addr[0], ndev->dev_addr[1],
-		ndev->dev_addr[2], ndev->dev_addr[3],
-		ndev->dev_addr[4], ndev->dev_addr[5],
-		addr, pci_dev->irq,
+		MAC_ARG(ndev->dev_addr) addr, pci_dev->irq,
 		(ndev->features & NETIF_F_HIGHDMA) ? "h,sg" : "sg"
 		);
 
--- netdev-2.6.orig/drivers/net/pasemi_mac.c	2007-08-22 20:33:16.691906163 +0200
+++ netdev-2.6/drivers/net/pasemi_mac.c	2007-08-22 20:40:01.121906163 +0200
@@ -1173,11 +1173,10 @@ pasemi_mac_probe(struct pci_dev *pdev, c
 		goto out;
 	} else
 		printk(KERN_INFO "%s: PA Semi %s: intf %d, txch %d, rxch %d, "
-		       "hw addr %02x:%02x:%02x:%02x:%02x:%02x\n",
+		       "hw addr " MAC_FMT "\n",
 		       dev->name, mac->type == MAC_TYPE_GMAC ? "GMAC" : "XAUI",
 		       mac->dma_if, mac->dma_txch, mac->dma_rxch,
-		       dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-		       dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+		       MAC_ARG(dev->dev_addr));
 
 	return err;
 
--- netdev-2.6.orig/drivers/net/ps3_gelic_net.c	2007-08-22 20:33:16.891906163 +0200
+++ netdev-2.6/drivers/net/ps3_gelic_net.c	2007-08-22 20:40:01.121906163 +0200
@@ -1397,10 +1397,8 @@ static int gelic_net_setup_netdev(struct
 	v1 <<= 16;
 	memcpy(addr.sa_data, &v1, ETH_ALEN);
 	memcpy(netdev->dev_addr, addr.sa_data, ETH_ALEN);
-	dev_info(ctodev(card), "MAC addr %02x:%02x:%02x:%02x:%02x:%02x\n",
-		 netdev->dev_addr[0], netdev->dev_addr[1],
-		 netdev->dev_addr[2], netdev->dev_addr[3],
-		 netdev->dev_addr[4], netdev->dev_addr[5]);
+	dev_info(ctodev(card), "MAC addr " MAC_FMT "\n",
+		 MAC_ARG(netdev->dev_addr));
 
 	card->vlan_index = -1;	/* no vlan */
 	for (i = 0; i < GELIC_NET_VLAN_MAX; i++) {
--- netdev-2.6.orig/drivers/net/qla3xxx.c	2007-08-22 20:33:16.901906163 +0200
+++ netdev-2.6/drivers/net/qla3xxx.c	2007-08-22 20:40:01.131906163 +0200
@@ -3576,10 +3576,8 @@ static void ql_display_dev_info(struct n
 
 	if (netif_msg_probe(qdev))
 		printk(KERN_INFO PFX
-		       "%s: MAC address %02x:%02x:%02x:%02x:%02x:%02x\n",
-		       ndev->name, ndev->dev_addr[0], ndev->dev_addr[1],
-		       ndev->dev_addr[2], ndev->dev_addr[3], ndev->dev_addr[4],
-		       ndev->dev_addr[5]);
+		       "%s: MAC address " MAC_FMT "\n",
+		       ndev->name, MAC_ARG(ndev->dev_addr));
 }
 
 static int ql_adapter_down(struct ql3_adapter *qdev, int do_reset)
--- netdev-2.6.orig/drivers/net/rionet.c	2007-08-22 20:33:16.901906163 +0200
+++ netdev-2.6/drivers/net/rionet.c	2007-08-22 20:40:01.141906163 +0200
@@ -482,13 +482,12 @@ static int rionet_setup_netdev(struct ri
 	if (rc != 0)
 		goto out;
 
-	printk("%s: %s %s Version %s, MAC %02x:%02x:%02x:%02x:%02x:%02x\n",
+	printk("%s: %s %s Version %s, MAC " MAC_FMT "\n",
 	       ndev->name,
 	       DRV_NAME,
 	       DRV_DESC,
 	       DRV_VERSION,
-	       ndev->dev_addr[0], ndev->dev_addr[1], ndev->dev_addr[2],
-	       ndev->dev_addr[3], ndev->dev_addr[4], ndev->dev_addr[5]);
+	       MAC_ARG(ndev->dev_addr));
 
       out:
 	return rc;
--- netdev-2.6.orig/drivers/net/s2io.c	2007-08-22 20:33:16.991906163 +0200
+++ netdev-2.6/drivers/net/s2io.c	2007-08-22 20:40:01.151906163 +0200
@@ -7330,14 +7330,8 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		  sp->product_name, pdev->revision);
 	DBG_PRINT(ERR_DBG, "%s: Driver version %s\n", dev->name,
 		  s2io_driver_version);
-	DBG_PRINT(ERR_DBG, "%s: MAC ADDR: "
-			  "%02x:%02x:%02x:%02x:%02x:%02x", dev->name,
-			  sp->def_mac_addr[0].mac_addr[0],
-			  sp->def_mac_addr[0].mac_addr[1],
-			  sp->def_mac_addr[0].mac_addr[2],
-			  sp->def_mac_addr[0].mac_addr[3],
-			  sp->def_mac_addr[0].mac_addr[4],
-			  sp->def_mac_addr[0].mac_addr[5]);
+	DBG_PRINT(ERR_DBG, "%s: MAC ADDR: " MAC_FMT, dev->name,
+		  MAC_ARG(sp->def_mac_addr[0]));
 	DBG_PRINT(ERR_DBG, "SERIAL NUMBER: %s\n", sp->serial_num);
 	if (sp->device_type & XFRAME_II_DEVICE) {
 		mode = s2io_print_pci_mode(sp);
--- netdev-2.6.orig/drivers/net/skge.c	2007-08-22 20:33:18.721906163 +0200
+++ netdev-2.6/drivers/net/skge.c	2007-08-22 20:40:01.211906163 +0200
@@ -3621,10 +3621,8 @@ static void __devinit skge_show_addr(str
 	const struct skge_port *skge = netdev_priv(dev);
 
 	if (netif_msg_probe(skge))
-		printk(KERN_INFO PFX "%s: addr %02x:%02x:%02x:%02x:%02x:%02x\n",
-		       dev->name,
-		       dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-		       dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+		printk(KERN_INFO PFX "%s: addr " MAC_FMT "\n",
+		       dev->name, MAC_ARG(dev->dev_addr));
 }
 
 static int __devinit skge_probe(struct pci_dev *pdev,
--- netdev-2.6.orig/drivers/net/sky2.c	2007-08-22 20:33:18.921906163 +0200
+++ netdev-2.6/drivers/net/sky2.c	2007-08-22 20:40:01.221906163 +0200
@@ -3808,10 +3808,8 @@ static void __devinit sky2_show_addr(str
 	const struct sky2_port *sky2 = netdev_priv(dev);
 
 	if (netif_msg_probe(sky2))
-		printk(KERN_INFO PFX "%s: addr %02x:%02x:%02x:%02x:%02x:%02x\n",
-		       dev->name,
-		       dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-		       dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+		printk(KERN_INFO PFX "%s: addr " MAC_FMT "\n",
+		       dev->name, MAC_ARG(dev->dev_addr));
 }
 
 /* Handle software interrupt used during MSI test */
--- netdev-2.6.orig/drivers/net/tsi108_eth.c	2007-08-22 20:33:31.261906163 +0200
+++ netdev-2.6/drivers/net/tsi108_eth.c	2007-08-22 20:40:01.231906163 +0200
@@ -1628,10 +1628,8 @@ tsi108_init_one(struct platform_device *
 		goto register_fail;
 	}
 
-	printk(KERN_INFO "%s: Tsi108 Gigabit Ethernet, MAC: "
-	       "%02x:%02x:%02x:%02x:%02x:%02x\n", dev->name,
-	       dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-	       dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+	printk(KERN_INFO "%s: Tsi108 Gigabit Ethernet, MAC: " MAC_FMT "\n",
+	       dev->name, MAC_ARG(dev->dev_addr));
 #ifdef DEBUG
 	data->msg_enable = DEBUG;
 	dump_eth_one(dev);
--- netdev-2.6.orig/drivers/net/zorro8390.c	2007-08-22 20:33:34.401906163 +0200
+++ netdev-2.6/drivers/net/zorro8390.c	2007-08-22 20:40:01.231906163 +0200
@@ -244,10 +244,8 @@ static int __devinit zorro8390_init(stru
 	return err;
     }
 
-    printk(KERN_INFO "%s: %s at 0x%08lx, Ethernet Address "
-	   "%02x:%02x:%02x:%02x:%02x:%02x\n", dev->name, name, board,
-	   dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-	   dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+    printk(KERN_INFO "%s: %s at 0x%08lx, Ethernet Address " MAC_FMT "\n",
+	   dev->name, name, board, MAC_ARG(dev->dev_addr));
 
     return 0;
 }
--- netdev-2.6.orig/include/linux/etherdevice.h	2007-08-22 20:34:43.451906163 +0200
+++ netdev-2.6/include/linux/etherdevice.h	2007-08-22 20:40:02.101906163 +0200
@@ -133,6 +133,7 @@ static inline unsigned compare_ether_add
 	BUILD_BUG_ON(ETH_ALEN != 6);
 	return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | (a[2] ^ b[2])) != 0;
 }
+
 #endif	/* __KERNEL__ */
 
 #endif	/* _LINUX_ETHERDEVICE_H */
--- netdev-2.6.orig/drivers/net/myri_sbus.c	2007-08-22 20:33:16.251906163 +0200
+++ netdev-2.6/drivers/net/myri_sbus.c	2007-08-22 20:40:02.171906163 +0200
@@ -854,10 +854,8 @@ static inline void determine_reg_space_s
 static void dump_eeprom(struct myri_eth *mp)
 {
 	printk("EEPROM: clockval[%08x] cpuvers[%04x] "
-	       "id[%02x,%02x,%02x,%02x,%02x,%02x]\n",
-	       mp->eeprom.cval, mp->eeprom.cpuvers,
-	       mp->eeprom.id[0], mp->eeprom.id[1], mp->eeprom.id[2],
-	       mp->eeprom.id[3], mp->eeprom.id[4], mp->eeprom.id[5]);
+	       "id[" MAC_FMT "]\n",
+	       mp->eeprom.cval, mp->eeprom.cpuvers, MAC_ARG(mp->eeprom.id));
 	printk("EEPROM: ramsz[%08x]\n", mp->eeprom.ramsz);
 	printk("EEPROM: fvers[%02x,%02x,%02x,%02x,%02x,%02x,%02x,%02x\n",
 	       mp->eeprom.fvers[0], mp->eeprom.fvers[1], mp->eeprom.fvers[2],
--- netdev-2.6.orig/include/net/mac80211.h	2007-08-22 20:35:04.481906163 +0200
+++ netdev-2.6/include/net/mac80211.h	2007-08-22 20:40:02.171906163 +0200
@@ -1058,8 +1058,4 @@ static inline int ieee80211_get_morefrag
 		IEEE80211_FCTL_MOREFRAGS) != 0;
 }
 
-#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
-#define MAC_ARG(x) ((u8*)(x))[0], ((u8*)(x))[1], ((u8*)(x))[2], \
-		   ((u8*)(x))[3], ((u8*)(x))[4], ((u8*)(x))[5]
-
 #endif /* MAC80211_H */
--- netdev-2.6.orig/include/net/ieee80211.h	2007-08-22 20:35:03.981906163 +0200
+++ netdev-2.6/include/net/ieee80211.h	2007-08-22 20:40:02.181906163 +0200
@@ -119,11 +119,6 @@ do { if (ieee80211_debug_level & (level)
 #define IEEE80211_DEBUG(level, fmt, args...) do {} while (0)
 #endif				/* CONFIG_IEEE80211_DEBUG */
 
-/* debug macros not dependent on CONFIG_IEEE80211_DEBUG */
-
-#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
-#define MAC_ARG(x) ((u8*)(x))[0],((u8*)(x))[1],((u8*)(x))[2],((u8*)(x))[3],((u8*)(x))[4],((u8*)(x))[5]
-
 /* escape_essid() is intended to be used in debug (and possibly error)
  * messages. It should never be used for passing essid to user space. */
 const char *escape_essid(const char *essid, u8 essid_len);
--- netdev-2.6.orig/include/linux/if_ether.h	2007-08-22 20:34:43.751906163 +0200
+++ netdev-2.6/include/linux/if_ether.h	2007-08-22 20:40:02.181906163 +0200
@@ -120,6 +120,11 @@ static inline struct ethhdr *eth_hdr(con
 #ifdef CONFIG_SYSCTL
 extern struct ctl_table ether_table[];
 #endif
+
+/* helper macros to print MAC addresses */
+#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
+#define MAC_ARG(x) ((u8*)(x))[0], ((u8*)(x))[1], ((u8*)(x))[2], \
+		   ((u8*)(x))[3], ((u8*)(x))[4], ((u8*)(x))[5]
 #endif
 
 #endif	/* _LINUX_IF_ETHER_H */


