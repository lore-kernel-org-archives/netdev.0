From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v7 28/46] vhost: make features 64 bit
Date: Sun, 30 Nov 2014 17:11:34 +0200
Message-ID: <1417359787-10138-29-git-send-email-mst@redhat.com>
References: <1417359787-10138-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cornelia.huck@de.ibm.com,
	rusty@au1.ibm.com, nab@linux-iscsi.org, pbonzini@redhat.com,
	thuth@linux.vnet.ibm.com, dahi@linux.vnet.ibm.com,
	Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1417359787-10138-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We need to use bit 32 for virtio 1.0

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Reviewed-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 3eda654..c624b09 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -106,7 +106,7 @@ struct vhost_virtqueue {
 	/* Protected by virtqueue mutex. */
 	struct vhost_memory *memory;
 	void *private_data;
-	unsigned acked_features;
+	u64 acked_features;
 	/* Log write descriptors */
 	void __user *log_base;
 	struct vhost_log *log;
@@ -174,6 +174,6 @@ enum {
 
 static inline int vhost_has_feature(struct vhost_virtqueue *vq, int bit)
 {
-	return vq->acked_features & (1 << bit);
+	return vq->acked_features & (1ULL << bit);
 }
 #endif
-- 
MST
