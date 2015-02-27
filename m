From: <grygorii.strashko@linaro.org>
Subject: [PATCH 1/2] net: davinci_mdio: add hibernation callbacks
Date: Fri, 27 Feb 2015 13:19:44 +0200
Message-ID: <1425035985-8875-1-git-send-email-grygorii.strashko@linaro.org>
Cc: <nm@ti.com>, <sumit.semwal@linaro.org>,
	Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org,
	<linux-omap@vger.kernel.org>,
	Grygorii Strashko <Grygorii.Strashko@linaro.org>
To: "David S. Miller" <davem@davemloft.net>,
	Felipe Balbi <balbi@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grygorii Strashko <Grygorii.Strashko@linaro.org>

Setting a dev_pm_ops suspend_late/resume_early pair but not a
set of hibernation functions means those pm functions will
not be called upon hibernation.
Fix this by using SET_LATE_SYSTEM_SLEEP_PM_OPS, which appropriately
assigns the suspend and hibernation handlers and move
davinci_mdio_x callbacks under CONFIG_PM_SLEEP to avoid build warnings.

Signed-off-by: Grygorii Strashko <Grygorii.Strashko@linaro.org>
---
 drivers/net/ethernet/ti/davinci_mdio.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index e58f0a7..25871dc 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -438,6 +438,7 @@ static int davinci_mdio_remove(struct platform_device *pdev)
 	return 0;
 }
 
+#ifdef CONFIG_PM_SLEEP
 static int davinci_mdio_suspend(struct device *dev)
 {
 	struct davinci_mdio_data *data = dev_get_drvdata(dev);
@@ -479,10 +480,10 @@ static int davinci_mdio_resume(struct device *dev)
 
 	return 0;
 }
+#endif
 
 static const struct dev_pm_ops davinci_mdio_pm_ops = {
-	.suspend_late	= davinci_mdio_suspend,
-	.resume_early	= davinci_mdio_resume,
+	SET_LATE_SYSTEM_SLEEP_PM_OPS(davinci_mdio_suspend, davinci_mdio_resume)
 };
 
 #if IS_ENABLED(CONFIG_OF)
-- 
1.9.1

