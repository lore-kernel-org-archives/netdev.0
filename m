From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Fix 64bit warning for firestream
Date: Sat, 17 Jul 2004 13:36:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3acxyj26v.fsf@averell.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-atm-general@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas@cmf.nrl.navy.mil
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Fix obvious 64bit issue in firestream driver. I haven't tested
if it actually works on 64bit due to lack of hardware.

-Andi

diff -u linux-2.6.8rc1-amd64-pre2/drivers/atm/firestream.c-o linux-2.6.8rc1-amd64-pre2/drivers/atm/firestream.c
--- linux-2.6.8rc1-amd64-pre2/drivers/atm/firestream.c-o	2004-07-17 13:26:01.000000000 +0200
+++ linux-2.6.8rc1-amd64-pre2/drivers/atm/firestream.c	2004-07-17 13:33:49.525480904 +0200
@@ -1380,7 +1380,7 @@
 
 	if (alignment <= 0x10) {
 		t = kmalloc (size, flags);
-		if ((unsigned int)t & (alignment-1)) {
+		if ((unsigned long)t & (alignment-1)) {
 			printk ("Kmalloc doesn't align things correctly! %p\n", t);
 			kfree (t);
 			return aligned_kmalloc (size, flags, alignment * 4);
