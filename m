From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 6/6] net: dsa: use switchdev obj in port_fdb_del
Date: Wed,  7 Oct 2015 19:48:31 -0400
Message-ID: <1444261711-1829-7-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1444261711-1829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444261711-1829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For consistency with the FDB add operation, propagate the
switchdev_obj_port_fdb structure in the DSA drivers.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 4 ++--
 drivers/net/dsa/mv88e6xxx.h | 2 +-
 include/net/dsa.h           | 2 +-
 net/dsa/slave.c             | 2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 916c98e..f73c953 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1869,13 +1869,13 @@ int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 }
 
 int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
-			   const unsigned char *addr, u16 vid)
+			   const struct switchdev_obj_port_fdb *fdb)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_port_fdb_load(ds, port, addr, vid,
+	ret = _mv88e6xxx_port_fdb_load(ds, port, fdb->addr, fdb->vid,
 				       GLOBAL_ATU_DATA_STATE_UNUSED);
 	mutex_unlock(&ps->smi_mutex);
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index e688bee..1347a73 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -486,7 +486,7 @@ int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 			   const struct switchdev_obj_port_fdb *fdb,
 			   struct switchdev_trans *trans);
 int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
-			   const unsigned char *addr, u16 vid);
+			   const struct switchdev_obj_port_fdb *fdb);
 int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
 			       unsigned char *addr, u16 *vid, bool *is_static);
 int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg);
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 2d86d31..b802dab 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -324,7 +324,7 @@ struct dsa_switch_driver {
 				const struct switchdev_obj_port_fdb *fdb,
 				struct switchdev_trans *trans);
 	int	(*port_fdb_del)(struct dsa_switch *ds, int port,
-				const unsigned char *addr, u16 vid);
+				const struct switchdev_obj_port_fdb *fdb);
 	int	(*port_fdb_getnext)(struct dsa_switch *ds, int port,
 				    unsigned char *addr, u16 *vid,
 				    bool *is_static);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 6f7f27e..bb2bd3b 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -367,7 +367,7 @@ static int dsa_slave_port_fdb_del(struct net_device *dev,
 	int ret = -EOPNOTSUPP;
 
 	if (ds->drv->port_fdb_del)
-		ret = ds->drv->port_fdb_del(ds, p->port, fdb->addr, fdb->vid);
+		ret = ds->drv->port_fdb_del(ds, p->port, fdb);
 
 	return ret;
 }
-- 
2.6.0
