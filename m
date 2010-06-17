From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH v2 2/2] broadcom: Add 5241 support
Date: Thu, 17 Jun 2010 13:02:24 +0400
Message-ID: <1276765344-12675-2-git-send-email-dbaryshkov@gmail.com>
References: <1276765344-12675-1-git-send-email-dbaryshkov@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52246 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757114Ab0FQJCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jun 2010 05:02:23 -0400
Received: by fxm10 with SMTP id 10so1391856fxm.19
        for <netdev@vger.kernel.org>; Thu, 17 Jun 2010 02:02:22 -0700 (PDT)
In-Reply-To: <1276765344-12675-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the 5241 PHY ID to the broadcom module.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 drivers/net/phy/broadcom.c |   22 ++++++++++++++++++++++
 include/linux/brcmphy.h    |    1 +
 2 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index b743d37..4accd83 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -834,6 +834,21 @@ static struct phy_driver bcmac131_driver = {
 	.driver		= { .owner = THIS_MODULE },
 };
 
+static struct phy_driver bcm5241_driver = {
+	.phy_id		= PHY_ID_BCM5241,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Broadcom BCM5241",
+	.features	= PHY_BASIC_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= brcm_fet_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= brcm_fet_ack_interrupt,
+	.config_intr	= brcm_fet_config_intr,
+	.driver		= { .owner = THIS_MODULE },
+};
+
 static int __init broadcom_init(void)
 {
 	int ret;
@@ -868,8 +883,13 @@ static int __init broadcom_init(void)
 	ret = phy_driver_register(&bcmac131_driver);
 	if (ret)
 		goto out_ac131;
+	ret = phy_driver_register(&bcm5241_driver);
+	if (ret)
+		goto out_5241;
 	return ret;
 
+out_5241:
+	phy_driver_unregister(&bcmac131_driver);
 out_ac131:
 	phy_driver_unregister(&bcm57780_driver);
 out_57780:
@@ -894,6 +914,7 @@ out_5411:
 
 static void __exit broadcom_exit(void)
 {
+	phy_driver_unregister(&bcm5241_driver);
 	phy_driver_unregister(&bcmac131_driver);
 	phy_driver_unregister(&bcm57780_driver);
 	phy_driver_unregister(&bcm50610m_driver);
@@ -920,6 +941,7 @@ static struct mdio_device_id broadcom_tbl[] = {
 	{ PHY_ID_BCM50610M, 0xfffffff0 },
 	{ PHY_ID_BCM57780, 0xfffffff0 },
 	{ PHY_ID_BCMAC131, 0xfffffff0 },
+	{ PHY_ID_BCM5241, 0xfffffff0 },
 	{ }
 };
 
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index c14c3a1..b840a49 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -1,5 +1,6 @@
 #define PHY_ID_BCM50610			0x0143bd60
 #define PHY_ID_BCM50610M		0x0143bd70
+#define PHY_ID_BCM5241			0x0143bc30
 #define PHY_ID_BCMAC131			0x0143bc70
 #define PHY_ID_BCM5481			0x0143bca0
 #define PHY_ID_BCM5482			0x0143bcb0
-- 
1.7.1

