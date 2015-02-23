From: Guenter Roeck <linux@roeck-us.net>
Subject: [RFT/RFC PATCH 5/8] net: dsa: mv88e6352: Use common port initialization code
Date: Mon, 23 Feb 2015 11:35:47 -0800
Message-ID: <1424720150-27564-6-git-send-email-linux@roeck-us.net>
References: <1424720150-27564-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424720150-27564-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This prepares the driver for hardware bridging.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6352.c | 19 +------------------
 1 file changed, 1 insertion(+), 18 deletions(-)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 75cf9e1..d7053db 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -220,23 +220,6 @@ static int mv88e6352_setup_port(struct dsa_switch *ds, int p)
 	 */
 	REG_WRITE(addr, 0x05, dsa_is_cpu_port(ds, p) ? 0x8000 : 0x0000);
 
-	/* Port based VLAN map: give each port its own address
-	 * database, allow the CPU port to talk to each of the 'real'
-	 * ports, and allow each of the 'real' ports to only talk to
-	 * the upstream port.
-	 */
-	val = (p & 0xf) << 12;
-	if (dsa_is_cpu_port(ds, p))
-		val |= ds->phys_port_mask;
-	else
-		val |= 1 << dsa_upstream_port(ds);
-	REG_WRITE(addr, 0x06, val);
-
-	/* Default VLAN ID and priority: don't set a default VLAN
-	 * ID, and set the default packet priority to zero.
-	 */
-	REG_WRITE(addr, 0x07, 0x0000);
-
 	/* Port Control 2: don't force a good FCS, set the maximum
 	 * frame size to 10240 bytes, don't let the switch add or
 	 * strip 802.1q tags, don't discard tagged or untagged frames
@@ -281,7 +264,7 @@ static int mv88e6352_setup_port(struct dsa_switch *ds, int p)
 	 */
 	REG_WRITE(addr, 0x19, 0x7654);
 
-	return 0;
+	return mv88e6xxx_setup_port_common(ds, p);
 }
 
 #ifdef CONFIG_NET_DSA_HWMON
-- 
2.1.0
