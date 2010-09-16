From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 06/12] BKL: Remove BKL from capifs
Date: Thu, 16 Sep 2010 19:46:19 +0200
Message-ID: <1284659185-8942-7-git-send-email-arnd@arndb.de>
References: <1284659185-8942-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1284659185-8942-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The BKL is only used in fill_super, which is  protected by the superblocks
s_umount rw_semaphore. Therefore it is safe to remove the BKL entirely.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: netdev@vger.kernel.org
---
 drivers/isdn/capi/capifs.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/drivers/isdn/capi/capifs.c b/drivers/isdn/capi/capifs.c
index c559b52..b0dcdbc 100644
--- a/drivers/isdn/capi/capifs.c
+++ b/drivers/isdn/capi/capifs.c
@@ -17,7 +17,6 @@
 #include <linux/init.h>
 #include <linux/ctype.h>
 #include <linux/sched.h>	/* current */
-#include <linux/smp_lock.h>	/* For lock_kernel() */
 
 #include "capifs.h"
 
@@ -100,8 +99,6 @@ capifs_fill_super(struct super_block *s, void *data, int silent)
 {
 	struct inode * inode;
 
-	lock_kernel();
-
 	s->s_blocksize = 1024;
 	s->s_blocksize_bits = 10;
 	s->s_magic = CAPIFS_SUPER_MAGIC;
@@ -119,15 +116,12 @@ capifs_fill_super(struct super_block *s, void *data, int silent)
 	inode->i_nlink = 2;
 
 	s->s_root = d_alloc_root(inode);
-	if (s->s_root) {
-		unlock_kernel();
+	if (s->s_root)
 		return 0;
-	}
 
 	printk("capifs: get root dentry failed\n");
 	iput(inode);
 fail:
-	unlock_kernel();
 	return -ENOMEM;
 }
 
-- 
1.7.1
