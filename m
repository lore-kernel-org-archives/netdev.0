From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 05/29] sysctl: Make the directories have nlink == 1
Date: Thu, 26 Jan 2012 20:51:41 -0800
Message-ID: <1327639925-12920-5-git-send-email-ebiederm@xmission.com>
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

I goofed when I made sysctl directories have nlink == 0.
nlink == 0 means the directory has been deleted.
nlink == 1 meands a directory does not count subdirectories.

Use the default nlink == 1 for sysctl directories.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 06e6f10..f6aa751 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -253,7 +253,6 @@ static struct inode *proc_sys_make_inode(struct super_block *sb,
 		inode->i_fop = &proc_sys_file_operations;
 	} else {
 		inode->i_mode |= S_IFDIR;
-		clear_nlink(inode);
 		inode->i_op = &proc_sys_dir_operations;
 		inode->i_fop = &proc_sys_dir_file_operations;
 	}
-- 
1.7.2.5
