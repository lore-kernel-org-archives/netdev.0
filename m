From: <Nisar.Sayed@microchip.com>
Subject: [PATCH v2 net 2/3] lan78xx: Allow EEPROM write for less than
 MAX_EEPROM_SIZE
Date: Mon, 11 Sep 2017 18:52:21 +0000
Message-ID: <CE371C1263339941885964188A0225FA335C94@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa2.microchip.iphmx.com ([68.232.149.84]:20081 "EHLO
        esa2.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751029AbdIKSxH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 14:53:07 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nisar Sayed <Nisar.Sayed@microchip.com>

Allow EEPROM write for less than MAX_EEPROM_SIZE

Fixes: 55d7de9de6c3 ("Microchip's LAN7800 family USB 2/3 to 10/100/1000 Ethernet device driver")
Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>
---
 drivers/net/usb/lan78xx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index baf91c7..02d64f75 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -1290,8 +1290,8 @@ static int lan78xx_ethtool_set_eeprom(struct net_device *netdev,
 
 	/* Allow entire eeprom update only */
 	if ((ee->magic == LAN78XX_EEPROM_MAGIC) &&
-	    (ee->offset == 0) &&
-	    (ee->len == 512) &&
+	    (ee->offset >= 0 && ee->offset < MAX_EEPROM_SIZE) &&
+	    (ee->len > 0 && (ee->offset + ee->len) <= MAX_EEPROM_SIZE) &&
 	    (data[0] == EEPROM_INDICATOR))
 		ret = lan78xx_write_raw_eeprom(dev, ee->offset, ee->len, data);
 	else if ((ee->magic == LAN78XX_OTP_MAGIC) &&
-- 
1.9.1
