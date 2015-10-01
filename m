From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 2/6] switchdev: rename SWITCHDEV_ATTR_* enum values to SWITCHDEV_ATTR_ID_*
Date: Thu,  1 Oct 2015 11:03:42 +0200
Message-ID: <1443690226-29833-3-git-send-email-jiri@resnulli.us>
References: <1443690226-29833-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35480 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755242AbbJAJDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 05:03:52 -0400
Received: by wicge5 with SMTP id ge5so19404885wic.0
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 02:03:50 -0700 (PDT)
In-Reply-To: <1443690226-29833-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

To be aligned with obj.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 Documentation/networking/switchdev.txt         |  9 +++++----
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c |  2 +-
 drivers/net/ethernet/rocker/rocker.c           |  8 ++++----
 include/net/switchdev.h                        |  8 ++++----
 net/bridge/br_stp.c                            |  2 +-
 net/core/net-sysfs.c                           |  2 +-
 net/core/rtnetlink.c                           |  2 +-
 net/dsa/slave.c                                |  4 ++--
 net/switchdev/switchdev.c                      | 14 +++++++-------
 9 files changed, 26 insertions(+), 25 deletions(-)

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
index c150a87..0714fe5 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -115,7 +115,7 @@ Switch ID
 ^^^^^^^^^
 
 The switchdev driver must implement the switchdev op switchdev_port_attr_get
-for SWITCHDEV_ATTR_PORT_PARENT_ID for each port netdev, returning the same
+for SWITCHDEV_ATTR_ID_PORT_PARENT_ID for each port netdev, returning the same
 physical ID for each port of a switch.  The ID must be unique between switches
 on the same system.  The ID does not need to be unique between switches on
 different systems.
@@ -233,8 +233,9 @@ the bridge's FDB.  It's possible, but not optimal, to enable learning on the
 device port and on the bridge port, and disable learning_sync.
 
 To support learning and learning_sync port attributes, the driver implements
-switchdev op switchdev_port_attr_get/set for SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS.
-The driver should initialize the attributes to the hardware defaults.
+switchdev op switchdev_port_attr_get/set for
+SWITCHDEV_ATTR_PORT_ID_BRIDGE_FLAGS. The driver should initialize the attributes
+to the hardware defaults.
 
 FDB Ageing
 ^^^^^^^^^^
@@ -260,7 +261,7 @@ STP State Change on Port
 Internally or with a third-party STP protocol implementation (e.g. mstpd), the
 bridge driver maintains the STP state for ports, and will notify the switch
 driver of STP state change on a port using the switchdev op
