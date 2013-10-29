From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  01/11] vxlan: Have the NIC drivers do less work for offloads
Date: Tue, 29 Oct 2013 05:02:21 -0700
Message-ID: <1383048151-15002-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1383048151-15002-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:48082 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752093Ab3J2MCg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 08:02:36 -0400
In-Reply-To: <1383048151-15002-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joseph Gasparakis <joseph.gasparakis@intel.com>

This patch removes the burden from the NIC drivers to check if the
vxlan driver is enabled in the kernel and also makes available
the vxlan headrooms to them.

Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/vxlan.c |  4 ----
 include/net/vxlan.h | 11 +++++++++++
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 75a3a74..24260ce 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -60,10 +60,6 @@
 
 #define VXLAN_N_VID	(1u << 24)
 #define VXLAN_VID_MASK	(VXLAN_N_VID - 1)
-/* IP header + UDP + VXLAN + Ethernet header */
-#define VXLAN_HEADROOM (20 + 8 + 8 + 14)
-/* IPv6 header + UDP + VXLAN + Ethernet header */
-#define VXLAN6_HEADROOM (40 + 8 + 8 + 14)
 #define VXLAN_HLEN (sizeof(struct udphdr) + sizeof(struct vxlanhdr))
 
 #define VXLAN_FLAGS 0x08000000	/* struct vxlanhdr.vx_flags required value. */
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 2d64d3c..6b6d180 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -36,5 +36,16 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 
 __be16 vxlan_src_port(__u16 port_min, __u16 port_max, struct sk_buff *skb);
 
+/* IP header + UDP + VXLAN + Ethernet header */
+#define VXLAN_HEADROOM (20 + 8 + 8 + 14)
+/* IPv6 header + UDP + VXLAN + Ethernet header */
+#define VXLAN6_HEADROOM (40 + 8 + 8 + 14)
+
+#if IS_ENABLED(CONFIG_VXLAN)
 void vxlan_get_rx_port(struct net_device *netdev);
+#else
+static inline void vxlan_get_rx_port(struct net_device *netdev)
+{
+}
+#endif
 #endif
-- 
1.8.3.1
