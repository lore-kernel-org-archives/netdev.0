From: sfeldma@gmail.com
Subject: [PATCH net-next v2 24/26] switchdev: rename netdev_switch_notifier_* to swdev_notifier_*
Date: Wed,  1 Apr 2015 03:08:00 -0700
Message-ID: <1427882882-2533-25-git-send-email-sfeldma@gmail.com>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33109 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753202AbbDAKGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 06:06:55 -0400
Received: by pacgg7 with SMTP id gg7so47932215pac.0
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 03:06:54 -0700 (PDT)
In-Reply-To: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

To be consistent with other swdev code, rename swdev notifier with swdev_
prefix.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |    8 +++-----
 include/net/switchdev.h              |   31 ++++++++++++++++---------------
 net/bridge/br.c                      |   22 +++++++++++-----------
 net/switchdev/switchdev.c            |   20 ++++++++++----------
 4 files changed, 40 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 2b62f02..b7e54c3 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3377,17 +3377,15 @@ static void rocker_port_fdb_learn_work(struct work_struct *work)
 		container_of(work, struct rocker_fdb_learn_work, work);
 	bool removing = (lw->flags & ROCKER_OP_FLAG_REMOVE);
 	bool learned = (lw->flags & ROCKER_OP_FLAG_LEARNED);
-	struct netdev_switch_notifier_fdb_info info;
+	struct swdev_notifier_fdb_info info;
 
 	info.addr = lw->addr;
 	info.vid = lw->vid;
 
 	if (learned && removing)
-		call_netdev_switch_notifiers(NETDEV_SWITCH_FDB_DEL,
-					     lw->dev, &info.info);
+		call_swdev_notifiers(SWDEV_FDB_DEL, lw->dev, &info.info);
 	else if (learned && !removing)
-		call_netdev_switch_notifiers(NETDEV_SWITCH_FDB_ADD,
-					     lw->dev, &info.info);
+		call_swdev_notifiers(SWDEV_FDB_ADD, lw->dev, &info.info);
 
 	kfree(work);
 }
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 55f9347..37a2607 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -86,23 +86,23 @@ struct swdev_ops {
 				      u8 tos, u8 type, u32 tb_id);
 };
 
