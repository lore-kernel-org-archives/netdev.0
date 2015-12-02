From: Thierry Reding <thierry.reding@gmail.com>
Subject: [PATCH 4/4] net: mv643xx: Use platform_register/unregister_drivers()
Date: Wed,  2 Dec 2015 17:30:29 +0100
Message-ID: <1449073829-12438-4-git-send-email-thierry.reding@gmail.com>
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

 drivers/net/ethernet/marvell/mv643xx_eth.c | 19 +++++++------------
 1 file changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 4182290fdbcf..4eba2ed53052 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -3257,25 +3257,20 @@ static struct platform_driver mv643xx_eth_driver = {
 	},
 };
 
+static struct platform_driver * const drivers[] = {
+	&mv643xx_eth_shared_driver,
+	&mv643xx_eth_driver,
+};
+
 static int __init mv643xx_eth_init_module(void)
 {
-	int rc;
-
-	rc = platform_driver_register(&mv643xx_eth_shared_driver);
-	if (!rc) {
-		rc = platform_driver_register(&mv643xx_eth_driver);
-		if (rc)
-			platform_driver_unregister(&mv643xx_eth_shared_driver);
-	}
-
-	return rc;
+	return platform_register_drivers(drivers, ARRAY_SIZE(drivers));
 }
 module_init(mv643xx_eth_init_module);
 
 static void __exit mv643xx_eth_cleanup_module(void)
 {
-	platform_driver_unregister(&mv643xx_eth_driver);
-	platform_driver_unregister(&mv643xx_eth_shared_driver);
+	platform_unregister_drivers(drivers, ARRAY_SIZE(drivers));
 }
 module_exit(mv643xx_eth_cleanup_module);
 
-- 
2.5.0
