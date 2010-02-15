From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 7/7] drivers/net/pcnet32.c: Checkpatch cleaning
Date: Mon, 15 Feb 2010 10:34:26 -0800
Message-ID: <a522406b98e927e6a12836405badc845b8c72ec6.1266258417.git.joe@perches.com>
References: <cover.1266258417.git.joe@perches.com>
Cc: Don Fry <pcnet32@verizon.net>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1266258417.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/pcnet32.c |  153 +++++++++++++++++++++++-------------------------
 1 files changed, 73 insertions(+), 80 deletions(-)

diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 9194abc..63e0315 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -52,10 +52,10 @@ static const char *const version =
 #include <linux/spinlock.h>
 #include <linux/moduleparam.h>
 #include <linux/bitops.h>
+#include <linux/io.h>
+#include <linux/uaccess.h>
 
 #include <asm/dma.h>
-#include <asm/io.h>
-#include <asm/uaccess.h>
 #include <asm/irq.h>
 
 /*
@@ -85,7 +85,7 @@ static int cards_found;
 static unsigned int pcnet32_portlist[] __initdata =
     { 0x300, 0x320, 0x340, 0x360, 0 };
 
-static int pcnet32_debug = 0;
+static int pcnet32_debug;
 static int tx_start = 1;	/* Mapping -- 0:20, 1:64, 2:128, 3:~220 (depends on chip vers) */
 static int pcnet32vlb;		/* check for VLB cards ? */
 
