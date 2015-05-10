From: sfeldma@gmail.com
Subject: [PATCH net-next v7 17/24] switchdev: remove unused switchdev_port_bridge_dellink
Date: Sun, 10 May 2015 09:48:02 -0700
Message-ID: <1431276489-64199-18-git-send-email-sfeldma@gmail.com>
References: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:36691 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854AbbEJQrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 12:47:18 -0400
Received: by pdea3 with SMTP id a3so129311155pde.3
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 09:47:18 -0700 (PDT)
In-Reply-To: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Now we can remove old wrappers for dellink.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |   15 ---------------
 net/switchdev/switchdev.c |   30 ------------------------------
 2 files changed, 45 deletions(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 8ffadca..397b1e6 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -130,8 +130,6 @@ int switchdev_port_bridge_setlink(struct net_device *dev,
 				  struct nlmsghdr *nlh, u16 flags);
 int switchdev_port_bridge_dellink(struct net_device *dev,
 				  struct nlmsghdr *nlh, u16 flags);
-int ndo_dflt_switchdev_port_bridge_dellink(struct net_device *dev,
-					   struct nlmsghdr *nlh, u16 flags);
 int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 			   u8 tos, u8 type, u32 nlflags, u32 tb_id);
 int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
@@ -164,12 +162,6 @@ static inline int switchdev_port_obj_del(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
-static inline int switchdev_port_bridge_dellink(struct net_device *dev,
-					    struct nlmsghdr *nlh, u16 flags)
-{
-	return -EOPNOTSUPP;
-}
-
 static inline int register_switchdev_notifier(struct notifier_block *nb)
 {
 	return 0;
@@ -201,13 +193,6 @@ static inline int switchdev_port_bridge_dellink(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
-static inline int ndo_dflt_switchdev_port_bridge_dellink(struct net_device *dev,
-							 struct nlmsghdr *nlh,
-							 u16 flags)
-{
-	return 0;
-}
-
 static inline int switchdev_fib_ipv4_add(u32 dst, int dst_len,
 					 struct fib_info *fi,
 					 u8 tos, u8 type,
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 8ce678e..0e15b6f 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -536,36 +536,6 @@ int switchdev_port_bridge_dellink(struct net_device *dev,
 }
 EXPORT_SYMBOL_GPL(switchdev_port_bridge_dellink);
 
-/**
- *	ndo_dflt_switchdev_port_bridge_dellink - default ndo bridge dellink
- *						 op for master devices
- *
- *	@dev: port device
- *	@nlh: netlink msg with bridge port attributes
- *	@flags: bridge dellink flags
- *
- *	Notify master device slaves of bridge port attribute deletes
- */
-int ndo_dflt_switchdev_port_bridge_dellink(struct net_device *dev,
-					   struct nlmsghdr *nlh, u16 flags)
-{
-	struct net_device *lower_dev;
-	struct list_head *iter;
-	int ret = 0, err = 0;
-
-	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
-		return ret;
-
-	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		err = switchdev_port_bridge_dellink(lower_dev, nlh, flags);
-		if (err && err != -EOPNOTSUPP)
-			ret = err;
-	}
-
-	return ret;
-}
-EXPORT_SYMBOL_GPL(ndo_dflt_switchdev_port_bridge_dellink);
-
 static struct net_device *switchdev_get_lowest_dev(struct net_device *dev)
 {
 	const struct switchdev_ops *ops = dev->switchdev_ops;
-- 
1.7.10.4
