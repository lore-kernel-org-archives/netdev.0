From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: [PATCH] phy: add HAS_IOMEM/OF_MDIO dependencies to MDIO_OCTEON
Date: Sat,  2 Jan 2016 14:06:28 +0100
Message-ID: <1451739988-14351-1-git-send-email-vegard.nossum@oracle.com>
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:46816 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751389AbcABNGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2016 08:06:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ran into this on UML:

drivers/built-in.o: In function `octeon_mdiobus_probe':
drivers/net/phy/mdio-octeon.c:295: undefined reference to `devm_ioremap'
drivers/net/phy/mdio-octeon.c:320: undefined reference to `of_mdiobus_register'
collect2: error: ld returned 1 exit status

devm_ioremap() is defined only when HAS_IOMEM is selected.

of_mdiobus_register() is defined only when OF_MDIO is selected.

Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/phy/Kconfig | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 60994a8..19314bb 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -186,6 +186,8 @@ config MDIO_GPIO
 config MDIO_OCTEON
 	tristate "Support for MDIO buses on Octeon and ThunderX SOCs"
 	depends on 64BIT
+	depends on HAS_IOMEM
+	depends on OF_MDIO
 	help
 
 	  This module provides a driver for the Octeon and ThunderX MDIO
-- 
1.9.1
