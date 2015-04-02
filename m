From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 11/12] net: dsa: Use mnemonics rather than register numbers
Date: Thu,  2 Apr 2015 04:06:39 +0200
Message-ID: <1427940400-12434-12-git-send-email-andrew@lunn.ch>
References: <1427940400-12434-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35811 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752655AbbDBCLE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 22:11:04 -0400
In-Reply-To: <1427940400-12434-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than refer to registers by number, define mnemonics. Also
define mnemonics for the commonly used bits within the registers.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Guenter Roeck <linux@roeck-us.net>
Tested-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6123_61_65.c |  26 ++--
 drivers/net/dsa/mv88e6131.c       |  24 ++--
 drivers/net/dsa/mv88e6171.c       |  10 +-
 drivers/net/dsa/mv88e6352.c       |  10 +-
 drivers/net/dsa/mv88e6xxx.c       | 195 +++++++++++++++++-------------
 drivers/net/dsa/mv88e6xxx.h       | 248 +++++++++++++++++++++++++++++---------
 6 files changed, 335 insertions(+), 178 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index 81cc24448164..b4af6d5aff7c 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -25,27 +25,27 @@ static char *mv88e6123_61_65_probe(struct device *host_dev, int sw_addr)
 	if (bus == NULL)
 		return NULL;
 
-	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), 0x03);
+	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
 	if (ret >= 0) {
-		if (ret == ID_6123_A1)
+		if (ret == PORT_SWITCH_ID_6123_A1)
 			return "Marvell 88E6123 (A1)";
-		if (ret == ID_6123_A2)
+		if (ret == PORT_SWITCH_ID_6123_A2)
 			return "Marvell 88E6123 (A2)";
-		if ((ret & 0xfff0) == ID_6123)
+		if ((ret & 0xfff0) == PORT_SWITCH_ID_6123)
 			return "Marvell 88E6123";
 
-		if (ret == ID_6161_A1)
+		if (ret == PORT_SWITCH_ID_6161_A1)
 			return "Marvell 88E6161 (A1)";
-		if (ret == ID_6161_A2)
+		if (ret == PORT_SWITCH_ID_6161_A2)
 			return "Marvell 88E6161 (A2)";
-		if ((ret & 0xfff0) == ID_6161)
+		if ((ret & 0xfff0) == PORT_SWITCH_ID_6161)
 			return "Marvell 88E6161";
 
-		if (ret == ID_6165_A1)
+		if (ret == PORT_SWITCH_ID_6165_A1)
 			return "Marvell 88E6165 (A1)";
-		if (ret == ID_6165_A2)
+		if (ret == PORT_SWITCH_ID_6165_A2)
 			return "Marvell 88e6165 (A2)";
-		if ((ret & 0xfff0) == ID_6165)
+		if ((ret & 0xfff0) == PORT_SWITCH_ID_6165)
 			return "Marvell 88E6165";
 	}
 
@@ -247,11 +247,11 @@ static int mv88e6123_61_65_setup(struct dsa_switch *ds)
 		return ret;
 
 	switch (ps->id) {
-	case ID_6123:
+	case PORT_SWITCH_ID_6123:
 		ps->num_ports = 3;
 		break;
-	case ID_6161:
-	case ID_6165:
+	case PORT_SWITCH_ID_6161:
+	case PORT_SWITCH_ID_6165:
 		ps->num_ports = 6;
 		break;
 	default:
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 5bec7a60b476..e54824fa0d95 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -25,17 +25,17 @@ static char *mv88e6131_probe(struct device *host_dev, int sw_addr)
 	if (bus == NULL)
 		return NULL;
 
-	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), 0x03);
+	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
 	if (ret >= 0) {
 		int ret_masked = ret & 0xfff0;
 
-		if (ret_masked == ID_6085)
+		if (ret_masked == PORT_SWITCH_ID_6085)
 			return "Marvell 88E6085";
-		if (ret_masked == ID_6095)
+		if (ret_masked == PORT_SWITCH_ID_6095)
 			return "Marvell 88E6095/88E6095F";
-		if (ret == ID_6131_B2)
+		if (ret == PORT_SWITCH_ID_6131_B2)
 			return "Marvell 88E6131 (B2)";
-		if (ret_masked == ID_6131)
+		if (ret_masked == PORT_SWITCH_ID_6131)
 			return "Marvell 88E6131";
 	}
 
@@ -135,7 +135,7 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 	 * (100 Mb/s on 6085) full duplex.
 	 */
 	if (dsa_is_cpu_port(ds, p) || ds->dsa_port_mask & (1 << p))
-		if (ps->id == ID_6085)
+		if (ps->id == PORT_SWITCH_ID_6085)
 			REG_WRITE(addr, 0x01, 0x003d); /* 100 Mb/s */
 		else
 			REG_WRITE(addr, 0x01, 0x003e); /* 1000 Mb/s */
@@ -162,7 +162,7 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 		/* On 6085, unknown multicast forward is controlled
 		 * here rather than in Port Control 2 register.
 		 */
-		if (ps->id == ID_6085)
+		if (ps->id == PORT_SWITCH_ID_6085)
 			val |= 0x0008;
 	}
 	if (ds->dsa_port_mask & (1 << p))
@@ -181,7 +181,7 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 	 * If this is the upstream port for this switch, enable
 	 * forwarding of unknown multicast addresses.
 	 */
