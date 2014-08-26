From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 1/4] net: phy: bcm7xxx: introduce helper macro
Date: Tue, 26 Aug 2014 13:15:24 -0700
Message-ID: <1409084127-30387-2-git-send-email-f.fainelli@gmail.com>
References: <1409084127-30387-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:55185 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754115AbaHZUQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 16:16:02 -0400
Received: by mail-pa0-f50.google.com with SMTP id et14so23798592pad.37
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 13:16:02 -0700 (PDT)
In-Reply-To: <1409084127-30387-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All 28nm Gigabit PHYs supported by the driver have the same
callbacks, the only differences being the 32-bits OUI and the name. Use
a macro to factor this, making it easier in the future to add new
entries.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 54 ++++++++++++++++-------------------------------
 1 file changed, 18 insertions(+), 36 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index e98c510b75c5..948c7086679a 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -319,44 +319,26 @@ static int bcm7xxx_dummy_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+#define BCM7XXX_28NM_GPHY(_oui, _name)					\
+{									\
+	.phy_id		= (_oui),					\
+	.phy_id_mask	= 0xfffffff0,					\
+	.name		= _name,					\
+	.features	= PHY_GBIT_FEATURES |				\
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,	\
+	.flags		= PHY_IS_INTERNAL,				\
+	.config_init	= bcm7xxx_28nm_afe_config_init,			\
+	.config_aneg	= genphy_config_aneg,				\
+	.read_status	= genphy_read_status,				\
+	.resume		= bcm7xxx_28nm_resume,				\
+	.driver		= { .owner = THIS_MODULE },			\
+}
+
 static struct phy_driver bcm7xxx_driver[] = {
+	BCM7XXX_28NM_GPHY(PHY_ID_BCM7366, "Broadcom BCM7366"),
+	BCM7XXX_28NM_GPHY(PHY_ID_BCM7439, "Broadcom BCM7439"),
+	BCM7XXX_28NM_GPHY(PHY_ID_BCM7445, "Broadcom BCM7445"),
 {
-	.phy_id		= PHY_ID_BCM7366,
-	.phy_id_mask	= 0xfffffff0,
-	.name		= "Broadcom BCM7366",
-	.features	= PHY_GBIT_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
-	.flags		= PHY_IS_INTERNAL,
-	.config_init	= bcm7xxx_28nm_afe_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
-	.resume		= bcm7xxx_28nm_resume,
-	.driver		= { .owner = THIS_MODULE },
-}, {
-	.phy_id		= PHY_ID_BCM7439,
-	.phy_id_mask	= 0xfffffff0,
-	.name		= "Broadcom BCM7439",
-	.features	= PHY_GBIT_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
-	.flags		= PHY_IS_INTERNAL,
-	.config_init	= bcm7xxx_28nm_afe_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
-	.resume		= bcm7xxx_28nm_resume,
-	.driver		= { .owner = THIS_MODULE },
-}, {
-	.phy_id		= PHY_ID_BCM7445,
-	.phy_id_mask	= 0xfffffff0,
-	.name		= "Broadcom BCM7445",
-	.features	= PHY_GBIT_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
-	.flags		= PHY_IS_INTERNAL,
-	.config_init	= bcm7xxx_28nm_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
-	.resume		= bcm7xxx_28nm_afe_config_init,
-	.driver		= { .owner = THIS_MODULE },
-}, {
 	.phy_id		= PHY_BCM_OUI_4,
 	.phy_id_mask	= 0xffff0000,
 	.name		= "Broadcom BCM7XXX 40nm",
-- 
1.9.1
