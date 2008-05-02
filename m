From: Nishant Kamat <nskamat@ti.com>
Subject: [PATCH 3/3] NET: SMC911X: Add support for OMAP LDP platform
Date: Fri,  2 May 2008 07:52:15 -0500
Message-ID: <1209732735-24443-4-git-send-email-nskamat@ti.com>
References: <1209732735-24443-1-git-send-email-nskamat@ti.com>
 <1209732735-24443-2-git-send-email-nskamat@ti.com>
 <1209732735-24443-3-git-send-email-nskamat@ti.com>
Cc: Nishant Kamat <nskamat@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from soda.ext.ti.com ([198.47.26.145]:57024 "EHLO soda.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760627AbYEBMwW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2008 08:52:22 -0400
Received: from dlep32.itg.ti.com ([157.170.170.70])
	by soda.ext.ti.com (8.13.7/8.13.7) with ESMTP id m42CqH7Z002677
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 07:52:22 -0500
In-Reply-To: <1209732735-24443-3-git-send-email-nskamat@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for OMAP LDP platform to smc911x driver.

Signed-off-by: Nishant Kamat <nskamat@ti.com>
---
 drivers/net/Kconfig   |    2 +-
 drivers/net/smc911x.c |    9 ++++++---
 drivers/net/smc911x.h |    5 +++++
 3 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 015e163..49752d0 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -955,7 +955,7 @@ config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
 	select MII
-	depends on ARCH_PXA || SH_MAGIC_PANEL_R2
+	depends on ARCH_PXA || SH_MAGIC_PANEL_R2 || ARCH_OMAP34XX
 	help
 	  This is a driver for SMSC's LAN911x series of Ethernet chipsets
 	  including the new LAN9115, LAN9116, LAN9117, and LAN9118.
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 00b9b3e..14a0e3a 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -2136,7 +2136,7 @@ static int smc911x_drv_probe(struct platform_device *pdev)
 		ret = -ENODEV;
 		goto out;
 	}
-
+#ifndef SMC_MEM_RESERVED
 	/*
 	 * Request the regions.
 	 */
@@ -2144,7 +2144,7 @@ static int smc911x_drv_probe(struct platform_device *pdev)
 		 ret = -EBUSY;
 		 goto out;
 	}
-
+#endif
 	ndev = alloc_etherdev(sizeof(struct smc911x_local));
 	if (!ndev) {
 		printk("%s: could not allocate device.\n", CARDNAME);
@@ -2172,7 +2172,9 @@ static int smc911x_drv_probe(struct platform_device *pdev)
 release_both:
 		free_netdev(ndev);
 release_1:
+#ifndef SMC_MEM_RESERVED
 		release_mem_region(res->start, SMC911X_IO_EXTENT);
+#endif
 out:
 		printk("%s: not found (%d).\n", CARDNAME, ret);
 	}
@@ -2211,8 +2213,9 @@ static int smc911x_drv_remove(struct platform_device *pdev)
 #endif
 	iounmap((void *)ndev->base_addr);
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+#ifndef SMC_MEM_RESERVED
 	release_mem_region(res->start, SMC911X_IO_EXTENT);
-
+#endif
 	free_netdev(ndev);
 	return 0;
 }
diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
index a416c61..aed2121 100644
--- a/drivers/net/smc911x.h
+++ b/drivers/net/smc911x.h
@@ -43,6 +43,11 @@
   #define SMC_USE_16BIT		0
   #define SMC_USE_32BIT		1
   #define SMC_IRQ_SENSE		IRQF_TRIGGER_LOW
+#elif defined(CONFIG_MACH_OMAP_LDP)
+  #define SMC_USE_16BIT		0
+  #define SMC_USE_32BIT		1
+  #define SMC_IRQ_SENSE		IRQF_TRIGGER_LOW
+  #define SMC_MEM_RESERVED	1
 #endif
 
 
-- 
1.5.3.2

