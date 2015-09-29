From: "Charles (Chas) Williams" <3chas3@gmail.com>
Subject: [linux 3.14-stable] virtio-net: drop NETIF_F_FRAGLIST
Date: Tue, 29 Sep 2015 16:00:57 -0400
Message-ID: <1443556857.3494.36.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:36199 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088AbbI2UBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 16:01:00 -0400
Received: by qgx61 with SMTP id 61so16596994qgx.3
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 13:00:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>

commit 48900cb6af4282fa0fb6ff4d72a81aa3dadb5c39 upstream.

virtio declares support for NETIF_F_FRAGLIST, but assumes
that there are at most MAX_SKB_FRAGS + 2 fragments which isn't
always true with a fraglist.

A longer fraglist in the skb will make the call to skb_to_sgvec overflow
the sg array, leading to memory corruption.

Drop NETIF_F_FRAGLIST so we only get what we can handle.

Fixes CVE-2015-5156.

Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
Acked-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Chas Williams <3chas3@gmail.com>
---
 drivers/net/virtio_net.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 841b608..5c150a0 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1652,9 +1652,9 @@ static int virtnet_probe(struct virtio_device *vdev)
 	/* Do we support "hardware" checksums? */
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_CSUM)) {
 		/* This opens up the world of extra features. */
-		dev->hw_features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
+		dev->hw_features |= NETIF_F_HW_CSUM | NETIF_F_SG;
 		if (csum)
-			dev->features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
+			dev->features |= NETIF_F_HW_CSUM | NETIF_F_SG;
 
 		if (virtio_has_feature(vdev, VIRTIO_NET_F_GSO)) {
 			dev->hw_features |= NETIF_F_TSO | NETIF_F_UFO
-- 
2.1.0
