From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCHv2 3/4] net: dsa: Add dsa_is_dsa_port() helper
Date: Sun, 28 Jun 2015 21:50:00 +0200
Message-ID: <1435521001-25195-4-git-send-email-andrew@lunn.ch>
References: <1435521001-25195-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58889 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752468AbbF1T4I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jun 2015 15:56:08 -0400
In-Reply-To: <1435521001-25195-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an inline helper for determining is a port is a DSA port.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 5 ++---
 include/net/dsa.h           | 5 +++++
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index fc73d809c292..a5eb89ce0b99 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1441,8 +1441,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 		 * full duplex.
 		 */
 		reg = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_PCS_CTRL);
-		if (dsa_is_cpu_port(ds, port) ||
-		    ds->dsa_port_mask & (1 << port)) {
+		if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) {
 			reg |= PORT_PCS_CTRL_FORCE_LINK |
 				PORT_PCS_CTRL_LINK_UP |
 				PORT_PCS_CTRL_DUPLEX_FULL |
@@ -1505,7 +1504,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
 	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
 	    mv88e6xxx_6095_family(ds) || mv88e6xxx_6065_family(ds)) {
-		if (ds->dsa_port_mask & (1 << port))
+		if (dsa_is_dsa_port(ds, port))
 			reg |= PORT_CONTROL_FRAME_MODE_DSA;
 		if (port == dsa_upstream_port(ds))
 			reg |= PORT_CONTROL_FORWARD_UNKNOWN |
diff --git a/include/net/dsa.h b/include/net/dsa.h
index fbca63ba8f73..153a6b23874f 100644
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
2.1.4
