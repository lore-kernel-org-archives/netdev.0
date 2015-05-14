From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 11/11] stmmac: drop driver from stmmac platform code
Date: Thu, 14 May 2015 12:11:06 +0200
Message-ID: <1431598266-25736-12-git-send-email-manabian@gmail.com>
References: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de, peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:35359 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932948AbbENKLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 06:11:52 -0400
Received: by labbd9 with SMTP id bd9so60512394lab.2
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 03:11:51 -0700 (PDT)
In-Reply-To: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dwmac-generic replaces the driver inside the stmmac
platform code. This turns stmmac platform into a library
used by drivers for common platform driver functions.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 .../net/ethernet/stmicro/stmmac/dwmac-generic.c    |  4 +++-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 22 ----------------------
 2 files changed, 3 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
index fb9623744e41..e817a1a44379 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
@@ -1,6 +1,7 @@
 /*
  * Generic DWMAC platform driver
  *
+ * Copyright (C) 2007-2011  STMicroelectronics Ltd
  * Copyright (C) 2015 Joachim Eastwood <manabian@gmail.com>
  *
  * This file is licensed under the terms of the GNU General Public
@@ -12,6 +13,7 @@
 #include <linux/of.h>
 #include <linux/platform_device.h>
 
+#include "stmmac.h"
 #include "stmmac_platform.h"
 
 static const struct of_device_id dwmac_generic_match[] = {
@@ -28,7 +30,7 @@ static struct platform_driver dwmac_generic_driver = {
 	.probe  = stmmac_pltfr_probe,
 	.remove = stmmac_pltfr_remove,
 	.driver = {
-		.name           = "dwmac-generic",
+		.name           = STMMAC_RESOURCE_NAME,
 		.pm		= &stmmac_pltfr_pm_ops,
 		.of_match_table = of_match_ptr(dwmac_generic_match),
 	},
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index e3a3c2bff86e..3e194c3ca297 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -32,12 +32,6 @@
 #include "stmmac.h"
 #include "stmmac_platform.h"
 
-static const struct of_device_id stmmac_dt_ids[] = {
-	/* SoC specific glue layers should come before generic bindings */
-	{ /* sentinel */ }
-};
-MODULE_DEVICE_TABLE(of, stmmac_dt_ids);
-
 #ifdef CONFIG_OF
 
 /**
@@ -431,19 +425,3 @@ static int stmmac_pltfr_resume(struct device *dev)
 SIMPLE_DEV_PM_OPS(stmmac_pltfr_pm_ops, stmmac_pltfr_suspend,
 				       stmmac_pltfr_resume);
 EXPORT_SYMBOL_GPL(stmmac_pltfr_pm_ops);
-
-static struct platform_driver stmmac_pltfr_driver = {
-	.probe = stmmac_pltfr_probe,
-	.remove = stmmac_pltfr_remove,
-	.driver = {
-		   .name = STMMAC_RESOURCE_NAME,
-		   .pm = &stmmac_pltfr_pm_ops,
-		   .of_match_table = of_match_ptr(stmmac_dt_ids),
-	},
-};
-
-module_platform_driver(stmmac_pltfr_driver);
-
-MODULE_DESCRIPTION("STMMAC 10/100/1000 Ethernet PLATFORM driver");
-MODULE_AUTHOR("Giuseppe Cavallaro <peppe.cavallaro@st.com>");
-MODULE_LICENSE("GPL");
-- 
1.8.0
