From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH] S390: Fix libphy link failure
Date: Mon, 06 May 2013 16:53:39 +0200
Message-ID: <1367852019.4569.123.camel@chaos.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Heiko Carstens <heiko.carstens@de.ibm.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:59054 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754031Ab3EFOyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 May 2013 10:54:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On S390 basic IRQ functions are provided by the PCI subsystem, so
code which calls these cannot be built if PCI support was not
selected.

Signed-off-by: Jean Delvare <jdelvare@suse.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
---
I know this isn't nice, but in the current state of S390 support
this is all I can offer.

 drivers/net/phy/Kconfig |    1 +
 1 file changed, 1 insertion(+)

--- linux-3.10-rc0.orig/drivers/net/phy/Kconfig	2013-04-29 02:36:01.000000000 +0200
+++ linux-3.10-rc0/drivers/net/phy/Kconfig	2013-05-06 10:34:41.141846466 +0200
@@ -5,6 +5,7 @@
 menuconfig PHYLIB
 	tristate "PHY Device support and infrastructure"
 	depends on NETDEVICES
+	depends on !S390 || PCI
 	help
 	  Ethernet controllers are usually attached to PHY
 	  devices.  This option provides infrastructure for

-- 
Jean Delvare
Suse L3
