From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 1/5] net: Fix GSO constants to match NETIF flags
Date: Sat, 14 Jun 2014 23:23:52 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406142315220.17425@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: joseph.gasparakis@intel.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f74.google.com ([209.85.219.74]:49312 "EHLO
	mail-oa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752162AbaFOGXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2014 02:23:54 -0400
Received: by mail-oa0-f74.google.com with SMTP id i7so824841oag.3
        for <netdev@vger.kernel.org>; Sat, 14 Jun 2014 23:23:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joseph Gasparakis reported that VXLAN GSO offload stopped working with
i40e device after recent UDP changes. The problem is that the
SKB_GSO_* bits are out of sync with the corresponding NETIF flags. This
patch fixes that. Also, we add BUILD_BUG_ONs in net_gso_ok for several
GSO constants that were missing to avoid the problem in the future.

Reported-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdev_features.h |  1 +
 include/linux/netdevice.h       |  7 +++++++
 include/linux/skbuff.h          | 11 ++++++-----
 3 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index e5a5894..d99800c 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -117,6 +117,7 @@ enum {
 #define NETIF_F_GSO_IPIP	__NETIF_F(GSO_IPIP)
 #define NETIF_F_GSO_SIT		__NETIF_F(GSO_SIT)
 #define NETIF_F_GSO_UDP_TUNNEL	__NETIF_F(GSO_UDP_TUNNEL)
+#define NETIF_F_GSO_UDP_TUNNEL_CSUM __NETIF_F(GSO_UDP_TUNNEL_CSUM)
 #define NETIF_F_GSO_MPLS	__NETIF_F(GSO_MPLS)
 #define NETIF_F_HW_VLAN_STAG_FILTER __NETIF_F(HW_VLAN_STAG_FILTER)
 #define NETIF_F_HW_VLAN_STAG_RX	__NETIF_F(HW_VLAN_STAG_RX)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 774e539..80f1e41 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3305,6 +3305,13 @@ static inline bool net_gso_ok(netdev_features_t features, int gso_type)
 	BUILD_BUG_ON(SKB_GSO_TCP_ECN != (NETIF_F_TSO_ECN >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_TCPV6   != (NETIF_F_TSO6 >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_FCOE    != (NETIF_F_FSO >> NETIF_F_GSO_SHIFT));
+	BUILD_BUG_ON(SKB_GSO_GRE     != (NETIF_F_GSO_GRE >> NETIF_F_GSO_SHIFT));
+	BUILD_BUG_ON(SKB_GSO_GRE_CSUM != (NETIF_F_GSO_GRE_CSUM >> NETIF_F_GSO_SHIFT));
+	BUILD_BUG_ON(SKB_GSO_IPIP    != (NETIF_F_GSO_IPIP >> NETIF_F_GSO_SHIFT));
+	BUILD_BUG_ON(SKB_GSO_SIT     != (NETIF_F_GSO_SIT >> NETIF_F_GSO_SHIFT));
+	BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL != (NETIF_F_GSO_UDP_TUNNEL >> NETIF_F_GSO_SHIFT));
+	BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL_CSUM != (NETIF_F_GSO_UDP_TUNNEL_CSUM >> NETIF_F_GSO_SHIFT));
+	BUILD_BUG_ON(SKB_GSO_MPLS    != (NETIF_F_GSO_MPLS >> NETIF_F_GSO_SHIFT));
 
 	return (features & feature) == feature;
 }
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5b5cd31..e13ed90 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -338,17 +338,18 @@ enum {
 
 	SKB_GSO_GRE = 1 << 6,
 
-	SKB_GSO_IPIP = 1 << 7,
+	SKB_GSO_GRE_CSUM = 1 << 7,
 
-	SKB_GSO_SIT = 1 << 8,
+	SKB_GSO_IPIP = 1 << 8,
 
-	SKB_GSO_UDP_TUNNEL = 1 << 9,
+	SKB_GSO_SIT = 1 << 9,
 
-	SKB_GSO_MPLS = 1 << 10,
+	SKB_GSO_UDP_TUNNEL = 1 << 10,
 
 	SKB_GSO_UDP_TUNNEL_CSUM = 1 << 11,
 
-	SKB_GSO_GRE_CSUM = 1 << 12,
+	SKB_GSO_MPLS = 1 << 12,
+
 };
 
 #if BITS_PER_LONG > 32
-- 
2.0.0.526.g5318336