-enum netdev_switch_notifier_type {
-	NETDEV_SWITCH_FDB_ADD = 1,
-	NETDEV_SWITCH_FDB_DEL,
+enum swdev_notifier_type {
+	SWDEV_FDB_ADD = 1,
+	SWDEV_FDB_DEL,
 };
 
-struct netdev_switch_notifier_info {
+struct swdev_notifier_info {
 	struct net_device *dev;
 };
 
-struct netdev_switch_notifier_fdb_info {
-	struct netdev_switch_notifier_info info; /* must be first */
+struct swdev_notifier_fdb_info {
+	struct swdev_notifier_info info; /* must be first */
 	const unsigned char *addr;
 	u16 vid;
 };
 
 static inline struct net_device *
-netdev_switch_notifier_info_to_dev(const struct netdev_switch_notifier_info *info)
+swdev_notifier_info_to_dev(const struct swdev_notifier_info *info)
 {
 	return info->dev;
 }
@@ -119,10 +119,10 @@ int swdev_port_bridge_setlink(struct net_device *dev, struct nlmsghdr *nlh,
 			      u16 flags);
 int swdev_port_bridge_dellink(struct net_device *dev, struct nlmsghdr *nlh,
 			      u16 flags);
-int register_netdev_switch_notifier(struct notifier_block *nb);
-int unregister_netdev_switch_notifier(struct notifier_block *nb);
-int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
-				 struct netdev_switch_notifier_info *info);
+int register_swdev_notifier(struct notifier_block *nb);
+int unregister_swdev_notifier(struct notifier_block *nb);
+int call_swdev_notifiers(unsigned long val, struct net_device *dev,
+			 struct swdev_notifier_info *info);
 int swdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 		       u8 tos, u8 type, u32 nlflags, u32 tb_id);
 int swdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
@@ -174,18 +174,19 @@ static inline int swdev_port_bridge_dellink(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
-static inline int register_netdev_switch_notifier(struct notifier_block *nb)
+static inline int register_swdev_notifier(struct notifier_block *nb)
 {
 	return 0;
 }
 
-static inline int unregister_netdev_switch_notifier(struct notifier_block *nb)
+static inline int unregister_swdev_notifier(struct notifier_block *nb)
 {
 	return 0;
 }
 
-static inline int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
-					       struct netdev_switch_notifier_info *info)
+static inline int call_swdev_notifiers(unsigned long val,
+				       struct net_device *dev,
+				       struct swdev_notifier_info *info)
 {
 	return NOTIFY_DONE;
 }
diff --git a/net/bridge/br.c b/net/bridge/br.c
index 02c24cf..9d54965 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -121,13 +121,13 @@ static struct notifier_block br_device_notifier = {
 	.notifier_call = br_device_event
 };
 
-static int br_netdev_switch_event(struct notifier_block *unused,
-				  unsigned long event, void *ptr)
+static int br_swdev_event(struct notifier_block *unused,
+			  unsigned long event, void *ptr)
 {
-	struct net_device *dev = netdev_switch_notifier_info_to_dev(ptr);
+	struct net_device *dev = swdev_notifier_info_to_dev(ptr);
 	struct net_bridge_port *p;
 	struct net_bridge *br;
-	struct netdev_switch_notifier_fdb_info *fdb_info;
+	struct swdev_notifier_fdb_info *fdb_info;
 	int err = NOTIFY_DONE;
 
 	rtnl_lock();
@@ -138,14 +138,14 @@ static int br_netdev_switch_event(struct notifier_block *unused,
 	br = p->br;
 
 	switch (event) {
-	case NETDEV_SWITCH_FDB_ADD:
+	case SWDEV_FDB_ADD:
 		fdb_info = ptr;
 		err = br_fdb_external_learn_add(br, p, fdb_info->addr,
 						fdb_info->vid);
 		if (err)
 			err = notifier_from_errno(err);
 		break;
-	case NETDEV_SWITCH_FDB_DEL:
+	case SWDEV_FDB_DEL:
 		fdb_info = ptr;
 		err = br_fdb_external_learn_del(br, p, fdb_info->addr,
 						fdb_info->vid);
@@ -159,8 +159,8 @@ out:
 	return err;
 }
 
-static struct notifier_block br_netdev_switch_notifier = {
-	.notifier_call = br_netdev_switch_event,
+static struct notifier_block br_swdev_notifier = {
+	.notifier_call = br_swdev_event,
 };
 
 static void __net_exit br_net_exit(struct net *net)
@@ -214,7 +214,7 @@ static int __init br_init(void)
 	if (err)
 		goto err_out3;
 
-	err = register_netdev_switch_notifier(&br_netdev_switch_notifier);
+	err = register_swdev_notifier(&br_swdev_notifier);
 	if (err)
 		goto err_out4;
 
@@ -235,7 +235,7 @@ static int __init br_init(void)
 	return 0;
 
 err_out5:
-	unregister_netdev_switch_notifier(&br_netdev_switch_notifier);
+	unregister_swdev_notifier(&br_swdev_notifier);
 err_out4:
 	unregister_netdevice_notifier(&br_device_notifier);
 err_out3:
@@ -253,7 +253,7 @@ static void __exit br_deinit(void)
 {
 	stp_proto_unregister(&br_stp_proto);
 	br_netlink_fini();
-	unregister_netdev_switch_notifier(&br_netdev_switch_notifier);
+	unregister_swdev_notifier(&br_swdev_notifier);
 	unregister_netdevice_notifier(&br_device_notifier);
 	brioctl_set(NULL);
 	unregister_pernet_subsys(&br_net_ops);
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 3142c57..98c631c 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -199,14 +199,14 @@ static DEFINE_MUTEX(netdev_switch_mutex);
 static RAW_NOTIFIER_HEAD(netdev_switch_notif_chain);
 
 /**
- *	register_netdev_switch_notifier - Register notifier
+ *	register_swdev_notifier - Register notifier
  *	@nb: notifier_block
  *
  *	Register switch device notifier. This should be used by code
  *	which needs to monitor events happening in particular device.
  *	Return values are same as for atomic_notifier_chain_register().
  */
-int register_netdev_switch_notifier(struct notifier_block *nb)
+int register_swdev_notifier(struct notifier_block *nb)
 {
 	int err;
 
@@ -215,16 +215,16 @@ int register_netdev_switch_notifier(struct notifier_block *nb)
 	mutex_unlock(&netdev_switch_mutex);
 	return err;
 }
-EXPORT_SYMBOL_GPL(register_netdev_switch_notifier);
+EXPORT_SYMBOL_GPL(register_swdev_notifier);
 
 /**
- *	unregister_netdev_switch_notifier - Unregister notifier
+ *	unregister_swdev_notifier - Unregister notifier
  *	@nb: notifier_block
  *
  *	Unregister switch device notifier.
  *	Return values are same as for atomic_notifier_chain_unregister().
  */
-int unregister_netdev_switch_notifier(struct notifier_block *nb)
+int unregister_swdev_notifier(struct notifier_block *nb)
 {
 	int err;
 
@@ -233,10 +233,10 @@ int unregister_netdev_switch_notifier(struct notifier_block *nb)
 	mutex_unlock(&netdev_switch_mutex);
 	return err;
 }
-EXPORT_SYMBOL_GPL(unregister_netdev_switch_notifier);
+EXPORT_SYMBOL_GPL(unregister_swdev_notifier);
 
 /**
- *	call_netdev_switch_notifiers - Call notifiers
+ *	call_swdev_notifiers - Call notifiers
  *	@val: value passed unmodified to notifier function
  *	@dev: port device
  *	@info: notifier information data
@@ -245,8 +245,8 @@ EXPORT_SYMBOL_GPL(unregister_netdev_switch_notifier);
  *	when it needs to propagate hardware event.
  *	Return values are same as for atomic_notifier_call_chain().
  */
-int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
-				 struct netdev_switch_notifier_info *info)
+int call_swdev_notifiers(unsigned long val, struct net_device *dev,
+			 struct swdev_notifier_info *info)
 {
 	int err;
 
@@ -256,7 +256,7 @@ int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
 	mutex_unlock(&netdev_switch_mutex);
 	return err;
 }
-EXPORT_SYMBOL_GPL(call_netdev_switch_notifiers);
+EXPORT_SYMBOL_GPL(call_swdev_notifiers);
 
 /**
  *	swdev_port_bridge_getlink - Get bridge port attributes
-- 
1.7.10.4
