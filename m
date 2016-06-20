From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v5 net-next v5 07/14] net: dsa: mv88e6xxx: remove table args in info lookup
Date: Mon, 20 Jun 2016 13:14:04 -0400
Message-ID: <20160620171411.13746-8-vivien.didelot@savoirfairelinux.com>
References: <20160620171411.13746-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160620171411.13746-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The mv88e6xxx_table array and the mv88e6xxx_lookup_info function are
static, so remove the table and size arguments from the lookup function.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index ec28465..75e5408 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3590,15 +3590,13 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	},
 };
 
-static const struct mv88e6xxx_info *
-mv88e6xxx_lookup_info(unsigned int prod_num, const struct mv88e6xxx_info *table,
-		      unsigned int num)
+static const struct mv88e6xxx_info *mv88e6xxx_lookup_info(unsigned int prod_num)
 {
 	int i;
 
-	for (i = 0; i < num; ++i)
-		if (table[i].prod_num == prod_num)
-			return &table[i];
+	for (i = 0; i < ARRAY_SIZE(mv88e6xxx_table); ++i)
+		if (mv88e6xxx_table[i].prod_num == prod_num)
+			return &mv88e6xxx_table[i];
 
 	return NULL;
 }
@@ -3625,8 +3623,7 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 	prod_num = (id & 0xfff0) >> 4;
 	rev = id & 0x000f;
 
-	info = mv88e6xxx_lookup_info(prod_num, mv88e6xxx_table,
-				     ARRAY_SIZE(mv88e6xxx_table));
+	info = mv88e6xxx_lookup_info(prod_num);
 	if (!info)
 		return NULL;
 
@@ -3739,8 +3736,7 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	prod_num = (id & 0xfff0) >> 4;
 	rev = id & 0x000f;
 
-	ps->info = mv88e6xxx_lookup_info(prod_num, mv88e6xxx_table,
-					 ARRAY_SIZE(mv88e6xxx_table));
+	ps->info = mv88e6xxx_lookup_info(prod_num);
 	if (!ps->info)
 		return -ENODEV;
 
-- 
2.9.0
