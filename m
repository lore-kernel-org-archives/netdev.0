From: Nisar Sayed <Nisar.Sayed@microchip.com>
Subject: [PATCH v4 net 3/3] lan78xx: Use default values loaded from EEPROM/OTP after reset
Date: Tue, 19 Sep 2017 03:32:25 +0530
Message-ID: <20170918220225.3767-4-Nisar.Sayed@microchip.com>
References: <20170918220225.3767-1-Nisar.Sayed@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa5.microchip.iphmx.com ([216.71.150.166]:10711 "EHLO
        esa5.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932746AbdIRQkA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 12:40:00 -0400
In-Reply-To: <20170918220225.3767-1-Nisar.Sayed@microchip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use default value of auto duplex and auto speed values loaded
from EEPROM/OTP after reset. The LAN78xx allows platform
configurations to be loaded from EEPROM/OTP.
Ex: When external phy is connected, the MAC can be configured to
have correct auto speed, auto duplex, auto polarity configured
from the EEPROM/OTP.

Fixes: 55d7de9de6c3 ("Microchip's LAN7800 family USB 2/3 to 10/100/1000 Ethernet device driver")
Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>
---
 drivers/net/usb/lan78xx.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 3292f56ffe02..0fc3c19d5aef 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -2449,7 +2449,6 @@ static int lan78xx_reset(struct lan78xx_net *dev)
 	/* LAN7801 only has RGMII mode */
 	if (dev->chipid == ID_REV_CHIP_ID_7801_)
 		buf &= ~MAC_CR_GMII_EN_;
-	buf |= MAC_CR_AUTO_DUPLEX_ | MAC_CR_AUTO_SPEED_;
 	ret = lan78xx_write_reg(dev, MAC_CR, buf);
 
 	ret = lan78xx_read_reg(dev, MAC_TX, &buf);
-- 
2.14.1
