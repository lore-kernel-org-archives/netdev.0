From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v2] net: ethernet: update dependency and help text of mvneta
Date: Tue, 18 Feb 2014 14:18:11 +0100
Message-ID: <1392729491-24913-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:44805 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754956AbaBRNSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 08:18:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the introduction of the support for Armada 375 and Armada 38x,
the hidden Kconfig option MACH_ARMADA_370_XP is being renamed to
MACH_MVEBU_V7. Therefore, the dependency that was used for the mvneta
driver can no longer work. This commit replaces this dependency by a
dependency on PLAT_ORION, which is used similarly for the mv643xx_eth
driver.

In addition to this, it takes this opportunity to adjust the
description and help text to indicate that the driver can is also used
for Armada 38x. Note that Armada 375 cannot use this driver as it has
a completely different networking unit, which will require a separate
driver.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
Changes since v1:
 - Instead of removing the Kconfig dependency, replace it by a
   dependency on PLAT_ORION, in order to avoid building mvneta on too
   many architectures and getting weird build issues. Suggested by
   Jason Cooper.
 - Fix capitalization in the Kconfig help text.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/Kconfig | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index 6300fd2..68e6a66 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -43,12 +43,12 @@ config MVMDIO
 	  This driver is used by the MV643XX_ETH and MVNETA drivers.
 
 config MVNETA
-	tristate "Marvell Armada 370/XP network interface support"
-	depends on MACH_ARMADA_370_XP
+	tristate "Marvell Armada 370/38x/XP network interface support"
+	depends on PLAT_ORION
 	select MVMDIO
 	---help---
 	  This driver supports the network interface units in the
-	  Marvell ARMADA XP and ARMADA 370 SoC family.
+	  Marvell ARMADA XP, ARMADA 370 and ARMADA 38x SoC family.
 
 	  Note that this driver is distinct from the mv643xx_eth
 	  driver, which should be used for the older Marvell SoCs
-- 
1.8.3.2
