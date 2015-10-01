From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 1/6] switchdev: rename SWITCHDEV_OBJ_* enum values to SWITCHDEV_OBJ_ID_*
Date: Thu,  1 Oct 2015 11:03:41 +0200
Message-ID: <1443690226-29833-2-git-send-email-jiri@resnulli.us>
References: <1443690226-29833-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:35449 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755203AbbJAJDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 05:03:50 -0400
Received: by wicge5 with SMTP id ge5so19404096wic.0
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 02:03:49 -0700 (PDT)
In-Reply-To: <1443690226-29833-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Suggested-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 Documentation/networking/switchdev.txt |  6 +++---
 drivers/net/ethernet/rocker/rocker.c   | 16 ++++++++--------
 include/net/switchdev.h                | 14 +++++++-------
 net/bridge/br_fdb.c                    |  2 +-
 net/bridge/br_vlan.c                   |  6 ++++--
 net/dsa/slave.c                        | 12 ++++++------
 net/switchdev/switchdev.c              | 16 ++++++++--------
 7 files changed, 37 insertions(+), 35 deletions(-)

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
index 9f9e258..c150a87 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -178,7 +178,7 @@ entries are installed, for example, using iproute2 bridge cmd:
 	bridge fdb add ADDR dev DEV [vlan VID] [self]
 
 The driver should use the helper switchdev_port_fdb_xxx ops for ndo_fdb_xxx
