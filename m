From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2 net-next v2 12/12] net: dsa: mv88e6xxx: add support for DSA ageing time
Date: Mon, 18 Jul 2016 14:46:28 -0400
Message-ID: <20160718184628.13103-13-vivien.didelot@savoirfairelinux.com>
References: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement the DSA driver function to configure the bridge ageing time.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index e2627a8..2101241 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3002,6 +3002,19 @@ static int mv88e6xxx_g1_set_age_time(struct mv88e6xxx_chip *chip,
 	return mv88e6xxx_write(chip, REG_GLOBAL, GLOBAL_ATU_CONTROL, val);
 }
 
+static int mv88e6xxx_set_ageing_time(struct dsa_switch *ds,
+				     unsigned int ageing_time)
+{
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	int err;
+
+	mutex_lock(&chip->reg_lock);
+	err = mv88e6xxx_g1_set_age_time(chip, ageing_time);
+	mutex_unlock(&chip->reg_lock);
+
+	return err;
+}
+
 static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 {
 	struct dsa_switch *ds = chip->ds;
@@ -3985,6 +3998,7 @@ static struct dsa_switch_driver mv88e6xxx_switch_driver = {
 	.set_eeprom		= mv88e6xxx_set_eeprom,
 	.get_regs_len		= mv88e6xxx_get_regs_len,
 	.get_regs		= mv88e6xxx_get_regs,
+	.set_ageing_time	= mv88e6xxx_set_ageing_time,
 	.port_bridge_join	= mv88e6xxx_port_bridge_join,
 	.port_bridge_leave	= mv88e6xxx_port_bridge_leave,
 	.port_stp_state_set	= mv88e6xxx_port_stp_state_set,
-- 
2.9.0
