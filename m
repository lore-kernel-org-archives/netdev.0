From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 05/10] net: dsa: mv88e6xxx: prefix Global 2 MGMT macros
Date: Mon, 19 Jun 2017 10:55:40 -0400
Message-ID: <20170619145545.26697-6-vivien.didelot@savoirfairelinux.com>
References: <20170619145545.26697-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170619145545.26697-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prefix and document the Global 2 MGMT registers macros.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/global2.c | 11 ++++++-----
 drivers/net/dsa/mv88e6xxx/global2.h | 23 +++++++++++++++--------
 2 files changed, 21 insertions(+), 13 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index d5239c4f3a9b..718bc9bf430d 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -52,7 +52,7 @@ int mv88e6095_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip)
 	 * addresses matching 01:80:c2:00:00:2x as MGMT.
 	 */
 	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_MGMT_EN_2X)) {
-		err = mv88e6xxx_g2_write(chip, GLOBAL2_MGMT_EN_2X, 0xffff);
+		err = mv88e6xxx_g2_write(chip, MV88E6XXX_G2_MGMT_EN_2X, 0xffff);
 		if (err)
 			return err;
 	}
@@ -61,7 +61,8 @@ int mv88e6095_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip)
 	 * addresses matching 01:80:c2:00:00:0x as MGMT.
 	 */
 	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_MGMT_EN_0X))
-		return mv88e6xxx_g2_write(chip, GLOBAL2_MGMT_EN_0X, 0xffff);
+		return mv88e6xxx_g2_write(chip, MV88E6XXX_G2_MGMT_EN_0X,
+					  0xffff);
 
 	return 0;
 }
@@ -1056,11 +1057,11 @@ int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 	 * highest, and send all special multicast frames to the CPU
 	 * port at the highest priority.
 	 */
-	reg = GLOBAL2_SWITCH_MGMT_FORCE_FLOW_CTRL_PRI | (0x7 << 4);
+	reg = MV88E6XXX_G2_SWITCH_MGMT_FORCE_FLOW_CTL_PRI | (0x7 << 4);
 	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_MGMT_EN_0X) ||
 	    mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_MGMT_EN_2X))
-		reg |= GLOBAL2_SWITCH_MGMT_RSVD2CPU | 0x7;
-	err = mv88e6xxx_g2_write(chip, GLOBAL2_SWITCH_MGMT, reg);
+		reg |= MV88E6XXX_G2_SWITCH_MGMT_RSVD2CPU | 0x7;
+	err = mv88e6xxx_g2_write(chip, MV88E6XXX_G2_SWITCH_MGMT, reg);
 	if (err)
 		return err;
 
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index dd9b243309a0..4c8ae59b49d4 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -22,15 +22,22 @@
 #define GLOBAL2_INT_SOURCE	0x00
 #define GLOBAL2_INT_SOURCE_WATCHDOG	15
 #define GLOBAL2_INT_MASK	0x01
-#define GLOBAL2_MGMT_EN_2X	0x02
-#define GLOBAL2_MGMT_EN_0X	0x03
+
+/* Offset 0x02: MGMT Enable Register 2x */
+#define MV88E6XXX_G2_MGMT_EN_2X		0x02
+
+/* Offset 0x03: MGMT Enable Register 0x */
+#define MV88E6XXX_G2_MGMT_EN_0X		0x03
+
 #define GLOBAL2_FLOW_CONTROL	0x04
-#define GLOBAL2_SWITCH_MGMT	0x05
-#define GLOBAL2_SWITCH_MGMT_USE_DOUBLE_TAG_DATA	BIT(15)
-#define GLOBAL2_SWITCH_MGMT_PREVENT_LOOPS	BIT(14)
-#define GLOBAL2_SWITCH_MGMT_FLOW_CONTROL_MSG	BIT(13)
-#define GLOBAL2_SWITCH_MGMT_FORCE_FLOW_CTRL_PRI	BIT(7)
-#define GLOBAL2_SWITCH_MGMT_RSVD2CPU		BIT(3)
+
+/* Offset 0x05: Switch Management Register */
+#define MV88E6XXX_G2_SWITCH_MGMT			0x05
+#define MV88E6XXX_G2_SWITCH_MGMT_USE_DOUBLE_TAG_DATA	0x8000
+#define MV88E6XXX_G2_SWITCH_MGMT_PREVENT_LOOPS		0x4000
+#define MV88E6XXX_G2_SWITCH_MGMT_FLOW_CTL_MSG		0x2000
+#define MV88E6XXX_G2_SWITCH_MGMT_FORCE_FLOW_CTL_PRI	0x0080
+#define MV88E6XXX_G2_SWITCH_MGMT_RSVD2CPU		0x0008
 
 /* Offset 0x06: Device Mapping Table Register */
 #define MV88E6XXX_G2_DEVICE_MAPPING		0x06
-- 
2.13.1
