From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: [PATCH] drivers/net/fddi/skfp/h/skfbi.h: Remove useless PCI_BASE_2ND
 macros
Date: Wed, 03 Sep 2014 23:26:26 +0800
Message-ID: <54073322.6030508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	michal.simek@xilinx.com, Michal Simek <monstr@monstr.eu>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:46043 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbaICP01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 11:26:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They are use less, and may generate compiling warnings, so remove them
(microblaze, arc, arm64, and unicore32 have already defined PCI_IOBASE).

The related warnings (with allmodconfig under microblaze):

  CC [M]  drivers/net/fddi/skfp/skfddi.o
  In file included from drivers/net/fddi/skfp/skfddi.c:95:0:
  drivers/net/fddi/skfp/h/skfbi.h:151:0: warning: "PCI_IOBASE" redefined
   #define PCI_IOBASE 0xffffff00L  /* Bit 31..8:  I/O Base address */
   ^
  In file included from include/linux/io.h:22:0,
                   from include/linux/pci.h:31,
                   from drivers/net/fddi/skfp/skfddi.c:82:
  ./arch/microblaze/include/asm/io.h:33:0: note: this is the location of the previous definition
   #define PCI_IOBASE ((void __iomem *)_IO_BASE)
   ^

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 drivers/net/fddi/skfp/h/skfbi.h | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/fddi/skfp/h/skfbi.h b/drivers/net/fddi/skfp/h/skfbi.h
index c1ba26c..3de2f0d 100644
--- a/drivers/net/fddi/skfp/h/skfbi.h
+++ b/drivers/net/fddi/skfp/h/skfbi.h
@@ -147,11 +147,6 @@
 #define	PCI_MEM64BIT	(2<<1)	     /* Base addr anywhere in 64 Bit range */
 #define	PCI_MEMSPACE	0x00000001L  /* Bit 0:	Memory Space Indic. */
 
-/*	PCI_BASE_2ND	32 bit	2nd Base address */
-#define	PCI_IOBASE	0xffffff00L  /* Bit 31..8:  I/O Base address */
-#define	PCI_IOSIZE	0x000000fcL  /* Bit 7..2:   I/O Size Requirements */
-#define	PCI_IOSPACE	0x00000001L  /* Bit 0:	    I/O Space Indicator */
-
 /*	PCI_SUB_VID	16 bit	Subsystem Vendor ID */
 /*	PCI_SUB_ID	16 bit	Subsystem ID */
 
-- 
1.9.3