-	if (ps->id == ID_6085)
+	if (ps->id == PORT_SWITCH_ID_6085)
 		/* on 6085, bits 3:0 are reserved, bit 6 control ARP
 		 * mirroring, and multicast forward is handled in
 		 * Port Control register.
@@ -233,14 +233,14 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 	mv88e6xxx_ppu_state_init(ds);
 
 	switch (ps->id) {
-	case ID_6085:
+	case PORT_SWITCH_ID_6085:
 		ps->num_ports = 10;
 		break;
-	case ID_6095:
+	case PORT_SWITCH_ID_6095:
 		ps->num_ports = 11;
 		break;
-	case ID_6131:
-	case ID_6131_B2:
+	case PORT_SWITCH_ID_6131:
+	case PORT_SWITCH_ID_6131_B2:
 		ps->num_ports = 8;
 		break;
 	default:
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 7314e7d71a67..9104efea0e3e 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -25,11 +25,11 @@ static char *mv88e6171_probe(struct device *host_dev, int sw_addr)
 	if (bus == NULL)
 		return NULL;
 
-	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), 0x03);
+	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
 	if (ret >= 0) {
-		if ((ret & 0xfff0) == ID_6171)
+		if ((ret & 0xfff0) == PORT_SWITCH_ID_6171)
 			return "Marvell 88E6171";
-		if ((ret & 0xfff0) == ID_6172)
+		if ((ret & 0xfff0) == PORT_SWITCH_ID_6172)
 			return "Marvell 88E6172";
 	}
 
@@ -263,7 +263,7 @@ static int mv88e6171_get_eee(struct dsa_switch *ds, int port,
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
-	if (ps->id == ID_6172)
+	if (ps->id == PORT_SWITCH_ID_6172)
 		return mv88e6xxx_get_eee(ds, port, e);
 
 	return -EOPNOTSUPP;
@@ -274,7 +274,7 @@ static int mv88e6171_set_eee(struct dsa_switch *ds, int port,
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
-	if (ps->id == ID_6172)
+	if (ps->id == PORT_SWITCH_ID_6172)
 		return mv88e6xxx_set_eee(ds, port, phydev, e);
 
 	return -EOPNOTSUPP;
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index a1be6e3c0351..126c11b81e75 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -30,15 +30,15 @@ static char *mv88e6352_probe(struct device *host_dev, int sw_addr)
 	if (bus == NULL)
 		return NULL;
 
-	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), 0x03);
+	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
 	if (ret >= 0) {
-		if ((ret & 0xfff0) == 0x1760)
+		if ((ret & 0xfff0) == PORT_SWITCH_ID_6176)
 			return "Marvell 88E6176";
-		if (ret == 0x3521)
+		if (ret == PORT_SWITCH_ID_6352_A0)
 			return "Marvell 88E6352 (A0)";
-		if (ret == 0x3522)
+		if (ret == PORT_SWITCH_ID_6352_A1)
 			return "Marvell 88E6352 (A1)";
-		if ((ret & 0xfff0) == 0x3520)
+		if ((ret & 0xfff0) == PORT_SWITCH_ID_6352)
 			return "Marvell 88E6352";
 	}
 
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index b360fe5346d3..488b6545dfb5 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -33,11 +33,11 @@ static int mv88e6xxx_reg_wait_ready(struct mii_bus *bus, int sw_addr)
 	int i;
 
 	for (i = 0; i < 16; i++) {
-		ret = mdiobus_read(bus, sw_addr, 0);
+		ret = mdiobus_read(bus, sw_addr, SMI_CMD);
 		if (ret < 0)
 			return ret;
 
-		if ((ret & 0x8000) == 0)
+		if ((ret & SMI_CMD_BUSY) == 0)
 			return 0;
 	}
 
@@ -57,7 +57,8 @@ int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg)
 		return ret;
 
 	/* Transmit the read command. */
-	ret = mdiobus_write(bus, sw_addr, 0, 0x9800 | (addr << 5) | reg);
+	ret = mdiobus_write(bus, sw_addr, SMI_CMD,
+			    SMI_CMD_OP_22_READ | (addr << 5) | reg);
 	if (ret < 0)
 		return ret;
 
@@ -67,7 +68,7 @@ int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg)
 		return ret;
 
 	/* Read the data. */
-	ret = mdiobus_read(bus, sw_addr, 1);
+	ret = mdiobus_read(bus, sw_addr, SMI_DATA);
 	if (ret < 0)
 		return ret;
 
@@ -119,12 +120,13 @@ int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
 		return ret;
 
 	/* Transmit the data to write. */
-	ret = mdiobus_write(bus, sw_addr, 1, val);
+	ret = mdiobus_write(bus, sw_addr, SMI_DATA, val);
 	if (ret < 0)
 		return ret;
 
 	/* Transmit the write command. */
-	ret = mdiobus_write(bus, sw_addr, 0, 0x9400 | (addr << 5) | reg);
+	ret = mdiobus_write(bus, sw_addr, SMI_CMD,
+			    SMI_CMD_OP_22_WRITE | (addr << 5) | reg);
 	if (ret < 0)
 		return ret;
 
@@ -166,26 +168,26 @@ int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
 int mv88e6xxx_config_prio(struct dsa_switch *ds)
 {
 	/* Configure the IP ToS mapping registers. */
-	REG_WRITE(REG_GLOBAL, 0x10, 0x0000);
-	REG_WRITE(REG_GLOBAL, 0x11, 0x0000);
-	REG_WRITE(REG_GLOBAL, 0x12, 0x5555);
-	REG_WRITE(REG_GLOBAL, 0x13, 0x5555);
-	REG_WRITE(REG_GLOBAL, 0x14, 0xaaaa);
-	REG_WRITE(REG_GLOBAL, 0x15, 0xaaaa);
-	REG_WRITE(REG_GLOBAL, 0x16, 0xffff);
-	REG_WRITE(REG_GLOBAL, 0x17, 0xffff);
+	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_0, 0x0000);
+	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_1, 0x0000);
+	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_2, 0x5555);
+	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_3, 0x5555);
+	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_4, 0xaaaa);
+	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_5, 0xaaaa);
+	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_6, 0xffff);
+	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_7, 0xffff);
 
 	/* Configure the IEEE 802.1p priority mapping register. */
-	REG_WRITE(REG_GLOBAL, 0x18, 0xfa41);
+	REG_WRITE(REG_GLOBAL, GLOBAL_IEEE_PRI, 0xfa41);
 
 	return 0;
 }
 
 int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr)
 {
-	REG_WRITE(REG_GLOBAL, 0x01, (addr[0] << 8) | addr[1]);
-	REG_WRITE(REG_GLOBAL, 0x02, (addr[2] << 8) | addr[3]);
-	REG_WRITE(REG_GLOBAL, 0x03, (addr[4] << 8) | addr[5]);
+	REG_WRITE(REG_GLOBAL, GLOBAL_MAC_01, (addr[0] << 8) | addr[1]);
+	REG_WRITE(REG_GLOBAL, GLOBAL_MAC_23, (addr[2] << 8) | addr[3]);
+	REG_WRITE(REG_GLOBAL, GLOBAL_MAC_45, (addr[4] << 8) | addr[5]);
 
 	return 0;
 }
