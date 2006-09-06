From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: [Patch] BUG_ON cleanup in drivers/net/tokenring/
Date: Wed, 06 Sep 2006 23:37:34 +0200
Message-ID: <1157578654.17839.3.camel@alice>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.de ([213.165.64.20]:49815 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S1751656AbWIFVhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 17:37:37 -0400
To: kernel-janitors@lists.osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi,

this patch converts one if() BUG(); to BUG_ON();
so it can be safely optimized away.

Signed-off-by: Eric Sesterhenn <snakebyte@gmx.de>

--- linux-2.6.18-rc6/drivers/net/tokenring/tmspci.c.orig	2006-09-06 23:32:41.000000000 +0200
+++ linux-2.6.18-rc6/drivers/net/tokenring/tmspci.c	2006-09-06 23:32:54.000000000 +0200
@@ -224,8 +224,7 @@ static void __devexit tms_pci_detach (st
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 
-	if (!dev)
-		BUG();
+	BUG_ON(!dev);
 	unregister_netdev(dev);
 	release_region(dev->base_addr, TMS_PCI_IO_EXTENT);
 	free_irq(dev->irq, dev);


