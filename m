From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v5 8/8] sh_eth: enclose PM code into #ifdef CONFIG_PM
Date: Thu, 6 Jun 2013 23:52:37 +0400
Message-ID: <201306062352.38151.sergei.shtylyov@cogentembedded.com>
References: <201306062339.21353.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201306062339.21353.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

Put '#ifdef CONFIG_PM' around sh_eth_runtime_nop() and 'sh_eth_dev_pm_ops'.
Add '#define SH_ETH_PM_OPS' to facilitate initialization of driver's 'pm' field
depending on whether CONFIG_PM is enabled. 

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
[Sergei: added the changelog, reworded the subject, changing the prefix.]
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Changes in version 5:
-refreshed the patch.

Changes in version 4:
- refreshed the patch;
- added the changelog;
- reworded the subject, changing the prefix.

Changes in version 3:
- fixed "ERROR: Macros with complex values should be enclosed in parenthesis" by
  scripts/checkpatch.pl.

 drivers/net/ethernet/renesas/sh_eth.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -2673,6 +2673,7 @@ static int sh_eth_drv_remove(struct plat
 	return 0;
 }
 
+#ifdef CONFIG_PM
 static int sh_eth_runtime_nop(struct device *dev)
 {
 	/*
@@ -2686,17 +2687,21 @@ static int sh_eth_runtime_nop(struct dev
 	return 0;
 }
 
-static struct dev_pm_ops sh_eth_dev_pm_ops = {
+static const struct dev_pm_ops sh_eth_dev_pm_ops = {
 	.runtime_suspend = sh_eth_runtime_nop,
 	.runtime_resume = sh_eth_runtime_nop,
 };
+#define SH_ETH_PM_OPS (&sh_eth_dev_pm_ops)
+#else
+#define SH_ETH_PM_OPS NULL
+#endif
 
 static struct platform_driver sh_eth_driver = {
 	.probe = sh_eth_drv_probe,
 	.remove = sh_eth_drv_remove,
 	.driver = {
 		   .name = CARDNAME,
-		   .pm = &sh_eth_dev_pm_ops,
+		   .pm = SH_ETH_PM_OPS,
 	},
 };
 

