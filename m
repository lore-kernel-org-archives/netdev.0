From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 07/15] drivers: net: davinci_mdio: remove pm runtime calls from suspend callbacks
Date: Fri, 24 Jun 2016 21:23:47 +0300
Message-ID: <20160624182355.23515-8-grygorii.strashko@ti.com>
References: <20160624182355.23515-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	Rob Herring <robh+dt@kernel.org>, <devicetree@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160624182355.23515-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PM runtime is disabled when Davinci MDIO .suspend_late() and
.resume_early() callbacks are called. As result, any PM runtime calls here will
be just a nop and can be removed.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 2e19dd1..291c42e 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -436,7 +436,6 @@ static int davinci_mdio_suspend(struct device *dev)
 
 	data->suspended = true;
 	spin_unlock(&data->lock);
-	pm_runtime_put_sync(data->dev);
 
 	/* Select sleep pin state */
 	pinctrl_pm_select_sleep_state(dev);
@@ -451,8 +450,6 @@ static int davinci_mdio_resume(struct device *dev)
 	/* Select default pin state */
 	pinctrl_pm_select_default_state(dev);
 
-	pm_runtime_get_sync(data->dev);
-
 	spin_lock(&data->lock);
 	/* restart the scan state machine */
 	__davinci_mdio_reset(data);
-- 
2.9.0
