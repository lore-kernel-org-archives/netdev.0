From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] ISDN: fix sc/shmem printk format warning
Date: Thu, 19 Feb 2009 13:47:40 -0800
Message-ID: <20090219134740.4dff14c2.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kkeil@suse.de, davem@davemloft.net,
	akpm <akpm@linux-foundation.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:45495 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756827AbZBSVsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 16:48:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix isdn/sc/shmem.c printk format warning:

drivers/isdn/sc/shmem.c:57: warning: format '%d' expects type 'int', but argument 3 has type 'size_t'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/isdn/sc/shmem.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.29-rc5-git3.orig/drivers/isdn/sc/shmem.c
+++ linux-2.6.29-rc5-git3/drivers/isdn/sc/shmem.c
@@ -54,7 +54,7 @@ void memcpy_toshmem(int card, void *dest
 	spin_unlock_irqrestore(&sc_adapter[card]->lock, flags);
 	pr_debug("%s: set page to %#x\n",sc_adapter[card]->devicename,
 		((sc_adapter[card]->shmem_magic + ch * SRAM_PAGESIZE)>>14)|0x80);
-	pr_debug("%s: copying %d bytes from %#lx to %#lx\n",
+	pr_debug("%s: copying %zu bytes from %#lx to %#lx\n",
 		sc_adapter[card]->devicename, n,
 		(unsigned long) src,
 		sc_adapter[card]->rambase + ((unsigned long) dest %0x4000));
