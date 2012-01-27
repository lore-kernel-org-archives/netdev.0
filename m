From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 14/29] sysctl: A more obvious version of grab_header.
Date: Thu, 26 Jan 2012 20:49:55 -0800
Message-ID: <1327639810-12760-14-git-send-email-ebiederm@xmission.com>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of relying on sysct_head_next(NULL) to magically
return the right header for the root directory instead
explicitly transform NULL into the root directories header.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index e573f9b..1544485 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -267,10 +267,10 @@ static struct ctl_table *find_in_table(struct ctl_table *p, struct qstr *name)
 
 static struct ctl_table_header *grab_header(struct inode *inode)
 {
-	if (PROC_I(inode)->sysctl)
-		return sysctl_head_grab(PROC_I(inode)->sysctl);
-	else
-		return sysctl_head_next(NULL);
+	struct ctl_table_header *head = PROC_I(inode)->sysctl;
+	if (!head)
+		head = &root_table_header;
+	return sysctl_head_grab(head);
 }
 
 static struct dentry *proc_sys_lookup(struct inode *dir, struct dentry *dentry,
-- 
1.7.2.5
