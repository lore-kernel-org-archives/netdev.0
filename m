From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 02/11] net: reclaim 8 upper bits of the netdev->features from
	GSO
Date: Fri, 27 Feb 2009 14:06:43 -0800
Message-ID: <20090227220643.4987.12818.stgit.yi.zou@intel.com>
References: <20090227220034.4987.50755.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: yi.zou@intel.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090227220034.4987.50755.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Leech <christopher.leech@intel.com>

Reclaim 8 upper bits of netdev->features from GSO.

Signed-off-by: Chris Leech <christopher.leech@intel.com>
Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 drivers/net/xen-netfront.c |    2 +-
 include/linux/netdevice.h  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index cd6184e..2ce536f 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1511,7 +1511,7 @@ static int xennet_set_tso(struct net_device *dev, u32 data)
 static void xennet_set_features(struct net_device *dev)
 {
 	/* Turn off all GSO bits except ROBUST. */
-	dev->features &= (1 << NETIF_F_GSO_SHIFT) - 1;
+	dev->features &= ~NETIF_F_GSO_MASK;
 	dev->features |= NETIF_F_GSO_ROBUST;
 	xennet_set_sg(dev, 0);
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ec54785..c8238d9 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -652,7 +652,7 @@ struct net_device
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
-#define NETIF_F_GSO_MASK	0xffff0000
+#define NETIF_F_GSO_MASK	0x00ff0000
 #define NETIF_F_TSO		(SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
 #define NETIF_F_UFO		(SKB_GSO_UDP << NETIF_F_GSO_SHIFT)
 #define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)

