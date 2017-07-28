From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next 2/4] net: dsa: lan9303: Multiply by 4 to get MDIO register
Date: Fri, 28 Jul 2017 17:11:55 +0200
Message-ID: <20170728151157.28983-3-privat@egil-hjelmeland.no>
References: <20170728151157.28983-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170728151157.28983-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

lan9303_mdio_write()/_read() must multiply register number by 4 to get
offset.

Added some commments to the register definitions.

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 drivers/net/dsa/lan9303-core.c | 6 ++++++
 drivers/net/dsa/lan9303_mdio.c | 2 ++
 2 files changed, 8 insertions(+)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index 9d0ab77edb4a..96ebeb9bd59a 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -20,6 +20,9 @@
 
 #include "lan9303.h"
 
+/* 13.2 System Control and Status Registers
+ * Multiply register number by 4 to get address offset.
+ */
 #define LAN9303_CHIP_REV 0x14
 # define LAN9303_CHIP_ID 0x9303
 #define LAN9303_IRQ_CFG 0x15
@@ -53,6 +56,9 @@
 #define LAN9303_VIRT_PHY_BASE 0x70
 #define LAN9303_VIRT_SPECIAL_CTRL 0x77
 
+/*13.4 Switch Fabric Control and Status Registers
+ * Accessed indirectly via SWITCH_CSR_CMD, SWITCH_CSR_DATA.
+ */
 #define LAN9303_SW_DEV_ID 0x0000
 #define LAN9303_SW_RESET 0x0001
 #define LAN9303_SW_RESET_RESET BIT(0)
diff --git a/drivers/net/dsa/lan9303_mdio.c b/drivers/net/dsa/lan9303_mdio.c
index 93c36c0541cf..2db7970fc88c 100644
--- a/drivers/net/dsa/lan9303_mdio.c
+++ b/drivers/net/dsa/lan9303_mdio.c
@@ -40,6 +40,7 @@ static int lan9303_mdio_write(void *ctx, uint32_t reg, uint32_t val)
 {
 	struct lan9303_mdio *sw_dev = (struct lan9303_mdio *)ctx;
 
+	reg <<= 2; /* reg num to offset */
 	mutex_lock(&sw_dev->device->bus->mdio_lock);
 	lan9303_mdio_real_write(sw_dev->device, reg, val & 0xffff);
 	lan9303_mdio_real_write(sw_dev->device, reg + 2, (val >> 16) & 0xffff);
@@ -57,6 +58,7 @@ static int lan9303_mdio_read(void *ctx, uint32_t reg, uint32_t *val)
 {
 	struct lan9303_mdio *sw_dev = (struct lan9303_mdio *)ctx;
 
+	reg <<= 2; /* reg num to offset */
 	mutex_lock(&sw_dev->device->bus->mdio_lock);
 	*val = lan9303_mdio_real_read(sw_dev->device, reg);
 	*val |= (lan9303_mdio_real_read(sw_dev->device, reg + 2) << 16);
-- 
2.11.0