@@ -199,12 +201,13 @@ int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
 		int j;
 
 		/* Write the MAC address byte. */
-		REG_WRITE(REG_GLOBAL2, 0x0d, 0x8000 | (i << 8) | addr[i]);
+		REG_WRITE(REG_GLOBAL2, GLOBAL2_SWITCH_MAC,
+			  GLOBAL2_SWITCH_MAC_BUSY | (i << 8) | addr[i]);
 
 		/* Wait for the write to complete. */
 		for (j = 0; j < 16; j++) {
-			ret = REG_READ(REG_GLOBAL2, 0x0d);
-			if ((ret & 0x8000) == 0)
+			ret = REG_READ(REG_GLOBAL2, GLOBAL2_SWITCH_MAC);
+			if ((ret & GLOBAL2_SWITCH_MAC_BUSY) == 0)
 				break;
 		}
 		if (j == 16)
@@ -237,14 +240,16 @@ static int mv88e6xxx_ppu_disable(struct dsa_switch *ds)
 	int ret;
 	unsigned long timeout;
 
-	ret = REG_READ(REG_GLOBAL, 0x04);
-	REG_WRITE(REG_GLOBAL, 0x04, ret & ~0x4000);
+	ret = REG_READ(REG_GLOBAL, GLOBAL_CONTROL);
+	REG_WRITE(REG_GLOBAL, GLOBAL_CONTROL,
+		  ret & ~GLOBAL_CONTROL_PPU_ENABLE);
 
 	timeout = jiffies + 1 * HZ;
 	while (time_before(jiffies, timeout)) {
-		ret = REG_READ(REG_GLOBAL, 0x00);
+		ret = REG_READ(REG_GLOBAL, GLOBAL_STATUS);
 		usleep_range(1000, 2000);
-		if ((ret & 0xc000) != 0xc000)
+		if ((ret & GLOBAL_STATUS_PPU_MASK) !=
+		    GLOBAL_STATUS_PPU_POLLING)
 			return 0;
 	}
 
@@ -256,14 +261,15 @@ static int mv88e6xxx_ppu_enable(struct dsa_switch *ds)
 	int ret;
 	unsigned long timeout;
 
-	ret = REG_READ(REG_GLOBAL, 0x04);
-	REG_WRITE(REG_GLOBAL, 0x04, ret | 0x4000);
+	ret = REG_READ(REG_GLOBAL, GLOBAL_CONTROL);
+	REG_WRITE(REG_GLOBAL, GLOBAL_CONTROL, ret | GLOBAL_CONTROL_PPU_ENABLE);
 
 	timeout = jiffies + 1 * HZ;
 	while (time_before(jiffies, timeout)) {
-		ret = REG_READ(REG_GLOBAL, 0x00);
+		ret = REG_READ(REG_GLOBAL, GLOBAL_STATUS);
 		usleep_range(1000, 2000);
-		if ((ret & 0xc000) == 0xc000)
+		if ((ret & GLOBAL_STATUS_PPU_MASK) ==
+		    GLOBAL_STATUS_PPU_POLLING)
 			return 0;
 	}
 
@@ -384,11 +390,12 @@ void mv88e6xxx_poll_link(struct dsa_switch *ds)
 
 		link = 0;
 		if (dev->flags & IFF_UP) {
-			port_status = mv88e6xxx_reg_read(ds, REG_PORT(i), 0x00);
+			port_status = mv88e6xxx_reg_read(ds, REG_PORT(i),
+							 PORT_STATUS);
 			if (port_status < 0)
 				continue;
 
-			link = !!(port_status & 0x0800);
+			link = !!(port_status & PORT_STATUS_LINK);
 		}
 
 		if (!link) {
@@ -399,22 +406,22 @@ void mv88e6xxx_poll_link(struct dsa_switch *ds)
 			continue;
 		}
 
-		switch (port_status & 0x0300) {
-		case 0x0000:
+		switch (port_status & PORT_STATUS_SPEED_MASK) {
+		case PORT_STATUS_SPEED_10:
 			speed = 10;
 			break;
-		case 0x0100:
+		case PORT_STATUS_SPEED_100:
 			speed = 100;
 			break;
-		case 0x0200:
+		case PORT_STATUS_SPEED_1000:
 			speed = 1000;
 			break;
 		default:
 			speed = -1;
 			break;
 		}
-		duplex = (port_status & 0x0400) ? 1 : 0;
-		fc = (port_status & 0x8000) ? 1 : 0;
+		duplex = (port_status & PORT_STATUS_DUPLEX) ? 1 : 0;
+		fc = (port_status & PORT_STATUS_PAUSE_EN) ? 1 : 0;
 
 		if (!netif_carrier_ok(dev)) {
 			netdev_info(dev,
@@ -433,8 +440,8 @@ static int mv88e6xxx_stats_wait(struct dsa_switch *ds)
 	int i;
 
 	for (i = 0; i < 10; i++) {
-		ret = REG_READ(REG_GLOBAL, 0x1d);
-		if ((ret & 0x8000) == 0)
+		ret = REG_READ(REG_GLOBAL, GLOBAL_STATS_OP);
+		if ((ret & GLOBAL_STATS_OP_BUSY) == 0)
 			return 0;
 	}
 
@@ -446,7 +453,9 @@ static int mv88e6xxx_stats_snapshot(struct dsa_switch *ds, int port)
 	int ret;
 
 	/* Snapshot the hardware statistics counters for this port. */
-	REG_WRITE(REG_GLOBAL, 0x1d, 0xdc00 | port);
+	REG_WRITE(REG_GLOBAL, GLOBAL_STATS_OP,
+		  GLOBAL_STATS_OP_CAPTURE_PORT |
+		  GLOBAL_STATS_OP_HIST_RX_TX | port);
 
 	/* Wait for the snapshotting to complete. */
 	ret = mv88e6xxx_stats_wait(ds);
@@ -463,7 +472,9 @@ static void mv88e6xxx_stats_read(struct dsa_switch *ds, int stat, u32 *val)
 
 	*val = 0;
 
-	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x1d, 0xcc00 | stat);
+	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_STATS_OP,
+				  GLOBAL_STATS_OP_READ_CAPTURED |
+				  GLOBAL_STATS_OP_HIST_RX_TX | stat);
 	if (ret < 0)
 		return;
 
@@ -471,13 +482,13 @@ static void mv88e6xxx_stats_read(struct dsa_switch *ds, int stat, u32 *val)
 	if (ret < 0)
 		return;
 
-	ret = mv88e6xxx_reg_read(ds, REG_GLOBAL, 0x1e);
+	ret = mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_STATS_COUNTER_32);
 	if (ret < 0)
 		return;
 
 	_val = ret << 16;
 
