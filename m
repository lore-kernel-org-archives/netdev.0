From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 3/3 net-2.6.26] [NETNS]: Do not include net/net_namespace.h from seq_file.h
Date: Mon, 31 Mar 2008 19:47:02 +0400
Message-ID: <1206978422-13088-3-git-send-email-den@openvz.org>
References: <1206978361.10660.31.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	yoshfuji@linux-ipv6.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:26694 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752378AbYCaPrN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 11:47:13 -0400
In-Reply-To: <1206978361.10660.31.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/linux/seq_file.h     |   22 ----------------------
 include/linux/seq_file_net.h |   27 +++++++++++++++++++++++++++
 include/net/net_namespace.h  |    2 ++
 3 files changed, 29 insertions(+), 22 deletions(-)
 create mode 100644 include/linux/seq_file_net.h

diff --git a/include/linux/seq_file.h b/include/linux/seq_file.h
index 5da70c3..1da1e62 100644
--- a/include/linux/seq_file.h
+++ b/include/linux/seq_file.h
@@ -5,7 +5,6 @@
 #include <linux/types.h>
 #include <linux/string.h>
 #include <linux/mutex.h>
-#include <net/net_namespace.h>
 
 struct seq_operations;
 struct file;
@@ -63,26 +62,5 @@ extern struct list_head *seq_list_start_head(struct list_head *head,
 extern struct list_head *seq_list_next(void *v, struct list_head *head,
 		loff_t *ppos);
 
-#ifdef CONFIG_NET
-struct net;
-struct seq_net_private {
-#ifdef CONFIG_NET_NS
-	struct net *net;
-#endif
-};
-
-int seq_open_net(struct inode *, struct file *,
-		 const struct seq_operations *, int);
-int seq_release_net(struct inode *, struct file *);
-static inline struct net *seq_file_net(struct seq_file *seq)
-{
-#ifdef CONFIG_NET_NS
-	return ((struct seq_net_private *)seq->private)->net;
-#else
-	return &init_net;
-#endif
-}
-#endif	/* CONFIG_NET */
-
 #endif
 #endif
diff --git a/include/linux/seq_file_net.h b/include/linux/seq_file_net.h
new file mode 100644
index 0000000..4ac5254
--- /dev/null
+++ b/include/linux/seq_file_net.h
@@ -0,0 +1,27 @@
+#ifndef __SEQ_FILE_NET_H__
+#define __SEQ_FILE_NET_H__
+
+#include <linux/seq_file.h>
+
+struct net;
+extern struct net init_net;
+
+struct seq_net_private {
+#ifdef CONFIG_NET_NS
+	struct net *net;
+#endif
+};
+
+int seq_open_net(struct inode *, struct file *,
+		 const struct seq_operations *, int);
+int seq_release_net(struct inode *, struct file *);
+static inline struct net *seq_file_net(struct seq_file *seq)
+{
+#ifdef CONFIG_NET_NS
+	return ((struct seq_net_private *)seq->private)->net;
+#else
+	return &init_net;
+#endif
+}
+
+#endif
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 035ebff..35b6752 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -63,6 +63,8 @@ struct net {
 
 
 #ifdef CONFIG_NET
+#include <linux/seq_file_net.h>
+
 /* Init's network namespace */
 extern struct net init_net;
 #define INIT_NET_NS(net_ns) .net_ns = &init_net,
-- 
1.5.3.rc5

