From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH 2/5] atl1: Remove unneeded PM_OPS definitions
Date: Tue, 16 Apr 2013 16:28:28 -0300
Message-ID: <1366140511-3836-2-git-send-email-fabio.estevam@freescale.com>
References: <1366140511-3836-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <joe@perches.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Jay Cliburn <jcliburn@gmail.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0184.outbound.messaging.microsoft.com ([213.199.154.184]:22657
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753687Ab3DPT36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 15:29:58 -0400
In-Reply-To: <1366140511-3836-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SIMPLE_DEV_PM_OPS macro can handle !CONFIG_PM_SLEEP case nicely, so there is no
need to define PM_OPS for both CONFIG_PM_SLEEP and !CONFIG_PM_SLEEP cases.

Remove the unneeded definitions.

Cc: Jay Cliburn <jcliburn@gmail.com>
Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/atheros/atlx/atl1.c |   11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 9948fee..9843c70 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -2876,16 +2876,9 @@ static int atl1_resume(struct device *dev)
 
 	return 0;
 }
+#endif
 
 static SIMPLE_DEV_PM_OPS(atl1_pm_ops, atl1_suspend, atl1_resume);
-#define ATL1_PM_OPS	(&atl1_pm_ops)
-
-#else
-
-static int atl1_suspend(struct device *dev) { return 0; }
-
-#define ATL1_PM_OPS	NULL
-#endif
 
 static void atl1_shutdown(struct pci_dev *pdev)
 {
@@ -3147,7 +3140,7 @@ static struct pci_driver atl1_driver = {
 	.probe = atl1_probe,
 	.remove = atl1_remove,
 	.shutdown = atl1_shutdown,
-	.driver.pm = ATL1_PM_OPS,
+	.driver.pm = &atl1_pm_ops,
 };
 
 /**
-- 
1.7.9.5
