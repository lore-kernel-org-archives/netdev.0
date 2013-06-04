From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 1/8] drivers: net: phy: at803x code cleanup on register and unregister driver
Date: Tue, 4 Jun 2013 11:40:04 +0530
Message-ID: <1370326212-17580-2-git-send-email-mugunthanvnm@ti.com>
References: <1370326212-17580-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <benoit.cousson@linaro.org>,
	<paul@pwsan.com>, Mugunthan V N <mugunthanvnm@ti.com>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:35177 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751383Ab3FDGJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jun 2013 02:09:40 -0400
In-Reply-To: <1370326212-17580-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make use of phy_drivers_register/phy_drivers_unregister to register/unregister
multiple phy drivers in a single module.

Cc: Matus Ujhelyi <ujhelyi.m@gmail.com>
Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/phy/at803x.c |   35 ++++++++++-------------------------
 1 file changed, 10 insertions(+), 25 deletions(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index 45cbc10..a1063e1 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -108,8 +108,9 @@ static int at803x_config_init(struct phy_device *phydev)
 	return 0;
 }
 
-/* ATHEROS 8035 */
-static struct phy_driver at8035_driver = {
+static struct phy_driver at803x_driver[] = {
+{
+	/* ATHEROS 8035 */
 	.phy_id		= 0x004dd072,
 	.name		= "Atheros 8035 ethernet",
 	.phy_id_mask	= 0xffffffef,
@@ -121,10 +122,8 @@ static struct phy_driver at8035_driver = {
 	.driver		= {
 		.owner = THIS_MODULE,
 	},
-};
-
-/* ATHEROS 8030 */
-static struct phy_driver at8030_driver = {
+}, {
+	/* ATHEROS 8030 */
 	.phy_id		= 0x004dd076,
 	.name		= "Atheros 8030 ethernet",
 	.phy_id_mask	= 0xffffffef,
@@ -136,32 +135,18 @@ static struct phy_driver at8030_driver = {
 	.driver		= {
 		.owner = THIS_MODULE,
 	},
-};
+} };
 
 static int __init atheros_init(void)
 {
-	int ret;
-
-	ret = phy_driver_register(&at8035_driver);
-	if (ret)
-		goto err1;
-
-	ret = phy_driver_register(&at8030_driver);
-	if (ret)
-		goto err2;
-
-	return 0;
-
-err2:
-	phy_driver_unregister(&at8035_driver);
-err1:
-	return ret;
+	return phy_drivers_register(at803x_driver,
+				    ARRAY_SIZE(at803x_driver));
 }
 
 static void __exit atheros_exit(void)
 {
-	phy_driver_unregister(&at8035_driver);
-	phy_driver_unregister(&at8030_driver);
+	return phy_drivers_unregister(at803x_driver,
+				      ARRAY_SIZE(at803x_driver));
 }
 
 module_init(atheros_init);
-- 
1.7.9.5
