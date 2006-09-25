From: akpm@osdl.org
Subject: [patch 03/11] Update smc91x driver with ARM Versatile board info
Date: Mon, 25 Sep 2006 16:39:18 -0700
Message-ID: <200609252339.k8PNdICF002628@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, dsaxena@plexity.net,
	nico@cam.org, rmk@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:19636 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751712AbWIYXjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 19:39:43 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Deepak Saxena <dsaxena@plexity.net>

We need to specify a Versatile-specific SMC_IRQ_FLAGS value or the new
generic IRQ layer will complain thusly:

No IRQF_TRIGGER set_type function for IRQ 25 (<NULL>)

Signed-off-by: Deepak Saxena <dsaxena@plexity.net>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Russell King <rmk@arm.linux.org.uk>
Cc: Nicolas Pitre <nico@cam.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/smc91x.h |   18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff -puN drivers/net/smc91x.h~update-smc91x-driver-with-arm-versatile-board-info drivers/net/smc91x.h
--- a/drivers/net/smc91x.h~update-smc91x-driver-with-arm-versatile-board-info
+++ a/drivers/net/smc91x.h
@@ -379,6 +379,24 @@ static inline void LPD7_SMC_outsw (unsig
 
 #define SMC_IRQ_FLAGS		(0)
 
+#elif	defined(CONFIG_ARCH_VERSATILE)
+
+#define SMC_CAN_USE_8BIT	1
+#define SMC_CAN_USE_16BIT	1
+#define SMC_CAN_USE_32BIT	1
+#define SMC_NOWAIT		1
+
+#define SMC_inb(a, r)		readb((a) + (r))
+#define SMC_inw(a, r)		readw((a) + (r))
+#define SMC_inl(a, r)		readl((a) + (r))
+#define SMC_outb(v, a, r)	writeb(v, (a) + (r))
+#define SMC_outw(v, a, r)	writew(v, (a) + (r))
+#define SMC_outl(v, a, r)	writel(v, (a) + (r))
+#define SMC_insl(a, r, p, l)	readsl((a) + (r), p, l)
+#define SMC_outsl(a, r, p, l)	writesl((a) + (r), p, l)
+
+#define SMC_IRQ_FLAGS		(0)
+
 #else
 
 #define SMC_CAN_USE_8BIT	1
_
