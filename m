From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 5/5] net: dsa: remove .set_addr
Date: Fri, 13 Oct 2017 14:18:09 -0400
Message-ID: <20171013181809.14627-6-vivien.didelot@savoirfairelinux.com>
References: <20171013181809.14627-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        David Laight <David.Laight@ACULAB.COM>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171013181809.14627-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that there is no user for the .set_addr function, remove it from
DSA. If a switch supports this feature (like mv88e6xxx), the
implementation can be done in the driver setup.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h | 1 -
 net/dsa/dsa2.c    | 6 ------
 net/dsa/legacy.c  | 6 ------
 3 files changed, 13 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index ce1d622734d7..2746741f74cf 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -291,7 +291,6 @@ struct dsa_switch_ops {
 	enum dsa_tag_protocol (*get_tag_protocol)(struct dsa_switch *ds);
 
 	int	(*setup)(struct dsa_switch *ds);
-	int	(*set_addr)(struct dsa_switch *ds, u8 *addr);
 	u32	(*get_phy_flags)(struct dsa_switch *ds, int port);
 
 	/*
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 54ed054777bd..6ac9e11d385c 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -336,12 +336,6 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 	if (err)
 		return err;
 
-	if (ds->ops->set_addr) {
-		err = ds->ops->set_addr(ds, dst->cpu_dp->netdev->dev_addr);
-		if (err < 0)
-			return err;
-	}
-
 	if (!ds->slave_mii_bus && ds->ops->phy_read) {
 		ds->slave_mii_bus = devm_mdiobus_alloc(ds->dev);
 		if (!ds->slave_mii_bus)
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index 19ff6e0a21dc..b0fefbffe082 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -172,12 +172,6 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 	if (ret)
 		return ret;
 
-	if (ops->set_addr) {
-		ret = ops->set_addr(ds, master->dev_addr);
-		if (ret < 0)
-			return ret;
-	}
-
 	if (!ds->slave_mii_bus && ops->phy_read) {
 		ds->slave_mii_bus = devm_mdiobus_alloc(ds->dev);
 		if (!ds->slave_mii_bus)
-- 
2.14.2
