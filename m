From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH 4/5] xgmac: Remove unneeded PM_OPS definitions
Date: Tue, 16 Apr 2013 16:28:30 -0300
Message-ID: <1366140511-3836-4-git-send-email-fabio.estevam@freescale.com>
References: <1366140511-3836-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <joe@perches.com>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe001.messaging.microsoft.com ([207.46.163.24]:26665
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753687Ab3DPT2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 15:28:54 -0400
In-Reply-To: <1366140511-3836-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SIMPLE_DEV_PM_OPS macro can handle !CONFIG_PM_SLEEP case nicely, so there is no
need to define PM_OPS for both CONFIG_PM_SLEEP and !CONFIG_PM_SLEEP cases.

Remove the unneeded definitions.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/calxeda/xgmac.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index b0ebc9f..791e5ff 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -1886,12 +1886,9 @@ static int xgmac_resume(struct device *dev)
 
 	return 0;
 }
+#endif /* CONFIG_PM_SLEEP */
 
 static SIMPLE_DEV_PM_OPS(xgmac_pm_ops, xgmac_suspend, xgmac_resume);
-#define XGMAC_PM_OPS (&xgmac_pm_ops)
-#else
-#define XGMAC_PM_OPS NULL
-#endif /* CONFIG_PM_SLEEP */
 
 static const struct of_device_id xgmac_of_match[] = {
 	{ .compatible = "calxeda,hb-xgmac", },
@@ -1906,7 +1903,7 @@ static struct platform_driver xgmac_driver = {
 	},
 	.probe = xgmac_probe,
 	.remove = xgmac_remove,
-	.driver.pm = XGMAC_PM_OPS,
+	.driver.pm = &xgmac_pm_ops,
 };
 
 module_platform_driver(xgmac_driver);
-- 
1.7.9.5
