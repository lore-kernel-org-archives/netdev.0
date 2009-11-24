From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: [PATCH] NET: smc91x: convert to dev_pm_ops
Date: Tue, 24 Nov 2009 14:57:47 -0800
Message-ID: <1259103467-31016-1-git-send-email-khilman@deeprootsystems.com>
Cc: linux-kernel@vger.kernel.org
To: Nicolas Pitre <nico@fluxnic.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934362AbZKXW5o@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert smc91x driver from legacy PM hooks over to using dev_pm_ops.

Tested on OMAP3 platform.

Signed-off-by: Kevin Hilman <khilman@deeprootsystems.com>
---
 drivers/net/smc91x.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 05c91ee..8e4c455 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -2365,9 +2365,10 @@ static int __devexit smc_drv_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static int smc_drv_suspend(struct platform_device *dev, pm_message_t state)
+static int smc_drv_suspend(struct device *dev)
 {
-	struct net_device *ndev = platform_get_drvdata(dev);
+	struct platform_device *pdev = to_platform_device(dev);
+	struct net_device *ndev = platform_get_drvdata(pdev);
 
 	if (ndev) {
 		if (netif_running(ndev)) {
@@ -2379,9 +2380,10 @@ static int smc_drv_suspend(struct platform_device *dev, pm_message_t state)
 	return 0;
 }
 
-static int smc_drv_resume(struct platform_device *dev)
+static int smc_drv_resume(struct device *dev)
 {
-	struct net_device *ndev = platform_get_drvdata(dev);
+	struct platform_device *pdev = to_platform_device(dev);
+	struct net_device *ndev = platform_get_drvdata(pdev);
 
 	if (ndev) {
 		struct smc_local *lp = netdev_priv(ndev);
@@ -2397,14 +2399,18 @@ static int smc_drv_resume(struct platform_device *dev)
 	return 0;
 }
 
+static struct dev_pm_ops smc_drv_pm_ops = {
+	.suspend	= smc_drv_suspend,
+	.resume		= smc_drv_resume,
+};
+
 static struct platform_driver smc_driver = {
 	.probe		= smc_drv_probe,
 	.remove		= __devexit_p(smc_drv_remove),
-	.suspend	= smc_drv_suspend,
-	.resume		= smc_drv_resume,
 	.driver		= {
 		.name	= CARDNAME,
 		.owner	= THIS_MODULE,
+		.pm	= &smc_drv_pm_ops,
 	},
 };
 
-- 
1.6.5.1
