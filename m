From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 04/13] net: dsa: mv88e6xxx: prefix Port Switch ID macros
Date: Mon, 12 Jun 2017 12:37:36 -0400
Message-ID: <20170612163745.16868-5-vivien.didelot@savoirfairelinux.com>
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

For implicit namespacing and clarity, prefix the common Switch ID
Register macros with MV88E6XXX_PORT_SWITCH_ID.

Document the register and prefer ordered hex masks values for all
Marvell 16-bit registers, this means shifting their values by 4.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 60 ++++++++++++++++++++--------------------
 drivers/net/dsa/mv88e6xxx/port.h | 58 ++++++++++++++++++++------------------
 2 files changed, 61 insertions(+), 57 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 0a2bac1cde44..7d0868a45cdc 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2181,7 +2181,7 @@ static int mv88e6xxx_mdio_read(struct mii_bus *bus, int phy, int reg)
 		 * the mv88e6390 family model number instead.
 		 */
 		if (!(val & 0x3f0))
-			val |= PORT_SWITCH_ID_PROD_NUM_6390;
+			val |= MV88E6XXX_PORT_SWITCH_ID_PROD_6390 >> 4;
 	}
 
 	return err ? err : val;
@@ -3162,7 +3162,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	[MV88E6085] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6085,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6085,
 		.family = MV88E6XXX_FAMILY_6097,
 		.name = "Marvell 88E6085",
 		.num_databases = 4096,
@@ -3180,7 +3180,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6095] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6095,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6095,
 		.family = MV88E6XXX_FAMILY_6095,
 		.name = "Marvell 88E6095/88E6095F",
 		.num_databases = 256,
@@ -3197,7 +3197,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6097] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6097,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6097,
 		.family = MV88E6XXX_FAMILY_6097,
 		.name = "Marvell 88E6097/88E6097F",
 		.num_databases = 4096,
@@ -3215,7 +3215,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6123] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6123,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6123,
 		.family = MV88E6XXX_FAMILY_6165,
 		.name = "Marvell 88E6123",
 		.num_databases = 4096,
@@ -3233,7 +3233,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6131] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6131,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6131,
 		.family = MV88E6XXX_FAMILY_6185,
 		.name = "Marvell 88E6131",
 		.num_databases = 256,
@@ -3250,7 +3250,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6141] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6141,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6141,
 		.family = MV88E6XXX_FAMILY_6341,
 		.name = "Marvell 88E6341",
 		.num_databases = 4096,
@@ -3267,7 +3267,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6161] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6161,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6161,
 		.family = MV88E6XXX_FAMILY_6165,
 		.name = "Marvell 88E6161",
 		.num_databases = 4096,
@@ -3285,7 +3285,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6165] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6165,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6165,
 		.family = MV88E6XXX_FAMILY_6165,
 		.name = "Marvell 88E6165",
 		.num_databases = 4096,
@@ -3303,7 +3303,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6171] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6171,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6171,
 		.family = MV88E6XXX_FAMILY_6351,
 		.name = "Marvell 88E6171",
 		.num_databases = 4096,
@@ -3321,7 +3321,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6172] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6172,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6172,
 		.family = MV88E6XXX_FAMILY_6352,
 		.name = "Marvell 88E6172",
 		.num_databases = 4096,
@@ -3339,7 +3339,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6175] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6175,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6175,
 		.family = MV88E6XXX_FAMILY_6351,
 		.name = "Marvell 88E6175",
 		.num_databases = 4096,
@@ -3357,7 +3357,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6176] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6176,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6176,
 		.family = MV88E6XXX_FAMILY_6352,
 		.name = "Marvell 88E6176",
 		.num_databases = 4096,
@@ -3375,7 +3375,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6185] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6185,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6185,
 		.family = MV88E6XXX_FAMILY_6185,
 		.name = "Marvell 88E6185",
 		.num_databases = 256,
@@ -3392,7 +3392,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6190] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6190,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6190,
 		.family = MV88E6XXX_FAMILY_6390,
 		.name = "Marvell 88E6190",
 		.num_databases = 4096,
@@ -3410,7 +3410,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6190X] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6190X,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6190X,
 		.family = MV88E6XXX_FAMILY_6390,
 		.name = "Marvell 88E6190X",
 		.num_databases = 4096,
@@ -3428,7 +3428,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6191] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6191,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6191,
 		.family = MV88E6XXX_FAMILY_6390,
 		.name = "Marvell 88E6191",
 		.num_databases = 4096,
@@ -3446,7 +3446,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6240] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6240,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6240,
 		.family = MV88E6XXX_FAMILY_6352,
 		.name = "Marvell 88E6240",
 		.num_databases = 4096,
@@ -3464,7 +3464,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6290] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6290,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6290,
 		.family = MV88E6XXX_FAMILY_6390,
 		.name = "Marvell 88E6290",
 		.num_databases = 4096,
@@ -3482,7 +3482,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6320] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6320,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6320,
 		.family = MV88E6XXX_FAMILY_6320,
 		.name = "Marvell 88E6320",
 		.num_databases = 4096,
@@ -3500,7 +3500,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6321] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6321,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6321,
 		.family = MV88E6XXX_FAMILY_6320,
 		.name = "Marvell 88E6321",
 		.num_databases = 4096,
@@ -3517,7 +3517,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6341] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6341,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6341,
 		.family = MV88E6XXX_FAMILY_6341,
 		.name = "Marvell 88E6341",
 		.num_databases = 4096,
@@ -3534,7 +3534,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6350] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6350,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6350,
 		.family = MV88E6XXX_FAMILY_6351,
 		.name = "Marvell 88E6350",
 		.num_databases = 4096,
