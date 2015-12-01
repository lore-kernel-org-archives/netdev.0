From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V2 2/3] vhost: introduce vhost_vq_more_avail()
Date: Tue,  1 Dec 2015 14:39:44 +0800
Message-ID: <1448951985-12385-3-git-send-email-jasowang@redhat.com>
References: <1448951985-12385-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448951985-12385-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 13 +++++++++++++
 drivers/vhost/vhost.h |  1 +
 2 files changed, 14 insertions(+)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 163b365..4f45a03 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1633,6 +1633,19 @@ void vhost_add_used_and_signal_n(struct vhost_dev *dev,
 }
 EXPORT_SYMBOL_GPL(vhost_add_used_and_signal_n);
 
+bool vhost_vq_more_avail(struct vhost_dev *dev, struct vhost_virtqueue *vq)
+{
+	__virtio16 avail_idx;
+	int r;
+
+	r = __get_user(avail_idx, &vq->avail->idx);
+	if (r)
+		return false;
+
+	return vhost16_to_cpu(vq, avail_idx) != vq->avail_idx;
+}
+EXPORT_SYMBOL_GPL(vhost_vq_more_avail);
+
 /* OK, now we need to know about added descriptors. */
 bool vhost_enable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 {
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 43284ad..2f3c57c 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -159,6 +159,7 @@ void vhost_add_used_and_signal_n(struct vhost_dev *, struct vhost_virtqueue *,
 			       struct vring_used_elem *heads, unsigned count);
 void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
 void vhost_disable_notify(struct vhost_dev *, struct vhost_virtqueue *);
+bool vhost_vq_more_avail(struct vhost_dev *, struct vhost_virtqueue *);
 bool vhost_enable_notify(struct vhost_dev *, struct vhost_virtqueue *);
 
 int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
-- 
2.5.0
