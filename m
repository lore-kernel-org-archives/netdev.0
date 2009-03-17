From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 18/30] solos: Remove IRQF_DISABLED, don't frob IRQ enable
 on the FPGA in solos_irq()
Date: Tue, 17 Mar 2009 21:29:29 +0000
Message-ID: <1237325369.27681.347.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37666 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758206AbZCQV3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:37 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgqs-0001vo-W5
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:35 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neither of these are necessary.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 2ef8157..f2736dd 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -570,16 +570,12 @@ static irqreturn_t solos_irq(int irq, void *dev_id)
 
 	//ACK IRQ
 	iowrite32(0, card->config_regs + IRQ_CLEAR);
-	//Disable IRQs from FPGA
-	iowrite32(0, card->config_regs + IRQ_EN_ADDR);
 
 	if (card->atmdev[0])
 		tasklet_schedule(&card->tlet);
 	else
 		wake_up(&card->fw_wq);
 
-	//Enable IRQs from FPGA
-	iowrite32(1, card->config_regs + IRQ_EN_ADDR);
 	return IRQ_RETVAL(handled);
 }
 
@@ -1132,7 +1128,7 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 	}
 */
 	//dev_dbg(&card->dev->dev, "Requesting IRQ: %d\n",dev->irq);
-	err = request_irq(dev->irq, solos_irq, IRQF_DISABLED|IRQF_SHARED,
+	err = request_irq(dev->irq, solos_irq, IRQF_SHARED,
 			  "solos-pci", card);
 	if (err) {
 		dev_dbg(&card->dev->dev, "Failed to request interrupt IRQ: %d\n", dev->irq);
-- 
1.6.0.6


