From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] prism54: small prismcompat cleanup (fwd)
Date: Wed, 8 Dec 2004 04:33:26 +0100
Message-ID: <20041208033326.GQ5496@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: prism54-private@prism54.org, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch forwarded below (slightly adopted for 2.6.10-rc2-mm4) still 
applies.

Please apply.


----- Forwarded message from Adrian Bunk <bunk@stusta.de> -----

Date: Sat, 30 Oct 2004 07:38:00 +0200
From: Adrian Bunk <bunk@stusta.de>
To: Margit Schubert-While <margitsw@t-online.de>
Cc: prism54-private@prism54.org, netdev@oss.sgi.com, jgarzik@pobox.com,
	linux-net@vger.kernel.org
Subject: [2.6 patch] prism54: small prismcompat cleanup


- the FW_LOADER is already guaranteed through the Kconfig file
- prism54_synchronize_irq is also #define'd to synchronize_irq
  in prismcompat24.h, so there's no need for it


diffstat output:
 drivers/net/wireless/prism54/islpci_dev.c  |    2 +-
 drivers/net/wireless/prism54/prismcompat.h |    6 ------
 2 files changed, 1 insertion(+), 7 deletions(-)


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.10-rc1-mm2-full/drivers/net/wireless/prism54/islpci_dev.c.old2	2004-10-30 07:23:07.000000000 +0200
+++ linux-2.6.10-rc1-mm2-full/drivers/net/wireless/prism54/islpci_dev.c	2004-10-30 07:23:19.000000000 +0200
@@ -420,7 +420,7 @@
 	 * currently in progress by emptying the TX and RX queues. */
 
 	/* wait until interrupts have finished executing on other CPUs */
-	prism54_synchronize_irq(priv->pdev->irq);
+	synchronize_irq(priv->pdev->irq);
 
 	reg = readl(device_base + ISL38XX_CTRL_STAT_REG);
 	reg &= ~(ISL38XX_CTRL_STAT_RESET | ISL38XX_CTRL_STAT_RAMBOOT);

--- linux-2.6.10-rc2-mm4-full/drivers/net/wireless/prism54/prismcompat.h.old	2004-12-08 04:06:13.000000000 +0100
+++ linux-2.6.10-rc2-mm4-full/drivers/net/wireless/prism54/prismcompat.h	2004-12-08 04:06:25.000000000 +0100
@@ -34,16 +34,10 @@
 #include <linux/workqueue.h>
 #include <linux/compiler.h>
 
-#if !defined(CONFIG_FW_LOADER) && !defined(CONFIG_FW_LOADER_MODULE)
-#error Firmware Loading is not configured in the kernel !
-#endif
-
 #ifndef __iomem
 #define __iomem
 #endif
 
-#define prism54_synchronize_irq(irq) synchronize_irq(irq)
-
 #define PRISM_FW_PDEV		&priv->pdev->dev
 
 #endif				/* _PRISM_COMPAT_H */
