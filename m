From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 1/9] net-dev: Convert (hw_/vlan_/wanted_)features fields from u32 type to u64
Date: Fri, 22 Apr 2011 16:35:59 -0700
Message-ID: <1303515367-25595-2-git-send-email-maheshb@google.com>
References: <1303515367-25595-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:35996 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755396Ab1DVXgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 19:36:17 -0400
In-Reply-To: <1303515367-25595-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 include/linux/netdevice.h |   86 ++++++++++++++++++++++----------------------
 net/core/dev.c            |   26 +++++++-------
 2 files changed, 56 insertions(+), 56 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cb8178a..7ec5af5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -877,12 +877,12 @@ struct netdev_tc_txq {
  *	Called to release previously enslaved netdev.
  *
  *      Feature/offload setting functions.
- * u32 (*ndo_fix_features)(struct net_device *dev, u32 features);
+ * u64 (*ndo_fix_features)(struct net_device *dev, u64 features);
  *	Adjusts the requested feature flags according to device-specific
  *	constraints, and returns the resulting flags. Must not modify
  *	the device state.
  *
- * int (*ndo_set_features)(struct net_device *dev, u32 features);
+ * int (*ndo_set_features)(struct net_device *dev, u64 features);
  *	Called to update device configuration to new features. Passed
  *	feature set might be less than what was returned by ndo_fix_features()).
  *	Must return >0 or -errno if it changed dev->features itself.
@@ -974,10 +974,10 @@ struct net_device_ops {
 						 struct net_device *slave_dev);
 	int			(*ndo_del_slave)(struct net_device *dev,
 						 struct net_device *slave_dev);
-	u32			(*ndo_fix_features)(struct net_device *dev,
-						    u32 features);
+	u64			(*ndo_fix_features)(struct net_device *dev,
+						    u64 features);
 	int			(*ndo_set_features)(struct net_device *dev,
-						    u32 features);
+						    u64 features);
 };
 
 /*
@@ -1030,43 +1030,43 @@ struct net_device {
 	struct list_head	unreg_list;
 
 	/* currently active device features */
-	u32			features;
+	u64			features;
 	/* user-changeable features */
-	u32			hw_features;
+	u64			hw_features;
 	/* user-requested features */
-	u32			wanted_features;
+	u64			wanted_features;
 	/* mask of features inheritable by VLAN devices */
-	u32			vlan_features;
+	u64			vlan_features;
 
 	/* Net device feature bits; if you change something,
 	 * also update netdev_features_strings[] in ethtool.c */
 
-#define NETIF_F_SG		1	/* Scatter/gather IO. */
-#define NETIF_F_IP_CSUM		2	/* Can checksum TCP/UDP over IPv4. */
-#define NETIF_F_NO_CSUM		4	/* Does not require checksum. F.e. loopack. */
-#define NETIF_F_HW_CSUM		8	/* Can checksum all the packets. */
-#define NETIF_F_IPV6_CSUM	16	/* Can checksum TCP/UDP over IPV6 */
-#define NETIF_F_HIGHDMA		32	/* Can DMA to high memory. */
-#define NETIF_F_FRAGLIST	64	/* Scatter/gather IO. */
-#define NETIF_F_HW_VLAN_TX	128	/* Transmit VLAN hw acceleration */
-#define NETIF_F_HW_VLAN_RX	256	/* Receive VLAN hw acceleration */
-#define NETIF_F_HW_VLAN_FILTER	512	/* Receive filtering on VLAN */
-#define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
-#define NETIF_F_GSO		2048	/* Enable software GSO. */
-#define NETIF_F_LLTX		4096	/* LockLess TX - deprecated. Please */
-					/* do not use LLTX in new drivers */
-#define NETIF_F_NETNS_LOCAL	8192	/* Does not change network namespaces */
-#define NETIF_F_GRO		16384	/* Generic receive offload */
-#define NETIF_F_LRO		32768	/* large receive offload */
+#define NETIF_F_SG		((u64)1 << 0) /* Scatter/gather IO. */
+#define NETIF_F_IP_CSUM		((u64)1 << 1) /* Can checksum TCP/UDP over IPv4. */
+#define NETIF_F_NO_CSUM		((u64)1 << 2) /* Does not require checksum. F.e. loopack. */
+#define NETIF_F_HW_CSUM		((u64)1 << 3) /* Can checksum all the packets. */
+#define NETIF_F_IPV6_CSUM	((u64)1 << 4) /* Can checksum TCP/UDP over IPV6 */
+#define NETIF_F_HIGHDMA		((u64)1 << 5) /* Can DMA to high memory. */
+#define NETIF_F_FRAGLIST	((u64)1 << 6) /* Scatter/gather IO. */
+#define NETIF_F_HW_VLAN_TX	((u64)1 << 7) /* Transmit VLAN hw acceleration */
+#define NETIF_F_HW_VLAN_RX	((u64)1 << 8) /* Receive VLAN hw acceleration */
+#define NETIF_F_HW_VLAN_FILTER	((u64)1 << 9) /* Receive filtering on VLAN */
+#define NETIF_F_VLAN_CHALLENGED	((u64)1 << 10) /* Device cannot handle VLAN packets */
+#define NETIF_F_GSO		((u64)1 << 11) /* Enable software GSO. */
+#define NETIF_F_LLTX		((u64)1 << 12) /* LockLess TX - deprecated. Please */
+					  /* do not use LLTX in new drivers */
+#define NETIF_F_NETNS_LOCAL	((u64)1 << 13) /* Does not change network namespaces */
+#define NETIF_F_GRO		((u64)1 << 14) /* Generic receive offload */
+#define NETIF_F_LRO		((u64)1 << 15) /* large receive offload */
 
 /* the GSO_MASK reserves bits 16 through 23 */
