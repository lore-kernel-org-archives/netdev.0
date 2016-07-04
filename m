From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 05/11] batman-adv: Consolidate logging
	related functions
Date: Mon,  4 Jul 2016 15:02:53 +0200
Message-ID: <1467637379-6089-6-git-send-email-sw@simonwunderlich.de>
References: <1467637379-6089-1-git-send-email-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1467637379-6089-1-git-send-email-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

There are several places in batman-adv which provide logging related
functions. These should be grouped together in the log.* files to make them
easier to find.

Reported-by: Markus Pargmann <mpa-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/Makefile                |   1 +
 net/batman-adv/bat_iv_ogm.c            |   1 +
 net/batman-adv/bat_v_elp.c             |   1 +
 net/batman-adv/bat_v_ogm.c             |   1 +
 net/batman-adv/bitarray.c              |   2 +
 net/batman-adv/bridge_loop_avoidance.c |   1 +
 net/batman-adv/debugfs.c               | 216 +-----------------------------
 net/batman-adv/distributed-arp-table.c |   1 +
 net/batman-adv/gateway_client.c        |   1 +
 net/batman-adv/gateway_common.c        |   1 +
 net/batman-adv/hard-interface.c        |   1 +
 net/batman-adv/icmp_socket.c           |   1 +
 net/batman-adv/log.c                   | 231 +++++++++++++++++++++++++++++++++
 net/batman-adv/log.h                   | 109 ++++++++++++++++
 net/batman-adv/main.c                  |   2 +
 net/batman-adv/main.h                  |  69 +---------
 net/batman-adv/multicast.c             |   1 +
 net/batman-adv/network-coding.c        |   1 +
 net/batman-adv/originator.c            |   1 +
 net/batman-adv/routing.c               |   1 +
 net/batman-adv/send.c                  |   1 +
 net/batman-adv/sysfs.c                 |   1 +
 net/batman-adv/translation-table.c     |   1 +
 23 files changed, 364 insertions(+), 282 deletions(-)
 create mode 100644 net/batman-adv/log.c
 create mode 100644 net/batman-adv/log.h

diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index 5260c17..a55f4ec 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -32,6 +32,7 @@ batman-adv-y += gateway_common.o
 batman-adv-y += hard-interface.o
 batman-adv-y += hash.o
 batman-adv-y += icmp_socket.o
+batman-adv-$(CONFIG_BATMAN_ADV_DEBUG) += log.o
 batman-adv-y += main.o
 batman-adv-$(CONFIG_BATMAN_ADV_MCAST) += multicast.o
 batman-adv-$(CONFIG_BATMAN_ADV_NC) += network-coding.o
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 948a5b4..805532a 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -52,6 +52,7 @@
 #include "bitarray.h"
 #include "hard-interface.h"
 #include "hash.h"
+#include "log.h"
 #include "network-coding.h"
 #include "originator.h"
 #include "packet.h"
diff --git a/net/batman-adv/bat_v_elp.c b/net/batman-adv/bat_v_elp.c
index cf0262b..15cf272 100644
--- a/net/batman-adv/bat_v_elp.c
+++ b/net/batman-adv/bat_v_elp.c
@@ -43,6 +43,7 @@
 #include "bat_algo.h"
 #include "bat_v_ogm.h"
 #include "hard-interface.h"
+#include "log.h"
 #include "originator.h"
 #include "packet.h"
 #include "routing.h"
diff --git a/net/batman-adv/bat_v_ogm.c b/net/batman-adv/bat_v_ogm.c
index 93e3d76..7ac9e0b 100644
--- a/net/batman-adv/bat_v_ogm.c
+++ b/net/batman-adv/bat_v_ogm.c
@@ -42,6 +42,7 @@
 #include "bat_algo.h"
 #include "hard-interface.h"
 #include "hash.h"
