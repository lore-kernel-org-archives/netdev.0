From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Fix warnings in hp100
Date: Tue, 7 Oct 2003 19:54:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007175446.GA1719@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Fix some harmless integer/pointer size mismatch warnings in hp100.c
on 64bit compiles

diff -u linux-2.5-cleanup/drivers/net/hp100.c-o linux-2.5-cleanup/drivers/net/hp100.c
--- linux-2.5-cleanup/drivers/net/hp100.c-o	2003-09-23 07:28:00.000000000 +0200
+++ linux-2.5-cleanup/drivers/net/hp100.c	2003-12-02 17:12:03.343110768 +0100
@@ -1265,9 +1265,9 @@
 {
 	/* pdlptr is starting address for this pdl */
 
-	if (0 != (((unsigned) pdlptr) & 0xf))
-		printk("hp100: %s: Init rxpdl: Unaligned pdlptr 0x%x.\n",
-		       dev->name, (unsigned) pdlptr);
+	if (0 != (((unsigned long) pdlptr) & 0xf))
+		printk("hp100: %s: Init rxpdl: Unaligned pdlptr 0x%lx.\n",
+		       dev->name, (unsigned long) pdlptr);
 
 	ringptr->pdl = pdlptr + 1;
 	ringptr->pdl_paddr = virt_to_whatever(dev, pdlptr + 1);
@@ -1292,8 +1292,8 @@
 			    register hp100_ring_t * ringptr,
 			    register u32 * pdlptr)
 {
-	if (0 != (((unsigned) pdlptr) & 0xf))
-		printk("hp100: %s: Init txpdl: Unaligned pdlptr 0x%x.\n", dev->name, (unsigned) pdlptr);
+	if (0 != (((unsigned long) pdlptr) & 0xf))
+		printk("hp100: %s: Init txpdl: Unaligned pdlptr 0x%lx.\n", dev->name, (unsigned long) pdlptr);
 
 	ringptr->pdl = pdlptr;	/* +1; */
 	ringptr->pdl_paddr = virt_to_whatever(dev, pdlptr);	/* +1 */
