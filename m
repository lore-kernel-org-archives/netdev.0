From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 02/11] openvswitch: Enable tunnel GSO for OVS bridge.
Date: Tue, 15 Jul 2014 10:14:43 -0700
Message-ID: <1405444483-16896-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog107.obsmtp.com ([74.125.149.197]:60113 "HELO
	na3sys009aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758192AbaGOROs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 13:14:48 -0400
Received: by mail-pd0-f182.google.com with SMTP id fp1so4604360pdb.13
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 10:14:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch enables all available tunnel GSO features for OVS
bridge device so that ovs can use hardware offloads available to
underling device.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Acked-by: Andy Zhou <azhou@nicira.com>
---
 include/linux/netdev_features.h      | 8 ++++++++
 net/openvswitch/vport-internal_dev.c | 5 ++++-
 2 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index d99800c..dcfdecb 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -176,4 +176,12 @@ enum {
 				 NETIF_F_HW_VLAN_STAG_RX | \
 				 NETIF_F_HW_VLAN_STAG_TX)
 
+#define NETIF_F_GSO_ENCAP_ALL	(NETIF_F_GSO_GRE |			\
+				 NETIF_F_GSO_GRE_CSUM |			\
+				 NETIF_F_GSO_IPIP |			\
+				 NETIF_F_GSO_SIT |			\
+				 NETIF_F_GSO_UDP_TUNNEL |		\
+				 NETIF_F_GSO_UDP_TUNNEL_CSUM |		\
+				 NETIF_F_GSO_MPLS)
+
 #endif	/* _LINUX_NETDEV_FEATURES_H */
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 295471a..4e8285f 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -140,11 +140,14 @@ static void do_setup(struct net_device *netdev)
 	netdev->tx_queue_len = 0;
 
 	netdev->features = NETIF_F_LLTX | NETIF_F_SG | NETIF_F_FRAGLIST |
-			   NETIF_F_HIGHDMA | NETIF_F_HW_CSUM | NETIF_F_GSO_SOFTWARE;
+			   NETIF_F_HIGHDMA | NETIF_F_HW_CSUM |
+			   NETIF_F_GSO_SOFTWARE | NETIF_F_GSO_ENCAP_ALL;
 
 	netdev->vlan_features = netdev->features;
+	netdev->hw_enc_features = netdev->features;
 	netdev->features |= NETIF_F_HW_VLAN_CTAG_TX;
 	netdev->hw_features = netdev->features & ~NETIF_F_LLTX;
+
 	eth_hw_addr_random(netdev);
 }
 
-- 
1.9.3
