From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 1/2] drivers: net: cpsw: use pinctrl PM helpers
Date: Thu, 6 Jun 2013 23:45:14 +0530
Message-ID: <1370542515-22009-2-git-send-email-mugunthanvnm@ti.com>
References: <1370542515-22009-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linus.walleij@linaro.org>,
	<broonie@kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1370542515-22009-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This utilize the new pinctrl core PM helpers to transition
the driver to "default" and "sleep" states.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index a45f64e..5143552 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -35,6 +35,7 @@
 #include <linux/if_vlan.h>
 
 #include <linux/platform_data/cpsw.h>
+#include <linux/pinctrl/consumer.h>
 
 #include "cpsw_ale.h"
 #include "cpts.h"
@@ -1691,6 +1692,9 @@ static int cpsw_probe(struct platform_device *pdev)
 	 */
 	pm_runtime_enable(&pdev->dev);
 
+	/* Select default pin state */
+	pinctrl_pm_select_default_state(&pdev->dev);
+
 	if (cpsw_probe_dt(&priv->data, pdev)) {
 		pr_err("cpsw: platform data missing\n");
 		ret = -ENODEV;
@@ -1979,6 +1983,9 @@ static int cpsw_suspend(struct device *dev)
 		cpsw_ndo_stop(ndev);
 	pm_runtime_put_sync(&pdev->dev);
 
+	/* Select sleep pin state */
+	pinctrl_pm_select_sleep_state(&pdev->dev);
+
 	return 0;
 }
 
@@ -1988,6 +1995,10 @@ static int cpsw_resume(struct device *dev)
 	struct net_device	*ndev = platform_get_drvdata(pdev);
 
 	pm_runtime_get_sync(&pdev->dev);
+
+	/* Select default pin state */
+	pinctrl_pm_select_default_state(&pdev->dev);
+
 	if (netif_running(ndev))
 		cpsw_ndo_open(ndev);
 	return 0;
-- 
1.7.9.5

