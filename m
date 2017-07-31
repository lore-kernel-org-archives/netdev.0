From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 07/11] net: dsa: mv88e6xxx: call phy_init_eee
Date: Mon, 31 Jul 2017 18:17:15 -0400
Message-ID: <20170731221719.16695-8-vivien.didelot@savoirfairelinux.com>
References: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is safer to init the EEE before the DSA layer call
phy_ethtool_set_eee, as sf2 and qca8k are doing.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 647d5d45c1d6..b531d4a3bab5 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -855,6 +855,12 @@ static int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
 
+	if (e->eee_enabled) {
+		err = phy_init_eee(phydev, 0);
+		if (err)
+			return err;
+	}
+
 	mutex_lock(&chip->reg_lock);
 	err = mv88e6xxx_energy_detect_write(chip, port, e);
 	mutex_unlock(&chip->reg_lock);
-- 
2.13.3
