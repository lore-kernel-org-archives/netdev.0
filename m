From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 3/6] switchdev: rename switchdev_obj_vlan to switchdev_obj_port_vlan
Date: Thu,  1 Oct 2015 11:03:43 +0200
Message-ID: <1443690226-29833-4-git-send-email-jiri@resnulli.us>
References: <1443690226-29833-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:38294 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755305AbbJAJDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 05:03:53 -0400
Received: by wiclk2 with SMTP id lk2so18337973wic.1
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 02:03:51 -0700 (PDT)
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
 net/bridge/br_vlan.c                 | 4 ++--
 net/dsa/slave.c                      | 6 +++---
 net/switchdev/switchdev.c            | 6 +++---
 5 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 4540ca6..d75fc4b3 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4408,7 +4408,7 @@ static int rocker_port_vlan_add(struct rocker_port *rocker_port,
 
 static int rocker_port_vlans_add(struct rocker_port *rocker_port,
 				 struct switchdev_trans *trans,
-				 const struct switchdev_obj_vlan *vlan)
+				 const struct switchdev_obj_port_vlan *vlan)
 {
 	u16 vid;
 	int err;
@@ -4480,7 +4480,7 @@ static int rocker_port_vlan_del(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_vlans_del(struct rocker_port *rocker_port,
-				 const struct switchdev_obj_vlan *vlan)
+				 const struct switchdev_obj_port_vlan *vlan)
 {
 	u16 vid;
 	int err;
@@ -4565,7 +4565,7 @@ static int rocker_port_fdb_dump(const struct rocker_port *rocker_port,
 }
 
 static int rocker_port_vlan_dump(const struct rocker_port *rocker_port,
-				 struct switchdev_obj_vlan *vlan,
+				 struct switchdev_obj_port_vlan *vlan,
 				int (*cb)(void *obj))
 {
 	u16 vid;
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 612719b..0138f9b 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -65,7 +65,7 @@ enum switchdev_obj_id {
 };
 
 /* SWITCHDEV_OBJ_ID_PORT_VLAN */
-struct switchdev_obj_vlan {
+struct switchdev_obj_port_vlan {
 	u16 flags;
 	u16 vid_begin;
 	u16 vid_end;
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 6c3ac5c..8bcb661 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -80,7 +80,7 @@ static int __vlan_vid_add(struct net_device *dev, struct net_bridge *br,
 	if (ops->ndo_vlan_rx_add_vid) {
 		err = vlan_vid_add(dev, br->vlan_proto, vid);
 	} else {
-		struct switchdev_obj_vlan v = {
+		struct switchdev_obj_port_vlan v = {
 			.flags = flags,
 			.vid_begin = vid,
 			.vid_end = vid,
@@ -130,7 +130,7 @@ static int __vlan_vid_del(struct net_device *dev, struct net_bridge *br,
 	if (ops->ndo_vlan_rx_kill_vid) {
 		vlan_vid_del(dev, br->vlan_proto, vid);
 	} else {
-		struct switchdev_obj_vlan v = {
+		struct switchdev_obj_port_vlan v = {
 			.vid_begin = vid,
 			.vid_end = vid,
 		};
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 8992568..baf34f2 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -242,7 +242,7 @@ static int dsa_bridge_check_vlan_range(struct dsa_switch *ds,
 }
 
 static int dsa_slave_port_vlan_add(struct net_device *dev,
-				   const struct switchdev_obj_vlan *vlan,
+				   const struct switchdev_obj_port_vlan *vlan,
 				   struct switchdev_trans *trans)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
@@ -278,7 +278,7 @@ static int dsa_slave_port_vlan_add(struct net_device *dev,
 }
 
 static int dsa_slave_port_vlan_del(struct net_device *dev,
-				   const struct switchdev_obj_vlan *vlan)
+				   const struct switchdev_obj_port_vlan *vlan)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
@@ -298,7 +298,7 @@ static int dsa_slave_port_vlan_del(struct net_device *dev,
 }
 
 static int dsa_slave_port_vlan_dump(struct net_device *dev,
-				    struct switchdev_obj_vlan *vlan,
+				    struct switchdev_obj_port_vlan *vlan,
 				    int (*cb)(void *obj))
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index c457c1f..02ee926 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -483,7 +483,7 @@ int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
 EXPORT_SYMBOL_GPL(call_switchdev_notifiers);
 
 struct switchdev_vlan_dump {
-	struct switchdev_obj_vlan vlan;
+	struct switchdev_obj_port_vlan vlan;
 	struct sk_buff *skb;
 	u32 filter_mask;
 	u16 flags;
@@ -523,7 +523,7 @@ static int switchdev_port_vlan_dump_put(struct switchdev_vlan_dump *dump)
 
 static int switchdev_port_vlan_dump_cb(void *obj)
 {
-	struct switchdev_obj_vlan *vlan = obj;
+	struct switchdev_obj_port_vlan *vlan = obj;
 	struct switchdev_vlan_dump *dump =
 		container_of(vlan, struct switchdev_vlan_dump, vlan);
 	int err = 0;
@@ -704,7 +704,7 @@ static int switchdev_port_br_afspec(struct net_device *dev,
 {
 	struct nlattr *attr;
 	struct bridge_vlan_info *vinfo;
-	struct switchdev_obj_vlan vlan = { 0 };
+	struct switchdev_obj_port_vlan vlan = { 0 };
 	int rem;
 	int err;
 
-- 
1.9.3
