From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT 4/5] sky2: suspend/resume patchlets
Date: Tue, 13 Jun 2006 17:17:30 +0900
Message-ID: <20060613081930.771804000@localhost.localdomain>
References: <20060613081726.695812000@localhost.localdomain>
Cc: linus@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:19691 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750760AbWFMIUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 04:20:36 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-suspend-nohwirq.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: [RFT 4/5] sky2: save/restore base hardware irq during suspend/resume

The hardware should be fully shut off during suspend, and the base
irq mask restored during resume.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- test.orig/drivers/net/sky2.c
+++ test/drivers/net/sky2.c
@@ -3442,6 +3442,7 @@ static int sky2_suspend(struct pci_dev *
 		}
 	}
 
+	sky2_write32(hw, B0_IMSK, 0);
 	pci_save_state(pdev);
 	sky2_set_power_state(hw, pstate);
 	return 0;
@@ -3460,6 +3461,8 @@ static int sky2_resume(struct pci_dev *p
 	if (err)
 		goto out;
 
+	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
+
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
 		if (dev && netif_running(dev)) {

--

