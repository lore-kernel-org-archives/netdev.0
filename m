From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/4] net: dsa: b53: Export most operations to other drivers
Date: Sun,  8 Jan 2017 14:52:05 -0800
Message-ID: <20170108225208.15431-2-f.fainelli@gmail.com>
References: <20170108225208.15431-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36315 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751928AbdAHW6t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 17:58:49 -0500
Received: by mail-pg0-f66.google.com with SMTP id 75so11597467pgf.3
        for <netdev@vger.kernel.org>; Sun, 08 Jan 2017 14:58:49 -0800 (PST)
In-Reply-To: <20170108225208.15431-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for making dsa_switch_ops const, export b53 operations
utilized by other drivers such as bcm_sf2.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 79 +++++++++++++++++++++++-----------------
 drivers/net/dsa/b53/b53_priv.h   | 33 +++++++++++++++++
 2 files changed, 79 insertions(+), 33 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index d5370c227043..a448661b55c6 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -712,7 +712,7 @@ static unsigned int b53_get_mib_size(struct b53_device *dev)
 		return B53_MIBS_SIZE;
 }
 
-static void b53_get_strings(struct dsa_switch *ds, int port, uint8_t *data)
+void b53_get_strings(struct dsa_switch *ds, int port, uint8_t *data)
 {
 	struct b53_device *dev = ds->priv;
 	const struct b53_mib_desc *mibs = b53_get_mib(dev);
@@ -723,9 +723,9 @@ static void b53_get_strings(struct dsa_switch *ds, int port, uint8_t *data)
 		memcpy(data + i * ETH_GSTRING_LEN,
 		       mibs[i].name, ETH_GSTRING_LEN);
 }
+EXPORT_SYMBOL(b53_get_strings);
 
