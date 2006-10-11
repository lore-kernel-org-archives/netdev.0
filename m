From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 01/10] sky2: MSI test is only a warning
Date: Wed, 11 Oct 2006 14:22:26 -0700
Message-ID: <20061011212310.137359774@osdl.org>
References: <20061011212225.941046083@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:31437 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161418AbWJKV0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 17:26:47 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=msi-message.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some motherboards don't implement MSI correctly. The driver handles this
but the warning is too verbose and overly cautious.


Signed-off-by: Stephe Hemminger <shemminger@osdl.org>


--- sky2.orig/drivers/net/sky2.c	2006-10-11 11:43:08.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-10-11 11:43:33.000000000 -0700
@@ -3326,9 +3326,8 @@
 
 	if (!hw->msi_detected) {
 		/* MSI test failed, go back to INTx mode */
-		printk(KERN_WARNING PFX "%s: No interrupt was generated using MSI, "
-		       "switching to INTx mode. Please report this failure to "
-		       "the PCI maintainer and include system chipset information.\n",
+		printk(KERN_INFO PFX "%s: No interrupt generated using MSI, "
+		       "switching to INTx mode.\n",
 		       pci_name(pdev));
 
 		err = -EOPNOTSUPP;
@@ -3336,6 +3335,7 @@
 	}
 
 	sky2_write32(hw, B0_IMSK, 0);
+	sky2_read32(hw, B0_IMSK);
 
 	free_irq(pdev->irq, hw);
 

--
Stephen Hemminger <shemminger@osdl.org>

