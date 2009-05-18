From: Gabriel Paubert <paubert@iram.es>
Subject: [PATCH] Allow selecting mv643xx_eth on Pegasos again
Date: Mon, 18 May 2009 19:37:56 +0200
Message-ID: <20090518173756.GA11805@iram.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, tbm@cyrius.com,
	pacman@kosh.dhis.org, netdev@vger.kernel.org,
	Matt Sealey <matt@genesi-usa.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	LinuxPPC <linuxppc-dev@ozlabs.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gra-lx1.iram.es ([150.214.224.41]:34152 "EHLO gra-lx1.iram.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750890AbZERRiK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2009 13:38:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since PPC_MUTIPLATFORM was removed, it was impossible to select the
driver for mv643xx_eth on the Pegasos. Fix by allowing to select
the driver on CHRP platforms; Pegasos is a CHRP platform and the driver
will not work without arch/powerpc/platforms/chrp/pegasos_eth.

Signed-off-by: Gabriel Paubert <paubert@iram.es> 

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 214a92d..6fc0ff4 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2351,7 +2351,7 @@ config UGETH_TX_ON_DEMAND
 
 config MV643XX_ETH
 	tristate "Marvell Discovery (643XX) and Orion ethernet support"
-	depends on MV64360 || MV64X60 || (PPC_MULTIPLATFORM && PPC32) || PLAT_ORION
+	depends on MV64X60 || PPC_CHRP || PLAT_ORION
 	select INET_LRO
 	select PHYLIB
 	help
