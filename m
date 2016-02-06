From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2 4/4] net: phy: bcm7xxx: Remove wildcard entries
Date: Sat,  6 Feb 2016 12:58:51 -0800
Message-ID: <1454792331-4435-5-git-send-email-f.fainelli@gmail.com>
References: <1454792331-4435-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	opendmb@gmail.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34952 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752872AbcBFU67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 15:58:59 -0500
Received: by mail-pf0-f177.google.com with SMTP id c10so21330011pfc.2
        for <netdev@vger.kernel.org>; Sat, 06 Feb 2016 12:58:59 -0800 (PST)
In-Reply-To: <1454792331-4435-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the two wildcard entries, they serve no purpose and will match way too
many devices, some of them being covered by the driver in
drivers/net/phy/broadcom.c. Remove the now unused bcm7xxx_dummy_config_init()
function which would produce a warning.

Fixes: b560a58c45c6 ("net: phy: add Broadcom BCM7xxx internal PHY driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c |   31 -------------------------------
 1 files changed, 0 insertions(+), 31 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 568768a..db507e3 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -303,11 +303,6 @@ static int bcm7xxx_suspend(struct phy_device *phydev)
 	return 0;
 }
 
-static int bcm7xxx_dummy_config_init(struct phy_device *phydev)
-{
-	return 0;
-}
-
 #define BCM7XXX_28NM_GPHY(_oui, _name)					\
 {									\
 	.phy_id		= (_oui),					\
@@ -365,30 +360,6 @@ static struct phy_driver bcm7xxx_driver[] = {
 	.read_status    = genphy_read_status,
 	.suspend        = bcm7xxx_suspend,
 	.resume         = bcm7xxx_config_init,
-}, {
-	.phy_id		= PHY_BCM_OUI_4,
-	.phy_id_mask	= 0xffff0000,
-	.name		= "Broadcom BCM7XXX 40nm",
-	.features	= PHY_GBIT_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
-	.flags		= PHY_IS_INTERNAL,
-	.config_init	= bcm7xxx_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
-	.suspend	= bcm7xxx_suspend,
-	.resume		= bcm7xxx_config_init,
-}, {
-	.phy_id		= PHY_BCM_OUI_5,
-	.phy_id_mask	= 0xffffff00,
-	.name		= "Broadcom BCM7XXX 65nm",
-	.features	= PHY_BASIC_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
-	.flags		= PHY_IS_INTERNAL,
-	.config_init	= bcm7xxx_dummy_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
-	.suspend	= bcm7xxx_suspend,
-	.resume		= bcm7xxx_config_init,
 } };
 
 static struct mdio_device_id __maybe_unused bcm7xxx_tbl[] = {
@@ -400,8 +371,6 @@ static struct mdio_device_id __maybe_unused bcm7xxx_tbl[] = {
 	{ PHY_ID_BCM7439, 0xfffffff0, },
 	{ PHY_ID_BCM7435, 0xfffffff0, },
 	{ PHY_ID_BCM7445, 0xfffffff0, },
-	{ PHY_BCM_OUI_4, 0xffff0000 },
-	{ PHY_BCM_OUI_5, 0xffffff00 },
 	{ }
 };
 
-- 
1.7.1
