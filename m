From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 4/6] switchdev: rename switchdev_obj_fdb to switchdev_obj_port_fdb
Date: Thu,  1 Oct 2015 11:03:44 +0200
Message-ID: <1443690226-29833-5-git-send-email-jiri@resnulli.us>
References: <1443690226-29833-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38318 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755345AbbJAJDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 05:03:54 -0400
Received: by wiclk2 with SMTP id lk2so18338627wic.1
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 02:03:52 -0700 (PDT)
In-Reply-To: <1443690226-29833-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Make the struct name in sync with object id name.

Suggested-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker.c | 6 +++---
 include/net/switchdev.h              | 2 +-
 net/bridge/br_fdb.c                  | 2 +-
 net/dsa/slave.c                      | 6 +++---
 net/switchdev/switchdev.c            | 8 ++++----
 5 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index d75fc4b3..875f9b5b 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4425,7 +4425,7 @@ static int rocker_port_vlans_add(struct rocker_port *rocker_port,
 
 static int rocker_port_fdb_add(struct rocker_port *rocker_port,
 			       struct switchdev_trans *trans,
-			       const struct switchdev_obj_fdb *fdb)
+			       const struct switchdev_obj_port_fdb *fdb)
 {
 	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, fdb->vid, NULL);
 	int flags = 0;
@@ -4496,7 +4496,7 @@ static int rocker_port_vlans_del(struct rocker_port *rocker_port,
 
 static int rocker_port_fdb_del(struct rocker_port *rocker_port,
 			       struct switchdev_trans *trans,
-			       const struct switchdev_obj_fdb *fdb)
+			       const struct switchdev_obj_port_fdb *fdb)
 {
 	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, fdb->vid, NULL);
 	int flags = ROCKER_OP_FLAG_NOWAIT | ROCKER_OP_FLAG_REMOVE;
@@ -4537,7 +4537,7 @@ static int rocker_port_obj_del(struct net_device *dev,
 }
 
 static int rocker_port_fdb_dump(const struct rocker_port *rocker_port,
-				struct switchdev_obj_fdb *fdb,
+				struct switchdev_obj_port_fdb *fdb,
 				int (*cb)(void *obj))
 {
 	struct rocker *rocker = rocker_port->rocker;
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 0138f9b..8d71fdb 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -83,7 +83,7 @@ struct switchdev_obj_ipv4_fib {
 };
 
 /* SWITCHDEV_OBJ_ID_PORT_FDB */
-struct switchdev_obj_fdb {
+struct switchdev_obj_port_fdb {
 	const unsigned char *addr;
 	u16 vid;
 	u16 ndm_state;
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 6fc8e71..36aab5e 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -133,7 +133,7 @@ static void fdb_del_hw_addr(struct net_bridge *br, const unsigned char *addr)
 
 static void fdb_del_external_learn(struct net_bridge_fdb_entry *f)
 {
-	struct switchdev_obj_fdb fdb = {
+	struct switchdev_obj_port_fdb fdb = {
 		.addr = f->addr.addr,
 		.vid = f->vlan_id,
 	};
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index baf34f2..6e8dc6a 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -341,7 +341,7 @@ static int dsa_slave_port_vlan_dump(struct net_device *dev,
 }
 
 static int dsa_slave_port_fdb_add(struct net_device *dev,
-				  const struct switchdev_obj_fdb *fdb,
+				  const struct switchdev_obj_port_fdb *fdb,
 				  struct switchdev_trans *trans)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
@@ -357,7 +357,7 @@ static int dsa_slave_port_fdb_add(struct net_device *dev,
 }
 
 static int dsa_slave_port_fdb_del(struct net_device *dev,
-				  const struct switchdev_obj_fdb *fdb)
+				  const struct switchdev_obj_port_fdb *fdb)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
@@ -370,7 +370,7 @@ static int dsa_slave_port_fdb_del(struct net_device *dev,
 }
 
 static int dsa_slave_port_fdb_dump(struct net_device *dev,
-				   struct switchdev_obj_fdb *fdb,
+				   struct switchdev_obj_port_fdb *fdb,
 				   int (*cb)(void *obj))
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 02ee926..250d013 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -819,7 +819,7 @@ int switchdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 			   struct net_device *dev, const unsigned char *addr,
 			   u16 vid, u16 nlm_flags)
 {
-	struct switchdev_obj_fdb fdb = {
+	struct switchdev_obj_port_fdb fdb = {
 		.addr = addr,
 		.vid = vid,
 	};
@@ -843,7 +843,7 @@ int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 			   struct net_device *dev, const unsigned char *addr,
 			   u16 vid)
 {
-	struct switchdev_obj_fdb fdb = {
+	struct switchdev_obj_port_fdb fdb = {
 		.addr = addr,
 		.vid = vid,
 	};
@@ -853,7 +853,7 @@ int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_del);
 
 struct switchdev_fdb_dump {
-	struct switchdev_obj_fdb fdb;
+	struct switchdev_obj_port_fdb fdb;
 	struct net_device *dev;
 	struct sk_buff *skb;
 	struct netlink_callback *cb;
@@ -862,7 +862,7 @@ struct switchdev_fdb_dump {
 
 static int switchdev_port_fdb_dump_cb(void *obj)
 {
-	struct switchdev_obj_fdb *fdb = obj;
+	struct switchdev_obj_port_fdb *fdb = obj;
 	struct switchdev_fdb_dump *dump =
 		container_of(fdb, struct switchdev_fdb_dump, fdb);
 	u32 portid = NETLINK_CB(dump->cb->skb).portid;
-- 
1.9.3