-	ret = mv88e6xxx_reg_read(ds, REG_GLOBAL, 0x1f);
+	ret = mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_STATS_COUNTER_01);
 	if (ret < 0)
 		return;
 
@@ -527,9 +538,11 @@ static bool have_sw_in_discards(struct dsa_switch *ds)
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
 	switch (ps->id) {
-	case ID_6095: case ID_6161: case ID_6165:
-	case ID_6171: case ID_6172: case ID_6176:
-	case ID_6182: case ID_6185: case ID_6352:
+	case PORT_SWITCH_ID_6095: case PORT_SWITCH_ID_6161:
+	case PORT_SWITCH_ID_6165: case PORT_SWITCH_ID_6171:
+	case PORT_SWITCH_ID_6172: case PORT_SWITCH_ID_6176:
+	case PORT_SWITCH_ID_6182: case PORT_SWITCH_ID_6185:
+	case PORT_SWITCH_ID_6352:
 		return true;
 	default:
 		return false;
@@ -723,17 +736,20 @@ static int mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset, u16 mask)
 
 int mv88e6xxx_phy_wait(struct dsa_switch *ds)
 {
-	return mv88e6xxx_wait(ds, REG_GLOBAL2, 0x18, 0x8000);
+	return mv88e6xxx_wait(ds, REG_GLOBAL2, GLOBAL2_SMI_OP,
+			      GLOBAL2_SMI_OP_BUSY);
 }
 
 int mv88e6xxx_eeprom_load_wait(struct dsa_switch *ds)
 {
-	return mv88e6xxx_wait(ds, REG_GLOBAL2, 0x14, 0x0800);
+	return mv88e6xxx_wait(ds, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
+			      GLOBAL2_EEPROM_OP_LOAD);
 }
 
 int mv88e6xxx_eeprom_busy_wait(struct dsa_switch *ds)
 {
-	return mv88e6xxx_wait(ds, REG_GLOBAL2, 0x14, 0x8000);
+	return mv88e6xxx_wait(ds, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
+			      GLOBAL2_EEPROM_OP_BUSY);
 }
 
 /* Must be called with SMI lock held */
@@ -758,7 +774,8 @@ static int _mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset, u16 mask)
 /* Must be called with SMI lock held */
 static int _mv88e6xxx_atu_wait(struct dsa_switch *ds)
 {
-	return _mv88e6xxx_wait(ds, REG_GLOBAL, 0x0b, ATU_BUSY);
+	return _mv88e6xxx_wait(ds, REG_GLOBAL, GLOBAL_ATU_OP,
+			       GLOBAL_ATU_OP_BUSY);
 }
 
 /* Must be called with phy mutex held */
@@ -767,21 +784,23 @@ static int _mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int addr,
 {
 	int ret;
 
-	REG_WRITE(REG_GLOBAL2, 0x18, 0x9800 | (addr << 5) | regnum);
+	REG_WRITE(REG_GLOBAL2, GLOBAL2_SMI_OP,
+		  GLOBAL2_SMI_OP_22_READ | (addr << 5) | regnum);
 
 	ret = mv88e6xxx_phy_wait(ds);
 	if (ret < 0)
 		return ret;
 
-	return REG_READ(REG_GLOBAL2, 0x19);
+	return REG_READ(REG_GLOBAL2, GLOBAL2_SMI_DATA);
 }
 
 /* Must be called with phy mutex held */
 static int _mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int addr,
 					 int regnum, u16 val)
 {
-	REG_WRITE(REG_GLOBAL2, 0x19, val);
-	REG_WRITE(REG_GLOBAL2, 0x18, 0x9400 | (addr << 5) | regnum);
+	REG_WRITE(REG_GLOBAL2, GLOBAL2_SMI_DATA, val);
+	REG_WRITE(REG_GLOBAL2, GLOBAL2_SMI_OP,
+		  GLOBAL2_SMI_OP_22_WRITE | (addr << 5) | regnum);
 
 	return mv88e6xxx_phy_wait(ds);
 }
@@ -800,11 +819,11 @@ int mv88e6xxx_get_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e)
 	e->eee_enabled = !!(reg & 0x0200);
 	e->tx_lpi_enabled = !!(reg & 0x0100);
 
-	reg = mv88e6xxx_reg_read(ds, REG_PORT(port), 0);
+	reg = mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_STATUS);
 	if (reg < 0)
 		goto out;
 
-	e->eee_active = !!(reg & 0x0040);
+	e->eee_active = !!(reg & PORT_STATUS_EEE);
 	reg = 0;
 
 out:
@@ -846,7 +865,7 @@ static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, int fid, u16 cmd)
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x0b, cmd);
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_OP, cmd);
 	if (ret < 0)
 		return ret;
 
@@ -861,7 +880,7 @@ static int _mv88e6xxx_flush_fid(struct dsa_switch *ds, int fid)
 	if (ret < 0)
 		return ret;
 
-	return _mv88e6xxx_atu_cmd(ds, fid, ATU_CMD_FLUSH_NONSTATIC_FID);
+	return _mv88e6xxx_atu_cmd(ds, fid, GLOBAL_ATU_OP_FLUSH_NON_STATIC_DB);
 }
 
 static int mv88e6xxx_set_port_state(struct dsa_switch *ds, int port, u8 state)
