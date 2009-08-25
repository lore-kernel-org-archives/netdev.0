From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 09/12] broadcom: Add BCM50610M support
Date: Tue, 25 Aug 2009 13:10:30 -0700
Message-ID: <1251232430.25415@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4229 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756066AbZHYUeZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2009 16:34:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the BCM50610M phy ID.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/phy/broadcom.c |   38 ++++++++++++++++++++++++++++++--------
 1 files changed, 30 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 190efc3..dec4dec 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -18,6 +18,7 @@
 #include <linux/phy.h>
 
 #define PHY_ID_BCM50610		0x0143bd60
+#define PHY_ID_BCM50610M	0x0143bd70
 
 #define MII_BCM54XX_ECR		0x10	/* BCM54xx extended control register */
 #define MII_BCM54XX_ECR_IM	0x1000	/* Interrupt mask */
@@ -447,7 +448,7 @@ static struct phy_driver bcm5411_driver = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
-	.driver 	= { .owner = THIS_MODULE },
+	.driver		= { .owner = THIS_MODULE },
 };
 
 static struct phy_driver bcm5421_driver = {
@@ -462,7 +463,7 @@ static struct phy_driver bcm5421_driver = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
-	.driver 	= { .owner = THIS_MODULE },
+	.driver		= { .owner = THIS_MODULE },
 };
 
 static struct phy_driver bcm5461_driver = {
@@ -477,7 +478,7 @@ static struct phy_driver bcm5461_driver = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
-	.driver 	= { .owner = THIS_MODULE },
+	.driver		= { .owner = THIS_MODULE },
 };
 
 static struct phy_driver bcm5464_driver = {
@@ -492,7 +493,7 @@ static struct phy_driver bcm5464_driver = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
-	.driver 	= { .owner = THIS_MODULE },
+	.driver		= { .owner = THIS_MODULE },
 };
 
 static struct phy_driver bcm5481_driver = {
@@ -507,7 +508,7 @@ static struct phy_driver bcm5481_driver = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
-	.driver 	= { .owner = THIS_MODULE },
+	.driver		= { .owner = THIS_MODULE },
 };
 
 static struct phy_driver bcm5482_driver = {
@@ -522,7 +523,7 @@ static struct phy_driver bcm5482_driver = {
 	.read_status	= bcm5482_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
-	.driver 	= { .owner = THIS_MODULE },
+	.driver		= { .owner = THIS_MODULE },
 };
 
 static struct phy_driver bcm50610_driver = {
@@ -537,7 +538,22 @@ static struct phy_driver bcm50610_driver = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
-	.driver 	= { .owner = THIS_MODULE },
+	.driver		= { .owner = THIS_MODULE },
+};
+
+static struct phy_driver bcm50610m_driver = {
+	.phy_id		= PHY_ID_BCM50610M,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Broadcom BCM50610M",
+	.features	= PHY_GBIT_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= bcm54xx_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= bcm54xx_ack_interrupt,
+	.config_intr	= bcm54xx_config_intr,
+	.driver		= { .owner = THIS_MODULE },
 };
 
 static struct phy_driver bcm57780_driver = {
@@ -552,7 +568,7 @@ static struct phy_driver bcm57780_driver = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
-	.driver 	= { .owner = THIS_MODULE },
+	.driver		= { .owner = THIS_MODULE },
 };
 
 static int __init broadcom_init(void)
@@ -580,12 +596,17 @@ static int __init broadcom_init(void)
 	ret = phy_driver_register(&bcm50610_driver);
 	if (ret)
 		goto out_50610;
+	ret = phy_driver_register(&bcm50610m_driver);
+	if (ret)
+		goto out_50610m;
 	ret = phy_driver_register(&bcm57780_driver);
 	if (ret)
 		goto out_57780;
 	return ret;
 
 out_57780:
+	phy_driver_unregister(&bcm50610m_driver);
+out_50610m:
 	phy_driver_unregister(&bcm50610_driver);
 out_50610:
 	phy_driver_unregister(&bcm5482_driver);
@@ -606,6 +627,7 @@ out_5411:
 static void __exit broadcom_exit(void)
 {
 	phy_driver_unregister(&bcm57780_driver);
+	phy_driver_unregister(&bcm50610m_driver);
 	phy_driver_unregister(&bcm50610_driver);
 	phy_driver_unregister(&bcm5482_driver);
 	phy_driver_unregister(&bcm5481_driver);
-- 
1.6.3.3


