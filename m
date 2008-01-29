From: Nate Case <ncase@xes-inc.com>
Subject: [PATCH] PHYLIB: Add BCM5482 PHY support
Date: Tue, 29 Jan 2008 10:19:00 -0600
Message-ID: <1201623540.12444.121.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xes-mad.com ([216.165.139.214]:39784 "EHLO xes-mad.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932844AbYA2QTH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 11:19:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This Broadcom PHY is similar to other bcm54xx devices.

Signed-off-by: Nate Case <ncase@xes-inc.com>
---
 drivers/net/phy/broadcom.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 29666c8..5b80358 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -141,6 +141,20 @@ static struct phy_driver bcm5461_driver = {
 	.driver 	= { .owner = THIS_MODULE },
 };
 
+static struct phy_driver bcm5482_driver = {
+    .phy_id		= 0x0143bcb0,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Broadcom BCM5482",
+	.features	= PHY_GBIT_FEATURES,
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
@@ -154,8 +168,13 @@ static int __init broadcom_init(void)
 	ret = phy_driver_register(&bcm5461_driver);
 	if (ret)
 		goto out_5461;
+	ret = phy_driver_register(&bcm5482_driver);
+	if (ret)
+		goto out_5482;
 	return ret;
 
+out_5482:
+	phy_driver_unregister(&bcm5461_driver);
 out_5461:
 	phy_driver_unregister(&bcm5421_driver);
 out_5421:
@@ -166,6 +185,7 @@ out_5411:
 
 static void __exit broadcom_exit(void)
 {
+	phy_driver_unregister(&bcm5482_driver);
 	phy_driver_unregister(&bcm5461_driver);
 	phy_driver_unregister(&bcm5421_driver);
 	phy_driver_unregister(&bcm5411_driver);
-- 
1.5.3.3



