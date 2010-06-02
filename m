From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Subject: [PATCH] fec: convert legacy PM hooks to dem_pm_ops
Date: Wed, 2 Jun 2010 19:27:04 +0000
Message-ID: <20100602192704.GA22726@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: s.hauer@pengutronix.de, eric@eukrea.com, gerg@uclinux.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:51728 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932897Ab0FBT1U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jun 2010 15:27:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch compile tested only.

Convert legacy PM hooks to dev_pm_ops
Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
drivers/net/fec.c |   24 +++++++++++++++++++++---
 1 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 42d9ac9..6990791 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1339,6 +1339,8 @@ fec_drv_remove(struct platform_device *pdev)
 	return 0;
 }
 
+#ifdef CONFIG_PM
+
 static int
 fec_suspend(struct platform_device *dev, pm_message_t state)
 {
@@ -1369,15 +1371,31 @@ fec_resume(struct platform_device *dev)
 	return 0;
 }
 
+static const struct dev_pm_ops fec_pm_ops = {
+	.suspend	= fec_suspend,
+	.resume		= fec_resume,
+	.freeze		= fec_suspend,
+	.thaw		= fec_resume,
+	.poweroff	= fec_suspend,
+	.restore	= fec_resume,
+};
+
+#define FEC_PM_OPS (&fec_pm_ops)
+
+#else /* !CONFIG_PM */
+
+#define FEC_PM_OPS NULL
+
+#endif /* !CONFIG_PM */
+
 static struct platform_driver fec_driver = {
 	.driver	= {
 		.name    = "fec",
 		.owner	 = THIS_MODULE,
+		.pm		 = FEC_PM_OPS,
 	},
 	.probe   = fec_probe,
 	.remove  = __devexit_p(fec_drv_remove),
-	.suspend = fec_suspend,
-	.resume  = fec_resume,
 };
 
 static int __init
