From: Andi Kleen <ak@suse.de>
Subject: [PATCH] Fix 64bit warnings in donauboe driver
Date: Wed, 17 Mar 2004 11:58:50 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040317115850.216e6d1b.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, irda-users@lists.sourceforge.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Fix a few 64bit warnings in the Donauboe driver. Untested.

-Andi

diff -u linux/drivers/net/irda/donauboe.c-o linux/drivers/net/irda/donauboe.c
--- linux/drivers/net/irda/donauboe.c-o	1970-01-01 01:12:51.000000000 +0100
+++ linux/drivers/net/irda/donauboe.c	2004-03-17 11:56:57.000000000 +0100
@@ -1669,16 +1669,15 @@
 
   /*We need to align the taskfile on a taskfile size boundary */
   {
-    __u32 addr;
+    unsigned long addr;
 
-    addr = (__u32) self->ringbuf;
-    addr &= ~(OBOE_RING_LEN - 1);
+    addr = (unsigned long) self->ringbuf;
+    addr &= ~((unsigned long)OBOE_RING_LEN - 1);
     addr += OBOE_RING_LEN;
     self->ring = (struct OboeRing *) addr;
   }
 
   memset (self->ring, 0, OBOE_RING_LEN);
-  self->io.mem_base = (__u32) self->ring;
 
   ok = 1;
   for (i = 0; i < TX_SLOTS; ++i)
