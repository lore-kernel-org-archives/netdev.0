From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 05/29] net: Flip seq_net_private to net_ctx
Date: Wed,  4 Feb 2015 18:34:06 -0700
Message-ID: <1423100070-31848-6-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:39517 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756049AbbBEBf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:35:58 -0500
Received: by mail-ie0-f180.google.com with SMTP id rl12so6705921iec.11
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:35:57 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enhances seq files for networking to have a network context from the
current namespace only.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 fs/proc/proc_net.c           |  2 +-
 include/linux/seq_file_net.h | 10 ++++++----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 1bde894bc624..4996f5e91a90 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -54,7 +54,7 @@ int seq_open_net(struct inode *ino, struct file *f,
 		return -ENOMEM;
 	}
 #ifdef CONFIG_NET_NS
-	p->net = net;
+	p->net_ctx.net = net;
 #endif
 	return 0;
 }
diff --git a/include/linux/seq_file_net.h b/include/linux/seq_file_net.h
index 32c89bbe24a2..b860d053a65e 100644
--- a/include/linux/seq_file_net.h
+++ b/include/linux/seq_file_net.h
@@ -7,9 +7,7 @@ struct net;
 extern struct net init_net;
 
 struct seq_net_private {
-#ifdef CONFIG_NET_NS
-	struct net *net;
-#endif
+	struct net_ctx net_ctx;
 };
 
 int seq_open_net(struct inode *, struct file *,
@@ -21,10 +19,14 @@ int single_release_net(struct inode *, struct file *);
 static inline struct net *seq_file_net(struct seq_file *seq)
 {
 #ifdef CONFIG_NET_NS
-	return ((struct seq_net_private *)seq->private)->net;
+	return ((struct seq_net_private *)seq->private)->net_ctx.net;
 #else
 	return &init_net;
 #endif
 }
+static inline struct net_ctx *seq_file_net_ctx(struct seq_file *seq)
+{
+	return &((struct seq_net_private *)seq->private)->net_ctx;
+}
 
 #endif
-- 
1.9.3 (Apple Git-50)
