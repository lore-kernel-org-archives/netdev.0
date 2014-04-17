From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC v3 02/10] net: rename netdev_phys_port_id to more generic name
Date: Thu, 17 Apr 2014 14:14:29 +0200
Message-ID: <1397736876-11771-3-git-send-email-jiri@resnulli.us>
References: <1397736876-11771-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:56822 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161233AbaDQMOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2014 08:14:53 -0400
Received: by mail-ee0-f50.google.com with SMTP id c13so596039eek.37
        for <netdev@vger.kernel.org>; Thu, 17 Apr 2014 05:14:52 -0700 (PDT)
In-Reply-To: <1397736876-11771-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So this can be reused for identification of other "items" as well.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |  2 +-
 include/linux/netdevice.h                        | 16 ++++++++--------
 net/core/dev.c                                   |  2 +-
 net/core/net-sysfs.c                             |  2 +-
 net/core/rtnetlink.c                             |  6 +++---
 7 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index a78edac..a4b25b1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12360,7 +12360,7 @@ static int bnx2x_validate_addr(struct net_device *dev)
 }
 
 static int bnx2x_get_phys_port_id(struct net_device *netdev,
-				  struct netdev_phys_port_id *ppid)
+				  struct netdev_phys_item_id *ppid)
 {
 	struct bnx2x *bp = netdev_priv(netdev);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index f085c2d..e784bb4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2251,7 +2251,7 @@ static int mlx4_en_set_vf_link_state(struct net_device *dev, int vf, int link_st
 
 #define PORT_ID_BYTE_LEN 8
 static int mlx4_en_get_phys_port_id(struct net_device *dev,
-				    struct netdev_phys_port_id *ppid)
+				    struct netdev_phys_item_id *ppid)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_dev *mdev = priv->mdev->dev;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 309d056..55af16a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -450,7 +450,7 @@ static void qlcnic_82xx_cancel_idc_work(struct qlcnic_adapter *adapter)
 }
 
 static int qlcnic_get_phys_port_id(struct net_device *netdev,
-				   struct netdev_phys_port_id *ppid)
+				   struct netdev_phys_item_id *ppid)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 775cc95..8cf4f5e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -735,13 +735,13 @@ struct netdev_fcoe_hbainfo {
 };
 #endif
 
-#define MAX_PHYS_PORT_ID_LEN 32
+#define MAX_PHYS_ITEM_ID_LEN 32
 
-/* This structure holds a unique identifier to identify the
- * physical port used by a netdevice.
+/* This structure holds a unique identifier to identify some
+ * physical item (port for example) used by a netdevice.
  */
-struct netdev_phys_port_id {
-	unsigned char id[MAX_PHYS_PORT_ID_LEN];
+struct netdev_phys_item_id {
+	unsigned char id[MAX_PHYS_ITEM_ID_LEN];
 	unsigned char id_len;
 };
 
@@ -955,7 +955,7 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	USB_CDC_NOTIFY_NETWORK_CONNECTION) should NOT implement this function.
  *
  * int (*ndo_get_phys_port_id)(struct net_device *dev,
- *			       struct netdev_phys_port_id *ppid);
+ *			       struct netdev_phys_item_id *ppid);
  *	Called to get ID of physical port of this device. If driver does
  *	not implement this, it is assumed that the hw is not able to have
  *	multiple net devices on single physical port.
@@ -1121,7 +1121,7 @@ struct net_device_ops {
 	int			(*ndo_change_carrier)(struct net_device *dev,
 						      bool new_carrier);
 	int			(*ndo_get_phys_port_id)(struct net_device *dev,
-							struct netdev_phys_port_id *ppid);
+							struct netdev_phys_item_id *ppid);
 	void			(*ndo_add_vxlan_port)(struct  net_device *dev,
 						      sa_family_t sa_family,
 						      __be16 port);
@@ -2616,7 +2616,7 @@ void dev_set_group(struct net_device *, int);
 int dev_set_mac_address(struct net_device *, struct sockaddr *);
 int dev_change_carrier(struct net_device *, bool new_carrier);
 int dev_get_phys_port_id(struct net_device *dev,
-			 struct netdev_phys_port_id *ppid);
+			 struct netdev_phys_item_id *ppid);
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq);
 int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index 7570634..a0de81c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5512,7 +5512,7 @@ EXPORT_SYMBOL(dev_change_carrier);
  *	Get device physical port ID
  */
 int dev_get_phys_port_id(struct net_device *dev,
-			 struct netdev_phys_port_id *ppid)
+			 struct netdev_phys_item_id *ppid)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 1cac29e..c64426e 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -368,7 +368,7 @@ static ssize_t phys_port_id_show(struct device *dev,
 		return restart_syscall();
 
 	if (dev_isalive(netdev)) {
-		struct netdev_phys_port_id ppid;
+		struct netdev_phys_item_id ppid;
 
 		ret = dev_get_phys_port_id(netdev, &ppid);
 		if (!ret)
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d4ff417..231e043 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -829,7 +829,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + rtnl_port_size(dev) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
 	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
 	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
-	       + nla_total_size(MAX_PHYS_PORT_ID_LEN); /* IFLA_PHYS_PORT_ID */
+	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN); /* IFLA_PHYS_PORT_ID */
 }
 
 static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
@@ -911,7 +911,7 @@ static int rtnl_port_fill(struct sk_buff *skb, struct net_device *dev)
 static int rtnl_phys_port_id_fill(struct sk_buff *skb, struct net_device *dev)
 {
 	int err;
-	struct netdev_phys_port_id ppid;
+	struct netdev_phys_item_id ppid;
 
 	err = dev_get_phys_port_id(dev, &ppid);
 	if (err) {
@@ -1149,7 +1149,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_PROMISCUITY]	= { .type = NLA_U32 },
 	[IFLA_NUM_TX_QUEUES]	= { .type = NLA_U32 },
 	[IFLA_NUM_RX_QUEUES]	= { .type = NLA_U32 },
-	[IFLA_PHYS_PORT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_PORT_ID_LEN },
+	[IFLA_PHYS_PORT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
 	[IFLA_CARRIER_CHANGES]	= { .type = NLA_U32 },  /* ignored */
 };
 
-- 
1.9.0
