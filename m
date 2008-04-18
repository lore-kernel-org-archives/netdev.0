From: Enrico Scholz <enrico.scholz@sigma-chemnitz.de>
Subject: [PATCH] DM9000: __devinit/exit annotations
Date: Fri, 18 Apr 2008 12:02:15 +0200
Message-ID: <1208512936-5897-2-git-send-email-enrico.scholz@sigma-chemnitz.de>
Cc: Enrico Scholz <enrico.scholz@sigma-chemnitz.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.cvg.de ([62.153.82.30]:58944 "EHLO mail.cvg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754650AbYDRKKQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2008 06:10:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There were missing __dev* annotations for the dm9000_probe() 
and dm9000_drv_remove() functions.

Signed-off-by: Enrico Scholz <enrico.scholz@sigma-chemnitz.de>
---
 drivers/net/dm9000.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index e668b37..7bc16d2 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -503,7 +503,7 @@ dm9000_release_board(struct platform_device *pdev, struct board_info *db)
 /*
  * Search DM9000 board, allocate space and register it
  */
-static int
+static int __devinit
 dm9000_probe(struct platform_device *pdev)
 {
 	struct dm9000_plat_data *pdata = pdev->dev.platform_data;
@@ -1376,7 +1376,7 @@ dm9000_drv_resume(struct platform_device *dev)
 	return 0;
 }
 
-static int
+static int __devexit
 dm9000_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
@@ -1397,7 +1397,7 @@ static struct platform_driver dm9000_driver = {
 		.owner	 = THIS_MODULE,
 	},
 	.probe   = dm9000_probe,
-	.remove  = dm9000_drv_remove,
+	.remove  = __devexit_p(dm9000_drv_remove),
 	.suspend = dm9000_drv_suspend,
 	.resume  = dm9000_drv_resume,
 };
-- 
1.5.4.1

