From: Nisar Sayed <Nisar.Sayed@microchip.com>
Subject: [PATCH v4 net 2/3] lan78xx: Allow EEPROM write for less than MAX_EEPROM_SIZE
Date: Tue, 19 Sep 2017 03:32:24 +0530
Message-ID: <20170918220225.3767-3-Nisar.Sayed@microchip.com>
References: <20170918220225.3767-1-Nisar.Sayed@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa2.microchip.iphmx.com ([68.232.149.84]:58591 "EHLO
        esa2.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932672AbdIRQjz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 12:39:55 -0400
In-Reply-To: <20170918220225.3767-1-Nisar.Sayed@microchip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow EEPROM write for less than MAX_EEPROM_SIZE

Fixes: 55d7de9de6c3 ("Microchip's LAN7800 family USB 2/3 to 10/100/1000 Ethernet device driver")
Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>
---
 drivers/net/usb/lan78xx.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index fcf85ae37435..3292f56ffe02 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -1290,11 +1290,10 @@ static int lan78xx_ethtool_set_eeprom(struct net_device *netdev,
 	if (ret)
 		return ret;
 
-	/* Allow entire eeprom update only */
-	if ((ee->magic == LAN78XX_EEPROM_MAGIC) &&
-	    (ee->offset == 0) &&
-	    (ee->len == 512) &&
-	    (data[0] == EEPROM_INDICATOR))
+	/* Invalid EEPROM_INDICATOR at offset zero will result in fail to
+	 * load data from EEPROM
+	 */
+	if (ee->magic == LAN78XX_EEPROM_MAGIC)
 		ret = lan78xx_write_raw_eeprom(dev, ee->offset, ee->len, data);
 	else if ((ee->magic == LAN78XX_OTP_MAGIC) &&
 		 (ee->offset == 0) &&
-- 
2.14.1