-#define NETIF_F_FCOE_CRC	(1 << 24) /* FCoE CRC32 */
-#define NETIF_F_SCTP_CSUM	(1 << 25) /* SCTP checksum offload */
-#define NETIF_F_FCOE_MTU	(1 << 26) /* Supports max FCoE MTU, 2158 bytes*/
-#define NETIF_F_NTUPLE		(1 << 27) /* N-tuple filters supported */
-#define NETIF_F_RXHASH		(1 << 28) /* Receive hashing offload */
-#define NETIF_F_RXCSUM		(1 << 29) /* Receive checksumming offload */
-#define NETIF_F_NOCACHE_COPY	(1 << 30) /* Use no-cache copyfromuser */
+#define NETIF_F_FCOE_CRC	((u64)1 << 24) /* FCoE CRC32 */
+#define NETIF_F_SCTP_CSUM	((u64)1 << 25) /* SCTP checksum offload */
+#define NETIF_F_FCOE_MTU	((u64)1 << 26) /* Supports max FCoE MTU, 2158 bytes*/
+#define NETIF_F_NTUPLE		((u64)1 << 27) /* N-tuple filters supported */
+#define NETIF_F_RXHASH		((u64)1 << 28) /* Receive hashing offload */
+#define NETIF_F_RXCSUM		((u64)1 << 29) /* Receive checksumming offload */
+#define NETIF_F_NOCACHE_COPY	((u64)1 << 30) /* Use no-cache copyfromuser */
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
@@ -1541,7 +1541,7 @@ struct packet_type {
 					 struct packet_type *,
 					 struct net_device *);
 	struct sk_buff		*(*gso_segment)(struct sk_buff *skb,
-						u32 features);
+						u64 features);
 	int			(*gso_send_check)(struct sk_buff *skb);
 	struct sk_buff		**(*gro_receive)(struct sk_buff **head,
 					       struct sk_buff *skb);
@@ -2518,7 +2518,7 @@ extern int		netdev_set_master(struct net_device *dev, struct net_device *master)
 extern int netdev_set_bond_master(struct net_device *dev,
 				  struct net_device *master);
 extern int skb_checksum_help(struct sk_buff *skb);
-extern struct sk_buff *skb_gso_segment(struct sk_buff *skb, u32 features);
+extern struct sk_buff *skb_gso_segment(struct sk_buff *skb, u64 features);
 #ifdef CONFIG_BUG
 extern void netdev_rx_csum_fault(struct net_device *dev);
 #else
