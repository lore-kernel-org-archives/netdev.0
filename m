From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net-next v7 1/3] net: dsa: mv88e6xxx: Don't forbid MDIO I/Os for PHY addr >= num_of_ports
Date: Mon, 30 Jan 2017 20:29:33 +0100
Message-ID: <f5a836a49991168a2ed2be4527303b39cf33925f.1485804488.git-series.gregory.clement@free-electrons.com>
References: <cover.69cbc1ba8937d0fc442538f992d62fc88aa26dcc.1485804488.git-series.gregory.clement@free-electrons.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Nadav Haklai <nadavh@marvell.com>,
        Wilson Ding <dingwei@marvell.com>,
        Kostya Porotchkin <kostap@marvell.com>,
        Joe Zhou <shjzhou@marvell.com>,
        Jon Pannell <jpannell@marvell.com>,
        Bob Bernstein <robertb@marvell.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.69cbc1ba8937d0fc442538f992d62fc88aa26dcc.1485804488.git-series.gregory.clement@free-electrons.com>
In-Reply-To: <cover.69cbc1ba8937d0fc442538f992d62fc88aa26dcc.1485804488.git-series.gregory.clement@free-electrons.com>
References: <cover.69cbc1ba8937d0fc442538f992d62fc88aa26dcc.1485804488.git-series.gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Romain Perier <romain.perier@free-electrons.com>

Some Marvell ethernet switches have internal ethernet transceivers with
hardcoded phy addresses. These addresses can be greater than the number
of ports or its value might be different than the associated port number.
This is for example the case for MV88E6341 that has 6 ports and internal
Port 1 to Port4 PHYs mapped at SMI addresses from 0x11 to 0x14.

This commits fixes the issue by removing the condition in MDIO callbacks.

Signed-off-by: Romain Perier <romain.perier@free-electrons.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 84cba32443de..1344dad21f46 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2917,9 +2917,6 @@ static int mv88e6xxx_mdio_read(struct mii_bus *bus, int phy, int reg)
 	u16 val;
 	int err;
 
-	if (phy >= mv88e6xxx_num_ports(chip))
-		return 0xffff;
-
 	if (!chip->info->ops->phy_read)
 		return -EOPNOTSUPP;
 
@@ -2936,9 +2933,6 @@ static int mv88e6xxx_mdio_write(struct mii_bus *bus, int phy, int reg, u16 val)
 	struct mv88e6xxx_chip *chip = mdio_bus->chip;
 	int err;
 
-	if (phy >= mv88e6xxx_num_ports(chip))
-		return 0xffff;
-
 	if (!chip->info->ops->phy_write)
 		return -EOPNOTSUPP;
 
-- 
git-series 0.9.1
