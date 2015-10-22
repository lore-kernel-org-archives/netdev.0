From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH 3/3] net: dsa: Make mv88e6060 use nested mdiobus read/write
Date: Thu, 22 Oct 2015 10:37:57 +0200
Message-ID: <5628A065.1090800@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com, Andrew Lunn <andrew@lunn.ch>,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nbd@openwrt.org,
	sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Like mv88e6xxx and mdio-mux, to avoid lockdep give false positives
because of nested MDIO busses, switch to previously introduced
nested mdiobus_read/write variants.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/dsa/mv88e6060.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index c29aebe..9093577 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -26,7 +26,7 @@ static int reg_read(struct dsa_switch *ds, int addr, int reg)
 	if (bus == NULL)
 		return -EINVAL;

-	return mdiobus_read(bus, ds->pd->sw_addr + addr, reg);
+	return mdiobus_read_nested(bus, ds->pd->sw_addr + addr, reg);
 }

 #define REG_READ(addr, reg)					\
@@ -47,7 +47,7 @@ static int reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
 	if (bus == NULL)
 		return -EINVAL;

-	return mdiobus_write(bus, ds->pd->sw_addr + addr, reg, val);
+	return mdiobus_write_nested(bus, ds->pd->sw_addr + addr, reg, val);
 }

 #define REG_WRITE(addr, reg, val)				\
-- 
1.9.1
