From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V2 net-next 4/7] tap: export skb_array
Date: Thu, 30 Mar 2017 15:22:27 +0800
Message-ID: <1490858550-7763-5-git-send-email-jasowang@redhat.com>
References: <1490858550-7763-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490858550-7763-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch exports skb_array through tap_get_skb_array(). Caller can
then manipulate skb array directly.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tap.c      | 13 +++++++++++++
 include/linux/if_tap.h |  5 +++++
 2 files changed, 18 insertions(+)

diff --git a/drivers/net/tap.c b/drivers/net/tap.c
index 4d4173d..abdaf86 100644
--- a/drivers/net/tap.c
+++ b/drivers/net/tap.c
@@ -1193,6 +1193,19 @@ struct socket *tap_get_socket(struct file *file)
 }
 EXPORT_SYMBOL_GPL(tap_get_socket);
 
+struct skb_array *tap_get_skb_array(struct file *file)
+{
+	struct tap_queue *q;
+
+	if (file->f_op != &tap_fops)
+		return ERR_PTR(-EINVAL);
+	q = file->private_data;
+	if (!q)
+		return ERR_PTR(-EBADFD);
+	return &q->skb_array;
+}
+EXPORT_SYMBOL_GPL(tap_get_skb_array);
+
 int tap_queue_resize(struct tap_dev *tap)
 {
 	struct net_device *dev = tap->dev;
diff --git a/include/linux/if_tap.h b/include/linux/if_tap.h
index 3482c3c..4837157 100644
--- a/include/linux/if_tap.h
+++ b/include/linux/if_tap.h
@@ -3,6 +3,7 @@
 
 #if IS_ENABLED(CONFIG_TAP)
 struct socket *tap_get_socket(struct file *);
+struct skb_array *tap_get_skb_array(struct file *file);
 #else
 #include <linux/err.h>
 #include <linux/errno.h>
@@ -12,6 +13,10 @@ static inline struct socket *tap_get_socket(struct file *f)
 {
 	return ERR_PTR(-EINVAL);
 }
+static inline struct skb_array *tap_get_skb_array(struct file *f)
+{
+	return ERR_PTR(-EINVAL);
+}
 #endif /* CONFIG_TAP */
 
 #include <net/sock.h>
-- 
2.7.4
