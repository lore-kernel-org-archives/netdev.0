From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 01/20] batman-adv: Prefix bat_debugfs local
	static functions with batadv_
Date: Mon, 25 Jun 2012 08:54:25 +0200
Message-ID: <1340607284-29950-2-git-send-email-ordex@autistici.org>
References: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1340607284-29950-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

All non-static symbols of batman-adv were prefixed with batadv_ to avoid
collisions with other symbols of the kernel. Other symbols of batman-adv
should use the same prefix to keep the naming scheme consistent.

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/bat_debugfs.c |  143 +++++++++++++++++++++---------------------
 1 file changed, 72 insertions(+), 71 deletions(-)

diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
index 4001c57..03f09f0 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -32,25 +32,25 @@
 #include "icmp_socket.h"
 #include "bridge_loop_avoidance.h"
 
-static struct dentry *bat_debugfs;
+static struct dentry *batadv_debugfs;
 
 #ifdef CONFIG_BATMAN_ADV_DEBUG
-#define LOG_BUFF_MASK (log_buff_len-1)
+#define LOG_BUFF_MASK (batadv_log_buff_len - 1)
 #define LOG_BUFF(idx) (debug_log->log_buff[(idx) & LOG_BUFF_MASK])
 
-static int log_buff_len = LOG_BUF_LEN;
+static int batadv_log_buff_len = LOG_BUF_LEN;
 
-static void emit_log_char(struct debug_log *debug_log, char c)
+static void batadv_emit_log_char(struct debug_log *debug_log, char c)
 {
 	LOG_BUFF(debug_log->log_end) = c;
 	debug_log->log_end++;
 
-	if (debug_log->log_end - debug_log->log_start > log_buff_len)
-		debug_log->log_start = debug_log->log_end - log_buff_len;
+	if (debug_log->log_end - debug_log->log_start > batadv_log_buff_len)
+		debug_log->log_start = debug_log->log_end - batadv_log_buff_len;
 }
 
 __printf(2, 3)
-static int fdebug_log(struct debug_log *debug_log, const char *fmt, ...)
+static int batadv_fdebug_log(struct debug_log *debug_log, const char *fmt, ...)
 {
 	va_list args;
 	static char debug_log_buf[256];
@@ -65,7 +65,7 @@ static int fdebug_log(struct debug_log *debug_log, const char *fmt, ...)
 	va_end(args);
 
 	for (p = debug_log_buf; *p != 0; p++)
-		emit_log_char(debug_log, *p);
+		batadv_emit_log_char(debug_log, *p);
 
 	spin_unlock_bh(&debug_log->lock);
 
@@ -81,14 +81,14 @@ int batadv_debug_log(struct bat_priv *bat_priv, const char *fmt, ...)
 
 	va_start(args, fmt);
 	vscnprintf(tmp_log_buf, sizeof(tmp_log_buf), fmt, args);
-	fdebug_log(bat_priv->debug_log, "[%10u] %s",
-		   jiffies_to_msecs(jiffies), tmp_log_buf);
+	batadv_fdebug_log(bat_priv->debug_log, "[%10u] %s",
+			  jiffies_to_msecs(jiffies), tmp_log_buf);
 	va_end(args);
 
 	return 0;
 }
 
