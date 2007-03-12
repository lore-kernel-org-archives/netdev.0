From: Valerie Henson <val_henson@linux.intel.com>
Subject: [patch 2/4] [TULIP]  Quiet down tulip_stop_rxtx
Date: Mon, 12 Mar 2007 02:59:30 -0700
Message-ID: <20070312095911.842948000@linux.intel.com>
References: <20070312093128.577087000@linux.intel.com>
Cc: Val Henson <val_henson@linux.intel.com>,
	Grant Grundler <grundler@parisc-linux.org>,
	Jeff Garzik <jeff@garzik.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965480AbXCLJ7R@vger.kernel.org>
Content-Disposition: inline; filename=tulip-quiet-stop-rxtx
Sender: linux-kernel-owner@vger.kernel.org
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
 1 files changed, 1 insertion(+), 1 deletion(-)

--- tulip-2.6-mm-linux.orig/drivers/net/tulip/tulip.h
+++ tulip-2.6-mm-linux/drivers/net/tulip/tulip.h
@@ -481,7 +481,7 @@ static inline void tulip_stop_rxtx(struc
 		while (--i && (ioread32(ioaddr + CSR5) & (CSR5_TS|CSR5_RS)))
 			udelay(10);
 
-		if (!i)
+		if (!i && (tulip_debug > 1))
 			printk(KERN_DEBUG "%s: tulip_stop_rxtx() failed"
 					" (CSR5 0x%x CSR6 0x%x)\n",
 					pci_name(tp->pdev),

--
