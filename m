From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 16/18] virtio_ring: Add capacity check API
Date: Wed, 4 May 2011 23:52:53 +0300
Message-ID: <e31be233fa2f0831d1e6d85a2c474d5c488d2a2f.1304541919.git.mst@redhat.com>
References: <cover.1304541918.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2@in.ibm.com>, Carsten Otte <cotte@de.ibm.com>,
        lguest@lists.ozlabs.org, Shirley Ma <xma@us.ibm.com>,
        kvm@vger.kernel.org, linux-s390@vger.kernel.org,
        netdev@vger.kernel.org, habanero@linux.vnet.ibm.com,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        linux-kernel@vger.kernel.org,
        virtualization@lists.linux-foundation.org, steved@us.ibm.com,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        Tom Lendacky <tahm@linux.vnet.ibm.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>, linux390@de.ibm.com
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <cover.1304541918.git.mst@redhat.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

>From: Shirley Ma <mashirle@us.ibm.com>

Signed-off-by: Shirley Ma <xma@us.ibm.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

I'm not sure who wrote this first anymore :)
But it's a simple patch.

 drivers/virtio/virtio_ring.c |    8 ++++++++
 include/linux/virtio.h       |    5 +++++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 3a70d70..57bf9d5 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -365,6 +365,14 @@ void *virtqueue_get_buf(struct virtqueue *_vq, unsigned int *len)
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
index 5151fd1..944ebcd 100644
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
@@ -89,6 +92,8 @@ void virtqueue_kick(struct virtqueue *vq);
 
 void *virtqueue_get_buf(struct virtqueue *vq, unsigned int *len);
 
+int virtqueue_get_capacity(struct virtqueue *vq);
+
 void virtqueue_disable_cb(struct virtqueue *vq);
 
 bool virtqueue_enable_cb(struct virtqueue *vq);
-- 
1.7.5.53.gc233e