@@ -872,23 +891,25 @@ static int mv88e6xxx_set_port_state(struct dsa_switch *ds, int port, u8 state)
 
 	mutex_lock(&ps->smi_mutex);
 
-	reg = _mv88e6xxx_reg_read(ds, REG_PORT(port), 0x04);
+	reg = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_CONTROL);
 	if (reg < 0)
 		goto abort;
 
-	oldstate = reg & PSTATE_MASK;
+	oldstate = reg & PORT_CONTROL_STATE_MASK;
 	if (oldstate != state) {
 		/* Flush forwarding database if we're moving a port
 		 * from Learning or Forwarding state to Disabled or
 		 * Blocking or Listening state.
 		 */
-		if (oldstate >= PSTATE_LEARNING && state <= PSTATE_BLOCKING) {
+		if (oldstate >= PORT_CONTROL_STATE_LEARNING &&
+		    state <= PORT_CONTROL_STATE_BLOCKING) {
 			ret = _mv88e6xxx_flush_fid(ds, ps->fid[port]);
 			if (ret)
 				goto abort;
 		}
-		reg = (reg & ~PSTATE_MASK) | state;
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), 0x04, reg);
+		reg = (reg & ~PORT_CONTROL_STATE_MASK) | state;
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_CONTROL,
+					   reg);
 	}
 
 abort:
@@ -909,7 +930,7 @@ static int _mv88e6xxx_update_port_config(struct dsa_switch *ds, int port)
 		reg |= (ps->bridge_mask[fid] |
 		       (1 << dsa_upstream_port(ds))) & ~(1 << port);
 
-	return _mv88e6xxx_reg_write(ds, REG_PORT(port), 0x06, reg);
+	return _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_BASE_VLAN, reg);
 }
 
 /* Must be called with smi lock held */
@@ -1021,18 +1042,18 @@ int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state)
 
 	switch (state) {
 	case BR_STATE_DISABLED:
-		stp_state = PSTATE_DISABLED;
+		stp_state = PORT_CONTROL_STATE_DISABLED;
 		break;
 	case BR_STATE_BLOCKING:
 	case BR_STATE_LISTENING:
-		stp_state = PSTATE_BLOCKING;
+		stp_state = PORT_CONTROL_STATE_BLOCKING;
 		break;
 	case BR_STATE_LEARNING:
-		stp_state = PSTATE_LEARNING;
+		stp_state = PORT_CONTROL_STATE_LEARNING;
 		break;
 	case BR_STATE_FORWARDING:
 	default:
-		stp_state = PSTATE_FORWARDING;
+		stp_state = PORT_CONTROL_STATE_FORWARDING;
 		break;
 	}
 
@@ -1054,8 +1075,9 @@ static int __mv88e6xxx_write_addr(struct dsa_switch *ds,
 	int i, ret;
 
 	for (i = 0; i < 3; i++) {
-		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x0d + i,
-					(addr[i * 2] << 8) | addr[i * 2 + 1]);
+		ret = _mv88e6xxx_reg_write(
+			ds, REG_GLOBAL, GLOBAL_ATU_MAC_01 + i,
+			(addr[i * 2] << 8) | addr[i * 2 + 1]);
 		if (ret < 0)
 			return ret;
 	}
@@ -1068,7 +1090,8 @@ static int __mv88e6xxx_read_addr(struct dsa_switch *ds, unsigned char *addr)
 	int i, ret;
 
 	for (i = 0; i < 3; i++) {
-		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, 0x0d + i);
+		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL,
+					  GLOBAL_ATU_MAC_01 + i);
 		if (ret < 0)
 			return ret;
 		addr[i * 2] = ret >> 8;
@@ -1093,12 +1116,12 @@ static int __mv88e6xxx_port_fdb_cmd(struct dsa_switch *ds, int port,
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x0c,
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_DATA,
 				   (0x10 << port) | state);
 	if (ret)
 		return ret;
 
-	ret = _mv88e6xxx_atu_cmd(ds, fid, ATU_CMD_LOAD_FID);
+	ret = _mv88e6xxx_atu_cmd(ds, fid, GLOBAL_ATU_OP_LOAD_DB);
 
 	return ret;
 }
@@ -1107,7 +1130,8 @@ int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 			   const unsigned char *addr, u16 vid)
 {
 	int state = is_multicast_ether_addr(addr) ?
-					FDB_STATE_MC_STATIC : FDB_STATE_STATIC;
+		GLOBAL_ATU_DATA_STATE_MC_STATIC :
+		GLOBAL_ATU_DATA_STATE_UC_STATIC;
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
@@ -1125,7 +1149,8 @@ int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = __mv88e6xxx_port_fdb_cmd(ds, port, addr, FDB_STATE_UNUSED);
+	ret = __mv88e6xxx_port_fdb_cmd(ds, port, addr,
+				       GLOBAL_ATU_DATA_STATE_UNUSED);
 	mutex_unlock(&ps->smi_mutex);
 
 	return ret;
@@ -1147,15 +1172,15 @@ static int __mv88e6xxx_port_getnext(struct dsa_switch *ds, int port,
 		return ret;
 
 	do {
-		ret = _mv88e6xxx_atu_cmd(ds, fid, ATU_CMD_GETNEXT_FID);
+		ret = _mv88e6xxx_atu_cmd(ds, fid,  GLOBAL_ATU_OP_GET_NEXT_DB);
 		if (ret < 0)
 			return ret;
 
-		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, 0x0c);
+		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_ATU_DATA);
 		if (ret < 0)
 			return ret;
-		state = ret & FDB_STATE_MASK;
-		if (state == FDB_STATE_UNUSED)
+		state = ret & GLOBAL_ATU_DATA_STATE_MASK;
+		if (state == GLOBAL_ATU_DATA_STATE_UNUSED)
 			return -ENOENT;
 	} while (!(((ret >> 4) & 0xff) & (1 << port)));
 
