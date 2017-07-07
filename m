From: David Miller <davem@davemloft.net>
Subject: [PATCH v2 RFC 07/13] virtio_net: Remove references to NETIF_F_UFO.
Date: Fri, 07 Jul 2017 10:44:20 +0100 (WEST)
Message-ID: <20170707.104420.503298079426396655.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemdebruijn.kernel@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49816 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751965AbdGGJoW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 05:44:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It is going away.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/virtio_net.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 2e69bcd..eb33e2e 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -2428,7 +2428,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 			dev->features |= NETIF_F_HW_CSUM | NETIF_F_SG;
 
 		if (virtio_has_feature(vdev, VIRTIO_NET_F_GSO)) {
-			dev->hw_features |= NETIF_F_TSO | NETIF_F_UFO
+			dev->hw_features |= NETIF_F_TSO
 				| NETIF_F_TSO_ECN | NETIF_F_TSO6;
 		}
 		/* Individual feature bits: what can host handle? */
@@ -2438,13 +2438,11 @@ static int virtnet_probe(struct virtio_device *vdev)
 			dev->hw_features |= NETIF_F_TSO6;
 		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_ECN))
 			dev->hw_features |= NETIF_F_TSO_ECN;
-		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_UFO))
-			dev->hw_features |= NETIF_F_UFO;
 
 		dev->features |= NETIF_F_GSO_ROBUST;
 
 		if (gso)
-			dev->features |= dev->hw_features & (NETIF_F_ALL_TSO|NETIF_F_UFO);
+			dev->features |= dev->hw_features & NETIF_F_ALL_TSO;
 		/* (!csum && gso) case will be fixed by register_netdev() */
 	}
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_CSUM))
-- 
2.9.4
