From: Meelis Roos <mroos@linux.ee>
Subject: [PATCH] tmspci: fix tr%d in printk
Date: Tue, 21 Sep 2010 10:19:03 +0300 (EEST)
Message-ID: <alpine.SOC.1.00.1009211011150.28446@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:59281 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754118Ab0IUHjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Sep 2010 03:39:06 -0400
Received: from math.ut.ee (math.ut.ee [193.40.36.2])
	by smtp2.it.da.ut.ee (Postfix) with ESMTP id DE4E473D699
	for <netdev@vger.kernel.org>; Tue, 21 Sep 2010 10:19:03 +0300 (EEST)
Received: from localhost (localhost [127.0.0.1])
	by math.ut.ee (Postfix) with ESMTP id A8225DAF80
	for <netdev@vger.kernel.org>; Tue, 21 Sep 2010 10:19:03 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tmspci driver uses dev->name before register_netdev() and so prints tr%d 
in initialization messages. Fix it by using dev_info.

Found and tested on real hardware.

Signed-off-by: Meelis Roos <mroos@linux.ee>

diff --git a/drivers/net/tokenring/tmspci.c b/drivers/net/tokenring/tmspci.c
index d4c7c0c..d3e788a 100644
--- a/drivers/net/tokenring/tmspci.c
+++ b/drivers/net/tokenring/tmspci.c
@@ -125,18 +125,16 @@ static int __devinit tms_pci_attach(struct pci_dev *pdev, const struct pci_devic
 	dev->irq 	= pci_irq_line;
 	dev->dma	= 0;
 
-	printk("%s: %s\n", dev->name, cardinfo->name);
-	printk("%s:    IO: %#4lx  IRQ: %d\n",
-	       dev->name, dev->base_addr, dev->irq);
+	dev_info(&pdev->dev, "%s\n", cardinfo->name);
+	dev_info(&pdev->dev, "    IO: %#4lx  IRQ: %d\n", dev->base_addr, dev->irq);
 		
 	tms_pci_read_eeprom(dev);
 
-	printk("%s:    Ring Station Address: %pM\n",
-	       dev->name, dev->dev_addr);
+	dev_info(&pdev->dev, "    Ring Station Address: %pM\n", dev->dev_addr);
 		
 	ret = tmsdev_init(dev, &pdev->dev);
 	if (ret) {
-		printk("%s: unable to get memory for dev->priv.\n", dev->name);
+		dev_info(&pdev->dev, "unable to get memory for dev->priv.\n");
 		goto err_out_region;
 	}
 
-- 
Meelis Roos (mroos@linux.ee)
