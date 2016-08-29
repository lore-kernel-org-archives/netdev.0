From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 4/8] dmaengine: sa11x0: unexport sa11x0_dma_filter_fn and
 clean up
Date: Mon, 29 Aug 2016 12:26:20 +0100
Message-ID: <E1beKho-0001H5-TA@rmk-PC.armlinux.org.uk>
References: <20160829112540.GF1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Dan Williams <dan.j.williams@intel.com>,
        Samuel Ortiz <samuel@sortiz.org>,
        Vinod Koul <vinod.koul@intel.com>
To: dmaengine@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:56853 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756977AbcH2L0h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 07:26:37 -0400
In-Reply-To: <20160829112540.GF1041@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As we now have no users of sa11x0_dma_filter_fn() in the tree, we can
unexport this function, and remove the now unused header file.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/dma/sa11x0-dma.c   | 21 ++++++++-------------
 include/linux/sa11x0-dma.h | 24 ------------------------
 2 files changed, 8 insertions(+), 37 deletions(-)
 delete mode 100644 include/linux/sa11x0-dma.h

diff --git a/drivers/dma/sa11x0-dma.c b/drivers/dma/sa11x0-dma.c
index 565bc67fac7e..6d942b8c4097 100644
--- a/drivers/dma/sa11x0-dma.c
+++ b/drivers/dma/sa11x0-dma.c
@@ -17,7 +17,6 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/platform_device.h>
-#include <linux/sa11x0-dma.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 
@@ -830,6 +829,14 @@ static const struct dma_slave_map sa11x0_dma_map[] = {
 	{ "sa11x0-ssp", "rx", "Ser4SSPRc" },
 };
 
+static bool sa11x0_dma_filter_fn(struct dma_chan *chan, void *param)
+{
+	struct sa11x0_dma_chan *c = to_sa11x0_dma_chan(chan);
+	const char *p = param;
+
+	return !strcmp(c->name, p);
+}
+
 static int sa11x0_dma_init_dmadev(struct dma_device *dmadev,
 	struct device *dev)
 {
@@ -1087,18 +1094,6 @@ static struct platform_driver sa11x0_dma_driver = {
 	.remove		= sa11x0_dma_remove,
 };
 
-bool sa11x0_dma_filter_fn(struct dma_chan *chan, void *param)
-{
-	if (chan->device->dev->driver == &sa11x0_dma_driver.driver) {
-		struct sa11x0_dma_chan *c = to_sa11x0_dma_chan(chan);
-		const char *p = param;
-
-		return !strcmp(c->name, p);
-	}
-	return false;
-}
-EXPORT_SYMBOL(sa11x0_dma_filter_fn);
-
 static int __init sa11x0_dma_init(void)
 {
 	return platform_driver_register(&sa11x0_dma_driver);
diff --git a/include/linux/sa11x0-dma.h b/include/linux/sa11x0-dma.h
deleted file mode 100644
index 65839a58b8e5..000000000000
--- a/include/linux/sa11x0-dma.h
+++ /dev/null
@@ -1,24 +0,0 @@
-/*
- * SA11x0 DMA Engine support
- *
- * Copyright (C) 2012 Russell King
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-#ifndef __LINUX_SA11X0_DMA_H
-#define __LINUX_SA11X0_DMA_H
-
-struct dma_chan;
-
-#if defined(CONFIG_DMA_SA11X0) || defined(CONFIG_DMA_SA11X0_MODULE)
-bool sa11x0_dma_filter_fn(struct dma_chan *, void *);
-#else
-static inline bool sa11x0_dma_filter_fn(struct dma_chan *c, void *d)
-{
-	return false;
-}
-#endif
-
-#endif
-- 
2.1.0
