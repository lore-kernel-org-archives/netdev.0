From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH 5/5] ks8851: Remove unneeded PM_OPS definitions
Date: Tue, 16 Apr 2013 16:28:31 -0300
Message-ID: <1366140511-3836-5-git-send-email-fabio.estevam@freescale.com>
References: <1366140511-3836-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <joe@perches.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Lars-Peter Clausen <lars@metafoo.de>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe001.messaging.microsoft.com ([207.46.163.24]:59440
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753837Ab3DPT24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 15:28:56 -0400
In-Reply-To: <1366140511-3836-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SIMPLE_DEV_PM_OPS macro can handle !CONFIG_PM_SLEEP case nicely, so there is no
need to define PM_OPS for both CONFIG_PM_SLEEP and !CONFIG_PM_SLEEP cases.

Remove the unneeded definitions.

Cc: Lars-Peter Clausen <lars@metafoo.de>
Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/micrel/ks8851.c |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index da64960..727b546a 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -1391,13 +1391,9 @@ static int ks8851_resume(struct device *dev)
 
 	return 0;
 }
+#endif
 
 static SIMPLE_DEV_PM_OPS(ks8851_pm_ops, ks8851_suspend, ks8851_resume);
-#define KS8851_PM_OPS (&ks8851_pm_ops)
-
-#else
-#define KS8851_PM_OPS NULL
-#endif
 
 static int ks8851_probe(struct spi_device *spi)
 {
@@ -1536,7 +1532,7 @@ static struct spi_driver ks8851_driver = {
 	.driver = {
 		.name = "ks8851",
 		.owner = THIS_MODULE,
-		.pm = KS8851_PM_OPS,
+		.pm = &ks8851_pm_ops,
 	},
 	.probe = ks8851_probe,
 	.remove = ks8851_remove,
-- 
1.7.9.5
