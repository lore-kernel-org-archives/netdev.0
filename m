From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH 1/6 RESEND] Add support for the Davicom DM9161A PHY
Date: Thu, 10 May 2007 15:16:04 -0500
Message-ID: <20070510151604.6d8c58b4.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:51049 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755707AbXEJUQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 16:16:18 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Distinguish between the Davicom DM9161A PHY and the DM9161E.

Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
resend of the one of six in the series Jeff didn't receive.

 drivers/net/phy/davicom.c |   34 ++++++++++++++++++++++++++--------
 1 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/davicom.c b/drivers/net/phy/davicom.c
index 519baa3..7ed632d 100644
--- a/drivers/net/phy/davicom.c
+++ b/drivers/net/phy/davicom.c
@@ -139,7 +139,7 @@ static int dm9161_ack_interrupt(struct phy_device *phydev)
 	return (err < 0) ? err : 0;
 }
 
-static struct phy_driver dm9161_driver = {
+static struct phy_driver dm9161e_driver = {
 	.phy_id		= 0x0181b880,
 	.name		= "Davicom DM9161E",
 	.phy_id_mask	= 0x0ffffff0,
@@ -147,7 +147,18 @@ static struct phy_driver dm9161_driver = {
 	.config_init	= dm9161_config_init,
 	.config_aneg	= dm9161_config_aneg,
 	.read_status	= genphy_read_status,
-	.driver 	= { .owner = THIS_MODULE,},
+	.driver		= { .owner = THIS_MODULE,},
+};
+
+static struct phy_driver dm9161a_driver = {
+	.phy_id		= 0x0181b8a0,
+	.name		= "Davicom DM9161A",
+	.phy_id_mask	= 0x0ffffff0,
+	.features	= PHY_BASIC_FEATURES,
+	.config_init	= dm9161_config_init,
+	.config_aneg	= dm9161_config_aneg,
+	.read_status	= genphy_read_status,
+	.driver		= { .owner = THIS_MODULE,},
 };
 
 static struct phy_driver dm9131_driver = {
@@ -160,31 +171,38 @@ static struct phy_driver dm9131_driver = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= dm9161_ack_interrupt,
 	.config_intr	= dm9161_config_intr,
-	.driver 	= { .owner = THIS_MODULE,},
+	.driver		= { .owner = THIS_MODULE,},
 };
 
 static int __init davicom_init(void)
 {
 	int ret;
 
-	ret = phy_driver_register(&dm9161_driver);
+	ret = phy_driver_register(&dm9161e_driver);
 	if (ret)
 		goto err1;
 
-	ret = phy_driver_register(&dm9131_driver);
+	ret = phy_driver_register(&dm9161a_driver);
 	if (ret)
 		goto err2;
+
+	ret = phy_driver_register(&dm9131_driver);
+	if (ret)
+		goto err3;
 	return 0;
 
- err2:	
-	phy_driver_unregister(&dm9161_driver);
+ err3:
+	phy_driver_unregister(&dm9161a_driver);
+ err2:
+	phy_driver_unregister(&dm9161e_driver);
  err1:
 	return ret;
 }
 
 static void __exit davicom_exit(void)
 {
-	phy_driver_unregister(&dm9161_driver);
+	phy_driver_unregister(&dm9161e_driver);
+	phy_driver_unregister(&dm9161a_driver);
 	phy_driver_unregister(&dm9131_driver);
 }
 
-- 
1.5.0.3

