From: Jason Wang <jasowang@redhat.com>
Subject: [RFC V7 PATCH 2/7] virtio_ring: try to disable event index callbacks in virtqueue_disable_cb()
Date: Mon, 25 May 2015 01:23:59 -0400
Message-ID: <1432531444-50193-3-git-send-email-jasowang@redhat.com>
References: <1432531444-50193-1-git-send-email-jasowang@redhat.com>
Cc: rusty@rustcorp.com.au, Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55634 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750726AbbEYFYQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 May 2015 01:24:16 -0400
In-Reply-To: <1432531444-50193-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we do nothing to prevent the callbacks in virtqueue_disable_cb() when
event index is used. This may cause spurious interrupts which may damage the
performance. This patch tries to publish last_used_idx as the used even to prevent
the callbacks.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/virtio/virtio_ring.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 096b857..a83aebc 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -538,6 +538,7 @@ void virtqueue_disable_cb(struct virtqueue *_vq)
 	struct vring_virtqueue *vq = to_vvq(_vq);
 
 	vq->vring.avail->flags |= cpu_to_virtio16(_vq->vdev, VRING_AVAIL_F_NO_INTERRUPT);
+	vring_used_event(&vq->vring) = cpu_to_virtio16(_vq->vdev, vq->last_used_idx);
 }
 EXPORT_SYMBOL_GPL(virtqueue_disable_cb);
 
-- 
1.8.3.1