-switchdev_attr_port_set for SWITCHDEV_ATTR_PORT_STP_UPDATE.
+switchdev_attr_port_set for SWITCHDEV_ATTR_PORT_ID_STP_UPDATE.
 
 State is one of BR_STATE_*.  The switch driver can use STP state updates to
 update ingress packet filter list for the port.  For example, if port is
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 3e52ee9..d448431 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -868,7 +868,7 @@ static int mlxsw_sx_port_attr_get(struct net_device *dev,
 	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
 
 	switch (attr->id) {
-	case SWITCHDEV_ATTR_PORT_PARENT_ID:
+	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
 		attr->u.ppid.id_len = sizeof(mlxsw_sx->hw_id);
 		memcpy(&attr->u.ppid.id, &mlxsw_sx->hw_id, attr->u.ppid.id_len);
 		break;
diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 9b2e8be..4540ca6 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4329,11 +4329,11 @@ static int rocker_port_attr_get(struct net_device *dev,
 	const struct rocker *rocker = rocker_port->rocker;
 
 	switch (attr->id) {
-	case SWITCHDEV_ATTR_PORT_PARENT_ID:
+	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
 		attr->u.ppid.id_len = sizeof(rocker->hw.id);
 		memcpy(&attr->u.ppid.id, &rocker->hw.id, attr->u.ppid.id_len);
 		break;
-	case SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS:
+	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS:
 		attr->u.brport_flags = rocker_port->brport_flags;
 		break;
 	default:
@@ -4369,12 +4369,12 @@ static int rocker_port_attr_set(struct net_device *dev,
 	int err = 0;
 
 	switch (attr->id) {
-	case SWITCHDEV_ATTR_PORT_STP_STATE:
+	case SWITCHDEV_ATTR_ID_PORT_STP_STATE:
 		err = rocker_port_stp_update(rocker_port, trans,
 					     ROCKER_OP_FLAG_NOWAIT,
 					     attr->u.stp_state);
 		break;
-	case SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS:
+	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS:
 		err = rocker_port_brport_flags_set(rocker_port, trans,
 						   attr->u.brport_flags);
 		break;
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 11f9c70..612719b 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -39,10 +39,10 @@ static inline bool switchdev_trans_ph_commit(struct switchdev_trans *trans)
 }
 
 enum switchdev_attr_id {
-	SWITCHDEV_ATTR_UNDEFINED,
-	SWITCHDEV_ATTR_PORT_PARENT_ID,
-	SWITCHDEV_ATTR_PORT_STP_STATE,
-	SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS,
+	SWITCHDEV_ATTR_ID_UNDEFINED,
+	SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
+	SWITCHDEV_ATTR_ID_PORT_STP_STATE,
+	SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
 };
 
 struct switchdev_attr {
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 3a7392e..3a982c0 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -40,7 +40,7 @@ void br_log_state(const struct net_bridge_port *p)
 void br_set_state(struct net_bridge_port *p, unsigned int state)
 {
 	struct switchdev_attr attr = {
-		.id = SWITCHDEV_ATTR_PORT_STP_STATE,
+		.id = SWITCHDEV_ATTR_ID_PORT_STP_STATE,
 		.u.stp_state = state,
 	};
 	int err;
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index b4c5300..12f4225 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -472,7 +472,7 @@ static ssize_t phys_switch_id_show(struct device *dev,
 
 	if (dev_isalive(netdev)) {
 		struct switchdev_attr attr = {
-			.id = SWITCHDEV_ATTR_PORT_PARENT_ID,
+			.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
 			.flags = SWITCHDEV_F_NO_RECURSE,
 		};
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 474a6da..b2258a3 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1025,7 +1025,7 @@ static int rtnl_phys_switch_id_fill(struct sk_buff *skb, struct net_device *dev)
 {
 	int err;
 	struct switchdev_attr attr = {
-		.id = SWITCHDEV_ATTR_PORT_PARENT_ID,
+		.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
 		.flags = SWITCHDEV_F_NO_RECURSE,
 	};
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index a706029..8992568 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -458,7 +458,7 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 	int ret;
 
 	switch (attr->id) {
-	case SWITCHDEV_ATTR_PORT_STP_STATE:
+	case SWITCHDEV_ATTR_ID_PORT_STP_STATE:
 		if (switchdev_trans_ph_prepare(trans))
 			ret = ds->drv->port_stp_update ? 0 : -EOPNOTSUPP;
 		else
@@ -584,7 +584,7 @@ static int dsa_slave_port_attr_get(struct net_device *dev,
 	struct dsa_switch *ds = p->parent;
 
 	switch (attr->id) {
-	case SWITCHDEV_ATTR_PORT_PARENT_ID:
+	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
 		attr->u.ppid.id_len = sizeof(ds->index);
 		memcpy(&attr->u.ppid.id, &ds->index, attr->u.ppid.id_len);
 		break;
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 5b1aa9f..c457c1f 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -104,7 +104,7 @@ int switchdev_port_attr_get(struct net_device *dev, struct switchdev_attr *attr)
 	struct net_device *lower_dev;
 	struct list_head *iter;
 	struct switchdev_attr first = {
-		.id = SWITCHDEV_ATTR_UNDEFINED
+		.id = SWITCHDEV_ATTR_ID_UNDEFINED
 	};
 	int err = -EOPNOTSUPP;
 
@@ -124,7 +124,7 @@ int switchdev_port_attr_get(struct net_device *dev, struct switchdev_attr *attr)
 		err = switchdev_port_attr_get(lower_dev, attr);
 		if (err)
 			break;
-		if (first.id == SWITCHDEV_ATTR_UNDEFINED)
+		if (first.id == SWITCHDEV_ATTR_ID_UNDEFINED)
 			first = *attr;
 		else if (memcmp(&first, attr, sizeof(*attr)))
 			return -ENODATA;
@@ -611,7 +611,7 @@ int switchdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				  int nlflags)
 {
 	struct switchdev_attr attr = {
-		.id = SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS,
+		.id = SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
 	};
 	u16 mode = BRIDGE_MODE_UNDEF;
 	u32 mask = BR_LEARNING | BR_LEARNING_SYNC;
@@ -632,7 +632,7 @@ static int switchdev_port_br_setflag(struct net_device *dev,
 				     unsigned long brport_flag)
 {
 	struct switchdev_attr attr = {
-		.id = SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS,
+		.id = SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
 	};
 	u8 flag = nla_get_u8(nlattr);
 	int err;
@@ -958,7 +958,7 @@ static struct net_device *switchdev_get_lowest_dev(struct net_device *dev)
 static struct net_device *switchdev_get_dev_by_nhs(struct fib_info *fi)
 {
 	struct switchdev_attr attr = {
-		.id = SWITCHDEV_ATTR_PORT_PARENT_ID,
+		.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
 	};
 	struct switchdev_attr prev_attr;
 	struct net_device *dev = NULL;
@@ -1107,11 +1107,11 @@ static bool switchdev_port_same_parent_id(struct net_device *a,
 					  struct net_device *b)
 {
 	struct switchdev_attr a_attr = {
-		.id = SWITCHDEV_ATTR_PORT_PARENT_ID,
+		.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
 		.flags = SWITCHDEV_F_NO_RECURSE,
 	};
 	struct switchdev_attr b_attr = {
-		.id = SWITCHDEV_ATTR_PORT_PARENT_ID,
+		.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
 		.flags = SWITCHDEV_F_NO_RECURSE,
 	};
 
-- 
1.9.3
