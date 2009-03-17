From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 22/30] solos: Remove debugging, commented-out test code
Date: Tue, 17 Mar 2009 21:29:32 +0000
Message-ID: <1237325372.27681.351.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37670 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758297AbZCQV3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:42 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgqy-0001w0-GR
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:40 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |   52 ++--------------------------------------------
 1 files changed, 3 insertions(+), 49 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index e7691b3..21c73b1 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -813,8 +813,7 @@ static int popen(struct atm_vcc *vcc)
 
 	fpga_queue(card, SOLOS_CHAN(vcc->dev), skb, NULL);
 
-//	dev_dbg(&card->dev->dev, "Open for vpi %d and vci %d on interface %d\n", vcc->vpi, vcc->vci, SOLOS_CHAN(vcc->dev));
-	set_bit(ATM_VF_ADDR, &vcc->flags); // accept the vpi / vci
+	set_bit(ATM_VF_ADDR, &vcc->flags);
 	set_bit(ATM_VF_READY, &vcc->flags);
 	list_vccs(0);
 
@@ -842,8 +841,6 @@ static void pclose(struct atm_vcc *vcc)
 
 	fpga_queue(card, SOLOS_CHAN(vcc->dev), skb, NULL);
 
-//	dev_dbg(&card->dev->dev, "Close for vpi %d and vci %d on interface %d\n", vcc->vpi, vcc->vci, SOLOS_CHAN(vcc->dev));
-
 	clear_bit(ATM_VF_ADDR, &vcc->flags);
 	clear_bit(ATM_VF_READY, &vcc->flags);
 
@@ -936,7 +933,7 @@ static uint32_t fpga_tx(struct solos_card *card)
 
 			if (skb && !card->using_dma) {
 				memcpy_toio(TX_BUF(card, port), skb->data, skb->len);
-				tx_started |= 1 << port; //Set TX full flag
+				tx_started |= 1 << port;
 				oldskb = skb; /* We're done with this skb already */
 			} else if (skb && card->using_dma) {
 				SKB_CB(skb)->dma_addr = pci_map_single(card->dev, skb->data,
@@ -965,10 +962,10 @@ static uint32_t fpga_tx(struct solos_card *card)
 
 		}
 	}
+	/* For non-DMA TX, write the 'TX start' bit for all four ports simultaneously */
 	if (tx_started)
 		iowrite32(tx_started, card->config_regs + FLAGS_ADDR);
 
- out:
 	spin_unlock_irqrestore(&card->tx_lock, flags);
 	return card_flags;
 }
@@ -979,9 +976,6 @@ static int psend(struct atm_vcc *vcc, struct sk_buff *skb)
 	struct pkt_hdr *header;
 	int pktlen;
 
-	//dev_dbg(&card->dev->dev, "psend called.\n");
-	//dev_dbg(&card->dev->dev, "dev,vpi,vci = %d,%d,%d\n",SOLOS_CHAN(vcc->dev),vcc->vpi,vcc->vci);
-
 	pktlen = skb->len;
 	if (pktlen > (BUF_SIZE - sizeof(*header))) {
 		dev_warn(&card->dev->dev, "Length of PDU is too large. Dropping PDU.\n");
@@ -1077,11 +1071,6 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 		goto out_unmap_config;
 	}
 
-//	for(i=0;i<64 ;i+=4){
-//		data32=ioread32(card->buffers + i);
-//		dev_dbg(&card->dev->dev, "%08lX\n",(unsigned long)data32);
-//	}
-
 	//Fill Config Mem with zeros
 	for(i = 0; i < 128; i += 4)
 		iowrite32(0, card->config_regs + i);
@@ -1110,33 +1099,6 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 	spin_lock_init(&card->param_queue_lock);
 	INIT_LIST_HEAD(&card->param_queue);
 
-/*
-	// Set Loopback mode
-	data32 = 0x00010000;
-	iowrite32(data32,card->config_regs + FLAGS_ADDR);
-*/
-/*
-	// Fill Buffers with zeros
-	for (i = 0; i < BUF_SIZE * 8; i += 4)
-		iowrite32(0, card->buffers + i);
-*/
-/*
-	for(i = 0; i < (BUF_SIZE * 1); i += 4)
-		iowrite32(0x12345678, card->buffers + i + (0*BUF_SIZE));
-	for(i = 0; i < (BUF_SIZE * 1); i += 4)
-		iowrite32(0xabcdef98, card->buffers + i + (1*BUF_SIZE));
-
-	// Read Config Memory
-	printk(KERN_DEBUG "Reading Config MEM\n");
-	i = 0;
-	for(i = 0; i < 16; i++) {
-		data32=ioread32(card->buffers + i*(BUF_SIZE/2));
-		printk(KERN_ALERT "Addr: %lX Data: %08lX\n",
-		       (unsigned long)(addr_start + i*(BUF_SIZE/2)),
-		       (unsigned long)data32);
-	}
-*/
-	//dev_dbg(&card->dev->dev, "Requesting IRQ: %d\n",dev->irq);
 	err = request_irq(dev->irq, solos_irq, IRQF_SHARED,
 			  "solos-pci", card);
 	if (err) {
@@ -1144,7 +1106,6 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 		goto out_unmap_both;
 	}
 
-	// Enable IRQs
 	iowrite32(1, card->config_regs + IRQ_EN_ADDR);
 
 	if (fpga_upgrade)
@@ -1243,25 +1204,18 @@ static void fpga_remove(struct pci_dev *dev)
 
 	atm_remove(card);
 
-	dev_vdbg(&dev->dev, "Freeing IRQ\n");
-	// Disable IRQs from FPGA
 	iowrite32(0, card->config_regs + IRQ_EN_ADDR);
 	free_irq(dev->irq, card);
 	tasklet_kill(&card->tlet);
 
-	//	iowrite32(0x01,pciregs);
-	dev_vdbg(&dev->dev, "Unmapping PCI resource\n");
 	pci_iounmap(dev, card->buffers);
 	pci_iounmap(dev, card->config_regs);
 
-	dev_vdbg(&dev->dev, "Releasing PCI Region\n");
 	pci_release_regions(dev);
 	pci_disable_device(dev);
 
 	pci_set_drvdata(dev, NULL);
 	kfree(card);
-//	dev_dbg(&card->dev->dev, "fpga_remove\n");
-	return;
 }
 
 static struct pci_device_id fpga_pci_tbl[] __devinitdata = {
-- 
1.6.0.6


