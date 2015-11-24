From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: phy: bcm7xxx: Add entry for Broadcom BCM7435
Date: Tue, 24 Nov 2015 15:30:21 -0800
Message-ID: <1448407821-22390-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, jaedon.shin@gmail.com, pgynther@google.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33440 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754161AbbKXXbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 18:31:33 -0500
Received: by pabfh17 with SMTP id fh17so37776249pab.0
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 15:31:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a PHY entry for the Broadcom BCM7435 chips, this is a 40nm
generation Ethernet PHY which is analogous to its 7425 and 7429 counter
parts.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 14 ++++++++++++++
 include/linux/brcmphy.h   |  1 +
 2 files changed, 15 insertions(+)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 03d4809a9126..d4083c381cd1 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -361,6 +361,19 @@ static struct phy_driver bcm7xxx_driver[] = {
 	.resume         = bcm7xxx_config_init,
 	.driver         = { .owner = THIS_MODULE },
 }, {
+	.phy_id         = PHY_ID_BCM7435,
+	.phy_id_mask    = 0xfffffff0,
+	.name           = "Broadcom BCM7435",
+	.features       = PHY_GBIT_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.flags          = PHY_IS_INTERNAL,
+	.config_init    = bcm7xxx_config_init,
+	.config_aneg    = genphy_config_aneg,
+	.read_status    = genphy_read_status,
+	.suspend        = bcm7xxx_suspend,
+	.resume         = bcm7xxx_config_init,
+	.driver         = { .owner = THIS_MODULE },
+}, {
 	.phy_id		= PHY_BCM_OUI_4,
 	.phy_id_mask	= 0xffff0000,
 	.name		= "Broadcom BCM7XXX 40nm",
@@ -395,6 +408,7 @@ static struct mdio_device_id __maybe_unused bcm7xxx_tbl[] = {
 	{ PHY_ID_BCM7425, 0xfffffff0, },
 	{ PHY_ID_BCM7429, 0xfffffff0, },
 	{ PHY_ID_BCM7439, 0xfffffff0, },
+	{ PHY_ID_BCM7435, 0xfffffff0, },
 	{ PHY_ID_BCM7445, 0xfffffff0, },
 	{ PHY_BCM_OUI_4, 0xffff0000 },
 	{ PHY_BCM_OUI_5, 0xffffff00 },
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 59f4a7304419..f0ba9c2ec639 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -26,6 +26,7 @@
 #define PHY_ID_BCM7366			0x600d8490
 #define PHY_ID_BCM7425			0x600d86b0
 #define PHY_ID_BCM7429			0x600d8730
+#define PHY_ID_BCM7435			0x600d8750
 #define PHY_ID_BCM7439			0x600d8480
 #define PHY_ID_BCM7439_2		0xae025080
 #define PHY_ID_BCM7445			0x600d8510
-- 
2.1.0
