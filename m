From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH] dsa: fix compile bug on s390
Date: Mon, 13 Oct 2008 11:04:18 +0200
Message-ID: <20081013090418.GB17793@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([194.196.100.161]:38613 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129AbYJMJEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 05:04:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>

git commit 45cec1bac0719c904bb5f4405c2937f7e715888c
"dsa: Need to select PHYLIB." causes this build bug on s390:

drivers/built-in.o: In function `phy_stop_interrupts':
/home/heicarst/linux-2.6/drivers/net/phy/phy.c:631: undefined reference to `free_irq'
/home/heicarst/linux-2.6/drivers/net/phy/phy.c:646: undefined reference to `enable_irq'
drivers/built-in.o: In function `phy_start_interrupts':
/home/heicarst/linux-2.6/drivers/net/phy/phy.c:601: undefined reference to `request_irq'
drivers/built-in.o: In function `phy_interrupt':
/home/heicarst/linux-2.6/drivers/net/phy/phy.c:528: undefined reference to `disable_irq_nosync'
drivers/built-in.o: In function `phy_change':
/home/heicarst/linux-2.6/drivers/net/phy/phy.c:674: undefined reference to `enable_irq'
/home/heicarst/linux-2.6/drivers/net/phy/phy.c:692: undefined reference to `disable_irq'

PHYLIB has alread a depend on !S390, however select PHYLIB at DSA overrides
that unfortunately. So add a depend on !S390 to DSA as well.

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---

 net/dsa/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/net/dsa/Kconfig
===================================================================
--- linux-2.6.orig/net/dsa/Kconfig
+++ linux-2.6/net/dsa/Kconfig
@@ -1,7 +1,7 @@
 menuconfig NET_DSA
 	bool "Distributed Switch Architecture support"
 	default n
-	depends on EXPERIMENTAL
+	depends on EXPERIMENTAL && !S390
 	select PHYLIB
 	---help---
 	  This allows you to use hardware switch chips that use
