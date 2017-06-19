From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 03/10] net: dsa: mv88e6xxx: prefix Global 2 Trunk macros
Date: Mon, 19 Jun 2017 10:55:38 -0400
Message-ID: <20170619145545.26697-4-vivien.didelot@savoirfairelinux.com>
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

Prefix and document the Global 2 Trunk registers macros. At the same
time, fix the hask -> hash typo and use the mv88e6xxx_port_mask helper.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/global2.c | 13 ++++++-------
 drivers/net/dsa/mv88e6xxx/global2.h | 18 +++++++++++-------
 2 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index f20a60af35cb..d821b9591a8f 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -102,15 +102,14 @@ static int mv88e6xxx_g2_set_device_mapping(struct mv88e6xxx_chip *chip)
 /* Offset 0x07: Trunk Mask Table register */
 
 static int mv88e6xxx_g2_trunk_mask_write(struct mv88e6xxx_chip *chip, int num,
-					 bool hask, u16 mask)
+					 bool hash, u16 mask)
 {
-	const u16 port_mask = BIT(mv88e6xxx_num_ports(chip)) - 1;
-	u16 val = (num << 12) | (mask & port_mask);
+	u16 val = (num << 12) | (mask & mv88e6xxx_port_mask(chip));
 
-	if (hask)
-		val |= GLOBAL2_TRUNK_MASK_HASK;
+	if (hash)
+		val |= MV88E6XXX_G2_TRUNK_MASK_HASH;
 
-	return mv88e6xxx_g2_update(chip, GLOBAL2_TRUNK_MASK, val);
+	return mv88e6xxx_g2_update(chip, MV88E6XXX_G2_TRUNK_MASK, val);
 }
 
 /* Offset 0x08: Trunk Mapping Table register */
@@ -121,7 +120,7 @@ static int mv88e6xxx_g2_trunk_mapping_write(struct mv88e6xxx_chip *chip, int id,
 	const u16 port_mask = BIT(mv88e6xxx_num_ports(chip)) - 1;
 	u16 val = (id << 11) | (map & port_mask);
 
-	return mv88e6xxx_g2_update(chip, GLOBAL2_TRUNK_MAPPING, val);
+	return mv88e6xxx_g2_update(chip, MV88E6XXX_G2_TRUNK_MAPPING, val);
 }
 
 static int mv88e6xxx_g2_clear_trunk(struct mv88e6xxx_chip *chip)
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index 8085c3bfb870..c838c51cb2a1 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -35,13 +35,17 @@
 #define GLOBAL2_DEVICE_MAPPING_UPDATE		BIT(15)
 #define GLOBAL2_DEVICE_MAPPING_TARGET_SHIFT	8
 #define GLOBAL2_DEVICE_MAPPING_PORT_MASK	0x0f
-#define GLOBAL2_TRUNK_MASK	0x07
-#define GLOBAL2_TRUNK_MASK_UPDATE		BIT(15)
-#define GLOBAL2_TRUNK_MASK_NUM_SHIFT		12
-#define GLOBAL2_TRUNK_MASK_HASK			BIT(11)
-#define GLOBAL2_TRUNK_MAPPING	0x08
-#define GLOBAL2_TRUNK_MAPPING_UPDATE		BIT(15)
-#define GLOBAL2_TRUNK_MAPPING_ID_SHIFT		11
+
+/* Offset 0x07: Trunk Mask Table Register */
+#define MV88E6XXX_G2_TRUNK_MASK			0x07
+#define MV88E6XXX_G2_TRUNK_MASK_UPDATE		0x8000
+#define MV88E6XXX_G2_TRUNK_MASK_NUM_MASK	0x7000
+#define MV88E6XXX_G2_TRUNK_MASK_HASH		0x0800
+
+/* Offset 0x08: Trunk Mapping Table Register */
+#define MV88E6XXX_G2_TRUNK_MAPPING		0x08
+#define MV88E6XXX_G2_TRUNK_MAPPING_UPDATE	0x8000
+#define MV88E6XXX_G2_TRUNK_MAPPING_ID_MASK	0x7800
 
 /* Offset 0x09: Ingress Rate Command Register */
 #define MV88E6XXX_G2_IRL_CMD			0x09
-- 
2.13.1
