From: "Stanley.Miao" <stanley.miao@windriver.com>
Subject: [PATCH 1/2] Add SMC_MEM_RESERVED for OMAP platform.
Date: Mon, 17 Nov 2008 17:29:54 +0800
Message-ID: <1226914195-20473-1-git-send-email-stanley.miao@windriver.com>
Cc: davem@davemloft.net, linux-omap@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:56888 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751482AbYKQJXv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 04:23:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The iomem resource for Ethernet device  has been reserved on omap24xx and
omap34xx. So, define SMC_MEM_RESERVED for them.

Signed-off-by: Stanley.Miao <stanley.miao@windriver.com>
---
 drivers/net/smc911x.c |    6 ++++--
 drivers/net/smc911x.h |   10 ++++++++++
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 1f26ab0..291ee46 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -2065,7 +2065,7 @@ static int smc911x_drv_probe(struct platform_device *pdev)
 		ret = -ENODEV;
 		goto out;
 	}
-
+#ifndef SMC_MEM_RESERVED
 	/*
 	 * Request the regions.
 	 */
@@ -2073,7 +2073,7 @@ static int smc911x_drv_probe(struct platform_device *pdev)
 		 ret = -EBUSY;
 		 goto out;
 	}
-
+#endif
 	ndev = alloc_etherdev(sizeof(struct smc911x_local));
 	if (!ndev) {
 		printk("%s: could not allocate device.\n", CARDNAME);
@@ -2110,7 +2110,9 @@ static int smc911x_drv_probe(struct platform_device *pdev)
 release_both:
 		free_netdev(ndev);
 release_1:
+#ifndef SMC_MEM_RESERVED
 		release_mem_region(res->start, SMC911X_IO_EXTENT);
+#endif
 out:
 		printk("%s: not found (%d).\n", CARDNAME, ret);
 	}
diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
index cc7d85b..d1b3b9b 100644
--- a/drivers/net/smc911x.h
+++ b/drivers/net/smc911x.h
@@ -42,6 +42,16 @@
   #define SMC_USE_16BIT		0
   #define SMC_USE_32BIT		1
   #define SMC_IRQ_SENSE		IRQF_TRIGGER_LOW
+#elif defined(CONFIG_ARCH_OMAP34XX)
+  #define SMC_USE_16BIT		0
+  #define SMC_USE_32BIT		1
+  #define SMC_IRQ_SENSE		IRQF_TRIGGER_LOW
+  #define SMC_MEM_RESERVED	1
+#elif defined(CONFIG_ARCH_OMAP24XX)
+  #define SMC_USE_16BIT		0
+  #define SMC_USE_32BIT		1
+  #define SMC_IRQ_SENSE		IRQF_TRIGGER_LOW
+  #define SMC_MEM_RESERVED	1
 #else
 /*
  * Default configuration
-- 
1.5.6.3

