From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 4/8] net: Rename NETIF_F_ALL_CSUM to NETIF_F_CSUM_MASK
Date: Mon, 14 Dec 2015 11:19:43 -0800
Message-ID: <1450120787-1773171-5-git-send-email-tom@herbertland.com>
References: <1450120787-1773171-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:48810 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932088AbbLNTUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 14:20:45 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tBEJJWIR021630
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 11:20:44 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1ysvw6abm0-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 11:20:44 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 c2918b9aa29711e593540002c99293a0-b11f8210 for <netdev@vger.kernel.org>;	Mon,
 14 Dec 2015 11:20:41 -0800
In-Reply-To: <1450120787-1773171-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The name NETIF_F_ALL_CSUM is a misnomer. This does not correspond to the
set of features for offloading all checksums. This a mask of the
checksum offload related features bits. It is incorrect to set both
NETIF_F_HW_CSUM and NETIF_F_IP_CSUM or NETIF_F_IPV6 at the same time for
features of a device.

This patch:
  - Changes instances of NETIF_F_ALL_CSUM to NETIF_F_CSUM_MASK (where
    NETIF_F_ALL_CSUM is being used as a mask).
  - Changes bonding, sfc/efx, ipvlan, macvlan, vlan, and team drivers to
    use NEITF_F_HW_CSUM in features list instead of NETIF_F_ALL_CSUM.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/bonding/bond_main.c                         |  7 +++----
 drivers/net/ethernet/emulex/benet/be_main.c             |  2 +-
 drivers/net/ethernet/ibm/ibmveth.c                      |  5 +++--
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c         |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c             |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c           |  2 +-
 drivers/net/ethernet/jme.c                              |  2 +-
 drivers/net/ethernet/marvell/sky2.c                     |  2 +-
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c   |  2 +-
 drivers/net/ethernet/sfc/efx.c                          |  2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c       |  4 ++--
 drivers/net/ipvlan/ipvlan_main.c                        |  2 +-
 drivers/net/macvlan.c                                   |  2 +-
 drivers/net/macvtap.c                                   |  2 +-
 drivers/net/team/team.c                                 |  3 +--
 drivers/net/usb/r8152.c                                 |  2 +-
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c |  2 +-
 include/linux/netdev_features.h                         |  7 ++++++-
 include/linux/netdevice.h                               |  6 +++---
 include/net/vxlan.h                                     |  2 +-
 net/8021q/vlan_dev.c                                    |  2 +-
 net/core/dev.c                                          | 10 +++++-----
 net/core/ethtool.c                                      |  2 +-
 net/ipv4/tcp.c                                          |  4 ++--
 24 files changed, 41 insertions(+), 37 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index fe0e7a6..cab99fd 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1067,12 +1067,12 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
 	return features;
 }
 
-#define BOND_VLAN_FEATURES	(NETIF_F_ALL_CSUM | NETIF_F_SG | \
+#define BOND_VLAN_FEATURES	(NETIF_F_HW_CSUM | NETIF_F_SG | \
 				 NETIF_F_FRAGLIST | NETIF_F_ALL_TSO | \
 				 NETIF_F_HIGHDMA | NETIF_F_LRO)
 
-#define BOND_ENC_FEATURES	(NETIF_F_ALL_CSUM | NETIF_F_SG | NETIF_F_RXCSUM |\
-				 NETIF_F_ALL_TSO)
+#define BOND_ENC_FEATURES	(NETIF_F_HW_CSUM | NETIF_F_SG | \
+				 NETIF_F_RXCSUM | NETIF_F_ALL_TSO)
 
 static void bond_compute_features(struct bonding *bond)
 {
@@ -4182,7 +4182,6 @@ void bond_setup(struct net_device *bond_dev)
 				NETIF_F_HW_VLAN_CTAG_RX |
 				NETIF_F_HW_VLAN_CTAG_FILTER;
 
-	bond_dev->hw_features &= ~(NETIF_F_ALL_CSUM & ~NETIF_F_HW_CSUM);
 	bond_dev->hw_features |= NETIF_F_GSO_ENCAP_ALL;
 	bond_dev->features |= bond_dev->hw_features;
 }
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 4cab887..34e324f 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -5289,7 +5289,7 @@ static netdev_features_t be_features_check(struct sk_buff *skb,
 	    skb->inner_protocol != htons(ETH_P_TEB) ||
 	    skb_inner_mac_header(skb) - skb_transport_header(skb) !=
 	    sizeof(struct udphdr) + sizeof(struct vxlanhdr))
