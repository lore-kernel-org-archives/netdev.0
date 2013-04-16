From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH v2] fec: Use SIMPLE_DEV_PM_OPS
Date: Tue, 16 Apr 2013 15:17:46 -0300
Message-ID: <1366136266-3324-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <joe@perches.com>,
	<sergei.shtylyov@cogentembedded.com>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe003.messaging.microsoft.com ([216.32.181.183]:19253
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752550Ab3DPSSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 14:18:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using SIMPLE_DEV_PM_OPS can make the code smaller and simpler.

Also change CONFIG_PM to CONFIG_PM_SLEEP.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
Changes since v1:
- Remove macro definition since SIMPLE_DEV_PM_OPS can handle CONFIG_PM_SLEEP
and !CONFIG_PM_SLEEP cases properly

 drivers/net/ethernet/freescale/fec_main.c |   15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index e472670..aa9dc62 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1915,7 +1915,7 @@ fec_drv_remove(struct platform_device *pdev)
 	return 0;
 }
 
-#ifdef CONFIG_PM
+#ifdef CONFIG_PM_SLEEP
 static int
 fec_suspend(struct device *dev)
 {
@@ -1949,24 +1949,15 @@ fec_resume(struct device *dev)
 
 	return 0;
 }
+#endif /* CONFIG_PM_SLEEP */
 
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
 
 static struct platform_driver fec_driver = {
 	.driver	= {
 		.name	= DRIVER_NAME,
 		.owner	= THIS_MODULE,
-#ifdef CONFIG_PM
 		.pm	= &fec_pm_ops,
-#endif
 		.of_match_table = fec_dt_ids,
 	},
 	.id_table = fec_devtype,
-- 
1.7.9.5
