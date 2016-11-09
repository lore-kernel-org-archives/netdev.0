From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 2/3] vhost: better detection of available buffers
Date: Wed,  9 Nov 2016 15:38:32 +0800
Message-ID: <1478677113-13126-2-git-send-email-jasowang@redhat.com>
References: <1478677113-13126-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478677113-13126-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should use vq->last_avail_idx instead of vq->avail_idx in the
checking of vhost_vq_avail_empty() since latter is the cached avail
index from guest but we want to know if there's pending available
buffers in the virtqueue.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index c6f2d89..fdf4cdf 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -2230,7 +2230,7 @@ bool vhost_vq_avail_empty(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 	if (r)
 		return false;
 
-	return vhost16_to_cpu(vq, avail_idx) == vq->avail_idx;
+	return vhost16_to_cpu(vq, avail_idx) == vq->last_avail_idx;
 }
 EXPORT_SYMBOL_GPL(vhost_vq_avail_empty);
 
-- 
2.7.4