@@ -1164,7 +1189,8 @@ static int __mv88e6xxx_port_getnext(struct dsa_switch *ds, int port,
 		return ret;
 
 	*is_static = state == (is_multicast_ether_addr(addr) ?
-			       FDB_STATE_MC_STATIC : FDB_STATE_STATIC);
+			       GLOBAL_ATU_DATA_STATE_MC_STATIC :
+			       GLOBAL_ATU_DATA_STATE_UC_STATIC);
 
 	return 0;
 }
@@ -1209,7 +1235,8 @@ int mv88e6xxx_setup_port_common(struct dsa_switch *ds, int port)
 	/* Port Control 1: disable trunking, disable sending
 	 * learning messages to this port.
 	 */
-	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), 0x05, 0x0000);
+	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_DEFAULT_VLAN,
+				   0x0000);
 	if (ret)
 		goto abort;
 
@@ -1246,7 +1273,7 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 	mutex_init(&ps->stats_mutex);
 	mutex_init(&ps->phy_mutex);
 
-	ps->id = REG_READ(REG_PORT(0), 0x03) & 0xfff0;
+	ps->id = REG_READ(REG_PORT(0), PORT_SWITCH_ID) & 0xfff0;
 
 	ps->fid_mask = (1 << DSA_MAX_PORTS) - 1;
 
@@ -1265,8 +1292,8 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
 
 	/* Set all ports to the disabled state. */
 	for (i = 0; i < ps->num_ports; i++) {
-		ret = REG_READ(REG_PORT(i), 0x04);
-		REG_WRITE(REG_PORT(i), 0x04, ret & 0xfffc);
+		ret = REG_READ(REG_PORT(i), PORT_CONTROL);
+		REG_WRITE(REG_PORT(i), PORT_CONTROL, ret & 0xfffc);
 	}
 
 	/* Wait for transmit queues to drain. */
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index fbbedc07754f..e045154f3364 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -11,69 +11,199 @@
 #ifndef __MV88E6XXX_H
 #define __MV88E6XXX_H
 
-/* switch product IDs */
-
-#define ID_6085		0x04a0
-#define ID_6095		0x0950
-
-#define ID_6123		0x1210
-#define ID_6123_A1	0x1212
-#define ID_6123_A2	0x1213
-
-#define ID_6131		0x1060
-#define ID_6131_B2	0x1066
-
-#define ID_6152		0x1a40
-#define ID_6155		0x1a50
-
-#define ID_6161		0x1610
-#define ID_6161_A1	0x1612
-#define ID_6161_A2	0x1613
-
-#define ID_6165		0x1650
-#define ID_6165_A1	0x1652
-#define ID_6165_A2	0x1653
-
-#define ID_6171		0x1710
-#define ID_6172		0x1720
-#define ID_6176		0x1760
-
-#define ID_6182		0x1a60
-#define ID_6185		0x1a70
-
-#define ID_6352		0x3520
-#define ID_6352_A0	0x3521
-#define ID_6352_A1	0x3522
-
-/* Registers */
+#define SMI_CMD			0x00
+#define SMI_CMD_BUSY		BIT(15)
+#define SMI_CMD_CLAUSE_22	BIT(12)
+#define SMI_CMD_OP_22_WRITE	((1 << 10) | SMI_CMD_BUSY | SMI_CMD_CLAUSE_22)
+#define SMI_CMD_OP_22_READ	((2 << 10) | SMI_CMD_BUSY | SMI_CMD_CLAUSE_22)
+#define SMI_CMD_OP_45_WRITE_ADDR	((0 << 10) | SMI_CMD_BUSY)
+#define SMI_CMD_OP_45_WRITE_DATA	((1 << 10) | SMI_CMD_BUSY)
+#define SMI_CMD_OP_45_READ_DATA		((2 << 10) | SMI_CMD_BUSY)
+#define SMI_CMD_OP_45_READ_DATA_INC	((3 << 10) | SMI_CMD_BUSY)
+#define SMI_DATA		0x01
 
 #define REG_PORT(p)		(0x10 + (p))
-#define REG_GLOBAL		0x1b
-#define REG_GLOBAL2		0x1c
-
-/* ATU commands */
-
-#define ATU_BUSY			0x8000
-
-#define ATU_CMD_LOAD_FID		(ATU_BUSY | 0x3000)
-#define ATU_CMD_GETNEXT_FID		(ATU_BUSY | 0x4000)
-#define ATU_CMD_FLUSH_NONSTATIC_FID	(ATU_BUSY | 0x6000)
+#define PORT_STATUS		0x00
+#define PORT_STATUS_PAUSE_EN	BIT(15)
+#define PORT_STATUS_MY_PAUSE	BIT(14)
+#define PORT_STATUS_HD_FLOW	BIT(13)
+#define PORT_STATUS_PHY_DETECT	BIT(12)
+#define PORT_STATUS_LINK	BIT(11)
+#define PORT_STATUS_DUPLEX	BIT(10)
+#define PORT_STATUS_SPEED_MASK	0x0300
+#define PORT_STATUS_SPEED_10	0x0000
+#define PORT_STATUS_SPEED_100	0x0100
+#define PORT_STATUS_SPEED_1000	0x0200
+#define PORT_STATUS_EEE		BIT(6) /* 6352 */
+#define PORT_STATUS_AM_DIS	BIT(6) /* 6165 */
+#define PORT_STATUS_MGMII	BIT(6) /* 6185 */
+#define PORT_STATUS_TX_PAUSED	BIT(5)
+#define PORT_STATUS_FLOW_CTRL	BIT(4)
+#define PORT_PCS_CTRL		0x01
+#define PORT_SWITCH_ID		0x03
+#define PORT_SWITCH_ID_6085	0x04a0
+#define PORT_SWITCH_ID_6095	0x0950
+#define PORT_SWITCH_ID_6123	0x1210
+#define PORT_SWITCH_ID_6123_A1	0x1212
+#define PORT_SWITCH_ID_6123_A2	0x1213
+#define PORT_SWITCH_ID_6131	0x1060
+#define PORT_SWITCH_ID_6131_B2	0x1066
+#define PORT_SWITCH_ID_6152	0x1a40
+#define PORT_SWITCH_ID_6155	0x1a50
+#define PORT_SWITCH_ID_6161	0x1610
+#define PORT_SWITCH_ID_6161_A1	0x1612
+#define PORT_SWITCH_ID_6161_A2	0x1613
+#define PORT_SWITCH_ID_6165	0x1650
+#define PORT_SWITCH_ID_6165_A1	0x1652
+#define PORT_SWITCH_ID_6165_A2	0x1653
+#define PORT_SWITCH_ID_6171	0x1710
+#define PORT_SWITCH_ID_6172	0x1720
+#define PORT_SWITCH_ID_6176	0x1760
+#define PORT_SWITCH_ID_6182	0x1a60
+#define PORT_SWITCH_ID_6185	0x1a70
+#define PORT_SWITCH_ID_6352	0x3520
+#define PORT_SWITCH_ID_6352_A0	0x3521
+#define PORT_SWITCH_ID_6352_A1	0x3522
+#define PORT_CONTROL		0x04
+#define PORT_CONTROL_STATE_MASK		0x03
+#define PORT_CONTROL_STATE_DISABLED	0x00
+#define PORT_CONTROL_STATE_BLOCKING	0x01
+#define PORT_CONTROL_STATE_LEARNING	0x02
+#define PORT_CONTROL_STATE_FORWARDING	0x03
+#define PORT_CONTROL_1		0x05
+#define PORT_BASE_VLAN		0x06
+#define PORT_DEFAULT_VLAN	0x07
+#define PORT_CONTROL_2		0x08
+#define PORT_RATE_CONTROL	0x09
+#define PORT_RATE_CONTROL_2	0x0a
+#define PORT_ASSOC_VECTOR	0x0b
+#define PORT_IN_DISCARD_LO	0x10
+#define PORT_IN_DISCARD_HI	0x11
+#define PORT_IN_FILTERED	0x12
+#define PORT_OUT_FILTERED	0x13
+#define PORT_TAG_REGMAP_0123	0x19
+#define PORT_TAG_REGMAP_4567	0x1a
 
