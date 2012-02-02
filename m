From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 1/4] sysctl: An easier to read version of find_subdir
Date: Wed, 01 Feb 2012 19:28:40 -0800
Message-ID: <m1y5slvrpz.fsf_-_@fess.ebiederm.org>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
	<m139atx6bs.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <m139atx6bs.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Wed, 01 Feb 2012 19:27:51 -0800")
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Suggested-by:  Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 27e265b..ebe8b30 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -833,9 +833,9 @@ static struct ctl_dir *find_subdir(struct ctl_dir *dir,
 	entry = find_entry(&head, dir, name, namelen);
 	if (!entry)
 		return ERR_PTR(-ENOENT);
-	if (S_ISDIR(entry->mode))
-		return container_of(head, struct ctl_dir, header);
-	return ERR_PTR(-ENOTDIR);
+	if (!S_ISDIR(entry->mode))
+		return ERR_PTR(-ENOTDIR);
+	return container_of(head, struct ctl_dir, header);
 }
 
 static struct ctl_dir *new_dir(struct ctl_table_set *set,
-- 
1.7.2.5