@@ -3552,7 +3552,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6351] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6351,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6351,
 		.family = MV88E6XXX_FAMILY_6351,
 		.name = "Marvell 88E6351",
 		.num_databases = 4096,
@@ -3570,7 +3570,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 
 	[MV88E6352] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6352,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6352,
 		.family = MV88E6XXX_FAMILY_6352,
 		.name = "Marvell 88E6352",
 		.num_databases = 4096,
@@ -3587,7 +3587,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.ops = &mv88e6352_ops,
 	},
 	[MV88E6390] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6390,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6390,
 		.family = MV88E6XXX_FAMILY_6390,
 		.name = "Marvell 88E6390",
 		.num_databases = 4096,
@@ -3604,7 +3604,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.ops = &mv88e6390_ops,
 	},
 	[MV88E6390X] = {
-		.prod_num = PORT_SWITCH_ID_PROD_NUM_6390X,
+		.prod_num = MV88E6XXX_PORT_SWITCH_ID_PROD_6390X,
 		.family = MV88E6XXX_FAMILY_6390,
 		.name = "Marvell 88E6390X",
 		.num_databases = 4096,
@@ -3641,13 +3641,13 @@ static int mv88e6xxx_detect(struct mv88e6xxx_chip *chip)
 	int err;
 
 	mutex_lock(&chip->reg_lock);
-	err = mv88e6xxx_port_read(chip, 0, PORT_SWITCH_ID, &id);
+	err = mv88e6xxx_port_read(chip, 0, MV88E6XXX_PORT_SWITCH_ID, &id);
 	mutex_unlock(&chip->reg_lock);
 	if (err)
 		return err;
 
-	prod_num = (id & 0xfff0) >> 4;
-	rev = id & 0x000f;
+	prod_num = id & MV88E6XXX_PORT_SWITCH_ID_PROD_MASK;
+	rev = id & MV88E6XXX_PORT_SWITCH_ID_REV_MASK;
 
 	info = mv88e6xxx_lookup_info(prod_num);
 	if (!info)
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 5226a0651d8e..dc99c3159038 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -76,33 +76,37 @@
 #define MV88E6390_PORT_FLOW_CTL_LIMIT_OUT	0x0100
 #define MV88E6390_PORT_FLOW_CTL_DATA_MASK	0x00ff
 
-#define PORT_SWITCH_ID		0x03
-#define PORT_SWITCH_ID_PROD_NUM_6085	0x04a
-#define PORT_SWITCH_ID_PROD_NUM_6095	0x095
-#define PORT_SWITCH_ID_PROD_NUM_6097	0x099
-#define PORT_SWITCH_ID_PROD_NUM_6131	0x106
-#define PORT_SWITCH_ID_PROD_NUM_6320	0x115
-#define PORT_SWITCH_ID_PROD_NUM_6123	0x121
-#define PORT_SWITCH_ID_PROD_NUM_6141	0x340
-#define PORT_SWITCH_ID_PROD_NUM_6161	0x161
-#define PORT_SWITCH_ID_PROD_NUM_6165	0x165
-#define PORT_SWITCH_ID_PROD_NUM_6171	0x171
-#define PORT_SWITCH_ID_PROD_NUM_6172	0x172
-#define PORT_SWITCH_ID_PROD_NUM_6175	0x175
-#define PORT_SWITCH_ID_PROD_NUM_6176	0x176
-#define PORT_SWITCH_ID_PROD_NUM_6185	0x1a7
-#define PORT_SWITCH_ID_PROD_NUM_6190	0x190
-#define PORT_SWITCH_ID_PROD_NUM_6190X	0x0a0
-#define PORT_SWITCH_ID_PROD_NUM_6191	0x191
-#define PORT_SWITCH_ID_PROD_NUM_6240	0x240
-#define PORT_SWITCH_ID_PROD_NUM_6290	0x290
-#define PORT_SWITCH_ID_PROD_NUM_6321	0x310
-#define PORT_SWITCH_ID_PROD_NUM_6341	0x341
-#define PORT_SWITCH_ID_PROD_NUM_6352	0x352
-#define PORT_SWITCH_ID_PROD_NUM_6350	0x371
-#define PORT_SWITCH_ID_PROD_NUM_6351	0x375
-#define PORT_SWITCH_ID_PROD_NUM_6390	0x390
-#define PORT_SWITCH_ID_PROD_NUM_6390X	0x0a1
+/* Offset 0x03: Switch Identifier Register */
+#define MV88E6XXX_PORT_SWITCH_ID		0x03
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_MASK	0xfff0
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6085	0x04a0
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6095	0x0950
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6097	0x0990
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6190X	0x0a00
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6390X	0x0a10
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6131	0x1060
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6320	0x1150
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6123	0x1210
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6161	0x1610
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6165	0x1650
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6171	0x1710
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6172	0x1720
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6175	0x1750
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6176	0x1760
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6190	0x1900
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6191	0x1910
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6185	0x1a70
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6240	0x2400
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6290	0x2900
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6321	0x3100
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6141	0x3400
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6341	0x3410
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6352	0x3520
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6350	0x3710
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6351	0x3750
+#define MV88E6XXX_PORT_SWITCH_ID_PROD_6390	0x3900
+#define MV88E6XXX_PORT_SWITCH_ID_REV_MASK	0x000f
+
 #define PORT_CONTROL		0x04
 #define PORT_CONTROL_USE_CORE_TAG	BIT(15)
 #define PORT_CONTROL_DROP_ON_LOCK	BIT(14)
-- 
2.13.1
