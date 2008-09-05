From: akpm@linux-foundation.org
Subject: [patch for 2.6.27? 4/6] drivers/net/mlx4/alloc.c needs mm.h
Date: Fri, 05 Sep 2008 14:04:07 -0700
Message-ID: <200809052104.m85L47vw020360@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40027 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752227AbYIEVGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 17:06:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

sparc32 allmodconfig with linux-next:

drivers/net/mlx4/alloc.c: In function 'mlx4_buf_alloc':
drivers/net/mlx4/alloc.c:164: error: 'PAGE_KERNEL' undeclared (first use in this function)
drivers/net/mlx4/alloc.c:164: error: (Each undeclared identifier is reported only once
drivers/net/mlx4/alloc.c:164: error: for each function it appears in.)

this is due to some header shuffle in linux-next.  I didn't look to see what
it was.  I'd sugges that this patch be merged ahead of a linux-next merge to
avoid bisection breaks.

We strictly only need asm/pgtable.h, but going direct to asm includes always
seems grubby.

Cc: Jeff Garzik <jeff@garzik.org>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/mlx4/alloc.c |    1 +
 1 file changed, 1 insertion(+)

diff -puN drivers/net/mlx4/alloc.c~drivers-net-mlx4-allocc-needs-mmh drivers/net/mlx4/alloc.c
--- a/drivers/net/mlx4/alloc.c~drivers-net-mlx4-allocc-needs-mmh
+++ a/drivers/net/mlx4/alloc.c
@@ -33,6 +33,7 @@
 
 #include <linux/errno.h>
 #include <linux/slab.h>
+#include <linux/mm.h>
 #include <linux/bitmap.h>
 #include <linux/dma-mapping.h>
 #include <linux/vmalloc.h>
_
