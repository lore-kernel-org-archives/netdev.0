From: Nisar Sayed <Nisar.Sayed@microchip.com>
Subject: [PATCH v5 net 3/3] lan78xx: Use default values loaded from EEPROM/OTP after reset
Date: Thu, 21 Sep 2017 02:36:38 +0530
Message-ID: <20170920210638.11150-4-Nisar.Sayed@microchip.com>
References: <20170920210638.11150-1-Nisar.Sayed@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa2.microchip.iphmx.com ([68.232.149.84]:10955 "EHLO
        esa2.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751773AbdITPoN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 11:44:13 -0400
In-Reply-To: <20170920210638.11150-1-Nisar.Sayed@microchip.com>
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
index f8c63eec8353..0161f77641fa 100644
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
