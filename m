From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 2/6 v4] net: Add netdev_ops to set and get
	MAC/VLAN rx filters
Date: Tue, 08 Nov 2011 23:55:45 -0800
Message-ID: <20111109075545.13549.64199.stgit@rhel6.1>
References: <20111109075449.13549.58135.stgit@rhel6.1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: chrisw@redhat.com, sri@us.ibm.com, dragos.tatulea@gmail.com,
	kvm@vger.kernel.org, arnd@arndb.de, mst@redhat.com,
	gregory.v.rose@intel.com, mchan@broadcom.com, dwang2@cisco.com,
	shemminger@vyatta.com, eric.dumazet@gmail.com, kaber@trash.net,
	benve@cisco.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-1.cisco.com ([173.36.130.12]:15073 "EHLO
	mtv-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932781Ab1KHX7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 18:59:20 -0500
In-Reply-To: <20111109075449.13549.58135.stgit@rhel6.1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch adds the following netdev_ops to set and get MAC/VLAN
filters on a SRIOV VF or any netdev interface. Each op takes a vf argument.
vf value of SELF_VF or -1 is for applying the operation directly on the
interface.

ndo_set_rx_filter_addr - to set address filter
ndo_get_rx_filter_addr_size - to get address filter size
ndo_get_rx_filter_addr - To get addr filter

ndo_set_rx_filter_vlan - to set vlan filter
ndo_get_rx_filter_vlan_size - to get vlan filter size
ndo_get_rx_filter_vlan - To get vlan filter

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 include/linux/netdevice.h |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+), 0 deletions(-)


diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cbeb586..3cbd700 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -855,6 +855,20 @@ struct netdev_tc_txq {
  *	feature set might be less than what was returned by ndo_fix_features()).
  *	Must return >0 or -errno if it changed dev->features itself.
  *
+ * Address Filter management functions:
+ * int (*ndo_set_rx_filter_addr)(struct net_device *dev, int vf,
+ *				 struct nlattr *tb[]);
+ * size_t (*ndo_get_rx_filter_addr_size)(const struct net_device *dev, int vf);
+ * int (*ndo_get_rx_filter_addr)(const struct net_device *dev, int vf,
+ *				 struct sk_buff *skb);
+ *
+ * Vlan Filter management functions:
+ * int (*ndo_set_rx_filter_vlan)(struct net_device *dev, int vf,
+ *				 struct nlattr *tb[]);
+ * size_t (*ndo_get_rx_filter_vlan_size)(const struct net_device *dev, int vf);
+ * int (*ndo_get_rx_filter_vlan)(const struct net_device *dev, int vf,
+ *				 struct sk_buff *skb);
+ *
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -948,6 +962,24 @@ struct net_device_ops {
 						    u32 features);
 	int			(*ndo_set_features)(struct net_device *dev,
 						    u32 features);
+	int			(*ndo_set_rx_filter_addr)(
+						struct net_device *dev, int vf,
+						struct nlattr *tb[]);
+	size_t			(*ndo_get_rx_filter_addr_size)(
+						const struct net_device *dev,
+						int vf);
+	int			(*ndo_get_rx_filter_addr)(
+						const struct net_device *dev,
+						int vf, struct sk_buff *skb);
+	int			(*ndo_set_rx_filter_vlan)(
+						struct net_device *dev, int vf,
+						struct nlattr *tb[]);
+	size_t			(*ndo_get_rx_filter_vlan_size)(
+						const struct net_device *dev,
+						int vf);
+	int			(*ndo_get_rx_filter_vlan)(
+						const struct net_device *dev,
+						int vf, struct sk_buff *skb);
 };
 
 /*
