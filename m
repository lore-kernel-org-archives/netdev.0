From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH] eliminate useless divert message
Date: Wed, 7 Apr 2004 12:29:12 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040407162912.GA21868@achilles.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[sorry if this is a dupe, but the original wasn't going through.]

Hello folks,

Debugging some ppp code has made me truely despise divert's log messages.  
This patch deletes both the allocate and delete printks.

		-ben
-- 
"Time is what keeps everything from happening all at once." -- John Wheeler


===== net/core/dv.c 1.9 vs edited =====
--- 1.9/net/core/dv.c	Sun Sep 28 19:47:07 2003
+++ edited/net/core/dv.c	Tue Apr  6 22:17:12 2004
@@ -53,9 +53,6 @@
 	int alloc_size = (sizeof(struct divert_blk) + 3) & ~3;
 
 	if (dev->type == ARPHRD_ETHER) {
-		printk(KERN_DEBUG "divert: allocating divert_blk for %s\n",
-		       dev->name);
-
 		dev->divert = (struct divert_blk *)
 			kmalloc(alloc_size, GFP_KERNEL);
 		if (dev->divert == NULL) {
@@ -67,9 +64,6 @@
 		}
 		dev_hold(dev);
 	} else {
-		printk(KERN_DEBUG "divert: not allocating divert_blk for non-ethernet device %s\n",
-		       dev->name);
-
 		dev->divert = NULL;
 	}
 	return 0;