-ops, and handle add/delete/dump of SWITCHDEV_OBJ_PORT_FDB object using
+ops, and handle add/delete/dump of SWITCHDEV_OBJ_ID_PORT_FDB object using
 switchdev_port_obj_xxx ops.
 
 XXX: what should be done if offloading this rule to hardware fails (for
@@ -316,9 +316,9 @@ SWITCHDEV_OBJ_IPV[4|6]_FIB object using switchdev_port_obj_xxx ops.
 switchdev_port_obj_add is used for both adding a new FIB entry to the device,
 or modifying an existing entry on the device.
 
-XXX: Currently, only SWITCHDEV_OBJ_IPV4_FIB objects are supported.
+XXX: Currently, only SWITCHDEV_OBJ_ID_IPV4_FIB objects are supported.
 
-SWITCHDEV_OBJ_IPV4_FIB object passes:
+SWITCHDEV_OBJ_ID_IPV4_FIB object passes:
 
 	struct switchdev_obj_ipv4_fib {         /* IPV4_FIB */
 		u32 dst;
diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 9773f5b..9b2e8be 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4445,16 +4445,16 @@ static int rocker_port_obj_add(struct net_device *dev,
 	int err = 0;
 
 	switch (id) {
-	case SWITCHDEV_OBJ_PORT_VLAN:
+	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = rocker_port_vlans_add(rocker_port, trans, obj);
 		break;
-	case SWITCHDEV_OBJ_IPV4_FIB:
+	case SWITCHDEV_OBJ_ID_IPV4_FIB:
 		fib4 = obj;
 		err = rocker_port_fib_ipv4(rocker_port, trans,
 					   htonl(fib4->dst), fib4->dst_len,
 					   fib4->fi, fib4->tb_id, 0);
 		break;
-	case SWITCHDEV_OBJ_PORT_FDB:
+	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = rocker_port_fdb_add(rocker_port, trans, obj);
 		break;
 	default:
@@ -4515,17 +4515,17 @@ static int rocker_port_obj_del(struct net_device *dev,
 	int err = 0;
 
 	switch (id) {
-	case SWITCHDEV_OBJ_PORT_VLAN:
+	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = rocker_port_vlans_del(rocker_port, obj);
 		break;
-	case SWITCHDEV_OBJ_IPV4_FIB:
+	case SWITCHDEV_OBJ_ID_IPV4_FIB:
 		fib4 = obj;
 		err = rocker_port_fib_ipv4(rocker_port, NULL,
 					   htonl(fib4->dst), fib4->dst_len,
 					   fib4->fi, fib4->tb_id,
 					   ROCKER_OP_FLAG_REMOVE);
 		break;
-	case SWITCHDEV_OBJ_PORT_FDB:
+	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = rocker_port_fdb_del(rocker_port, NULL, obj);
 		break;
 	default:
@@ -4594,10 +4594,10 @@ static int rocker_port_obj_dump(struct net_device *dev,
 	int err = 0;
 
 	switch (id) {
-	case SWITCHDEV_OBJ_PORT_FDB:
+	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = rocker_port_fdb_dump(rocker_port, obj, cb);
 		break;
-	case SWITCHDEV_OBJ_PORT_VLAN:
+	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = rocker_port_vlan_dump(rocker_port, obj, cb);
 		break;
 	default:
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index e11425e..11f9c70 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -58,20 +58,20 @@ struct switchdev_attr {
 struct fib_info;
 
 enum switchdev_obj_id {
-	SWITCHDEV_OBJ_UNDEFINED,
-	SWITCHDEV_OBJ_PORT_VLAN,
-	SWITCHDEV_OBJ_IPV4_FIB,
-	SWITCHDEV_OBJ_PORT_FDB,
+	SWITCHDEV_OBJ_ID_UNDEFINED,
+	SWITCHDEV_OBJ_ID_PORT_VLAN,
+	SWITCHDEV_OBJ_ID_IPV4_FIB,
+	SWITCHDEV_OBJ_ID_PORT_FDB,
 };
 
-/* SWITCHDEV_OBJ_PORT_VLAN */
+/* SWITCHDEV_OBJ_ID_PORT_VLAN */
 struct switchdev_obj_vlan {
 	u16 flags;
 	u16 vid_begin;
 	u16 vid_end;
 };
 
-/* SWITCHDEV_OBJ_IPV4_FIB */
+/* SWITCHDEV_OBJ_ID_IPV4_FIB */
 struct switchdev_obj_ipv4_fib {
 	u32 dst;
 	int dst_len;
@@ -82,7 +82,7 @@ struct switchdev_obj_ipv4_fib {
 	u32 tb_id;
 };
 
-/* SWITCHDEV_OBJ_PORT_FDB */
+/* SWITCHDEV_OBJ_ID_PORT_FDB */
 struct switchdev_obj_fdb {
 	const unsigned char *addr;
 	u16 vid;
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 7826782d..6fc8e71 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -138,7 +138,7 @@ static void fdb_del_external_learn(struct net_bridge_fdb_entry *f)
 		.vid = f->vlan_id,
 	};
 
-	switchdev_port_obj_del(f->dst->dev, SWITCHDEV_OBJ_PORT_FDB, &fdb);
+	switchdev_port_obj_del(f->dst->dev, SWITCHDEV_OBJ_ID_PORT_FDB, &fdb);
 }
 
 static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index e227164..6c3ac5c 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -86,7 +86,8 @@ static int __vlan_vid_add(struct net_device *dev, struct net_bridge *br,
 			.vid_end = vid,
 		};
 
-		err = switchdev_port_obj_add(dev, SWITCHDEV_OBJ_PORT_VLAN, &v);
+		err = switchdev_port_obj_add(dev, SWITCHDEV_OBJ_ID_PORT_VLAN,
+					     &v);
 		if (err == -EOPNOTSUPP)
 			err = 0;
 	}
@@ -134,7 +135,8 @@ static int __vlan_vid_del(struct net_device *dev, struct net_bridge *br,
 			.vid_end = vid,
 		};
 
-		err = switchdev_port_obj_del(dev, SWITCHDEV_OBJ_PORT_VLAN, &v);
+		err = switchdev_port_obj_del(dev, SWITCHDEV_OBJ_ID_PORT_VLAN,
+					     &v);
 		if (err == -EOPNOTSUPP)
 			err = 0;
 	}
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 7b1d9ec..a706029 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -485,10 +485,10 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 	 */
 
 	switch (id) {
-	case SWITCHDEV_OBJ_PORT_FDB:
+	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = dsa_slave_port_fdb_add(dev, obj, trans);
 		break;
-	case SWITCHDEV_OBJ_PORT_VLAN:
+	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = dsa_slave_port_vlan_add(dev, obj, trans);
 		break;
 	default:
@@ -505,10 +505,10 @@ static int dsa_slave_port_obj_del(struct net_device *dev,
 	int err;
 
 	switch (id) {
-	case SWITCHDEV_OBJ_PORT_FDB:
+	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = dsa_slave_port_fdb_del(dev, obj);
 		break;
-	case SWITCHDEV_OBJ_PORT_VLAN:
+	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = dsa_slave_port_vlan_del(dev, obj);
 		break;
 	default:
@@ -526,10 +526,10 @@ static int dsa_slave_port_obj_dump(struct net_device *dev,
 	int err;
 
 	switch (id) {
-	case SWITCHDEV_OBJ_PORT_FDB:
+	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = dsa_slave_port_fdb_dump(dev, obj, cb);
 		break;
-	case SWITCHDEV_OBJ_PORT_VLAN:
+	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = dsa_slave_port_vlan_dump(dev, obj, cb);
 		break;
 	default:
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index fe82fab..5b1aa9f 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -584,7 +584,7 @@ static int switchdev_port_vlan_fill(struct sk_buff *skb, struct net_device *dev,
 
 	if ((filter_mask & RTEXT_FILTER_BRVLAN) ||
 	    (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)) {
-		err = switchdev_port_obj_dump(dev, SWITCHDEV_OBJ_PORT_VLAN,
+		err = switchdev_port_obj_dump(dev, SWITCHDEV_OBJ_ID_PORT_VLAN,
 					      &dump.vlan,
 					      switchdev_port_vlan_dump_cb);
 		if (err)
@@ -725,7 +725,7 @@ static int switchdev_port_br_afspec(struct net_device *dev,
 			vlan.vid_end = vinfo->vid;
 			if (vlan.vid_end <= vlan.vid_begin)
 				return -EINVAL;
-			err = f(dev, SWITCHDEV_OBJ_PORT_VLAN, &vlan);
+			err = f(dev, SWITCHDEV_OBJ_ID_PORT_VLAN, &vlan);
 			if (err)
 				return err;
 			memset(&vlan, 0, sizeof(vlan));
@@ -734,7 +734,7 @@ static int switchdev_port_br_afspec(struct net_device *dev,
 				return -EINVAL;
 			vlan.vid_begin = vinfo->vid;
 			vlan.vid_end = vinfo->vid;
-			err = f(dev, SWITCHDEV_OBJ_PORT_VLAN, &vlan);
+			err = f(dev, SWITCHDEV_OBJ_ID_PORT_VLAN, &vlan);
 			if (err)
 				return err;
 			memset(&vlan, 0, sizeof(vlan));
@@ -824,7 +824,7 @@ int switchdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		.vid = vid,
 	};
 
-	return switchdev_port_obj_add(dev, SWITCHDEV_OBJ_PORT_FDB, &fdb);
+	return switchdev_port_obj_add(dev, SWITCHDEV_OBJ_ID_PORT_FDB, &fdb);
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_add);
 
@@ -848,7 +848,7 @@ int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 		.vid = vid,
 	};
 
-	return switchdev_port_obj_del(dev, SWITCHDEV_OBJ_PORT_FDB, &fdb);
+	return switchdev_port_obj_del(dev, SWITCHDEV_OBJ_ID_PORT_FDB, &fdb);
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_del);
 
@@ -926,7 +926,7 @@ int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 		.idx = idx,
 	};
 
-	switchdev_port_obj_dump(dev, SWITCHDEV_OBJ_PORT_FDB, &dump.fdb,
+	switchdev_port_obj_dump(dev, SWITCHDEV_OBJ_ID_PORT_FDB, &dump.fdb,
 				switchdev_port_fdb_dump_cb);
 	return dump.idx;
 }
@@ -1033,7 +1033,7 @@ int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 	if (!dev)
 		return 0;
 
-	err = switchdev_port_obj_add(dev, SWITCHDEV_OBJ_IPV4_FIB, &ipv4_fib);
+	err = switchdev_port_obj_add(dev, SWITCHDEV_OBJ_ID_IPV4_FIB, &ipv4_fib);
 	if (!err)
 		fi->fib_flags |= RTNH_F_OFFLOAD;
 
@@ -1075,7 +1075,7 @@ int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 	if (!dev)
 		return 0;
 
-	err = switchdev_port_obj_del(dev, SWITCHDEV_OBJ_IPV4_FIB, &ipv4_fib);
+	err = switchdev_port_obj_del(dev, SWITCHDEV_OBJ_ID_IPV4_FIB, &ipv4_fib);
 	if (!err)
 		fi->fib_flags &= ~RTNH_F_OFFLOAD;
 
-- 
1.9.3
