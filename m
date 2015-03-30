From: sfeldma@gmail.com
Subject: [PATCH net-next 01/18] switchdev: introduce get/set attrs ops
Date: Mon, 30 Mar 2015 01:40:19 -0700
Message-ID: <1427704836-8776-2-git-send-email-sfeldma@gmail.com>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:34916 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122AbbC3Ijq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 04:39:46 -0400
Received: by pddn5 with SMTP id n5so52846486pdd.2
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 01:39:45 -0700 (PDT)
In-Reply-To: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Add two new swdev ops for get/set switch port attributes.  We'll flesh these
out in the next patch.  Most swdev interactions on a port are gets or sets on
port attributes, so rather than adding ops for each attribute, let's define
clean get/set ops for all attributes, and then we can have clear, consistent
rules on how attributes propagate on stacked devs.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |   30 ++++++++++++++++++++++++++++++
 net/switchdev/switchdev.c |   24 ++++++++++++++++++++++++
 2 files changed, 54 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index d2e69ee..7b72a4f 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -14,6 +14,14 @@
 #include <linux/netdevice.h>
 #include <linux/notifier.h>
 
+enum swdev_attr_id {
+	SWDEV_ATTR_UNDEFINED,
+};
+
+struct swdev_attr {
+	enum swdev_attr_id attr;
+};
+
 struct fib_info;
 
 /**
@@ -23,6 +31,10 @@ struct fib_info;
  *   is part of.  If driver implements this, it indicates that it
  *   represents a port of a switch chip.
  *
+ * @swdev_port_attr_get: Get a port attribute (see swdev_attr).
+ *
+ * @swdev_port_attr_set: Set a port attribute (see swdev_attr).
+ *
  * @swdev_port_stp_update: Called to notify switch device port of bridge
  *   port STP state change.
  *
@@ -33,6 +45,10 @@ struct fib_info;
 struct swdev_ops {
 	int	(*swdev_parent_id_get)(struct net_device *dev,
 				       struct netdev_phys_item_id *psid);
+	int	(*swdev_port_attr_get)(struct net_device *dev,
+				       struct swdev_attr *attr);
+	int	(*swdev_port_attr_set)(struct net_device *dev,
+				       struct swdev_attr *attr);
 	int	(*swdev_port_stp_update)(struct net_device *dev, u8 state);
 	int	(*swdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
 				      int dst_len, struct fib_info *fi,
@@ -68,6 +84,8 @@ netdev_switch_notifier_info_to_dev(const struct netdev_switch_notifier_info *inf
 
 int netdev_switch_parent_id_get(struct net_device *dev,
 				struct netdev_phys_item_id *psid);
+int swdev_port_attr_get(struct net_device *dev, struct swdev_attr *attr);
+int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr);
 int netdev_switch_port_stp_update(struct net_device *dev, u8 state);
 int register_netdev_switch_notifier(struct notifier_block *nb);
 int unregister_netdev_switch_notifier(struct notifier_block *nb);
@@ -95,6 +113,18 @@ static inline int netdev_switch_parent_id_get(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static inline int swdev_port_attr_get(struct net_device *dev,
+				      enum swdev_attr *attr)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int swdev_port_attr_set(struct net_device *dev,
+				      enum swdev_attr *attr)
+{
+	return -EOPNOTSUPP;
+}
+
 static inline int netdev_switch_port_stp_update(struct net_device *dev,
 						u8 state)
 {
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 46568b8..a894fa5 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -37,6 +37,30 @@ int netdev_switch_parent_id_get(struct net_device *dev,
 EXPORT_SYMBOL_GPL(netdev_switch_parent_id_get);
 
 /**
+ *	swdev_port_attr_get - Get port attribute
+ *
+ *	@dev: port device
+ *	@attr: attribute to get
+ */
+int swdev_port_attr_get(struct net_device *dev, struct swdev_attr *attr)
+{
+	return -EOPNOTSUPP;
+}
+EXPORT_SYMBOL_GPL(swdev_port_attr_get);
+
+/**
+ *	swdev_port_attr_set - Set port attribute
+ *
+ *	@dev: port device
+ *	@attr: attribute to set
+ */
+int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
+{
+	return -EOPNOTSUPP;
+}
+EXPORT_SYMBOL_GPL(swdev_port_attr_set);
+
+/**
  *	netdev_switch_port_stp_update - Notify switch device port of STP
  *					state change
  *	@dev: port device
-- 
1.7.10.4
