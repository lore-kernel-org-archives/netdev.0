From: Thomas Huth <thuth@linux.vnet.ibm.com>
Subject: [PATCH] virtio-net: Set RXCSUM feature if GUEST_CSUM is available
Date: Tue, 27 Aug 2013 17:09:02 +0200
Message-ID: <1377616142-29590-1-git-send-email-thuth@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, Thomas Huth <thuth@linux.vnet.ibm.com>
To: virtualization@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp18.uk.ibm.com ([195.75.94.114]:42261 "EHLO
	e06smtp18.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751746Ab3H0PJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 11:09:09 -0400
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <thuth@linux.vnet.ibm.com>;
	Tue, 27 Aug 2013 16:02:08 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id D81451B0805D
	for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 16:09:06 +0100 (BST)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7RF8qfY66126064
	for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 15:08:52 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7RF93TD007439
	for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 09:09:04 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the VIRTIO_NET_F_GUEST_CSUM virtio feature is available, the guest
does not have to calculate the checksums on all received packets. This
is pretty much the same feature as RX checksum offloading on real
network cards, so the virtio-net driver should report this by setting
the NETIF_F_RXCSUM flag. When the user now runs "ethtool -k", he or she
can see whether the virtio-net interface has to calculate RX checksums
or not.

Signed-off-by: Thomas Huth <thuth@linux.vnet.ibm.com>
---
 drivers/net/virtio_net.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index f216002..defec2b 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1538,6 +1538,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 			dev->features |= dev->hw_features & (NETIF_F_ALL_TSO|NETIF_F_UFO);
 		/* (!csum && gso) case will be fixed by register_netdev() */
 	}
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_CSUM))
+		dev->features |= NETIF_F_RXCSUM;
 
 	dev->vlan_features = dev->features;
 
-- 
1.8.1.4
