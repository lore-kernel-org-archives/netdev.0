From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 16/29] sysctl: Factor out init_header from __register_sysctl_paths
Date: Thu, 26 Jan 2012 20:51:52 -0800
Message-ID: <1327639925-12920-16-git-send-email-ebiederm@xmission.com>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Factor out a routing to initialize the sysctl_table_header.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c |   25 +++++++++++++++++--------
 1 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 13faa48..4979925 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -42,6 +42,21 @@ static struct ctl_table_root sysctl_table_root = {
 
 static DEFINE_SPINLOCK(sysctl_lock);
 
+static void init_header(struct ctl_table_header *head,
+	struct ctl_table_root *root, struct ctl_table_set *set,
+	struct ctl_table *table)
+{
+	head->ctl_table_arg = table;
+	INIT_LIST_HEAD(&head->ctl_entry);
+	head->used = 0;
+	head->count = 1;
+	head->nreg = 1;
+	head->unregistering = NULL;
+	head->root = root;
+	head->set = set;
+	head->parent = NULL;
+}
+
 /* called under sysctl_lock */
 static int use_table(struct ctl_table_header *p)
 {
@@ -932,14 +947,8 @@ struct ctl_table_header *__register_sysctl_table(
 		new_name += namelen + 1;
 	}
 	*prevp = table;
-	header->ctl_table_arg = table;
-
-	INIT_LIST_HEAD(&header->ctl_entry);
-	header->used = 0;
-	header->unregistering = NULL;
-	header->root = root;
-	header->count = 1;
-	header->nreg = 1;
+
+	init_header(header, root, NULL, table);
 	if (sysctl_check_table(path, table))
 		goto fail;
 
-- 
1.7.2.5
