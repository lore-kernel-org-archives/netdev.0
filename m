From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 2/2] drivers: net: davinci_mdio: use pinctrl PM helpers
Date: Thu, 6 Jun 2013 23:45:15 +0530
Message-ID: <1370542515-22009-3-git-send-email-mugunthanvnm@ti.com>
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
 drivers/net/ethernet/ti/davinci_mdio.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 12aec17..5e361f4 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -38,6 +38,7 @@
 #include <linux/davinci_emac.h>
 #include <linux/of.h>
 #include <linux/of_device.h>
+#include <linux/pinctrl/consumer.h>
 
 /*
  * This timeout definition is a worst-case ultra defensive measure against
@@ -347,6 +348,9 @@ static int davinci_mdio_probe(struct platform_device *pdev)
 	data->bus->parent	= dev;
 	data->bus->priv		= data;
 
+	/* Select default pin state */
+	pinctrl_pm_select_default_state(&pdev->dev);
+
 	pm_runtime_enable(&pdev->dev);
 	pm_runtime_get_sync(&pdev->dev);
 	data->clk = clk_get(&pdev->dev, "fck");
@@ -454,6 +458,9 @@ static int davinci_mdio_suspend(struct device *dev)
 	data->suspended = true;
 	spin_unlock(&data->lock);
 
+	/* Select sleep pin state */
+	pinctrl_pm_select_sleep_state(dev);
+
 	return 0;
 }
 
@@ -462,6 +469,9 @@ static int davinci_mdio_resume(struct device *dev)
 	struct davinci_mdio_data *data = dev_get_drvdata(dev);
 	u32 ctrl;
 
+	/* Select default pin state */
+	pinctrl_pm_select_default_state(dev);
+
 	spin_lock(&data->lock);
 	pm_runtime_get_sync(data->dev);
 
-- 
1.7.9.5

