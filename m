From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] Fix ROSE security hole
Date: Wed, 2 Mar 2005 09:06:58 +0000
Message-ID: <20050302090658.GA6873@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

ROSE wasn't verifying the ndigis argument of a new route resulting in a
minor security hole.

Index: bk-afu/net/rose/rose_route.c
===================================================================
--- bk-afu.orig/net/rose/rose_route.c	2005-02-05 22:16:25.582983368 +0000
+++ bk-afu/net/rose/rose_route.c	2005-02-05 22:16:25.585982912 +0000
@@ -727,7 +727,8 @@
 		}
 		if (rose_route.mask > 10) /* Mask can't be more than 10 digits */
 			return -EINVAL;
-
+		if (rose_route.ndigis > 8) /* No more than 8 digipeats */
+			return -EINVAL;
 		err = rose_add_node(&rose_route, dev);
 		dev_put(dev);
 		return err;
