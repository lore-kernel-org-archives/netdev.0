From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 2/2] netdev: Depend on INET before selecting INET_LRO
Date: Mon, 04 Oct 2010 02:42:05 +0100
Message-ID: <1286156525.3916.215.camel@localhost>
References: <1286156262.3916.213.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Subrata Modak <subrata@linux.vnet.ibm.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Olof Johansson <olof@lixom.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60853 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751028Ab0JDBmT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Oct 2010 21:42:19 -0400
In-Reply-To: <1286156262.3916.213.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 'select' ignores dependencies, drivers that select INET_LRO must
depend on INET.  This fixes the broken configuration reported in
<http://article.gmane.org/gmane.linux.kernel/825646>.

Reported-by: Subrata Modak <subrata@linux.vnet.ibm.com>
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index ef683a9..13d01f3 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2428,7 +2428,7 @@ config UGETH_TX_ON_DEMAND
 
 config MV643XX_ETH
 	tristate "Marvell Discovery (643XX) and Orion ethernet support"
-	depends on MV64X60 || PPC32 || PLAT_ORION
+	depends on (MV64X60 || PPC32 || PLAT_ORION) && INET
 	select INET_LRO
 	select PHYLIB
 	help
@@ -2815,7 +2815,7 @@ config NIU
 
 config PASEMI_MAC
 	tristate "PA Semi 1/10Gbit MAC"
-	depends on PPC_PASEMI && PCI
+	depends on PPC_PASEMI && PCI && INET
 	select PHYLIB
 	select INET_LRO
 	help
-- 
1.7.1


