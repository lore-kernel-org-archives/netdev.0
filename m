From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v4 09/10] net: harmonize vxlan_get_rx_port and geneve_get_rx_port to netdev_refresh_offloads
Date: Sat,  9 Jan 2016 16:07:31 +0100
Message-ID: <1452352052-27574-10-git-send-email-hannes@stressinduktion.org>
References: <1452352052-27574-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:40729 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754507AbcAIPHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 10:07:53 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 90F3020A57
	for <netdev@vger.kernel.org>; Sat,  9 Jan 2016 10:07:52 -0500 (EST)
In-Reply-To: <1452352052-27574-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c    | 4 ++--
 drivers/net/ethernet/broadcom/bnxt/bnxt.c           | 2 +-
 drivers/net/ethernet/emulex/benet/be_main.c         | 2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c     | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c         | 7 ++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c       | 4 ++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c      | 2 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c    | 2 +-
 include/linux/netdevice.h                           | 4 ++++
 include/net/geneve.h                                | 5 -----
 include/net/vxlan.h                                 | 5 -----
 12 files changed, 16 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 6c4e3a69976fca..6204154f1f2fe2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10286,7 +10286,7 @@ sp_rtnl_not_reset:
 			netdev_info(bp->dev,
 				    "Deleted vxlan dest port %d", port);
 			bp->vxlan_dst_port = 0;
-			vxlan_get_rx_port(bp->dev);
+			netdev_refresh_offloads(bp->dev);
 		}
 	}
 #endif
@@ -12492,7 +12492,7 @@ static int bnx2x_open(struct net_device *dev)
 
 #ifdef CONFIG_BNX2X_VXLAN
 	if (IS_PF(bp))
