From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 1/5] net: dsa: mv88e6xxx: Abstract mv88e6165 PHY operations
Date: Tue, 24 Jan 2017 14:53:47 +0100
Message-ID: <1485266031-4980-2-git-send-email-andrew@lunn.ch>
References: <1485266031-4980-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43689 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751137AbdAXNzi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 08:55:38 -0500
In-Reply-To: <1485266031-4980-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6165 family has the internal PHYs mapped directly onto the
SMI register space as the switch. So the registers can be read
directly. Put a wrapper around this, in preparation for changing the
signature in order to support the external MDIO bus of the 6390.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 24 ++++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index c7e08e13bb54..374d887e8256 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -222,6 +222,18 @@ int mv88e6xxx_write(struct mv88e6xxx_chip *chip, int addr, int reg, u16 val)
 	return 0;
 }
 
+static int mv88e6165_phy_read(struct mv88e6xxx_chip *chip, int addr,
+			      int reg, u16 *val)
+{
+	return mv88e6xxx_read(chip, addr, reg, val);
+}
+
+static int mv88e6165_phy_write(struct mv88e6xxx_chip *chip, int addr,
+			       int reg, u16 val)
+{
+	return mv88e6xxx_write(chip, addr, reg, val);
+}
+
 static int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
 			      int reg, u16 *val)
 {
@@ -3085,8 +3097,8 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 static const struct mv88e6xxx_ops mv88e6123_ops = {
 	/* MV88E6XXX_FAMILY_6165 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
-	.phy_read = mv88e6xxx_read,
-	.phy_write = mv88e6xxx_write,
+	.phy_read = mv88e6165_phy_read,
+	.phy_write = mv88e6165_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
@@ -3132,8 +3144,8 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 static const struct mv88e6xxx_ops mv88e6161_ops = {
 	/* MV88E6XXX_FAMILY_6165 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
-	.phy_read = mv88e6xxx_read,
-	.phy_write = mv88e6xxx_write,
+	.phy_read = mv88e6165_phy_read,
+	.phy_write = mv88e6165_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
@@ -3157,8 +3169,8 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 static const struct mv88e6xxx_ops mv88e6165_ops = {
 	/* MV88E6XXX_FAMILY_6165 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
-	.phy_read = mv88e6xxx_read,
-	.phy_write = mv88e6xxx_write,
+	.phy_read = mv88e6165_phy_read,
+	.phy_write = mv88e6165_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
-- 
2.11.0
