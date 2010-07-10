From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH net-next-2.6][atm]: remove IRQF_DISABLED in combination with IRQF_SHARED
Date: Sat, 10 Jul 2010 09:42:02 -0400
Message-ID: <201007101342.o6ADg2wx019157@cmf.nrl.navy.mil>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:48319 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754791Ab0GJNm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 09:42:29 -0400
Received: from cmf.nrl.navy.mil (thirdoffive.cmf.nrl.navy.mil [134.207.12.180])
	by hedwig.cmf.nrl.navy.mil (8.14.2/8.14.2) with ESMTP id o6ADg278014330
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sat, 10 Jul 2010 09:42:03 -0400
Received: from thirdoffive.cmf.nrl.navy.mil (chas@localhost)
	by cmf.nrl.navy.mil (8.14.3/8.14.3/Submit) with ESMTP id o6ADg2wx019157
	for <netdev@vger.kernel.org>; Sat, 10 Jul 2010 09:42:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

commit 2fae0433cf7febc4b69ff58730de1ca412846743
Author: chas williams - CONTRACTOR <chas@relax.cmf.nrl.navy.mil>
Date:   Sat Jul 10 09:38:05 2010 -0400

    [atm]: remove IRQF_DISABLED in combination with IRQF_SHARED
    
    Signed-off-by: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index ea9cbe5..fa4d600 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -967,7 +967,8 @@ he_init_irq(struct he_dev *he_dev)
 	he_writel(he_dev, 0x0, GRP_54_MAP);
 	he_writel(he_dev, 0x0, GRP_76_MAP);
 
-	if (request_irq(he_dev->pci_dev->irq, he_irq_handler, IRQF_DISABLED|IRQF_SHARED, DEV_LABEL, he_dev)) {
+	if (request_irq(he_dev->pci_dev->irq,
+			he_irq_handler, IRQF_SHARED, DEV_LABEL, he_dev)) {
 		hprintk("irq %d already in use\n", he_dev->pci_dev->irq);
 		return -EINVAL;
 	}   
diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index 98657a6..558ad18 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -3364,7 +3364,7 @@ init_card(struct atm_dev *dev)
 		writel(SAR_STAT_TMROF, SAR_REG_STAT);
 	}
 	IPRINTK("%s: Request IRQ ... ", card->name);
-	if (request_irq(pcidev->irq, idt77252_interrupt, IRQF_DISABLED|IRQF_SHARED,
+	if (request_irq(pcidev->irq, idt77252_interrupt, IRQF_SHARED,
 			card->name, card) != 0) {
 		printk("%s: can't allocate IRQ.\n", card->name);
 		deinit_card(card);
diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 59876c6..cff337e 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -765,8 +765,7 @@ static int __devinit ns_init_card(int i, struct pci_dev *pcidev)
 
 	card->intcnt = 0;
 	if (request_irq
-	    (pcidev->irq, &ns_irq_handler, IRQF_DISABLED | IRQF_SHARED,
-	     "nicstar", card) != 0) {
+	    (pcidev->irq, &ns_irq_handler, IRQF_SHARED, "nicstar", card) != 0) {
 		printk("nicstar%d: can't allocate IRQ %d.\n", i, pcidev->irq);
 		error = 9;
 		ns_init_card_error(card, error);
