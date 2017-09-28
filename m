From: Brandon Streiff <brandon.streiff@ni.com>
Subject: [PATCH net-next RFC 3/9] net: dsa: mv88e6xxx: add support for GPIO configuration
Date: Thu, 28 Sep 2017 10:25:35 -0500
Message-ID: <1506612341-18061-4-git-send-email-brandon.streiff@ni.com>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        "Vivien Didelot" <vivien.didelot@savoirfairelinux.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>,
        Brandon Streiff <brandon.streiff@ni.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Scratch/Misc register is a windowed interface that provides access
to the GPIO configuration. Provide a new method for configuration of
GPIO functions.

Signed-off-by: Brandon Streiff <brandon.streiff@ni.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c    | 13 +++++++
 drivers/net/dsa/mv88e6xxx/chip.h    |  8 +++++
 drivers/net/dsa/mv88e6xxx/global2.c | 71 +++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global2.h | 32 +++++++++++++++++
 4 files changed, 124 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 2ed37d8..4a37b26 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3218,6 +3218,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6341",
 		.num_databases = 4096,
 		.num_ports = 6,
+		.num_gpio = 11,
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
@@ -3297,6 +3298,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6172",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.num_gpio = 15,
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
@@ -3337,6 +3339,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6176",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.num_gpio = 15,
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
@@ -3375,6 +3378,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6190",
 		.num_databases = 4096,
 		.num_ports = 11,	/* 10 + Z80 */
+		.num_gpio = 16,
 		.max_vid = 8191,
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
@@ -3395,6 +3399,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6190X",
 		.num_databases = 4096,
 		.num_ports = 11,	/* 10 + Z80 */
+		.num_gpio = 16,
 		.max_vid = 8191,
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
@@ -3436,6 +3441,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6240",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.num_gpio = 15,
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
@@ -3457,6 +3463,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6290",
 		.num_databases = 4096,
 		.num_ports = 11,	/* 10 + Z80 */
+		.num_gpio = 16,
 		.max_vid = 8191,
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
@@ -3478,6 +3485,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6320",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.num_gpio = 15,
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
@@ -3498,6 +3506,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6321",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.num_gpio = 15,
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
@@ -3517,6 +3526,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6341",
 		.num_databases = 4096,
 		.num_ports = 6,
+		.num_gpio = 11,
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
@@ -3577,6 +3587,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6352",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.num_gpio = 15,
 		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
@@ -3597,6 +3608,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6390",
 		.num_databases = 4096,
 		.num_ports = 11,	/* 10 + Z80 */
+		.num_gpio = 16,
 		.max_vid = 8191,
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
@@ -3617,6 +3629,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6390X",
 		.num_databases = 4096,
 		.num_ports = 11,	/* 10 + Z80 */
+		.num_gpio = 16,
 		.max_vid = 8191,
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
diff --git a/drivers/net/dsa/mv88e6xxx/chip.h b/drivers/net/dsa/mv88e6xxx/chip.h
index 648bd50..5f132e2 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -41,6 +41,8 @@
 #define MV88E6XXX_MAX_PVT_SWITCHES	32
 #define MV88E6XXX_MAX_PVT_PORTS		16
 
+#define MV88E6XXX_MAX_GPIO	16
+
 enum mv88e6xxx_egress_mode {
 	MV88E6XXX_EGRESS_MODE_UNMODIFIED,
 	MV88E6XXX_EGRESS_MODE_UNTAGGED,
@@ -107,6 +109,7 @@ struct mv88e6xxx_info {
 	const char *name;
 	unsigned int num_databases;
 	unsigned int num_ports;
+	unsigned int num_gpio;
 	unsigned int max_vid;
 	unsigned int port_base_addr;
 	unsigned int global1_addr;
@@ -417,6 +420,11 @@ static inline u16 mv88e6xxx_port_mask(struct mv88e6xxx_chip *chip)
 	return GENMASK(mv88e6xxx_num_ports(chip) - 1, 0);
 }
 
+static inline unsigned int mv88e6xxx_num_gpio(struct mv88e6xxx_chip *chip)
+{
+	return chip->info->num_gpio;
+}
+
 int mv88e6xxx_read(struct mv88e6xxx_chip *chip, int addr, int reg, u16 *val);
 int mv88e6xxx_write(struct mv88e6xxx_chip *chip, int addr, int reg, u16 val);
 int mv88e6xxx_update(struct mv88e6xxx_chip *chip, int addr, int reg,
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index b6d0c71..fe2c970 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -971,6 +971,77 @@ int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
 						   val);
 }
 
