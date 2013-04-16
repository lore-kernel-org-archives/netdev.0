From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH] fec: Use SIMPLE_DEV_PM_OPS
Date: Tue, 16 Apr 2013 10:58:51 -0300
Message-ID: <1366120731-31427-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe003.messaging.microsoft.com ([216.32.181.183]:3806
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935122Ab3DPN7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 09:59:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using SIMPLE_DEV_PM_OPS can make the code smaller and simpler.

Also change CONFIG_PM to CONFIG_PM_SLEEP.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |   20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 806a56d..2e8bb58 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1911,7 +1911,7 @@ fec_drv_remove(struct platform_device *pdev)
 	return 0;
 }
 
-#ifdef CONFIG_PM
+#ifdef CONFIG_PM_SLEEP
 static int
 fec_suspend(struct device *dev)
 {
@@ -1946,23 +1946,17 @@ fec_resume(struct device *dev)
 	return 0;
 }
 
-static const struct dev_pm_ops fec_pm_ops = {
-	.suspend	= fec_suspend,
-	.resume		= fec_resume,
-	.freeze		= fec_suspend,
-	.thaw		= fec_resume,
-	.poweroff	= fec_suspend,
-	.restore	= fec_resume,
-};
-#endif
+static SIMPLE_DEV_PM_OPS(fec_pm_ops, fec_suspend, fec_resume);
+#define FEC_PM_OPS (&fec_pm_ops)
+#else
+#define FEC_PM_OPS NULL
+#endif /* CONFIG_PM_SLEEP */
 
 static struct platform_driver fec_driver = {
 	.driver	= {
 		.name	= DRIVER_NAME,
 		.owner	= THIS_MODULE,
-#ifdef CONFIG_PM
-		.pm	= &fec_pm_ops,
-#endif
+		.pm	= FEC_PM_OPS,
 		.of_match_table = fec_dt_ids,
 	},
 	.id_table = fec_devtype,
-- 
1.7.9.5
