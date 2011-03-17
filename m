From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH 1/2]virtio_ring: Add capacity check API
Date: Wed, 16 Mar 2011 17:10:04 -0700
Message-ID: <1300320604.3255.31.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---
 drivers/virtio/virtio_ring.c |    8 ++++++++
 include/linux/virtio.h       |    5 +++++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index cc2f73e..ef6d920 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -329,6 +329,14 @@ void *virtqueue_get_buf(struct virtqueue *_vq, unsigned int *len)
 }
 EXPORT_SYMBOL_GPL(virtqueue_get_buf);
 
+int virtqueue_get_capacity(struct virtqueue *_vq)
+{
+	struct vring_virtqueue *vq = to_vvq(_vq);
+
+	return vq->num_free;
+}
+EXPORT_SYMBOL_GPL(virtqueue_get_capacity);
+
 void virtqueue_disable_cb(struct virtqueue *_vq)
 {
 	struct vring_virtqueue *vq = to_vvq(_vq);
diff --git a/include/linux/virtio.h b/include/linux/virtio.h
index aff5b4f..6c7f519 100644
--- a/include/linux/virtio.h
+++ b/include/linux/virtio.h
@@ -42,6 +42,9 @@ struct virtqueue {
  *	vq: the struct virtqueue we're talking about.
  *	len: the length written into the buffer
  *	Returns NULL or the "data" token handed to add_buf.
+ * virtqueue_get_capacity: get the current capacity of the queue
+ *	vq: the struct virtqueue we're talking about.
+ *	Returns remaining capacity of the queue.
  * virtqueue_disable_cb: disable callbacks
  *	vq: the struct virtqueue we're talking about.
  *	Note that this is not necessarily synchronous, hence unreliable and only
@@ -82,6 +85,8 @@ void virtqueue_kick(struct virtqueue *vq);
 
 void *virtqueue_get_buf(struct virtqueue *vq, unsigned int *len);
 
+int virtqueue_get_capacity(struct virtqueue *vq);
+
 void virtqueue_disable_cb(struct virtqueue *vq);
 
 bool virtqueue_enable_cb(struct virtqueue *vq);


