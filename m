From: sfeldma@gmail.com
Subject: [PATCH net-next v4 2/8] netdevice: add IPv4 fib add/del ops
Date: Thu,  5 Mar 2015 21:21:14 -0800
Message-ID: <1425619280-27492-3-git-send-email-sfeldma@gmail.com>
References: <1425619280-27492-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	roopa@cumulusnetworks.com, alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:44464 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753242AbbCFFUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 00:20:37 -0500
Received: by pdjz10 with SMTP id z10so21308681pdj.11
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 21:20:36 -0800 (PST)
In-Reply-To: <1425619280-27492-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Add two new ndo ops for IPv4 fib offload support, add and del.  Add uses
modifiy semantics if fib entry already offloaded.  Drivers implementing the new
ndo ops will return err<0 if programming device fails, for example if device's
tables are full.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/linux/netdevice.h |   22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 625c8d7..4541378 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -768,6 +768,8 @@ struct netdev_phys_item_id {
 typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
 				       struct sk_buff *skb);
 
+struct fib_info;
+
 /*
  * This structure defines the management hooks for network devices.
  * The following hooks can be defined; unless noted otherwise, they are
@@ -1031,6 +1033,14 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  * int (*ndo_switch_port_stp_update)(struct net_device *dev, u8 state);
  *	Called to notify switch device port of bridge port STP
  *	state change.
+ * int (*ndo_sw_parent_fib_ipv4_add)(struct net_device *dev, __be32 dst,
+ *				     int dst_len, struct fib_info *fi,
+ *				     u8 tos, u8 type, u32 tb_id);
+ *	Called to add/modify IPv4 route to switch device.
+ * int (*ndo_sw_parent_fib_ipv4_del)(struct net_device *dev, __be32 dst,
+ *				     int dst_len, struct fib_info *fi,
+ *				     u8 tos, u8 type, u32 tb_id);
+ *	Called to delete IPv4 route from switch device.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1192,6 +1202,18 @@ struct net_device_ops {
 							    struct netdev_phys_item_id *psid);
 	int			(*ndo_switch_port_stp_update)(struct net_device *dev,
 							      u8 state);
+	int			(*ndo_switch_fib_ipv4_add)(struct net_device *dev,
+							   __be32 dst,
+							   int dst_len,
+							   struct fib_info *fi,
+							   u8 tos, u8 type,
+							   u32 tb_id);
+	int			(*ndo_switch_fib_ipv4_del)(struct net_device *dev,
+							   __be32 dst,
+							   int dst_len,
+							   struct fib_info *fi,
+							   u8 tos, u8 type,
+							   u32 tb_id);
 #endif
 };
 
-- 
1.7.10.4