-		vxlan_get_rx_port(dev);
+		netdev_refresh_offloads(dev);
 #endif
 
 	return 0;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index f9569493034b4d..1641f94aa315c1 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4637,7 +4637,7 @@ static int __bnxt_open_nic(struct bnxt *bp, bool irq_re_init, bool link_re_init)
 
 	if (irq_re_init) {
 #if defined(CONFIG_VXLAN) || defined(CONFIG_VXLAN_MODULE)
-		vxlan_get_rx_port(bp->dev);
+		netdev_refresh_offloads(bp->dev);
 #endif
 		if (!bnxt_hwrm_tunnel_dst_port_alloc(
 				bp, htons(0x17c1),
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 3200f48ddd5a68..16edce294bbb2b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3601,7 +3601,7 @@ static int be_open(struct net_device *netdev)
 	netif_tx_start_all_queues(netdev);
 #ifdef CONFIG_BE2NET_VXLAN
 	if (skyhawk_chip(adapter))
-		vxlan_get_rx_port(netdev);
+		netdev_refresh_offloads(netdev);
 #endif
 
 	return 0;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 662569d5b7c01a..a2f0775ddd5460 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -558,7 +558,7 @@ int fm10k_open(struct net_device *netdev)
 
 #ifdef CONFIG_FM10K_VXLAN
 	/* update VXLAN port configuration */
-	vxlan_get_rx_port(netdev);
+	netdev_refresh_offloads(netdev);
 #endif
 
 	fm10k_up(interface);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index bb4612c159fd19..0a78cf046df608 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5344,11 +5344,8 @@ int i40e_open(struct net_device *netdev)
 						       TCP_FLAG_CWR) >> 16);
 	wr32(&pf->hw, I40E_GLLAN_TSOMSK_L, be32_to_cpu(TCP_FLAG_CWR) >> 16);
 
-#ifdef CONFIG_I40E_VXLAN
-	vxlan_get_rx_port(netdev);
-#endif
-#ifdef CONFIG_I40E_GENEVE
-	geneve_get_rx_port(netdev);
+#if defined(CONFIG_I40E_VXLAN) || defined(CONFIG_I40E_GENEVE)
+	netdev_refresh_offloads(netdev);
 #endif
 
 	return 0;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 85ec389bd46560..b288b18fa0c6c0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6041,7 +6041,7 @@ static int ixgbe_open(struct net_device *netdev)
 
 	ixgbe_clear_vxlan_port(adapter);
 #ifdef CONFIG_IXGBE_VXLAN
-	vxlan_get_rx_port(netdev);
+	netdev_refresh_offloads(netdev);
 #endif
 
 	return 0;
@@ -7121,7 +7121,7 @@ static void ixgbe_service_task(struct work_struct *work)
 	rtnl_lock();
 	if (adapter->flags2 & IXGBE_FLAG2_VXLAN_REREG_NEEDED) {
 		adapter->flags2 &= ~IXGBE_FLAG2_VXLAN_REREG_NEEDED;
-		vxlan_get_rx_port(adapter->netdev);
+		netdev_refresh_offloads(adapter->netdev);
 	}
 	rtnl_unlock();
 #endif /* CONFIG_IXGBE_VXLAN */
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 94abd0843901cf..4b077d892cf193 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1683,7 +1683,7 @@ int mlx4_en_start_port(struct net_device *dev)
 
 #ifdef CONFIG_MLX4_EN_VXLAN
 	if (priv->mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
-		vxlan_get_rx_port(dev);
+		netdev_refresh_offloads(dev);
 #endif
 	priv->port_up = true;
 	netif_tx_start_all_queues(dev);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 43c618bafdb641..70338327b47550 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1795,7 +1795,7 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 	if (nn->ctrl & NFP_NET_CFG_CTRL_VXLAN) {
 		memset(&nn->vxlan_ports, 0, sizeof(nn->vxlan_ports));
 		memset(&nn->vxlan_usecnt, 0, sizeof(nn->vxlan_usecnt));
-		vxlan_get_rx_port(netdev);
+		netdev_refresh_offloads(netdev);
 	}
 
 	/* Step 3: Enable for kernel
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 1c29105b6c364f..22ba8b7c8db1b1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2017,7 +2017,7 @@ qlcnic_attach(struct qlcnic_adapter *adapter)
 
 #ifdef CONFIG_QLCNIC_VXLAN
 	if (qlcnic_encap_rx_offload(adapter))
-		vxlan_get_rx_port(netdev);
+		netdev_refresh_offloads(netdev);
 #endif
 
 	adapter->is_up = QLCNIC_ADAPTER_UP_MAGIC;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9750e46760695d..4d93d474f1cd44 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2224,6 +2224,10 @@ netdev_notifier_info_to_dev(const struct netdev_notifier_info *info)
 
 int call_netdevice_notifiers(unsigned long val, struct net_device *dev);
 
+static inline void netdev_refresh_offloads(struct net_device *netdev)
+{
+	call_netdevice_notifiers(NETDEV_REFRESH_OFFLOADS, netdev);
+}
 
 extern rwlock_t				dev_base_lock;		/* Device list lock */
 
diff --git a/include/net/geneve.h b/include/net/geneve.h
index 7d52077b72faa3..9e27fc7027052d 100644
--- a/include/net/geneve.h
+++ b/include/net/geneve.h
@@ -64,11 +64,6 @@ struct genevehdr {
 	struct geneve_opt options[];
 };
 
-static inline void geneve_get_rx_port(struct net_device *netdev)
-{
-	call_netdevice_notifiers(NETDEV_REFRESH_OFFLOADS, netdev);
-}
-
 #ifdef CONFIG_INET
 struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 					u8 name_assign_type, u16 dst_port);
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 48d0450160c91f..eb0a7e3368ca1c 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -242,11 +242,6 @@ static inline netdev_features_t vxlan_features_check(struct sk_buff *skb,
 /* IPv6 header + UDP + VXLAN + Ethernet header */
 #define VXLAN6_HEADROOM (40 + 8 + 8 + 14)
 
-static inline void vxlan_get_rx_port(struct net_device *netdev)
-{
-	call_netdevice_notifiers(NETDEV_REFRESH_OFFLOADS, netdev);
-}
-
 static inline unsigned short vxlan_get_sk_family(struct vxlan_sock *vs)
 {
 	return vs->sock->sk->sk_family;
-- 
2.5.0
