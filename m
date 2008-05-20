From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 4/4] flock: remove unused fields from file_lock_operations
Date: Tue, 20 May 2008 13:59:49 +0400
Message-ID: <1211277589-8565-4-git-send-email-den@openvz.org>
References: <1211277589-8565-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Denis V. Lunev" <den@openvz.org>, Matthew Wilcox <matthew@wil.cx>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:35692 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763772AbYETJ7x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 05:59:53 -0400
In-Reply-To: <1211277589-8565-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fl_insert and fl_remove are not used right now in the kernel. Remove them.

Signed-off-by: Denis V. Lunev <den@openvz.org>
Cc: Matthew Wilcox <matthew@wil.cx>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>
---
 fs/locks.c         |    6 ------
 include/linux/fs.h |    2 --
 2 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 11dbf08..dce8c74 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -561,9 +561,6 @@ static void locks_insert_lock(struct file_lock **pos, struct file_lock *fl)
 	/* insert into file's list */
 	fl->fl_next = *pos;
 	*pos = fl;
-
-	if (fl->fl_ops && fl->fl_ops->fl_insert)
-		fl->fl_ops->fl_insert(fl);
 }
 
 /*
@@ -586,9 +583,6 @@ static void locks_delete_lock(struct file_lock **thisfl_p)
 		fl->fl_fasync = NULL;
 	}
 
-	if (fl->fl_ops && fl->fl_ops->fl_remove)
-		fl->fl_ops->fl_remove(fl);
-
 	if (fl->fl_nspid) {
 		put_pid(fl->fl_nspid);
 		fl->fl_nspid = NULL;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 9bb4ffd..13fb854 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -901,8 +901,6 @@ static inline int file_check_writeable(struct file *filp)
 typedef struct files_struct *fl_owner_t;
 
 struct file_lock_operations {
-	void (*fl_insert)(struct file_lock *);	/* lock insertion callback */
-	void (*fl_remove)(struct file_lock *);	/* lock removal callback */
 	void (*fl_copy_lock)(struct file_lock *, struct file_lock *);
 	void (*fl_release_private)(struct file_lock *);
 };
-- 
1.5.3.rc5

