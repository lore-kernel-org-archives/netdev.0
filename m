From: Thierry Reding <thierry.reding@gmail.com>
Subject: [PATCH 1/4] net: bfin_mac: Use platform_register/unregister_drivers()
Date: Wed,  2 Dec 2015 17:30:26 +0100
Message-ID: <1449073829-12438-1-git-send-email-thierry.reding@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

These new helpers simplify implementing multi-driver modules and
properly handle failure to register one driver by unregistering all
previously registered drivers.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
Applies on top of next-20151127.

 drivers/net/ethernet/adi/bfin_mac.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 096531a73124..e0e95a15cab0 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1912,21 +1912,21 @@ static struct platform_driver bfin_mac_driver = {
 	},
 };
 
+static struct platform_driver * const drivers[] = {
+	&bfin_mii_bus_driver,
+	&bfin_mac_driver,
+};
+
 static int __init bfin_mac_init(void)
 {
-	int ret;
-	ret = platform_driver_register(&bfin_mii_bus_driver);
-	if (!ret)
-		return platform_driver_register(&bfin_mac_driver);
-	return -ENODEV;
+	return platform_register_drivers(drivers, ARRAY_SIZE(drivers));
 }
 
 module_init(bfin_mac_init);
 
 static void __exit bfin_mac_cleanup(void)
 {
-	platform_driver_unregister(&bfin_mac_driver);
-	platform_driver_unregister(&bfin_mii_bus_driver);
+	platform_unregister_drivers(drivers, ARRAY_SIZE(drivers));
 }
 
 module_exit(bfin_mac_cleanup);
-- 
2.5.0
