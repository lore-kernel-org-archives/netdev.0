From: chas williams (contractor) <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] atm/idt77252: correct printk of dma_addr_t
Date: Wed, 04 Feb 2004 14:05:00 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402041904.i14J4xRr017789@ginger.cmf.nrl.navy.mil>
References: <rddunlap@osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: Message from "Randy.Dunlap" <rddunlap@osdl.org>
   of "Tue, 03 Feb 2004 15:34:48 PST." <20040203153448.5c81e49d.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

dave, please apply the following to the 2.6 and 2.4 trees.

thanks!


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1549  -> 1.1550 
#	drivers/atm/idt77252.c	1.21    -> 1.22   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/02/04	chas@relax.cmf.nrl.navy.mil	1.1550
# [ATM]: [idt77252] fix dma_addr_t type error with CONFIG_HIGHMEM64G=y (by "Randy.Dunlap" <rddunlap@osdl.org>)
# --------------------------------------------
#
diff -Nru a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
--- a/drivers/atm/idt77252.c	Wed Feb  4 13:24:55 2004
+++ b/drivers/atm/idt77252.c	Wed Feb  4 13:24:55 2004
@@ -664,8 +664,8 @@
 	skb_queue_head_init(&scq->transmit);
 	skb_queue_head_init(&scq->pending);
 
-	TXPRINTK("idt77252: SCQ: base 0x%p, next 0x%p, last 0x%p, paddr %08x\n",
-		 scq->base, scq->next, scq->last, scq->paddr);
+	TXPRINTK("idt77252: SCQ: base 0x%p, next 0x%p, last 0x%p, paddr %08llx\n",
+		 scq->base, scq->next, scq->last, (unsigned long long)scq->paddr);
 
 	return scq;
 }
