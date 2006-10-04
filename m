From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sk98lin: check result of pci_enable_device on resume
Date: Wed, 4 Oct 2006 16:21:34 -0700
Message-ID: <20061004162134.48288923@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:17848 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751221AbWJDXWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2006 19:22:19 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gets rid of a must_check warning.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.6.orig/drivers/net/sk98lin/skge.c
+++ linux-2.6/drivers/net/sk98lin/skge.c
@@ -5070,7 +5070,13 @@ static int skge_resume(struct pci_dev *p
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
-	pci_enable_device(pdev);
+	ret = pci_enable_device(pdev);
+	if (ret) {
+		printk(KERN_WARNING "sk98lin: unable to enable device %s\n",
+		       dev->name);
+		return ret;
+	}
+
 	pci_set_master(pdev);
 	if (pAC->GIni.GIMacsFound == 2)
 		ret = request_irq(dev->irq, SkGeIsr, IRQF_SHARED, "sk98lin", dev);
