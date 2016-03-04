From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V4 1/3] vhost: introduce vhost_has_work()
Date: Fri,  4 Mar 2016 06:24:51 -0500
Message-ID: <1457090693-55974-2-git-send-email-jasowang@redhat.com>
References: <1457090693-55974-1-git-send-email-jasowang@redhat.com>
Cc: RAPOPORT@il.ibm.com, yang.zhang.wz@gmail.com,
	borntraeger@de.ibm.com, Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457090693-55974-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This path introduces a helper which can give a hint for whether or not
there's a work queued in the work list. This could be used for busy
polling code to exit the busy loop.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 7 +++++++
 drivers/vhost/vhost.h | 1 +
 2 files changed, 8 insertions(+)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index ad2146a..90ac092 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -245,6 +245,13 @@ void vhost_work_queue(struct vhost_dev *dev, struct vhost_work *work)
 }
 EXPORT_SYMBOL_GPL(vhost_work_queue);
 
+/* A lockless hint for busy polling code to exit the loop */
+bool vhost_has_work(struct vhost_dev *dev)
+{
+	return !list_empty(&dev->work_list);
+}
+EXPORT_SYMBOL_GPL(vhost_has_work);
+
 void vhost_poll_queue(struct vhost_poll *poll)
 {
 	vhost_work_queue(poll->dev, &poll->work);
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index d3f7674..43284ad 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -37,6 +37,7 @@ struct vhost_poll {
 
 void vhost_work_init(struct vhost_work *work, vhost_work_fn_t fn);
 void vhost_work_queue(struct vhost_dev *dev, struct vhost_work *work);
+bool vhost_has_work(struct vhost_dev *dev);
 
 void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
 		     unsigned long mask, struct vhost_dev *dev);
-- 
1.8.3.1
