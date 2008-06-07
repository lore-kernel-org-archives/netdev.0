From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH stable] ssb: Fix context assertion in ssb_pcicore_dev_irqvecs_enable
Date: Sat, 7 Jun 2008 17:57:37 +0200
Message-ID: <200806071757.38139.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"linux-kernel" <linux-kernel@vger.kernel.org>
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:47481 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760061AbYFGP6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jun 2008 11:58:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a context assertion in ssb that makes b44 print
out warnings on resume.

This fixes the following kernel oops:
http://www.kerneloops.org/oops.php?number=12732
http://www.kerneloops.org/oops.php?number=11410

Upstream commit is a3bafeedfff2ac5fa0a316bea4570e27900b6fcc

Signed-off-by: Michael Buesch <mb@bu3sch.de>


Index: linux-2.6.25.4/drivers/ssb/driver_pcicore.c
===================================================================
--- linux-2.6.25.4.orig/drivers/ssb/driver_pcicore.c	2008-05-22 16:35:41.000000000 +0200
+++ linux-2.6.25.4/drivers/ssb/driver_pcicore.c	2008-06-07 17:20:55.000000000 +0200
@@ -516,18 +516,18 @@ int ssb_pcicore_dev_irqvecs_enable(struc
 {
 	struct ssb_device *pdev = pc->dev;
 	struct ssb_bus *bus;
 	int err = 0;
 	u32 tmp;
 
-	might_sleep();
-
 	if (!pdev)
 		goto out;
 	bus = pdev->bus;
 
+	might_sleep_if(pdev->id.coreid != SSB_DEV_PCI);
+
 	/* Enable interrupts for this device. */
 	if (bus->host_pci &&
 	    ((pdev->id.revision >= 6) || (pdev->id.coreid == SSB_DEV_PCIE))) {
 		u32 coremask;
 
 		/* Calculate the "coremask" for the device. */
