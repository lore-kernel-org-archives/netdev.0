From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v4 net-next v4 06/14] net: dsa: mv88e6xxx: use gpio get optional variant
Date: Mon, 20 Jun 2016 12:03:29 -0400
Message-ID: <20160620160337.2934-7-vivien.didelot@savoirfairelinux.com>
References: <20160620160337.2934-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:45643 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754614AbcFTQE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 12:04:59 -0400
In-Reply-To: <20160620160337.2934-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the optional variant to get the reset GPIO line, instead of checking
for the -ENOENT error.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index ad7735d..ec28465 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3744,16 +3744,9 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	if (!ps->info)
 		return -ENODEV;
 
-	ps->reset = devm_gpiod_get(dev, "reset", GPIOD_ASIS);
-	if (IS_ERR(ps->reset)) {
-		err = PTR_ERR(ps->reset);
-		if (err == -ENOENT) {
-			/* Optional, so not an error */
-			ps->reset = NULL;
-		} else {
-			return err;
-		}
-	}
+	ps->reset = devm_gpiod_get_optional(dev, "reset", GPIOD_ASIS);
+	if (IS_ERR(ps->reset))
+		return PTR_ERR(ps->reset);
 
 	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEPROM) &&
 	    !of_property_read_u32(np, "eeprom-length", &eeprom_len))
-- 
2.9.0
