From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 05/30] solos: Kill global 'opens' count.
Date: Tue, 17 Mar 2009 21:29:13 +0000
Message-ID: <1237325353.27681.334.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37653 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757469AbZCQV3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:18 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgqa-0001ur-90
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:16 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 89bdf73..5179dbf 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -111,8 +111,6 @@ module_param(atmdebug, int, 0644);
 module_param(firmware_upgrade, int, 0444);
 module_param(fpga_upgrade, int, 0444);
 
-static int opens;
-
 static void fpga_queue(struct solos_card *card, int port, struct sk_buff *skb,
 		       struct atm_vcc *vcc);
 static int fpga_tx(struct solos_card *);
@@ -455,10 +453,6 @@ static int popen(struct atm_vcc *vcc)
 	set_bit(ATM_VF_READY, &vcc->flags);
 	list_vccs(0);
 
-	if (!opens)
-		iowrite32(1, card->config_regs + IRQ_EN_ADDR);
-
-	opens++; //count open PVCs
 
 	return 0;
 }
@@ -484,8 +478,6 @@ static void pclose(struct atm_vcc *vcc)
 	fpga_queue(card, SOLOS_CHAN(vcc->dev), skb, NULL);
 
 //	dev_dbg(&card->dev->dev, "Close for vpi %d and vci %d on interface %d\n", vcc->vpi, vcc->vci, SOLOS_CHAN(vcc->dev));
-	if (!--opens)
-		iowrite32(0, card->config_regs + IRQ_EN_ADDR);
 
 	clear_bit(ATM_VF_ADDR, &vcc->flags);
 	clear_bit(ATM_VF_READY, &vcc->flags);
@@ -800,8 +792,6 @@ static int atm_init(struct solos_card *card)
 {
 	int i;
 
-	opens = 0;
-
 	for (i = 0; i < card->nr_ports; i++) {
 		skb_queue_head_init(&card->tx_queue[i]);
 		skb_queue_head_init(&card->cli_queue[i]);
-- 
1.6.0.6


