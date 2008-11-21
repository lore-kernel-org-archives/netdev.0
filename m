From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next/-mm/mainline] net/hp-plus: fix link errors
Date: Thu, 20 Nov 2008 21:17:24 -0800
Message-ID: <20081120211724.09b94026.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>, davem@davemloft.net,
	alan@lxorguk.ukuu.org.uk, akpm <akpm@linux-foundation.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet14.oracle.com ([148.87.113.126]:42755 "EHLO
	rgminet14.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788AbYKUFTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 00:19:51 -0500
Received: from rgminet12.oracle.com (rcsinet12.oracle.com [148.87.113.124])
	by rgminet14.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id mAL5KiqZ032491
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 21 Nov 2008 05:20:45 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix hp-plus driver link errors.
Builds as loadable module and kernel image driver.
All drivers that use 8390.o or 8390p.o that will build on
i386 with MCA/PCI/EISA/ISA were built successfully both
=m and =y.

drivers/built-in.o: In function `hpp_open':
hp-plus.c:(.text+0xac06c): undefined reference to `eip_interrupt'
hp-plus.c:(.text+0xac0d7): undefined reference to `eip_open'
drivers/built-in.o: In function `hpp_close':
hp-plus.c:(.text+0xac1bb): undefined reference to `eip_close'
drivers/built-in.o: In function `hpp_probe1':
hp-plus.c:(.init.text+0xa98a): undefined reference to `NS8390p_init'
drivers/built-in.o: In function `hp_plus_probe':
(.init.text+0xa9fe): undefined reference to `__alloc_eip_netdev'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/Makefile |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- mmotm-2008-1120-1703.orig/drivers/net/Makefile
+++ mmotm-2008-1120-1703/drivers/net/Makefile
@@ -113,7 +113,7 @@ obj-$(CONFIG_EL2) += 3c503.o 8390p.o
 obj-$(CONFIG_NE2000) += ne.o 8390p.o
 obj-$(CONFIG_NE2_MCA) += ne2.o 8390p.o
 obj-$(CONFIG_HPLAN) += hp.o 8390p.o
-obj-$(CONFIG_HPLAN_PLUS) += hp-plus.o 8390.o
+obj-$(CONFIG_HPLAN_PLUS) += hp-plus.o 8390p.o
 obj-$(CONFIG_ULTRA) += smc-ultra.o 8390.o
 obj-$(CONFIG_ULTRAMCA) += smc-mca.o 8390.o
 obj-$(CONFIG_ULTRA32) += smc-ultra32.o 8390.o
