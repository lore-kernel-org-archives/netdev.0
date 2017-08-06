From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH net-next v3 09/13] net: dsa: Remove support for MDB dump from DSA's drivers
Date: Sun,  6 Aug 2017 16:15:47 +0300
Message-ID: <1502025351-41261-10-git-send-email-arkadis@mellanox.com>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, Woojung.Huh@microchip.com,
        mlxsw@mellanox.com, Arkadi Sharshevsky <arkadis@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44807 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751343AbdHFNMS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 09:12:18 -0400
In-Reply-To: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is done as a preparation before removing support for MDB dump from
DSA core. The MDBs are synced with the bridge and thus there is no
need for special dump operation support.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
---
 drivers/net/dsa/microchip/ksz_common.c |  9 ---------
 drivers/net/dsa/mv88e6xxx/chip.c       | 24 ------------------------
 2 files changed, 33 deletions(-)

diff --git a/drivers/net/dsa/microchip/ksz_common.c b/drivers/net/dsa/microchip/ksz_common.c
index a53ce59..4de9d90 100644
--- a/drivers/net/dsa/microchip/ksz_common.c
+++ b/drivers/net/dsa/microchip/ksz_common.c
@@ -1020,14 +1020,6 @@ static int ksz_port_mdb_del(struct dsa_switch *ds, int port,
 	return ret;
 }
 
-static int ksz_port_mdb_dump(struct dsa_switch *ds, int port,
-			     struct switchdev_obj_port_mdb *mdb,
-			     switchdev_obj_dump_cb_t *cb)
-{
-	/* this is not called by switch layer */
-	return 0;
-}
-
 static int ksz_port_mirror_add(struct dsa_switch *ds, int port,
 			       struct dsa_mall_mirror_tc_entry *mirror,
 			       bool ingress)
@@ -1090,7 +1082,6 @@ static const struct dsa_switch_ops ksz_switch_ops = {
 	.port_mdb_prepare       = ksz_port_mdb_prepare,
 	.port_mdb_add           = ksz_port_mdb_add,
 	.port_mdb_del           = ksz_port_mdb_del,
-	.port_mdb_dump          = ksz_port_mdb_dump,
 	.port_mirror_add	= ksz_port_mirror_add,
 	.port_mirror_del	= ksz_port_mirror_del,
 };
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 5bb1138..1f5c202 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1414,15 +1414,6 @@ static int mv88e6xxx_port_db_dump_fid(struct mv88e6xxx_chip *chip,
 				fdb->ndm_state = NUD_NOARP;
 			else
 				fdb->ndm_state = NUD_REACHABLE;
-		} else if (obj->id == SWITCHDEV_OBJ_ID_PORT_MDB) {
-			struct switchdev_obj_port_mdb *mdb;
-
-			if (!is_multicast_ether_addr(addr.mac))
-				continue;
-
-			mdb = SWITCHDEV_OBJ_PORT_MDB(obj);
-			mdb->vid = vid;
-			ether_addr_copy(mdb->addr, addr.mac);
 		} else {
 			return -EOPNOTSUPP;
 		}
@@ -3800,20 +3791,6 @@ static int mv88e6xxx_port_mdb_del(struct dsa_switch *ds, int port,
 	return err;
 }
 
-static int mv88e6xxx_port_mdb_dump(struct dsa_switch *ds, int port,
-				   struct switchdev_obj_port_mdb *mdb,
-				   switchdev_obj_dump_cb_t *cb)
-{
-	struct mv88e6xxx_chip *chip = ds->priv;
-	int err;
-
-	mutex_lock(&chip->reg_lock);
-	err = mv88e6xxx_port_db_dump(chip, port, &mdb->obj, cb);
-	mutex_unlock(&chip->reg_lock);
-
-	return err;
-}
-
 static const struct dsa_switch_ops mv88e6xxx_switch_ops = {
 	.probe			= mv88e6xxx_drv_probe,
 	.get_tag_protocol	= mv88e6xxx_get_tag_protocol,
@@ -3847,7 +3824,6 @@ static const struct dsa_switch_ops mv88e6xxx_switch_ops = {
 	.port_mdb_prepare       = mv88e6xxx_port_mdb_prepare,
 	.port_mdb_add           = mv88e6xxx_port_mdb_add,
 	.port_mdb_del           = mv88e6xxx_port_mdb_del,
-	.port_mdb_dump          = mv88e6xxx_port_mdb_dump,
 	.crosschip_bridge_join	= mv88e6xxx_crosschip_bridge_join,
 	.crosschip_bridge_leave	= mv88e6xxx_crosschip_bridge_leave,
 };
-- 
2.4.11
