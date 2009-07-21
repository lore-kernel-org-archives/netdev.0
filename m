From: Mike Rapoport <mike@compulab.co.il>
Subject: [PATCH] dm9000: switch to dev_pm_ops
Date: Tue, 21 Jul 2009 17:00:37 +0300
Message-ID: <1248184837-22350-1-git-send-email-mike@compulab.co.il>
Cc: Ben Dooks <ben@simtec.co.uk>, netdev@vger.kernel.org,
	Mike Rapoport <mike@compulab.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from compulab.site5.com ([67.18.134.219]:40006 "EHLO compulab.co.il"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751057AbZGUOAm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 10:00:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mike Rapoport <mike@compulab.co.il>
---
 drivers/net/dm9000.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index dd771de..7b639cd 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -1410,9 +1410,10 @@ out:
 }
 
 static int
-dm9000_drv_suspend(struct platform_device *dev, pm_message_t state)
+dm9000_drv_suspend(struct device *dev)
 {
-	struct net_device *ndev = platform_get_drvdata(dev);
+	struct platform_device *pdev = to_platform_device(dev);
+	struct net_device *ndev = platform_get_drvdata(pdev);
 	board_info_t *db;
 
 	if (ndev) {
@@ -1428,9 +1429,10 @@ dm9000_drv_suspend(struct platform_device *dev, pm_message_t state)
 }
 
 static int
-dm9000_drv_resume(struct platform_device *dev)
+dm9000_drv_resume(struct device *dev)
 {
-	struct net_device *ndev = platform_get_drvdata(dev);
+	struct platform_device *pdev = to_platform_device(dev);
+	struct net_device *ndev = platform_get_drvdata(pdev);
 	board_info_t *db = netdev_priv(ndev);
 
 	if (ndev) {
@@ -1447,6 +1449,11 @@ dm9000_drv_resume(struct platform_device *dev)
 	return 0;
 }
 
+static struct dev_pm_ops dm9000_drv_pm_ops = {
+	.suspend	= dm9000_drv_suspend,
+	.resume		= dm9000_drv_resume,
+};
+
 static int __devexit
 dm9000_drv_remove(struct platform_device *pdev)
 {
@@ -1466,11 +1473,10 @@ static struct platform_driver dm9000_driver = {
 	.driver	= {
 		.name    = "dm9000",
 		.owner	 = THIS_MODULE,
+		.pm	 = &dm9000_drv_pm_ops,
 	},
 	.probe   = dm9000_probe,
 	.remove  = __devexit_p(dm9000_drv_remove),
-	.suspend = dm9000_drv_suspend,
-	.resume  = dm9000_drv_resume,
 };
 
 static int __init
-- 
1.6.0.6

