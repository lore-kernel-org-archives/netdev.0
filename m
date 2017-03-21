From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 3/8] tun: export skb_array
Date: Tue, 21 Mar 2017 12:04:42 +0800
Message-ID: <1490069087-4783-4-git-send-email-jasowang@redhat.com>
References: <1490069087-4783-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1490069087-4783-1-git-send-email-jasowang@redhat.com>
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
