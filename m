From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next] marvell: mark mvneta and mvpp2 32-bit only
Date: Tue, 22 Nov 2016 15:21:22 +0100
Message-ID: <20161122142136.1690096-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Marcin Wojtas <mw@semihalf.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.134]:55016 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756156AbcKVOVs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 09:21:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both of these drivers won't work on 64-bit architectures unless they
are redesigned, since they store a virtual address pointer in a 32-bit
field of the descriptors:

drivers/net/ethernet/marvell/mvneta_bm.c: In function 'mvneta_bm_construct':
drivers/net/ethernet/marvell/mvneta_bm.c:103:16: error: cast from pointer to integer of different size [-Werror=pointer-to-int-cast]
drivers/net/ethernet/marvell/mvpp2.c: In function 'mvpp2_prs_vlan_init':
drivers/net/ethernet/marvell/mvpp2.c:2563:32: error: large integer implicitly truncated to unsigned type [-Werror=overflow]

This limits the COMPILE_TEST option for the two drivers again to
only build them on 32-bit. This seems nicer than shutting up the
warnings, in case we ever actually want to use them on 64-bit,
as the warnings indicate which parts of the driver are currently
broken there.

Fixes: a0627f776a45 ("net: marvell: Allow drivers to be built with COMPILE_TEST")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/marvell/Kconfig | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index d74d4e6f0b34..66fd9dbb2ca7 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -58,6 +58,7 @@ config MVNETA
 	tristate "Marvell Armada 370/38x/XP network interface support"
 	depends on PLAT_ORION || COMPILE_TEST
 	depends on HAS_DMA
+	depends on !64BIT
 	select MVMDIO
 	select FIXED_PHY
 	---help---
@@ -81,6 +82,7 @@ config MVPP2
 	tristate "Marvell Armada 375 network interface support"
 	depends on MACH_ARMADA_375 || COMPILE_TEST
 	depends on HAS_DMA
+	depends on !64BIT
 	select MVMDIO
 	---help---
 	  This driver supports the network interface units in the
-- 
2.9.0
