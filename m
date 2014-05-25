From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH 2/2] openvswitch: Enable tunnel GSO for OVS bridge.
Date: Sun, 25 May 2014 04:39:45 -0700
Message-ID: <1401017985-1574-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:44975 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932226AbaFJAzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 20:55:48 -0400
Received: by mail-pa0-f47.google.com with SMTP id fa1so74694pad.20
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 17:55:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/linux/netdev_features.h      | 4 ++++
 net/openvswitch/vport-internal_dev.c | 3 ++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index e5a5894..12118a5 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -152,6 +152,10 @@ enum {
 #define NETIF_F_ALL_FCOE	(NETIF_F_FCOE_CRC | NETIF_F_FCOE_MTU | \
 				 NETIF_F_FSO)
 
+#define NETIF_F_ALL_ENCAP_GSO   (NETIF_F_GSO_GRE | NETIF_F_GSO_GRE_CSUM | \
+				 NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT |     \
+				 NETIF_F_GSO_UDP_TUNNEL | NETIF_F_GSO_MPLS)
+
 /*
  * If one device supports one of these features, then enable them
  * for all in netdev_increment_features.
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 789af92..b971610 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -134,7 +134,8 @@ static void do_setup(struct net_device *netdev)
 	netdev->tx_queue_len = 0;
 
 	netdev->features = NETIF_F_LLTX | NETIF_F_SG | NETIF_F_FRAGLIST |
-			   NETIF_F_HIGHDMA | NETIF_F_HW_CSUM | NETIF_F_GSO_SOFTWARE;
+			   NETIF_F_HIGHDMA | NETIF_F_HW_CSUM | NETIF_F_GSO_SOFTWARE |
+			   NETIF_F_ALL_ENCAP_GSO;
 
 	netdev->vlan_features = netdev->features;
 	netdev->features |= NETIF_F_HW_VLAN_CTAG_TX;
-- 
1.9.1
