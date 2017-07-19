From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH net-next v2 10/13] net: dsa: Remove redundant MDB dump support
Date: Wed, 19 Jul 2017 19:04:51 +0300
Message-ID: <1500480294-10604-11-git-send-email-arkadis@mellanox.com>
References: <1500480294-10604-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com,
        Arkadi Sharshevsky <arkadis@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:50689 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755289AbdGSQBe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 12:01:34 -0400
In-Reply-To: <1500480294-10604-1-git-send-email-arkadis@mellanox.com>
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
index 4b82647..0f4912b 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -406,10 +406,6 @@ struct dsa_switch_ops {
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
index cddcea2..897ac24 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -132,8 +132,6 @@ int dsa_port_mdb_add(struct dsa_port *dp,
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
index f939d79..14f4d69 100644
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