+#include "log.h"
 #include "originator.h"
 #include "packet.h"
 #include "routing.h"
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index a0c7913..0322714 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -20,6 +20,8 @@
 
 #include <linux/bitmap.h>
 
+#include "log.h"
+
 /* shift the packet array by n places. */
 static void batadv_bitmap_shift_left(unsigned long *seq_bits, s32 n)
 {
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 748a9ea..e4f7494 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -48,6 +48,7 @@
 
 #include "hard-interface.h"
 #include "hash.h"
+#include "log.h"
 #include "originator.h"
 #include "packet.h"
 #include "sysfs.h"
diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index 227c84b..1d68b6e 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -18,37 +18,26 @@
 #include "debugfs.h"
 #include "main.h"
 
-#include <linux/compiler.h>
 #include <linux/debugfs.h>
 #include <linux/device.h>
 #include <linux/errno.h>
 #include <linux/export.h>
-#include <linux/fcntl.h>
 #include <linux/fs.h>
-#include <linux/jiffies.h>
-#include <linux/kernel.h>
-#include <linux/module.h>
 #include <linux/netdevice.h>
-#include <linux/poll.h>
 #include <linux/printk.h>
 #include <linux/sched.h> /* for linux/wait.h */
 #include <linux/seq_file.h>
-#include <linux/slab.h>
-#include <linux/spinlock.h>
 #include <linux/stat.h>
 #include <linux/stddef.h>
 #include <linux/stringify.h>
 #include <linux/sysfs.h>
-#include <linux/types.h>
-#include <linux/uaccess.h>
-#include <linux/wait.h>
-#include <stdarg.h>
 
 #include "bat_algo.h"
 #include "bridge_loop_avoidance.h"
 #include "distributed-arp-table.h"
 #include "gateway_client.h"
 #include "icmp_socket.h"
+#include "log.h"
 #include "multicast.h"
 #include "network-coding.h"
 #include "originator.h"
@@ -56,209 +45,6 @@
 
 static struct dentry *batadv_debugfs;
 
-#ifdef CONFIG_BATMAN_ADV_DEBUG
-#define BATADV_LOG_BUFF_MASK (batadv_log_buff_len - 1)
-
-static const int batadv_log_buff_len = BATADV_LOG_BUF_LEN;
-
-static char *batadv_log_char_addr(struct batadv_priv_debug_log *debug_log,
-				  size_t idx)
-{
-	return &debug_log->log_buff[idx & BATADV_LOG_BUFF_MASK];
-}
-
-static void batadv_emit_log_char(struct batadv_priv_debug_log *debug_log,
-				 char c)
-{
-	char *char_addr;
-
-	char_addr = batadv_log_char_addr(debug_log, debug_log->log_end);
-	*char_addr = c;
-	debug_log->log_end++;
-
-	if (debug_log->log_end - debug_log->log_start > batadv_log_buff_len)
-		debug_log->log_start = debug_log->log_end - batadv_log_buff_len;
-}
-
-__printf(2, 3)
-static int batadv_fdebug_log(struct batadv_priv_debug_log *debug_log,
-			     const char *fmt, ...)
-{
-	va_list args;
-	static char debug_log_buf[256];
-	char *p;
-
-	if (!debug_log)
-		return 0;
-
-	spin_lock_bh(&debug_log->lock);
-	va_start(args, fmt);
-	vscnprintf(debug_log_buf, sizeof(debug_log_buf), fmt, args);
-	va_end(args);
-
-	for (p = debug_log_buf; *p != 0; p++)
-		batadv_emit_log_char(debug_log, *p);
-
-	spin_unlock_bh(&debug_log->lock);
-
-	wake_up(&debug_log->queue_wait);
-
-	return 0;
-}
-
-int batadv_debug_log(struct batadv_priv *bat_priv, const char *fmt, ...)
-{
-	va_list args;
-	char tmp_log_buf[256];
-
-	va_start(args, fmt);
-	vscnprintf(tmp_log_buf, sizeof(tmp_log_buf), fmt, args);
-	batadv_fdebug_log(bat_priv->debug_log, "[%10u] %s",
-			  jiffies_to_msecs(jiffies), tmp_log_buf);
-	va_end(args);
-
-	return 0;
-}
-
-static int batadv_log_open(struct inode *inode, struct file *file)
-{
-	if (!try_module_get(THIS_MODULE))
-		return -EBUSY;
-
-	nonseekable_open(inode, file);
-	file->private_data = inode->i_private;
-	return 0;
-}
-
-static int batadv_log_release(struct inode *inode, struct file *file)
-{
-	module_put(THIS_MODULE);
-	return 0;
-}
-
-static bool batadv_log_empty(struct batadv_priv_debug_log *debug_log)
-{
-	return !(debug_log->log_start - debug_log->log_end);
-}
-
-static ssize_t batadv_log_read(struct file *file, char __user *buf,
-			       size_t count, loff_t *ppos)
-{
-	struct batadv_priv *bat_priv = file->private_data;
-	struct batadv_priv_debug_log *debug_log = bat_priv->debug_log;
-	int error, i = 0;
-	char *char_addr;
-	char c;
-
-	if ((file->f_flags & O_NONBLOCK) && batadv_log_empty(debug_log))
-		return -EAGAIN;
-
-	if (!buf)
-		return -EINVAL;
-
-	if (count == 0)
-		return 0;
-
-	if (!access_ok(VERIFY_WRITE, buf, count))
-		return -EFAULT;
-
-	error = wait_event_interruptible(debug_log->queue_wait,
-					 (!batadv_log_empty(debug_log)));
-
-	if (error)
-		return error;
-
-	spin_lock_bh(&debug_log->lock);
-
-	while ((!error) && (i < count) &&
-	       (debug_log->log_start != debug_log->log_end)) {
-		char_addr = batadv_log_char_addr(debug_log,
-						 debug_log->log_start);
-		c = *char_addr;
-
-		debug_log->log_start++;
-
-		spin_unlock_bh(&debug_log->lock);
-
-		error = __put_user(c, buf);
-
-		spin_lock_bh(&debug_log->lock);
-
-		buf++;
-		i++;
-	}
-
-	spin_unlock_bh(&debug_log->lock);
-
-	if (!error)
-		return i;
-
-	return error;
-}
-
-static unsigned int batadv_log_poll(struct file *file, poll_table *wait)
-{
-	struct batadv_priv *bat_priv = file->private_data;
-	struct batadv_priv_debug_log *debug_log = bat_priv->debug_log;
-
-	poll_wait(file, &debug_log->queue_wait, wait);
-
-	if (!batadv_log_empty(debug_log))
-		return POLLIN | POLLRDNORM;
-
-	return 0;
-}
-
-static const struct file_operations batadv_log_fops = {
-	.open           = batadv_log_open,
-	.release        = batadv_log_release,
-	.read           = batadv_log_read,
-	.poll           = batadv_log_poll,
-	.llseek         = no_llseek,
-};
-
-static int batadv_debug_log_setup(struct batadv_priv *bat_priv)
-{
-	struct dentry *d;
-
-	if (!bat_priv->debug_dir)
-		goto err;
-
-	bat_priv->debug_log = kzalloc(sizeof(*bat_priv->debug_log), GFP_ATOMIC);
-	if (!bat_priv->debug_log)
-		goto err;
-
-	spin_lock_init(&bat_priv->debug_log->lock);
-	init_waitqueue_head(&bat_priv->debug_log->queue_wait);
-
-	d = debugfs_create_file("log", S_IFREG | S_IRUSR,
-				bat_priv->debug_dir, bat_priv,
-				&batadv_log_fops);
-	if (!d)
-		goto err;
-
-	return 0;
-
-err:
-	return -ENOMEM;
-}
-
-static void batadv_debug_log_cleanup(struct batadv_priv *bat_priv)
-{
-	kfree(bat_priv->debug_log);
-	bat_priv->debug_log = NULL;
-}
-#else /* CONFIG_BATMAN_ADV_DEBUG */
-static int batadv_debug_log_setup(struct batadv_priv *bat_priv)
-{
-	return 0;
-}
-
-static void batadv_debug_log_cleanup(struct batadv_priv *bat_priv)
-{
-}
-#endif
-
 static int batadv_algorithms_open(struct inode *inode, struct file *file)
 {
 	return single_open(file, batadv_algo_seq_print_text, NULL);
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 584b827..fa76465 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -45,6 +45,7 @@
 
 #include "hard-interface.h"
 #include "hash.h"
+#include "log.h"
 #include "originator.h"
 #include "send.h"
 #include "translation-table.h"
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 18c3715..63a805d 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -42,6 +42,7 @@
 
 #include "gateway_common.h"
 #include "hard-interface.h"
+#include "log.h"
 #include "originator.h"
 #include "packet.h"
 #include "routing.h"
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index 6a6f2d4..d7bc6a8 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -28,6 +28,7 @@
 #include <linux/string.h>
 
 #include "gateway_client.h"
+#include "log.h"
 #include "packet.h"
 #include "tvlv.h"
 
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index a3483f6..ad2c37c 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -42,6 +42,7 @@
 #include "debugfs.h"
 #include "distributed-arp-table.h"
 #include "gateway_client.h"
+#include "log.h"
 #include "originator.h"
 #include "packet.h"
 #include "send.h"
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 777aea1..378cc11 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -45,6 +45,7 @@
 #include <linux/wait.h>
 
 #include "hard-interface.h"
+#include "log.h"
 #include "originator.h"
 #include "packet.h"
 #include "send.h"
diff --git a/net/batman-adv/log.c b/net/batman-adv/log.c
new file mode 100644
index 0000000..56dc532
--- /dev/null
+++ b/net/batman-adv/log.c
@@ -0,0 +1,231 @@
+/* Copyright (C) 2010-2016  B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include "log.h"
+#include "main.h"
+
+#include <linux/compiler.h>
+#include <linux/debugfs.h>
+#include <linux/errno.h>
+#include <linux/export.h>
+#include <linux/fcntl.h>
+#include <linux/fs.h>
+#include <linux/jiffies.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/poll.h>
+#include <linux/sched.h> /* for linux/wait.h */
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/stat.h>
+#include <linux/stddef.h>
+#include <linux/types.h>
+#include <linux/uaccess.h>
+#include <linux/wait.h>
+#include <stdarg.h>
+
+#define BATADV_LOG_BUFF_MASK (batadv_log_buff_len - 1)
+
+static const int batadv_log_buff_len = BATADV_LOG_BUF_LEN;
+
+static char *batadv_log_char_addr(struct batadv_priv_debug_log *debug_log,
+				  size_t idx)
+{
+	return &debug_log->log_buff[idx & BATADV_LOG_BUFF_MASK];
+}
+
+static void batadv_emit_log_char(struct batadv_priv_debug_log *debug_log,
+				 char c)
+{
+	char *char_addr;
+
+	char_addr = batadv_log_char_addr(debug_log, debug_log->log_end);
+	*char_addr = c;
+	debug_log->log_end++;
+
+	if (debug_log->log_end - debug_log->log_start > batadv_log_buff_len)
+		debug_log->log_start = debug_log->log_end - batadv_log_buff_len;
+}
+
+__printf(2, 3)
+static int batadv_fdebug_log(struct batadv_priv_debug_log *debug_log,
+			     const char *fmt, ...)
+{
+	va_list args;
+	static char debug_log_buf[256];
+	char *p;
+
+	if (!debug_log)
+		return 0;
+
+	spin_lock_bh(&debug_log->lock);
+	va_start(args, fmt);
+	vscnprintf(debug_log_buf, sizeof(debug_log_buf), fmt, args);
+	va_end(args);
+
+	for (p = debug_log_buf; *p != 0; p++)
+		batadv_emit_log_char(debug_log, *p);
+
+	spin_unlock_bh(&debug_log->lock);
+
+	wake_up(&debug_log->queue_wait);
+
+	return 0;
+}
+
+int batadv_debug_log(struct batadv_priv *bat_priv, const char *fmt, ...)
+{
+	va_list args;
+	char tmp_log_buf[256];
+
+	va_start(args, fmt);
+	vscnprintf(tmp_log_buf, sizeof(tmp_log_buf), fmt, args);
+	batadv_fdebug_log(bat_priv->debug_log, "[%10u] %s",
+			  jiffies_to_msecs(jiffies), tmp_log_buf);
+	va_end(args);
+
+	return 0;
+}
+
+static int batadv_log_open(struct inode *inode, struct file *file)
+{
+	if (!try_module_get(THIS_MODULE))
+		return -EBUSY;
+
+	nonseekable_open(inode, file);
+	file->private_data = inode->i_private;
+	return 0;
+}
+
+static int batadv_log_release(struct inode *inode, struct file *file)
+{
+	module_put(THIS_MODULE);
+	return 0;
+}
+
+static bool batadv_log_empty(struct batadv_priv_debug_log *debug_log)
+{
+	return !(debug_log->log_start - debug_log->log_end);
+}
+
+static ssize_t batadv_log_read(struct file *file, char __user *buf,
+			       size_t count, loff_t *ppos)
+{
+	struct batadv_priv *bat_priv = file->private_data;
+	struct batadv_priv_debug_log *debug_log = bat_priv->debug_log;
+	int error, i = 0;
+	char *char_addr;
+	char c;
+
+	if ((file->f_flags & O_NONBLOCK) && batadv_log_empty(debug_log))
+		return -EAGAIN;
+
+	if (!buf)
+		return -EINVAL;
+
+	if (count == 0)
+		return 0;
+
+	if (!access_ok(VERIFY_WRITE, buf, count))
+		return -EFAULT;
+
+	error = wait_event_interruptible(debug_log->queue_wait,
+					 (!batadv_log_empty(debug_log)));
+
+	if (error)
+		return error;
+
+	spin_lock_bh(&debug_log->lock);
+
+	while ((!error) && (i < count) &&
+	       (debug_log->log_start != debug_log->log_end)) {
+		char_addr = batadv_log_char_addr(debug_log,
+						 debug_log->log_start);
+		c = *char_addr;
+
+		debug_log->log_start++;
+
+		spin_unlock_bh(&debug_log->lock);
+
+		error = __put_user(c, buf);
+
+		spin_lock_bh(&debug_log->lock);
+
+		buf++;
+		i++;
+	}
+
+	spin_unlock_bh(&debug_log->lock);
+
+	if (!error)
+		return i;
+
+	return error;
+}
+
+static unsigned int batadv_log_poll(struct file *file, poll_table *wait)
+{
+	struct batadv_priv *bat_priv = file->private_data;
+	struct batadv_priv_debug_log *debug_log = bat_priv->debug_log;
+
+	poll_wait(file, &debug_log->queue_wait, wait);
+
+	if (!batadv_log_empty(debug_log))
+		return POLLIN | POLLRDNORM;
+
+	return 0;
+}
+
+static const struct file_operations batadv_log_fops = {
+	.open           = batadv_log_open,
+	.release        = batadv_log_release,
+	.read           = batadv_log_read,
+	.poll           = batadv_log_poll,
+	.llseek         = no_llseek,
+};
+
+int batadv_debug_log_setup(struct batadv_priv *bat_priv)
+{
+	struct dentry *d;
+
+	if (!bat_priv->debug_dir)
+		goto err;
+
+	bat_priv->debug_log = kzalloc(sizeof(*bat_priv->debug_log), GFP_ATOMIC);
+	if (!bat_priv->debug_log)
+		goto err;
+
+	spin_lock_init(&bat_priv->debug_log->lock);
+	init_waitqueue_head(&bat_priv->debug_log->queue_wait);
+
+	d = debugfs_create_file("log", S_IFREG | S_IRUSR,
+				bat_priv->debug_dir, bat_priv,
+				&batadv_log_fops);
+	if (!d)
+		goto err;
+
+	return 0;
+
+err:
+	return -ENOMEM;
+}
+
+void batadv_debug_log_cleanup(struct batadv_priv *bat_priv)
+{
+	kfree(bat_priv->debug_log);
+	bat_priv->debug_log = NULL;
+}
diff --git a/net/batman-adv/log.h b/net/batman-adv/log.h
new file mode 100644
index 0000000..9948e56
--- /dev/null
+++ b/net/batman-adv/log.h
@@ -0,0 +1,109 @@
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef _NET_BATMAN_ADV_LOG_H_
+#define _NET_BATMAN_ADV_LOG_H_
+
+#include "main.h"
+
+#include <linux/bitops.h>
+#include <linux/compiler.h>
+#include <linux/printk.h>
+
+#ifdef CONFIG_BATMAN_ADV_DEBUG
+
+int batadv_debug_log_setup(struct batadv_priv *bat_priv);
+void batadv_debug_log_cleanup(struct batadv_priv *bat_priv);
+
+#else
+
+static inline int batadv_debug_log_setup(struct batadv_priv *bat_priv)
+{
+	return 0;
+}
+
+static inline void batadv_debug_log_cleanup(struct batadv_priv *bat_priv)
+{
+}
+
+#endif
+
+/**
+ * enum batadv_dbg_level - available log levels
+ * @BATADV_DBG_BATMAN: OGM and TQ computations related messages
+ * @BATADV_DBG_ROUTES: route added / changed / deleted
+ * @BATADV_DBG_TT: translation table messages
+ * @BATADV_DBG_BLA: bridge loop avoidance messages
+ * @BATADV_DBG_DAT: ARP snooping and DAT related messages
+ * @BATADV_DBG_NC: network coding related messages
+ * @BATADV_DBG_MCAST: multicast related messages
+ * @BATADV_DBG_ALL: the union of all the above log levels
+ */
+enum batadv_dbg_level {
+	BATADV_DBG_BATMAN = BIT(0),
+	BATADV_DBG_ROUTES = BIT(1),
+	BATADV_DBG_TT	  = BIT(2),
+	BATADV_DBG_BLA    = BIT(3),
+	BATADV_DBG_DAT    = BIT(4),
+	BATADV_DBG_NC	  = BIT(5),
+	BATADV_DBG_MCAST  = BIT(6),
+	BATADV_DBG_ALL    = 127,
+};
+
+#ifdef CONFIG_BATMAN_ADV_DEBUG
+int batadv_debug_log(struct batadv_priv *bat_priv, const char *fmt, ...)
+__printf(2, 3);
+
+/* possibly ratelimited debug output */
+#define _batadv_dbg(type, bat_priv, ratelimited, fmt, arg...)	\
+	do {							\
+		if (atomic_read(&bat_priv->log_level) & type && \
+		    (!ratelimited || net_ratelimit()))		\
+			batadv_debug_log(bat_priv, fmt, ## arg);\
+	}							\
+	while (0)
+#else /* !CONFIG_BATMAN_ADV_DEBUG */
+__printf(4, 5)
+static inline void _batadv_dbg(int type __always_unused,
+			       struct batadv_priv *bat_priv __always_unused,
+			       int ratelimited __always_unused,
+			       const char *fmt __always_unused, ...)
+{
+}
+#endif
+
+#define batadv_dbg(type, bat_priv, arg...) \
+	_batadv_dbg(type, bat_priv, 0, ## arg)
+#define batadv_dbg_ratelimited(type, bat_priv, arg...) \
+	_batadv_dbg(type, bat_priv, 1, ## arg)
+
+#define batadv_info(net_dev, fmt, arg...)				\
+	do {								\
+		struct net_device *_netdev = (net_dev);                 \
+		struct batadv_priv *_batpriv = netdev_priv(_netdev);    \
+		batadv_dbg(BATADV_DBG_ALL, _batpriv, fmt, ## arg);	\
+		pr_info("%s: " fmt, _netdev->name, ## arg);		\
+	} while (0)
+#define batadv_err(net_dev, fmt, arg...)				\
+	do {								\
+		struct net_device *_netdev = (net_dev);                 \
+		struct batadv_priv *_batpriv = netdev_priv(_netdev);    \
+		batadv_dbg(BATADV_DBG_ALL, _batpriv, fmt, ## arg);	\
+		pr_err("%s: " fmt, _netdev->name, ## arg);		\
+	} while (0)
+
+#endif /* _NET_BATMAN_ADV_LOG_H_ */
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index c5a7cab..05e559c 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -33,6 +33,7 @@
 #include <linux/list.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
+#include <linux/printk.h>
 #include <linux/rculist.h>
 #include <linux/rcupdate.h>
 #include <linux/seq_file.h>
@@ -52,6 +53,7 @@
 #include "gateway_common.h"
 #include "hard-interface.h"
 #include "icmp_socket.h"
+#include "log.h"
 #include "multicast.h"
 #include "network-coding.h"
 #include "originator.h"
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 3ec6285..857fb5a 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -175,7 +175,6 @@ enum batadv_uev_type {
 
 /* Kernel headers */
 
-#include <linux/atomic.h>
 #include <linux/bitops.h> /* for packet.h */
 #include <linux/compiler.h>
 #include <linux/cpumask.h>
@@ -183,13 +182,13 @@ enum batadv_uev_type {
 #include <linux/if_ether.h> /* for packet.h */
 #include <linux/if_vlan.h>
 #include <linux/jiffies.h>
-#include <linux/netdevice.h>
 #include <linux/percpu.h>
-#include <linux/printk.h>
 #include <linux/types.h>
 
 #include "types.h"
 
+struct net_device;
+struct packet_type;
 struct seq_file;
 struct sk_buff;
 
@@ -219,70 +218,6 @@ void batadv_recv_handler_unregister(u8 packet_type);
 __be32 batadv_skb_crc32(struct sk_buff *skb, u8 *payload_ptr);
 
 /**
- * enum batadv_dbg_level - available log levels
- * @BATADV_DBG_BATMAN: OGM and TQ computations related messages
- * @BATADV_DBG_ROUTES: route added / changed / deleted
- * @BATADV_DBG_TT: translation table messages
- * @BATADV_DBG_BLA: bridge loop avoidance messages
- * @BATADV_DBG_DAT: ARP snooping and DAT related messages
- * @BATADV_DBG_NC: network coding related messages
- * @BATADV_DBG_MCAST: multicast related messages
- * @BATADV_DBG_ALL: the union of all the above log levels
- */
-enum batadv_dbg_level {
-	BATADV_DBG_BATMAN = BIT(0),
-	BATADV_DBG_ROUTES = BIT(1),
-	BATADV_DBG_TT	  = BIT(2),
-	BATADV_DBG_BLA    = BIT(3),
-	BATADV_DBG_DAT    = BIT(4),
-	BATADV_DBG_NC	  = BIT(5),
-	BATADV_DBG_MCAST  = BIT(6),
-	BATADV_DBG_ALL    = 127,
-};
-
-#ifdef CONFIG_BATMAN_ADV_DEBUG
-int batadv_debug_log(struct batadv_priv *bat_priv, const char *fmt, ...)
-__printf(2, 3);
-
-/* possibly ratelimited debug output */
-#define _batadv_dbg(type, bat_priv, ratelimited, fmt, arg...)	\
-	do {							\
-		if (atomic_read(&bat_priv->log_level) & type && \
-		    (!ratelimited || net_ratelimit()))		\
-			batadv_debug_log(bat_priv, fmt, ## arg);\
-	}							\
-	while (0)
-#else /* !CONFIG_BATMAN_ADV_DEBUG */
-__printf(4, 5)
-static inline void _batadv_dbg(int type __always_unused,
-			       struct batadv_priv *bat_priv __always_unused,
-			       int ratelimited __always_unused,
-			       const char *fmt __always_unused, ...)
-{
-}
-#endif
-
-#define batadv_dbg(type, bat_priv, arg...) \
-	_batadv_dbg(type, bat_priv, 0, ## arg)
-#define batadv_dbg_ratelimited(type, bat_priv, arg...) \
-	_batadv_dbg(type, bat_priv, 1, ## arg)
-
-#define batadv_info(net_dev, fmt, arg...)				\
-	do {								\
-		struct net_device *_netdev = (net_dev);                 \
-		struct batadv_priv *_batpriv = netdev_priv(_netdev);    \
-		batadv_dbg(BATADV_DBG_ALL, _batpriv, fmt, ## arg);	\
-		pr_info("%s: " fmt, _netdev->name, ## arg);		\
-	} while (0)
-#define batadv_err(net_dev, fmt, arg...)				\
-	do {								\
-		struct net_device *_netdev = (net_dev);                 \
-		struct batadv_priv *_batpriv = netdev_priv(_netdev);    \
-		batadv_dbg(BATADV_DBG_ALL, _batpriv, fmt, ## arg);	\
-		pr_err("%s: " fmt, _netdev->name, ## arg);		\
-	} while (0)
-
-/**
  * batadv_compare_eth - Compare two not u16 aligned Ethernet addresses
  * @data1: Pointer to a six-byte array containing the Ethernet address
  * @data2: Pointer other six-byte array containing the Ethernet address
diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index 0e7d78f..cc91507 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -55,6 +55,7 @@
 
 #include "hard-interface.h"
 #include "hash.h"
+#include "log.h"
 #include "packet.h"
 #include "translation-table.h"
 #include "tvlv.h"
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index d0383de..293ef4f 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -51,6 +51,7 @@
 
 #include "hard-interface.h"
 #include "hash.h"
+#include "log.h"
 #include "originator.h"
 #include "packet.h"
 #include "routing.h"
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 592cbda..8ad17ad 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -40,6 +40,7 @@
 #include "gateway_client.h"
 #include "hard-interface.h"
 #include "hash.h"
+#include "log.h"
 #include "multicast.h"
 #include "network-coding.h"
 #include "routing.h"
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index b9c7325..a5b53a3 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -41,6 +41,7 @@
 #include "fragmentation.h"
 #include "hard-interface.h"
 #include "icmp_socket.h"
+#include "log.h"
 #include "network-coding.h"
 #include "originator.h"
 #include "packet.h"
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 4e49454..3a59df2 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -42,6 +42,7 @@
 #include "fragmentation.h"
 #include "gateway_client.h"
 #include "hard-interface.h"
+#include "log.h"
 #include "network-coding.h"
 #include "originator.h"
 #include "routing.h"
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 6244a9a..1a7942d 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -43,6 +43,7 @@
 #include "gateway_client.h"
 #include "gateway_common.h"
 #include "hard-interface.h"
+#include "log.h"
 #include "network-coding.h"
 #include "packet.h"
 #include "soft-interface.h"
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 5c3cf7f..53458d6 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -48,6 +48,7 @@
 #include "bridge_loop_avoidance.h"
 #include "hard-interface.h"
 #include "hash.h"
+#include "log.h"
 #include "multicast.h"
 #include "originator.h"
 #include "packet.h"
-- 
2.8.1
