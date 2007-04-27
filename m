From: dmitry pervushin <dpervushin@gmail.com>
Subject: [PATCH] SMC on pxa3xx (was: pxa3xx base patch [5/5] - net)
Date: Fri, 27 Apr 2007 12:52:08 +0400
Message-ID: <1177663928.4307.7.camel@diimka.dev.rtsoft.ru>
Reply-To: dpervushin@gmail.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:51471 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755496AbXD0Iup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 04:50:45 -0400
Received: by ug-out-1314.google.com with SMTP id 44so777591uga
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2007 01:50:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is to support network adapter on pxa3xx-based boards

Signed-off-by: dmitry pervushin <dpervushin@ru.mvista.com>
KernelVersion: 2.6.21

Index: linux-2.6.21/drivers/net/smc91x.h
===================================================================
--- linux-2.6.21.orig/drivers/net/smc91x.h
+++ linux-2.6.21/drivers/net/smc91x.h
@@ -175,6 +175,20 @@ SMC_outw(u16 val, void __iomem *ioaddr, 
 	}
 }
 
+#elif defined(CONFIG_PXA3xx)
+#define SMC_CAN_USE_8BIT	1
+#define SMC_CAN_USE_16BIT	1
+#define SMC_CAN_USE_32BIT	0
+#define SMC_IO_SHIFT		0
+#define SMC_NOWAIT		1
+#define SMC_USE_PXA_DMA		1
+#define SMC_inb(a, r)		readb((a) + (r))
+#define SMC_outb(v, a, r)	writeb(v, (a) + (r))
+#define SMC_inw(a, r)		readw((a) + (r))
+#define SMC_outw(v, a, r)	writew(v, (a) + (r))
+#define SMC_insw(a, r, p, l)	insw((a) + (r), p, l)
+#define SMC_outsw(a, r, p, l)	outsw((a) + (r), p, l)
+
 #elif	defined(CONFIG_ARCH_OMAP)
 
 /* We can only do 16-bit reads and writes in the static memory space. */


