From: Andi Kleen <ak@suse.de>
Subject: [PATCH] Fix ADMtek Comet on x86-64
Date: Wed, 28 Jul 2004 15:25:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040728132559.GB23406@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This Tulip clone doesn't like an Cache Line setting over 8 words.
This broke it on x86-64.  Make it the same as on i386.

Some testing if I didn't break other Tulips on x86-64 would 
be appreciated.


-Andi


diff -u linux/drivers/net/tulip/tulip_core.c-o linux/drivers/net/tulip/tulip_core.c
--- linux/drivers/net/tulip/tulip_core.c-o	2004-04-06 13:12:12.000000000 +0200
+++ linux/drivers/net/tulip/tulip_core.c	2004-07-28 14:45:05.000000000 +0200
@@ -88,9 +88,9 @@
 	ToDo: Non-Intel setting could be better.
 */
 
-#if defined(__alpha__) || defined(__ia64__) || defined(__x86_64__)
+#if defined(__alpha__) || defined(__ia64__)
 static int csr0 = 0x01A00000 | 0xE000;
-#elif defined(__i386__) || defined(__powerpc__)
+#elif defined(__i386__) || defined(__powerpc__) || defined(__x86_64__)
 static int csr0 = 0x01A00000 | 0x8000;
 #elif defined(__sparc__) || defined(__hppa__)
 /* The UltraSparc PCI controllers will disconnect at every 64-byte
