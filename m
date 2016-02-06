From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: phy: bcm7xxx: Reduce boilerplate code for 40nm EPHY
Date: Sat,  6 Feb 2016 13:09:37 -0800
Message-ID: <1454792977-7987-3-git-send-email-f.fainelli@gmail.com>
References: <1454792977-7987-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	opendmb@gmail.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34598 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752716AbcBFVJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 16:09:44 -0500
Received: by mail-pf0-f176.google.com with SMTP id o185so87872797pfb.1
        for <netdev@vger.kernel.org>; Sat, 06 Feb 2016 13:09:44 -0800 (PST)
In-Reply-To: <1454792977-7987-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a macro which helps adding new 40NM EPHY entries and reduces the
amount of boilerplate code.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c |   54 +++++++++++++++------------------------------
 1 files changed, 18 insertions(+), 36 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 6215185..9b31104 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -326,6 +326,21 @@ static int bcm7xxx_dummy_config_init(struct phy_device *phydev)
 	.resume		= bcm7xxx_28nm_resume,				\
 }
 
+#define BCM7XXX_40NM_EPHY(_oui, _name)					\
+{									\
+	.phy_id         = (_oui),					\
+	.phy_id_mask    = 0xfffffff0,					\
+	.name           = _name,					\
+	.features       = PHY_BASIC_FEATURES |				\
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,	\
+	.flags          = PHY_IS_INTERNAL,				\
+	.config_init    = bcm7xxx_config_init,				\
+	.config_aneg    = genphy_config_aneg,				\
+	.read_status    = genphy_read_status,				\
+	.suspend        = bcm7xxx_suspend,				\
+	.resume         = bcm7xxx_config_init,				\
+}
+
 static struct phy_driver bcm7xxx_driver[] = {
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7250, "Broadcom BCM7250"),
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7364, "Broadcom BCM7364"),
@@ -333,43 +348,10 @@ static struct phy_driver bcm7xxx_driver[] = {
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7439, "Broadcom BCM7439"),
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7439_2, "Broadcom BCM7439 (2)"),
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7445, "Broadcom BCM7445"),
+	BCM7XXX_40NM_EPHY(PHY_ID_BCM7425, "Broadcom BCM7425"),
+	BCM7XXX_40NM_EPHY(PHY_ID_BCM7429, "Broadcom BCM7429"),
+	BCM7XXX_40NM_EPHY(PHY_ID_BCM7435, "Broadcom BCM7435"),
 {
-	.phy_id         = PHY_ID_BCM7425,
-	.phy_id_mask    = 0xfffffff0,
-	.name           = "Broadcom BCM7425",
-	.features       = PHY_GBIT_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
-	.flags          = PHY_IS_INTERNAL,
-	.config_init    = bcm7xxx_config_init,
-	.config_aneg    = genphy_config_aneg,
-	.read_status    = genphy_read_status,
-	.suspend        = bcm7xxx_suspend,
-	.resume         = bcm7xxx_config_init,
-}, {
-	.phy_id         = PHY_ID_BCM7429,
-	.phy_id_mask    = 0xfffffff0,
-	.name           = "Broadcom BCM7429",
-	.features       = PHY_GBIT_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
-	.flags          = PHY_IS_INTERNAL,
-	.config_init    = bcm7xxx_config_init,
-	.config_aneg    = genphy_config_aneg,
-	.read_status    = genphy_read_status,
-	.suspend        = bcm7xxx_suspend,
-	.resume         = bcm7xxx_config_init,
-}, {
-	.phy_id         = PHY_ID_BCM7435,
-	.phy_id_mask    = 0xfffffff0,
-	.name           = "Broadcom BCM7435",
-	.features       = PHY_GBIT_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
-	.flags          = PHY_IS_INTERNAL,
-	.config_init    = bcm7xxx_config_init,
-	.config_aneg    = genphy_config_aneg,
-	.read_status    = genphy_read_status,
-	.suspend        = bcm7xxx_suspend,
-	.resume         = bcm7xxx_config_init,
-}, {
 	.phy_id		= PHY_BCM_OUI_4,
 	.phy_id_mask	= 0xffff0000,
 	.name		= "Broadcom BCM7XXX 40nm",
-- 
1.7.1
