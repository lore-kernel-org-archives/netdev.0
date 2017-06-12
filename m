From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 13/13] net: dsa: mv88e6xxx: prefix remaining port macros
Date: Mon, 12 Jun 2017 12:37:45 -0400
Message-ID: <20170612163745.16868-14-vivien.didelot@savoirfairelinux.com>
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

For implicit namespacing and clarity, prefix the remaining common Port
Registers macros with MV88E6XXX_PORT.

Document the register and prefer ordered hex masks values for all
Marvell 16-bit registers.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c |  4 ++--
 drivers/net/dsa/mv88e6xxx/port.c |  6 +++---
 drivers/net/dsa/mv88e6xxx/port.h | 35 +++++++++++++++++++++++++++--------
 3 files changed, 32 insertions(+), 13 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index e04e780ffe90..fb950ca29081 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1729,14 +1729,14 @@ static int mv88e6xxx_set_port_mode_normal(struct mv88e6xxx_chip *chip, int port)
 {
 	return mv88e6xxx_set_port_mode(chip, port, MV88E6XXX_FRAME_MODE_NORMAL,
 				       MV88E6XXX_EGRESS_MODE_UNMODIFIED,
-				       PORT_ETH_TYPE_DEFAULT);
+				       MV88E6XXX_PORT_ETH_TYPE_DEFAULT);
 }
 
 static int mv88e6xxx_set_port_mode_dsa(struct mv88e6xxx_chip *chip, int port)
 {
 	return mv88e6xxx_set_port_mode(chip, port, MV88E6XXX_FRAME_MODE_DSA,
 				       MV88E6XXX_EGRESS_MODE_UNMODIFIED,
-				       PORT_ETH_TYPE_DEFAULT);
+				       MV88E6XXX_PORT_ETH_TYPE_DEFAULT);
 }
 
 static int mv88e6xxx_set_port_mode_edsa(struct mv88e6xxx_chip *chip, int port)
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 166208f062e3..73d825e08be3 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -873,14 +873,14 @@ int mv88e6097_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port)
 
 int mv88e6xxx_port_disable_learn_limit(struct mv88e6xxx_chip *chip, int port)
 {
-	return mv88e6xxx_port_write(chip, port, PORT_ATU_CONTROL, 0);
+	return mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_ATU_CTL, 0);
 }
 
 /* Offset 0x0D: (Priority) Override Register */
 
 int mv88e6xxx_port_disable_pri_override(struct mv88e6xxx_chip *chip, int port)
 {
-	return mv88e6xxx_port_write(chip, port, PORT_PRI_OVERRIDE, 0);
+	return mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_PRI_OVERRIDE, 0);
 }
 
 /* Offset 0x0f: Port Ether type */
@@ -888,7 +888,7 @@ int mv88e6xxx_port_disable_pri_override(struct mv88e6xxx_chip *chip, int port)
 int mv88e6351_port_set_ether_type(struct mv88e6xxx_chip *chip, int port,
 				  u16 etype)
 {
-	return mv88e6xxx_port_write(chip, port, PORT_ETH_TYPE, etype);
+	return mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_ETH_TYPE, etype);
 }
 
 /* Offset 0x18: Port IEEE Priority Remapping Registers [0-3]
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 5144941cb0db..8a34ea7c868a 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -191,14 +191,33 @@
 #define MV88E6XXX_PORT_ASSOC_VECTOR_IGNORE_WRONG	0x1000
 #define MV88E6XXX_PORT_ASSOC_VECTOR_REFRESH_LOCKED	0x0800
 
-#define PORT_ATU_CONTROL	0x0c
-#define PORT_PRI_OVERRIDE	0x0d
-#define PORT_ETH_TYPE		0x0f
-#define PORT_ETH_TYPE_DEFAULT	0x9100
-#define PORT_IN_DISCARD_LO	0x10
-#define PORT_IN_DISCARD_HI	0x11
-#define PORT_IN_FILTERED	0x12
-#define PORT_OUT_FILTERED	0x13
+/* Offset 0x0C: Port ATU Control */
+#define MV88E6XXX_PORT_ATU_CTL		0x0c
+
+/* Offset 0x0D: Priority Override Register */
+#define MV88E6XXX_PORT_PRI_OVERRIDE	0x0d
+
+/* Offset 0x0E: Policy Control Register */
+#define MV88E6XXX_PORT_POLICY_CTL	0x0e
+
+/* Offset 0x0F: Port Special Ether Type */
+#define MV88E6XXX_PORT_ETH_TYPE		0x0f
+#define MV88E6XXX_PORT_ETH_TYPE_DEFAULT	0x9100
+
+/* Offset 0x10: InDiscards Low Counter */
+#define MV88E6XXX_PORT_IN_DISCARD_LO	0x10
+
+/* Offset 0x11: InDiscards High Counter */
+#define MV88E6XXX_PORT_IN_DISCARD_HI	0x11
+
+/* Offset 0x12: InFiltered Counter */
+#define MV88E6XXX_PORT_IN_FILTERED	0x12
+
+/* Offset 0x13: OutFiltered Counter */
+#define MV88E6XXX_PORT_OUT_FILTERED	0x13
+
+/* Offset 0x16: LED Control */
+#define MV88E6XXX_PORT_LED_CONTROL	0x16
 
 /* Offset 0x18: IEEE Priority Mapping Table */
 #define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE			0x18
-- 
2.13.1
