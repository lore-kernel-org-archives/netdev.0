From: Maxim Zhukov <mussitantesmortem@gmail.com>
Subject: [PATCH 1/2] net: ethernet: dlink: dl2k: fix code style
Date: Wed, 23 Mar 2016 17:36:39 +0300
Message-ID: <1458743800-30606-1-git-send-email-mussitantesmortem@gmail.com>
Cc: linux@rainbow-software.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Maxim Zhukov <mussitantesmortem@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit fixed spacing errors and warnings.

Signed-off-by: Maxim Zhukov <mussitantesmortem@gmail.com>
---
 drivers/net/ethernet/dlink/dl2k.c | 491 +++++++++++++++++++-------------------
 1 file changed, 245 insertions(+), 246 deletions(-)

diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index f92b6d9..d128306 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -30,16 +30,16 @@ static int mtu[MAX_UNITS];
 static int vlan[MAX_UNITS];
 static int jumbo[MAX_UNITS];
 static char *media[MAX_UNITS];
-static int tx_flow=-1;
-static int rx_flow=-1;
+static int tx_flow = -1;
+static int rx_flow = -1;
 static int copy_thresh;
-static int rx_coalesce=10;	/* Rx frame count each interrupt */
-static int rx_timeout=200;	/* Rx DMA wait time in 640ns increments */
-static int tx_coalesce=16;	/* HW xmit count each TxDMAComplete */
+static int rx_coalesce = 10;	/* Rx frame count each interrupt */
+static int rx_timeout = 200;	/* Rx DMA wait time in 640ns increments */
+static int tx_coalesce = 16;	/* HW xmit count each TxDMAComplete */
 
 
-MODULE_AUTHOR ("Edward Peng");
-MODULE_DESCRIPTION ("D-Link DL2000-based Gigabit Ethernet Adapter");
+MODULE_AUTHOR("Edward Peng");
+MODULE_DESCRIPTION("D-Link DL2000-based Gigabit Ethernet Adapter");
 MODULE_LICENSE("GPL");
 module_param_array(mtu, int, NULL, 0);
 module_param_array(media, charp, NULL, 0);
@@ -54,7 +54,7 @@ module_param(tx_coalesce, int, 0); /* HW xmit count each TxDMAComplete */
 
 
 /* Enable the default interrupts */
-#define DEFAULT_INTR (RxDMAComplete | HostError | IntRequested | TxDMAComplete| \
+#define DEFAULT_INTR (RxDMAComplete | HostError | IntRequested | TxDMAComplete | \
        UpdateStats | LinkEvent)
 
 static void dl2k_enable_int(struct netdev_private *np)
@@ -67,32 +67,32 @@ static void dl2k_enable_int(struct netdev_private *np)
 static const int max_intrloop = 50;
 static const int multicast_filter_limit = 0x40;
 
-static int rio_open (struct net_device *dev);
-static void rio_timer (unsigned long data);
-static void rio_tx_timeout (struct net_device *dev);
-static netdev_tx_t start_xmit (struct sk_buff *skb, struct net_device *dev);
-static irqreturn_t rio_interrupt (int irq, void *dev_instance);
-static void rio_free_tx (struct net_device *dev, int irq);
-static void tx_error (struct net_device *dev, int tx_status);
-static int receive_packet (struct net_device *dev);
-static void rio_error (struct net_device *dev, int int_status);
-static int change_mtu (struct net_device *dev, int new_mtu);
-static void set_multicast (struct net_device *dev);
-static struct net_device_stats *get_stats (struct net_device *dev);
-static int clear_stats (struct net_device *dev);
-static int rio_ioctl (struct net_device *dev, struct ifreq *rq, int cmd);
-static int rio_close (struct net_device *dev);
-static int find_miiphy (struct net_device *dev);
-static int parse_eeprom (struct net_device *dev);
-static int read_eeprom (struct netdev_private *, int eep_addr);
-static int mii_wait_link (struct net_device *dev, int wait);
-static int mii_set_media (struct net_device *dev);
-static int mii_get_media (struct net_device *dev);
-static int mii_set_media_pcs (struct net_device *dev);
-static int mii_get_media_pcs (struct net_device *dev);
-static int mii_read (struct net_device *dev, int phy_addr, int reg_num);
-static int mii_write (struct net_device *dev, int phy_addr, int reg_num,
-		      u16 data);
+static int rio_open(struct net_device *dev);
+static void rio_timer(unsigned long data);
+static void rio_tx_timeout(struct net_device *dev);
+static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev);
+static irqreturn_t rio_interrupt(int irq, void *dev_instance);
+static void rio_free_tx(struct net_device *dev, int irq);
+static void tx_error(struct net_device *dev, int tx_status);
+static int receive_packet(struct net_device *dev);
+static void rio_error(struct net_device *dev, int int_status);
+static int change_mtu(struct net_device *dev, int new_mtu);
+static void set_multicast(struct net_device *dev);
+static struct net_device_stats *get_stats(struct net_device *dev);
+static int clear_stats(struct net_device *dev);
+static int rio_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
+static int rio_close(struct net_device *dev);
+static int find_miiphy(struct net_device *dev);
+static int parse_eeprom(struct net_device *dev);
+static int read_eeprom(struct netdev_private *, int eep_addr);
+static int mii_wait_link(struct net_device *dev, int wait);
+static int mii_set_media(struct net_device *dev);
+static int mii_get_media(struct net_device *dev);
+static int mii_set_media_pcs(struct net_device *dev);
+static int mii_get_media_pcs(struct net_device *dev);
+static int mii_read(struct net_device *dev, int phy_addr, int reg_num);
+static int mii_write(struct net_device *dev, int phy_addr, int reg_num,
+		     u16 data);
 
 static const struct ethtool_ops ethtool_ops;
 
@@ -102,7 +102,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_stop		= rio_close,
 	.ndo_get_stats		= get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_set_rx_mode	= set_multicast,
 	.ndo_do_ioctl		= rio_ioctl,
 	.ndo_tx_timeout		= rio_tx_timeout,
@@ -110,7 +110,7 @@ static const struct net_device_ops netdev_ops = {
 };
 
 static int
-rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
+rio_probe1(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *dev;
 	struct netdev_private *np;
@@ -123,22 +123,22 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 	dma_addr_t ring_dma;
 
 	if (!version_printed++)
-		printk ("%s", version);
+		printk("%s", version);
 
-	err = pci_enable_device (pdev);
+	err = pci_enable_device(pdev);
 	if (err)
 		return err;
 
 	irq = pdev->irq;
-	err = pci_request_regions (pdev, "dl2k");
+	err = pci_request_regions(pdev, "dl2k");
 	if (err)
 		goto err_out_disable;
 
-	pci_set_master (pdev);
+	pci_set_master(pdev);
 
 	err = -ENOMEM;
 
-	dev = alloc_etherdev (sizeof (*np));
+	dev = alloc_etherdev(sizeof(*np));
 	if (!dev)
 		goto err_out_res;
 	SET_NETDEV_DEV(dev, &pdev->dev);
@@ -160,8 +160,8 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 	np->ioaddr = ioaddr;
 	np->chip_id = chip_idx;
 	np->pdev = pdev;
-	spin_lock_init (&np->tx_lock);
-	spin_lock_init (&np->rx_lock);
+	spin_lock_init(&np->tx_lock);
+	spin_lock_init(&np->rx_lock);
 
 	/* Parse manual configuration */
 	np->an_enable = 1;
@@ -169,32 +169,32 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (card_idx < MAX_UNITS) {
 		if (media[card_idx] != NULL) {
 			np->an_enable = 0;
-			if (strcmp (media[card_idx], "auto") == 0 ||
-			    strcmp (media[card_idx], "autosense") == 0 ||
-			    strcmp (media[card_idx], "0") == 0 ) {
+			if (strcmp(media[card_idx], "auto") == 0 ||
+			    strcmp(media[card_idx], "autosense") == 0 ||
+			    strcmp(media[card_idx], "0") == 0) {
 				np->an_enable = 2;
-			} else if (strcmp (media[card_idx], "100mbps_fd") == 0 ||
-			    strcmp (media[card_idx], "4") == 0) {
+			} else if (strcmp(media[card_idx], "100mbps_fd") == 0 ||
+			    strcmp(media[card_idx], "4") == 0) {
 				np->speed = 100;
 				np->full_duplex = 1;
-			} else if (strcmp (media[card_idx], "100mbps_hd") == 0 ||
-				   strcmp (media[card_idx], "3") == 0) {
+			} else if (strcmp(media[card_idx], "100mbps_hd") == 0 ||
+				   strcmp(media[card_idx], "3") == 0) {
 				np->speed = 100;
 				np->full_duplex = 0;
-			} else if (strcmp (media[card_idx], "10mbps_fd") == 0 ||
-				   strcmp (media[card_idx], "2") == 0) {
+			} else if (strcmp(media[card_idx], "10mbps_fd") == 0 ||
+				   strcmp(media[card_idx], "2") == 0) {
 				np->speed = 10;
 				np->full_duplex = 1;
-			} else if (strcmp (media[card_idx], "10mbps_hd") == 0 ||
-				   strcmp (media[card_idx], "1") == 0) {
+			} else if (strcmp(media[card_idx], "10mbps_hd") == 0 ||
+				   strcmp(media[card_idx], "1") == 0) {
 				np->speed = 10;
 				np->full_duplex = 0;
-			} else if (strcmp (media[card_idx], "1000mbps_fd") == 0 ||
-				 strcmp (media[card_idx], "6") == 0) {
-				np->speed=1000;
-				np->full_duplex=1;
-			} else if (strcmp (media[card_idx], "1000mbps_hd") == 0 ||
-				 strcmp (media[card_idx], "5") == 0) {
+			} else if (strcmp(media[card_idx], "1000mbps_fd") == 0 ||
+				 strcmp(media[card_idx], "6") == 0) {
+				np->speed = 1000;
+				np->full_duplex = 1;
+			} else if (strcmp(media[card_idx], "1000mbps_hd") == 0 ||
+				 strcmp(media[card_idx], "5") == 0) {
 				np->speed = 1000;
 				np->full_duplex = 0;
 			} else {
@@ -221,7 +221,7 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 
 		if (tx_coalesce < 1)
 			tx_coalesce = 1;
-		else if (tx_coalesce > TX_RING_SIZE-1)
+		else if (tx_coalesce > TX_RING_SIZE - 1)
 			tx_coalesce = TX_RING_SIZE - 1;
 	}
 	dev->netdev_ops = &netdev_ops;
@@ -230,25 +230,25 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 #if 0
 	dev->features = NETIF_F_IP_CSUM;
 #endif
-	pci_set_drvdata (pdev, dev);
+	pci_set_drvdata(pdev, dev);
 
-	ring_space = pci_alloc_consistent (pdev, TX_TOTAL_SIZE, &ring_dma);
+	ring_space = pci_alloc_consistent(pdev, TX_TOTAL_SIZE, &ring_dma);
 	if (!ring_space)
 		goto err_out_iounmap;
 	np->tx_ring = ring_space;
 	np->tx_ring_dma = ring_dma;
 
-	ring_space = pci_alloc_consistent (pdev, RX_TOTAL_SIZE, &ring_dma);
+	ring_space = pci_alloc_consistent(pdev, RX_TOTAL_SIZE, &ring_dma);
 	if (!ring_space)
 		goto err_out_unmap_tx;
 	np->rx_ring = ring_space;
 	np->rx_ring_dma = ring_dma;
 
 	/* Parse eeprom data */
-	parse_eeprom (dev);
+	parse_eeprom(dev);
 
 	/* Find PHY address */
-	err = find_miiphy (dev);
+	err = find_miiphy(dev);
 	if (err)
 		goto err_out_unmap_rx;
 
@@ -258,7 +258,7 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* Set media and reset PHY */
 	if (np->phy_media) {
 		/* default Auto-Negotiation for fiber deivices */
-	 	if (np->an_enable == 2) {
+		if (np->an_enable == 2) {
 			np->an_enable = 1;
 		}
 	} else {
@@ -268,13 +268,13 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 			np->an_enable = 1;
 	}
 
-	err = register_netdev (dev);
+	err = register_netdev(dev);
 	if (err)
 		goto err_out_unmap_rx;
 
 	card_idx++;
 
-	printk (KERN_INFO "%s: %s, %pM, IRQ %d\n",
+	printk(KERN_INFO "%s: %s, %pM, IRQ %d\n",
 		dev->name, np->name, dev->dev_addr, irq);
 	if (tx_coalesce > 1)
 		printk(KERN_INFO "tx_coalesce:\t%d packets\n",
@@ -283,31 +283,31 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 		printk(KERN_INFO
 		       "rx_coalesce:\t%d packets\n"
 		       "rx_timeout: \t%d ns\n",
-				np->rx_coalesce, np->rx_timeout*640);
+				np->rx_coalesce, np->rx_timeout * 640);
 	if (np->vlan)
 		printk(KERN_INFO "vlan(id):\t%d\n", np->vlan);
 	return 0;
 
 err_out_unmap_rx:
-	pci_free_consistent (pdev, RX_TOTAL_SIZE, np->rx_ring, np->rx_ring_dma);
+	pci_free_consistent(pdev, RX_TOTAL_SIZE, np->rx_ring, np->rx_ring_dma);
 err_out_unmap_tx:
-	pci_free_consistent (pdev, TX_TOTAL_SIZE, np->tx_ring, np->tx_ring_dma);
+	pci_free_consistent(pdev, TX_TOTAL_SIZE, np->tx_ring, np->tx_ring_dma);
 err_out_iounmap:
 #ifdef MEM_MAPPING
 	pci_iounmap(pdev, np->ioaddr);
 #endif
 	pci_iounmap(pdev, np->eeprom_addr);
 err_out_dev:
-	free_netdev (dev);
+	free_netdev(dev);
 err_out_res:
-	pci_release_regions (pdev);
+	pci_release_regions(pdev);
 err_out_disable:
-	pci_disable_device (pdev);
+	pci_disable_device(pdev);
 	return err;
 }
 
 static int
-find_miiphy (struct net_device *dev)
+find_miiphy(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	int i, phy_found = 0;
@@ -315,21 +315,21 @@ find_miiphy (struct net_device *dev)
 	np->phy_addr = 1;
 
 	for (i = 31; i >= 0; i--) {
-		int mii_status = mii_read (dev, i, 1);
+		int mii_status = mii_read(dev, i, 1);
 		if (mii_status != 0xffff && mii_status != 0x0000) {
 			np->phy_addr = i;
 			phy_found++;
 		}
 	}
 	if (!phy_found) {
-		printk (KERN_ERR "%s: No MII PHY found!\n", dev->name);
+		printk(KERN_ERR "%s: No MII PHY found!\n", dev->name);
 		return -ENODEV;
 	}
 	return 0;
 }
 
 static int
-parse_eeprom (struct net_device *dev)
+parse_eeprom(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->ioaddr;
@@ -337,18 +337,18 @@ parse_eeprom (struct net_device *dev)
 	u8 sromdata[256];
 	u8 *psib;
 	u32 crc;
-	PSROM_t psrom = (PSROM_t) sromdata;
+	PSROM_t psrom = (PSROM_t)sromdata;
 
 	int cid, next;
 
 	for (i = 0; i < 128; i++)
-		((__le16 *) sromdata)[i] = cpu_to_le16(read_eeprom(np, i));
+		((__le16 *)sromdata)[i] = cpu_to_le16(read_eeprom(np, i));
 
 	if (np->pdev->vendor == PCI_VENDOR_ID_DLINK) {	/* D-Link Only */
 		/* Check CRC */
-		crc = ~ether_crc_le (256 - 4, sromdata);
+		crc = ~ether_crc_le(256 - 4, sromdata);
 		if (psrom->crc != cpu_to_le32(crc)) {
-			printk (KERN_ERR "%s: EEPROM data CRC error.\n",
+			printk(KERN_ERR "%s: EEPROM data CRC error.\n",
 					dev->name);
 			return -1;
 		}
@@ -369,12 +369,12 @@ parse_eeprom (struct net_device *dev)
 
 	/* Parse Software Information Block */
 	i = 0x30;
-	psib = (u8 *) sromdata;
+	psib = (u8 *)sromdata;
 	do {
 		cid = psib[i++];
 		next = psib[i++];
 		if ((cid == 0 && next == 0) || (cid == 0xff && next == 0xff)) {
-			printk (KERN_ERR "Cell data error\n");
+			printk(KERN_ERR "Cell data error\n");
 			return -1;
 		}
 		switch (cid) {
@@ -391,7 +391,7 @@ parse_eeprom (struct net_device *dev)
 			break;
 		case 9:	/* Adapter description */
 			j = (next - i > 255) ? 255 : next - i;
-			memcpy (np->name, &(psib[i]), j);
+			memcpy(np->name, &(psib[i]), j);
 			break;
 		case 4:
 		case 5:
@@ -560,7 +560,7 @@ static void rio_hw_init(struct net_device *dev)
 
 	/* Jumbo frame */
 	if (np->jumbo != 0)
-		dw16(MaxFrameSize, MAX_JUMBO+14);
+		dw16(MaxFrameSize, MAX_JUMBO + 14);
 
 	/* Set RFDListPtr */
 	dw32(RFDListPtr0, np->rx_ring_dma);
@@ -574,7 +574,7 @@ static void rio_hw_init(struct net_device *dev)
 		dw16(StationAddr0 + 2 * i,
 		     cpu_to_le16(((u16 *)dev->dev_addr)[i]));
 
-	set_multicast (dev);
+	set_multicast(dev);
 	if (np->coalesce) {
 		dw32(RxDMAIntCtrl, np->rx_coalesce | np->rx_timeout << 16);
 	}
@@ -585,7 +585,7 @@ static void rio_hw_init(struct net_device *dev)
 	dw8(RxDMAUrgentThresh, 0x30);
 	dw32(RmonStatMask, 0x0007ffff);
 	/* clear statistics */
-	clear_stats (dev);
+	clear_stats(dev);
 
 	/* VLAN supported */
 	if (np->vlan) {
@@ -646,19 +646,19 @@ static int rio_open(struct net_device *dev)
 	np->timer.expires = jiffies + 1 * HZ;
 	add_timer(&np->timer);
 
-	netif_start_queue (dev);
+	netif_start_queue(dev);
 
 	dl2k_enable_int(np);
 	return 0;
 }
 
 static void
-rio_timer (unsigned long data)
+rio_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
 	struct netdev_private *np = netdev_priv(dev);
 	unsigned int entry;
-	int next_tick = 1*HZ;
+	int next_tick = 1 * HZ;
 	unsigned long flags;
 
 	spin_lock_irqsave(&np->rx_lock, flags);
@@ -675,14 +675,14 @@ rio_timer (unsigned long data)
 								np->rx_buf_sz);
 				if (skb == NULL) {
 					np->rx_ring[entry].fraginfo = 0;
-					printk (KERN_INFO
+					printk(KERN_INFO
 						"%s: Still unable to re-allocate Rx skbuff.#%d\n",
 						dev->name, entry);
 					break;
 				}
 				np->rx_skbuff[entry] = skb;
 				np->rx_ring[entry].fraginfo =
-				    cpu_to_le64 (pci_map_single
+				    cpu_to_le64(pci_map_single
 					 (np->pdev, skb->data, np->rx_buf_sz,
 					  PCI_DMA_FROMDEVICE));
 			}
@@ -691,18 +691,18 @@ rio_timer (unsigned long data)
 			np->rx_ring[entry].status = 0;
 		} /* end for */
 	} /* end if */
-	spin_unlock_irqrestore (&np->rx_lock, flags);
+	spin_unlock_irqrestore(&np->rx_lock, flags);
 	np->timer.expires = jiffies + next_tick;
 	add_timer(&np->timer);
 }
 
 static void
-rio_tx_timeout (struct net_device *dev)
+rio_tx_timeout(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->ioaddr;
 
-	printk (KERN_INFO "%s: Tx timed out (%4.4x), is buffer full?\n",
+	printk(KERN_INFO "%s: Tx timed out (%4.4x), is buffer full?\n",
 		dev->name, dr32(TxStatus));
 	rio_free_tx(dev, 0);
 	dev->if_port = 0;
@@ -710,7 +710,7 @@ rio_tx_timeout (struct net_device *dev)
 }
 
 static netdev_tx_t
-start_xmit (struct sk_buff *skb, struct net_device *dev)
+start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->ioaddr;
@@ -729,7 +729,7 @@ start_xmit (struct sk_buff *skb, struct net_device *dev)
 #if 0
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		txdesc->status |=
-		    cpu_to_le64 (TCPChecksumEnable | UDPChecksumEnable |
+		    cpu_to_le64(TCPChecksumEnable | UDPChecksumEnable |
 				 IPChecksumEnable);
 	}
 #endif
@@ -738,7 +738,7 @@ start_xmit (struct sk_buff *skb, struct net_device *dev)
 		    ((u64)np->vlan << 32) |
 		    ((u64)skb->priority << 45);
 	}
-	txdesc->fraginfo = cpu_to_le64 (pci_map_single (np->pdev, skb->data,
+	txdesc->fraginfo = cpu_to_le64(pci_map_single(np->pdev, skb->data,
 							skb->len,
 							PCI_DMA_TODEVICE));
 	txdesc->fraginfo |= cpu_to_le64((u64)skb->len << 48);
@@ -746,12 +746,12 @@ start_xmit (struct sk_buff *skb, struct net_device *dev)
 	/* DL2K bug: DMA fails to get next descriptor ptr in 10Mbps mode
 	 * Work around: Always use 1 descriptor in 10Mbps mode */
 	if (entry % np->tx_coalesce == 0 || np->speed == 10)
-		txdesc->status = cpu_to_le64 (entry | tfc_vlan_tag |
+		txdesc->status = cpu_to_le64(entry | tfc_vlan_tag |
 					      WordAlignDisable |
 					      TxDMAIndicate |
 					      (1 << FragCountShift));
 	else
-		txdesc->status = cpu_to_le64 (entry | tfc_vlan_tag |
+		txdesc->status = cpu_to_le64(entry | tfc_vlan_tag |
 					      WordAlignDisable |
 					      (1 << FragCountShift));
 
@@ -764,13 +764,13 @@ start_xmit (struct sk_buff *skb, struct net_device *dev)
 			< TX_QUEUE_LEN - 1 && np->speed != 10) {
 		/* do nothing */
 	} else if (!netif_queue_stopped(dev)) {
-		netif_stop_queue (dev);
+		netif_stop_queue(dev);
 	}
 
 	/* The first TFDListPtr */
 	if (!dr32(TFDListPtr0)) {
 		dw32(TFDListPtr0, np->tx_ring_dma +
-		     entry * sizeof (struct netdev_desc));
+		     entry * sizeof(struct netdev_desc));
 		dw32(TFDListPtr1, 0);
 	}
 
@@ -778,7 +778,7 @@ start_xmit (struct sk_buff *skb, struct net_device *dev)
 }
 
 static irqreturn_t
-rio_interrupt (int irq, void *dev_instance)
+rio_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
 	struct netdev_private *np = netdev_priv(dev);
@@ -796,21 +796,21 @@ rio_interrupt (int irq, void *dev_instance)
 		handled = 1;
 		/* Processing received packets */
 		if (int_status & RxDMAComplete)
-			receive_packet (dev);
+			receive_packet(dev);
 		/* TxDMAComplete interrupt */
-		if ((int_status & (TxDMAComplete|IntRequested))) {
+		if ((int_status & (TxDMAComplete | IntRequested))) {
 			int tx_status;
 			tx_status = dr32(TxStatus);
 			if (tx_status & 0x01)
-				tx_error (dev, tx_status);
+				tx_error(dev, tx_status);
 			/* Free used tx skbuffs */
-			rio_free_tx (dev, 1);
+			rio_free_tx(dev, 1);
 		}
 
 		/* Handle uncommon events */
 		if (int_status &
 		    (HostError | LinkEvent | UpdateStats))
-			rio_error (dev, int_status);
+			rio_error(dev, int_status);
 	}
 	if (np->cur_tx != np->old_tx)
 		dw32(CountDown, 100);
@@ -818,7 +818,7 @@ rio_interrupt (int irq, void *dev_instance)
 }
 
 static void
-rio_free_tx (struct net_device *dev, int irq)
+rio_free_tx(struct net_device *dev, int irq)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	int entry = np->old_tx % TX_RING_SIZE;
@@ -837,13 +837,13 @@ rio_free_tx (struct net_device *dev, int irq)
 		if (!(np->tx_ring[entry].status & cpu_to_le64(TFDDone)))
 			break;
 		skb = np->tx_skbuff[entry];
-		pci_unmap_single (np->pdev,
+		pci_unmap_single(np->pdev,
 				  desc_to_dma(&np->tx_ring[entry]),
 				  skb->len, PCI_DMA_TODEVICE);
 		if (irq)
-			dev_kfree_skb_irq (skb);
+			dev_kfree_skb_irq(skb);
 		else
-			dev_kfree_skb (skb);
+			dev_kfree_skb(skb);
 
 		np->tx_skbuff[entry] = NULL;
 		entry = (entry + 1) % TX_RING_SIZE;
@@ -861,12 +861,12 @@ rio_free_tx (struct net_device *dev, int irq)
 	if (netif_queue_stopped(dev) &&
 	    ((np->cur_tx - np->old_tx + TX_RING_SIZE) % TX_RING_SIZE
 	    < TX_QUEUE_LEN - 1 || np->speed == 10)) {
-		netif_wake_queue (dev);
+		netif_wake_queue(dev);
 	}
 }
 
 static void
-tx_error (struct net_device *dev, int tx_status)
+tx_error(struct net_device *dev, int tx_status)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->ioaddr;
@@ -874,7 +874,7 @@ tx_error (struct net_device *dev, int tx_status)
 	int i;
 
 	frame_id = (tx_status & 0xffff0000);
-	printk (KERN_ERR "%s: Transmit error, TxStatus %4.4x, FrameId %d.\n",
+	printk(KERN_ERR "%s: Transmit error, TxStatus %4.4x, FrameId %d.\n",
 		dev->name, tx_status, frame_id);
 	np->stats.tx_errors++;
 	/* Ttransmit Underrun */
@@ -888,13 +888,13 @@ tx_error (struct net_device *dev, int tx_status)
 		for (i = 50; i > 0; i--) {
 			if (!(dr16(ASICCtrl + 2) & ResetBusy))
 				break;
-			mdelay (1);
+			mdelay(1);
 		}
 		rio_set_led_mode(dev);
-		rio_free_tx (dev, 1);
+		rio_free_tx(dev, 1);
 		/* Reset TFDListPtr */
 		dw32(TFDListPtr0, np->tx_ring_dma +
-		     np->old_tx * sizeof (struct netdev_desc));
+		     np->old_tx * sizeof(struct netdev_desc));
 		dw32(TFDListPtr1, 0);
 
 		/* Let TxStartThresh stay default value */
@@ -908,7 +908,7 @@ tx_error (struct net_device *dev, int tx_status)
 		for (i = 50; i > 0; i--) {
 			if (!(dr16(ASICCtrl + 2) & ResetBusy))
 				break;
-			mdelay (1);
+			mdelay(1);
 		}
 		rio_set_led_mode(dev);
 		/* Let TxStartThresh stay default value */
@@ -926,7 +926,7 @@ tx_error (struct net_device *dev, int tx_status)
 }
 
 static int
-receive_packet (struct net_device *dev)
+receive_packet(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	int entry = np->cur_rx % RX_RING_SIZE;
@@ -958,33 +958,33 @@ receive_packet (struct net_device *dev)
 			if (frame_status & RxAlignmentError && np->speed != 1000)
 				np->stats.rx_frame_errors++;
 			if (frame_status & RxFIFOOverrun)
-	 			np->stats.rx_fifo_errors++;
+				np->stats.rx_fifo_errors++;
 		} else {
 			struct sk_buff *skb;
 
 			/* Small skbuffs for short packets */
 			if (pkt_len > copy_thresh) {
-				pci_unmap_single (np->pdev,
+				pci_unmap_single(np->pdev,
 						  desc_to_dma(desc),
 						  np->rx_buf_sz,
 						  PCI_DMA_FROMDEVICE);
-				skb_put (skb = np->rx_skbuff[entry], pkt_len);
+				skb_put(skb = np->rx_skbuff[entry], pkt_len);
 				np->rx_skbuff[entry] = NULL;
 			} else if ((skb = netdev_alloc_skb_ip_align(dev, pkt_len))) {
 				pci_dma_sync_single_for_cpu(np->pdev,
 							    desc_to_dma(desc),
 							    np->rx_buf_sz,
 							    PCI_DMA_FROMDEVICE);
-				skb_copy_to_linear_data (skb,
+				skb_copy_to_linear_data(skb,
 						  np->rx_skbuff[entry]->data,
 						  pkt_len);
-				skb_put (skb, pkt_len);
+				skb_put(skb, pkt_len);
 				pci_dma_sync_single_for_device(np->pdev,
 							       desc_to_dma(desc),
 							       np->rx_buf_sz,
 							       PCI_DMA_FROMDEVICE);
 			}
-			skb->protocol = eth_type_trans (skb, dev);
+			skb->protocol = eth_type_trans(skb, dev);
 #if 0
 			/* Checksum done by hw, but csum value unavailable. */
 			if (np->pdev->pci_rev_id >= 0x0c &&
@@ -992,7 +992,7 @@ receive_packet (struct net_device *dev)
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 			}
 #endif
-			netif_rx (skb);
+			netif_rx(skb);
 		}
 		entry = (entry + 1) % RX_RING_SIZE;
 	}
@@ -1007,7 +1007,7 @@ receive_packet (struct net_device *dev)
 			skb = netdev_alloc_skb_ip_align(dev, np->rx_buf_sz);
 			if (skb == NULL) {
 				np->rx_ring[entry].fraginfo = 0;
-				printk (KERN_INFO
+				printk(KERN_INFO
 					"%s: receive_packet: "
 					"Unable to re-allocate Rx skbuff.#%d\n",
 					dev->name, entry);
@@ -1015,7 +1015,7 @@ receive_packet (struct net_device *dev)
 			}
 			np->rx_skbuff[entry] = skb;
 			np->rx_ring[entry].fraginfo =
-			    cpu_to_le64 (pci_map_single
+			    cpu_to_le64(pci_map_single
 					 (np->pdev, skb->data, np->rx_buf_sz,
 					  PCI_DMA_FROMDEVICE));
 		}
@@ -1030,7 +1030,7 @@ receive_packet (struct net_device *dev)
 }
 
 static void
-rio_error (struct net_device *dev, int int_status)
+rio_error(struct net_device *dev, int int_status)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->ioaddr;
@@ -1038,12 +1038,12 @@ rio_error (struct net_device *dev, int int_status)
 
 	/* Link change event */
 	if (int_status & LinkEvent) {
-		if (mii_wait_link (dev, 10) == 0) {
-			printk (KERN_INFO "%s: Link up\n", dev->name);
+		if (mii_wait_link(dev, 10) == 0) {
+			printk(KERN_INFO "%s: Link up\n", dev->name);
 			if (np->phy_media)
-				mii_get_media_pcs (dev);
+				mii_get_media_pcs(dev);
 			else
-				mii_get_media (dev);
+				mii_get_media(dev);
 			if (np->speed == 1000)
 				np->tx_coalesce = tx_coalesce;
 			else
@@ -1059,7 +1059,7 @@ rio_error (struct net_device *dev, int int_status)
 			np->link_status = 1;
 			netif_carrier_on(dev);
 		} else {
-			printk (KERN_INFO "%s: Link off\n", dev->name);
+			printk(KERN_INFO "%s: Link off\n", dev->name);
 			np->link_status = 0;
 			netif_carrier_off(dev);
 		}
@@ -1067,22 +1067,22 @@ rio_error (struct net_device *dev, int int_status)
 
 	/* UpdateStats statistics registers */
 	if (int_status & UpdateStats) {
-		get_stats (dev);
+		get_stats(dev);
 	}
 
 	/* PCI Error, a catastronphic error related to the bus interface
 	   occurs, set GlobalReset and HostReset to reset. */
 	if (int_status & HostError) {
-		printk (KERN_ERR "%s: HostError! IntStatus %4.4x.\n",
+		printk(KERN_ERR "%s: HostError! IntStatus %4.4x.\n",
 			dev->name, int_status);
 		dw16(ASICCtrl + 2, GlobalReset | HostReset);
-		mdelay (500);
+		mdelay(500);
 		rio_set_led_mode(dev);
 	}
 }
 
 static struct net_device_stats *
-get_stats (struct net_device *dev)
+get_stats(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->ioaddr;
@@ -1144,7 +1144,7 @@ get_stats (struct net_device *dev)
 }
 
 static int
-clear_stats (struct net_device *dev)
+clear_stats(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->ioaddr;
@@ -1200,7 +1200,7 @@ clear_stats (struct net_device *dev)
 
 
 static int
-change_mtu (struct net_device *dev, int new_mtu)
+change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	int max = (np->jumbo) ? MAX_JUMBO : 1536;
@@ -1215,7 +1215,7 @@ change_mtu (struct net_device *dev, int new_mtu)
 }
 
 static void
-set_multicast (struct net_device *dev)
+set_multicast(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->ioaddr;
@@ -1276,7 +1276,7 @@ static int rio_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if (np->phy_media) {
 		/* fiber device */
 		cmd->supported = SUPPORTED_Autoneg | SUPPORTED_FIBRE;
-		cmd->advertising= ADVERTISED_Autoneg | ADVERTISED_FIBRE;
+		cmd->advertising = ADVERTISED_Autoneg | ADVERTISED_FIBRE;
 		cmd->port = PORT_FIBRE;
 		cmd->transceiver = XCVR_INTERNAL;
 	} else {
@@ -1287,19 +1287,19 @@ static int rio_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			SUPPORTED_Autoneg | SUPPORTED_MII;
 		cmd->advertising = ADVERTISED_10baseT_Half |
 			ADVERTISED_10baseT_Full | ADVERTISED_100baseT_Half |
-			ADVERTISED_100baseT_Full | ADVERTISED_1000baseT_Full|
+			ADVERTISED_100baseT_Full | ADVERTISED_1000baseT_Full |
 			ADVERTISED_Autoneg | ADVERTISED_MII;
 		cmd->port = PORT_MII;
 		cmd->transceiver = XCVR_INTERNAL;
 	}
-	if ( np->link_status ) {
+	if (np->link_status) {
 		ethtool_cmd_speed_set(cmd, np->speed);
 		cmd->duplex = np->full_duplex ? DUPLEX_FULL : DUPLEX_HALF;
 	} else {
 		ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
 		cmd->duplex = DUPLEX_UNKNOWN;
 	}
-	if ( np->an_enable)
+	if (np->an_enable)
 		cmd->autoneg = AUTONEG_ENABLE;
 	else
 		cmd->autoneg = AUTONEG_DISABLE;
@@ -1359,7 +1359,7 @@ static const struct ethtool_ops ethtool_ops = {
 };
 
 static int
-rio_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
+rio_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	int phy_addr;
 	struct netdev_private *np = netdev_priv(dev);
@@ -1371,12 +1371,12 @@ rio_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
 		miidata->phy_id = phy_addr;
 		break;
 	case SIOCGMIIREG:
-		miidata->val_out = mii_read (dev, phy_addr, miidata->reg_num);
+		miidata->val_out = mii_read(dev, phy_addr, miidata->reg_num);
 		break;
 	case SIOCSMIIREG:
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
-		mii_write (dev, phy_addr, miidata->reg_num, miidata->val_in);
+		mii_write(dev, phy_addr, miidata->reg_num, miidata->val_in);
 		break;
 	default:
 		return -EOPNOTSUPP;
@@ -1408,20 +1408,20 @@ enum phy_ctrl_bits {
 
 #define mii_delay() dr8(PhyCtrl)
 static void
-mii_sendbit (struct net_device *dev, u32 data)
+mii_sendbit(struct net_device *dev, u32 data)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->ioaddr;
 
 	data = ((data) ? MII_DATA1 : 0) | (dr8(PhyCtrl) & 0xf8) | MII_WRITE;
 	dw8(PhyCtrl, data);
-	mii_delay ();
+	mii_delay();
 	dw8(PhyCtrl, data | MII_CLK);
-	mii_delay ();
+	mii_delay();
 }
 
 static int
-mii_getbit (struct net_device *dev)
+mii_getbit(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->ioaddr;
@@ -1429,67 +1429,67 @@ mii_getbit (struct net_device *dev)
 
 	data = (dr8(PhyCtrl) & 0xf8) | MII_READ;
 	dw8(PhyCtrl, data);
-	mii_delay ();
+	mii_delay();
 	dw8(PhyCtrl, data | MII_CLK);
-	mii_delay ();
+	mii_delay();
 	return (dr8(PhyCtrl) >> 1) & 1;
 }
 
 static void
-mii_send_bits (struct net_device *dev, u32 data, int len)
+mii_send_bits(struct net_device *dev, u32 data, int len)
 {
 	int i;
 
 	for (i = len - 1; i >= 0; i--) {
-		mii_sendbit (dev, data & (1 << i));
+		mii_sendbit(dev, data & (1 << i));
 	}
 }
 
 static int
-mii_read (struct net_device *dev, int phy_addr, int reg_num)
+mii_read(struct net_device *dev, int phy_addr, int reg_num)
 {
 	u32 cmd;
 	int i;
 	u32 retval = 0;
 
 	/* Preamble */
-	mii_send_bits (dev, 0xffffffff, 32);
+	mii_send_bits(dev, 0xffffffff, 32);
 	/* ST(2), OP(2), ADDR(5), REG#(5), TA(2), Data(16) total 32 bits */
 	/* ST,OP = 0110'b for read operation */
 	cmd = (0x06 << 10 | phy_addr << 5 | reg_num);
-	mii_send_bits (dev, cmd, 14);
+	mii_send_bits(dev, cmd, 14);
 	/* Turnaround */
-	if (mii_getbit (dev))
+	if (mii_getbit(dev))
 		goto err_out;
 	/* Read data */
 	for (i = 0; i < 16; i++) {
-		retval |= mii_getbit (dev);
+		retval |= mii_getbit(dev);
 		retval <<= 1;
 	}
 	/* End cycle */
-	mii_getbit (dev);
+	mii_getbit(dev);
 	return (retval >> 1) & 0xffff;
 
       err_out:
 	return 0;
 }
 static int
-mii_write (struct net_device *dev, int phy_addr, int reg_num, u16 data)
+mii_write(struct net_device *dev, int phy_addr, int reg_num, u16 data)
 {
 	u32 cmd;
 
 	/* Preamble */
-	mii_send_bits (dev, 0xffffffff, 32);
+	mii_send_bits(dev, 0xffffffff, 32);
 	/* ST(2), OP(2), ADDR(5), REG#(5), TA(2), Data(16) total 32 bits */
 	/* ST,OP,AAAAA,RRRRR,TA = 0101xxxxxxxxxx10'b = 0x5002 for write */
 	cmd = (0x5002 << 16) | (phy_addr << 23) | (reg_num << 18) | data;
-	mii_send_bits (dev, cmd, 32);
+	mii_send_bits(dev, cmd, 32);
 	/* End cycle */
-	mii_getbit (dev);
+	mii_getbit(dev);
 	return 0;
 }
 static int
-mii_wait_link (struct net_device *dev, int wait)
+mii_wait_link(struct net_device *dev, int wait)
 {
 	__u16 bmsr;
 	int phy_addr;
@@ -1499,15 +1499,15 @@ mii_wait_link (struct net_device *dev, int wait)
 	phy_addr = np->phy_addr;
 
 	do {
-		bmsr = mii_read (dev, phy_addr, MII_BMSR);
+		bmsr = mii_read(dev, phy_addr, MII_BMSR);
 		if (bmsr & BMSR_LSTATUS)
 			return 0;
-		mdelay (1);
+		mdelay(1);
 	} while (--wait > 0);
 	return -1;
 }
 static int
-mii_get_media (struct net_device *dev)
+mii_get_media(struct net_device *dev)
 {
 	__u16 negotiate;
 	__u16 bmsr;
@@ -1519,40 +1519,40 @@ mii_get_media (struct net_device *dev)
 	np = netdev_priv(dev);
 	phy_addr = np->phy_addr;
 
-	bmsr = mii_read (dev, phy_addr, MII_BMSR);
+	bmsr = mii_read(dev, phy_addr, MII_BMSR);
 	if (np->an_enable) {
 		if (!(bmsr & BMSR_ANEGCOMPLETE)) {
 			/* Auto-Negotiation not completed */
 			return -1;
 		}
-		negotiate = mii_read (dev, phy_addr, MII_ADVERTISE) &
-			mii_read (dev, phy_addr, MII_LPA);
-		mscr = mii_read (dev, phy_addr, MII_CTRL1000);
-		mssr = mii_read (dev, phy_addr, MII_STAT1000);
+		negotiate = mii_read(dev, phy_addr, MII_ADVERTISE) &
+			mii_read(dev, phy_addr, MII_LPA);
+		mscr = mii_read(dev, phy_addr, MII_CTRL1000);
+		mssr = mii_read(dev, phy_addr, MII_STAT1000);
 		if (mscr & ADVERTISE_1000FULL && mssr & LPA_1000FULL) {
 			np->speed = 1000;
 			np->full_duplex = 1;
-			printk (KERN_INFO "Auto 1000 Mbps, Full duplex\n");
+			printk(KERN_INFO "Auto 1000 Mbps, Full duplex\n");
 		} else if (mscr & ADVERTISE_1000HALF && mssr & LPA_1000HALF) {
 			np->speed = 1000;
 			np->full_duplex = 0;
-			printk (KERN_INFO "Auto 1000 Mbps, Half duplex\n");
+			printk(KERN_INFO "Auto 1000 Mbps, Half duplex\n");
 		} else if (negotiate & ADVERTISE_100FULL) {
 			np->speed = 100;
 			np->full_duplex = 1;
-			printk (KERN_INFO "Auto 100 Mbps, Full duplex\n");
+			printk(KERN_INFO "Auto 100 Mbps, Full duplex\n");
 		} else if (negotiate & ADVERTISE_100HALF) {
 			np->speed = 100;
 			np->full_duplex = 0;
-			printk (KERN_INFO "Auto 100 Mbps, Half duplex\n");
+			printk(KERN_INFO "Auto 100 Mbps, Half duplex\n");
 		} else if (negotiate & ADVERTISE_10FULL) {
 			np->speed = 10;
 			np->full_duplex = 1;
-			printk (KERN_INFO "Auto 10 Mbps, Full duplex\n");
+			printk(KERN_INFO "Auto 10 Mbps, Full duplex\n");
 		} else if (negotiate & ADVERTISE_10HALF) {
 			np->speed = 10;
 			np->full_duplex = 0;
-			printk (KERN_INFO "Auto 10 Mbps, Half duplex\n");
+			printk(KERN_INFO "Auto 10 Mbps, Half duplex\n");
 		}
 		if (negotiate & ADVERTISE_PAUSE_CAP) {
 			np->tx_flow &= 1;
@@ -1563,21 +1563,21 @@ mii_get_media (struct net_device *dev)
 		}
 		/* else tx_flow, rx_flow = user select  */
 	} else {
-		__u16 bmcr = mii_read (dev, phy_addr, MII_BMCR);
+		__u16 bmcr = mii_read(dev, phy_addr, MII_BMCR);
 		switch (bmcr & (BMCR_SPEED100 | BMCR_SPEED1000)) {
 		case BMCR_SPEED1000:
-			printk (KERN_INFO "Operating at 1000 Mbps, ");
+			printk(KERN_INFO "Operating at 1000 Mbps, ");
 			break;
 		case BMCR_SPEED100:
-			printk (KERN_INFO "Operating at 100 Mbps, ");
+			printk(KERN_INFO "Operating at 100 Mbps, ");
 			break;
 		case 0:
-			printk (KERN_INFO "Operating at 10 Mbps, ");
+			printk(KERN_INFO "Operating at 10 Mbps, ");
 		}
 		if (bmcr & BMCR_FULLDPLX) {
-			printk (KERN_CONT "Full duplex\n");
+			printk(KERN_CONT "Full duplex\n");
 		} else {
-			printk (KERN_CONT "Half duplex\n");
+			printk(KERN_CONT "Half duplex\n");
 		}
 	}
 	if (np->tx_flow)
@@ -1593,7 +1593,7 @@ mii_get_media (struct net_device *dev)
 }
 
 static int
-mii_set_media (struct net_device *dev)
+mii_set_media(struct net_device *dev)
 {
 	__u16 pscr;
 	__u16 bmcr;
@@ -1607,8 +1607,8 @@ mii_set_media (struct net_device *dev)
 	/* Does user set speed? */
 	if (np->an_enable) {
 		/* Advertise capabilities */
-		bmsr = mii_read (dev, phy_addr, MII_BMSR);
-		anar = mii_read (dev, phy_addr, MII_ADVERTISE) &
+		bmsr = mii_read(dev, phy_addr, MII_BMSR);
+		anar = mii_read(dev, phy_addr, MII_ADVERTISE) &
 			~(ADVERTISE_100FULL | ADVERTISE_10FULL |
 			  ADVERTISE_100HALF | ADVERTISE_10HALF |
 			  ADVERTISE_100BASE4);
@@ -1623,66 +1623,66 @@ mii_set_media (struct net_device *dev)
 		if (bmsr & BMSR_10HALF)
 			anar |= ADVERTISE_10HALF;
 		anar |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
-		mii_write (dev, phy_addr, MII_ADVERTISE, anar);
+		mii_write(dev, phy_addr, MII_ADVERTISE, anar);
 
 		/* Enable Auto crossover */
-		pscr = mii_read (dev, phy_addr, MII_PHY_SCR);
+		pscr = mii_read(dev, phy_addr, MII_PHY_SCR);
 		pscr |= 3 << 5;	/* 11'b */
-		mii_write (dev, phy_addr, MII_PHY_SCR, pscr);
+		mii_write(dev, phy_addr, MII_PHY_SCR, pscr);
 
 		/* Soft reset PHY */
-		mii_write (dev, phy_addr, MII_BMCR, BMCR_RESET);
+		mii_write(dev, phy_addr, MII_BMCR, BMCR_RESET);
 		bmcr = BMCR_ANENABLE | BMCR_ANRESTART | BMCR_RESET;
-		mii_write (dev, phy_addr, MII_BMCR, bmcr);
+		mii_write(dev, phy_addr, MII_BMCR, bmcr);
 		mdelay(1);
 	} else {
 		/* Force speed setting */
 		/* 1) Disable Auto crossover */
-		pscr = mii_read (dev, phy_addr, MII_PHY_SCR);
+		pscr = mii_read(dev, phy_addr, MII_PHY_SCR);
 		pscr &= ~(3 << 5);
-		mii_write (dev, phy_addr, MII_PHY_SCR, pscr);
+		mii_write(dev, phy_addr, MII_PHY_SCR, pscr);
 
 		/* 2) PHY Reset */
-		bmcr = mii_read (dev, phy_addr, MII_BMCR);
+		bmcr = mii_read(dev, phy_addr, MII_BMCR);
 		bmcr |= BMCR_RESET;
-		mii_write (dev, phy_addr, MII_BMCR, bmcr);
+		mii_write(dev, phy_addr, MII_BMCR, bmcr);
 
 		/* 3) Power Down */
 		bmcr = 0x1940;	/* must be 0x1940 */
-		mii_write (dev, phy_addr, MII_BMCR, bmcr);
-		mdelay (100);	/* wait a certain time */
+		mii_write(dev, phy_addr, MII_BMCR, bmcr);
+		mdelay(100);	/* wait a certain time */
 
 		/* 4) Advertise nothing */
-		mii_write (dev, phy_addr, MII_ADVERTISE, 0);
+		mii_write(dev, phy_addr, MII_ADVERTISE, 0);
 
 		/* 5) Set media and Power Up */
 		bmcr = BMCR_PDOWN;
 		if (np->speed == 100) {
 			bmcr |= BMCR_SPEED100;
-			printk (KERN_INFO "Manual 100 Mbps, ");
+			printk(KERN_INFO "Manual 100 Mbps, ");
 		} else if (np->speed == 10) {
-			printk (KERN_INFO "Manual 10 Mbps, ");
+			printk(KERN_INFO "Manual 10 Mbps, ");
 		}
 		if (np->full_duplex) {
 			bmcr |= BMCR_FULLDPLX;
-			printk (KERN_CONT "Full duplex\n");
+			printk(KERN_CONT "Full duplex\n");
 		} else {
-			printk (KERN_CONT "Half duplex\n");
+			printk(KERN_CONT "Half duplex\n");
 		}
 #if 0
 		/* Set 1000BaseT Master/Slave setting */
-		mscr = mii_read (dev, phy_addr, MII_CTRL1000);
+		mscr = mii_read(dev, phy_addr, MII_CTRL1000);
 		mscr |= MII_MSCR_CFG_ENABLE;
 		mscr &= ~MII_MSCR_CFG_VALUE = 0;
 #endif
-		mii_write (dev, phy_addr, MII_BMCR, bmcr);
+		mii_write(dev, phy_addr, MII_BMCR, bmcr);
 		mdelay(10);
 	}
 	return 0;
 }
 
 static int
-mii_get_media_pcs (struct net_device *dev)
+mii_get_media_pcs(struct net_device *dev)
 {
 	__u16 negotiate;
 	__u16 bmsr;
@@ -1692,20 +1692,20 @@ mii_get_media_pcs (struct net_device *dev)
 	np = netdev_priv(dev);
 	phy_addr = np->phy_addr;
 
-	bmsr = mii_read (dev, phy_addr, PCS_BMSR);
+	bmsr = mii_read(dev, phy_addr, PCS_BMSR);
 	if (np->an_enable) {
 		if (!(bmsr & BMSR_ANEGCOMPLETE)) {
 			/* Auto-Negotiation not completed */
 			return -1;
 		}
-		negotiate = mii_read (dev, phy_addr, PCS_ANAR) &
-			mii_read (dev, phy_addr, PCS_ANLPAR);
+		negotiate = mii_read(dev, phy_addr, PCS_ANAR) &
+			mii_read(dev, phy_addr, PCS_ANLPAR);
 		np->speed = 1000;
 		if (negotiate & PCS_ANAR_FULL_DUPLEX) {
-			printk (KERN_INFO "Auto 1000 Mbps, Full duplex\n");
+			printk(KERN_INFO "Auto 1000 Mbps, Full duplex\n");
 			np->full_duplex = 1;
 		} else {
-			printk (KERN_INFO "Auto 1000 Mbps, half duplex\n");
+			printk(KERN_INFO "Auto 1000 Mbps, half duplex\n");
 			np->full_duplex = 0;
 		}
 		if (negotiate & PCS_ANAR_PAUSE) {
@@ -1717,12 +1717,12 @@ mii_get_media_pcs (struct net_device *dev)
 		}
 		/* else tx_flow, rx_flow = user select  */
 	} else {
-		__u16 bmcr = mii_read (dev, phy_addr, PCS_BMCR);
-		printk (KERN_INFO "Operating at 1000 Mbps, ");
+		__u16 bmcr = mii_read(dev, phy_addr, PCS_BMCR);
+		printk(KERN_INFO "Operating at 1000 Mbps, ");
 		if (bmcr & BMCR_FULLDPLX) {
-			printk (KERN_CONT "Full duplex\n");
+			printk(KERN_CONT "Full duplex\n");
 		} else {
-			printk (KERN_CONT "Half duplex\n");
+			printk(KERN_CONT "Half duplex\n");
 		}
 	}
 	if (np->tx_flow)
@@ -1738,7 +1738,7 @@ mii_get_media_pcs (struct net_device *dev)
 }
 
 static int
-mii_set_media_pcs (struct net_device *dev)
+mii_set_media_pcs(struct net_device *dev)
 {
 	__u16 bmcr;
 	__u16 esr;
@@ -1751,8 +1751,8 @@ mii_set_media_pcs (struct net_device *dev)
 	/* Auto-Negotiation? */
 	if (np->an_enable) {
 		/* Advertise capabilities */
-		esr = mii_read (dev, phy_addr, PCS_ESR);
-		anar = mii_read (dev, phy_addr, MII_ADVERTISE) &
+		esr = mii_read(dev, phy_addr, PCS_ESR);
+		anar = mii_read(dev, phy_addr, MII_ADVERTISE) &
 			~PCS_ANAR_HALF_DUPLEX &
 			~PCS_ANAR_FULL_DUPLEX;
 		if (esr & (MII_ESR_1000BT_HD | MII_ESR_1000BX_HD))
@@ -1760,48 +1760,48 @@ mii_set_media_pcs (struct net_device *dev)
 		if (esr & (MII_ESR_1000BT_FD | MII_ESR_1000BX_FD))
 			anar |= PCS_ANAR_FULL_DUPLEX;
 		anar |= PCS_ANAR_PAUSE | PCS_ANAR_ASYMMETRIC;
-		mii_write (dev, phy_addr, MII_ADVERTISE, anar);
+		mii_write(dev, phy_addr, MII_ADVERTISE, anar);
 
 		/* Soft reset PHY */
-		mii_write (dev, phy_addr, MII_BMCR, BMCR_RESET);
+		mii_write(dev, phy_addr, MII_BMCR, BMCR_RESET);
 		bmcr = BMCR_ANENABLE | BMCR_ANRESTART | BMCR_RESET;
-		mii_write (dev, phy_addr, MII_BMCR, bmcr);
+		mii_write(dev, phy_addr, MII_BMCR, bmcr);
 		mdelay(1);
 	} else {
 		/* Force speed setting */
 		/* PHY Reset */
 		bmcr = BMCR_RESET;
-		mii_write (dev, phy_addr, MII_BMCR, bmcr);
+		mii_write(dev, phy_addr, MII_BMCR, bmcr);
 		mdelay(10);
 		if (np->full_duplex) {
 			bmcr = BMCR_FULLDPLX;
-			printk (KERN_INFO "Manual full duplex\n");
+			printk(KERN_INFO "Manual full duplex\n");
 		} else {
 			bmcr = 0;
-			printk (KERN_INFO "Manual half duplex\n");
+			printk(KERN_INFO "Manual half duplex\n");
 		}
-		mii_write (dev, phy_addr, MII_BMCR, bmcr);
+		mii_write(dev, phy_addr, MII_BMCR, bmcr);
 		mdelay(10);
 
 		/*  Advertise nothing */
-		mii_write (dev, phy_addr, MII_ADVERTISE, 0);
+		mii_write(dev, phy_addr, MII_ADVERTISE, 0);
 	}
 	return 0;
 }
 
 
 static int
-rio_close (struct net_device *dev)
+rio_close(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	struct pci_dev *pdev = np->pdev;
 
-	netif_stop_queue (dev);
+	netif_stop_queue(dev);
 
 	rio_hw_stop(dev);
 
 	free_irq(pdev->irq, dev);
-	del_timer_sync (&np->timer);
+	del_timer_sync(&np->timer);
 
 	free_list(dev);
 
@@ -1809,25 +1809,25 @@ rio_close (struct net_device *dev)
 }
 
 static void
-rio_remove1 (struct pci_dev *pdev)
+rio_remove1(struct pci_dev *pdev)
 {
-	struct net_device *dev = pci_get_drvdata (pdev);
+	struct net_device *dev = pci_get_drvdata(pdev);
 
 	if (dev) {
 		struct netdev_private *np = netdev_priv(dev);
 
-		unregister_netdev (dev);
-		pci_free_consistent (pdev, RX_TOTAL_SIZE, np->rx_ring,
-				     np->rx_ring_dma);
-		pci_free_consistent (pdev, TX_TOTAL_SIZE, np->tx_ring,
-				     np->tx_ring_dma);
+		unregister_netdev(dev);
+		pci_free_consistent(pdev, RX_TOTAL_SIZE, np->rx_ring,
+				    np->rx_ring_dma);
+		pci_free_consistent(pdev, TX_TOTAL_SIZE, np->tx_ring,
+				    np->tx_ring_dma);
 #ifdef MEM_MAPPING
 		pci_iounmap(pdev, np->ioaddr);
 #endif
 		pci_iounmap(pdev, np->eeprom_addr);
-		free_netdev (dev);
-		pci_release_regions (pdev);
-		pci_disable_device (pdev);
+		free_netdev(dev);
+		pci_release_regions(pdev);
+		pci_disable_device(pdev);
 	}
 }
 
@@ -1892,4 +1892,3 @@ gcc -D__KERNEL__ -DMODULE -I/usr/src/linux/include -Wall -Wstrict-prototypes -O2
 Read Documentation/networking/dl2k.txt for details.
 
 */
-
-- 
2.7.1.1.g3617aa0
