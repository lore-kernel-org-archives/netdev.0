From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] smc91x: disable DMA mode on the logicpd pxa270
Date: Fri, 23 Jun 2006 23:24:36 +0200
Message-ID: <20060623212436.GB4843@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nico@cam.org, mikee@logicpd.com, peterb@logicpd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:55472 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S1752079AbWFWVYh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 17:24:37 -0400
To: jgarzik@pobox.com, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enabling PXA DMA for the smc91x on the logicpd pxa270 produces
unacceptable interference with the TFT panel, so disable it.  Also
delete the lpd270 versions of the SMC_{in,out}[bl]() macros, as they
aren't used, since the board only supports 16bit accesses.

Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>

Index: linux-2.6.17-git5/drivers/net/smc91x.h
===================================================================
--- linux-2.6.17-git5.orig/drivers/net/smc91x.h
+++ linux-2.6.17-git5/drivers/net/smc91x.h
@@ -136,14 +136,9 @@
 #define SMC_CAN_USE_32BIT	0
 #define SMC_IO_SHIFT		0
 #define SMC_NOWAIT		1
-#define SMC_USE_PXA_DMA		1
 
-#define SMC_inb(a, r)		readb((a) + (r))
 #define SMC_inw(a, r)		readw((a) + (r))
-#define SMC_inl(a, r)		readl((a) + (r))
-#define SMC_outb(v, a, r)	writeb(v, (a) + (r))
 #define SMC_outw(v, a, r)	writew(v, (a) + (r))
-#define SMC_outl(v, a, r)	writel(v, (a) + (r))
 #define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
 #define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
