From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 01/11] net: dsa: mv88e6xxx: Take switch out of reset before probe
Date: Mon, 21 Nov 2016 23:26:55 +0100
Message-ID: <1479767225-13789-2-git-send-email-andrew@lunn.ch>
References: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47749 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753763AbcKUWaL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 17:30:11 -0500
In-Reply-To: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The switch needs to be taken out of reset before we can read its ID
register on the MDIO bus.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index e30d0eaf2b5f..062b9128a58d 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3855,16 +3855,16 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	if (err)
 		return err;
 
+	chip->reset = devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_LOW);
+	if (IS_ERR(chip->reset))
+		return PTR_ERR(chip->reset);
+
 	err = mv88e6xxx_detect(chip);
 	if (err)
 		return err;
 
 	mv88e6xxx_phy_init(chip);
 
-	chip->reset = devm_gpiod_get_optional(dev, "reset", GPIOD_ASIS);
-	if (IS_ERR(chip->reset))
-		return PTR_ERR(chip->reset);
-
 	if (chip->info->ops->get_eeprom &&
 	    !of_property_read_u32(np, "eeprom-length", &eeprom_len))
 		chip->eeprom_len = eeprom_len;
-- 
2.10.2
