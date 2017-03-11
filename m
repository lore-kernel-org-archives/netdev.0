From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 01/17] net: dsa: mv88e6xxx: add port mask helper
Date: Sat, 11 Mar 2017 16:12:47 -0500
Message-ID: <20170311211303.24560-2-vivien.didelot@savoirfairelinux.com>
References: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a mv88e6xxx_port_mask() helper to get the bitmask of ports in a
switch chip, that will be used in several features.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 5 +++++
 drivers/net/dsa/mv88e6xxx/port.c      | 2 +-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 6033f2f6260a..166b513ff751 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -944,6 +944,11 @@ static inline unsigned int mv88e6xxx_num_ports(struct mv88e6xxx_chip *chip)
 	return chip->info->num_ports;
 }
 
+static inline u16 mv88e6xxx_port_mask(struct mv88e6xxx_chip *chip)
+{
+	return GENMASK(mv88e6xxx_num_ports(chip) - 1, 0);
+}
+
 int mv88e6xxx_read(struct mv88e6xxx_chip *chip, int addr, int reg, u16 *val);
 int mv88e6xxx_write(struct mv88e6xxx_chip *chip, int addr, int reg, u16 val);
 int mv88e6xxx_update(struct mv88e6xxx_chip *chip, int addr, int reg,
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 8875784c4718..9bb0f2134cba 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -539,7 +539,7 @@ int mv88e6351_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
 
 int mv88e6xxx_port_set_vlan_map(struct mv88e6xxx_chip *chip, int port, u16 map)
 {
-	const u16 mask = GENMASK(mv88e6xxx_num_ports(chip) - 1, 0);
+	const u16 mask = mv88e6xxx_port_mask(chip);
 	u16 reg;
 	int err;
 
-- 
2.12.0
