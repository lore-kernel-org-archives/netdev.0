From: Valerie Henson <val_henson@linux.intel.com>
Subject: [patch 4/6] [TULIP]  Quiet down tulip_stop_rxtx
Date: Mon, 12 Mar 2007 02:31:32 -0700
Message-ID: <20070312184218.317747000@linux.intel.com>
References: <20070312093128.577087000@linux.intel.com>
Cc: netdev@vger.kernel.org, Val Henson <val_henson@linux.intel.com>,
	Grant Grundler <grundler@parisc-linux.org>
To: Jeff Garzik <jeff@garzik.org>, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:36367 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751594AbXCLSmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 14:42:15 -0400
Content-Disposition: inline; filename=tulip-quiet-stop-rxtx
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Only print out debugging info for tulip_stop_rxtx if debug is on.
Many cards (including at least two of my own) fail to stop properly
during initialization according to this test with no apparent ill
effects.  Worse, it tends to spam logs when the driver doesn't work.

Signed-off-by: Val Henson <val_henson@linux.intel.com>
Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
Cc: Jeff Garzik <jeff@garzik.org>

---
 drivers/net/tulip/tulip.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- pristine-linux.orig/drivers/net/tulip/tulip.h
+++ pristine-linux/drivers/net/tulip/tulip.h
@@ -481,7 +481,7 @@ static inline void tulip_stop_rxtx(struc
 		while (--i && (ioread32(ioaddr + CSR5) & (CSR5_TS|CSR5_RS)))
 			udelay(10);
 
-		if (!i)
+		if (!i && (tulip_debug > 1))
 			printk(KERN_DEBUG "%s: tulip_stop_rxtx() failed"
 					" (CSR5 0x%x CSR6 0x%x)\n",
 					pci_name(tp->pdev),

--