-static void b53_get_ethtool_stats(struct dsa_switch *ds, int port,
-				  uint64_t *data)
+void b53_get_ethtool_stats(struct dsa_switch *ds, int port, uint64_t *data)
 {
 	struct b53_device *dev = ds->priv;
 	const struct b53_mib_desc *mibs = b53_get_mib(dev);
@@ -756,13 +756,15 @@ static void b53_get_ethtool_stats(struct dsa_switch *ds, int port,
 
 	mutex_unlock(&dev->stats_mutex);
 }
+EXPORT_SYMBOL(b53_get_ethtool_stats);
 
-static int b53_get_sset_count(struct dsa_switch *ds)
+int b53_get_sset_count(struct dsa_switch *ds)
 {
 	struct b53_device *dev = ds->priv;
 
 	return b53_get_mib_size(dev);
 }
+EXPORT_SYMBOL(b53_get_sset_count);
 
 static int b53_setup(struct dsa_switch *ds)
 {
@@ -921,15 +923,15 @@ static void b53_adjust_link(struct dsa_switch *ds, int port,
 	}
 }
 
-static int b53_vlan_filtering(struct dsa_switch *ds, int port,
-			      bool vlan_filtering)
+int b53_vlan_filtering(struct dsa_switch *ds, int port, bool vlan_filtering)
 {
 	return 0;
 }
+EXPORT_SYMBOL(b53_vlan_filtering);
 
-static int b53_vlan_prepare(struct dsa_switch *ds, int port,
-			    const struct switchdev_obj_port_vlan *vlan,
-			    struct switchdev_trans *trans)
+int b53_vlan_prepare(struct dsa_switch *ds, int port,
+		     const struct switchdev_obj_port_vlan *vlan,
+		     struct switchdev_trans *trans)
 {
 	struct b53_device *dev = ds->priv;
 
@@ -943,10 +945,11 @@ static int b53_vlan_prepare(struct dsa_switch *ds, int port,
 
 	return 0;
 }
+EXPORT_SYMBOL(b53_vlan_prepare);
 
-static void b53_vlan_add(struct dsa_switch *ds, int port,
-			 const struct switchdev_obj_port_vlan *vlan,
-			 struct switchdev_trans *trans)
+void b53_vlan_add(struct dsa_switch *ds, int port,
+		  const struct switchdev_obj_port_vlan *vlan,
+		  struct switchdev_trans *trans)
 {
 	struct b53_device *dev = ds->priv;
 	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
@@ -977,9 +980,10 @@ static void b53_vlan_add(struct dsa_switch *ds, int port,
 		b53_fast_age_vlan(dev, vid);
 	}
 }
+EXPORT_SYMBOL(b53_vlan_add);
 
-static int b53_vlan_del(struct dsa_switch *ds, int port,
-			const struct switchdev_obj_port_vlan *vlan)
+int b53_vlan_del(struct dsa_switch *ds, int port,
+		 const struct switchdev_obj_port_vlan *vlan)
 {
 	struct b53_device *dev = ds->priv;
 	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
@@ -1015,10 +1019,11 @@ static int b53_vlan_del(struct dsa_switch *ds, int port,
 
 	return 0;
 }
+EXPORT_SYMBOL(b53_vlan_del);
 
-static int b53_vlan_dump(struct dsa_switch *ds, int port,
-			 struct switchdev_obj_port_vlan *vlan,
-			 int (*cb)(struct switchdev_obj *obj))
+int b53_vlan_dump(struct dsa_switch *ds, int port,
+		  struct switchdev_obj_port_vlan *vlan,
+		  int (*cb)(struct switchdev_obj *obj))
 {
 	struct b53_device *dev = ds->priv;
 	u16 vid, vid_start = 0, pvid;
@@ -1057,6 +1062,7 @@ static int b53_vlan_dump(struct dsa_switch *ds, int port,
 
 	return err;
 }
+EXPORT_SYMBOL(b53_vlan_dump);
 
 /* Address Resolution Logic routines */
 static int b53_arl_op_wait(struct b53_device *dev)
@@ -1175,9 +1181,9 @@ static int b53_arl_op(struct b53_device *dev, int op, int port,
 	return b53_arl_rw_op(dev, 0);
 }
 
-static int b53_fdb_prepare(struct dsa_switch *ds, int port,
-			   const struct switchdev_obj_port_fdb *fdb,
-			   struct switchdev_trans *trans)
+int b53_fdb_prepare(struct dsa_switch *ds, int port,
+		    const struct switchdev_obj_port_fdb *fdb,
+		    struct switchdev_trans *trans)
 {
 	struct b53_device *priv = ds->priv;
 
@@ -1189,24 +1195,27 @@ static int b53_fdb_prepare(struct dsa_switch *ds, int port,
 
 	return 0;
 }
+EXPORT_SYMBOL(b53_fdb_prepare);
 
-static void b53_fdb_add(struct dsa_switch *ds, int port,
-			const struct switchdev_obj_port_fdb *fdb,
-			struct switchdev_trans *trans)
+void b53_fdb_add(struct dsa_switch *ds, int port,
+		 const struct switchdev_obj_port_fdb *fdb,
+		 struct switchdev_trans *trans)
 {
 	struct b53_device *priv = ds->priv;
 
 	if (b53_arl_op(priv, 0, port, fdb->addr, fdb->vid, true))
 		pr_err("%s: failed to add MAC address\n", __func__);
 }
+EXPORT_SYMBOL(b53_fdb_add);
 
-static int b53_fdb_del(struct dsa_switch *ds, int port,
-		       const struct switchdev_obj_port_fdb *fdb)
+int b53_fdb_del(struct dsa_switch *ds, int port,
+		const struct switchdev_obj_port_fdb *fdb)
 {
 	struct b53_device *priv = ds->priv;
 
 	return b53_arl_op(priv, 0, port, fdb->addr, fdb->vid, false);
 }
+EXPORT_SYMBOL(b53_fdb_del);
 
 static int b53_arl_search_wait(struct b53_device *dev)
 {
@@ -1258,9 +1267,9 @@ static int b53_fdb_copy(struct net_device *dev, int port,
 	return cb(&fdb->obj);
 }
 
-static int b53_fdb_dump(struct dsa_switch *ds, int port,
-			struct switchdev_obj_port_fdb *fdb,
-			int (*cb)(struct switchdev_obj *obj))
+int b53_fdb_dump(struct dsa_switch *ds, int port,
+		 struct switchdev_obj_port_fdb *fdb,
+		 int (*cb)(struct switchdev_obj *obj))
 {
 	struct b53_device *priv = ds->priv;
 	struct net_device *dev = ds->ports[port].netdev;
@@ -1297,9 +1306,9 @@ static int b53_fdb_dump(struct dsa_switch *ds, int port,
 
 	return 0;
 }
+EXPORT_SYMBOL(b53_fdb_dump);
 
-static int b53_br_join(struct dsa_switch *ds, int port,
-		       struct net_device *bridge)
+int b53_br_join(struct dsa_switch *ds, int port, struct net_device *bridge)
 {
 	struct b53_device *dev = ds->priv;
 	s8 cpu_port = ds->dst->cpu_port;
@@ -1343,8 +1352,9 @@ static int b53_br_join(struct dsa_switch *ds, int port,
 
 	return 0;
 }
+EXPORT_SYMBOL(b53_br_join);
 
-static void b53_br_leave(struct dsa_switch *ds, int port)
+void b53_br_leave(struct dsa_switch *ds, int port)
 {
 	struct b53_device *dev = ds->priv;
 	struct net_device *bridge = dev->ports[port].bridge_dev;
@@ -1393,8 +1403,9 @@ static void b53_br_leave(struct dsa_switch *ds, int port)
 		b53_set_vlan_entry(dev, pvid, vl);
 	}
 }
+EXPORT_SYMBOL(b53_br_leave);
 
-static void b53_br_set_stp_state(struct dsa_switch *ds, int port, u8 state)
+void b53_br_set_stp_state(struct dsa_switch *ds, int port, u8 state)
 {
 	struct b53_device *dev = ds->priv;
 	u8 hw_state;
@@ -1426,14 +1437,16 @@ static void b53_br_set_stp_state(struct dsa_switch *ds, int port, u8 state)
 	reg |= hw_state;
 	b53_write8(dev, B53_CTRL_PAGE, B53_PORT_CTRL(port), reg);
 }
+EXPORT_SYMBOL(b53_br_set_stp_state);
 
-static void b53_br_fast_age(struct dsa_switch *ds, int port)
+void b53_br_fast_age(struct dsa_switch *ds, int port)
 {
 	struct b53_device *dev = ds->priv;
 
 	if (b53_fast_age_port(dev, port))
 		dev_err(ds->dev, "fast ageing failed\n");
 }
+EXPORT_SYMBOL(b53_br_fast_age);
 
 static enum dsa_tag_protocol b53_get_tag_protocol(struct dsa_switch *ds)
 {
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index 1f4b07b77de2..86f125d55aaf 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -374,4 +374,37 @@ static inline int b53_switch_get_reset_gpio(struct b53_device *dev)
 	return -ENOENT;
 }
 #endif
+
+/* Exported functions towards other drivers */
+void b53_get_strings(struct dsa_switch *ds, int port, uint8_t *data);
+void b53_get_ethtool_stats(struct dsa_switch *ds, int port, uint64_t *data);
+int b53_get_sset_count(struct dsa_switch *ds);
+int b53_br_join(struct dsa_switch *ds, int port, struct net_device *bridge);
+void b53_br_leave(struct dsa_switch *ds, int port);
+void b53_br_set_stp_state(struct dsa_switch *ds, int port, u8 state);
+void b53_br_fast_age(struct dsa_switch *ds, int port);
+int b53_vlan_filtering(struct dsa_switch *ds, int port, bool vlan_filtering);
+int b53_vlan_prepare(struct dsa_switch *ds, int port,
+		     const struct switchdev_obj_port_vlan *vlan,
+		     struct switchdev_trans *trans);
+void b53_vlan_add(struct dsa_switch *ds, int port,
+		  const struct switchdev_obj_port_vlan *vlan,
+		  struct switchdev_trans *trans);
+int b53_vlan_del(struct dsa_switch *ds, int port,
+		 const struct switchdev_obj_port_vlan *vlan);
+int b53_vlan_dump(struct dsa_switch *ds, int port,
+		  struct switchdev_obj_port_vlan *vlan,
+		  int (*cb)(struct switchdev_obj *obj));
+int b53_fdb_prepare(struct dsa_switch *ds, int port,
+		    const struct switchdev_obj_port_fdb *fdb,
+		    struct switchdev_trans *trans);
+void b53_fdb_add(struct dsa_switch *ds, int port,
+		 const struct switchdev_obj_port_fdb *fdb,
+		 struct switchdev_trans *trans);
+int b53_fdb_del(struct dsa_switch *ds, int port,
+		const struct switchdev_obj_port_fdb *fdb);
+int b53_fdb_dump(struct dsa_switch *ds, int port,
+		 struct switchdev_obj_port_fdb *fdb,
+		 int (*cb)(struct switchdev_obj *obj));
+
 #endif
-- 
2.9.3
