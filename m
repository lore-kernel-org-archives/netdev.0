From: <Nisar.Sayed@microchip.com>
Subject: [PATCH net 2/3] lan78xx: Allow EEPROM write for less than
 MAX_EEPROM_SIZE
Date: Thu, 7 Sep 2017 07:11:26 +0000
Message-ID: <CE371C1263339941885964188A0225FA333A7C@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa3.microchip.iphmx.com ([68.232.153.233]:9668 "EHLO
        esa3.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753980AbdIGHLn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 03:11:43 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nisar Sayed <Nisar.Sayed@microchip.com>

Allow EEPROM write for less than MAX_EEPROM_SIZE

Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>
---
 drivers/net/usb/lan78xx.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index baf91c7..94ef943 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -1299,6 +1299,10 @@ static int lan78xx_ethtool_set_eeprom(struct net_device *netdev,
 		 (ee->len == 512) &&
 		 (data[0] == OTP_INDICATOR_1))
 		ret = lan78xx_write_raw_otp(dev, ee->offset, ee->len, data);
+	else if ((ee->magic == LAN78XX_EEPROM_MAGIC) &&
+		 (ee->offset >= 0 && ee->offset < MAX_EEPROM_SIZE) &&
+		 (ee->len > 0 && (ee->offset + ee->len) <= MAX_EEPROM_SIZE))
+		ret = lan78xx_write_raw_eeprom(dev, ee->offset, ee->len, data);
 
 	usb_autopm_put_interface(dev->intf);
 
-- 
1.9.1