-		return features & ~(NETIF_F_ALL_CSUM | NETIF_F_GSO_MASK);
+		return features & ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
 
 	return features;
 }
diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 7af870a..6691b5a 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -763,7 +763,7 @@ static netdev_features_t ibmveth_fix_features(struct net_device *dev,
 	 */
 
 	if (!(features & NETIF_F_RXCSUM))
-		features &= ~NETIF_F_ALL_CSUM;
+		features &= ~NETIF_F_CSUM_MASK;
 
 	return features;
 }
@@ -928,7 +928,8 @@ static int ibmveth_set_features(struct net_device *dev,
 		rc1 = ibmveth_set_csum_offload(dev, rx_csum);
 		if (rc1 && !adapter->rx_csum)
 			dev->features =
-				features & ~(NETIF_F_ALL_CSUM | NETIF_F_RXCSUM);
+				features & ~(NETIF_F_CSUM_MASK |
+					     NETIF_F_RXCSUM);
 	}
 
 	if (large_send != adapter->large_send) {
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 79f6b7d..d4d23b3 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1355,7 +1355,7 @@ static netdev_features_t fm10k_features_check(struct sk_buff *skb,
 	if (!skb->encapsulation || fm10k_tx_encap_offload(skb))
 		return features;
 
-	return features & ~(NETIF_F_ALL_CSUM | NETIF_F_GSO_MASK);
+	return features & ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
 }
 
 static const struct net_device_ops fm10k_netdev_ops = {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 6faa998..701aa5a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8720,7 +8720,7 @@ static netdev_features_t i40e_features_check(struct sk_buff *skb,
 	if (skb->encapsulation &&
 	    (skb_inner_mac_header(skb) - skb_transport_header(skb) >
 	     I40E_MAX_TUNNEL_HDR_LEN))
-		return features & ~(NETIF_F_ALL_CSUM | NETIF_F_GSO_MASK);
+		return features & ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
 
 	return features;
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 62c7c8b..5edaec9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8432,7 +8432,7 @@ ixgbe_features_check(struct sk_buff *skb, struct net_device *dev,
 
 	if (unlikely(skb_inner_mac_header(skb) - skb_transport_header(skb) >
 		     IXGBE_MAX_TUNNEL_HDR_LEN))
-		return features & ~NETIF_F_ALL_CSUM;
+		return features & ~NETIF_F_CSUM_MASK;
 
 	return features;
 }
diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 060dd39..b1de7af 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -2753,7 +2753,7 @@ static netdev_features_t
 jme_fix_features(struct net_device *netdev, netdev_features_t features)
 {
 	if (netdev->mtu > 1900)
-		features &= ~(NETIF_F_ALL_TSO | NETIF_F_ALL_CSUM);
+		features &= ~(NETIF_F_ALL_TSO | NETIF_F_CSUM_MASK);
 	return features;
 }
 
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 5606a04..ec0a221 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -4380,7 +4380,7 @@ static netdev_features_t sky2_fix_features(struct net_device *dev,
 	 */
 	if (dev->mtu > ETH_DATA_LEN && hw->chip_id == CHIP_ID_YUKON_EC_U) {
 		netdev_info(dev, "checksum offload not possible with jumbo frames\n");
-		features &= ~(NETIF_F_TSO|NETIF_F_SG|NETIF_F_ALL_CSUM);
+		features &= ~(NETIF_F_TSO | NETIF_F_SG | NETIF_F_CSUM_MASK);
 	}
 
 	/* Some hardware requires receive checksum for RSS to work. */
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c
index 08d4be6..e097e6b 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c
@@ -500,7 +500,7 @@ void pch_gbe_check_options(struct pch_gbe_adapter *adapter)
 		val = XsumTX;
 		pch_gbe_validate_option(&val, &opt, adapter);
 		if (!val)
-			dev->features &= ~NETIF_F_ALL_CSUM;
+			dev->features &= ~NETIF_F_CSUM_MASK;
 	}
 	{ /* Flow Control */
 		static const struct pch_gbe_option opt = {
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index b405349..1fe13c7 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -3131,7 +3131,7 @@ static int efx_pci_probe(struct pci_dev *pci_dev,
 	if (efx->type->offload_features & NETIF_F_V6_CSUM)
 		net_dev->features |= NETIF_F_TSO6;
 	/* Mask for features that also apply to VLAN devices */
-	net_dev->vlan_features |= (NETIF_F_ALL_CSUM | NETIF_F_SG |
+	net_dev->vlan_features |= (NETIF_F_HW_CSUM | NETIF_F_SG |
 				   NETIF_F_HIGHDMA | NETIF_F_ALL_TSO |
 				   NETIF_F_RXCSUM);
 	/* All offloads can be toggled */
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 3c6549a..0b0fea7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2402,7 +2402,7 @@ static netdev_features_t stmmac_fix_features(struct net_device *dev,
 		features &= ~NETIF_F_RXCSUM;
 
 	if (!priv->plat->tx_coe)
-		features &= ~NETIF_F_ALL_CSUM;
+		features &= ~NETIF_F_CSUM_MASK;
 
 	/* Some GMAC devices have a bugged Jumbo frame support that
 	 * needs to have the Tx COE disabled for oversized frames
@@ -2410,7 +2410,7 @@ static netdev_features_t stmmac_fix_features(struct net_device *dev,
 	 * the TX csum insertionin the TDES and not use SF.
 	 */
 	if (priv->plat->bugged_jumbo && (dev->mtu > ETH_DATA_LEN))
-		features &= ~NETIF_F_ALL_CSUM;
+		features &= ~NETIF_F_CSUM_MASK;
 
 	return features;
 }
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index a9268db..f94392d 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -88,7 +88,7 @@ static struct lock_class_key ipvlan_netdev_xmit_lock_key;
 static struct lock_class_key ipvlan_netdev_addr_lock_key;
 
 #define IPVLAN_FEATURES \
-	(NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
+	(NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
 	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_GSO_ROBUST | \
 	 NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_GRO | NETIF_F_RXCSUM | \
 	 NETIF_F_HW_VLAN_CTAG_FILTER | NETIF_F_HW_VLAN_STAG_FILTER)
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 06c8bfe..ae3b486 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -762,7 +762,7 @@ static struct lock_class_key macvlan_netdev_addr_lock_key;
 	 NETIF_F_GSO_ROBUST)
 
 #define MACVLAN_FEATURES \
-	(NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
+	(NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
 	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_LRO | \
 	 NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_GRO | NETIF_F_RXCSUM | \
 	 NETIF_F_HW_VLAN_CTAG_FILTER | NETIF_F_HW_VLAN_STAG_FILTER)
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 0fc5219..d636d05 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -388,7 +388,7 @@ static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
 		 *        check, we either support them all or none.
 		 */
 		if (skb->ip_summed == CHECKSUM_PARTIAL &&
-		    !(features & NETIF_F_ALL_CSUM) &&
+		    !(features & NETIF_F_CSUM_MASK) &&
 		    skb_checksum_help(skb))
 			goto drop;
 		skb_queue_tail(&q->sk.sk_receive_queue, skb);
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 059c0f6..915f60f 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -981,7 +981,7 @@ static void team_port_disable(struct team *team,
 	team_lower_state_changed(port);
 }
 
-#define TEAM_VLAN_FEATURES (NETIF_F_ALL_CSUM | NETIF_F_SG | \
+#define TEAM_VLAN_FEATURES (NETIF_F_HW_CSUM | NETIF_F_SG | \
 			    NETIF_F_FRAGLIST | NETIF_F_ALL_TSO | \
 			    NETIF_F_HIGHDMA | NETIF_F_LRO)
 
@@ -2091,7 +2091,6 @@ static void team_setup(struct net_device *dev)
 			   NETIF_F_HW_VLAN_CTAG_RX |
 			   NETIF_F_HW_VLAN_CTAG_FILTER;
 
-	dev->hw_features &= ~(NETIF_F_ALL_CSUM & ~NETIF_F_HW_CSUM);
 	dev->features |= dev->hw_features;
 }
 
diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index d9427ca..34642a9 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1986,7 +1986,7 @@ rtl8152_features_check(struct sk_buff *skb, struct net_device *dev,
 	int offset = skb_transport_offset(skb);
 
 	if ((mss || skb->ip_summed == CHECKSUM_PARTIAL) && offset > max_offset)
-		features &= ~(NETIF_F_ALL_CSUM | NETIF_F_GSO_MASK);
+		features &= ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
 	else if ((skb->len + sizeof(struct tx_desc)) > agg_buf_sz)
 		features &= ~NETIF_F_GSO_MASK;
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index 679785b..9de4f23 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -69,7 +69,7 @@ ksocknal_lib_zc_capable(ksock_conn_t *conn)
 
 	/* ZC if the socket supports scatter/gather and doesn't need software
 	 * checksums */
-	return ((caps & NETIF_F_SG) != 0 && (caps & NETIF_F_ALL_CSUM) != 0);
+	return ((caps & NETIF_F_SG) != 0 && (caps & NETIF_F_CSUM_MASK) != 0);
 }
 
 int
diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 6395f83..2c4e94a 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -149,7 +149,12 @@ enum {
 #define NETIF_F_GEN_CSUM	NETIF_F_HW_CSUM
 #define NETIF_F_V4_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IP_CSUM)
 #define NETIF_F_V6_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IPV6_CSUM)
-#define NETIF_F_ALL_CSUM	(NETIF_F_V4_CSUM | NETIF_F_V6_CSUM)
+
+/* List of IP checksum features. Note that NETIF_HW_CSUM should not be
+ * set in features when NETIF_F_IP_CSUM or NETIF_F_IPV6_CSUM are set--
+ * this would be contradictory
+ */
+#define NETIF_F_CSUM_MASK	(NETIF_F_V4_CSUM | NETIF_F_V6_CSUM)
 
 #define NETIF_F_ALL_TSO 	(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1bb21ff..a54223a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3763,12 +3763,12 @@ static inline netdev_features_t netdev_intersect_features(netdev_features_t f1,
 							  netdev_features_t f2)
 {
 	if (f1 & NETIF_F_GEN_CSUM)
-		f1 |= (NETIF_F_ALL_CSUM & ~NETIF_F_GEN_CSUM);
+		f1 |= (NETIF_F_CSUM_MASK & ~NETIF_F_GEN_CSUM);
 	if (f2 & NETIF_F_GEN_CSUM)
-		f2 |= (NETIF_F_ALL_CSUM & ~NETIF_F_GEN_CSUM);
+		f2 |= (NETIF_F_CSUM_MASK & ~NETIF_F_GEN_CSUM);
 	f1 &= f2;
 	if (f1 & NETIF_F_GEN_CSUM)
-		f1 &= ~(NETIF_F_ALL_CSUM & ~NETIF_F_GEN_CSUM);
+		f1 &= ~(NETIF_F_CSUM_MASK & ~NETIF_F_GEN_CSUM);
 
 	return f1;
 }
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index c1c899c..b5a1aec 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -232,7 +232,7 @@ static inline netdev_features_t vxlan_features_check(struct sk_buff *skb,
 	     skb->inner_protocol != htons(ETH_P_TEB) ||
 	     (skb_inner_mac_header(skb) - skb_transport_header(skb) !=
 	      sizeof(struct udphdr) + sizeof(struct vxlanhdr))))
-		return features & ~(NETIF_F_ALL_CSUM | NETIF_F_GSO_MASK);
+		return features & ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
 
 	return features;
 }
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index c2bf37f..58477d9 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -542,7 +542,7 @@ static int vlan_dev_init(struct net_device *dev)
 					  (1<<__LINK_STATE_DORMANT))) |
 		      (1<<__LINK_STATE_PRESENT);
 
-	dev->hw_features = NETIF_F_ALL_CSUM | NETIF_F_SG |
+	dev->hw_features = NETIF_F_HW_CSUM | NETIF_F_SG |
 			   NETIF_F_FRAGLIST | NETIF_F_GSO_SOFTWARE |
 			   NETIF_F_HIGHDMA | NETIF_F_SCTP_CRC |
 			   NETIF_F_ALL_FCOE;
diff --git a/net/core/dev.c b/net/core/dev.c
index 8f705fc..5a3b5a4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2645,7 +2645,7 @@ static netdev_features_t harmonize_features(struct sk_buff *skb,
 
 	if (skb->ip_summed != CHECKSUM_NONE &&
 	    !can_checksum_protocol(features, type)) {
-		features &= ~NETIF_F_ALL_CSUM;
+		features &= ~NETIF_F_CSUM_MASK;
 	} else if (illegal_highdma(skb->dev, skb)) {
 		features &= ~NETIF_F_SG;
 	}
@@ -2792,7 +2792,7 @@ static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device
 			else
 				skb_set_transport_header(skb,
 							 skb_checksum_start_offset(skb));
-			if (!(features & NETIF_F_ALL_CSUM) &&
+			if (!(features & NETIF_F_CSUM_MASK) &&
 			    skb_checksum_help(skb))
 				goto out_kfree_skb;
 		}
@@ -7572,15 +7572,15 @@ netdev_features_t netdev_increment_features(netdev_features_t all,
 	netdev_features_t one, netdev_features_t mask)
 {
 	if (mask & NETIF_F_GEN_CSUM)
-		mask |= NETIF_F_ALL_CSUM;
+		mask |= NETIF_F_CSUM_MASK;
 	mask |= NETIF_F_VLAN_CHALLENGED;
 
-	all |= one & (NETIF_F_ONE_FOR_ALL|NETIF_F_ALL_CSUM) & mask;
+	all |= one & (NETIF_F_ONE_FOR_ALL | NETIF_F_CSUM_MASK) & mask;
 	all &= one | ~NETIF_F_ALL_FOR_ALL;
 
 	/* If one device supports hw checksumming, set for all. */
 	if (all & NETIF_F_GEN_CSUM)
-		all &= ~(NETIF_F_ALL_CSUM & ~NETIF_F_GEN_CSUM);
+		all &= ~(NETIF_F_CSUM_MASK & ~NETIF_F_GEN_CSUM);
 
 	return all;
 }
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 4a0cab8..09948a7 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -235,7 +235,7 @@ static netdev_features_t ethtool_get_feature_mask(u32 eth_cmd)
 	switch (eth_cmd) {
 	case ETHTOOL_GTXCSUM:
 	case ETHTOOL_STXCSUM:
-		return NETIF_F_ALL_CSUM | NETIF_F_SCTP_CRC;
+		return NETIF_F_CSUM_MASK | NETIF_F_SCTP_CRC;
 	case ETHTOOL_GRXCSUM:
 	case ETHTOOL_SRXCSUM:
 		return NETIF_F_RXCSUM;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c82cca1..cf7ef7b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1018,7 +1018,7 @@ int tcp_sendpage(struct sock *sk, struct page *page, int offset,
 	ssize_t res;
 
 	if (!(sk->sk_route_caps & NETIF_F_SG) ||
-	    !(sk->sk_route_caps & NETIF_F_ALL_CSUM))
+	    !(sk->sk_route_caps & NETIF_F_CSUM_MASK))
 		return sock_no_sendpage(sk->sk_socket, page, offset, size,
 					flags);
 
@@ -1175,7 +1175,7 @@ new_segment:
 			/*
 			 * Check whether we can use HW checksum.
 			 */
-			if (sk->sk_route_caps & NETIF_F_ALL_CSUM)
+			if (sk->sk_route_caps & NETIF_F_CSUM_MASK)
 				skb->ip_summed = CHECKSUM_PARTIAL;
 
 			skb_entail(sk, skb);
-- 
2.4.6
