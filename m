From: <Nisar.Sayed@microchip.com>
Subject: [PATCH v2 net 3/3] lan78xx: Use default value loaded from
 EEPROM/OTP when resetting
Date: Mon, 11 Sep 2017 18:52:34 +0000
Message-ID: <CE371C1263339941885964188A0225FA335CA5@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa6.microchip.iphmx.com ([216.71.154.253]:38826 "EHLO
        esa6.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751243AbdIKSwf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 14:52:35 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nisar Sayed <Nisar.Sayed@microchip.com>

Use default value loaded from EEPROM/OTP when resetting

The LAN78xx allows platform configurations to be loaded from EEPROM/OTP.
Ex: When external phy is connected, the MAC can be configured to
have speed, duplex, polarity configurations loadded from the EEPROM/OTP.

Fixes: 55d7de9de6c3 ("Microchip's LAN7800 family USB 2/3 to 10/100/1000 Ethernet device driver")
Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>
---
 drivers/net/usb/lan78xx.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 02d64f75..ffe302a 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -2448,7 +2448,6 @@ static int lan78xx_reset(struct lan78xx_net *dev)
 	/* LAN7801 only has RGMII mode */
 	if (dev->chipid == ID_REV_CHIP_ID_7801_)
 		buf &= ~MAC_CR_GMII_EN_;
-	buf |= MAC_CR_AUTO_DUPLEX_ | MAC_CR_AUTO_SPEED_;
 	ret = lan78xx_write_reg(dev, MAC_CR, buf);
 
 	ret = lan78xx_read_reg(dev, MAC_TX, &buf);
-- 
1.9.1
