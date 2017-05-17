From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V5 5/9] tun: export skb_array
Date: Wed, 17 May 2017 12:14:41 +0800
Message-ID: <1494994485-12994-6-git-send-email-jasowang@redhat.com>
References: <1494994485-12994-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42206 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752330AbdEQEPb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 00:15:31 -0400
In-Reply-To: <1494994485-12994-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch exports skb_array through tun_get_skb_array(). Caller can
then manipulate skb array directly.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c      | 13 +++++++++++++
 include/linux/if_tun.h |  5 +++++
 2 files changed, 18 insertions(+)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index bbd707b..3cbfc5c 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -2626,6 +2626,19 @@ struct socket *tun_get_socket(struct file *file)
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
