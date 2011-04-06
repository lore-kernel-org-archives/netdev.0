From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 19/20] virtio_net: extending (hw_/wanted_/vlan_)features fields to a bitmap.
Date: Tue,  5 Apr 2011 17:44:24 -0700
Message-ID: <1302050665-10460-20-git-send-email-maheshb@google.com>
References: <1302050665-10460-1-git-send-email-maheshb@google.com>
 <1302050665-10460-2-git-send-email-maheshb@google.com>
 <1302050665-10460-3-git-send-email-maheshb@google.com>
 <1302050665-10460-4-git-send-email-maheshb@google.com>
 <1302050665-10460-5-git-send-email-maheshb@google.com>
 <1302050665-10460-6-git-send-email-maheshb@google.com>
 <1302050665-10460-7-git-send-email-maheshb@google.com>
 <1302050665-10460-8-git-send-email-maheshb@google.com>
 <1302050665-10460-9-git-send-email-maheshb@google.com>
 <1302050665-10460-10-git-send-email-maheshb@google.com>
 <1302050665-10460-11-git-send-email-maheshb@google.com>
 <1302050665-10460-12-git-send-email-maheshb@google.com>
 <1302050665-10460-13-git-send-email-maheshb@google.com>
 <1302050665-10460-14-git-send-email-maheshb@google.com>
 <1302050665-10460-15-git-send-email-maheshb@google.com>
 <1302050665-10460-16-git-send-email-maheshb@google.com>
 <1302050665-10460-17-git-send-email-maheshb@google.com>
 <1302050665-10460-18-git-send-email-maheshb@google.com>
 <1302050665-10460-19-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:54014 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754153Ab1DFAoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 20:44:54 -0400
In-Reply-To: <1302050665-10460-19-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converting current use of (hw_/wanted_/vlan_)features to
legacy_(hw_/wanted_/vlan_)features to differntiate from the proposed usage.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/virtio_net.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 0cb0b06..36eed90 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -892,33 +892,34 @@ static int virtnet_probe(struct virtio_device *vdev)
 
 	/* Set up network device as normal. */
 	dev->netdev_ops = &virtnet_netdev;
-	dev->features = NETIF_F_HIGHDMA;
+	dev->legacy_features = NETIF_F_HIGHDMA;
 	SET_ETHTOOL_OPS(dev, &virtnet_ethtool_ops);
 	SET_NETDEV_DEV(dev, &vdev->dev);
 
 	/* Do we support "hardware" checksums? */
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_CSUM)) {
 		/* This opens up the world of extra features. */
-		dev->hw_features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
+		dev->legacy_hw_features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
 		if (csum)
-			dev->features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
+			dev->legacy_features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
 
 		if (virtio_has_feature(vdev, VIRTIO_NET_F_GSO)) {
-			dev->hw_features |= NETIF_F_TSO | NETIF_F_UFO
+			dev->legacy_hw_features |= NETIF_F_TSO | NETIF_F_UFO
 				| NETIF_F_TSO_ECN | NETIF_F_TSO6;
 		}
 		/* Individual feature bits: what can host handle? */
 		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_TSO4))
-			dev->hw_features |= NETIF_F_TSO;
+			dev->legacy_hw_features |= NETIF_F_TSO;
 		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_TSO6))
-			dev->hw_features |= NETIF_F_TSO6;
+			dev->legacy_hw_features |= NETIF_F_TSO6;
 		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_ECN))
-			dev->hw_features |= NETIF_F_TSO_ECN;
+			dev->legacy_hw_features |= NETIF_F_TSO_ECN;
 		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_UFO))
-			dev->hw_features |= NETIF_F_UFO;
+			dev->legacy_hw_features |= NETIF_F_UFO;
 
 		if (gso)
-			dev->features |= dev->hw_features & (NETIF_F_ALL_TSO|NETIF_F_UFO);
+			dev->legacy_features |=
+				dev->legacy_hw_features & (NETIF_F_ALL_TSO|NETIF_F_UFO);
 		/* (!csum && gso) case will be fixed by register_netdev() */
 	}
 
@@ -965,7 +966,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 		vi->cvq = vqs[2];
 
 		if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VLAN))
-			dev->features |= NETIF_F_HW_VLAN_FILTER;
+			dev->legacy_features |= NETIF_F_HW_VLAN_FILTER;
 	}
 
 	err = register_netdev(dev);
-- 
1.7.3.1

