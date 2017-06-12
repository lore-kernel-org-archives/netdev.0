From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 12/13] net: dsa: mv88e6xxx: prefix Port IEEE Priority mapping macros
Date: Mon, 12 Jun 2017 12:37:44 -0400
Message-ID: <20170612163745.16868-13-vivien.didelot@savoirfairelinux.com>
References: <20170612163745.16868-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170612163745.16868-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For implicit namespacing and clarity, prefix the common Port IEEE
Priority Remapping registers macros with MV88E6095_PORT_IEEE_PRIO.

The 88E6390 family turned the 0x18 register into a single indirect
table, document that at the same time.

Document the register and prefer ordered hex masks values for all
Marvell 16-bit registers.

Also fix the following checkpatch checks with a temporary variable:

    CHECK: Alignment should match open parenthesis
    #65: FILE: drivers/net/dsa/mv88e6xxx/port.c:932:
    +		err = mv88e6xxx_port_ieeepmt_write(chip, port,
    +			   MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_INGRESS_PCP,

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/port.c | 37 ++++++++++++++++++++-----------------
 drivers/net/dsa/mv88e6xxx/port.h | 30 ++++++++++++++++++------------
 2 files changed, 38 insertions(+), 29 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 595f842c955b..166208f062e3 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -900,11 +900,15 @@ int mv88e6095_port_tag_remap(struct mv88e6xxx_chip *chip, int port)
 	int err;
 
 	/* Use a direct priority mapping for all IEEE tagged frames */
-	err = mv88e6xxx_port_write(chip, port, PORT_TAG_REGMAP_0123, 0x3210);
+	err = mv88e6xxx_port_write(chip, port,
+				   MV88E6095_PORT_IEEE_PRIO_REMAP_0123,
+				   0x3210);
 	if (err)
 		return err;
 
-	return mv88e6xxx_port_write(chip, port, PORT_TAG_REGMAP_4567, 0x7654);
+	return mv88e6xxx_port_write(chip, port,
+				    MV88E6095_PORT_IEEE_PRIO_REMAP_4567,
+				    0x7654);
 }
 
 static int mv88e6xxx_port_ieeepmt_write(struct mv88e6xxx_chip *chip,
@@ -913,40 +917,39 @@ static int mv88e6xxx_port_ieeepmt_write(struct mv88e6xxx_chip *chip,
 {
 	u16 reg;
 
-	reg = PORT_IEEE_PRIO_MAP_TABLE_UPDATE |
+	reg = MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_UPDATE |
 		table |
-		(pointer << PORT_IEEE_PRIO_MAP_TABLE_POINTER_SHIFT) |
+		(pointer << MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_POINTER_SHIFT) |
 		data;
 
-	return mv88e6xxx_port_write(chip, port, PORT_IEEE_PRIO_MAP_TABLE, reg);
+	return mv88e6xxx_port_write(chip, port,
+				    MV88E6390_PORT_IEEE_PRIO_MAP_TABLE, reg);
 }
 
 int mv88e6390_port_tag_remap(struct mv88e6xxx_chip *chip, int port)
 {
 	int err, i;
+	u16 table;
 
 	for (i = 0; i <= 7; i++) {
-		err = mv88e6xxx_port_ieeepmt_write(
-			chip, port, PORT_IEEE_PRIO_MAP_TABLE_INGRESS_PCP,
-			i, (i | i << 4));
+		table = MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_INGRESS_PCP;
+		err = mv88e6xxx_port_ieeepmt_write(chip, port, table, i,
+						   (i | i << 4));
 		if (err)
 			return err;
 
-		err = mv88e6xxx_port_ieeepmt_write(
-			chip, port, PORT_IEEE_PRIO_MAP_TABLE_EGRESS_GREEN_PCP,
-			i, i);
+		table = MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_EGRESS_GREEN_PCP;
+		err = mv88e6xxx_port_ieeepmt_write(chip, port, table, i, i);
 		if (err)
 			return err;
 
-		err = mv88e6xxx_port_ieeepmt_write(
-			chip, port, PORT_IEEE_PRIO_MAP_TABLE_EGRESS_YELLOW_PCP,
-			i, i);
+		table = MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_EGRESS_YELLOW_PCP;
+		err = mv88e6xxx_port_ieeepmt_write(chip, port, table, i, i);
 		if (err)
 			return err;
 
-		err = mv88e6xxx_port_ieeepmt_write(
-			chip, port, PORT_IEEE_PRIO_MAP_TABLE_EGRESS_AVB_PCP,
-			i, i);
+		table = MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_EGRESS_AVB_PCP;
+		err = mv88e6xxx_port_ieeepmt_write(chip, port, table, i, i);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index a855409789c3..5144941cb0db 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -199,18 +199,24 @@
 #define PORT_IN_DISCARD_HI	0x11
 #define PORT_IN_FILTERED	0x12
 #define PORT_OUT_FILTERED	0x13
-#define PORT_TAG_REGMAP_0123	0x18
-#define PORT_TAG_REGMAP_4567	0x19
-#define PORT_IEEE_PRIO_MAP_TABLE	0x18    /* 6390 */
-#define PORT_IEEE_PRIO_MAP_TABLE_UPDATE		BIT(15)
-#define PORT_IEEE_PRIO_MAP_TABLE_INGRESS_PCP		(0x0 << 12)
-#define PORT_IEEE_PRIO_MAP_TABLE_EGRESS_GREEN_PCP	(0x1 << 12)
-#define PORT_IEEE_PRIO_MAP_TABLE_EGRESS_YELLOW_PCP	(0x2 << 12)
-#define PORT_IEEE_PRIO_MAP_TABLE_EGRESS_AVB_PCP		(0x3 << 12)
-#define PORT_IEEE_PRIO_MAP_TABLE_EGRESS_GREEN_DSCP	(0x5 << 12)
-#define PORT_IEEE_PRIO_MAP_TABLE_EGRESS_YELLOW_DSCP	(0x6 << 12)
-#define PORT_IEEE_PRIO_MAP_TABLE_EGRESS_AVB_DSCP	(0x7 << 12)
-#define PORT_IEEE_PRIO_MAP_TABLE_POINTER_SHIFT		9
+
+/* Offset 0x18: IEEE Priority Mapping Table */
+#define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE			0x18
+#define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_UPDATE		0x8000
+#define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_INGRESS_PCP		0x0000
+#define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_EGRESS_GREEN_PCP	0x1000
+#define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_EGRESS_YELLOW_PCP	0x2000
+#define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_EGRESS_AVB_PCP	0x3000
+#define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_EGRESS_GREEN_DSCP	0x5000
+#define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_EGRESS_YELLOW_DSCP	0x6000
+#define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_EGRESS_AVB_DSCP	0x7000
+#define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_POINTER_SHIFT	9
+
+/* Offset 0x18: Port IEEE Priority Remapping Registers (0-3) */
+#define MV88E6095_PORT_IEEE_PRIO_REMAP_0123	0x18
+
+/* Offset 0x19: Port IEEE Priority Remapping Registers (4-7) */
+#define MV88E6095_PORT_IEEE_PRIO_REMAP_4567	0x19
 
 int mv88e6xxx_port_read(struct mv88e6xxx_chip *chip, int port, int reg,
 			u16 *val);
-- 
2.13.1
