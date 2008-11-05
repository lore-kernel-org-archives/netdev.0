From: Mark McLoughlin <markmc@redhat.com>
Subject: [PATCH] virtio_net: don't set NETIF_F_FRAGLIST
Date: Wed,  5 Nov 2008 12:34:46 +0000
Message-ID: <1225888486-977-1-git-send-email-markmc@redhat.com>
Cc: netdev@vger.kernel.org, Mark McLoughlin <markmc@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail08.svc.cra.dublin.eircom.net ([159.134.118.24]:34530 "HELO
	mail08.svc.cra.dublin.eircom.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754613AbYKEMft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 07:35:49 -0500
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't handle skb_shared_info->frag_list, so we shouldn't
be setting the NETIF_F_FRAGLIST flag.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
---
 drivers/net/virtio_net.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 0196a0d..9d4fdad 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -505,7 +505,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 	/* Do we support "hardware" checksums? */
 	if (csum && virtio_has_feature(vdev, VIRTIO_NET_F_CSUM)) {
 		/* This opens up the world of extra features. */
-		dev->features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
+		dev->features |= NETIF_F_HW_CSUM|NETIF_F_SG;
 		if (gso && virtio_has_feature(vdev, VIRTIO_NET_F_GSO)) {
 			dev->features |= NETIF_F_TSO | NETIF_F_UFO
 				| NETIF_F_TSO_ECN | NETIF_F_TSO6;
-- 
1.5.4.3

