From: sfeldma@gmail.com
Subject: [PATCH net-next v2 3/3] netdev: remove ndo ops for switchdev
Date: Sun, 15 Mar 2015 18:45:21 -0700
Message-ID: <1426470321-48669-4-git-send-email-sfeldma@gmail.com>
References: <1426470321-48669-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com,
	simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33706 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752690AbbCPBoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 21:44:19 -0400
Received: by pagr17 with SMTP id r17so49066595pag.0
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 18:44:18 -0700 (PDT)
In-Reply-To: <1426470321-48669-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/linux/netdevice.h |   38 --------------------------------------
 1 file changed, 38 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9e8a2a9..dd1d069 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -768,8 +768,6 @@ struct netdev_phys_item_id {
 typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
 				       struct sk_buff *skb);
 
-struct fib_info;
-
 /*
  * This structure defines the management hooks for network devices.
  * The following hooks can be defined; unless noted otherwise, they are
@@ -1024,23 +1022,6 @@ struct fib_info;
  *	be otherwise expressed by feature flags. The check is called with
  *	the set of features that the stack has calculated and it returns
  *	those the driver believes to be appropriate.
- *
- * int (*ndo_switch_parent_id_get)(struct net_device *dev,
- *				   struct netdev_phys_item_id *psid);
- *	Called to get an ID of the switch chip this port is part of.
- *	If driver implements this, it indicates that it represents a port
- *	of a switch chip.
- * int (*ndo_switch_port_stp_update)(struct net_device *dev, u8 state);
- *	Called to notify switch device port of bridge port STP
- *	state change.
- * int (*ndo_sw_parent_fib_ipv4_add)(struct net_device *dev, __be32 dst,
- *				     int dst_len, struct fib_info *fi,
- *				     u8 tos, u8 type, u32 nlflags, u32 tb_id);
- *	Called to add/modify IPv4 route to switch device.
- * int (*ndo_sw_parent_fib_ipv4_del)(struct net_device *dev, __be32 dst,
- *				     int dst_len, struct fib_info *fi,
- *				     u8 tos, u8 type, u32 tb_id);
- *	Called to delete IPv4 route from switch device.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1197,25 +1178,6 @@ struct net_device_ops {
 	netdev_features_t	(*ndo_features_check) (struct sk_buff *skb,
 						       struct net_device *dev,
 						       netdev_features_t features);
-#ifdef CONFIG_NET_SWITCHDEV
-	int			(*ndo_switch_parent_id_get)(struct net_device *dev,
-							    struct netdev_phys_item_id *psid);
-	int			(*ndo_switch_port_stp_update)(struct net_device *dev,
-							      u8 state);
-	int			(*ndo_switch_fib_ipv4_add)(struct net_device *dev,
-							   __be32 dst,
-							   int dst_len,
-							   struct fib_info *fi,
-							   u8 tos, u8 type,
-							   u32 nlflags,
-							   u32 tb_id);
-	int			(*ndo_switch_fib_ipv4_del)(struct net_device *dev,
-							   __be32 dst,
-							   int dst_len,
-							   struct fib_info *fi,
-							   u8 tos, u8 type,
-							   u32 tb_id);
-#endif
 };
 
 /**
-- 
1.7.10.4
