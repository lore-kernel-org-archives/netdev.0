From: akpm@linux-foundation.org
Subject: [patch 3/3] isdn: fix netjet build errors
Date: Thu, 06 Aug 2009 16:06:25 -0700
Message-ID: <200908062306.n76N6P08006390@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	randy.dunlap@oracle.com
To: isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58774 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756868AbZHFXG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 19:06:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix netjet driver link errors when ISDN_I4L is not enabled:

drivers/built-in.o: In function `mode_tiger':
netjet.c:(.text+0x325dc8): undefined reference to `isdnhdlc_rcv_init'
netjet.c:(.text+0x325dd5): undefined reference to `isdnhdlc_out_init'
drivers/built-in.o: In function `fill_dma':
netjet.c:(.text+0x325fb6): undefined reference to `isdnhdlc_encode'
drivers/built-in.o: In function `read_dma':
netjet.c:(.text+0x32631a): undefined reference to `isdnhdlc_decode'
drivers/built-in.o: In function `nj_irq':
netjet.c:(.text+0x326e01): undefined reference to `isdnhdlc_encode'

or move isdnhdlc.c to some other sub-dir..

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Karsten Keil <isdn@linux-pingi.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/hardware/mISDN/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff -puN drivers/isdn/hardware/mISDN/Kconfig~isdn-fix-netjet-build-errors drivers/isdn/hardware/mISDN/Kconfig
--- a/drivers/isdn/hardware/mISDN/Kconfig~isdn-fix-netjet-build-errors
+++ a/drivers/isdn/hardware/mISDN/Kconfig
@@ -78,6 +78,7 @@ config MISDN_NETJET
 	depends on PCI
 	select MISDN_IPAC
 	select ISDN_HDLC
+	select ISDN_I4L # so that make will recurse into sub-dir.
 	help
 	  Enable support for Traverse Technologies NETJet PCI cards.
 
_
