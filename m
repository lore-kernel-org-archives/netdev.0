From: <Woojung.Huh@microchip.com>
Subject: [PATCH net] phy: keep pause flags in phy driver features
Date: Thu, 11 Feb 2016 17:29:47 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D404AC676@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <andrew@lunn.ch>
To: <davem@davemloft.net>, <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:26814 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751098AbcBKR3s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 12:29:48 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


genphy_config_init() masked out pause flags set in phy driver structure.
Pause flags needs to be preserved in phydev->supported &
phydev->advertising.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/phy/phy_device.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index bad3f00..e551f3a 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1410,7 +1410,7 @@ int genphy_config_init(struct phy_device *phydev)
 
 	features = (SUPPORTED_TP | SUPPORTED_MII
 			| SUPPORTED_AUI | SUPPORTED_FIBRE |
-			SUPPORTED_BNC);
+			SUPPORTED_BNC | SUPPORTED_Pause | SUPPORTED_Asym_Pause);
 
 	/* Do we support autonegotiation? */
 	val = phy_read(phydev, MII_BMSR);
-- 
2.7.0