+/* Offset 0x1A: Scratch and Misc. Register */
+static int mv88e6xxx_g2_scratch_reg_read(struct mv88e6xxx_chip *chip,
+					 int reg, u8 *data)
+{
+	int err;
+	u16 value;
+
+	err = mv88e6xxx_g2_write(chip, MV88E6XXX_G2_SCRATCH_MISC_MISC,
+				 reg << 8);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g2_read(chip, MV88E6XXX_G2_SCRATCH_MISC_MISC, &value);
+	if (err)
+		return err;
+
+	*data = (value & MV88E6XXX_G2_SCRATCH_MISC_DATA_MASK);
+
+	return 0;
+}
+
+static int mv88e6xxx_g2_scratch_reg_write(struct mv88e6xxx_chip *chip,
+					  int reg, u8 data)
+{
+	u16 value = (reg << 8) | data;
+
+	return mv88e6xxx_g2_update(chip, MV88E6XXX_G2_SCRATCH_MISC_MISC, value);
+}
+
+/* Configures the specified pin for the specified function. This function
+ * does not unset other pins configured for the same function. If multiple
+ * pins are configured for the same function, the lower-index pin gets
+ * that function and the higher-index pin goes back to being GPIO.
+ */
+int mv88e6xxx_g2_set_gpio_config(struct mv88e6xxx_chip *chip, int pin,
+				 int func, int dir)
+{
+	int mode_reg = MV88E6XXX_G2_SCRATCH_GPIO_MODE(pin);
+	int dir_reg = MV88E6XXX_G2_SCRATCH_GPIO_DIR(pin);
+	int err;
+	u8 val;
+
+	if (pin < 0 || pin >= mv88e6xxx_num_gpio(chip))
+		return -ERANGE;
+
+	/* Set function first */
+	err = mv88e6xxx_g2_scratch_reg_read(chip, mode_reg, &val);
+	if (err)
+		return err;
+
+	/* Zero bits in the field for this GPIO and OR in new config */
+	val &= ~MV88E6XXX_G2_SCRATCH_GPIO_MODE_MASK(pin);
+	val |= (func << MV88E6XXX_G2_SCRATCH_GPIO_MODE_OFFSET(pin));
+
+	err = mv88e6xxx_g2_scratch_reg_write(chip, mode_reg, val);
+	if (err)
+		return err;
+
+	/* Set direction */
+	err = mv88e6xxx_g2_scratch_reg_read(chip, dir_reg, &val);
+	if (err)
+		return err;
+
+	/* Zero bits in the field for this GPIO and OR in new config */
+	val &= ~MV88E6XXX_G2_SCRATCH_GPIO_DIR_MASK(pin);
+	val |= (dir << MV88E6XXX_G2_SCRATCH_GPIO_DIR_OFFSET(pin));
+
+	return mv88e6xxx_g2_scratch_reg_write(chip, dir_reg, val);
+}
+
+/* Offset 0x1B: Watchdog Control */
 static int mv88e6097_watchdog_action(struct mv88e6xxx_chip *chip, int irq)
 {
 	u16 reg;
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index 642d2b0..f192fc6 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -242,6 +242,29 @@
 #define MV88E6352_G2_NOEGR_POLICY	0x2000
 #define MV88E6390_G2_LAG_ID_4		0x2000
 
+/* Scratch/Misc registers accessed through MV88E6XXX_G2_SCRATCH_MISC */
+#define MV88E6XXX_G2_SCRATCH_GPIO_CONFIG_LO	0x60
+#define MV88E6XXX_G2_SCRATCH_GPIO_CONFIG_HI	0x61
+#define MV88E6XXX_G2_SCRATCH_GPIO_DIR(pin)	(0x62 + ((pin) / 8))
+#define MV88E6XXX_G2_SCRATCH_GPIO_DIR_OFFSET(pin) \
+			((pin) & 0x7)
+#define MV88E6XXX_G2_SCRATCH_GPIO_DIR_MASK(pin)	\
+			(1 << MV88E6XXX_G2_SCRATCH_GPIO_DIR_OFFSET(pin))
+#define MV88E6XXX_G2_SCRATCH_GPIO_DIR_OUT	0
+#define MV88E6XXX_G2_SCRATCH_GPIO_DIR_IN	1
+#define MV88E6XXX_G2_SCRATCH_GPIO_DATA(pin)	(0x64 + ((pin) / 8))
+#define MV88E6XXX_G2_SCRATCH_GPIO_MODE(pin)	(0x68 + ((pin) / 2))
+#define MV88E6XXX_G2_SCRATCH_GPIO_MODE_OFFSET(pin) \
+			((pin) & 0x1 ? 4 : 0)
+#define MV88E6XXX_G2_SCRATCH_GPIO_MODE_MASK(pin) \
+			(0x7 << MV88E6XXX_G2_SCRATCH_GPIO_MODE_OFFSET(pin))
+#define MV88E6XXX_G2_SCRATCH_GPIO_MODE_GPIO	0
+#define MV88E6XXX_G2_SCRATCH_GPIO_MODE_TRIG	1
+#define MV88E6XXX_G2_SCRATCH_GPIO_MODE_EVREQ	2
+#define MV88E6XXX_G2_SCRATCH_GPIO_MODE_EXTCLK	3
+#define MV88E6XXX_G2_SCRATCH_GPIO_MODE_RXCLK0	4
+#define MV88E6XXX_G2_SCRATCH_GPIO_MODE_RXCLK1	5
+
 #ifdef CONFIG_NET_DSA_MV88E6XXX_GLOBAL2
 
 static inline int mv88e6xxx_g2_require(struct mv88e6xxx_chip *chip)
@@ -270,6 +293,9 @@ int mv88e6xxx_g2_get_eeprom16(struct mv88e6xxx_chip *chip,
 int mv88e6xxx_g2_set_eeprom16(struct mv88e6xxx_chip *chip,
 			      struct ethtool_eeprom *eeprom, u8 *data);
 
+int mv88e6xxx_g2_set_gpio_config(struct mv88e6xxx_chip *chip, int pin,
+				 int func, int dir);
+
 int mv88e6xxx_g2_pvt_write(struct mv88e6xxx_chip *chip, int src_dev,
 			   int src_port, u16 data);
 int mv88e6xxx_g2_misc_4_bit_port(struct mv88e6xxx_chip *chip);
@@ -361,6 +387,12 @@ static inline int mv88e6xxx_g2_set_eeprom16(struct mv88e6xxx_chip *chip,
 	return -EOPNOTSUPP;
 }
 
+static inline int mv88e6xxx_g2_set_gpio_config(struct mv88e6xxx_chip *chip,
+					       int pin, int func, int dir)
+{
+	return -EOPNOTSUPP;
+}
+
 static inline int mv88e6xxx_g2_pvt_write(struct mv88e6xxx_chip *chip,
 					 int src_dev, int src_port, u16 data)
 {
-- 
2.1.4
