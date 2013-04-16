From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH 3/5] tg3: Remove unneeded PM_OPS definitions
Date: Tue, 16 Apr 2013 16:28:29 -0300
Message-ID: <1366140511-3836-3-git-send-email-fabio.estevam@freescale.com>
References: <1366140511-3836-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <joe@perches.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Nithin Nayak Sujir <nsujir@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0189.outbound.messaging.microsoft.com ([213.199.154.189]:31042
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935301Ab3DPT3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 15:29:51 -0400
In-Reply-To: <1366140511-3836-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SIMPLE_DEV_PM_OPS macro can handle !CONFIG_PM_SLEEP case nicely, so there is no
need to define PM_OPS for both CONFIG_PM_SLEEP and !CONFIG_PM_SLEEP cases.

Remove the unneeded definitions.

Cc: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index ce98572..45719dd 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -17533,15 +17533,9 @@ out:
 
 	return err;
 }
+#endif /* CONFIG_PM_SLEEP */
 
 static SIMPLE_DEV_PM_OPS(tg3_pm_ops, tg3_suspend, tg3_resume);
-#define TG3_PM_OPS (&tg3_pm_ops)
-
-#else
-
-#define TG3_PM_OPS NULL
-
-#endif /* CONFIG_PM_SLEEP */
 
 /**
  * tg3_io_error_detected - called when PCI error is detected
@@ -17689,7 +17683,7 @@ static struct pci_driver tg3_driver = {
 	.probe		= tg3_init_one,
 	.remove		= tg3_remove_one,
 	.err_handler	= &tg3_err_handler,
-	.driver.pm	= TG3_PM_OPS,
+	.driver.pm	= &tg3_pm_ops,
 };
 
 static int __init tg3_init(void)
-- 
1.7.9.5