@@ -392,7 +392,7 @@ static struct pcnet32_access pcnet32_wio = {
 static u16 pcnet32_dwio_read_csr(unsigned long addr, int index)
 {
 	outl(index, addr + PCNET32_DWIO_RAP);
-	return (inl(addr + PCNET32_DWIO_RDP) & 0xffff);
+	return inl(addr + PCNET32_DWIO_RDP) & 0xffff;
 }
 
 static void pcnet32_dwio_write_csr(unsigned long addr, int index, u16 val)
@@ -404,7 +404,7 @@ static void pcnet32_dwio_write_csr(unsigned long addr, int index, u16 val)
 static u16 pcnet32_dwio_read_bcr(unsigned long addr, int index)
 {
 	outl(index, addr + PCNET32_DWIO_RAP);
-	return (inl(addr + PCNET32_DWIO_BDP) & 0xffff);
+	return inl(addr + PCNET32_DWIO_BDP) & 0xffff;
 }
 
 static void pcnet32_dwio_write_bcr(unsigned long addr, int index, u16 val)
@@ -415,7 +415,7 @@ static void pcnet32_dwio_write_bcr(unsigned long addr, int index, u16 val)
 
 static u16 pcnet32_dwio_read_rap(unsigned long addr)
 {
-	return (inl(addr + PCNET32_DWIO_RAP) & 0xffff);
+	return inl(addr + PCNET32_DWIO_RAP) & 0xffff;
 }
 
 static void pcnet32_dwio_write_rap(unsigned long addr, u16 val)
@@ -524,15 +524,14 @@ static void pcnet32_realloc_tx_ring(struct net_device *dev,
 	lp->tx_skbuff = new_skb_list;
 	return;
 
-    free_new_lists:
+free_new_lists:
 	kfree(new_dma_addr_list);
-    free_new_tx_ring:
+free_new_tx_ring:
 	pci_free_consistent(lp->pci_dev,
 			    sizeof(struct pcnet32_tx_head) *
 			    (1 << size),
 			    new_tx_ring,
 			    new_ring_dma_addr);
-	return;
 }
 
 /*
@@ -587,10 +586,11 @@ static void pcnet32_realloc_rx_ring(struct net_device *dev,
 		new_skb_list[new] = lp->rx_skbuff[new];
 	}
 	/* now allocate any new buffers needed */
-	for (; new < size; new++ ) {
+	for (; new < size; new++) {
 		struct sk_buff *rx_skbuff;
 		new_skb_list[new] = dev_alloc_skb(PKT_BUF_SKB);
-		if (!(rx_skbuff = new_skb_list[new])) {
+		rx_skbuff = new_skb_list[new];
+		if (!rx_skbuff) {
 			/* keep the original lists and buffers */
 			netif_err(lp, drv, dev, "%s dev_alloc_skb failed\n",
 				  __func__);
@@ -630,8 +630,8 @@ static void pcnet32_realloc_rx_ring(struct net_device *dev,
 	lp->rx_skbuff = new_skb_list;
 	return;
 
-    free_all_new:
-	for (; --new >= lp->rx_ring_size; ) {
+free_all_new:
+	while (--new >= lp->rx_ring_size) {
 		if (new_skb_list[new]) {
 			pci_unmap_single(lp->pci_dev, new_dma_addr_list[new],
 					 PKT_BUF_SIZE, PCI_DMA_FROMDEVICE);
@@ -639,9 +639,9 @@ static void pcnet32_realloc_rx_ring(struct net_device *dev,
 		}
 	}
 	kfree(new_skb_list);
-    free_new_lists:
+free_new_lists:
 	kfree(new_dma_addr_list);
-    free_new_rx_ring:
+free_new_rx_ring:
 	pci_free_consistent(lp->pci_dev,
 			    sizeof(struct pcnet32_rx_head) *
 			    (1 << size),
@@ -831,7 +831,7 @@ static int pcnet32_set_ringparam(struct net_device *dev,
 }
 
 static void pcnet32_get_strings(struct net_device *dev, u32 stringset,
-				u8 * data)
+				u8 *data)
 {
 	memcpy(data, pcnet32_gstrings_test, sizeof(pcnet32_gstrings_test));
 }
@@ -908,39 +908,39 @@ static int pcnet32_loopback_test(struct net_device *dev, uint64_t * data1)
 	/* Initialize Transmit buffers. */
 	size = data_len + 15;
 	for (x = 0; x < numbuffs; x++) {
-		if (!(skb = dev_alloc_skb(size))) {
+		skb = dev_alloc_skb(size);
+		if (!skb) {
 			netif_printk(lp, hw, KERN_DEBUG, dev,
 				     "Cannot allocate skb at line: %d!\n",
 				     __LINE__);
 			goto clean_up;
-		} else {
-			packet = skb->data;
-			skb_put(skb, size);	/* create space for data */
-			lp->tx_skbuff[x] = skb;
-			lp->tx_ring[x].length = cpu_to_le16(-skb->len);
-			lp->tx_ring[x].misc = 0;
-
-			/* put DA and SA into the skb */
-			for (i = 0; i < 6; i++)
-				*packet++ = dev->dev_addr[i];
-			for (i = 0; i < 6; i++)
-				*packet++ = dev->dev_addr[i];
-			/* type */
-			*packet++ = 0x08;
-			*packet++ = 0x06;
-			/* packet number */
-			*packet++ = x;
-			/* fill packet with data */
-			for (i = 0; i < data_len; i++)
-				*packet++ = i;
-
-			lp->tx_dma_addr[x] =
-			    pci_map_single(lp->pci_dev, skb->data, skb->len,
-					   PCI_DMA_TODEVICE);
-			lp->tx_ring[x].base = cpu_to_le32(lp->tx_dma_addr[x]);
-			wmb();	/* Make sure owner changes after all others are visible */
-			lp->tx_ring[x].status = cpu_to_le16(status);
 		}
+		packet = skb->data;
+		skb_put(skb, size);	/* create space for data */
+		lp->tx_skbuff[x] = skb;
+		lp->tx_ring[x].length = cpu_to_le16(-skb->len);
+		lp->tx_ring[x].misc = 0;
+
+		/* put DA and SA into the skb */
+		for (i = 0; i < 6; i++)
+			*packet++ = dev->dev_addr[i];
+		for (i = 0; i < 6; i++)
+			*packet++ = dev->dev_addr[i];
+		/* type */
+		*packet++ = 0x08;
+		*packet++ = 0x06;
+		/* packet number */
+		*packet++ = x;
+		/* fill packet with data */
+		for (i = 0; i < data_len; i++)
+			*packet++ = i;
+
+		lp->tx_dma_addr[x] =
+			pci_map_single(lp->pci_dev, skb->data, skb->len,
+				       PCI_DMA_TODEVICE);
+		lp->tx_ring[x].base = cpu_to_le32(lp->tx_dma_addr[x]);
+		wmb();	/* Make sure owner changes after all others are visible */
+		lp->tx_ring[x].status = cpu_to_le16(status);
 	}
 
 	x = a->read_bcr(ioaddr, 32);	/* set internal loopback in BCR32 */
@@ -978,9 +978,8 @@ static int pcnet32_loopback_test(struct net_device *dev, uint64_t * data1)
 		for (x = 0; x < numbuffs; x++) {
 			netdev_printk(KERN_DEBUG, dev, "Packet %d: ", x);
 			skb = lp->rx_skbuff[x];
-			for (i = 0; i < size; i++) {
+			for (i = 0; i < size; i++)
 				pr_cont(" %02x", *(skb->data + i));
-			}
 			pr_cont("\n");
 		}
 	}
@@ -1002,7 +1001,7 @@ static int pcnet32_loopback_test(struct net_device *dev, uint64_t * data1)
 		x++;
 	}
 
-      clean_up:
+clean_up:
 	*data1 = rc;
 	pcnet32_purge_tx_ring(dev);
 
@@ -1021,7 +1020,7 @@ static int pcnet32_loopback_test(struct net_device *dev, uint64_t * data1)
 	}
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-	return (rc);
+	return rc;
 }				/* end pcnet32_loopback_test  */
 
 static void pcnet32_led_blink_callback(struct net_device *dev)
@@ -1033,9 +1032,8 @@ static void pcnet32_led_blink_callback(struct net_device *dev)
 	int i;
 
 	spin_lock_irqsave(&lp->lock, flags);
-	for (i = 4; i < 8; i++) {
+	for (i = 4; i < 8; i++)
 		a->write_bcr(ioaddr, i, a->read_bcr(ioaddr, i) ^ 0x4000);
-	}
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	mod_timer(&lp->blink_timer, PCNET32_BLINK_TIMEOUT);
@@ -1057,9 +1055,8 @@ static int pcnet32_phys_id(struct net_device *dev, u32 data)
 
 	/* Save the current value of the bcrs */
 	spin_lock_irqsave(&lp->lock, flags);
-	for (i = 4; i < 8; i++) {
+	for (i = 4; i < 8; i++)
 		regs[i - 4] = a->read_bcr(ioaddr, i);
-	}
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	mod_timer(&lp->blink_timer, jiffies);
@@ -1074,9 +1071,8 @@ static int pcnet32_phys_id(struct net_device *dev, u32 data)
 
 	/* Restore the original value of the bcrs */
 	spin_lock_irqsave(&lp->lock, flags);
-	for (i = 4; i < 8; i++) {
+	for (i = 4; i < 8; i++)
 		a->write_bcr(ioaddr, i, regs[i - 4]);
-	}
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	return 0;
@@ -1173,7 +1169,8 @@ static void pcnet32_rx_entry(struct net_device *dev,
 	if (pkt_len > rx_copybreak) {
 		struct sk_buff *newskb;
 
-		if ((newskb = dev_alloc_skb(PKT_BUF_SKB))) {
+		newskb = dev_alloc_skb(PKT_BUF_SKB);
+		if (newskb) {
 			skb_reserve(newskb, NET_IP_ALIGN);
 			skb = lp->rx_skbuff[entry];
 			pci_unmap_single(lp->pci_dev,
@@ -1191,9 +1188,8 @@ static void pcnet32_rx_entry(struct net_device *dev,
 			rx_in_place = 1;
 		} else
 			skb = NULL;
-	} else {
+	} else
 		skb = dev_alloc_skb(pkt_len + NET_IP_ALIGN);
-	}
 
 	if (skb == NULL) {
 		netif_err(lp, drv, dev, "Memory squeeze, dropping packet\n");
@@ -1380,7 +1376,7 @@ static int pcnet32_get_regs_len(struct net_device *dev)
 	struct pcnet32_private *lp = netdev_priv(dev);
 	int j = lp->phycount * PCNET32_REGS_PER_PHY;
 
-	return ((PCNET32_NUM_REGS + j) * sizeof(u16));
+	return (PCNET32_NUM_REGS + j) * sizeof(u16);
 }
 
 static void pcnet32_get_regs(struct net_device *dev, struct ethtool_regs *regs,
@@ -1404,21 +1400,20 @@ static void pcnet32_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		*buff++ = inw(ioaddr + i);
 
 	/* read control and status registers */
-	for (i = 0; i < 90; i++) {
+	for (i = 0; i < 90; i++)
 		*buff++ = a->read_csr(ioaddr, i);
-	}
 
 	*buff++ = a->read_csr(ioaddr, 112);
 	*buff++ = a->read_csr(ioaddr, 114);
 
 	/* read bus configuration registers */
-	for (i = 0; i < 30; i++) {
+	for (i = 0; i < 30; i++)
 		*buff++ = a->read_bcr(ioaddr, i);
-	}
+
 	*buff++ = 0;		/* skip bcr30 so as not to hang 79C976 */
-	for (i = 31; i < 36; i++) {
+
+	for (i = 31; i < 36; i++)
 		*buff++ = a->read_bcr(ioaddr, i);
-	}
 
 	/* read mii phy registers */
 	if (lp->mii) {
@@ -1511,17 +1506,16 @@ pcnet32_probe_pci(struct pci_dev *pdev, const struct pci_device_id *ent)
 			pr_err("architecture does not support 32bit PCI busmaster DMA\n");
 		return -ENODEV;
 	}
-	if (request_region(ioaddr, PCNET32_TOTAL_SIZE, "pcnet32_probe_pci") ==
-	    NULL) {
+	if (!request_region(ioaddr, PCNET32_TOTAL_SIZE, "pcnet32_probe_pci")) {
 		if (pcnet32_debug & NETIF_MSG_PROBE)
 			pr_err("io address range already allocated\n");
 		return -EBUSY;
 	}
 
 	err = pcnet32_probe1(ioaddr, 1, pdev);
-	if (err < 0) {
+	if (err < 0)
 		pci_disable_device(pdev);
-	}
+
 	return err;
 }
 
@@ -1764,8 +1758,9 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	dev->base_addr = ioaddr;
 	lp = netdev_priv(dev);
 	/* pci_alloc_consistent returns page-aligned memory, so we do not have to check the alignment */
-	if ((lp->init_block =
-	     pci_alloc_consistent(pdev, sizeof(*lp->init_block), &lp->init_dma_addr)) == NULL) {
+	lp->init_block = pci_alloc_consistent(pdev, sizeof(*lp->init_block),
+					      &lp->init_dma_addr);
+	if (!lp->init_block) {
 		if (pcnet32_debug & NETIF_MSG_PROBE)
 			pr_err("Consistent memory allocation failed\n");
 		ret = -ENOMEM;
@@ -1890,9 +1885,8 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 					id1, id2, i);
 		}
 		lp->a.write_bcr(ioaddr, 33, (lp->mii_if.phy_id) << 5);
-		if (lp->phycount > 1) {
+		if (lp->phycount > 1)
 			lp->options |= PCNET32_PORT_MII;
-		}
 	}
 
 	init_timer(&lp->watchdog_timer);
@@ -2236,7 +2230,7 @@ static int pcnet32_open(struct net_device *dev)
 
 	return 0;		/* Always succeed */
 
-      err_free_ring:
+err_free_ring:
 	/* free any allocated skbuffs */
 	pcnet32_purge_rx_ring(dev);
 
@@ -2246,7 +2240,7 @@ static int pcnet32_open(struct net_device *dev)
 	 */
 	lp->a.write_bcr(ioaddr, 20, 4);
 
-      err_free_irq:
+err_free_irq:
 	spin_unlock_irqrestore(&lp->lock, flags);
 	free_irq(dev->irq, dev);
 	return rc;
@@ -2297,10 +2291,10 @@ static int pcnet32_init_ring(struct net_device *dev)
 	for (i = 0; i < lp->rx_ring_size; i++) {
 		struct sk_buff *rx_skbuff = lp->rx_skbuff[i];
 		if (rx_skbuff == NULL) {
-			if (!
-			    (rx_skbuff = lp->rx_skbuff[i] =
-			     dev_alloc_skb(PKT_BUF_SKB))) {
-				/* there is not much, we can do at this point */
+			lp->rx_skbuff[i] = dev_alloc_skb(PKT_BUF_SKB);
+			rx_skbuff = lp->rx_skbuff[i];
+			if (!rx_skbuff) {
+				/* there is not much we can do at this point */
 				netif_err(lp, drv, dev, "%s dev_alloc_skb failed\n",
 					  __func__);
 				return -1;
@@ -2482,9 +2476,8 @@ pcnet32_interrupt(int irq, void *dev_id)
 
 	csr0 = lp->a.read_csr(ioaddr, CSR0);
 	while ((csr0 & 0x8f00) && --boguscnt >= 0) {
-		if (csr0 == 0xffff) {
+		if (csr0 == 0xffff)
 			break;	/* PCMCIA remove happened */
-		}
 		/* Acknowledge all of the current interrupt sources ASAP. */
 		lp->a.write_csr(ioaddr, CSR0, csr0 & ~0x004f);
 
-- 
1.7.0.14.g7e948
