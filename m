From: Thierry Reding <thierry.reding@gmail.com>
Subject: [PATCH 3/4] net: mpc52xx: Use platform_register/unregister_drivers()
Date: Wed,  2 Dec 2015 17:30:28 +0100
Message-ID: <1449073829-12438-3-git-send-email-thierry.reding@gmail.com>
References: <1449073829-12438-1-git-send-email-thierry.reding@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449073829-12438-1-git-send-email-thierry.reding@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

These new helpers simplify implementing multi-driver modules and
properly handle failure to register one driver by unregistering all
previously registered drivers.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
Applies on top of next-20151127.

 drivers/net/ethernet/freescale/fec_mpc52xx.c | 22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index afe7f39cdd7c..25553ee857b4 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -1084,27 +1084,23 @@ static struct platform_driver mpc52xx_fec_driver = {
 /* Module                                                                   */
 /* ======================================================================== */
 
+static struct platform_driver * const drivers[] = {
+#ifdef CONFIG_FEC_MPC52xx_MDIO
+	&mpc52xx_fec_mdio_driver,
+#endif
+	&mpc52xx_fec_driver,
+};
+
 static int __init
 mpc52xx_fec_init(void)
 {
-#ifdef CONFIG_FEC_MPC52xx_MDIO
-	int ret;
-	ret = platform_driver_register(&mpc52xx_fec_mdio_driver);
-	if (ret) {
-		pr_err("failed to register mdio driver\n");
-		return ret;
-	}
-#endif
-	return platform_driver_register(&mpc52xx_fec_driver);
+	return platform_register_drivers(drivers, ARRAY_SIZE(drivers));
 }
 
 static void __exit
 mpc52xx_fec_exit(void)
 {
-	platform_driver_unregister(&mpc52xx_fec_driver);
-#ifdef CONFIG_FEC_MPC52xx_MDIO
-	platform_driver_unregister(&mpc52xx_fec_mdio_driver);
-#endif
+	platform_unregister_drivers(drivers, ARRAY_SIZE(drivers));
 }
 
 
-- 
2.5.0
