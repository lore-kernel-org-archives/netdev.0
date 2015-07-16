From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 5/8] stmmac: export probe_config_dt() and get_platform_resources()
Date: Fri, 17 Jul 2015 00:26:09 +0200
Message-ID: <1437085572-11371-6-git-send-email-manabian@gmail.com>
References: <1437085572-11371-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org
To: peppe.cavallaro@st.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:33857 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756005AbbGPW0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 18:26:39 -0400
Received: by lbbzr7 with SMTP id zr7so51886182lbb.1
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 15:26:38 -0700 (PDT)
In-Reply-To: <1437085572-11371-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export stmmac_probe_config_dt() and stmmac_get_platform_resources()
so they can be used in the dwmac-* drivers themselves. This will
allow us to build more flexible and standalone drivers which just
use stmmac_platform as a library for setup functions.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 10 ++++++----
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h |  8 ++++++++
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index ea467be93673..eca0eb845241 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -104,7 +104,7 @@ static int dwmac1000_validate_ucast_entries(int ucast_entries)
  * this function is to read the driver parameters from device-tree and
  * set some private fields that will be used by the main at runtime.
  */
-static struct plat_stmmacenet_data *
+struct plat_stmmacenet_data *
 stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 {
 	struct device_node *np = pdev->dev.of_node;
@@ -251,15 +251,16 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 	return plat;
 }
 #else
-static struct plat_stmmacenet_data *
+struct plat_stmmacenet_data *
 stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 {
 	return ERR_PTR(-ENOSYS);
 }
 #endif /* CONFIG_OF */
+EXPORT_SYMBOL_GPL(stmmac_probe_config_dt);
 
-static int stmmac_get_platform_resources(struct platform_device *pdev,
-					 struct stmmac_resources *stmmac_res)
+int stmmac_get_platform_resources(struct platform_device *pdev,
+				  struct stmmac_resources *stmmac_res)
 {
 	struct resource *res;
 
@@ -302,6 +303,7 @@ static int stmmac_get_platform_resources(struct platform_device *pdev,
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(stmmac_get_platform_resources);
 
 /**
  * stmmac_pltfr_probe - platform driver probe.
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
index 71da86d7bd00..84ceb5342686 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
@@ -19,6 +19,14 @@
 #ifndef __STMMAC_PLATFORM_H__
 #define __STMMAC_PLATFORM_H__
 
+#include "stmmac.h"
+
+struct plat_stmmacenet_data *
+stmmac_probe_config_dt(struct platform_device *pdev, const char **mac);
+
+int stmmac_get_platform_resources(struct platform_device *pdev,
+				  struct stmmac_resources *stmmac_res);
+
 int stmmac_pltfr_probe(struct platform_device *pdev);
 int stmmac_pltfr_remove(struct platform_device *pdev);
 extern const struct dev_pm_ops stmmac_pltfr_pm_ops;
-- 
1.8.0