-/* port states */
-
-#define PSTATE_MASK		0x03
-#define PSTATE_DISABLED		0x00
-#define PSTATE_BLOCKING		0x01
-#define PSTATE_LEARNING		0x02
-#define PSTATE_FORWARDING	0x03
-
-/* FDB states */
-
-#define FDB_STATE_MASK			0x0f
+#define REG_GLOBAL		0x1b
+#define GLOBAL_STATUS		0x00
+#define GLOBAL_STATUS_PPU_STATE BIT(15) /* 6351 and 6171 */
+/* Two bits for 6165, 6185 etc */
+#define GLOBAL_STATUS_PPU_MASK		(0x3 << 14)
+#define GLOBAL_STATUS_PPU_DISABLED_RST	(0x0 << 14)
+#define GLOBAL_STATUS_PPU_INITIALIZING	(0x1 << 14)
+#define GLOBAL_STATUS_PPU_DISABLED	(0x2 << 14)
+#define GLOBAL_STATUS_PPU_POLLING	(0x3 << 14)
+#define GLOBAL_MAC_01		0x01
+#define GLOBAL_MAC_23		0x02
+#define GLOBAL_MAC_45		0x03
+#define GLOBAL_CONTROL		0x04
+#define GLOBAL_CONTROL_SW_RESET		BIT(15)
+#define GLOBAL_CONTROL_PPU_ENABLE	BIT(14)
+#define GLOBAL_CONTROL_DISCARD_EXCESS	BIT(13) /* 6352 */
+#define GLOBAL_CONTROL_SCHED_PRIO	BIT(11) /* 6152 */
+#define GLOBAL_CONTROL_MAX_FRAME_1632	BIT(10) /* 6152 */
+#define GLOBAL_CONTROL_RELOAD_EEPROM	BIT(9)  /* 6152 */
+#define GLOBAL_CONTROL_DEVICE_EN	BIT(7)
+#define GLOBAL_CONTROL_STATS_DONE_EN	BIT(6)
+#define GLOBAL_CONTROL_VTU_PROBLEM_EN	BIT(5)
+#define GLOBAL_CONTROL_VTU_DONE_EN	BIT(4)
+#define GLOBAL_CONTROL_ATU_PROBLEM_EN	BIT(3)
+#define GLOBAL_CONTROL_ATU_DONE_EN	BIT(2)
+#define GLOBAL_CONTROL_TCAM_EN		BIT(1)
+#define GLOBAL_CONTROL_EEPROM_DONE_EN	BIT(0)
+#define GLOBAL_VTU_OP		0x05
+#define GLOBAL_VTU_VID		0x06
+#define GLOBAL_VTU_DATA_0_3	0x07
+#define GLOBAL_VTU_DATA_4_7	0x08
+#define GLOBAL_VTU_DATA_8_11	0x09
+#define GLOBAL_ATU_CONTROL	0x0a
+#define GLOBAL_ATU_OP		0x0b
+#define GLOBAL_ATU_OP_BUSY	BIT(15)
+#define GLOBAL_ATU_OP_NOP		(0 << 12)
+#define GLOBAL_ATU_OP_FLUSH_ALL		((1 << 12) | GLOBAL_ATU_OP_BUSY)
+#define GLOBAL_ATU_OP_FLUSH_NON_STATIC	((2 << 12) | GLOBAL_ATU_OP_BUSY)
+#define GLOBAL_ATU_OP_LOAD_DB		((3 << 12) | GLOBAL_ATU_OP_BUSY)
+#define GLOBAL_ATU_OP_GET_NEXT_DB	((4 << 12) | GLOBAL_ATU_OP_BUSY)
+#define GLOBAL_ATU_OP_FLUSH_DB		((5 << 12) | GLOBAL_ATU_OP_BUSY)
+#define GLOBAL_ATU_OP_FLUSH_NON_STATIC_DB ((6 << 12) | GLOBAL_ATU_OP_BUSY)
+#define GLOBAL_ATU_OP_GET_CLR_VIOLATION	  ((7 << 12) | GLOBAL_ATU_OP_BUSY)
+#define GLOBAL_ATU_DATA		0x0c
+#define GLOBAL_ATU_DATA_STATE_MASK		0x0f
+#define GLOBAL_ATU_DATA_STATE_UNUSED		0x00
+#define GLOBAL_ATU_DATA_STATE_UC_MGMT		0x0d
+#define GLOBAL_ATU_DATA_STATE_UC_STATIC		0x0e
+#define GLOBAL_ATU_DATA_STATE_UC_PRIO_OVER	0x0f
+#define GLOBAL_ATU_DATA_STATE_MC_NONE_RATE	0x05
+#define GLOBAL_ATU_DATA_STATE_MC_STATIC		0x07
+#define GLOBAL_ATU_DATA_STATE_MC_MGMT		0x0e
+#define GLOBAL_ATU_DATA_STATE_MC_PRIO_OVER	0x0f
+#define GLOBAL_ATU_MAC_01	0x0d
+#define GLOBAL_ATU_MAC_23	0x0e
+#define GLOBAL_ATU_MAC_45	0x0f
+#define GLOBAL_IP_PRI_0		0x10
+#define GLOBAL_IP_PRI_1		0x11
+#define GLOBAL_IP_PRI_2		0x12
+#define GLOBAL_IP_PRI_3		0x13
+#define GLOBAL_IP_PRI_4		0x14
+#define GLOBAL_IP_PRI_5		0x15
+#define GLOBAL_IP_PRI_6		0x16
+#define GLOBAL_IP_PRI_7		0x17
+#define GLOBAL_IEEE_PRI		0x18
+#define GLOBAL_CORE_TAG_TYPE	0x19
+#define GLOBAL_MONITOR_CONTROL	0x1a
+#define GLOBAL_CONTROL_2	0x1c
+#define GLOBAL_STATS_OP		0x1d
+#define GLOBAL_STATS_OP_BUSY	BIT(15)
+#define GLOBAL_STATS_OP_NOP		(0 << 12)
+#define GLOBAL_STATS_OP_FLUSH_ALL	((1 << 12) | GLOBAL_STATS_OP_BUSY)
+#define GLOBAL_STATS_OP_FLUSH_PORT	((2 << 12) | GLOBAL_STATS_OP_BUSY)
+#define GLOBAL_STATS_OP_READ_CAPTURED	((4 << 12) | GLOBAL_STATS_OP_BUSY)
+#define GLOBAL_STATS_OP_CAPTURE_PORT	((5 << 12) | GLOBAL_STATS_OP_BUSY)
+#define GLOBAL_STATS_OP_HIST_RX		((1 << 10) | GLOBAL_STATS_OP_BUSY)
+#define GLOBAL_STATS_OP_HIST_TX		((2 << 10) | GLOBAL_STATS_OP_BUSY)
+#define GLOBAL_STATS_OP_HIST_RX_TX	((3 << 10) | GLOBAL_STATS_OP_BUSY)
+#define GLOBAL_STATS_COUNTER_32	0x1e
+#define GLOBAL_STATS_COUNTER_01	0x1f
 