-static int log_open(struct inode *inode, struct file *file)
+static int batadv_log_open(struct inode *inode, struct file *file)
 {
 	nonseekable_open(inode, file);
 	file->private_data = inode->i_private;
@@ -96,14 +96,14 @@ static int log_open(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static int log_release(struct inode *inode, struct file *file)
+static int batadv_log_release(struct inode *inode, struct file *file)
 {
 	batadv_dec_module_count();
 	return 0;
 }
 
-static ssize_t log_read(struct file *file, char __user *buf,
-			size_t count, loff_t *ppos)
+static ssize_t batadv_log_read(struct file *file, char __user *buf,
+			       size_t count, loff_t *ppos)
 {
 	struct bat_priv *bat_priv = file->private_data;
 	struct debug_log *debug_log = bat_priv->debug_log;
@@ -156,7 +156,7 @@ static ssize_t log_read(struct file *file, char __user *buf,
 	return error;
 }
 
-static unsigned int log_poll(struct file *file, poll_table *wait)
+static unsigned int batadv_log_poll(struct file *file, poll_table *wait)
 {
 	struct bat_priv *bat_priv = file->private_data;
 	struct debug_log *debug_log = bat_priv->debug_log;
@@ -169,15 +169,15 @@ static unsigned int log_poll(struct file *file, poll_table *wait)
 	return 0;
 }
 
-static const struct file_operations log_fops = {
-	.open           = log_open,
-	.release        = log_release,
-	.read           = log_read,
-	.poll           = log_poll,
+static const struct file_operations batadv_log_fops = {
+	.open           = batadv_log_open,
+	.release        = batadv_log_release,
+	.read           = batadv_log_read,
+	.poll           = batadv_log_poll,
 	.llseek         = no_llseek,
 };
 
-static int debug_log_setup(struct bat_priv *bat_priv)
+static int batadv_debug_log_setup(struct bat_priv *bat_priv)
 {
 	struct dentry *d;
 
@@ -192,7 +192,8 @@ static int debug_log_setup(struct bat_priv *bat_priv)
 	init_waitqueue_head(&bat_priv->debug_log->queue_wait);
 
 	d = debugfs_create_file("log", S_IFREG | S_IRUSR,
-				bat_priv->debug_dir, bat_priv, &log_fops);
+				bat_priv->debug_dir, bat_priv,
+				&batadv_log_fops);
 	if (!d)
 		goto err;
 
@@ -202,49 +203,49 @@ err:
 	return -ENOMEM;
 }
 
-static void debug_log_cleanup(struct bat_priv *bat_priv)
+static void batadv_debug_log_cleanup(struct bat_priv *bat_priv)
 {
 	kfree(bat_priv->debug_log);
 	bat_priv->debug_log = NULL;
 }
 #else /* CONFIG_BATMAN_ADV_DEBUG */
-static int debug_log_setup(struct bat_priv *bat_priv)
+static int batadv_debug_log_setup(struct bat_priv *bat_priv)
 {
 	bat_priv->debug_log = NULL;
 	return 0;
 }
 
-static void debug_log_cleanup(struct bat_priv *bat_priv)
+static void batadv_debug_log_cleanup(struct bat_priv *bat_priv)
 {
 	return;
 }
 #endif
 
-static int bat_algorithms_open(struct inode *inode, struct file *file)
+static int batadv_algorithms_open(struct inode *inode, struct file *file)
 {
 	return single_open(file, batadv_algo_seq_print_text, NULL);
 }
 
-static int originators_open(struct inode *inode, struct file *file)
+static int batadv_originators_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
 	return single_open(file, batadv_orig_seq_print_text, net_dev);
 }
 
-static int gateways_open(struct inode *inode, struct file *file)
+static int batadv_gateways_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
 	return single_open(file, batadv_gw_client_seq_print_text, net_dev);
 }
 
-static int transtable_global_open(struct inode *inode, struct file *file)
+static int batadv_transtable_global_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
 	return single_open(file, batadv_tt_global_seq_print_text, net_dev);
 }
 
 #ifdef CONFIG_BATMAN_ADV_BLA
-static int bla_claim_table_open(struct inode *inode, struct file *file)
+static int batadv_bla_claim_table_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
 	return single_open(file, batadv_bla_claim_table_seq_print_text,
@@ -252,13 +253,13 @@ static int bla_claim_table_open(struct inode *inode, struct file *file)
 }
 #endif
 
-static int transtable_local_open(struct inode *inode, struct file *file)
+static int batadv_transtable_local_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
 	return single_open(file, batadv_tt_local_seq_print_text, net_dev);
 }
 
-static int vis_data_open(struct inode *inode, struct file *file)
+static int batadv_vis_data_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
 	return single_open(file, batadv_vis_seq_print_text, net_dev);
@@ -269,37 +270,37 @@ struct bat_debuginfo {
 	const struct file_operations fops;
 };
 
-#define BAT_DEBUGINFO(_name, _mode, _open)	\
-struct bat_debuginfo bat_debuginfo_##_name = {	\
-	.attr = { .name = __stringify(_name),	\
-		  .mode = _mode, },		\
-	.fops = { .owner = THIS_MODULE,		\
-		  .open = _open,		\
-		  .read	= seq_read,		\
-		  .llseek = seq_lseek,		\
-		  .release = single_release,	\
-		}				\
+#define BAT_DEBUGINFO(_name, _mode, _open)		\
+struct bat_debuginfo batadv_debuginfo_##_name = {	\
+	.attr = { .name = __stringify(_name),		\
+		  .mode = _mode, },			\
+	.fops = { .owner = THIS_MODULE,			\
+		  .open = _open,			\
+		  .read	= seq_read,			\
+		  .llseek = seq_lseek,			\
+		  .release = single_release,		\
+		}					\
 };
 
-static BAT_DEBUGINFO(routing_algos, S_IRUGO, bat_algorithms_open);
-static BAT_DEBUGINFO(originators, S_IRUGO, originators_open);
-static BAT_DEBUGINFO(gateways, S_IRUGO, gateways_open);
-static BAT_DEBUGINFO(transtable_global, S_IRUGO, transtable_global_open);
+static BAT_DEBUGINFO(routing_algos, S_IRUGO, batadv_algorithms_open);
+static BAT_DEBUGINFO(originators, S_IRUGO, batadv_originators_open);
+static BAT_DEBUGINFO(gateways, S_IRUGO, batadv_gateways_open);
+static BAT_DEBUGINFO(transtable_global, S_IRUGO, batadv_transtable_global_open);
 #ifdef CONFIG_BATMAN_ADV_BLA
