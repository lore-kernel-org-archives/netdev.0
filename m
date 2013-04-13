From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH] net: mvmdio: add select PHYLIB
Date: Sat, 13 Apr 2013 18:18:56 +0200
Message-ID: <1365869936-17190-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>,
	Maen Suleiman <maen@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Florian Fainelli <florian@openwrt.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:43980 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753717Ab3DMQTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Apr 2013 12:19:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mvmdio driver uses the phylib API, so it should select the PHYLIB
symbol, otherwise, a build with mvmdio (but without mvneta) fails to
build with undefined symbols such as mdiobus_unregister, mdiobus_free,
etc.

The mvneta driver does not use the phylib API directly, so it does not
need to select PHYLIB. It already selects the mvmdio driver anyway.

Historically, this problem is due to the fact that the PHY handling
was originally part of mvneta, and was later moved to a separate
driver, without updating the Kconfig select statements
accordingly. And since there was no functional reason to use mvmdio
without mvneta, this case was not tested.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
---
This problem has been around since Linux 3.8 and causes build issues
when CONFIG_MVMDIO={y,m} and CONFIG_PHYLIB is not enabled. If
possible, it should therefore be applied on both 3.8 and 3.9 kernels.
---
 drivers/net/ethernet/marvell/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index edfba93..434e33c 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -33,6 +33,7 @@ config MV643XX_ETH
 
 config MVMDIO
 	tristate "Marvell MDIO interface support"
+	select PHYLIB
 	---help---
 	  This driver supports the MDIO interface found in the network
 	  interface units of the Marvell EBU SoCs (Kirkwood, Orion5x,
@@ -45,7 +46,6 @@ config MVMDIO
 config MVNETA
 	tristate "Marvell Armada 370/XP network interface support"
 	depends on MACH_ARMADA_370_XP
-	select PHYLIB
 	select MVMDIO
 	---help---
 	  This driver supports the network interface units in the
-- 
1.7.9.5
