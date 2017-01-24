From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net-next v6 4/4] phy: marvell: Add support for the PHY embedded in the topaz switch
Date: Tue, 24 Jan 2017 21:10:26 +0100
Message-ID: <f8526f4a5d99223fc90fe5579b4958eaa0950a3a.1485288602.git-series.gregory.clement@free-electrons.com>
References: <cover.b0e18efe751186768e720c341693117fdd4d3c16.1485288602.git-series.gregory.clement@free-electrons.com>
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
        Jon Pannell <jpannell@marvell.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.b0e18efe751186768e720c341693117fdd4d3c16.1485288602.git-series.gregory.clement@free-electrons.com>
In-Reply-To: <cover.b0e18efe751186768e720c341693117fdd4d3c16.1485288602.git-series.gregory.clement@free-electrons.com>
References: <cover.b0e18efe751186768e720c341693117fdd4d3c16.1485288602.git-series.gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PHY with the ID 0x1410C00 can be found embedded in the Marvell Topaz
switches (88E6141/88E6341). It is compatible with the 88E1510 (at least for
the temperature information), so add support for it, using the 88E1510
specific functions.

Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/phy/marvell.c   | 21 +++++++++++++++++++++
 include/linux/marvell_phy.h |  1 +
 2 files changed, 22 insertions(+)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 64229976ace1..8b9338a746b8 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -2141,6 +2141,26 @@ static struct phy_driver marvell_drivers[] = {
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
 	},
+	{
+		.phy_id = MARVELL_PHY_ID_88E6141,
+		.phy_id_mask = MARVELL_PHY_ID_MASK,
+		.name = "Marvell 88E6141",
+		.probe = m88e1510_probe,
+		.remove = &marvell_remove,
+		.features = PHY_GBIT_FEATURES,
+		.flags = PHY_HAS_INTERRUPT,
+		.config_init = &marvell_config_init,
+		.config_aneg = &m88e1510_config_aneg,
+		.read_status = &marvell_read_status,
+		.ack_interrupt = &marvell_ack_interrupt,
+		.config_intr = &marvell_config_intr,
+		.did_interrupt = &m88e1121_did_interrupt,
+		.resume = &genphy_resume,
+		.suspend = &genphy_suspend,
+		.get_sset_count = marvell_get_sset_count,
+		.get_strings = marvell_get_strings,
+		.get_stats = marvell_get_stats,
+	},
 };
 
 module_phy_driver(marvell_drivers);
@@ -2159,6 +2179,7 @@ static struct mdio_device_id __maybe_unused marvell_tbl[] = {
 	{ MARVELL_PHY_ID_88E1510, MARVELL_PHY_ID_MASK },
 	{ MARVELL_PHY_ID_88E1540, MARVELL_PHY_ID_MASK },
 	{ MARVELL_PHY_ID_88E3016, MARVELL_PHY_ID_MASK },
+	{ MARVELL_PHY_ID_88E6141, MARVELL_PHY_ID_MASK },
 	{ }
 };
 
diff --git a/include/linux/marvell_phy.h b/include/linux/marvell_phy.h
index a57f0dfb6db7..6f33b73f2044 100644
--- a/include/linux/marvell_phy.h
+++ b/include/linux/marvell_phy.h
@@ -5,6 +5,7 @@
 #define MARVELL_PHY_ID_MASK		0xfffffff0
 
 /* Known PHY IDs */
+#define MARVELL_PHY_ID_88E6141		0x01410c00
 #define MARVELL_PHY_ID_88E1101		0x01410c60
 #define MARVELL_PHY_ID_88E1112		0x01410c90
 #define MARVELL_PHY_ID_88E1111		0x01410cc0
-- 
git-series 0.9.1
