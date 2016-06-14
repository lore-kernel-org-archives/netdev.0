From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2 net-next v2 07/12] net: dsa: mv88e6xxx: put chip info in ID table
Date: Tue, 14 Jun 2016 14:31:48 -0400
Message-ID: <20160614183153.32327-8-vivien.didelot@savoirfairelinux.com>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the chip info structure as the data of the compatible of device,
which will be used later by probe code.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 6f43280..8c39dd0 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3607,6 +3607,16 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 };
 
+static const struct of_device_id mv88e6xxx_of_id_table[] = {
+	{
+		.compatible = "marvell,mv88e6085",
+		.data = &mv88e6xxx_table[MV88E6085],
+	},
+	{ /* sentinel */ },
+};
+
+MODULE_DEVICE_TABLE(of, mv88e6xxx_of_id_table);
+
 static const struct mv88e6xxx_info *
 mv88e6xxx_lookup_info(unsigned int prod_num, const struct mv88e6xxx_info *table,
 		      unsigned int num)
@@ -3801,19 +3811,12 @@ static void mv88e6xxx_remove(struct mdio_device *mdiodev)
 	mv88e6xxx_mdio_unregister(ps);
 }
 
-static const struct of_device_id mv88e6xxx_of_match[] = {
-	{ .compatible = "marvell,mv88e6085" },
-	{ /* sentinel */ },
-};
-
-MODULE_DEVICE_TABLE(of, mv88e6xxx_of_match);
-
 static struct mdio_driver mv88e6xxx_driver = {
 	.probe	= mv88e6xxx_probe,
 	.remove = mv88e6xxx_remove,
 	.mdiodrv.driver = {
-		.name = "mv88e6085",
-		.of_match_table = mv88e6xxx_of_match,
+		.name = "mv88e6xxx",
+		.of_match_table = mv88e6xxx_of_id_table,
 	},
 };
 
-- 
2.8.3
