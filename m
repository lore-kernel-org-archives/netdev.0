From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] dsa: mv88e6xxx: hide unused functions
Date: Thu, 23 Jun 2016 16:13:22 +0200
Message-ID: <20160623141409.356324-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
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
---
 drivers/net/dsa/mv88e6xxx.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 9b116d8d4e23..2a95f2d6cf09 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3241,6 +3241,7 @@ unlock:
 	return err;
 }
 
+#ifdef CONFIG_NET_DSA_HWMON
 static int mv88e6xxx_mdio_page_read(struct dsa_switch *ds, int port, int page,
 				    int reg)
 {
@@ -3266,6 +3267,7 @@ static int mv88e6xxx_mdio_page_write(struct dsa_switch *ds, int port, int page,
 
 	return ret;
 }
+#endif
 
 static int mv88e6xxx_port_to_mdio_addr(struct mv88e6xxx_priv_state *ps,
 				       int port)
-- 
2.9.0
