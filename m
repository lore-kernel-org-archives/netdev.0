From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/2 net-2.6.26] [NETNS]: Compile NET /proc support only if CONFIG_NET is set.
Date: Thu, 27 Mar 2008 13:29:56 +0300
Message-ID: <1206613797-32045-1-git-send-email-den@openvz.org>
References: <20080327.022206.100283150.davem@davemloft.net>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	yoshfuji@linux-ipv6.org, --cc@sw.ru,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:58588 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754650AbYC0K30 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 06:29:26 -0400
In-Reply-To: <20080327.022206.100283150.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fix broken compilation for 'allnoconfig'. This was introduced by
Introduced by commit 1218854afa6f659be90b748cf1bc7badee954a35 ("[NET]
NETNS: Omit seq_net_private->net without CONFIG_NET_NS.")

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 fs/proc/proc_net.c       |    2 ++
 include/linux/seq_file.h |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 13cd783..7034fac 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -51,6 +51,7 @@ int seq_open_net(struct inode *ino, struct file *f,
 }
 EXPORT_SYMBOL_GPL(seq_open_net);
 
+#ifdef CONFIG_NET
 int seq_release_net(struct inode *ino, struct file *f)
 {
 	struct seq_file *seq;
@@ -218,3 +219,4 @@ int __init proc_net_init(void)
 
 	return register_pernet_subsys(&proc_net_ns_ops);
 }
+#endif /* CONFIG_NET */
diff --git a/include/linux/seq_file.h b/include/linux/seq_file.h
index d870a82..5da70c3 100644
--- a/include/linux/seq_file.h
+++ b/include/linux/seq_file.h
@@ -63,6 +63,7 @@ extern struct list_head *seq_list_start_head(struct list_head *head,
 extern struct list_head *seq_list_next(void *v, struct list_head *head,
 		loff_t *ppos);
 
+#ifdef CONFIG_NET
 struct net;
 struct seq_net_private {
 #ifdef CONFIG_NET_NS
@@ -81,6 +82,7 @@ static inline struct net *seq_file_net(struct seq_file *seq)
 	return &init_net;
 #endif
 }
+#endif	/* CONFIG_NET */
 
 #endif
 #endif
-- 
1.5.3.rc5

