From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] ssb: Fix context assertion in ssb_pcicore_dev_irqvecs_enable
Date: Mon, 2 Jun 2008 16:15:23 +0200
Message-ID: <200806021615.23710.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org
To: John Linville <linville@tuxdriver.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762328AbYFBOQz@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes a context assertion in ssb that makes b44 print
out warnings on resume.

This fixes the following kernel oops:
http://www.kerneloops.org/oops.php?number=12732
http://www.kerneloops.org/oops.php?number=11410

Signed-off-by: Michael Buesch <mb@bu3sch.de>

---

John, please apply to 2.6.26.

Index: wireless-testing/drivers/ssb/driver_pcicore.c
===================================================================
--- wireless-testing.orig/drivers/ssb/driver_pcicore.c	2008-06-02 16:09:55.000000000 +0200
+++ wireless-testing/drivers/ssb/driver_pcicore.c	2008-06-02 16:09:59.000000000 +0200
@@ -537,12 +537,12 @@ int ssb_pcicore_dev_irqvecs_enable(struc
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

-- 
Greetings Michael.
