From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V2 net-next 3/7] tun: export skb_array
Date: Thu, 30 Mar 2017 15:22:26 +0800
Message-ID: <1490858550-7763-4-git-send-email-jasowang@redhat.com>
References: <1490858550-7763-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490858550-7763-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch exports skb_array through tun_get_skb_array(). Caller can
then manipulate skb array directly.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c      | 13 +++++++++++++
 include/linux/if_tun.h |  5 +++++
 2 files changed, 18 insertions(+)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index c418f0a..70dd9ec 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -2613,6 +2613,19 @@ struct socket *tun_get_socket(struct file *file)
 }
 EXPORT_SYMBOL_GPL(tun_get_socket);
 
+struct skb_array *tun_get_skb_array(struct file *file)
+{
+	struct tun_file *tfile;
+
+	if (file->f_op != &tun_fops)
+		return ERR_PTR(-EINVAL);
+	tfile = file->private_data;
+	if (!tfile)
+		return ERR_PTR(-EBADFD);
+	return &tfile->tx_array;
+}
+EXPORT_SYMBOL_GPL(tun_get_skb_array);
+
 module_init(tun_init);
 module_exit(tun_cleanup);
 MODULE_DESCRIPTION(DRV_DESCRIPTION);
diff --git a/include/linux/if_tun.h b/include/linux/if_tun.h
index ed6da2e..bf9bdf4 100644
--- a/include/linux/if_tun.h
+++ b/include/linux/if_tun.h
@@ -19,6 +19,7 @@
 
 #if defined(CONFIG_TUN) || defined(CONFIG_TUN_MODULE)
 struct socket *tun_get_socket(struct file *);
+struct skb_array *tun_get_skb_array(struct file *file);
 #else
 #include <linux/err.h>
 #include <linux/errno.h>
@@ -28,5 +29,9 @@ static inline struct socket *tun_get_socket(struct file *f)
 {
 	return ERR_PTR(-EINVAL);
 }
+static inline struct skb_array *tun_get_skb_array(struct file *f)
+{
+	return ERR_PTR(-EINVAL);
+}
 #endif /* CONFIG_TUN */
 #endif /* __IF_TUN_H */
-- 
2.7.4
