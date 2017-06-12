From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 10/13] net: dsa: mv88e6xxx: prefix Port Egress Rate Control macros
Date: Mon, 12 Jun 2017 12:37:42 -0400
Message-ID: <20170612163745.16868-11-vivien.didelot@savoirfairelinux.com>
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

For implicit namespacing and clarity, prefix the common Port Egress Rate
Control and Port Egress Rate Control 2 registers macros with
MV88E6XXX_PORT_EGRESS_RATE_CTL1 and MV88E6XXX_PORT_EGRESS_RATE_CTL2.

Document the register and prefer ordered hex masks values for all
Marvell 16-bit registers.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 3 ++-
 drivers/net/dsa/mv88e6xxx/port.c | 6 ++++--
 drivers/net/dsa/mv88e6xxx/port.h | 8 ++++++--
 3 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index efc57003b9ee..8146c94e394d 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1897,7 +1897,8 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 		return err;
 
 	/* Egress rate control 2: disable egress rate control. */
-	err = mv88e6xxx_port_write(chip, port, PORT_RATE_CONTROL_2, 0x0000);
+	err = mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_EGRESS_RATE_CTL2,
+				   0x0000);
 	if (err)
 		return err;
 
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index ad86b2e30ac5..595f842c955b 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -859,12 +859,14 @@ int mv88e6165_port_set_jumbo_size(struct mv88e6xxx_chip *chip, int port,
 
 int mv88e6095_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port)
 {
-	return mv88e6xxx_port_write(chip, port, PORT_RATE_CONTROL, 0x0000);
+	return mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_EGRESS_RATE_CTL1,
+				    0x0000);
 }
 
 int mv88e6097_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port)
 {
-	return mv88e6xxx_port_write(chip, port, PORT_RATE_CONTROL, 0x0001);
+	return mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_EGRESS_RATE_CTL1,
+				    0x0001);
 }
 
 /* Offset 0x0C: Port ATU Control */
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index ce236f06db6d..5bcba657a111 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -177,8 +177,12 @@
 #define MV88E6XXX_PORT_CTL2_INGRESS_MONITOR		0x0010
 #define MV88E6095_PORT_CTL2_CPU_PORT_MASK		0x000f
 
-#define PORT_RATE_CONTROL	0x09
-#define PORT_RATE_CONTROL_2	0x0a
+/* Offset 0x09: Egress Rate Control */
+#define MV88E6XXX_PORT_EGRESS_RATE_CTL1		0x09
+
+/* Offset 0x0A: Egress Rate Control 2 */
+#define MV88E6XXX_PORT_EGRESS_RATE_CTL2		0x0a
+
 #define PORT_ASSOC_VECTOR	0x0b
 #define PORT_ASSOC_VECTOR_HOLD_AT_1		BIT(15)
 #define PORT_ASSOC_VECTOR_INT_AGE_OUT		BIT(14)
-- 
2.13.1
