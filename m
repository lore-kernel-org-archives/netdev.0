From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 1/3] virtio: add API to query ring capacity
Date: Fri, 28 Sep 2012 11:26:05 +0200
Message-ID: <17454e9212d4c2b2d91413296c67868d78d8bd1d.1348824232.git.mst@redhat.com>
References: <cover.1348824232.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, avi@redhat.com,
	Sasha Levin <levinsasha928@gmail.com>
To: Thomas Lendacky <tahm@linux.vnet.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <cover.1348824232.git.mst@redhat.com>
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

It's sometimes necessary to query ring capacity after dequeueing a
buffer. Add an API for this.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/virtio/virtio_ring.c | 19 +++++++++++++++++++
 include/linux/virtio.h       |  2 ++
 2 files changed, 21 insertions(+)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 5aa43c3..ee3d80b 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -715,4 +715,23 @@ unsigned int virtqueue_get_vring_size(struct virtqueue *_vq)
 }
 EXPORT_SYMBOL_GPL(virtqueue_get_vring_size);
 
+/**
+ * virtqueue_get_capacity - query available ring capacity
+ * @vq: the struct virtqueue we're talking about.
+ *
+ * Caller must ensure we don't call this with other virtqueue operations
+ * at the same time (except where noted), otherwise result is unreliable.
+ *
+ * Returns remaining capacity of queue.
+ * Note that it only really makes sense to treat all
+ * return values as "available": indirect buffers mean that
+ * we can put an entire sg[] array inside a single queue entry.
+ */
+unsigned int virtqueue_get_capacity(struct virtqueue *_vq)
+{
+	struct vring_virtqueue *vq = to_vvq(_vq);
+	return vq->num_free;
+}
+EXPORT_SYMBOL_GPL(virtqueue_get_capacity);
+
 MODULE_LICENSE("GPL");
diff --git a/include/linux/virtio.h b/include/linux/virtio.h
index a1ba8bb..fab61e8 100644
--- a/include/linux/virtio.h
+++ b/include/linux/virtio.h
@@ -50,6 +50,8 @@ void *virtqueue_detach_unused_buf(struct virtqueue *vq);
 
 unsigned int virtqueue_get_vring_size(struct virtqueue *vq);
 
+unsigned int virtqueue_get_capacity(struct virtqueue *vq);
+
 /**
  * virtio_device - representation of a device using virtio
  * @index: unique position on the virtio bus
-- 
MST
