From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH RFC v5 net-next 2/6] virtio_ring: try to disable event index
	callbacks in virtqueue_disable_cb()
Date: Mon,  9 Feb 2015 03:39:21 -0500
Message-ID: <1423471165-34243-3-git-send-email-jasowang@redhat.com>
References: <1423471165-34243-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pagupta@redhat.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1423471165-34243-1-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Currently, we do nothing to prevent the callbacks in
virtqueue_disable_cb() when event index is used. This may cause
spurious interrupts which may damage the performance. This patch tries
to publish avail event as the used even to prevent the callbacks.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/virtio/virtio_ring.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 545fed5..e9ffbfb 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -539,6 +539,8 @@ void virtqueue_disable_cb(struct virtqueue *_vq)
 	struct vring_virtqueue *vq = to_vvq(_vq);
 
 	vq->vring.avail->flags |= cpu_to_virtio16(_vq->vdev, VRING_AVAIL_F_NO_INTERRUPT);
+	vring_used_event(&vq->vring) = cpu_to_virtio16(_vq->vdev,
+						       vq->vring.avail->idx);
 }
 EXPORT_SYMBOL_GPL(virtqueue_disable_cb);
 
-- 
1.8.3.1
