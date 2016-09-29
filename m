From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 07/10] net: dsa: mv88e6xxx: rename mv88e6xxx_ops
Date: Thu, 29 Sep 2016 12:21:59 -0400
Message-ID: <20160929162202.10685-8-vivien.didelot@savoirfairelinux.com>
References: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48781 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755602AbcI2QW2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 12:22:28 -0400
In-Reply-To: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6xxx_ops is used to describe how to access the chip registers.
It can be through SMI (via an MDIO bus), or via another interface such
as crafted remote management frames.

The correct BUS operations structure is chosen at runtime, depending on
the chip address and connectivity.

We will need the mv88e6xxx_ops name for future chip-wide operation
structure, thus rename mv88e6xxx_ops to more explicit mv88e6xxx_bus_ops.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 10 +++++-----
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  8 ++++----
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index d805661..ad31d3e 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -98,7 +98,7 @@ static int mv88e6xxx_smi_single_chip_write(struct mv88e6xxx_chip *chip,
 	return 0;
 }
 
-static const struct mv88e6xxx_ops mv88e6xxx_smi_single_chip_ops = {
+static const struct mv88e6xxx_bus_ops mv88e6xxx_smi_single_chip_ops = {
 	.read = mv88e6xxx_smi_single_chip_read,
 	.write = mv88e6xxx_smi_single_chip_write,
 };
@@ -180,7 +180,7 @@ static int mv88e6xxx_smi_multi_chip_write(struct mv88e6xxx_chip *chip,
 	return 0;
 }
 
-static const struct mv88e6xxx_ops mv88e6xxx_smi_multi_chip_ops = {
+static const struct mv88e6xxx_bus_ops mv88e6xxx_smi_multi_chip_ops = {
 	.read = mv88e6xxx_smi_multi_chip_read,
 	.write = mv88e6xxx_smi_multi_chip_write,
 };
@@ -515,7 +515,7 @@ static int mv88e6xxx_phy_ppu_write(struct mv88e6xxx_chip *chip, int addr,
 	return err;
 }
 
-static const struct mv88e6xxx_ops mv88e6xxx_phy_ppu_ops = {
+static const struct mv88e6xxx_bus_ops mv88e6xxx_phy_ppu_ops = {
 	.read = mv88e6xxx_phy_ppu_read,
 	.write = mv88e6xxx_phy_ppu_write,
 };
@@ -3479,12 +3479,12 @@ static struct mv88e6xxx_chip *mv88e6xxx_alloc_chip(struct device *dev)
 	return chip;
 }
 
-static const struct mv88e6xxx_ops mv88e6xxx_g2_smi_phy_ops = {
+static const struct mv88e6xxx_bus_ops mv88e6xxx_g2_smi_phy_ops = {
 	.read = mv88e6xxx_g2_smi_phy_read,
 	.write = mv88e6xxx_g2_smi_phy_write,
 };
 
-static const struct mv88e6xxx_ops mv88e6xxx_phy_ops = {
+static const struct mv88e6xxx_bus_ops mv88e6xxx_phy_ops = {
 	.read = mv88e6xxx_read,
 	.write = mv88e6xxx_write,
 };
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index ee7873a..b9ef769 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -648,7 +648,7 @@ struct mv88e6xxx_vtu_entry {
 	u8	data[DSA_MAX_PORTS];
 };
 
-struct mv88e6xxx_ops;
+struct mv88e6xxx_bus_ops;
 
 struct mv88e6xxx_priv_port {
 	struct net_device *bridge_dev;
@@ -669,14 +669,14 @@ struct mv88e6xxx_chip {
 	/* The MII bus and the address on the bus that is used to
 	 * communication with the switch
 	 */
-	const struct mv88e6xxx_ops *smi_ops;
+	const struct mv88e6xxx_bus_ops *smi_ops;
 	struct mii_bus *bus;
 	int sw_addr;
 
 	/* Handles automatic disabling and re-enabling of the PHY
 	 * polling unit.
 	 */
-	const struct mv88e6xxx_ops *phy_ops;
+	const struct mv88e6xxx_bus_ops *phy_ops;
 	struct mutex		ppu_mutex;
 	int			ppu_disabled;
 	struct work_struct	ppu_work;
@@ -705,7 +705,7 @@ struct mv88e6xxx_chip {
 	struct mii_bus *mdio_bus;
 };
 
-struct mv88e6xxx_ops {
+struct mv88e6xxx_bus_ops {
 	int (*read)(struct mv88e6xxx_chip *chip, int addr, int reg, u16 *val);
 	int (*write)(struct mv88e6xxx_chip *chip, int addr, int reg, u16 val);
 };
-- 
2.10.0
