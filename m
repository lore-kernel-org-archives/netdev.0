From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 06/10] net: dsa: mv88e6xxx: prefix Global 2 PVT macros
Date: Mon, 19 Jun 2017 10:55:41 -0400
Message-ID: <20170619145545.26697-7-vivien.didelot@savoirfairelinux.com>
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

Prefix and document the Global 2 Cross-chip Port VLAN registers macros.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/global2.c | 14 ++++++++------
 drivers/net/dsa/mv88e6xxx/global2.h | 19 +++++++++++++------
 2 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 718bc9bf430d..dc6c0f5fd605 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -188,7 +188,8 @@ int mv88e6390_g2_irl_init_all(struct mv88e6xxx_chip *chip, int port)
 
 static int mv88e6xxx_g2_pvt_op_wait(struct mv88e6xxx_chip *chip)
 {
-	return mv88e6xxx_g2_wait(chip, GLOBAL2_PVT_ADDR, GLOBAL2_PVT_ADDR_BUSY);
+	return mv88e6xxx_g2_wait(chip, MV88E6XXX_G2_PVT_ADDR,
+				 MV88E6XXX_G2_PVT_ADDR_BUSY);
 }
 
 static int mv88e6xxx_g2_pvt_op(struct mv88e6xxx_chip *chip, int src_dev,
@@ -196,13 +197,14 @@ static int mv88e6xxx_g2_pvt_op(struct mv88e6xxx_chip *chip, int src_dev,
 {
 	int err;
 
-	/* 9-bit Cross-chip PVT pointer: with GLOBAL2_MISC_5_BIT_PORT cleared,
-	 * source device is 5-bit, source port is 4-bit.
+	/* 9-bit Cross-chip PVT pointer: with MV88E6XXX_G2_MISC_5_BIT_PORT
+	 * cleared, source device is 5-bit, source port is 4-bit.
 	 */
+	op |= MV88E6XXX_G2_PVT_ADDR_BUSY;
 	op |= (src_dev & 0x1f) << 4;
 	op |= (src_port & 0xf);
 
-	err = mv88e6xxx_g2_write(chip, GLOBAL2_PVT_ADDR, op);
+	err = mv88e6xxx_g2_write(chip, MV88E6XXX_G2_PVT_ADDR, op);
 	if (err)
 		return err;
 
@@ -218,12 +220,12 @@ int mv88e6xxx_g2_pvt_write(struct mv88e6xxx_chip *chip, int src_dev,
 	if (err)
 		return err;
 
-	err = mv88e6xxx_g2_write(chip, GLOBAL2_PVT_DATA, data);
+	err = mv88e6xxx_g2_write(chip, MV88E6XXX_G2_PVT_DATA, data);
 	if (err)
 		return err;
 
 	return mv88e6xxx_g2_pvt_op(chip, src_dev, src_port,
-				   GLOBAL2_PVT_ADDR_OP_WRITE_PVLAN);
+				   MV88E6XXX_G2_PVT_ADDR_OP_WRITE_PVLAN);
 }
 
 /* Offset 0x0D: Switch MAC/WoL/WoF register */
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index 4c8ae59b49d4..0133c1cdfd6c 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -79,12 +79,19 @@
 #define MV88E6XXX_G2_IRL_DATA		0x0a
 #define MV88E6XXX_G2_IRL_DATA_MASK	0xffff
 
-#define GLOBAL2_PVT_ADDR	0x0b
-#define GLOBAL2_PVT_ADDR_BUSY	BIT(15)
-#define GLOBAL2_PVT_ADDR_OP_INIT_ONES	((0x01 << 12) | GLOBAL2_PVT_ADDR_BUSY)
-#define GLOBAL2_PVT_ADDR_OP_WRITE_PVLAN	((0x03 << 12) | GLOBAL2_PVT_ADDR_BUSY)
-#define GLOBAL2_PVT_ADDR_OP_READ	((0x04 << 12) | GLOBAL2_PVT_ADDR_BUSY)
-#define GLOBAL2_PVT_DATA	0x0c
+/* Offset 0x0B: Cross-chip Port VLAN Register */
+#define MV88E6XXX_G2_PVT_ADDR			0x0b
+#define MV88E6XXX_G2_PVT_ADDR_BUSY		0x8000
+#define MV88E6XXX_G2_PVT_ADDR_OP_MASK		0x7000
+#define MV88E6XXX_G2_PVT_ADDR_OP_INIT_ONES	0x1000
+#define MV88E6XXX_G2_PVT_ADDR_OP_WRITE_PVLAN	0x3000
+#define MV88E6XXX_G2_PVT_ADDR_OP_READ		0x4000
+#define MV88E6XXX_G2_PVT_ADDR_PTR_MASK		0x01ff
+
+/* Offset 0x0C: Cross-chip Port VLAN Data Register */
+#define MV88E6XXX_G2_PVT_DATA		0x0c
+#define MV88E6XXX_G2_PVT_DATA_MASK	0x7f
+
 #define GLOBAL2_SWITCH_MAC	0x0d
 #define GLOBAL2_ATU_STATS	0x0e
 #define GLOBAL2_PRIO_OVERRIDE	0x0f
-- 
2.13.1