-#define FDB_STATE_UNUSED		0x00
-#define FDB_STATE_MC_STATIC		0x07	/* static multicast */
-#define FDB_STATE_STATIC		0x0e	/* static unicast */
+#define REG_GLOBAL2		0x1c
+#define GLOBAL2_INT_SOURCE	0x00
+#define GLOBAL2_INT_MASK	0x01
+#define GLOBAL2_MGMT_EN_2X	0x02
+#define GLOBAL2_MGMT_EN_0X	0x03
+#define GLOBAL2_FLOW_CONTROL	0x04
+#define GLOBAL2_SWITCH_MGMT	0x05
+#define GLOBAL2_DEVICE_MAPPING	0x06
+#define GLOBAL2_TRUNK_MASK	0x07
+#define GLOBAL2_TRUNK_MAPPING	0x08
+#define GLOBAL2_INGRESS_OP	0x09
+#define GLOBAL2_INGRESS_DATA	0x0a
+#define GLOBAL2_PVT_ADDR	0x0b
+#define GLOBAL2_PVT_DATA	0x0c
+#define GLOBAL2_SWITCH_MAC	0x0d
+#define GLOBAL2_SWITCH_MAC_BUSY BIT(15)
+#define GLOBAL2_ATU_STATS	0x0e
+#define GLOBAL2_PRIO_OVERRIDE	0x0f
+#define GLOBAL2_EEPROM_OP	0x14
+#define GLOBAL2_EEPROM_OP_BUSY	BIT(15)
+#define GLOBAL2_EEPROM_OP_LOAD	BIT(11)
+#define GLOBAL2_EEPROM_DATA	0x15
+#define GLOBAL2_PTP_AVB_OP	0x16
+#define GLOBAL2_PTP_AVB_DATA	0x17
+#define GLOBAL2_SMI_OP		0x18
+#define GLOBAL2_SMI_OP_BUSY		BIT(15)
+#define GLOBAL2_SMI_OP_CLAUSE_22	BIT(12)
+#define GLOBAL2_SMI_OP_22_WRITE		((1 << 10) | GLOBAL2_SMI_OP_BUSY | \
+					 GLOBAL2_SMI_OP_CLAUSE_22)
+#define GLOBAL2_SMI_OP_22_READ		((2 << 10) | GLOBAL2_SMI_OP_BUSY | \
+					 GLOBAL2_SMI_OP_CLAUSE_22)
+#define GLOBAL2_SMI_OP_45_WRITE_ADDR	((0 << 10) | GLOBAL2_SMI_OP_BUSY)
+#define GLOBAL2_SMI_OP_45_WRITE_DATA	((1 << 10) | GLOBAL2_SMI_OP_BUSY)
+#define GLOBAL2_SMI_OP_45_READ_DATA	((2 << 10) | GLOBAL2_SMI_OP_BUSY)
+#define GLOBAL2_SMI_DATA	0x19
+#define GLOBAL2_SCRATCH_MISC	0x1a
+#define GLOBAL2_WDOG_CONTROL	0x1b
+#define GLOBAL2_QOS_WEIGHT	0x1c
+#define GLOBAL2_MISC		0x1d
 
 struct mv88e6xxx_priv_state {
 	/* When using multi-chip addressing, this mutex protects
-- 
2.1.4
