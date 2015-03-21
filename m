From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 07/18] net: dsa: mv88e6171: Use common port configuration
Date: Sat, 21 Mar 2015 08:46:44 -0700
Message-ID: <1426952815-4642-8-git-send-email-linux@roeck-us.net>
References: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:40273 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748AbbCUPrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 11:47:42 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YZLci-0001W6-Ve
	for netdev@vger.kernel.org; Sat, 21 Mar 2015 15:47:41 +0000
In-Reply-To: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6171.c | 24 +-----------------------
 1 file changed, 1 insertion(+), 23 deletions(-)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 2f6662c..6ce6a3e 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -221,28 +221,6 @@ static int mv88e6171_setup_port(struct dsa_switch *ds, int p)
 		val |= 0x000c;
 	REG_WRITE(addr, 0x04, val);
 
-	/* Port Control 1: disable trunking.  Also, if this is the
-	 * CPU port, enable learn messages to be sent to this port.
-	 */
-	REG_WRITE(addr, 0x05, dsa_is_cpu_port(ds, p) ? 0x8000 : 0x0000);
-
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
@@ -287,7 +265,7 @@ static int mv88e6171_setup_port(struct dsa_switch *ds, int p)
 	 */
 	REG_WRITE(addr, 0x19, 0x7654);
 
-	return 0;
+	return mv88e6xxx_setup_port_common(ds, p);
 }
 
 static int mv88e6171_setup(struct dsa_switch *ds)
-- 
2.1.0
