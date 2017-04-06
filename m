From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2] net: dsa: mv88e6xxx: Make SMI c22/c45 read/write functions static
Date: Thu,  6 Apr 2017 12:42:16 -0700
Message-ID: <20170406194217.13927-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:32915 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753731AbdDFTmX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 15:42:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SMI clause 22 & 45 read/write operations are local to the global2.c file,
so make them static. This eliminates the following warning:

drivers/net/dsa/mv88e6xxx/global2.c:571:5: warning: no previous prototype for 'mv88e6xxx_g2_smi_phy_read_c45' [-Wmissing-prototypes]
 int mv88e6xxx_g2_smi_phy_read_c45(struct mv88e6xxx_chip *chip, int addr,
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
drivers/net/dsa/mv88e6xxx/global2.c:602:5: warning: no previous prototype for 'mv88e6xxx_g2_smi_phy_read_c22' [-Wmissing-prototypes]
 int mv88e6xxx_g2_smi_phy_read_c22(struct mv88e6xxx_chip *chip, int addr,
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
drivers/net/dsa/mv88e6xxx/global2.c:635:5: warning: no previous prototype for 'mv88e6xxx_g2_smi_phy_write_c45' [-Wmissing-prototypes]
 int mv88e6xxx_g2_smi_phy_write_c45(struct mv88e6xxx_chip *chip, int addr,
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
drivers/net/dsa/mv88e6xxx/global2.c:664:5: warning: no previous prototype for 'mv88e6xxx_g2_smi_phy_write_c22' [-Wmissing-prototypes]
 int mv88e6xxx_g2_smi_phy_write_c22(struct mv88e6xxx_chip *chip, int addr,
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Suggested-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/mv88e6xxx/global2.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 7c6bc33a9516..b3fea55071e3 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -568,8 +568,9 @@ static int mv88e6xxx_g2_smi_phy_write_addr(struct mv88e6xxx_chip *chip,
 	return mv88e6xxx_g2_smi_phy_cmd(chip, cmd);
 }
 
-int mv88e6xxx_g2_smi_phy_read_c45(struct mv88e6xxx_chip *chip, int addr,
-				  int reg_c45, u16 *val, bool external)
+static int mv88e6xxx_g2_smi_phy_read_c45(struct mv88e6xxx_chip *chip,
+					 int addr, int reg_c45, u16 *val,
+					 bool external)
 {
 	int device = (reg_c45 >> 16) & 0x1f;
 	int reg = reg_c45 & 0xffff;
@@ -599,8 +600,9 @@ int mv88e6xxx_g2_smi_phy_read_c45(struct mv88e6xxx_chip *chip, int addr,
 	return 0;
 }
 
-int mv88e6xxx_g2_smi_phy_read_c22(struct mv88e6xxx_chip *chip, int addr,
-				  int reg, u16 *val, bool external)
+static int mv88e6xxx_g2_smi_phy_read_c22(struct mv88e6xxx_chip *chip,
+					 int addr, int reg, u16 *val,
+					 bool external)
 {
 	u16 cmd = GLOBAL2_SMI_PHY_CMD_OP_22_READ_DATA | (addr << 5) | reg;
 	int err;
@@ -632,8 +634,9 @@ int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip,
 	return mv88e6xxx_g2_smi_phy_read_c22(chip, addr, reg, val, external);
 }
 
-int mv88e6xxx_g2_smi_phy_write_c45(struct mv88e6xxx_chip *chip, int addr,
-				   int reg_c45, u16 val, bool external)
+static int mv88e6xxx_g2_smi_phy_write_c45(struct mv88e6xxx_chip *chip,
+					  int addr, int reg_c45, u16 val,
+					  bool external)
 {
 	int device = (reg_c45 >> 16) & 0x1f;
 	int reg = reg_c45 & 0xffff;
@@ -661,8 +664,9 @@ int mv88e6xxx_g2_smi_phy_write_c45(struct mv88e6xxx_chip *chip, int addr,
 	return 0;
 }
 
-int mv88e6xxx_g2_smi_phy_write_c22(struct mv88e6xxx_chip *chip, int addr,
-				   int reg, u16 val, bool external)
+static int mv88e6xxx_g2_smi_phy_write_c22(struct mv88e6xxx_chip *chip,
+					  int addr, int reg, u16 val,
+					  bool external)
 {
 	u16 cmd = GLOBAL2_SMI_PHY_CMD_OP_22_WRITE_DATA | (addr << 5) | reg;
 	int err;
-- 
2.9.3
