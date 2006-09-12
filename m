From: bora.sahin@ttnet.net.tr
Subject: [PATCH 1/11] smc911x: Fix accessor SMC_* routines
Date: Tue, 12 Sep 2006 20:32:47 +0300
Message-ID: <200609122032.47980.bora.sahin@ttnet.net.tr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ttnet.net.tr ([212.175.13.129]:65504 "EHLO
	fep01.ttnet.net.tr") by vger.kernel.org with ESMTP id S1030291AbWILRgq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 13:36:46 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


When in 16 bit mode, SMC_outl incorrectly simulates the situation and plus in 
32 bit mode SMC_outw is missing...

Signed-off-by: Bora Sahin <bora.sahin@ttnet.net.tr>

Index: linux-2.6.18-rc4/drivers/net/smc911x.h
===================================================================
--- linux-2.6.18-rc4.orig/drivers/net/smc911x.h	2006-08-06 21:20:11.000000000 
+0300
+++ linux-2.6.18-rc4/drivers/net/smc911x.h	2006-08-24 12:23:10.000000000 +0300
@@ -51,8 +51,8 @@
 #define SMC_outw(v, a, r)		 writew(v, (a) + (r))
 #define SMC_outl(v, a, r) 			 \
 	do{					 \
-		 writel(v & 0xFFFF, (a) + (r));	 \
-		 writel(v >> 16, (a) + (r) + 2); \
+		 writew(v & 0xFFFF, (a) + (r));	 \
+		 writew(v >> 16, (a) + (r) + 2); \
 	 } while (0)
 #define SMC_insl(a, r, p, l)	 readsw((short*)((a) + (r)), p, l*2)
 #define SMC_outsl(a, r, p, l)	 writesw((short*)((a) + (r)), p, l*2)
@@ -62,6 +62,7 @@
 #define SMC_inw(a, r)		 readw((a) + (r))
 #define SMC_inl(a, r)		 readl((a) + (r))
 #define SMC_outb(v, a, r)	 writeb(v, (a) + (r))
+#define SMC_outw(v, a, r)	 writew(v, (a) + (r))
 #define SMC_outl(v, a, r)	 writel(v, (a) + (r))
 #define SMC_insl(a, r, p, l)	 readsl((int*)((a) + (r)), p, l)
 #define SMC_outsl(a, r, p, l)	 writesl((int*)((a) + (r)), p, l)


--
Bora SAHIN
