From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 11/13] net: dsa: mv88e6xxx: prefix Port Association Vector macros
Date: Mon, 12 Jun 2017 12:37:43 -0400
Message-ID: <20170612163745.16868-12-vivien.didelot@savoirfairelinux.com>
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

For implicit namespacing and clarity, prefix the common Port Association
Vector Register macros with MV88E6XXX_PORT_ASSOC_VECTOR.

Document the register and prefer ordered hex masks values for all
Marvell 16-bit registers.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c |  3 ++-
 drivers/net/dsa/mv88e6xxx/port.h | 14 ++++++++------
 2 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 8146c94e394d..e04e780ffe90 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1892,7 +1892,8 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	if (dsa_is_cpu_port(ds, port))
 		reg = 0;
 
-	err = mv88e6xxx_port_write(chip, port, PORT_ASSOC_VECTOR, reg);
+	err = mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_ASSOC_VECTOR,
+				   reg);
 	if (err)
 		return err;
 
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 5bcba657a111..a855409789c3 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -183,12 +183,14 @@
 /* Offset 0x0A: Egress Rate Control 2 */
 #define MV88E6XXX_PORT_EGRESS_RATE_CTL2		0x0a
 
-#define PORT_ASSOC_VECTOR	0x0b
-#define PORT_ASSOC_VECTOR_HOLD_AT_1		BIT(15)
-#define PORT_ASSOC_VECTOR_INT_AGE_OUT		BIT(14)
-#define PORT_ASSOC_VECTOR_LOCKED_PORT		BIT(13)
-#define PORT_ASSOC_VECTOR_IGNORE_WRONG		BIT(12)
-#define PORT_ASSOC_VECTOR_REFRESH_LOCKED	BIT(11)
+/* Offset 0x0B: Port Association Vector */
+#define MV88E6XXX_PORT_ASSOC_VECTOR			0x0b
+#define MV88E6XXX_PORT_ASSOC_VECTOR_HOLD_AT_1		0x8000
+#define MV88E6XXX_PORT_ASSOC_VECTOR_INT_AGE_OUT		0x4000
+#define MV88E6XXX_PORT_ASSOC_VECTOR_LOCKED_PORT		0x2000
+#define MV88E6XXX_PORT_ASSOC_VECTOR_IGNORE_WRONG	0x1000
+#define MV88E6XXX_PORT_ASSOC_VECTOR_REFRESH_LOCKED	0x0800
+
 #define PORT_ATU_CONTROL	0x0c
 #define PORT_PRI_OVERRIDE	0x0d
 #define PORT_ETH_TYPE		0x0f
-- 
2.13.1
