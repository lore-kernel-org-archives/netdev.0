From: Simon Xiao <sixiao@microsoft.com>
Subject: [PATCH net-next] hv_netvsc: Add feature flags NETIF_F_IPV6_CSUM and NETIF_F_TSO6 for netvsc
Date: Wed,  3 Feb 2016 13:30:41 -0800
Message-ID: <1454535041-14893-1-git-send-email-sixiao@microsoft.com>
Cc: Simon Xiao <sixiao@microsoft.com>
To: kys@microsoft.com, haiyangz@microsoft.com,
	devel@linuxdriverproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded04.prod.phx3.secureserver.net ([208.109.80.198]:54640
	"EHLO p3plsmtps2ded04.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751875AbcBCTxy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2016 14:53:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Adding NETIF_F_IPV6_CSUM and NETIF_F_TSO6 feature flags which are
supported by Hyper-V platform.
2. Cleanup the coding style of flag assignment by using macro.

Signed-off-by: Simon Xiao <sixiao@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 1d3a665..0cde741 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -43,6 +43,12 @@
 
 #define RING_SIZE_MIN 64
 #define LINKCHANGE_INT (2 * HZ)
+#define NETVSC_HW_FEATURES	(NETIF_F_RXCSUM | \
+				 NETIF_F_SG | \
+				 NETIF_F_TSO | \
+				 NETIF_F_TSO6 | \
+				 NETIF_F_IP_CSUM | \
+				 NETIF_F_IPV6_CSUM)
 static int ring_size = 128;
 module_param(ring_size, int, S_IRUGO);
 MODULE_PARM_DESC(ring_size, "Ring buffer size (# of pages)");
@@ -1081,10 +1087,8 @@ static int netvsc_probe(struct hv_device *dev,
 
 	net->netdev_ops = &device_ops;
 
-	net->hw_features = NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_IP_CSUM |
-				NETIF_F_TSO;
-	net->features = NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_SG | NETIF_F_RXCSUM |
-			NETIF_F_IP_CSUM | NETIF_F_TSO;
+	net->hw_features = NETVSC_HW_FEATURES;
+	net->features = NETVSC_HW_FEATURES | NETIF_F_HW_VLAN_CTAG_TX;
 
 	net->ethtool_ops = &ethtool_ops;
 	SET_NETDEV_DEV(net, &dev->device);
-- 
2.5.0
