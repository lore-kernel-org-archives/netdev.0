From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 2/3] net: reclaim 8 upper bits of the netdev->features from GSO
Date: Mon, 17 Nov 2008 10:38:42 -0800
Message-ID: <20081117183842.15856.3131.stgit@zychongqing.jf.intel.com>
References: <20081117183539.15856.46809.stgit@zychongqing.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48747 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752138AbYKQStQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 13:49:16 -0500
In-Reply-To: <20081117183539.15856.46809.stgit@zychongqing.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Leech <christopher.leech@intel.com>

Signed-off-by: Chris Leech <christopher.leech@intel.com>
Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 drivers/net/xen-netfront.c |    2 +-
 include/linux/netdevice.h  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 4b21bcf..a2bbdaa 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1504,7 +1504,7 @@ static int xennet_set_tso(struct net_device *dev, u32 data)
 static void xennet_set_features(struct net_device *dev)
 {
 	/* Turn off all GSO bits except ROBUST. */
-	dev->features &= (1 << NETIF_F_GSO_SHIFT) - 1;
+	dev->features &= ~NETIF_F_GSO_MASK;
 	dev->features |= NETIF_F_GSO_ROBUST;
 	xennet_set_sg(dev, 0);
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 12d7f44..423c7bc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -525,7 +525,7 @@ struct net_device
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
-#define NETIF_F_GSO_MASK	0xffff0000
+#define NETIF_F_GSO_MASK	0x00ff0000
 #define NETIF_F_TSO		(SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
 #define NETIF_F_UFO		(SKB_GSO_UDP << NETIF_F_GSO_SHIFT)
 #define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)

