From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/4] sysctl: Correct error return from get_subdir
Date: Wed, 01 Feb 2012 19:29:07 -0800
Message-ID: <m1ty39vrp8.fsf_-_@fess.ebiederm.org>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
	<m139atx6bs.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m139atx6bs.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Wed, 01 Feb 2012 19:27:51 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


When insert_header fails ensure we return the proper error value
from get_subdir.  In practice nothing cares, but there is no
need to be sloppy.

Reported-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index ebe8b30..722ec11 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -869,6 +869,7 @@ static struct ctl_dir *get_subdir(struct ctl_dir *dir,
 {
 	struct ctl_table_set *set = dir->header.set;
 	struct ctl_dir *subdir, *new = NULL;
+	int err;
 
 	spin_lock(&sysctl_lock);
 	subdir = find_subdir(dir, name, namelen);
@@ -890,7 +891,9 @@ static struct ctl_dir *get_subdir(struct ctl_dir *dir,
 	if (PTR_ERR(subdir) != -ENOENT)
 		goto failed;
 
-	if (insert_header(dir, &new->header))
+	err = insert_header(dir, &new->header);
+	subdir = ERR_PTR(err);
+	if (err)
 		goto failed;
 	subdir = new;
 found:
-- 
1.7.2.5
