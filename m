From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: [PATCH] sh_eth: pm_runtime should not need null operations
Date: Fri, 21 Mar 2014 11:15:13 +0100
Message-ID: <1395396913-24354-1-git-send-email-ben.dooks@codethink.co.uk>
Cc: linux-sh@vger.kernel.org, davem@davemloft.net,
	Ben Dooks <ben.dooks@codethink.co.uk>
To: linux-kernel@lists.codethink.co.uk, netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver has a no-op for the pm_runtime callbacks but
the pm_runtime core should correctly ignore drivers without
any pm_rumtime callback ops.

Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
---
 drivers/net/ethernet/renesas/sh_eth.c | 23 -----------------------
 1 file changed, 23 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index b908507..bb93333e 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2998,28 +2998,6 @@ static int sh_eth_drv_remove(struct platform_device *pdev)
 	return 0;
 }
 
-#ifdef CONFIG_PM
-static int sh_eth_runtime_nop(struct device *dev)
-{
-	/* Runtime PM callback shared between ->runtime_suspend()
-	 * and ->runtime_resume(). Simply returns success.
-	 *
-	 * This driver re-initializes all registers after
-	 * pm_runtime_get_sync() anyway so there is no need
-	 * to save and restore registers here.
-	 */
-	return 0;
-}
-
-static const struct dev_pm_ops sh_eth_dev_pm_ops = {
-	.runtime_suspend = sh_eth_runtime_nop,
-	.runtime_resume = sh_eth_runtime_nop,
-};
-#define SH_ETH_PM_OPS (&sh_eth_dev_pm_ops)
-#else
-#define SH_ETH_PM_OPS NULL
-#endif
-
 static struct platform_device_id sh_eth_id_table[] = {
 	{ "sh7619-ether", (kernel_ulong_t)&sh7619_data },
 	{ "sh771x-ether", (kernel_ulong_t)&sh771x_data },
@@ -3043,7 +3021,6 @@ static struct platform_driver sh_eth_driver = {
 	.id_table = sh_eth_id_table,
 	.driver = {
 		   .name = CARDNAME,
-		   .pm = SH_ETH_PM_OPS,
 		   .of_match_table = of_match_ptr(sh_eth_match_table),
 	},
 };
-- 
1.9.0

