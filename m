From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 09/10] broadcom: Add 57780 support
Date: Fri, 21 Nov 2008 11:03:32 -0800
Message-ID: <1227295576.5628@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4268 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754156AbYKUT01 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 14:26:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the 57780 PHY ID to the broadcom module.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/phy/broadcom.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index fd4fc66..190efc3 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -540,6 +540,21 @@ static struct phy_driver bcm50610_driver = {
 	.driver 	= { .owner = THIS_MODULE },
 };
 
+static struct phy_driver bcm57780_driver = {
+	.phy_id		= 0x03625d90,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Broadcom BCM57780",
+	.features	= PHY_GBIT_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= bcm54xx_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= bcm54xx_ack_interrupt,
+	.config_intr	= bcm54xx_config_intr,
+	.driver 	= { .owner = THIS_MODULE },
+};
+
 static int __init broadcom_init(void)
 {
 	int ret;
@@ -565,8 +580,13 @@ static int __init broadcom_init(void)
 	ret = phy_driver_register(&bcm50610_driver);
 	if (ret)
 		goto out_50610;
+	ret = phy_driver_register(&bcm57780_driver);
+	if (ret)
+		goto out_57780;
 	return ret;
 
+out_57780:
+	phy_driver_unregister(&bcm50610_driver);
 out_50610:
 	phy_driver_unregister(&bcm5482_driver);
 out_5482:
@@ -585,6 +605,7 @@ out_5411:
 
 static void __exit broadcom_exit(void)
 {
+	phy_driver_unregister(&bcm57780_driver);
 	phy_driver_unregister(&bcm50610_driver);
 	phy_driver_unregister(&bcm5482_driver);
 	phy_driver_unregister(&bcm5481_driver);
-- 
1.5.6.4



