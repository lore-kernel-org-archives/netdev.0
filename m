From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [PATCH] net: Drop owner assignment from platform_driver
Date: Fri, 10 Jul 2015 15:29:23 +0900
Message-ID: <1436509763-23980-1-git-send-email-k.kozlowski@samsung.com>
Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>
To: Wingman Kwok <w-kwok2@ti.com>,
	Murali Karicheri <m-karicheri2@ti.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

platform_driver does not need to set an owner because
platform_driver_register() will set it.

Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>

---

The coccinelle script which generated the patch was sent here:
http://www.spinics.net/lists/kernel/msg2029903.html
---
 drivers/net/ethernet/hisilicon/hip04_eth.c  | 1 -
 drivers/net/ethernet/hisilicon/hip04_mdio.c | 1 -
 drivers/net/ethernet/ti/netcp_core.c        | 1 -
 3 files changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
index d49bee38cd31..cc2d8b4b18e3 100644
--- a/drivers/net/ethernet/hisilicon/hip04_eth.c
+++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
@@ -965,7 +965,6 @@ static struct platform_driver hip04_mac_driver = {
 	.remove	= hip04_remove,
 	.driver	= {
 		.name		= DRV_NAME,
-		.owner		= THIS_MODULE,
 		.of_match_table	= hip04_mac_match,
 	},
 };
diff --git a/drivers/net/ethernet/hisilicon/hip04_mdio.c b/drivers/net/ethernet/hisilicon/hip04_mdio.c
index b3bac25db99c..fca0a5be1f0f 100644
--- a/drivers/net/ethernet/hisilicon/hip04_mdio.c
+++ b/drivers/net/ethernet/hisilicon/hip04_mdio.c
@@ -174,7 +174,6 @@ static struct platform_driver hip04_mdio_driver = {
 	.remove = hip04_mdio_remove,
 	.driver = {
 		.name = "hip04-mdio",
-		.owner = THIS_MODULE,
 		.of_match_table = hip04_mdio_match,
 	},
 };
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 5ec4ed3f6c8d..3e47202b9010 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -2142,7 +2142,6 @@ MODULE_DEVICE_TABLE(of, of_match);
 static struct platform_driver netcp_driver = {
 	.driver = {
 		.name		= "netcp-1.0",
-		.owner		= THIS_MODULE,
 		.of_match_table	= of_match,
 	},
 	.probe = netcp_probe,
-- 
1.9.1
