From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 1/5] virtio_ring: allow to store zero as the ctx
Date: Mon, 17 Jul 2017 20:43:57 +0800
Message-ID: <1500295441-19339-2-git-send-email-jasowang@redhat.com>
References: <1500295441-19339-1-git-send-email-jasowang@redhat.com>
To: mst@redhat.com, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1500295441-19339-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow zero to be store as a ctx, with this we could store e.g zero
value which could be meaningful for the case of storing headroom
through ctx.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/virtio/virtio_ring.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 5e1b548..9aaa177 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -391,7 +391,7 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 	vq->desc_state[head].data = data;
 	if (indirect)
 		vq->desc_state[head].indir_desc = desc;
-	if (ctx)
+	else
 		vq->desc_state[head].indir_desc = ctx;
 
 	/* Put entry in available array (but don't update avail->idx until they
-- 
2.7.4
