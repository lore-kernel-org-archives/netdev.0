From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 13/29] sysctl: Remove the now unused ctl_table parent field.
Date: Thu, 26 Jan 2012 20:49:54 -0800
Message-ID: <1327639810-12760-13-git-send-email-ebiederm@xmission.com>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While useful at one time for selinux and the sysctl sanity
checks those users no longer use the parent field and we can
safely remove it.

Inspired-by: Lucian Adrian Grijincu <lucian.grijincu@gmil.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c  |   12 +-----------
 include/linux/sysctl.h |    1 -
 2 files changed, 1 insertions(+), 12 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index a492ff6..e573f9b 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -218,16 +218,6 @@ static int sysctl_perm(struct ctl_table_root *root, struct ctl_table *table, int
 	return test_perm(mode, op);
 }
 
-static void sysctl_set_parent(struct ctl_table *parent, struct ctl_table *table)
-{
-	for (; table->procname; table++) {
-		table->parent = parent;
-		if (table->child)
-			sysctl_set_parent(table, table->child);
-	}
-}
-
-
 static struct inode *proc_sys_make_inode(struct super_block *sb,
 		struct ctl_table_header *head, struct ctl_table *table)
 {
@@ -947,10 +937,10 @@ struct ctl_table_header *__register_sysctl_table(
 	header->used = 0;
 	header->unregistering = NULL;
 	header->root = root;
-	sysctl_set_parent(NULL, header->ctl_table);
 	header->count = 1;
 	if (sysctl_check_table(path, table))
 		goto fail;
+
 	spin_lock(&sysctl_lock);
 	header->set = lookup_header_set(root, namespaces);
 	header->attached_by = header->ctl_table;
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 25c7dfe..094bc5c 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -1016,7 +1016,6 @@ struct ctl_table
 	int maxlen;
 	umode_t mode;
 	struct ctl_table *child;	/* Deprecated */
-	struct ctl_table *parent;	/* Automatically set */
 	proc_handler *proc_handler;	/* Callback for text formatting */
 	struct ctl_table_poll *poll;
 	void *extra1;
-- 
1.7.2.5
