From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 2/3] net: reclaim 8 upper bits of the netdev->features from GSO
Date: Mon, 06 Oct 2008 16:39:23 -0700
Message-ID: <20081006233923.4918.25059.stgit@zyfc9ini.jf.intel.com>
References: <20081006233409.4918.82298.stgit@zyfc9ini.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:55211 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752970AbYJFXmJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2008 19:42:09 -0400
In-Reply-To: <20081006233409.4918.82298.stgit@zyfc9ini.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Leech <christopher.leech@intel.com>

Signed-off-by: Chris Leech <christopher.leech@intel.com>
---

 drivers/net/xen-netfront.c |    2 +-
 include/linux/netdevice.h  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index c749bdb..9f76177 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1502,7 +1502,7 @@ static int xennet_set_tso(struct net_device *dev, u32 data)
 static void xennet_set_features(struct net_device *dev)
 {
 	/* Turn off all GSO bits except ROBUST. */
-	dev->features &= (1 << NETIF_F_GSO_SHIFT) - 1;
+	dev->features &= ~NETIF_F_GSO_MASK;
 	dev->features |= NETIF_F_GSO_ROBUST;
 	xennet_set_sg(dev, 0);
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9cfd20b..add9937 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -524,7 +524,7 @@ struct net_device
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
-#define NETIF_F_GSO_MASK	0xffff0000
+#define NETIF_F_GSO_MASK	0x00ff0000
 #define NETIF_F_TSO		(SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
 #define NETIF_F_UFO		(SKB_GSO_UDP << NETIF_F_GSO_SHIFT)
 #define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)

