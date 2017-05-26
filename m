From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/3] net: dsa: mv88e6xxx: rename PHY PPU accessors
Date: Fri, 26 May 2017 18:03:06 -0400
Message-ID: <20170526220307.23503-3-vivien.didelot@savoirfairelinux.com>
References: <20170526220307.23503-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48758 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948778AbdEZWFm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 18:05:42 -0400
In-Reply-To: <20170526220307.23503-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make it clear that mv88e6xxx_phy_ppu_{read,write} are an implementation
of the .phy_{read,write} operations, by renaming them with the mv88e6185
prefix, since 88E6185 it is the reference switch model supported in an
upstream board (ZII Dev Rev B), which makes use of them.

Distinguish the signatures of implementation specific and generic PHY
functions in the phy.h header.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 16 ++++++++--------
 drivers/net/dsa/mv88e6xxx/phy.c  |  4 ++--
 drivers/net/dsa/mv88e6xxx/phy.h  | 11 +++++++----
 3 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 7f5f44f89389..070e82ac6132 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2371,8 +2371,8 @@ static int mv88e6xxx_set_eeprom(struct dsa_switch *ds,
 static const struct mv88e6xxx_ops mv88e6085_ops = {
 	/* MV88E6XXX_FAMILY_6097 */
 	.set_switch_mac = mv88e6xxx_g1_set_switch_mac,
-	.phy_read = mv88e6xxx_phy_ppu_read,
-	.phy_write = mv88e6xxx_phy_ppu_write,
+	.phy_read = mv88e6185_phy_ppu_read,
+	.phy_write = mv88e6185_phy_ppu_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
@@ -2402,8 +2402,8 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 static const struct mv88e6xxx_ops mv88e6095_ops = {
 	/* MV88E6XXX_FAMILY_6095 */
 	.set_switch_mac = mv88e6xxx_g1_set_switch_mac,
-	.phy_read = mv88e6xxx_phy_ppu_read,
-	.phy_write = mv88e6xxx_phy_ppu_write,
+	.phy_read = mv88e6185_phy_ppu_read,
+	.phy_write = mv88e6185_phy_ppu_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
@@ -2480,8 +2480,8 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 static const struct mv88e6xxx_ops mv88e6131_ops = {
 	/* MV88E6XXX_FAMILY_6185 */
 	.set_switch_mac = mv88e6xxx_g1_set_switch_mac,
-	.phy_read = mv88e6xxx_phy_ppu_read,
-	.phy_write = mv88e6xxx_phy_ppu_write,
+	.phy_read = mv88e6185_phy_ppu_read,
+	.phy_write = mv88e6185_phy_ppu_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
@@ -2727,8 +2727,8 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 static const struct mv88e6xxx_ops mv88e6185_ops = {
 	/* MV88E6XXX_FAMILY_6185 */
 	.set_switch_mac = mv88e6xxx_g1_set_switch_mac,
-	.phy_read = mv88e6xxx_phy_ppu_read,
-	.phy_write = mv88e6xxx_phy_ppu_write,
+	.phy_read = mv88e6185_phy_ppu_read,
+	.phy_write = mv88e6185_phy_ppu_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
diff --git a/drivers/net/dsa/mv88e6xxx/phy.c b/drivers/net/dsa/mv88e6xxx/phy.c
index b865b1e2b103..19e0128257e5 100644
--- a/drivers/net/dsa/mv88e6xxx/phy.c
+++ b/drivers/net/dsa/mv88e6xxx/phy.c
@@ -202,7 +202,7 @@ static void mv88e6xxx_ppu_state_destroy(struct mv88e6xxx_chip *chip)
 	del_timer_sync(&chip->ppu_timer);
 }
 
-int mv88e6xxx_phy_ppu_read(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
+int mv88e6185_phy_ppu_read(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
 			   int addr, int reg, u16 *val)
 {
 	int err;
@@ -216,7 +216,7 @@ int mv88e6xxx_phy_ppu_read(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
 	return err;
 }
 
-int mv88e6xxx_phy_ppu_write(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
+int mv88e6185_phy_ppu_write(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
 			    int addr, int reg, u16 val)
 {
 	int err;
diff --git a/drivers/net/dsa/mv88e6xxx/phy.h b/drivers/net/dsa/mv88e6xxx/phy.h
index dfa98549dfcd..91fe3c3e9aea 100644
--- a/drivers/net/dsa/mv88e6xxx/phy.h
+++ b/drivers/net/dsa/mv88e6xxx/phy.h
@@ -14,10 +14,17 @@
 #ifndef _MV88E6XXX_PHY_H
 #define _MV88E6XXX_PHY_H
 
+/* PHY Registers accesses implementations */
 int mv88e6165_phy_read(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
 		       int addr, int reg, u16 *val);
 int mv88e6165_phy_write(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
 			int addr, int reg, u16 val);
+int mv88e6185_phy_ppu_read(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
+			   int addr, int reg, u16 *val);
+int mv88e6185_phy_ppu_write(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
+			    int addr, int reg, u16 val);
+
+/* Generic PHY operations */
 int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
 		       int reg, u16 *val);
 int mv88e6xxx_phy_write(struct mv88e6xxx_chip *chip, int phy,
@@ -26,10 +33,6 @@ int mv88e6xxx_phy_page_read(struct mv88e6xxx_chip *chip, int phy,
 			    u8 page, int reg, u16 *val);
 int mv88e6xxx_phy_page_write(struct mv88e6xxx_chip *chip, int phy,
 			     u8 page, int reg, u16 val);
-int mv88e6xxx_phy_ppu_read(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
-			   int addr, int reg, u16 *val);
-int mv88e6xxx_phy_ppu_write(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
-			    int addr, int reg, u16 val);
 void mv88e6xxx_phy_init(struct mv88e6xxx_chip *chip);
 void mv88e6xxx_phy_destroy(struct mv88e6xxx_chip *chip);
 int mv88e6xxx_phy_setup(struct mv88e6xxx_chip *chip);
-- 
2.13.0
