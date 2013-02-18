From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH net-next 2/4] net: proc: remove proc_net_fops_create
Date: Mon, 18 Feb 2013 19:34:55 +0800
Message-ID: <1361187297-2527-2-git-send-email-gaofeng@cn.fujitsu.com>
References: <1361187297-2527-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: ebiederm@xmission.com, davem@davemloft.net,
	containers@lists.linux-foundation.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:15552 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751368Ab3BRLeZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 06:34:25 -0500
In-Reply-To: <1361187297-2527-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

proc_net_fops_create has been replaced by proc_create,
we can remove it now.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 fs/proc/proc_net.c      | 8 --------
 include/linux/proc_fs.h | 3 ---
 2 files changed, 11 deletions(-)

diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index fe72cd0..30f7c67 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -177,14 +177,6 @@ const struct file_operations proc_net_operations = {
 	.readdir	= proc_tgid_net_readdir,
 };
 
-
-struct proc_dir_entry *proc_net_fops_create(struct net *net,
-	const char *name, umode_t mode, const struct file_operations *fops)
-{
-	return proc_create(name, mode, net->proc_net, fops);
-}
-EXPORT_SYMBOL_GPL(proc_net_fops_create);
-
 void proc_net_remove(struct net *net, const char *name)
 {
 	remove_proc_entry(name, net->proc_net);
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 32676b3..35ee189 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -171,8 +171,6 @@ static inline struct proc_dir_entry *create_proc_read_entry(const char *name,
 	return res;
 }
  
-extern struct proc_dir_entry *proc_net_fops_create(struct net *net,
-	const char *name, umode_t mode, const struct file_operations *fops);
 extern void proc_net_remove(struct net *net, const char *name);
 extern struct proc_dir_entry *proc_net_mkdir(struct net *net, const char *name,
 	struct proc_dir_entry *parent);
@@ -184,7 +182,6 @@ extern int proc_alloc_inum(unsigned int *pino);
 extern void proc_free_inum(unsigned int inum);
 #else
 
-#define proc_net_fops_create(net, name, mode, fops)  ({ (void)(mode), NULL; })
 static inline void proc_net_remove(struct net *net, const char *name) {}
 
 static inline void proc_flush_task(struct task_struct *task)
-- 
1.7.11.7
