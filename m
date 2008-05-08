From: Ben Dooks <ben-linux@fluff.org>
Subject: DM9000: Add __devinit and __devexit attributes to probe and remove
Date: Thu, 8 May 2008 11:33:03 +0100
Message-ID: <20080508103303.GC30439@fluff.org.uk>
References: <20080428151309.GA30439@fluff.org.uk> <4820865F.70703@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Dooks <ben-linux@fluff.org>,
	Linux Networking <netdev@vger.kernel.org>,
	akpm@linux-foundation.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:54535 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759297AbYEHKdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 06:33:11 -0400
Content-Disposition: inline
In-Reply-To: <4820865F.70703@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Enrico Scholz <enrico.scholz@sigma-chemnitz.de>

There were missing __dev* annotations for the dm9000_probe() 
and dm9000_drv_remove() functions.

Signed-off-by: Enrico Scholz <enrico.scholz@sigma-chemnitz.de>
Signed-off-by: Ben Dooks <ben-linux@fluff.org>

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

--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
