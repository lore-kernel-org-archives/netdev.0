From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] phylib: available for any speed ethernet
Date: Wed, 11 Aug 2010 16:26:57 -0700
Message-ID: <20100811162657.cfb767a7.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:21818 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363Ab0HKX2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 19:28:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Several gigabit network drivers (SB1250_MAC, TIGON3, FSL, GIANFAR,
UCC_GETH, MV643XX_ETH, XILINX_LL_TEMAC, S6GMAC, STMMAC_ETH, PASEMI_MAC,
and OCTEON_ETHERNET) select PHYLIB.  These drivers are not under
NET_ETHERNET (10/100 mbit), so this warning is generated (long, irrelevant
parts are omitted):

warning: (NET_DSA && NET && EXPERIMENTAL && NET_ETHERNET && !S390 || ... || SB1250_MAC && NETDEVICES && NETDEV_1000 && SIBYTE_SB1xxx_SOC || TIGON3 && NETDEVICES && NETDEV_1000 && PCI || FSL_PQ_MDIO && NETDEVICES && NETDEV_1000 && FSL_SOC || GIANFAR && NETDEVICES && NETDEV_1000 && FSL_SOC || UCC_GETH && NETDEVICES && NETDEV_1000 && QUICC_ENGINE || MV643XX_ETH && NETDEVICES && NETDEV_1000 && (MV64X60 || PPC32 || PLAT_ORION) || XILINX_LL_TEMAC && NETDEVICES && NETDEV_1000 && (PPC || MICROBLAZE) || S6GMAC && NETDEVICES && NETDEV_1000 && XTENSA_VARIANT_S6000 || STMMAC_ETH && NETDEV_1000 && NETDEVICES && CPU_SUBTYPE_ST40 || PASEMI_MAC && NETDEVICES && NETDEV_10000 && PPC_PASEMI && PCI || OCTEON_ETHERNET && STAGING && !STAGING_EXCLUDE_BUILD && CPU_CAVIUM_OCTEON) selects PHYLIB which has unmet dir
 ect dependencies (!S390 && NET_ETHERNET)

PHYLIB is used by non-10/100 mbit ethernet drivers, so change the dependencies
to be NETDEVICES instead of NET_ETHERNET.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/phy/Kconfig |    2 +-
 net/dsa/Kconfig         |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

--- linux-next-20100810.orig/drivers/net/phy/Kconfig
+++ linux-next-20100810/drivers/net/phy/Kconfig
@@ -5,7 +5,7 @@
 menuconfig PHYLIB
 	tristate "PHY Device support and infrastructure"
 	depends on !S390
-	depends on NET_ETHERNET
+	depends on NETDEVICES
 	help
 	  Ethernet controllers are usually attached to PHY
 	  devices.  This option provides infrastructure for
--- linux-next-20100810.orig/net/dsa/Kconfig
+++ linux-next-20100810/net/dsa/Kconfig
@@ -1,7 +1,7 @@
 menuconfig NET_DSA
 	bool "Distributed Switch Architecture support"
 	default n
-	depends on EXPERIMENTAL && NET_ETHERNET && !S390
+	depends on EXPERIMENTAL && NETDEVICES && !S390
 	select PHYLIB
 	---help---
 	  This allows you to use hardware switch chips that use
