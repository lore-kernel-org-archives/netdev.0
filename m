From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH,RESEND] smc91x: disable DMA mode on the logicpd pxa270
Date: Sat, 12 Aug 2006 10:55:07 +0200
Message-ID: <20060812085506.GA650@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nico@cam.org, mikee@logicpd.com, peterb@logicpd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:40359 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S932371AbWHLIzJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 04:55:09 -0400
To: jgarzik@pobox.com, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enabling PXA DMA for the smc91x on the logicpd pxa270 produces
unacceptable interference with the TFT panel, so disable it.  Also
delete the lpd270 versions of the SMC_{in,out}[bl]() macros, as they
aren't used, since the board only supports 16bit accesses.

Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>

--- linux-2.6.18-rc4.orig/drivers/net/smc91x.h	2006-08-12 10:45:45.000000000 +0200
+++ linux-2.6.18-rc4/drivers/net/smc91x.h	2006-08-12 10:46:00.000000000 +0200
@@ -135,16 +135,11 @@
 #define SMC_CAN_USE_16BIT	1
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
 
 #elif	defined(CONFIG_ARCH_INNOKOM) || \
