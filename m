From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/3] net: phy: bcm7xxx: remove 28nm wildcard entry
Date: Thu, 14 Aug 2014 16:52:51 -0700
Message-ID: <1408060373-5996-2-git-send-email-f.fainelli@gmail.com>
References: <1408060373-5996-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:56859 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbaHNXxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 19:53:16 -0400
Received: by mail-pd0-f176.google.com with SMTP id y10so2414279pdj.21
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 16:53:16 -0700 (PDT)
In-Reply-To: <1408060373-5996-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A wildcard entry with the 32-bits OUI 0x600d8400 was added as part of
the BCM7xxx internal PHY driver, but that entry might match other PHYs
that are not covered by this driver, so let's just remove it.

Fixes: b560a58c45c6 ("net: phy: add Broadcom BCM7xxx internal PHY driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 14 --------------
 include/linux/brcmphy.h   |  1 -
 2 files changed, 15 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 526b94cea569..2b40548c85d5 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -287,19 +287,6 @@ static struct phy_driver bcm7xxx_driver[] = {
 	.resume		= bcm7xxx_28nm_config_init,
 	.driver		= { .owner = THIS_MODULE },
 }, {
-	.name		= "Broadcom BCM7XXX 28nm",
-	.phy_id		= PHY_ID_BCM7XXX_28,
-	.phy_id_mask	= PHY_BCM_OUI_MASK,
-	.features	= PHY_GBIT_FEATURES |
-			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
-	.flags		= PHY_IS_INTERNAL,
-	.config_init	= bcm7xxx_28nm_config_init,
-	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
-	.suspend	= bcm7xxx_suspend,
-	.resume		= bcm7xxx_28nm_config_init,
-	.driver		= { .owner = THIS_MODULE },
-}, {
 	.phy_id		= PHY_BCM_OUI_4,
 	.phy_id_mask	= 0xffff0000,
 	.name		= "Broadcom BCM7XXX 40nm",
@@ -331,7 +318,6 @@ static struct mdio_device_id __maybe_unused bcm7xxx_tbl[] = {
 	{ PHY_ID_BCM7366, 0xfffffff0, },
 	{ PHY_ID_BCM7439, 0xfffffff0, },
 	{ PHY_ID_BCM7445, 0xfffffff0, },
-	{ PHY_ID_BCM7XXX_28, 0xfffffc00 },
 	{ PHY_BCM_OUI_4, 0xffff0000 },
 	{ PHY_BCM_OUI_5, 0xffffff00 },
 	{ }
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 6f76277baf39..61219b9b3445 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -16,7 +16,6 @@
 #define PHY_ID_BCM7366			0x600d8490
 #define PHY_ID_BCM7439			0x600d8480
 #define PHY_ID_BCM7445			0x600d8510
-#define PHY_ID_BCM7XXX_28		0x600d8400
 
 #define PHY_BCM_OUI_MASK		0xfffffc00
 #define PHY_BCM_OUI_1			0x00206000
-- 
1.9.1
