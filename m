From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 17/30] solos: Remove unused loopback debug stuff
Date: Tue, 17 Mar 2009 21:29:29 +0000
Message-ID: <1237325369.27681.346.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37665 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758077AbZCQV3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:35 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgqr-0001vl-KK
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:33 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |   23 -----------------------
 1 files changed, 0 insertions(+), 23 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index bf59c40..2ef8157 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -70,7 +70,6 @@
 
 #define RX_DMA_SIZE	2048
 
-static int debug = 0;
 static int atmdebug = 0;
 static int firmware_upgrade = 0;
 static int fpga_upgrade = 0;
@@ -133,11 +132,9 @@ MODULE_AUTHOR("Traverse Technologies <support@traverse.com.au>");
 MODULE_DESCRIPTION("Solos PCI driver");
 MODULE_VERSION(VERSION);
 MODULE_LICENSE("GPL");
-MODULE_PARM_DESC(debug, "Enable Loopback");
 MODULE_PARM_DESC(atmdebug, "Print ATM data");
 MODULE_PARM_DESC(firmware_upgrade, "Initiate Solos firmware upgrade");
 MODULE_PARM_DESC(fpga_upgrade, "Initiate FPGA upgrade");
-module_param(debug, int, 0444);
 module_param(atmdebug, int, 0644);
 module_param(firmware_upgrade, int, 0444);
 module_param(fpga_upgrade, int, 0444);
@@ -974,26 +971,12 @@ static int fpga_tx(struct solos_card *card)
 static int psend(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	struct solos_card *card = vcc->dev->dev_data;
-	struct sk_buff *skb2 = NULL;
 	struct pkt_hdr *header;
 	int pktlen;
 
 	//dev_dbg(&card->dev->dev, "psend called.\n");
 	//dev_dbg(&card->dev->dev, "dev,vpi,vci = %d,%d,%d\n",SOLOS_CHAN(vcc->dev),vcc->vpi,vcc->vci);
 
-	if (debug) {
-		skb2 = atm_alloc_charge(vcc, skb->len, GFP_ATOMIC);
-		if (skb2) {
-			memcpy(skb2->data, skb->data, skb->len);
-			skb_put(skb2, skb->len);
-			vcc->push(vcc, skb2);
-			atomic_inc(&vcc->stats->rx);
-		}
-		atomic_inc(&vcc->stats->tx);
-		solos_pop(vcc, skb);
-		return 0;
-	}
-
 	pktlen = skb->len;
 	if (pktlen > (BUF_SIZE - sizeof(*header))) {
 		dev_warn(&card->dev->dev, "Length of PDU is too large. Dropping PDU.\n");
@@ -1052,9 +1035,6 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 	uint32_t data32;
 	struct solos_card *card;
 
-	if (debug)
-		return 0;
-
 	card = kzalloc(sizeof(*card), GFP_KERNEL);
 	if (!card)
 		return -ENOMEM;
@@ -1256,9 +1236,6 @@ static void fpga_remove(struct pci_dev *dev)
 {
 	struct solos_card *card = pci_get_drvdata(dev);
 
-	if (debug)
-		return;
-
 	atm_remove(card);
 
 	dev_vdbg(&dev->dev, "Freeing IRQ\n");
-- 
1.6.0.6


