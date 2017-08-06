From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH net-next v3 10/13] net: dsa: Remove redundant MDB dump support
Date: Sun,  6 Aug 2017 16:15:48 +0300
Message-ID: <1502025351-41261-11-git-send-email-arkadis@mellanox.com>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, Woojung.Huh@microchip.com,
        mlxsw@mellanox.com, Arkadi Sharshevsky <arkadis@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44844 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751348AbdHFNMS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 09:12:18 -0400
In-Reply-To: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the MDB HW database is synced with the bridge's one, thus,
There is no need to support special dump functionality.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
---
 include/net/dsa.h  |  4 ----
 net/dsa/dsa_priv.h |  2 --
 net/dsa/port.c     | 11 -----------
 net/dsa/slave.c    |  3 ---
 4 files changed, 20 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index d7b9bdd..4ef1859 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -400,10 +400,6 @@ struct dsa_switch_ops {
 				struct switchdev_trans *trans);
 	int	(*port_mdb_del)(struct dsa_switch *ds, int port,
 				const struct switchdev_obj_port_mdb *mdb);
-	int	(*port_mdb_dump)(struct dsa_switch *ds, int port,
-				 struct switchdev_obj_port_mdb *mdb,
-				  switchdev_obj_dump_cb_t *cb);
-
 	/*
 	 * RXNFC
 	 */
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 77ddec4..3207071 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -141,8 +141,6 @@ int dsa_port_mdb_add(struct dsa_port *dp,
 		     struct switchdev_trans *trans);
 int dsa_port_mdb_del(struct dsa_port *dp,
 		     const struct switchdev_obj_port_mdb *mdb);
-int dsa_port_mdb_dump(struct dsa_port *dp, struct switchdev_obj_port_mdb *mdb,
-		      switchdev_obj_dump_cb_t *cb);
 int dsa_port_vlan_add(struct dsa_port *dp,
 		      const struct switchdev_obj_port_vlan *vlan,
 		      struct switchdev_trans *trans);
diff --git a/net/dsa/port.c b/net/dsa/port.c
index ce19216..7378782 100644
--- a/net/dsa/port.c
+++ b/net/dsa/port.c
@@ -210,17 +210,6 @@ int dsa_port_mdb_del(struct dsa_port *dp,
 	return dsa_port_notify(dp, DSA_NOTIFIER_MDB_DEL, &info);
 }
 
-int dsa_port_mdb_dump(struct dsa_port *dp, struct switchdev_obj_port_mdb *mdb,
-		      switchdev_obj_dump_cb_t *cb)
-{
-	struct dsa_switch *ds = dp->ds;
-
-	if (ds->ops->port_mdb_dump)
-		return ds->ops->port_mdb_dump(ds, dp->index, mdb, cb);
-
-	return -EOPNOTSUPP;
-}
-
 int dsa_port_vlan_add(struct dsa_port *dp,
 		      const struct switchdev_obj_port_vlan *vlan,
 		      struct switchdev_trans *trans)
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 5b37298..8482060 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -299,9 +299,6 @@ static int dsa_slave_port_obj_dump(struct net_device *dev,
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = dsa_port_fdb_dump(dp, SWITCHDEV_OBJ_PORT_FDB(obj), cb);
 		break;
-	case SWITCHDEV_OBJ_ID_PORT_MDB:
-		err = dsa_port_mdb_dump(dp, SWITCHDEV_OBJ_PORT_MDB(obj), cb);
-		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
-- 
2.4.11
