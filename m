From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 2/3] net: dsa: Add dsa_is_dsa_port() helper
Date: Mon, 17 Aug 2015 23:52:51 +0200
Message-ID: <1439848372-4055-3-git-send-email-andrew@lunn.ch>
References: <1439848372-4055-1-git-send-email-andrew@lunn.ch>
Cc: Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60880 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751050AbbHQWAW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2015 18:00:22 -0400
In-Reply-To: <1439848372-4055-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an inline helper for determining is a port is a DSA port.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 5 ++---
 include/net/dsa.h           | 5 +++++
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 332f2c8090d0..486e9792fc05 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1926,8 +1926,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 		 * full duplex.
 		 */
 		reg = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_PCS_CTRL);
-		if (dsa_is_cpu_port(ds, port) ||
-		    ds->dsa_port_mask & (1 << port)) {
+		if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) {
 			reg |= PORT_PCS_CTRL_FORCE_LINK |
 				PORT_PCS_CTRL_LINK_UP |
 				PORT_PCS_CTRL_DUPLEX_FULL |
@@ -1992,7 +1991,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
 	    mv88e6xxx_6095_family(ds) || mv88e6xxx_6065_family(ds) ||
 	    mv88e6xxx_6320_family(ds)) {
-		if (ds->dsa_port_mask & (1 << port))
+		if (dsa_is_dsa_port(ds, port))
 			reg |= PORT_CONTROL_FRAME_MODE_DSA;
 		if (port == dsa_upstream_port(ds))
 			reg |= PORT_CONTROL_FORWARD_UNKNOWN |
diff --git a/include/net/dsa.h b/include/net/dsa.h
index bd9b76502458..b34d812bc5d0 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -171,6 +171,11 @@ static inline bool dsa_is_cpu_port(struct dsa_switch *ds, int p)
 	return !!(ds->index == ds->dst->cpu_switch && p == ds->dst->cpu_port);
 }
 
+static inline bool dsa_is_dsa_port(struct dsa_switch *ds, int p)
+{
+	return !!((ds->dsa_port_mask) & (1 << p));
+}
+
 static inline bool dsa_is_port_initialized(struct dsa_switch *ds, int p)
 {
 	return ds->phys_port_mask & (1 << p) && ds->ports[p];
-- 
2.5.0
