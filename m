From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: phy: bcm7xxx: Fix 7425 PHY ID and flags
Date: Fri, 22 May 2015 14:07:30 -0700
Message-ID: <1432328850-29065-1-git-send-email-f.fainelli@gmail.com>
Cc: pgynther@google.com, netdev@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34941 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756645AbbEVVH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 17:07:56 -0400
Received: by pacwv17 with SMTP id wv17so28606183pac.2
        for <netdev@vger.kernel.org>; Fri, 22 May 2015 14:07:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While adding support for 7425 PHY in the 7xxx PHY driver, the ID that
was used was actually coming from an external PHY: a BCM5461x. Fix this
by using the proper ID for the internal 7425 PHY and set the
PHY_IS_INTERNAL flag, otherwise consumers of this PHY driver would not
be able to properly identify it as such.

Fixes: d068b02cfdfc2 ("net: phy: add BCM7425 and BCM7429 PHYs")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 2 +-
 include/linux/brcmphy.h   | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 64c74c6a4828..b5dc59de094e 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -404,7 +404,7 @@ static struct phy_driver bcm7xxx_driver[] = {
 	.name           = "Broadcom BCM7425",
 	.features       = PHY_GBIT_FEATURES |
 			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
-	.flags          = 0,
+	.flags          = PHY_IS_INTERNAL,
 	.config_init    = bcm7xxx_config_init,
 	.config_aneg    = genphy_config_aneg,
 	.read_status    = genphy_read_status,
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index ae2982c0f7a6..656da2a12ffe 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -17,7 +17,7 @@
 #define PHY_ID_BCM7250			0xae025280
 #define PHY_ID_BCM7364			0xae025260
 #define PHY_ID_BCM7366			0x600d8490
-#define PHY_ID_BCM7425			0x03625e60
+#define PHY_ID_BCM7425			0x600d86b0
 #define PHY_ID_BCM7429			0x600d8730
 #define PHY_ID_BCM7439			0x600d8480
 #define PHY_ID_BCM7439_2		0xae025080
-- 
2.1.0
