From: Thomas Chou <thomas@wytron.com.tw>
Subject: [PATCH v3] smc91x: add devicetree support
Date: Tue, 25 Jan 2011 20:11:48 +0800
Message-ID: <1295957508-2701-1-git-send-email-thomas@wytron.com.tw>
References: <1295939399-4197-1-git-send-email-thomas@wytron.com.tw>
Cc: linux-kernel@vger.kernel.org, nios2-dev@sopc.et.ntust.edu.tw,
	devicetree-discuss@lists.ozlabs.org, netdev@vger.kernel.org,
	Thomas Chou <thomas@wytron.com.tw>
To: Grant Likely <grant.likely@secretlab.ca>,
	Nicolas Pitre <nico@fluxnic.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295939399-4197-1-git-send-email-thomas@wytron.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Chou <thomas@wytron.com.tw>
---
v2 specify part numbers in compat as Grant suggested.
v3 more specific part name.

 drivers/net/smc91x.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 726df61..65b2a70 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -81,6 +81,7 @@ static const char version[] =
 #include <linux/ethtool.h>
 #include <linux/mii.h>
 #include <linux/workqueue.h>
+#include <linux/of.h>
 
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -2394,6 +2395,13 @@ static int smc_drv_resume(struct device *dev)
 	return 0;
 }
 
+static const struct of_device_id smc91x_match[] = {
+	{ .compatible = "smsc,lan91c94", },
+	{ .compatible = "smsc,lan91c111", },
+	{},
+}
+MODULE_DEVICE_TABLE(of, smc91x_match);
+
 static struct dev_pm_ops smc_drv_pm_ops = {
 	.suspend	= smc_drv_suspend,
 	.resume		= smc_drv_resume,
@@ -2406,6 +2414,9 @@ static struct platform_driver smc_driver = {
 		.name	= CARDNAME,
 		.owner	= THIS_MODULE,
 		.pm	= &smc_drv_pm_ops,
+#ifdef CONFIG_OF
+		.of_match_table = smc91x_match,
+#endif
 	},
 };
 
-- 
1.7.3.5
