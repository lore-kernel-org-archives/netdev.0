From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/3] net: dsa: use switchdev_obj_dump_cb_t everywhere
Date: Wed, 17 May 2017 15:46:05 -0400
Message-ID: <20170517194605.31639-4-vivien.didelot@savoirfairelinux.com>
References: <20170517194605.31639-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170517194605.31639-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that the DSA public header includes switchdev.h, use the provided
switchdev_obj_dump_cb_t typedef for the object dump callback.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/b53/b53_common.c |  6 +++---
 drivers/net/dsa/b53/b53_priv.h   |  4 ++--
 drivers/net/dsa/dsa_loop.c       |  2 +-
 drivers/net/dsa/mt7530.c         |  2 +-
 drivers/net/dsa/mv88e6xxx/chip.c | 10 +++++-----
 drivers/net/dsa/qca8k.c          |  2 +-
 include/net/dsa.h                |  6 +++---
 7 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index fbc3eb17c7a3..fa099ed41652 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1055,7 +1055,7 @@ EXPORT_SYMBOL(b53_vlan_del);
 
 int b53_vlan_dump(struct dsa_switch *ds, int port,
 		  struct switchdev_obj_port_vlan *vlan,
-		  int (*cb)(struct switchdev_obj *obj))
+		  switchdev_obj_dump_cb_t *cb)
 {
 	struct b53_device *dev = ds->priv;
 	u16 vid, vid_start = 0, pvid;
@@ -1284,7 +1284,7 @@ static void b53_arl_search_rd(struct b53_device *dev, u8 idx,
 static int b53_fdb_copy(struct net_device *dev, int port,
 			const struct b53_arl_entry *ent,
 			struct switchdev_obj_port_fdb *fdb,
-			int (*cb)(struct switchdev_obj *obj))
+			switchdev_obj_dump_cb_t *cb)
 {
 	if (!ent->is_valid)
 		return 0;
@@ -1301,7 +1301,7 @@ static int b53_fdb_copy(struct net_device *dev, int port,
 
 int b53_fdb_dump(struct dsa_switch *ds, int port,
 		 struct switchdev_obj_port_fdb *fdb,
-		 int (*cb)(struct switchdev_obj *obj))
+		 switchdev_obj_dump_cb_t *cb)
 {
 	struct b53_device *priv = ds->priv;
 	struct net_device *dev = ds->ports[port].netdev;
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index a9dc90a01438..155a9c48c317 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -395,7 +395,7 @@ int b53_vlan_del(struct dsa_switch *ds, int port,
 		 const struct switchdev_obj_port_vlan *vlan);
 int b53_vlan_dump(struct dsa_switch *ds, int port,
 		  struct switchdev_obj_port_vlan *vlan,
-		  int (*cb)(struct switchdev_obj *obj));
+		  switchdev_obj_dump_cb_t *cb);
 int b53_fdb_prepare(struct dsa_switch *ds, int port,
 		    const struct switchdev_obj_port_fdb *fdb,
 		    struct switchdev_trans *trans);
@@ -406,7 +406,7 @@ int b53_fdb_del(struct dsa_switch *ds, int port,
 		const struct switchdev_obj_port_fdb *fdb);
 int b53_fdb_dump(struct dsa_switch *ds, int port,
 		 struct switchdev_obj_port_fdb *fdb,
-		 int (*cb)(struct switchdev_obj *obj));
+		 switchdev_obj_dump_cb_t *cb);
 int b53_mirror_add(struct dsa_switch *ds, int port,
 		   struct dsa_mall_mirror_tc_entry *mirror, bool ingress);
 void b53_mirror_del(struct dsa_switch *ds, int port,
diff --git a/drivers/net/dsa/dsa_loop.c b/drivers/net/dsa/dsa_loop.c
index 6afab16d13dd..5edf07beb9d2 100644
--- a/drivers/net/dsa/dsa_loop.c
+++ b/drivers/net/dsa/dsa_loop.c
@@ -187,7 +187,7 @@ static int dsa_loop_port_vlan_del(struct dsa_switch *ds, int port,
 
 static int dsa_loop_port_vlan_dump(struct dsa_switch *ds, int port,
 				   struct switchdev_obj_port_vlan *vlan,
-				   int (*cb)(struct switchdev_obj *obj))
+				   switchdev_obj_dump_cb_t *cb)
 {
 	struct dsa_loop_priv *ps = ds->priv;
 	struct mii_bus *bus = ps->bus;
diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index 1bcbe15870ed..4d2f45153ede 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -853,7 +853,7 @@ mt7530_port_fdb_del(struct dsa_switch *ds, int port,
 static int
 mt7530_port_fdb_dump(struct dsa_switch *ds, int port,
 		     struct switchdev_obj_port_fdb *fdb,
-		     int (*cb)(struct switchdev_obj *obj))
+		     switchdev_obj_dump_cb_t *cb)
 {
 	struct mt7530_priv *priv = ds->priv;
 	struct mt7530_fdb _fdb = { 0 };
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 386d878569ed..41de250dbcc3 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1268,7 +1268,7 @@ static int mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 
 static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 				    struct switchdev_obj_port_vlan *vlan,
-				    int (*cb)(struct switchdev_obj *obj))
+				    switchdev_obj_dump_cb_t *cb)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
 	struct mv88e6xxx_vtu_entry next = {
@@ -1699,7 +1699,7 @@ static int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 static int mv88e6xxx_port_db_dump_fid(struct mv88e6xxx_chip *chip,
 				      u16 fid, u16 vid, int port,
 				      struct switchdev_obj *obj,
-				      int (*cb)(struct switchdev_obj *obj))
+				      switchdev_obj_dump_cb_t *cb)
 {
 	struct mv88e6xxx_atu_entry addr;
 	int err;
@@ -1754,7 +1754,7 @@ static int mv88e6xxx_port_db_dump_fid(struct mv88e6xxx_chip *chip,
 
 static int mv88e6xxx_port_db_dump(struct mv88e6xxx_chip *chip, int port,
 				  struct switchdev_obj *obj,
-				  int (*cb)(struct switchdev_obj *obj))
+				  switchdev_obj_dump_cb_t *cb)
 {
 	struct mv88e6xxx_vtu_entry vlan = {
 		.vid = chip->info->max_vid,
@@ -1791,7 +1791,7 @@ static int mv88e6xxx_port_db_dump(struct mv88e6xxx_chip *chip, int port,
 
 static int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
 				   struct switchdev_obj_port_fdb *fdb,
-				   int (*cb)(struct switchdev_obj *obj))
+				   switchdev_obj_dump_cb_t *cb)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
@@ -4037,7 +4037,7 @@ static int mv88e6xxx_port_mdb_del(struct dsa_switch *ds, int port,
 
 static int mv88e6xxx_port_mdb_dump(struct dsa_switch *ds, int port,
 				   struct switchdev_obj_port_mdb *mdb,
-				   int (*cb)(struct switchdev_obj *obj))
+				   switchdev_obj_dump_cb_t *cb)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index 149f109dbffb..0f6a011d8ed1 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -872,7 +872,7 @@ qca8k_port_fdb_del(struct dsa_switch *ds, int port,
 static int
 qca8k_port_fdb_dump(struct dsa_switch *ds, int port,
 		    struct switchdev_obj_port_fdb *fdb,
-		    int (*cb)(struct switchdev_obj *obj))
+		    switchdev_obj_dump_cb_t *cb)
 {
 	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
 	struct qca8k_fdb _fdb = { 0 };
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 61984895a9ad..beb69a6e705f 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -404,7 +404,7 @@ struct dsa_switch_ops {
 				 const struct switchdev_obj_port_vlan *vlan);
 	int	(*port_vlan_dump)(struct dsa_switch *ds, int port,
 				  struct switchdev_obj_port_vlan *vlan,
-				  int (*cb)(struct switchdev_obj *obj));
+				  switchdev_obj_dump_cb_t *cb);
 
 	/*
 	 * Forwarding database
@@ -419,7 +419,7 @@ struct dsa_switch_ops {
 				const struct switchdev_obj_port_fdb *fdb);
 	int	(*port_fdb_dump)(struct dsa_switch *ds, int port,
 				 struct switchdev_obj_port_fdb *fdb,
-				 int (*cb)(struct switchdev_obj *obj));
+				  switchdev_obj_dump_cb_t *cb);
 
 	/*
 	 * Multicast database
@@ -434,7 +434,7 @@ struct dsa_switch_ops {
 				const struct switchdev_obj_port_mdb *mdb);
 	int	(*port_mdb_dump)(struct dsa_switch *ds, int port,
 				 struct switchdev_obj_port_mdb *mdb,
-				 int (*cb)(struct switchdev_obj *obj));
+				  switchdev_obj_dump_cb_t *cb);
 
 	/*
 	 * RXNFC
-- 
2.13.0
