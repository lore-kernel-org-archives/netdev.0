From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/9] dsa: mv88e6xxx: hide unused functions
Date: Wed, 10 Aug 2016 23:54:08 +0200
Message-ID: <20160810215424.1926658-3-arnd@arndb.de>
References: <20160810215424.1926658-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160810215424.1926658-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When CONFIG_NET_DSA_HWMON is disabled, we get warnings about two unused
functions whose only callers are all inside of an #ifdef:

drivers/net/dsa/mv88e6xxx.c:3257:12: 'mv88e6xxx_mdio_page_write' defined but not used [-Werror=unused-function]
drivers/net/dsa/mv88e6xxx.c:3244:12: 'mv88e6xxx_mdio_page_read' defined but not used [-Werror=unused-function]

This adds another ifdef around the function definitions. The warnings
appeared after the functions were marked 'static', but the problem
was already there before that.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 57d3231057e9 ("net: dsa: mv88e6xxx: fix style issues")
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
When I first submitted it on June 23, there was a clash with some
other patches, this version is based on top of current mainline,
which contains those patches already, so it should apply cleanly.
---
 drivers/net/dsa/mv88e6xxx/chip.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index d36aedde8cb9..d1d9d3cf9139 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3187,6 +3187,7 @@ static int mv88e6xxx_set_addr(struct dsa_switch *ds, u8 *addr)
 	return err;
 }
 
+#ifdef CONFIG_NET_DSA_HWMON
 static int mv88e6xxx_mdio_page_read(struct dsa_switch *ds, int port, int page,
 				    int reg)
 {
@@ -3212,6 +3213,7 @@ static int mv88e6xxx_mdio_page_write(struct dsa_switch *ds, int port, int page,
 
 	return ret;
 }
+#endif
 
 static int mv88e6xxx_port_to_mdio_addr(struct mv88e6xxx_chip *chip, int port)
 {
-- 
2.9.0