-static BAT_DEBUGINFO(bla_claim_table, S_IRUGO, bla_claim_table_open);
+static BAT_DEBUGINFO(bla_claim_table, S_IRUGO, batadv_bla_claim_table_open);
 #endif
-static BAT_DEBUGINFO(transtable_local, S_IRUGO, transtable_local_open);
-static BAT_DEBUGINFO(vis_data, S_IRUGO, vis_data_open);
+static BAT_DEBUGINFO(transtable_local, S_IRUGO, batadv_transtable_local_open);
+static BAT_DEBUGINFO(vis_data, S_IRUGO, batadv_vis_data_open);
 
-static struct bat_debuginfo *mesh_debuginfos[] = {
-	&bat_debuginfo_originators,
-	&bat_debuginfo_gateways,
-	&bat_debuginfo_transtable_global,
+static struct bat_debuginfo *batadv_mesh_debuginfos[] = {
+	&batadv_debuginfo_originators,
+	&batadv_debuginfo_gateways,
+	&batadv_debuginfo_transtable_global,
 #ifdef CONFIG_BATMAN_ADV_BLA
-	&bat_debuginfo_bla_claim_table,
+	&batadv_debuginfo_bla_claim_table,
 #endif
-	&bat_debuginfo_transtable_local,
-	&bat_debuginfo_vis_data,
+	&batadv_debuginfo_transtable_local,
+	&batadv_debuginfo_vis_data,
 	NULL,
 };
 
@@ -308,17 +309,17 @@ void batadv_debugfs_init(void)
 	struct bat_debuginfo *bat_debug;
 	struct dentry *file;
 
-	bat_debugfs = debugfs_create_dir(DEBUGFS_BAT_SUBDIR, NULL);
-	if (bat_debugfs == ERR_PTR(-ENODEV))
-		bat_debugfs = NULL;
+	batadv_debugfs = debugfs_create_dir(DEBUGFS_BAT_SUBDIR, NULL);
+	if (batadv_debugfs == ERR_PTR(-ENODEV))
+		batadv_debugfs = NULL;
 
-	if (!bat_debugfs)
+	if (!batadv_debugfs)
 		goto out;
 
-	bat_debug = &bat_debuginfo_routing_algos;
+	bat_debug = &batadv_debuginfo_routing_algos;
 	file = debugfs_create_file(bat_debug->attr.name,
 				   S_IFREG | bat_debug->attr.mode,
-				   bat_debugfs, NULL, &bat_debug->fops);
+				   batadv_debugfs, NULL, &bat_debug->fops);
 	if (!file)
 		pr_err("Can't add debugfs file: %s\n", bat_debug->attr.name);
 
@@ -328,9 +329,9 @@ out:
 
 void batadv_debugfs_destroy(void)
 {
-	if (bat_debugfs) {
-		debugfs_remove_recursive(bat_debugfs);
-		bat_debugfs = NULL;
+	if (batadv_debugfs) {
+		debugfs_remove_recursive(batadv_debugfs);
+		batadv_debugfs = NULL;
 	}
 }
 
@@ -340,20 +341,20 @@ int batadv_debugfs_add_meshif(struct net_device *dev)
 	struct bat_debuginfo **bat_debug;
 	struct dentry *file;
 
-	if (!bat_debugfs)
+	if (!batadv_debugfs)
 		goto out;
 
-	bat_priv->debug_dir = debugfs_create_dir(dev->name, bat_debugfs);
+	bat_priv->debug_dir = debugfs_create_dir(dev->name, batadv_debugfs);
 	if (!bat_priv->debug_dir)
 		goto out;
 
 	if (batadv_socket_setup(bat_priv) < 0)
 		goto rem_attr;
 
-	if (debug_log_setup(bat_priv) < 0)
+	if (batadv_debug_log_setup(bat_priv) < 0)
 		goto rem_attr;
 
-	for (bat_debug = mesh_debuginfos; *bat_debug; ++bat_debug) {
+	for (bat_debug = batadv_mesh_debuginfos; *bat_debug; ++bat_debug) {
 		file = debugfs_create_file(((*bat_debug)->attr).name,
 					  S_IFREG | ((*bat_debug)->attr).mode,
 					  bat_priv->debug_dir,
@@ -381,9 +382,9 @@ void batadv_debugfs_del_meshif(struct net_device *dev)
 {
 	struct bat_priv *bat_priv = netdev_priv(dev);
 
-	debug_log_cleanup(bat_priv);
+	batadv_debug_log_cleanup(bat_priv);
 
-	if (bat_debugfs) {
+	if (batadv_debugfs) {
 		debugfs_remove_recursive(bat_priv->debug_dir);
 		bat_priv->debug_dir = NULL;
 	}
-- 
1.7.9.4
