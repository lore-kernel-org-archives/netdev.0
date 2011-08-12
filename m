From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next] spider_net: fix compile issue introduced by driver move
Date: Thu, 11 Aug 2011 20:33:20 -0700
Message-ID: <1313120000-12085-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both Spider net driver and Sun GEM driver use the sungem_phy.o object.
This fix creates a Kconfig object for sungem_phy (like MDIO) so that
both drivers require the SUNGEM_PHY object.

This has been compile tested for the Sun GEM driver.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig               |    4 ++++
 drivers/net/Makefile              |    2 +-
 drivers/net/ethernet/sun/Kconfig  |    1 +
 drivers/net/ethernet/sun/Makefile |    3 ++-
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index e6be7123..c8779c1 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -934,6 +934,7 @@ config SPIDER_NET
 	tristate "Spider Gigabit Ethernet driver"
 	depends on PCI && (PPC_IBM_CELL_BLADE || PPC_CELLEB)
 	select FW_LOADER
+	select SUNGEM_PHY
 	help
 	  This driver supports the Gigabit Ethernet chips present on the
 	  Cell Processor-Based Blades from IBM.
@@ -1083,6 +1084,9 @@ if NETDEV_10000
 config MDIO
 	tristate
 
+config SUNGEM_PHY
+	tristate
+
 endif # NETDEV_10000
 
 source "drivers/net/tokenring/Kconfig"
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index d151075..db888b0 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -41,7 +41,7 @@ obj-$(CONFIG_R6040) += r6040.o
 obj-$(CONFIG_YELLOWFIN) += yellowfin.o
 obj-$(CONFIG_FEALNX) += fealnx.o
 spidernet-y += spider_net.o spider_net_ethtool.o
-obj-$(CONFIG_SPIDER_NET) += spidernet.o ethernet/sun/sungem_phy.o
+obj-$(CONFIG_SPIDER_NET) += spidernet.o
 obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
 gelic_wireless-$(CONFIG_GELIC_WIRELESS) += ps3_gelic_wireless.o
 ps3_gelic-objs += ps3_gelic_net.o $(gelic_wireless-y)
diff --git a/drivers/net/ethernet/sun/Kconfig b/drivers/net/ethernet/sun/Kconfig
index 87b17a7..5132fa6 100644
--- a/drivers/net/ethernet/sun/Kconfig
+++ b/drivers/net/ethernet/sun/Kconfig
@@ -57,6 +57,7 @@ config SUNGEM
 	tristate "Sun GEM support"
 	depends on PCI
 	select CRC32
+	select SUNGEM_PHY
 	---help---
 	  Support for the Sun GEM chip, aka Sun GigabitEthernet/P 2.0.  See also
 	  <http://www.sun.com/products-n-solutions/hardware/docs/pdf/806-3985-10.pdf>.
diff --git a/drivers/net/ethernet/sun/Makefile b/drivers/net/ethernet/sun/Makefile
index 4f25217..6e25dad 100644
--- a/drivers/net/ethernet/sun/Makefile
+++ b/drivers/net/ethernet/sun/Makefile
@@ -5,7 +5,8 @@
 obj-$(CONFIG_HAPPYMEAL) += sunhme.o
 obj-$(CONFIG_SUNQE) += sunqe.o
 obj-$(CONFIG_SUNBMAC) += sunbmac.o
-obj-$(CONFIG_SUNGEM) += sungem.o sungem_phy.o
+obj-$(CONFIG_SUNGEM) += sungem.o
+obj-$(CONFIG_SUNGEM_PHY) += sungem_phy.o
 obj-$(CONFIG_CASSINI) += cassini.o
 obj-$(CONFIG_SUNVNET) += sunvnet.o
 obj-$(CONFIG_NIU) += niu.o
-- 
1.7.6
