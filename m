From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH,RESEND] smc91x: support for logicpd pxa270 platform
Date: Sun, 18 Jun 2006 19:16:51 +0200
Message-ID: <20060618171651.GA24647@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nico@cam.org, peterb@logicpd.com, mikee@logicpd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:15253 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S932191AbWFRRQz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jun 2006 13:16:55 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for the smc91x on the LogicPD PXA270 to
the smc91x driver.

Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>

-- 
This patch was previously submitted on March 28, but doesn't seem
to have made it into 2.6.17.

Index: linux-2.6.17/drivers/net/smc91x.h
===================================================================
--- linux-2.6.17.orig/drivers/net/smc91x.h
+++ linux-2.6.17/drivers/net/smc91x.h
@@ -129,6 +129,19 @@
 #define SMC_insb(a, r, p, l)	readsb((a) + (r), p, (l))
 #define SMC_outsb(a, r, p, l)	writesb((a) + (r), p, (l))
 
+#elif	defined(CONFIG_MACH_LOGICPD_PXA270)
+
+#define SMC_CAN_USE_8BIT	0
+#define SMC_CAN_USE_16BIT	1
+#define SMC_CAN_USE_32BIT	0
+#define SMC_IO_SHIFT		0
+#define SMC_NOWAIT		1
+
+#define SMC_inw(a, r)		readw((a) + (r))
+#define SMC_outw(v, a, r)	writew(v, (a) + (r))
+#define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
+#define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
+
 #elif	defined(CONFIG_ARCH_INNOKOM) || \
 	defined(CONFIG_MACH_MAINSTONE) || \
 	defined(CONFIG_ARCH_PXA_IDP) || \
