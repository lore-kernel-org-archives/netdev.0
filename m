From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] isdn: fix netjet/isdnhdlc build errors
Date: Mon, 28 Sep 2009 09:25:20 -0700
Message-ID: <20090928092520.b6f921de.randy.dunlap@oracle.com>
References: <alpine.LFD.2.01.0909271511190.3349@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Karsten Keil <keil@b1-systems.de>,
	netdev <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:37913 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681AbZI1Q0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 12:26:12 -0400
In-Reply-To: <alpine.LFD.2.01.0909271511190.3349@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Commit cb3824bade2549d7ad059d5802da43312540fdee didn't fix this problem.

Fix build errors in netjet, using isdnhdlc module:

drivers/built-in.o: In function `mode_tiger':
netjet.c:(.text+0x1ca0c7): undefined reference to `isdnhdlc_rcv_init'
netjet.c:(.text+0x1ca0d4): undefined reference to `isdnhdlc_out_init'
drivers/built-in.o: In function `fill_dma':
netjet.c:(.text+0x1ca2bd): undefined reference to `isdnhdlc_encode'
drivers/built-in.o: In function `read_dma':
netjet.c:(.text+0x1ca614): undefined reference to `isdnhdlc_decode'
drivers/built-in.o: In function `nj_irq':
netjet.c:(.text+0x1cb07a): undefined reference to `isdnhdlc_encode'

drivers/built-in.o: In function `isdnhdlc_decode':
(.text+0x1c2088): undefined reference to `crc_ccitt_table'
drivers/built-in.o: In function `isdnhdlc_encode':
(.text+0x1c2339): undefined reference to `crc_ccitt_table'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/hardware/mISDN/Kconfig |    1 +
 drivers/isdn/i4l/Kconfig            |    3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

--- lnx-2632-rc1.orig/drivers/isdn/hardware/mISDN/Kconfig
+++ lnx-2632-rc1/drivers/isdn/hardware/mISDN/Kconfig
@@ -78,6 +78,7 @@ config MISDN_NETJET
 	depends on PCI
 	select MISDN_IPAC
 	select ISDN_HDLC
+	select ISDN_I4L
 	help
 	  Enable support for Traverse Technologies NETJet PCI cards.
 
--- lnx-2632-rc1.orig/drivers/isdn/i4l/Kconfig
+++ lnx-2632-rc1/drivers/isdn/i4l/Kconfig
@@ -141,8 +141,7 @@ endmenu
 endif
 
 config ISDN_HDLC
-	tristate 
-	depends on HISAX_ST5481
+	tristate
 	select CRC_CCITT
 	select BITREVERSE
 
