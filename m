From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH 1/5] can: mcp251x: Remove unneeded PM_OPS definitions
Date: Tue, 16 Apr 2013 16:28:27 -0300
Message-ID: <1366140511-3836-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <joe@perches.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0187.outbound.messaging.microsoft.com ([213.199.154.187]:21397
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964959Ab3DPT3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 15:29:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SIMPLE_DEV_PM_OPS macro can handle !CONFIG_PM_SLEEP case nicely, so there is no
need to define PM_OPS for both CONFIG_PM_SLEEP and !CONFIG_PM_SLEEP cases.

Remove the unneeded definitions.

Cc: Marc Kleine-Budde <mkl@pengutronix.de>
Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/can/mcp251x.c |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 18e4010..8cda23b 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -1200,14 +1200,10 @@ static int mcp251x_can_resume(struct device *dev)
 	enable_irq(spi->irq);
 	return 0;
 }
+#endif
 
 static SIMPLE_DEV_PM_OPS(mcp251x_can_pm_ops, mcp251x_can_suspend,
 	mcp251x_can_resume);
-#define MCP251X_PM_OPS (&mcp251x_can_pm_ops)
-
-#else
-#define MCP251X_PM_OPS NULL
-#endif
 
 static const struct spi_device_id mcp251x_id_table[] = {
 	{ "mcp2510",	CAN_MCP251X_MCP2510 },
@@ -1221,7 +1217,7 @@ static struct spi_driver mcp251x_can_driver = {
 	.driver = {
 		.name = DEVICE_NAME,
 		.owner = THIS_MODULE,
-		.pm = MCP251X_PM_OPS,
+		.pm = &mcp251x_can_pm_ops,
 	},
 
 	.id_table = mcp251x_id_table,
-- 
1.7.9.5
