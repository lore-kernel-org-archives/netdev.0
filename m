From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v5 net-next v5 06/14] net: dsa: mv88e6xxx: use gpio get optional variant
Date: Mon, 20 Jun 2016 13:14:03 -0400
Message-ID: <20160620171411.13746-7-vivien.didelot@savoirfairelinux.com>
References: <20160620171411.13746-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160620171411.13746-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