@@ -2545,33 +2545,33 @@ extern char *netdev_drivername(const struct net_device *dev, char *buffer, int l
 
 extern void linkwatch_run_queue(void);
 
-static inline u32 netdev_get_wanted_features(struct net_device *dev)
+static inline u64 netdev_get_wanted_features(struct net_device *dev)
 {
 	return (dev->features & ~dev->hw_features) | dev->wanted_features;
 }
-u32 netdev_increment_features(u32 all, u32 one, u32 mask);
-u32 netdev_fix_features(struct net_device *dev, u32 features);
+u64 netdev_increment_features(u64 all, u64 one, u64 mask);
+u64 netdev_fix_features(struct net_device *dev, u64 features);
 int __netdev_update_features(struct net_device *dev);
 void netdev_update_features(struct net_device *dev);
 
 void netif_stacked_transfer_operstate(const struct net_device *rootdev,
 					struct net_device *dev);
 
-u32 netif_skb_features(struct sk_buff *skb);
+u64 netif_skb_features(struct sk_buff *skb);
 
-static inline int net_gso_ok(u32 features, int gso_type)
+static inline u64 net_gso_ok(u64 features, int gso_type)
 {
-	int feature = gso_type << NETIF_F_GSO_SHIFT;
+	u64 feature = (u64)gso_type << NETIF_F_GSO_SHIFT;
 	return (features & feature) == feature;
 }
 
-static inline int skb_gso_ok(struct sk_buff *skb, u32 features)
+static inline int skb_gso_ok(struct sk_buff *skb, u64 features)
 {
 	return net_gso_ok(features, skb_shinfo(skb)->gso_type) &&
 	       (!skb_has_frag_list(skb) || (features & NETIF_F_FRAGLIST));
 }
 
-static inline int netif_needs_gso(struct sk_buff *skb, int features)
+static inline int netif_needs_gso(struct sk_buff *skb, u64 features)
 {
 	return skb_is_gso(skb) && (!skb_gso_ok(skb, features) ||
 		unlikely(skb->ip_summed != CHECKSUM_PARTIAL));
diff --git a/net/core/dev.c b/net/core/dev.c
index 379c993..73d96e5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1840,7 +1840,7 @@ EXPORT_SYMBOL(skb_checksum_help);
  *	It may return NULL if the skb requires no segmentation.  This is
  *	only possible when GSO is used for verifying header integrity.
  */
-struct sk_buff *skb_gso_segment(struct sk_buff *skb, u32 features)
+struct sk_buff *skb_gso_segment(struct sk_buff *skb, u64 features)
 {
 	struct sk_buff *segs = ERR_PTR(-EPROTONOSUPPORT);
 	struct packet_type *ptype;
@@ -1978,7 +1978,7 @@ static void dev_gso_skb_destructor(struct sk_buff *skb)
  *	This function segments the given skb and stores the list of segments
  *	in skb->next.
  */
-static int dev_gso_segment(struct sk_buff *skb, int features)
+static int dev_gso_segment(struct sk_buff *skb, u64 features)
 {
 	struct sk_buff *segs;
 
@@ -2017,7 +2017,7 @@ static inline void skb_orphan_try(struct sk_buff *skb)
 	}
 }
 
-static bool can_checksum_protocol(unsigned long features, __be16 protocol)
+static bool can_checksum_protocol(u64 features, __be16 protocol)
 {
 	return ((features & NETIF_F_GEN_CSUM) ||
 		((features & NETIF_F_V4_CSUM) &&
@@ -2028,7 +2028,7 @@ static bool can_checksum_protocol(unsigned long features, __be16 protocol)
 		 protocol == htons(ETH_P_FCOE)));
 }
 
-static u32 harmonize_features(struct sk_buff *skb, __be16 protocol, u32 features)
+static u64 harmonize_features(struct sk_buff *skb, __be16 protocol, u64 features)
 {
 	if (!can_checksum_protocol(features, protocol)) {
 		features &= ~NETIF_F_ALL_CSUM;
@@ -2040,10 +2040,10 @@ static u32 harmonize_features(struct sk_buff *skb, __be16 protocol, u32 features
 	return features;
 }
 
-u32 netif_skb_features(struct sk_buff *skb)
+u64 netif_skb_features(struct sk_buff *skb)
 {
 	__be16 protocol = skb->protocol;
-	u32 features = skb->dev->features;
+	u64 features = skb->dev->features;
 
 	if (protocol == htons(ETH_P_8021Q)) {
 		struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
@@ -2072,7 +2072,7 @@ EXPORT_SYMBOL(netif_skb_features);
  *	   support DMA from it.
  */
 static inline int skb_needs_linearize(struct sk_buff *skb,
-				      int features)
+				      u64 features)
 {
 	return skb_is_nonlinear(skb) &&
 			((skb_has_frag_list(skb) &&
@@ -2088,7 +2088,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 	int rc = NETDEV_TX_OK;
 
 	if (likely(!skb->next)) {
-		u32 features;
+		u64 features;
 
 		/*
 		 * If device doesn't need skb->dst, release it right now while
@@ -5185,7 +5185,7 @@ static void rollback_registered(struct net_device *dev)
 	list_del(&single);
 }
 
-u32 netdev_fix_features(struct net_device *dev, u32 features)
+u64 netdev_fix_features(struct net_device *dev, u64 features)
 {
 	/* Fix illegal checksum combinations */
 	if ((features & NETIF_F_HW_CSUM) &&
@@ -5248,7 +5248,7 @@ EXPORT_SYMBOL(netdev_fix_features);
 
 int __netdev_update_features(struct net_device *dev)
 {
-	u32 features;
+	u64 features;
 	int err = 0;
 
 	ASSERT_RTNL();
@@ -5264,7 +5264,7 @@ int __netdev_update_features(struct net_device *dev)
 	if (dev->features == features)
 		return 0;
 
-	netdev_info(dev, "Features changed: 0x%08x -> 0x%08x\n",
+	netdev_info(dev, "Features changed: 0x%016x -> 0x%016x\n",
 		dev->features, features);
 
 	if (dev->netdev_ops->ndo_set_features)
@@ -5272,7 +5272,7 @@ int __netdev_update_features(struct net_device *dev)
 
 	if (unlikely(err < 0)) {
 		netdev_err(dev,
-			"set_features() failed (%d); wanted 0x%08x, left 0x%08x\n",
+			"set_features() failed (%d); wanted 0x%016x, left 0x%016x\n",
 			err, features, dev->features);
 		return -1;
 	}
@@ -6182,7 +6182,7 @@ static int dev_cpu_callback(struct notifier_block *nfb,
  *	@one to the master device with current feature set @all.  Will not
  *	enable anything that is off in @mask. Returns the new feature set.
  */
-u32 netdev_increment_features(u32 all, u32 one, u32 mask)
+u64 netdev_increment_features(u64 all, u64 one, u64 mask)
 {
 	/* If device needs checksumming, downgrade to it. */
 	if (all & NETIF_F_NO_CSUM && !(one & NETIF_F_NO_CSUM))
-- 
1.7.3.1

