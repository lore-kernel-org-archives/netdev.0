From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 070/115] sysctl: rename sysctl_head_get/put to sysctl_proc_inode_get/put
Date: Mon,  9 May 2011 00:39:22 +0200
Message-ID: <1304894407-32201-71-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47346 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932503Ab1EHWlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:41:50 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clarify the purpose of those references. No functional changes.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 fs/proc/inode.c        |    2 +-
 fs/proc/proc_sysctl.c  |    2 +-
 include/linux/sysctl.h |    7 +++++--
 kernel/sysctl.c        |    6 +++---
 4 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index d15aa1b..08166df 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -42,7 +42,7 @@ static void proc_evict_inode(struct inode *inode)
 	head = PROC_I(inode)->sysctl;
 	if (head) {
 		rcu_assign_pointer(PROC_I(inode)->sysctl, NULL);
-		sysctl_head_put(head);
+		sysctl_proc_inode_put(head);
 	}
 }
 
diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 068d39c..125b679 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -26,7 +26,7 @@ static struct inode *proc_sys_make_inode(struct super_block *sb,
 
 	inode->i_ino = get_next_ino();
 
-	sysctl_head_get(head);
+	sysctl_proc_inode_get(head);
 	ei = PROC_I(inode);
 	ei->sysctl = head;
 	ei->sysctl_entry = table;
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 0f41beb..e265880 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -951,8 +951,11 @@ extern void setup_sysctl_set(struct ctl_table_set *p,
 
 struct ctl_table_header;
 
-extern void sysctl_head_get(struct ctl_table_header *);
-extern void sysctl_head_put(struct ctl_table_header *);
+/* get/put a reference to this header that
+ * will be/was embedded in a procfs proc_inode */
+extern void sysctl_proc_inode_get(struct ctl_table_header *);
+extern void sysctl_proc_inode_put(struct ctl_table_header *);
+
 extern int sysctl_is_seen(struct ctl_table_header *);
 extern struct ctl_table_header *sysctl_use_header(struct ctl_table_header *);
 extern struct ctl_table_header *sysctl_use_next_header(struct ctl_table_header *prev);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 48a1ffd..caafbb8 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1551,7 +1551,7 @@ static void start_unregistering(struct ctl_table_header *p)
 	list_del_init(&p->ctl_entry);
 }
 
-void sysctl_head_get(struct ctl_table_header *head)
+void sysctl_proc_inode_get(struct ctl_table_header *head)
 {
 	spin_lock(&sysctl_lock);
 	head->ctl_procfs_refs++;
@@ -1563,7 +1563,7 @@ static void free_head(struct rcu_head *rcu)
 	kfree(container_of(rcu, struct ctl_table_header, rcu));
 }
 
-void sysctl_head_put(struct ctl_table_header *head)
+void sysctl_proc_inode_put(struct ctl_table_header *head)
 {
 	spin_lock(&sysctl_lock);
 	head->ctl_procfs_refs--;
@@ -1990,7 +1990,7 @@ void setup_sysctl_set(struct ctl_table_set *p,
 {
 }
 
-void sysctl_head_put(struct ctl_table_header *head)
+void sysctl_proc_inode_put(struct ctl_table_header *head)
 {
 }
 
-- 
1.7.5.134.g1c08b

