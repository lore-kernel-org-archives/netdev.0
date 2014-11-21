From: roopa@cumulusnetworks.com
Subject: [RFC PATCH 3/4] swdevice: new generic op to set bridge port attr
Date: Fri, 21 Nov 2014 14:49:29 -0800
Message-ID: <1416610170-21224-4-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shrijeet@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	vyasevic@redhat.com, f.fainelli@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:36880 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752667AbaKUWtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 17:49:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

A generic switch device op to offload any type of bridge port attribute.

(This is still TBD)
---
 include/net/switchdev.h   |    8 +++++++-
 net/switchdev/switchdev.c |   17 +++++++++++++++++
 2 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index a9ccfa4..c97994d 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -145,7 +145,8 @@ int netdev_sw_parent_flow_insert(struct net_device *dev,
 				 const struct swdev_flow *flow);
 int netdev_sw_parent_flow_remove(struct net_device *dev,
 				 const struct swdev_flow *flow);
-
+int netdev_sw_port_set_attr(struct net_device *dev, int attrtype,
+                            void *attrval);
 #else
 
 static inline int netdev_sw_parent_id_get(struct net_device *dev,
@@ -202,6 +203,11 @@ static inline int netdev_sw_parent_flow_remove(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static int netdev_sw_port_set_attr(struct net_device *dev, int attrtype,
+                                   void *attrval)
+{
+	return -EOPNOTSUPP;
+}
 #endif
 
 #endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index dc8e769..48f451b 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -314,3 +314,20 @@ int netdev_sw_parent_flow_remove(struct net_device *dev,
 	return ops->ndo_sw_parent_flow_remove(dev, flow);
 }
 EXPORT_SYMBOL(netdev_sw_parent_flow_remove);
+
+/**
+ *	netdev_sw_port_set_attr - set a port attr
+ *	@dev: port device
+ *	@attrttype: netlink attribute
+ *	@attrval: attribute value
+ *
+ *	Set switch port attribute
+ */
+int netdev_sw_port_set_attr(struct net_device *dev,
+					int attrttype, void *attrval)
+{
+	/* XXX: yet to be implemented */
+
+	return 0;
+}
+EXPORT_SYMBOL(netdev_sw_port_set_attr);
-- 
1.7.10.4
