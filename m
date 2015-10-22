From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next RFC 1/2] vhost: introduce vhost_has_work()
Date: Thu, 22 Oct 2015 01:27:28 -0400
Message-ID: <1445491649-62614-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

This path introduces a helper which can give a hint for whether or not
there's a work queued in the work list.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 6 ++++++
 drivers/vhost/vhost.h | 1 +
 2 files changed, 7 insertions(+)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index eec2f11..d42d11e 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -245,6 +245,12 @@ void vhost_work_queue(struct vhost_dev *dev, struct vhost_work *work)
 }
 EXPORT_SYMBOL_GPL(vhost_work_queue);
 
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
index 4772862..ea0327d 100644
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
