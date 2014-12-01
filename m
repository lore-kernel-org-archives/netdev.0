From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v8 29/50] vhost: make features 64 bit
Date: Mon, 1 Dec 2014 18:05:09 +0200
Message-ID: <1417449619-24896-30-git-send-email-mst@redhat.com>
References: <1417449619-24896-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cornelia.huck@de.ibm.com,
	rusty@au1.ibm.com, nab@linux-iscsi.org, pbonzini@redhat.com,
	thuth@linux.vnet.ibm.com, dahi@linux.vnet.ibm.com,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1417449619-24896-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We need to use bit 32 for virtio 1.0.
Make vhost_has_feature bool to avoid discarding high bits.

Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Cc: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Reviewed-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 3eda654..55a95c9 100644
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
@@ -172,8 +172,8 @@ enum {
 			 (1ULL << VHOST_F_LOG_ALL),
 };
 
-static inline int vhost_has_feature(struct vhost_virtqueue *vq, int bit)
+static inline bool vhost_has_feature(struct vhost_virtqueue *vq, int bit)
 {
-	return vq->acked_features & (1 << bit);
+	return vq->acked_features & (1ULL << bit);
 }
 #endif
-- 
MST
