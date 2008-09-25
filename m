From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] further net driver updates for .28
Date: Wed, 24 Sep 2008 22:27:22 -0400
Message-ID: <20080925022722.GA32005@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:41084 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752011AbYIYC1Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 22:27:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'davem-next' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-next

to receive the following updates:

 arch/arm/mach-kirkwood/db88f6281-bp-setup.c  |    2 +-
 arch/arm/mach-kirkwood/rd88f6192-nas-setup.c |    2 +-
 arch/arm/mach-kirkwood/rd88f6281-setup.c     |    2 +-
 arch/arm/mach-loki/lb88rc8480-setup.c        |    2 +-
 arch/arm/mach-mv78xx0/common.c               |    6 +-
 arch/arm/mach-mv78xx0/db78x00-bp-setup.c     |    8 +-
 arch/arm/mach-orion5x/db88f5281-setup.c      |    2 +-
 arch/arm/mach-orion5x/dns323-setup.c         |    2 +-
 arch/arm/mach-orion5x/kurobox_pro-setup.c    |    2 +-
 arch/arm/mach-orion5x/mss2-setup.c           |    2 +-
 arch/arm/mach-orion5x/mv2120-setup.c         |    2 +-
 arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c |    2 +-
 arch/arm/mach-orion5x/rd88f5181l-ge-setup.c  |    2 +-
 arch/arm/mach-orion5x/rd88f5182-setup.c      |    2 +-
 arch/arm/mach-orion5x/ts78xx-setup.c         |    3 +-
 arch/arm/mach-orion5x/tsx09-common.c         |    2 +-
 arch/arm/mach-orion5x/wnr854t-setup.c        |    2 +-
 arch/arm/mach-orion5x/wrt350n-v2-setup.c     |    2 +-
 arch/powerpc/sysdev/mv64x60_dev.c            |    6 +-
 drivers/net/Kconfig                          |   13 +-
 drivers/net/atl1e/atl1e_hw.c                 |    6 +-
 drivers/net/atlx/atl2.c                      |    4 +-
 drivers/net/bonding/bonding.h                |    8 +
 drivers/net/e1000/e1000.h                    |   17 -
 drivers/net/e1000/e1000_main.c               |  416 +--------
 drivers/net/e1000e/ich8lan.c                 |    2 +
 drivers/net/e1000e/netdev.c                  |    6 +-
 drivers/net/enic/enic.h                      |    3 +-
 drivers/net/enic/enic_main.c                 |  195 ++--
 drivers/net/forcedeth.c                      |    2 +-
 drivers/net/fs_enet/fs_enet-main.c           |   22 +-
 drivers/net/fs_enet/fs_enet.h                |    2 -
 drivers/net/fs_enet/mac-fcc.c                |   12 -
 drivers/net/fs_enet/mac-fec.c                |   30 -
 drivers/net/fs_enet/mac-scc.c                |   26 -
 drivers/net/gianfar_mii.c                    |   18 +-
 drivers/net/ibm_newemac/Kconfig              |    2 +-
 drivers/net/mv643xx_eth.c                    | 1438 +++++++++++++-------------
 drivers/net/ne.c                             |  272 +++--
 drivers/net/phy/mdio_bus.c                   |   89 +-
 drivers/net/r6040.c                          |    2 +-
 drivers/net/sb1250-mac.c                     |   12 +-
 drivers/s390/net/qeth_core_main.c            |    4 +-
 drivers/s390/net/qeth_l2_main.c              |   14 +-
 drivers/s390/net/qeth_l3_main.c              |    8 +-
 include/linux/mv643xx_eth.h                  |   13 +-
 include/linux/phy.h                          |    2 +
 47 files changed, 1145 insertions(+), 1546 deletions(-)

Andy Fleming (1):
      gianfar: free/iounmap memory after an error in mii bus initialization

Ayaz Abdulla (1):
      forcedeth fix: take phy out of reset during power up

Ben Dooks (1):
      drivers/net/bonding: sparse fixes for exported tables

Brandeburg, Jesse (1):
      e1000: remove unused Kconfig option for disabling packet split

Bruce Allan (1):
      e1000e: remove failed request for sw/fw/hw flag

David Fries (1):
      ne.c: fix rmmod, platform driver improvements

Florian Fainelli (1):
      r6040: fix wrong assignment in r6040_free_txbufs

Frans Pop (1):
      e1000e: avoid duplicated output of device name in kernel warning

Jay Cliburn (1):
      atl2: add tx bytes statistic

Jie Yang (1):
      atl1e: remove the unneeded (struct atl1e_adapter *)

Kumar Gala (2):
      netdev: drop CONFIG_PPC_MERGE from Kconfig
      fs-enet: remove code associated with !CONFIG_PPC_MERGE

Lennert Buytenhek (28):
      mv643xx_eth: fix 'netdev_priv(dev) == dev->priv' assumption
      mv643xx_eth: fix receive buffer DMA unmapping
      mv643xx_eth: get rid of IRQF_SAMPLE_RANDOM
      mv643xx_eth: get rid of modulo operations
      mv643xx_eth: switch ->phy_lock from a spinlock to a mutex
      mv643xx_eth: use the SMI done interrupt to wait for SMI access completion
      mv643xx_eth: make napi unconditional
      mv643xx_eth: get rid of receive-side locking
      mv643xx_eth: get rid of compile-time configurable transmit checksumming
      mv643xx_eth: require contiguous receive and transmit queue numbering
      mv643xx_eth: smi sharing is a per-unit property, not a per-port one
      mv643xx_eth: remove force_phy_addr field
      mv643xx_eth: get rid of netif_{stop,wake}_queue() calls on link down/up
      mv643xx_eth: delete unused and uninteresting interrupt source mask bits
      mv643xx_eth: transmit multiqueue support
      mv643xx_eth: move all work to the napi poll handler
      mv643xx_eth: switch to netif tx queue lock, get rid of private spinlock
      mv643xx_eth: avoid dropping tx lock during transmit reclaim
      mv643xx_eth: replace array of skbs awaiting transmit completion with a queue
      mv643xx_eth: shrink default receive and transmit queue sizes
      mv643xx_eth: avoid reading ->byte_cnt twice during receive processing
      mv643xx_eth: add support for chips without transmit bandwidth control
      mv643xx_eth: fix receive checksumming
      mv643xx_eth: deal with unexpected ethernet header sizes
      mv643xx_eth: enforce frequent hardware statistics polling
      phylib: allow incremental scanning of an mii bus
      mv643xx_eth: convert to phylib
      mv643xx_eth: bump version to 1.4

Scott Feldman (4):
      enic: Don't indicate IPv6 pkts using soft-LRO
      enic: fixes for review items from Ben Hutchings
      enic: Bug fix: Free MSI intr with correct data handle
      enic: bug fix: don't set netdev->name too early

Trent Piepho (1):
      gianfar: Fix error in mdio reset timeout

Ursula Braun (2):
      qeth: use firmware MAC-address for layer2 hsi-devices
      qeth: avoid qeth recovery problems

Weiwei Wang (1):
      [netdrvr] convert sbmac tx to spin_lock_irqsave to prevent early IRQ enable

diff --git a/arch/arm/mach-kirkwood/db88f6281-bp-setup.c b/arch/arm/mach-kirkwood/db88f6281-bp-setup.c
index 610fb24..cd31779 100644
--- a/arch/arm/mach-kirkwood/db88f6281-bp-setup.c
+++ b/arch/arm/mach-kirkwood/db88f6281-bp-setup.c
@@ -25,7 +25,7 @@
 #include "common.h"
 
 static struct mv643xx_eth_platform_data db88f6281_ge00_data = {
-	.phy_addr	= 8,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
 };
 
 static struct mv_sata_platform_data db88f6281_sata_data = {
diff --git a/arch/arm/mach-kirkwood/rd88f6192-nas-setup.c b/arch/arm/mach-kirkwood/rd88f6192-nas-setup.c
index a3012d4..b1d1a87 100644
--- a/arch/arm/mach-kirkwood/rd88f6192-nas-setup.c
+++ b/arch/arm/mach-kirkwood/rd88f6192-nas-setup.c
@@ -30,7 +30,7 @@
 #define RD88F6192_GPIO_USB_VBUS		10
 
 static struct mv643xx_eth_platform_data rd88f6192_ge00_data = {
-	.phy_addr	= 8,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
 };
 
 static struct mv_sata_platform_data rd88f6192_sata_data = {
diff --git a/arch/arm/mach-kirkwood/rd88f6281-setup.c b/arch/arm/mach-kirkwood/rd88f6281-setup.c
index d96487a..b641661 100644
--- a/arch/arm/mach-kirkwood/rd88f6281-setup.c
+++ b/arch/arm/mach-kirkwood/rd88f6281-setup.c
@@ -69,7 +69,7 @@ static struct platform_device rd88f6281_nand_flash = {
 };
 
 static struct mv643xx_eth_platform_data rd88f6281_ge00_data = {
-	.phy_addr	= -1,
+	.phy_addr	= MV643XX_ETH_PHY_NONE,
 	.speed		= SPEED_1000,
 	.duplex		= DUPLEX_FULL,
 };
diff --git a/arch/arm/mach-loki/lb88rc8480-setup.c b/arch/arm/mach-loki/lb88rc8480-setup.c
index 2cc9ac9..85f9c12 100644
--- a/arch/arm/mach-loki/lb88rc8480-setup.c
+++ b/arch/arm/mach-loki/lb88rc8480-setup.c
@@ -67,7 +67,7 @@ static struct platform_device lb88rc8480_boot_flash = {
 };
 
 static struct mv643xx_eth_platform_data lb88rc8480_ge0_data = {
-	.phy_addr	= 1,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(1),
 	.mac_addr	= { 0x00, 0x50, 0x43, 0x11, 0x22, 0x33 },
 };
 
diff --git a/arch/arm/mach-mv78xx0/common.c b/arch/arm/mach-mv78xx0/common.c
index 953a26c..5842d3b 100644
--- a/arch/arm/mach-mv78xx0/common.c
+++ b/arch/arm/mach-mv78xx0/common.c
@@ -330,6 +330,7 @@ void __init mv78xx0_ge00_init(struct mv643xx_eth_platform_data *eth_data)
 struct mv643xx_eth_shared_platform_data mv78xx0_ge01_shared_data = {
 	.t_clk		= 0,
 	.dram		= &mv78xx0_mbus_dram_info,
+	.shared_smi	= &mv78xx0_ge00_shared,
 };
 
 static struct resource mv78xx0_ge01_shared_resources[] = {
@@ -370,7 +371,6 @@ static struct platform_device mv78xx0_ge01 = {
 void __init mv78xx0_ge01_init(struct mv643xx_eth_platform_data *eth_data)
 {
 	eth_data->shared = &mv78xx0_ge01_shared;
-	eth_data->shared_smi = &mv78xx0_ge00_shared;
 	mv78xx0_ge01.dev.platform_data = eth_data;
 
 	platform_device_register(&mv78xx0_ge01_shared);
@@ -384,6 +384,7 @@ void __init mv78xx0_ge01_init(struct mv643xx_eth_platform_data *eth_data)
 struct mv643xx_eth_shared_platform_data mv78xx0_ge10_shared_data = {
 	.t_clk		= 0,
 	.dram		= &mv78xx0_mbus_dram_info,
+	.shared_smi	= &mv78xx0_ge00_shared,
 };
 
 static struct resource mv78xx0_ge10_shared_resources[] = {
@@ -424,7 +425,6 @@ static struct platform_device mv78xx0_ge10 = {
 void __init mv78xx0_ge10_init(struct mv643xx_eth_platform_data *eth_data)
 {
 	eth_data->shared = &mv78xx0_ge10_shared;
-	eth_data->shared_smi = &mv78xx0_ge00_shared;
 	mv78xx0_ge10.dev.platform_data = eth_data;
 
 	platform_device_register(&mv78xx0_ge10_shared);
@@ -438,6 +438,7 @@ void __init mv78xx0_ge10_init(struct mv643xx_eth_platform_data *eth_data)
 struct mv643xx_eth_shared_platform_data mv78xx0_ge11_shared_data = {
 	.t_clk		= 0,
 	.dram		= &mv78xx0_mbus_dram_info,
+	.shared_smi	= &mv78xx0_ge00_shared,
 };
 
 static struct resource mv78xx0_ge11_shared_resources[] = {
@@ -478,7 +479,6 @@ static struct platform_device mv78xx0_ge11 = {
 void __init mv78xx0_ge11_init(struct mv643xx_eth_platform_data *eth_data)
 {
 	eth_data->shared = &mv78xx0_ge11_shared;
-	eth_data->shared_smi = &mv78xx0_ge00_shared;
 	mv78xx0_ge11.dev.platform_data = eth_data;
 
 	platform_device_register(&mv78xx0_ge11_shared);
diff --git a/arch/arm/mach-mv78xx0/db78x00-bp-setup.c b/arch/arm/mach-mv78xx0/db78x00-bp-setup.c
index a2d0c97..49f434c 100644
--- a/arch/arm/mach-mv78xx0/db78x00-bp-setup.c
+++ b/arch/arm/mach-mv78xx0/db78x00-bp-setup.c
@@ -19,19 +19,19 @@
 #include "common.h"
 
 static struct mv643xx_eth_platform_data db78x00_ge00_data = {
-	.phy_addr	= 8,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
 };
 
 static struct mv643xx_eth_platform_data db78x00_ge01_data = {
-	.phy_addr	= 9,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(9),
 };
 
 static struct mv643xx_eth_platform_data db78x00_ge10_data = {
-	.phy_addr	= -1,
+	.phy_addr	= MV643XX_ETH_PHY_NONE,
 };
 
 static struct mv643xx_eth_platform_data db78x00_ge11_data = {
-	.phy_addr	= -1,
+	.phy_addr	= MV643XX_ETH_PHY_NONE,
 };
 
 static struct mv_sata_platform_data db78x00_sata_data = {
diff --git a/arch/arm/mach-orion5x/db88f5281-setup.c b/arch/arm/mach-orion5x/db88f5281-setup.c
index ff13e90..d318bea 100644
--- a/arch/arm/mach-orion5x/db88f5281-setup.c
+++ b/arch/arm/mach-orion5x/db88f5281-setup.c
@@ -285,7 +285,7 @@ subsys_initcall(db88f5281_pci_init);
  * Ethernet
  ****************************************************************************/
 static struct mv643xx_eth_platform_data db88f5281_eth_data = {
-	.phy_addr	= 8,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
 };
 
 /*****************************************************************************
diff --git a/arch/arm/mach-orion5x/dns323-setup.c b/arch/arm/mach-orion5x/dns323-setup.c
index b38c65c..3e66098 100644
--- a/arch/arm/mach-orion5x/dns323-setup.c
+++ b/arch/arm/mach-orion5x/dns323-setup.c
@@ -79,7 +79,7 @@ subsys_initcall(dns323_pci_init);
  */
 
 static struct mv643xx_eth_platform_data dns323_eth_data = {
-	.phy_addr = 8,
+	.phy_addr = MV643XX_ETH_PHY_ADDR(8),
 };
 
 /****************************************************************************
diff --git a/arch/arm/mach-orion5x/kurobox_pro-setup.c b/arch/arm/mach-orion5x/kurobox_pro-setup.c
index e321ec3..610f2a6 100644
--- a/arch/arm/mach-orion5x/kurobox_pro-setup.c
+++ b/arch/arm/mach-orion5x/kurobox_pro-setup.c
@@ -161,7 +161,7 @@ subsys_initcall(kurobox_pro_pci_init);
  ****************************************************************************/
 
 static struct mv643xx_eth_platform_data kurobox_pro_eth_data = {
-	.phy_addr	= 8,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
 };
 
 /*****************************************************************************
diff --git a/arch/arm/mach-orion5x/mss2-setup.c b/arch/arm/mach-orion5x/mss2-setup.c
index 53ff189..68acca9 100644
--- a/arch/arm/mach-orion5x/mss2-setup.c
+++ b/arch/arm/mach-orion5x/mss2-setup.c
@@ -109,7 +109,7 @@ subsys_initcall(mss2_pci_init);
  ****************************************************************************/
 
 static struct mv643xx_eth_platform_data mss2_eth_data = {
-	.phy_addr	= 8,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
 };
 
 /*****************************************************************************
diff --git a/arch/arm/mach-orion5x/mv2120-setup.c b/arch/arm/mach-orion5x/mv2120-setup.c
index 978d4d5..97c9ccb 100644
--- a/arch/arm/mach-orion5x/mv2120-setup.c
+++ b/arch/arm/mach-orion5x/mv2120-setup.c
@@ -39,7 +39,7 @@
  * Ethernet
  ****************************************************************************/
 static struct mv643xx_eth_platform_data mv2120_eth_data = {
-	.phy_addr	= 8,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
 };
 
 static struct mv_sata_platform_data mv2120_sata_data = {
diff --git a/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c b/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
index e72fe1e..500cdad 100644
--- a/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
+++ b/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
@@ -88,7 +88,7 @@ static struct orion5x_mpp_mode rd88f5181l_fxo_mpp_modes[] __initdata = {
 };
 
 static struct mv643xx_eth_platform_data rd88f5181l_fxo_eth_data = {
-	.phy_addr	= -1,
+	.phy_addr	= MV643XX_ETH_PHY_NONE,
 	.speed		= SPEED_1000,
 	.duplex		= DUPLEX_FULL,
 };
diff --git a/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c b/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
index a1fe325..ebde814 100644
--- a/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
+++ b/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
@@ -89,7 +89,7 @@ static struct orion5x_mpp_mode rd88f5181l_ge_mpp_modes[] __initdata = {
 };
 
 static struct mv643xx_eth_platform_data rd88f5181l_ge_eth_data = {
-	.phy_addr	= -1,
+	.phy_addr	= MV643XX_ETH_PHY_NONE,
 	.speed		= SPEED_1000,
 	.duplex		= DUPLEX_FULL,
 };
diff --git a/arch/arm/mach-orion5x/rd88f5182-setup.c b/arch/arm/mach-orion5x/rd88f5182-setup.c
index 4c3bcd7..a04f9e4 100644
--- a/arch/arm/mach-orion5x/rd88f5182-setup.c
+++ b/arch/arm/mach-orion5x/rd88f5182-setup.c
@@ -221,7 +221,7 @@ subsys_initcall(rd88f5182_pci_init);
  ****************************************************************************/
 
 static struct mv643xx_eth_platform_data rd88f5182_eth_data = {
-	.phy_addr	= 8,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
 };
 
 /*****************************************************************************
diff --git a/arch/arm/mach-orion5x/ts78xx-setup.c b/arch/arm/mach-orion5x/ts78xx-setup.c
index ae0a5dc..1368e9f 100644
--- a/arch/arm/mach-orion5x/ts78xx-setup.c
+++ b/arch/arm/mach-orion5x/ts78xx-setup.c
@@ -103,8 +103,7 @@ static struct platform_device ts78xx_nor_boot_flash = {
  * Ethernet
  ****************************************************************************/
 static struct mv643xx_eth_platform_data ts78xx_eth_data = {
-	.phy_addr	= 0,
-	.force_phy_addr = 1,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
 };
 
 /*****************************************************************************
diff --git a/arch/arm/mach-orion5x/tsx09-common.c b/arch/arm/mach-orion5x/tsx09-common.c
index 83feac3..19cde24 100644
--- a/arch/arm/mach-orion5x/tsx09-common.c
+++ b/arch/arm/mach-orion5x/tsx09-common.c
@@ -48,7 +48,7 @@ void qnap_tsx09_power_off(void)
  ****************************************************************************/
 
 struct mv643xx_eth_platform_data qnap_tsx09_eth_data = {
-	.phy_addr	= 8,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
 };
 
 static int __init qnap_tsx09_parse_hex_nibble(char n)
diff --git a/arch/arm/mach-orion5x/wnr854t-setup.c b/arch/arm/mach-orion5x/wnr854t-setup.c
index b6bc43e..7ddc22c 100644
--- a/arch/arm/mach-orion5x/wnr854t-setup.c
+++ b/arch/arm/mach-orion5x/wnr854t-setup.c
@@ -92,7 +92,7 @@ static struct platform_device wnr854t_nor_flash = {
 };
 
 static struct mv643xx_eth_platform_data wnr854t_eth_data = {
-	.phy_addr	= -1,
+	.phy_addr	= MV643XX_ETH_PHY_NONE,
 	.speed		= SPEED_1000,
 	.duplex		= DUPLEX_FULL,
 };
diff --git a/arch/arm/mach-orion5x/wrt350n-v2-setup.c b/arch/arm/mach-orion5x/wrt350n-v2-setup.c
index b10da17..9a4fd52 100644
--- a/arch/arm/mach-orion5x/wrt350n-v2-setup.c
+++ b/arch/arm/mach-orion5x/wrt350n-v2-setup.c
@@ -100,7 +100,7 @@ static struct platform_device wrt350n_v2_nor_flash = {
 };
 
 static struct mv643xx_eth_platform_data wrt350n_v2_eth_data = {
-	.phy_addr	= -1,
+	.phy_addr	= MV643XX_ETH_PHY_NONE,
 	.speed		= SPEED_1000,
 	.duplex		= DUPLEX_FULL,
 };
diff --git a/arch/powerpc/sysdev/mv64x60_dev.c b/arch/powerpc/sysdev/mv64x60_dev.c
index 32e0ad0..b6bd775 100644
--- a/arch/powerpc/sysdev/mv64x60_dev.c
+++ b/arch/powerpc/sysdev/mv64x60_dev.c
@@ -293,10 +293,8 @@ static int __init mv64x60_eth_device_setup(struct device_node *np, int id,
 		return -ENODEV;
 
 	prop = of_get_property(phy, "reg", NULL);
-	if (prop) {
-		pdata.force_phy_addr = 1;
-		pdata.phy_addr = *prop;
-	}
+	if (prop)
+		pdata.phy_addr = MV643XX_ETH_PHY_ADDR(*prop);
 
 	of_node_put(phy);
 
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 031b95b..2d6a060 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1813,7 +1813,7 @@ config FEC2
 
 config FEC_MPC52xx
 	tristate "MPC52xx FEC driver"
-	depends on PPC_MERGE && PPC_MPC52xx && PPC_BESTCOMM_FEC
+	depends on PPC_MPC52xx && PPC_BESTCOMM_FEC
 	select CRC32
 	select PHYLIB
 	---help---
@@ -1938,15 +1938,6 @@ config E1000
 	  To compile this driver as a module, choose M here. The module
 	  will be called e1000.
 
-config E1000_DISABLE_PACKET_SPLIT
-	bool "Disable Packet Split for PCI express adapters"
-	depends on E1000
-	help
-	  Say Y here if you want to use the legacy receive path for PCI express
-	  hardware.
-
-	  If in doubt, say N.
-
 config E1000E
 	tristate "Intel(R) PRO/1000 PCI-Express Gigabit Ethernet support"
 	depends on PCI && (!SPARC32 || BROKEN)
@@ -2274,7 +2265,7 @@ config UGETH_TX_ON_DEMAND
 config MV643XX_ETH
 	tristate "Marvell Discovery (643XX) and Orion ethernet support"
 	depends on MV64360 || MV64X60 || (PPC_MULTIPLATFORM && PPC32) || PLAT_ORION
-	select MII
+	select PHYLIB
 	help
 	  This driver supports the gigabit ethernet MACs in the
 	  Marvell Discovery PPC/MIPS chipset family (MV643XX) and
diff --git a/drivers/net/atl1e/atl1e_hw.c b/drivers/net/atl1e/atl1e_hw.c
index 949e753..8cbc1b5 100644
--- a/drivers/net/atl1e/atl1e_hw.c
+++ b/drivers/net/atl1e/atl1e_hw.c
@@ -397,7 +397,7 @@ static int atl1e_phy_setup_autoneg_adv(struct atl1e_hw *hw)
  */
 int atl1e_phy_commit(struct atl1e_hw *hw)
 {
-	struct atl1e_adapter *adapter = (struct atl1e_adapter *)hw->adapter;
+	struct atl1e_adapter *adapter = hw->adapter;
 	struct pci_dev *pdev = adapter->pdev;
 	int ret_val;
 	u16 phy_data;
@@ -431,7 +431,7 @@ int atl1e_phy_commit(struct atl1e_hw *hw)
 
 int atl1e_phy_init(struct atl1e_hw *hw)
 {
-	struct atl1e_adapter *adapter = (struct atl1e_adapter *)hw->adapter;
+	struct atl1e_adapter *adapter = hw->adapter;
 	struct pci_dev *pdev = adapter->pdev;
 	s32 ret_val;
 	u16 phy_val;
@@ -525,7 +525,7 @@ int atl1e_phy_init(struct atl1e_hw *hw)
  */
 int atl1e_reset_hw(struct atl1e_hw *hw)
 {
-	struct atl1e_adapter *adapter = (struct atl1e_adapter *)hw->adapter;
+	struct atl1e_adapter *adapter = hw->adapter;
 	struct pci_dev *pdev = adapter->pdev;
 
 	u32 idle_status_data = 0;
diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index d548a67..5ab9c76 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -522,8 +522,10 @@ static void atl2_intr_tx(struct atl2_adapter *adapter)
 		atomic_set(&adapter->txd_read_ptr, (int)txd_read_ptr);
 
 		/* tx statistics: */
-		if (txs->ok)
+		if (txs->ok) {
+			adapter->net_stats.tx_bytes += txs->pkt_size;
 			adapter->net_stats.tx_packets++;
+		}
 		else
 			adapter->net_stats.tx_errors++;
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index f7b40ed..ffb668d 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -333,5 +333,13 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
 void bond_register_arp(struct bonding *);
 void bond_unregister_arp(struct bonding *);
 
+/* exported from bond_main.c */
+extern struct list_head bond_dev_list;
+extern struct bond_parm_tbl bond_lacp_tbl[];
+extern struct bond_parm_tbl bond_mode_tbl[];
+extern struct bond_parm_tbl xmit_hashtype_tbl[];
+extern struct bond_parm_tbl arp_validate_tbl[];
+extern struct bond_parm_tbl fail_over_mac_tbl[];
+
 #endif /* _LINUX_BONDING_H */
 
diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 19e317e..62f6297 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -155,8 +155,6 @@ do {									\
 #endif
 
 #define E1000_MNG_VLAN_NONE (-1)
-/* Number of packet split data buffers (not including the header buffer) */
-#define PS_PAGE_BUFFERS (MAX_PS_BUFFERS - 1)
 
 /* wrapper around a pointer to a socket buffer,
  * so a DMA handle can be stored along with the buffer */
@@ -168,14 +166,6 @@ struct e1000_buffer {
 	u16 next_to_watch;
 };
 
-struct e1000_ps_page {
-	struct page *ps_page[PS_PAGE_BUFFERS];
-};
-
-struct e1000_ps_page_dma {
-	u64 ps_page_dma[PS_PAGE_BUFFERS];
-};
-
 struct e1000_tx_ring {
 	/* pointer to the descriptor ring memory */
 	void *desc;
@@ -213,9 +203,6 @@ struct e1000_rx_ring {
 	unsigned int next_to_clean;
 	/* array of buffer information structs */
 	struct e1000_buffer *buffer_info;
-	/* arrays of page information for packet split */
-	struct e1000_ps_page *ps_page;
-	struct e1000_ps_page_dma *ps_page_dma;
 
 	/* cpu for rx queue */
 	int cpu;
@@ -228,8 +215,6 @@ struct e1000_rx_ring {
 	((((R)->next_to_clean > (R)->next_to_use)			\
 	  ? 0 : (R)->count) + (R)->next_to_clean - (R)->next_to_use - 1)
 
-#define E1000_RX_DESC_PS(R, i)						\
-	(&(((union e1000_rx_desc_packet_split *)((R).desc))[i]))
 #define E1000_RX_DESC_EXT(R, i)						\
 	(&(((union e1000_rx_desc_extended *)((R).desc))[i]))
 #define E1000_GET_DESC(R, i, type)	(&(((struct type *)((R).desc))[i]))
@@ -311,10 +296,8 @@ struct e1000_adapter {
 	u32 rx_int_delay;
 	u32 rx_abs_int_delay;
 	bool rx_csum;
-	unsigned int rx_ps_pages;
 	u32 gorcl;
 	u64 gorcl_old;
-	u16 rx_ps_bsize0;
 
 	/* OS defined structs */
 	struct net_device *netdev;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index ad6da7b..2ab44db 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -137,15 +137,9 @@ static int e1000_clean(struct napi_struct *napi, int budget);
 static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 			       struct e1000_rx_ring *rx_ring,
 			       int *work_done, int work_to_do);
-static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
-				  struct e1000_rx_ring *rx_ring,
-				  int *work_done, int work_to_do);
 static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
                                    struct e1000_rx_ring *rx_ring,
 				   int cleaned_count);
-static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
-                                      struct e1000_rx_ring *rx_ring,
-				      int cleaned_count);
 static int e1000_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd);
 static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 			   int cmd);
@@ -1331,7 +1325,6 @@ static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
 	pci_read_config_word(pdev, PCI_COMMAND, &hw->pci_cmd_word);
 
 	adapter->rx_buffer_len = MAXIMUM_ETHERNET_VLAN_SIZE;
-	adapter->rx_ps_bsize0 = E1000_RXBUFFER_128;
 	hw->max_frame_size = netdev->mtu +
 			     ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
 	hw->min_frame_size = MINIMUM_ETHERNET_FRAME_SIZE;
@@ -1815,26 +1808,6 @@ static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
 	}
 	memset(rxdr->buffer_info, 0, size);
 
-	rxdr->ps_page = kcalloc(rxdr->count, sizeof(struct e1000_ps_page),
-	                        GFP_KERNEL);
-	if (!rxdr->ps_page) {
-		vfree(rxdr->buffer_info);
-		DPRINTK(PROBE, ERR,
-		"Unable to allocate memory for the receive descriptor ring\n");
-		return -ENOMEM;
-	}
-
-	rxdr->ps_page_dma = kcalloc(rxdr->count,
-	                            sizeof(struct e1000_ps_page_dma),
-	                            GFP_KERNEL);
-	if (!rxdr->ps_page_dma) {
-		vfree(rxdr->buffer_info);
-		kfree(rxdr->ps_page);
-		DPRINTK(PROBE, ERR,
-		"Unable to allocate memory for the receive descriptor ring\n");
-		return -ENOMEM;
-	}
-
 	if (hw->mac_type <= e1000_82547_rev_2)
 		desc_len = sizeof(struct e1000_rx_desc);
 	else
@@ -1852,8 +1825,6 @@ static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
 		"Unable to allocate memory for the receive descriptor ring\n");
 setup_rx_desc_die:
 		vfree(rxdr->buffer_info);
-		kfree(rxdr->ps_page);
-		kfree(rxdr->ps_page_dma);
 		return -ENOMEM;
 	}
 
@@ -1932,11 +1903,7 @@ int e1000_setup_all_rx_resources(struct e1000_adapter *adapter)
 static void e1000_setup_rctl(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	u32 rctl, rfctl;
-	u32 psrctl = 0;
-#ifndef CONFIG_E1000_DISABLE_PACKET_SPLIT
-	u32 pages = 0;
-#endif
+	u32 rctl;
 
 	rctl = er32(RCTL);
 
@@ -1988,55 +1955,6 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 			break;
 	}
 
-#ifndef CONFIG_E1000_DISABLE_PACKET_SPLIT
-	/* 82571 and greater support packet-split where the protocol
-	 * header is placed in skb->data and the packet data is
-	 * placed in pages hanging off of skb_shinfo(skb)->nr_frags.
-	 * In the case of a non-split, skb->data is linearly filled,
-	 * followed by the page buffers.  Therefore, skb->data is
-	 * sized to hold the largest protocol header.
-	 */
-	/* allocations using alloc_page take too long for regular MTU
-	 * so only enable packet split for jumbo frames */
-	pages = PAGE_USE_COUNT(adapter->netdev->mtu);
-	if ((hw->mac_type >= e1000_82571) && (pages <= 3) &&
-	    PAGE_SIZE <= 16384 && (rctl & E1000_RCTL_LPE))
-		adapter->rx_ps_pages = pages;
-	else
-		adapter->rx_ps_pages = 0;
-#endif
-	if (adapter->rx_ps_pages) {
-		/* Configure extra packet-split registers */
-		rfctl = er32(RFCTL);
-		rfctl |= E1000_RFCTL_EXTEN;
-		/* disable packet split support for IPv6 extension headers,
-		 * because some malformed IPv6 headers can hang the RX */
-		rfctl |= (E1000_RFCTL_IPV6_EX_DIS |
-		          E1000_RFCTL_NEW_IPV6_EXT_DIS);
-
-		ew32(RFCTL, rfctl);
-
-		rctl |= E1000_RCTL_DTYP_PS;
-
-		psrctl |= adapter->rx_ps_bsize0 >>
-			E1000_PSRCTL_BSIZE0_SHIFT;
-
-		switch (adapter->rx_ps_pages) {
-		case 3:
-			psrctl |= PAGE_SIZE <<
-				E1000_PSRCTL_BSIZE3_SHIFT;
-		case 2:
-			psrctl |= PAGE_SIZE <<
-				E1000_PSRCTL_BSIZE2_SHIFT;
-		case 1:
-			psrctl |= PAGE_SIZE >>
-				E1000_PSRCTL_BSIZE1_SHIFT;
-			break;
-		}
-
-		ew32(PSRCTL, psrctl);
-	}
-
 	ew32(RCTL, rctl);
 }
 
@@ -2053,18 +1971,10 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rdlen, rctl, rxcsum, ctrl_ext;
 
-	if (adapter->rx_ps_pages) {
-		/* this is a 32 byte descriptor */
-		rdlen = adapter->rx_ring[0].count *
-			sizeof(union e1000_rx_desc_packet_split);
-		adapter->clean_rx = e1000_clean_rx_irq_ps;
-		adapter->alloc_rx_buf = e1000_alloc_rx_buffers_ps;
-	} else {
-		rdlen = adapter->rx_ring[0].count *
-			sizeof(struct e1000_rx_desc);
-		adapter->clean_rx = e1000_clean_rx_irq;
-		adapter->alloc_rx_buf = e1000_alloc_rx_buffers;
-	}
+	rdlen = adapter->rx_ring[0].count *
+		sizeof(struct e1000_rx_desc);
+	adapter->clean_rx = e1000_clean_rx_irq;
+	adapter->alloc_rx_buf = e1000_alloc_rx_buffers;
 
 	/* disable receives while setting up the descriptors */
 	rctl = er32(RCTL);
@@ -2109,28 +2019,14 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	/* Enable 82543 Receive Checksum Offload for TCP and UDP */
 	if (hw->mac_type >= e1000_82543) {
 		rxcsum = er32(RXCSUM);
-		if (adapter->rx_csum) {
+		if (adapter->rx_csum)
 			rxcsum |= E1000_RXCSUM_TUOFL;
-
-			/* Enable 82571 IPv4 payload checksum for UDP fragments
-			 * Must be used in conjunction with packet-split. */
-			if ((hw->mac_type >= e1000_82571) &&
-			    (adapter->rx_ps_pages)) {
-				rxcsum |= E1000_RXCSUM_IPPCSE;
-			}
-		} else {
-			rxcsum &= ~E1000_RXCSUM_TUOFL;
+		else
 			/* don't need to clear IPPCSE as it defaults to 0 */
-		}
+			rxcsum &= ~E1000_RXCSUM_TUOFL;
 		ew32(RXCSUM, rxcsum);
 	}
 
-	/* enable early receives on 82573, only takes effect if using > 2048
-	 * byte total frame size.  for example only for jumbo frames */
-#define E1000_ERT_2048 0x100
-	if (hw->mac_type == e1000_82573)
-		ew32(ERT, E1000_ERT_2048);
-
 	/* Enable Receives */
 	ew32(RCTL, rctl);
 }
@@ -2256,10 +2152,6 @@ static void e1000_free_rx_resources(struct e1000_adapter *adapter,
 
 	vfree(rx_ring->buffer_info);
 	rx_ring->buffer_info = NULL;
-	kfree(rx_ring->ps_page);
-	rx_ring->ps_page = NULL;
-	kfree(rx_ring->ps_page_dma);
-	rx_ring->ps_page_dma = NULL;
 
 	pci_free_consistent(pdev, rx_ring->size, rx_ring->desc, rx_ring->dma);
 
@@ -2292,11 +2184,9 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_buffer *buffer_info;
-	struct e1000_ps_page *ps_page;
-	struct e1000_ps_page_dma *ps_page_dma;
 	struct pci_dev *pdev = adapter->pdev;
 	unsigned long size;
-	unsigned int i, j;
+	unsigned int i;
 
 	/* Free all the Rx ring sk_buffs */
 	for (i = 0; i < rx_ring->count; i++) {
@@ -2310,25 +2200,10 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
 			dev_kfree_skb(buffer_info->skb);
 			buffer_info->skb = NULL;
 		}
-		ps_page = &rx_ring->ps_page[i];
-		ps_page_dma = &rx_ring->ps_page_dma[i];
-		for (j = 0; j < adapter->rx_ps_pages; j++) {
-			if (!ps_page->ps_page[j]) break;
-			pci_unmap_page(pdev,
-				       ps_page_dma->ps_page_dma[j],
-				       PAGE_SIZE, PCI_DMA_FROMDEVICE);
-			ps_page_dma->ps_page_dma[j] = 0;
-			put_page(ps_page->ps_page[j]);
-			ps_page->ps_page[j] = NULL;
-		}
 	}
 
 	size = sizeof(struct e1000_buffer) * rx_ring->count;
 	memset(rx_ring->buffer_info, 0, size);
-	size = sizeof(struct e1000_ps_page) * rx_ring->count;
-	memset(rx_ring->ps_page, 0, size);
-	size = sizeof(struct e1000_ps_page_dma) * rx_ring->count;
-	memset(rx_ring->ps_page_dma, 0, size);
 
 	/* Zero out the descriptor ring */
 
@@ -4235,181 +4110,6 @@ next_desc:
 }
 
 /**
- * e1000_clean_rx_irq_ps - Send received data up the network stack; packet split
- * @adapter: board private structure
- **/
-
-static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
-				  struct e1000_rx_ring *rx_ring,
-				  int *work_done, int work_to_do)
-{
-	union e1000_rx_desc_packet_split *rx_desc, *next_rxd;
-	struct net_device *netdev = adapter->netdev;
-	struct pci_dev *pdev = adapter->pdev;
-	struct e1000_buffer *buffer_info, *next_buffer;
-	struct e1000_ps_page *ps_page;
-	struct e1000_ps_page_dma *ps_page_dma;
-	struct sk_buff *skb;
-	unsigned int i, j;
-	u32 length, staterr;
-	int cleaned_count = 0;
-	bool cleaned = false;
-	unsigned int total_rx_bytes=0, total_rx_packets=0;
-
-	i = rx_ring->next_to_clean;
-	rx_desc = E1000_RX_DESC_PS(*rx_ring, i);
-	staterr = le32_to_cpu(rx_desc->wb.middle.status_error);
-	buffer_info = &rx_ring->buffer_info[i];
-
-	while (staterr & E1000_RXD_STAT_DD) {
-		ps_page = &rx_ring->ps_page[i];
-		ps_page_dma = &rx_ring->ps_page_dma[i];
-
-		if (unlikely(*work_done >= work_to_do))
-			break;
-		(*work_done)++;
-
-		skb = buffer_info->skb;
-
-		/* in the packet split case this is header only */
-		prefetch(skb->data - NET_IP_ALIGN);
-
-		if (++i == rx_ring->count) i = 0;
-		next_rxd = E1000_RX_DESC_PS(*rx_ring, i);
-		prefetch(next_rxd);
-
-		next_buffer = &rx_ring->buffer_info[i];
-
-		cleaned = true;
-		cleaned_count++;
-		pci_unmap_single(pdev, buffer_info->dma,
-				 buffer_info->length,
-				 PCI_DMA_FROMDEVICE);
-
-		if (unlikely(!(staterr & E1000_RXD_STAT_EOP))) {
-			E1000_DBG("%s: Packet Split buffers didn't pick up"
-				  " the full packet\n", netdev->name);
-			dev_kfree_skb_irq(skb);
-			goto next_desc;
-		}
-
-		if (unlikely(staterr & E1000_RXDEXT_ERR_FRAME_ERR_MASK)) {
-			dev_kfree_skb_irq(skb);
-			goto next_desc;
-		}
-
-		length = le16_to_cpu(rx_desc->wb.middle.length0);
-
-		if (unlikely(!length)) {
-			E1000_DBG("%s: Last part of the packet spanning"
-				  " multiple descriptors\n", netdev->name);
-			dev_kfree_skb_irq(skb);
-			goto next_desc;
-		}
-
-		/* Good Receive */
-		skb_put(skb, length);
-
-		{
-		/* this looks ugly, but it seems compiler issues make it
-		   more efficient than reusing j */
-		int l1 = le16_to_cpu(rx_desc->wb.upper.length[0]);
-
-		/* page alloc/put takes too long and effects small packet
-		 * throughput, so unsplit small packets and save the alloc/put*/
-		if (l1 && (l1 <= copybreak) && ((length + l1) <= adapter->rx_ps_bsize0)) {
-			u8 *vaddr;
-			/* there is no documentation about how to call
-			 * kmap_atomic, so we can't hold the mapping
-			 * very long */
-			pci_dma_sync_single_for_cpu(pdev,
-				ps_page_dma->ps_page_dma[0],
-				PAGE_SIZE,
-				PCI_DMA_FROMDEVICE);
-			vaddr = kmap_atomic(ps_page->ps_page[0],
-			                    KM_SKB_DATA_SOFTIRQ);
-			memcpy(skb_tail_pointer(skb), vaddr, l1);
-			kunmap_atomic(vaddr, KM_SKB_DATA_SOFTIRQ);
-			pci_dma_sync_single_for_device(pdev,
-				ps_page_dma->ps_page_dma[0],
-				PAGE_SIZE, PCI_DMA_FROMDEVICE);
-			/* remove the CRC */
-			l1 -= 4;
-			skb_put(skb, l1);
-			goto copydone;
-		} /* if */
-		}
-
-		for (j = 0; j < adapter->rx_ps_pages; j++) {
-			length = le16_to_cpu(rx_desc->wb.upper.length[j]);
-			if (!length)
-				break;
-			pci_unmap_page(pdev, ps_page_dma->ps_page_dma[j],
-					PAGE_SIZE, PCI_DMA_FROMDEVICE);
-			ps_page_dma->ps_page_dma[j] = 0;
-			skb_fill_page_desc(skb, j, ps_page->ps_page[j], 0,
-			                   length);
-			ps_page->ps_page[j] = NULL;
-			skb->len += length;
-			skb->data_len += length;
-			skb->truesize += length;
-		}
-
-		/* strip the ethernet crc, problem is we're using pages now so
-		 * this whole operation can get a little cpu intensive */
-		pskb_trim(skb, skb->len - 4);
-
-copydone:
-		total_rx_bytes += skb->len;
-		total_rx_packets++;
-
-		e1000_rx_checksum(adapter, staterr,
-				  le16_to_cpu(rx_desc->wb.lower.hi_dword.csum_ip.csum), skb);
-		skb->protocol = eth_type_trans(skb, netdev);
-
-		if (likely(rx_desc->wb.upper.header_status &
-			   cpu_to_le16(E1000_RXDPS_HDRSTAT_HDRSP)))
-			adapter->rx_hdr_split++;
-
-		if (unlikely(adapter->vlgrp && (staterr & E1000_RXD_STAT_VP))) {
-			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-				le16_to_cpu(rx_desc->wb.middle.vlan));
-		} else {
-			netif_receive_skb(skb);
-		}
-
-		netdev->last_rx = jiffies;
-
-next_desc:
-		rx_desc->wb.middle.status_error &= cpu_to_le32(~0xFF);
-		buffer_info->skb = NULL;
-
-		/* return some buffers to hardware, one at a time is too slow */
-		if (unlikely(cleaned_count >= E1000_RX_BUFFER_WRITE)) {
-			adapter->alloc_rx_buf(adapter, rx_ring, cleaned_count);
-			cleaned_count = 0;
-		}
-
-		/* use prefetched values */
-		rx_desc = next_rxd;
-		buffer_info = next_buffer;
-
-		staterr = le32_to_cpu(rx_desc->wb.middle.status_error);
-	}
-	rx_ring->next_to_clean = i;
-
-	cleaned_count = E1000_DESC_UNUSED(rx_ring);
-	if (cleaned_count)
-		adapter->alloc_rx_buf(adapter, rx_ring, cleaned_count);
-
-	adapter->total_rx_packets += total_rx_packets;
-	adapter->total_rx_bytes += total_rx_bytes;
-	adapter->net_stats.rx_bytes += total_rx_bytes;
-	adapter->net_stats.rx_packets += total_rx_packets;
-	return cleaned;
-}
-
-/**
  * e1000_alloc_rx_buffers - Replace used receive buffers; legacy & extended
  * @adapter: address of board private structure
  **/
@@ -4521,104 +4221,6 @@ map_skb:
 }
 
 /**
- * e1000_alloc_rx_buffers_ps - Replace used receive buffers; packet split
- * @adapter: address of board private structure
- **/
-
-static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
-				      struct e1000_rx_ring *rx_ring,
-				      int cleaned_count)
-{
-	struct e1000_hw *hw = &adapter->hw;
-	struct net_device *netdev = adapter->netdev;
-	struct pci_dev *pdev = adapter->pdev;
-	union e1000_rx_desc_packet_split *rx_desc;
-	struct e1000_buffer *buffer_info;
-	struct e1000_ps_page *ps_page;
-	struct e1000_ps_page_dma *ps_page_dma;
-	struct sk_buff *skb;
-	unsigned int i, j;
-
-	i = rx_ring->next_to_use;
-	buffer_info = &rx_ring->buffer_info[i];
-	ps_page = &rx_ring->ps_page[i];
-	ps_page_dma = &rx_ring->ps_page_dma[i];
-
-	while (cleaned_count--) {
-		rx_desc = E1000_RX_DESC_PS(*rx_ring, i);
-
-		for (j = 0; j < PS_PAGE_BUFFERS; j++) {
-			if (j < adapter->rx_ps_pages) {
-				if (likely(!ps_page->ps_page[j])) {
-					ps_page->ps_page[j] =
-						alloc_page(GFP_ATOMIC);
-					if (unlikely(!ps_page->ps_page[j])) {
-						adapter->alloc_rx_buff_failed++;
-						goto no_buffers;
-					}
-					ps_page_dma->ps_page_dma[j] =
-						pci_map_page(pdev,
-							    ps_page->ps_page[j],
-							    0, PAGE_SIZE,
-							    PCI_DMA_FROMDEVICE);
-				}
-				/* Refresh the desc even if buffer_addrs didn't
-				 * change because each write-back erases
-				 * this info.
-				 */
-				rx_desc->read.buffer_addr[j+1] =
-				     cpu_to_le64(ps_page_dma->ps_page_dma[j]);
-			} else
-				rx_desc->read.buffer_addr[j+1] = ~cpu_to_le64(0);
-		}
-
-		skb = netdev_alloc_skb(netdev,
-		                       adapter->rx_ps_bsize0 + NET_IP_ALIGN);
-
-		if (unlikely(!skb)) {
-			adapter->alloc_rx_buff_failed++;
-			break;
-		}
-
-		/* Make buffer alignment 2 beyond a 16 byte boundary
-		 * this will result in a 16 byte aligned IP header after
-		 * the 14 byte MAC header is removed
-		 */
-		skb_reserve(skb, NET_IP_ALIGN);
-
-		buffer_info->skb = skb;
-		buffer_info->length = adapter->rx_ps_bsize0;
-		buffer_info->dma = pci_map_single(pdev, skb->data,
-						  adapter->rx_ps_bsize0,
-						  PCI_DMA_FROMDEVICE);
-
-		rx_desc->read.buffer_addr[0] = cpu_to_le64(buffer_info->dma);
-
-		if (unlikely(++i == rx_ring->count)) i = 0;
-		buffer_info = &rx_ring->buffer_info[i];
-		ps_page = &rx_ring->ps_page[i];
-		ps_page_dma = &rx_ring->ps_page_dma[i];
-	}
-
-no_buffers:
-	if (likely(rx_ring->next_to_use != i)) {
-		rx_ring->next_to_use = i;
-		if (unlikely(i-- == 0)) i = (rx_ring->count - 1);
-
-		/* Force memory writes to complete before letting h/w
-		 * know there are new descriptors to fetch.  (Only
-		 * applicable for weak-ordered memory model archs,
-		 * such as IA-64). */
-		wmb();
-		/* Hardware increments by 16 bytes, but packet split
-		 * descriptors are 32 bytes...so we increment tail
-		 * twice as much.
-		 */
-		writel(i<<1, hw->hw_addr + rx_ring->rdt);
-	}
-}
-
-/**
  * e1000_smartspeed - Workaround for SmartSpeed on 82541 and 82547 controllers.
  * @adapter:
  **/
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 019b9c0..692251b 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -398,6 +398,8 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 
 	if (!timeout) {
 		hw_dbg(hw, "FW or HW has locked the resource for too long.\n");
+		extcnf_ctrl &= ~E1000_EXTCNF_CTRL_SWFLAG;
+		ew32(EXTCNF_CTRL, extcnf_ctrl);
 		return -E1000_ERR_CONFIG;
 	}
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 0925204..24d05cb 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4671,13 +4671,15 @@ static void e1000_eeprom_checks(struct e1000_adapter *adapter)
 	ret_val = e1000_read_nvm(hw, NVM_INIT_CONTROL2_REG, 1, &buf);
 	if (!(le16_to_cpu(buf) & (1 << 0))) {
 		/* Deep Smart Power Down (DSPD) */
-		e_warn("Warning: detected DSPD enabled in EEPROM\n");
+		dev_warn(&adapter->pdev->dev,
+			 "Warning: detected DSPD enabled in EEPROM\n");
 	}
 
 	ret_val = e1000_read_nvm(hw, NVM_INIT_3GIO_3, 1, &buf);
 	if (le16_to_cpu(buf) & (3 << 2)) {
 		/* ASPM enable */
-		e_warn("Warning: detected ASPM enabled in EEPROM\n");
+		dev_warn(&adapter->pdev->dev,
+			 "Warning: detected ASPM enabled in EEPROM\n");
 	}
 }
 
diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index fb83c92..7f677e8 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -33,7 +33,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco 10G Ethernet Driver"
-#define DRV_VERSION		"0.0.1.18163.472"
+#define DRV_VERSION		"0.0.1-18163.472-k1"
 #define DRV_COPYRIGHT		"Copyright 2008 Cisco Systems, Inc"
 #define PFX			DRV_NAME ": "
 
@@ -75,7 +75,6 @@ struct enic {
 	struct vnic_enet_config config;
 	struct vnic_dev_bar bar0;
 	struct vnic_dev *vdev;
-	struct net_device_stats net_stats;
 	struct timer_list notify_timer;
 	struct work_struct reset;
 	struct msix_entry msix_entry[ENIC_MSIX_MAX];
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 4cf5ec7..f3a47a8 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -43,7 +43,6 @@
 #include "enic.h"
 
 #define ENIC_NOTIFY_TIMER_PERIOD	(2 * HZ)
-#define ENIC_JUMBO_FIRST_BUF_SIZE	256
 
 /* Supported devices */
 static struct pci_device_id enic_id_table[] = {
@@ -167,9 +166,14 @@ static void enic_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 	}
 }
 
-static int enic_get_stats_count(struct net_device *netdev)
+static int enic_get_sset_count(struct net_device *netdev, int sset)
 {
-	return enic_n_tx_stats + enic_n_rx_stats;
+	switch (sset) {
+	case ETH_SS_STATS:
+		return enic_n_tx_stats + enic_n_rx_stats;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void enic_get_ethtool_stats(struct net_device *netdev,
@@ -199,8 +203,10 @@ static int enic_set_rx_csum(struct net_device *netdev, u32 data)
 {
 	struct enic *enic = netdev_priv(netdev);
 
-	enic->csum_rx_enabled =
-		(data && ENIC_SETTING(enic, RXCSUM)) ? 1 : 0;
+	if (data && !ENIC_SETTING(enic, RXCSUM))
+		return -EINVAL;
+
+	enic->csum_rx_enabled = !!data;
 
 	return 0;
 }
@@ -209,7 +215,10 @@ static int enic_set_tx_csum(struct net_device *netdev, u32 data)
 {
 	struct enic *enic = netdev_priv(netdev);
 
-	if (data && ENIC_SETTING(enic, TXCSUM))
+	if (data && !ENIC_SETTING(enic, TXCSUM))
+		return -EINVAL;
+
+	if (data)
 		netdev->features |= NETIF_F_HW_CSUM;
 	else
 		netdev->features &= ~NETIF_F_HW_CSUM;
@@ -221,7 +230,10 @@ static int enic_set_tso(struct net_device *netdev, u32 data)
 {
 	struct enic *enic = netdev_priv(netdev);
 
-	if (data && ENIC_SETTING(enic, TSO))
+	if (data && !ENIC_SETTING(enic, TSO))
+		return -EINVAL;
+
+	if (data)
 		netdev->features |=
 			NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN;
 	else
@@ -250,7 +262,7 @@ static struct ethtool_ops enic_ethtool_ops = {
 	.set_msglevel = enic_set_msglevel,
 	.get_link = ethtool_op_get_link,
 	.get_strings = enic_get_strings,
-	.get_stats_count = enic_get_stats_count,
+	.get_sset_count = enic_get_sset_count,
 	.get_ethtool_stats = enic_get_ethtool_stats,
 	.get_rx_csum = enic_get_rx_csum,
 	.set_rx_csum = enic_set_rx_csum,
@@ -652,25 +664,26 @@ static int enic_hard_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 static struct net_device_stats *enic_get_stats(struct net_device *netdev)
 {
 	struct enic *enic = netdev_priv(netdev);
+	struct net_device_stats *net_stats = &netdev->stats;
 	struct vnic_stats *stats;
 
 	spin_lock(&enic->devcmd_lock);
 	vnic_dev_stats_dump(enic->vdev, &stats);
 	spin_unlock(&enic->devcmd_lock);
 
-	enic->net_stats.tx_packets = stats->tx.tx_frames_ok;
-	enic->net_stats.tx_bytes = stats->tx.tx_bytes_ok;
-	enic->net_stats.tx_errors = stats->tx.tx_errors;
-	enic->net_stats.tx_dropped = stats->tx.tx_drops;
+	net_stats->tx_packets = stats->tx.tx_frames_ok;
+	net_stats->tx_bytes = stats->tx.tx_bytes_ok;
+	net_stats->tx_errors = stats->tx.tx_errors;
+	net_stats->tx_dropped = stats->tx.tx_drops;
 
-	enic->net_stats.rx_packets = stats->rx.rx_frames_ok;
-	enic->net_stats.rx_bytes = stats->rx.rx_bytes_ok;
-	enic->net_stats.rx_errors = stats->rx.rx_errors;
-	enic->net_stats.multicast = stats->rx.rx_multicast_frames_ok;
-	enic->net_stats.rx_crc_errors = stats->rx.rx_crc_errors;
-	enic->net_stats.rx_dropped = stats->rx.rx_no_bufs;
+	net_stats->rx_packets = stats->rx.rx_frames_ok;
+	net_stats->rx_bytes = stats->rx.rx_bytes_ok;
+	net_stats->rx_errors = stats->rx.rx_errors;
+	net_stats->multicast = stats->rx.rx_multicast_frames_ok;
+	net_stats->rx_crc_errors = stats->rx.rx_crc_errors;
+	net_stats->rx_dropped = stats->rx.rx_no_bufs;
 
-	return &enic->net_stats;
+	return net_stats;
 }
 
 static void enic_reset_mcaddrs(struct enic *enic)
@@ -941,7 +954,7 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 
 		if (enic->vlan_group && vlan_stripped) {
 
-			if (ENIC_SETTING(enic, LRO))
+			if (ENIC_SETTING(enic, LRO) && ipv4)
 				lro_vlan_hwaccel_receive_skb(&enic->lro_mgr,
 					skb, enic->vlan_group,
 					vlan, cq_desc);
@@ -951,7 +964,7 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 
 		} else {
 
-			if (ENIC_SETTING(enic, LRO))
+			if (ENIC_SETTING(enic, LRO) && ipv4)
 				lro_receive_skb(&enic->lro_mgr, skb, cq_desc);
 			else
 				netif_receive_skb(skb);
@@ -1109,7 +1122,8 @@ static void enic_notify_timer(unsigned long data)
 
 	enic_notify_check(enic);
 
-	mod_timer(&enic->notify_timer, round_jiffies(ENIC_NOTIFY_TIMER_PERIOD));
+	mod_timer(&enic->notify_timer,
+		round_jiffies(jiffies + ENIC_NOTIFY_TIMER_PERIOD));
 }
 
 static void enic_free_intr(struct enic *enic)
@@ -1119,9 +1133,11 @@ static void enic_free_intr(struct enic *enic)
 
 	switch (vnic_dev_get_intr_mode(enic->vdev)) {
 	case VNIC_DEV_INTR_MODE_INTX:
-	case VNIC_DEV_INTR_MODE_MSI:
 		free_irq(enic->pdev->irq, netdev);
 		break;
+	case VNIC_DEV_INTR_MODE_MSI:
+		free_irq(enic->pdev->irq, enic);
+		break;
 	case VNIC_DEV_INTR_MODE_MSIX:
 		for (i = 0; i < ARRAY_SIZE(enic->msix); i++)
 			if (enic->msix[i].requested)
@@ -1156,12 +1172,12 @@ static int enic_request_intr(struct enic *enic)
 	case VNIC_DEV_INTR_MODE_MSIX:
 
 		sprintf(enic->msix[ENIC_MSIX_RQ].devname,
-			"%.11s-rx", netdev->name);
+			"%.11s-rx-0", netdev->name);
 		enic->msix[ENIC_MSIX_RQ].isr = enic_isr_msix_rq;
 		enic->msix[ENIC_MSIX_RQ].devid = enic;
 
 		sprintf(enic->msix[ENIC_MSIX_WQ].devname,
-			"%.11s-tx", netdev->name);
+			"%.11s-tx-0", netdev->name);
 		enic->msix[ENIC_MSIX_WQ].isr = enic_isr_msix_wq;
 		enic->msix[ENIC_MSIX_WQ].devid = enic;
 
@@ -1234,13 +1250,28 @@ static int enic_open(struct net_device *netdev)
 	unsigned int i;
 	int err;
 
+	err = enic_request_intr(enic);
+	if (err) {
+		printk(KERN_ERR PFX "%s: Unable to request irq.\n",
+			netdev->name);
+		return err;
+	}
+
+	err = enic_notify_set(enic);
+	if (err) {
+		printk(KERN_ERR PFX
+			"%s: Failed to alloc notify buffer, aborting.\n",
+			netdev->name);
+		goto err_out_free_intr;
+	}
+
 	for (i = 0; i < enic->rq_count; i++) {
 		err = vnic_rq_fill(&enic->rq[i], enic_rq_alloc_buf);
 		if (err) {
 			printk(KERN_ERR PFX
 				"%s: Unable to alloc receive buffers.\n",
 				netdev->name);
-			return err;
+			goto err_out_notify_unset;
 		}
 	}
 
@@ -1262,6 +1293,13 @@ static int enic_open(struct net_device *netdev)
 	enic_notify_timer_start(enic);
 
 	return 0;
+
+err_out_notify_unset:
+	vnic_dev_notify_unset(enic->vdev);
+err_out_free_intr:
+	enic_free_intr(enic);
+
+	return err;
 }
 
 /* rtnl lock is held, process context */
@@ -1291,6 +1329,9 @@ static int enic_stop(struct net_device *netdev)
 			return err;
 	}
 
+	vnic_dev_notify_unset(enic->vdev);
+	enic_free_intr(enic);
+
 	(void)vnic_cq_service(&enic->cq[ENIC_CQ_RQ],
 		-1, enic_rq_service_drop, NULL);
 	(void)vnic_cq_service(&enic->cq[ENIC_CQ_WQ],
@@ -1313,14 +1354,12 @@ static int enic_change_mtu(struct net_device *netdev, int new_mtu)
 	struct enic *enic = netdev_priv(netdev);
 	int running = netif_running(netdev);
 
+	if (new_mtu < ENIC_MIN_MTU || new_mtu > ENIC_MAX_MTU)
+		return -EINVAL;
+
 	if (running)
 		enic_stop(netdev);
 
-	if (new_mtu < ENIC_MIN_MTU)
-		new_mtu = ENIC_MIN_MTU;
-	if (new_mtu > ENIC_MAX_MTU)
-		new_mtu = ENIC_MAX_MTU;
-
 	netdev->mtu = new_mtu;
 
 	if (netdev->mtu > enic->port_mtu)
@@ -1578,18 +1617,6 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 		return -ENOMEM;
 	}
 
-	/* Set the netdev name early so intr vectors are properly
-	 * named and any error msgs can include netdev->name
-	 */
-
-	rtnl_lock();
-	err = dev_alloc_name(netdev, netdev->name);
-	rtnl_unlock();
-	if (err < 0) {
-		printk(KERN_ERR PFX "Unable to allocate netdev name.\n");
-		goto err_out_free_netdev;
-	}
-
 	pci_set_drvdata(pdev, netdev);
 
 	SET_NETDEV_DEV(netdev, &pdev->dev);
@@ -1604,16 +1631,14 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	err = pci_enable_device(pdev);
 	if (err) {
 		printk(KERN_ERR PFX
-			"%s: Cannot enable PCI device, aborting.\n",
-			netdev->name);
+			"Cannot enable PCI device, aborting.\n");
 		goto err_out_free_netdev;
 	}
 
 	err = pci_request_regions(pdev, DRV_NAME);
 	if (err) {
 		printk(KERN_ERR PFX
-			"%s: Cannot request PCI regions, aborting.\n",
-			netdev->name);
+			"Cannot request PCI regions, aborting.\n");
 		goto err_out_disable_device;
 	}
 
@@ -1629,25 +1654,22 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 		if (err) {
 			printk(KERN_ERR PFX
-				"%s: No usable DMA configuration, aborting.\n",
-				netdev->name);
+				"No usable DMA configuration, aborting.\n");
 			goto err_out_release_regions;
 		}
 		err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
 		if (err) {
 			printk(KERN_ERR PFX
-				"%s: Unable to obtain 32-bit DMA "
-				"for consistent allocations, aborting.\n",
-				netdev->name);
+				"Unable to obtain 32-bit DMA "
+				"for consistent allocations, aborting.\n");
 			goto err_out_release_regions;
 		}
 	} else {
 		err = pci_set_consistent_dma_mask(pdev, DMA_40BIT_MASK);
 		if (err) {
 			printk(KERN_ERR PFX
-				"%s: Unable to obtain 40-bit DMA "
-				"for consistent allocations, aborting.\n",
-				netdev->name);
+				"Unable to obtain 40-bit DMA "
+				"for consistent allocations, aborting.\n");
 			goto err_out_release_regions;
 		}
 		using_dac = 1;
@@ -1658,8 +1680,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 
 	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
 		printk(KERN_ERR PFX
-			"%s: BAR0 not memory-map'able, aborting.\n",
-			netdev->name);
+			"BAR0 not memory-map'able, aborting.\n");
 		err = -ENODEV;
 		goto err_out_release_regions;
 	}
@@ -1670,8 +1691,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 
 	if (!enic->bar0.vaddr) {
 		printk(KERN_ERR PFX
-			"%s: Cannot memory-map BAR0 res hdr, aborting.\n",
-			netdev->name);
+			"Cannot memory-map BAR0 res hdr, aborting.\n");
 		err = -ENODEV;
 		goto err_out_release_regions;
 	}
@@ -1682,8 +1702,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	enic->vdev = vnic_dev_register(NULL, enic, pdev, &enic->bar0);
 	if (!enic->vdev) {
 		printk(KERN_ERR PFX
-			"%s: vNIC registration failed, aborting.\n",
-			netdev->name);
+			"vNIC registration failed, aborting.\n");
 		err = -ENODEV;
 		goto err_out_iounmap;
 	}
@@ -1694,8 +1713,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	err = enic_dev_open(enic);
 	if (err) {
 		printk(KERN_ERR PFX
-			"%s: vNIC dev open failed, aborting.\n",
-			netdev->name);
+			"vNIC dev open failed, aborting.\n");
 		goto err_out_vnic_unregister;
 	}
 
@@ -1712,8 +1730,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	err = vnic_dev_init(enic->vdev, 0);
 	if (err) {
 		printk(KERN_ERR PFX
-			"%s: vNIC dev init failed, aborting.\n",
-			netdev->name);
+			"vNIC dev init failed, aborting.\n");
 		goto err_out_dev_close;
 	}
 
@@ -1723,8 +1740,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	err = enic_get_vnic_config(enic);
 	if (err) {
 		printk(KERN_ERR PFX
-			"%s: Get vNIC configuration failed, aborting.\n",
-			netdev->name);
+			"Get vNIC configuration failed, aborting.\n");
 		goto err_out_dev_close;
 	}
 
@@ -1740,18 +1756,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	err = enic_set_intr_mode(enic);
 	if (err) {
 		printk(KERN_ERR PFX
-			"%s: Failed to set intr mode, aborting.\n",
-			netdev->name);
-		goto err_out_dev_close;
-	}
-
-	/* Request interrupt vector(s)
-	*/
-
-	err = enic_request_intr(enic);
-	if (err) {
-		printk(KERN_ERR PFX "%s: Unable to request irq.\n",
-			netdev->name);
+			"Failed to set intr mode, aborting.\n");
 		goto err_out_dev_close;
 	}
 
@@ -1761,8 +1766,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	err = enic_alloc_vnic_resources(enic);
 	if (err) {
 		printk(KERN_ERR PFX
-			"%s: Failed to alloc vNIC resources, aborting.\n",
-			netdev->name);
+			"Failed to alloc vNIC resources, aborting.\n");
 		goto err_out_free_vnic_resources;
 	}
 
@@ -1778,19 +1782,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 		ig_vlan_strip_en);
 	if (err) {
 		printk(KERN_ERR PFX
-			"%s: Failed to config nic, aborting.\n",
-			netdev->name);
-		goto err_out_free_vnic_resources;
-	}
-
-	/* Setup notification buffer area
-	 */
-
-	err = enic_notify_set(enic);
-	if (err) {
-		printk(KERN_ERR PFX
-			"%s: Failed to alloc notify buffer, aborting.\n",
-			netdev->name);
+			"Failed to config nic, aborting.\n");
 		goto err_out_free_vnic_resources;
 	}
 
@@ -1817,9 +1809,8 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	err = enic_set_mac_addr(netdev, enic->mac_addr);
 	if (err) {
 		printk(KERN_ERR PFX
-			"%s: Invalid MAC address, aborting.\n",
-			netdev->name);
-		goto err_out_notify_unset;
+			"Invalid MAC address, aborting.\n");
+		goto err_out_free_vnic_resources;
 	}
 
 	netdev->open = enic_open;
@@ -1873,18 +1864,14 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	err = register_netdev(netdev);
 	if (err) {
 		printk(KERN_ERR PFX
-			"%s: Cannot register net device, aborting.\n",
-			netdev->name);
-		goto err_out_notify_unset;
+			"Cannot register net device, aborting.\n");
+		goto err_out_free_vnic_resources;
 	}
 
 	return 0;
 
-err_out_notify_unset:
-	vnic_dev_notify_unset(enic->vdev);
 err_out_free_vnic_resources:
 	enic_free_vnic_resources(enic);
-	enic_free_intr(enic);
 err_out_dev_close:
 	vnic_dev_close(enic->vdev);
 err_out_vnic_unregister:
@@ -1912,9 +1899,7 @@ static void __devexit enic_remove(struct pci_dev *pdev)
 
 		flush_scheduled_work();
 		unregister_netdev(netdev);
-		vnic_dev_notify_unset(enic->vdev);
 		enic_free_vnic_resources(enic);
-		enic_free_intr(enic);
 		vnic_dev_close(enic->vdev);
 		enic_clear_intr_mode(enic);
 		vnic_dev_unregister(enic->vdev);
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 0b6ecef..35e582d 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -337,7 +337,7 @@ enum {
 	NvRegMSIXIrqStatus = 0x3f0,
 
 	NvRegPowerState2 = 0x600,
-#define NVREG_POWERSTATE2_POWERUP_MASK		0x0F11
+#define NVREG_POWERSTATE2_POWERUP_MASK		0x0F15
 #define NVREG_POWERSTATE2_POWERUP_REV_A3	0x0001
 #define NVREG_POWERSTATE2_PHY_RESET		0x0004
 };
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 9d46182..cb51c1f 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -664,23 +664,6 @@ static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-static int fs_request_irq(struct net_device *dev, int irq, const char *name,
-		irq_handler_t irqf)
-{
-	struct fs_enet_private *fep = netdev_priv(dev);
-
-	(*fep->ops->pre_request_irq)(dev, irq);
-	return request_irq(irq, irqf, IRQF_SHARED, name, dev);
-}
-
-static void fs_free_irq(struct net_device *dev, int irq)
-{
-	struct fs_enet_private *fep = netdev_priv(dev);
-
-	free_irq(irq, dev);
-	(*fep->ops->post_free_irq)(dev, irq);
-}
-
 static void fs_timeout(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
@@ -800,7 +783,8 @@ static int fs_enet_open(struct net_device *dev)
 		napi_enable(&fep->napi);
 
 	/* Install our interrupt handler. */
-	r = fs_request_irq(dev, fep->interrupt, "fs_enet-mac", fs_enet_interrupt);
+	r = request_irq(fep->interrupt, fs_enet_interrupt, IRQF_SHARED,
+			"fs_enet-mac", dev);
 	if (r != 0) {
 		printk(KERN_ERR DRV_MODULE_NAME
 		       ": %s Could not allocate FS_ENET IRQ!", dev->name);
@@ -842,7 +826,7 @@ static int fs_enet_close(struct net_device *dev)
 	/* release any irqs */
 	phy_disconnect(fep->phydev);
 	fep->phydev = NULL;
-	fs_free_irq(dev, fep->interrupt);
+	free_irq(fep->interrupt, dev);
 
 	return 0;
 }
diff --git a/drivers/net/fs_enet/fs_enet.h b/drivers/net/fs_enet/fs_enet.h
index db46d2e..85a4bab 100644
--- a/drivers/net/fs_enet/fs_enet.h
+++ b/drivers/net/fs_enet/fs_enet.h
@@ -34,8 +34,6 @@ struct fs_ops {
 	void (*adjust_link)(struct net_device *dev);
 	void (*restart)(struct net_device *dev);
 	void (*stop)(struct net_device *dev);
-	void (*pre_request_irq)(struct net_device *dev, int irq);
-	void (*post_free_irq)(struct net_device *dev, int irq);
 	void (*napi_clear_rx_event)(struct net_device *dev);
 	void (*napi_enable_rx)(struct net_device *dev);
 	void (*napi_disable_rx)(struct net_device *dev);
diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
index 1c7ef81..22e5a84 100644
--- a/drivers/net/fs_enet/mac-fcc.c
+++ b/drivers/net/fs_enet/mac-fcc.c
@@ -421,16 +421,6 @@ static void stop(struct net_device *dev)
 	fs_cleanup_bds(dev);
 }
 
-static void pre_request_irq(struct net_device *dev, int irq)
-{
-	/* nothing */
-}
-
-static void post_free_irq(struct net_device *dev, int irq)
-{
-	/* nothing */
-}
-
 static void napi_clear_rx_event(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
@@ -540,8 +530,6 @@ const struct fs_ops fs_fcc_ops = {
 	.set_multicast_list	= set_multicast_list,
 	.restart		= restart,
 	.stop			= stop,
-	.pre_request_irq	= pre_request_irq,
-	.post_free_irq		= post_free_irq,
 	.napi_clear_rx_event	= napi_clear_rx_event,
 	.napi_enable_rx		= napi_enable_rx,
 	.napi_disable_rx	= napi_disable_rx,
diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
index 0a7d1c5..14e5753 100644
--- a/drivers/net/fs_enet/mac-fec.c
+++ b/drivers/net/fs_enet/mac-fec.c
@@ -313,11 +313,7 @@ static void restart(struct net_device *dev)
 	 * Clear any outstanding interrupt.
 	 */
 	FW(fecp, ievent, 0xffc0);
-#ifndef CONFIG_PPC_MERGE
-	FW(fecp, ivec, (fep->interrupt / 2) << 29);
-#else
 	FW(fecp, ivec, (virq_to_hw(fep->interrupt) / 2) << 29);
-#endif
 
 	/*
 	 * adjust to speed (only for DUET & RMII)
@@ -413,30 +409,6 @@ static void stop(struct net_device *dev)
 	}
 }
 
-static void pre_request_irq(struct net_device *dev, int irq)
-{
-#ifndef CONFIG_PPC_MERGE
-	immap_t *immap = fs_enet_immap;
-	u32 siel;
-
-	/* SIU interrupt */
-	if (irq >= SIU_IRQ0 && irq < SIU_LEVEL7) {
-
-		siel = in_be32(&immap->im_siu_conf.sc_siel);
-		if ((irq & 1) == 0)
-			siel |= (0x80000000 >> irq);
-		else
-			siel &= ~(0x80000000 >> (irq & ~1));
-		out_be32(&immap->im_siu_conf.sc_siel, siel);
-	}
-#endif
-}
-
-static void post_free_irq(struct net_device *dev, int irq)
-{
-	/* nothing */
-}
-
 static void napi_clear_rx_event(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
@@ -529,8 +501,6 @@ const struct fs_ops fs_fec_ops = {
 	.set_multicast_list	= set_multicast_list,
 	.restart		= restart,
 	.stop			= stop,
-	.pre_request_irq	= pre_request_irq,
-	.post_free_irq		= post_free_irq,
 	.napi_clear_rx_event	= napi_clear_rx_event,
 	.napi_enable_rx		= napi_enable_rx,
 	.napi_disable_rx	= napi_disable_rx,
diff --git a/drivers/net/fs_enet/mac-scc.c b/drivers/net/fs_enet/mac-scc.c
index 22f50dd..008cdd9 100644
--- a/drivers/net/fs_enet/mac-scc.c
+++ b/drivers/net/fs_enet/mac-scc.c
@@ -377,30 +377,6 @@ static void stop(struct net_device *dev)
 	fs_cleanup_bds(dev);
 }
 
-static void pre_request_irq(struct net_device *dev, int irq)
-{
-#ifndef CONFIG_PPC_MERGE
-	immap_t *immap = fs_enet_immap;
-	u32 siel;
-
-	/* SIU interrupt */
-	if (irq >= SIU_IRQ0 && irq < SIU_LEVEL7) {
-
-		siel = in_be32(&immap->im_siu_conf.sc_siel);
-		if ((irq & 1) == 0)
-			siel |= (0x80000000 >> irq);
-		else
-			siel &= ~(0x80000000 >> (irq & ~1));
-		out_be32(&immap->im_siu_conf.sc_siel, siel);
-	}
-#endif
-}
-
-static void post_free_irq(struct net_device *dev, int irq)
-{
-	/* nothing */
-}
-
 static void napi_clear_rx_event(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
@@ -494,8 +470,6 @@ const struct fs_ops fs_scc_ops = {
 	.set_multicast_list	= set_multicast_list,
 	.restart		= restart,
 	.stop			= stop,
-	.pre_request_irq	= pre_request_irq,
-	.post_free_irq		= post_free_irq,
 	.napi_clear_rx_event	= napi_clear_rx_event,
 	.napi_enable_rx		= napi_enable_rx,
 	.napi_disable_rx	= napi_disable_rx,
diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index ebcfb27..678f48c 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -136,12 +136,12 @@ static int gfar_mdio_reset(struct mii_bus *bus)
 
 	/* Wait until the bus is free */
 	while ((gfar_read(&regs->miimind) & MIIMIND_BUSY) &&
-			timeout--)
+			--timeout)
 		cpu_relax();
 
 	mutex_unlock(&bus->mdio_lock);
 
-	if(timeout <= 0) {
+	if(timeout == 0) {
 		printk(KERN_ERR "%s: The MII Bus is stuck!\n",
 				bus->name);
 		return -EBUSY;
@@ -211,19 +211,21 @@ static int gfar_mdio_probe(struct device *dev)
 	gfar_write(&enet_regs->tbipa, 0);
 	for (i = PHY_MAX_ADDR; i > 0; i--) {
 		u32 phy_id;
-		int r;
 
-		r = get_phy_id(new_bus, i, &phy_id);
-		if (r)
-			return r;
+		err = get_phy_id(new_bus, i, &phy_id);
+		if (err)
+			goto bus_register_fail;
 
 		if (phy_id == 0xffffffff)
 			break;
 	}
 
 	/* The bus is full.  We don't support using 31 PHYs, sorry */
-	if (i == 0)
-		return -EBUSY;
+	if (i == 0) {
+		err = -EBUSY;
+
+		goto bus_register_fail;
+	}
 
 	gfar_write(&enet_regs->tbipa, i);
 
diff --git a/drivers/net/ibm_newemac/Kconfig b/drivers/net/ibm_newemac/Kconfig
index 70a3272..bcec732 100644
--- a/drivers/net/ibm_newemac/Kconfig
+++ b/drivers/net/ibm_newemac/Kconfig
@@ -1,6 +1,6 @@
 config IBM_NEW_EMAC
 	tristate "IBM EMAC Ethernet support"
-	depends on PPC_DCR && PPC_MERGE
+	depends on PPC_DCR
 	select CRC32
 	help
 	  This driver supports the IBM EMAC family of Ethernet controllers
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 0a18b9e..55aa8ba 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -48,30 +48,28 @@
 #include <linux/kernel.h>
 #include <linux/spinlock.h>
 #include <linux/workqueue.h>
-#include <linux/mii.h>
+#include <linux/phy.h>
 #include <linux/mv643xx_eth.h>
 #include <asm/io.h>
 #include <asm/types.h>
 #include <asm/system.h>
 
 static char mv643xx_eth_driver_name[] = "mv643xx_eth";
-static char mv643xx_eth_driver_version[] = "1.3";
+static char mv643xx_eth_driver_version[] = "1.4";
 
-#define MV643XX_ETH_CHECKSUM_OFFLOAD_TX
-#define MV643XX_ETH_NAPI
-#define MV643XX_ETH_TX_FAST_REFILL
-
-#ifdef MV643XX_ETH_CHECKSUM_OFFLOAD_TX
-#define MAX_DESCS_PER_SKB	(MAX_SKB_FRAGS + 1)
-#else
-#define MAX_DESCS_PER_SKB	1
-#endif
 
 /*
  * Registers shared between all ports.
  */
 #define PHY_ADDR			0x0000
 #define SMI_REG				0x0004
+#define  SMI_BUSY			0x10000000
+#define  SMI_READ_VALID			0x08000000
+#define  SMI_OPCODE_READ		0x04000000
+#define  SMI_OPCODE_WRITE		0x00000000
+#define ERR_INT_CAUSE			0x0080
+#define  ERR_INT_SMI_DONE		0x00000010
+#define ERR_INT_MASK			0x0084
 #define WINDOW_BASE(w)			(0x0200 + ((w) << 3))
 #define WINDOW_SIZE(w)			(0x0204 + ((w) << 3))
 #define WINDOW_REMAP_HIGH(w)		(0x0280 + ((w) << 2))
@@ -104,16 +102,12 @@ static char mv643xx_eth_driver_version[] = "1.3";
 #define TX_BW_MTU(p)			(0x0458 + ((p) << 10))
 #define TX_BW_BURST(p)			(0x045c + ((p) << 10))
 #define INT_CAUSE(p)			(0x0460 + ((p) << 10))
-#define  INT_TX_END_0			0x00080000
 #define  INT_TX_END			0x07f80000
-#define  INT_RX				0x0007fbfc
+#define  INT_RX				0x000003fc
 #define  INT_EXT			0x00000002
 #define INT_CAUSE_EXT(p)		(0x0464 + ((p) << 10))
-#define  INT_EXT_LINK			0x00100000
-#define  INT_EXT_PHY			0x00010000
-#define  INT_EXT_TX_ERROR_0		0x00000100
-#define  INT_EXT_TX_0			0x00000001
-#define  INT_EXT_TX			0x0000ffff
+#define  INT_EXT_LINK_PHY		0x00110000
+#define  INT_EXT_TX			0x000000ff
 #define INT_MASK(p)			(0x0468 + ((p) << 10))
 #define INT_MASK_EXT(p)			(0x046c + ((p) << 10))
 #define TX_FIFO_URGENT_THRESHOLD(p)	(0x0474 + ((p) << 10))
@@ -171,8 +165,8 @@ static char mv643xx_eth_driver_version[] = "1.3";
 #define FORCE_LINK_PASS				(1 << 1)
 #define SERIAL_PORT_ENABLE			(1 << 0)
 
-#define DEFAULT_RX_QUEUE_SIZE		400
-#define DEFAULT_TX_QUEUE_SIZE		800
+#define DEFAULT_RX_QUEUE_SIZE		128
+#define DEFAULT_TX_QUEUE_SIZE		256
 
 
 /*
@@ -249,9 +243,23 @@ struct mv643xx_eth_shared_private {
 	void __iomem *base;
 
 	/*
-	 * Protects access to SMI_REG, which is shared between ports.
+	 * Points at the right SMI instance to use.
+	 */
+	struct mv643xx_eth_shared_private *smi;
+
+	/*
+	 * Provides access to local SMI interface.
+	 */
+	struct mii_bus smi_bus;
+
+	/*
+	 * If we have access to the error interrupt pin (which is
+	 * somewhat misnamed as it not only reflects internal errors
+	 * but also reflects SMI completion), use that to wait for
+	 * SMI access completion instead of polling the SMI busy bit.
 	 */
-	spinlock_t phy_lock;
+	int err_interrupt;
+	wait_queue_head_t smi_busy_wait;
 
 	/*
 	 * Per-port MBUS window access register value.
@@ -263,9 +271,13 @@ struct mv643xx_eth_shared_private {
 	 */
 	unsigned int t_clk;
 	int extended_rx_coal_limit;
-	int tx_bw_control_moved;
+	int tx_bw_control;
 };
 
+#define TX_BW_CONTROL_ABSENT		0
+#define TX_BW_CONTROL_OLD_LAYOUT	1
+#define TX_BW_CONTROL_NEW_LAYOUT	2
+
 
 /* per-port *****************************************************************/
 struct mib_counters {
@@ -314,8 +326,6 @@ struct rx_queue {
 	dma_addr_t rx_desc_dma;
 	int rx_desc_area_size;
 	struct sk_buff **rx_skb;
-
-	struct timer_list rx_oom;
 };
 
 struct tx_queue {
@@ -330,7 +340,12 @@ struct tx_queue {
 	struct tx_desc *tx_desc_area;
 	dma_addr_t tx_desc_dma;
 	int tx_desc_area_size;
-	struct sk_buff **tx_skb;
+
+	struct sk_buff_head tx_skb;
+
+	unsigned long tx_packets;
+	unsigned long tx_bytes;
+	unsigned long tx_dropped;
 };
 
 struct mv643xx_eth_private {
@@ -339,14 +354,21 @@ struct mv643xx_eth_private {
 
 	struct net_device *dev;
 
-	struct mv643xx_eth_shared_private *shared_smi;
-	int phy_addr;
-
-	spinlock_t lock;
+	struct phy_device *phy;
 
+	struct timer_list mib_counters_timer;
+	spinlock_t mib_counters_lock;
 	struct mib_counters mib_counters;
+
 	struct work_struct tx_timeout_task;
-	struct mii_if_info mii;
+
+	struct napi_struct napi;
+	u8 work_link;
+	u8 work_tx;
+	u8 work_tx_end;
+	u8 work_rx;
+	u8 work_rx_refill;
+	u8 work_rx_oom;
 
 	/*
 	 * RX state.
@@ -354,9 +376,8 @@ struct mv643xx_eth_private {
 	int default_rx_ring_size;
 	unsigned long rx_desc_sram_addr;
 	int rx_desc_sram_size;
-	u8 rxq_mask;
-	int rxq_primary;
-	struct napi_struct napi;
+	int rxq_count;
+	struct timer_list rx_oom;
 	struct rx_queue rxq[8];
 
 	/*
@@ -365,12 +386,8 @@ struct mv643xx_eth_private {
 	int default_tx_ring_size;
 	unsigned long tx_desc_sram_addr;
 	int tx_desc_sram_size;
-	u8 txq_mask;
-	int txq_primary;
+	int txq_count;
 	struct tx_queue txq[8];
-#ifdef MV643XX_ETH_TX_FAST_REFILL
-	int tx_clean_threshold;
-#endif
 };
 
 
@@ -440,94 +457,21 @@ static void txq_disable(struct tx_queue *txq)
 		udelay(10);
 }
 
-static void __txq_maybe_wake(struct tx_queue *txq)
+static void txq_maybe_wake(struct tx_queue *txq)
 {
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
+	struct netdev_queue *nq = netdev_get_tx_queue(mp->dev, txq->index);
 
-	/*
-	 * netif_{stop,wake}_queue() flow control only applies to
-	 * the primary queue.
-	 */
-	BUG_ON(txq->index != mp->txq_primary);
-
-	if (txq->tx_ring_size - txq->tx_desc_count >= MAX_DESCS_PER_SKB)
-		netif_wake_queue(mp->dev);
-}
-
-
-/* rx ***********************************************************************/
-static void txq_reclaim(struct tx_queue *txq, int force);
-
-static void rxq_refill(struct rx_queue *rxq)
-{
-	struct mv643xx_eth_private *mp = rxq_to_mp(rxq);
-	unsigned long flags;
-
-	spin_lock_irqsave(&mp->lock, flags);
-
-	while (rxq->rx_desc_count < rxq->rx_ring_size) {
-		int skb_size;
-		struct sk_buff *skb;
-		int unaligned;
-		int rx;
-
-		/*
-		 * Reserve 2+14 bytes for an ethernet header (the
-		 * hardware automatically prepends 2 bytes of dummy
-		 * data to each received packet), 16 bytes for up to
-		 * four VLAN tags, and 4 bytes for the trailing FCS
-		 * -- 36 bytes total.
-		 */
-		skb_size = mp->dev->mtu + 36;
-
-		/*
-		 * Make sure that the skb size is a multiple of 8
-		 * bytes, as the lower three bits of the receive
-		 * descriptor's buffer size field are ignored by
-		 * the hardware.
-		 */
-		skb_size = (skb_size + 7) & ~7;
-
-		skb = dev_alloc_skb(skb_size + dma_get_cache_alignment() - 1);
-		if (skb == NULL)
-			break;
-
-		unaligned = (u32)skb->data & (dma_get_cache_alignment() - 1);
-		if (unaligned)
-			skb_reserve(skb, dma_get_cache_alignment() - unaligned);
-
-		rxq->rx_desc_count++;
-		rx = rxq->rx_used_desc;
-		rxq->rx_used_desc = (rx + 1) % rxq->rx_ring_size;
-
-		rxq->rx_desc_area[rx].buf_ptr = dma_map_single(NULL, skb->data,
-						skb_size, DMA_FROM_DEVICE);
-		rxq->rx_desc_area[rx].buf_size = skb_size;
-		rxq->rx_skb[rx] = skb;
-		wmb();
-		rxq->rx_desc_area[rx].cmd_sts = BUFFER_OWNED_BY_DMA |
-						RX_ENABLE_INTERRUPT;
-		wmb();
-
-		/*
-		 * The hardware automatically prepends 2 bytes of
-		 * dummy data to each received packet, so that the
-		 * IP header ends up 16-byte aligned.
-		 */
-		skb_reserve(skb, 2);
+	if (netif_tx_queue_stopped(nq)) {
+		__netif_tx_lock(nq, smp_processor_id());
+		if (txq->tx_ring_size - txq->tx_desc_count >= MAX_SKB_FRAGS + 1)
+			netif_tx_wake_queue(nq);
+		__netif_tx_unlock(nq);
 	}
-
-	if (rxq->rx_desc_count != rxq->rx_ring_size)
-		mod_timer(&rxq->rx_oom, jiffies + (HZ / 10));
-
-	spin_unlock_irqrestore(&mp->lock, flags);
 }
 
-static inline void rxq_refill_timer_wrapper(unsigned long data)
-{
-	rxq_refill((struct rx_queue *)data);
-}
 
+/* rx napi ******************************************************************/
 static int rxq_process(struct rx_queue *rxq, int budget)
 {
 	struct mv643xx_eth_private *mp = rxq_to_mp(rxq);
@@ -539,31 +483,31 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 		struct rx_desc *rx_desc;
 		unsigned int cmd_sts;
 		struct sk_buff *skb;
-		unsigned long flags;
-
-		spin_lock_irqsave(&mp->lock, flags);
+		u16 byte_cnt;
 
 		rx_desc = &rxq->rx_desc_area[rxq->rx_curr_desc];
 
 		cmd_sts = rx_desc->cmd_sts;
-		if (cmd_sts & BUFFER_OWNED_BY_DMA) {
-			spin_unlock_irqrestore(&mp->lock, flags);
+		if (cmd_sts & BUFFER_OWNED_BY_DMA)
 			break;
-		}
 		rmb();
 
 		skb = rxq->rx_skb[rxq->rx_curr_desc];
 		rxq->rx_skb[rxq->rx_curr_desc] = NULL;
 
-		rxq->rx_curr_desc = (rxq->rx_curr_desc + 1) % rxq->rx_ring_size;
-
-		spin_unlock_irqrestore(&mp->lock, flags);
+		rxq->rx_curr_desc++;
+		if (rxq->rx_curr_desc == rxq->rx_ring_size)
+			rxq->rx_curr_desc = 0;
 
-		dma_unmap_single(NULL, rx_desc->buf_ptr + 2,
+		dma_unmap_single(NULL, rx_desc->buf_ptr,
 				 rx_desc->buf_size, DMA_FROM_DEVICE);
 		rxq->rx_desc_count--;
 		rx++;
 
+		mp->work_rx_refill |= 1 << rxq->index;
+
+		byte_cnt = rx_desc->byte_cnt;
+
 		/*
 		 * Update statistics.
 		 *
@@ -573,7 +517,7 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 		 * byte CRC at the end of the packet (which we do count).
 		 */
 		stats->rx_packets++;
-		stats->rx_bytes += rx_desc->byte_cnt - 2;
+		stats->rx_bytes += byte_cnt - 2;
 
 		/*
 		 * In case we received a packet without first / last bits
@@ -596,72 +540,96 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 			if (cmd_sts & ERROR_SUMMARY)
 				stats->rx_errors++;
 
-			dev_kfree_skb_irq(skb);
+			dev_kfree_skb(skb);
 		} else {
 			/*
 			 * The -4 is for the CRC in the trailer of the
 			 * received packet
 			 */
-			skb_put(skb, rx_desc->byte_cnt - 2 - 4);
+			skb_put(skb, byte_cnt - 2 - 4);
 
-			if (cmd_sts & LAYER_4_CHECKSUM_OK) {
+			if (cmd_sts & LAYER_4_CHECKSUM_OK)
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
-				skb->csum = htons(
-					(cmd_sts & 0x0007fff8) >> 3);
-			}
 			skb->protocol = eth_type_trans(skb, mp->dev);
-#ifdef MV643XX_ETH_NAPI
 			netif_receive_skb(skb);
-#else
-			netif_rx(skb);
-#endif
 		}
 
 		mp->dev->last_rx = jiffies;
 	}
 
-	rxq_refill(rxq);
+	if (rx < budget)
+		mp->work_rx &= ~(1 << rxq->index);
 
 	return rx;
 }
 
-#ifdef MV643XX_ETH_NAPI
-static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
+static int rxq_refill(struct rx_queue *rxq, int budget)
 {
-	struct mv643xx_eth_private *mp;
-	int rx;
-	int i;
+	struct mv643xx_eth_private *mp = rxq_to_mp(rxq);
+	int skb_size;
+	int refilled;
 
-	mp = container_of(napi, struct mv643xx_eth_private, napi);
+	/*
+	 * Reserve 2+14 bytes for an ethernet header (the hardware
+	 * automatically prepends 2 bytes of dummy data to each
+	 * received packet), 16 bytes for up to four VLAN tags, and
+	 * 4 bytes for the trailing FCS -- 36 bytes total.
+	 */
+	skb_size = rxq_to_mp(rxq)->dev->mtu + 36;
 
-#ifdef MV643XX_ETH_TX_FAST_REFILL
-	if (++mp->tx_clean_threshold > 5) {
-		mp->tx_clean_threshold = 0;
-		for (i = 0; i < 8; i++)
-			if (mp->txq_mask & (1 << i))
-				txq_reclaim(mp->txq + i, 0);
-
-		if (netif_carrier_ok(mp->dev)) {
-			spin_lock_irq(&mp->lock);
-			__txq_maybe_wake(mp->txq + mp->txq_primary);
-			spin_unlock_irq(&mp->lock);
+	/*
+	 * Make sure that the skb size is a multiple of 8 bytes, as
+	 * the lower three bits of the receive descriptor's buffer
+	 * size field are ignored by the hardware.
+	 */
+	skb_size = (skb_size + 7) & ~7;
+
+	refilled = 0;
+	while (refilled < budget && rxq->rx_desc_count < rxq->rx_ring_size) {
+		struct sk_buff *skb;
+		int unaligned;
+		int rx;
+
+		skb = dev_alloc_skb(skb_size + dma_get_cache_alignment() - 1);
+		if (skb == NULL) {
+			mp->work_rx_oom |= 1 << rxq->index;
+			goto oom;
 		}
-	}
-#endif
 
-	rx = 0;
-	for (i = 7; rx < budget && i >= 0; i--)
-		if (mp->rxq_mask & (1 << i))
-			rx += rxq_process(mp->rxq + i, budget - rx);
+		unaligned = (u32)skb->data & (dma_get_cache_alignment() - 1);
+		if (unaligned)
+			skb_reserve(skb, dma_get_cache_alignment() - unaligned);
 
-	if (rx < budget) {
-		netif_rx_complete(mp->dev, napi);
-		wrl(mp, INT_MASK(mp->port_num), INT_TX_END | INT_RX | INT_EXT);
+		refilled++;
+		rxq->rx_desc_count++;
+
+		rx = rxq->rx_used_desc++;
+		if (rxq->rx_used_desc == rxq->rx_ring_size)
+			rxq->rx_used_desc = 0;
+
+		rxq->rx_desc_area[rx].buf_ptr = dma_map_single(NULL, skb->data,
+						skb_size, DMA_FROM_DEVICE);
+		rxq->rx_desc_area[rx].buf_size = skb_size;
+		rxq->rx_skb[rx] = skb;
+		wmb();
+		rxq->rx_desc_area[rx].cmd_sts = BUFFER_OWNED_BY_DMA |
+						RX_ENABLE_INTERRUPT;
+		wmb();
+
+		/*
+		 * The hardware automatically prepends 2 bytes of
+		 * dummy data to each received packet, so that the
+		 * IP header ends up 16-byte aligned.
+		 */
+		skb_reserve(skb, 2);
 	}
 
-	return rx;
+	if (refilled < budget)
+		mp->work_rx_refill &= ~(1 << rxq->index);
+
+oom:
+	return refilled;
 }
-#endif
 
 
 /* tx ***********************************************************************/
@@ -684,8 +652,9 @@ static int txq_alloc_desc_index(struct tx_queue *txq)
 
 	BUG_ON(txq->tx_desc_count >= txq->tx_ring_size);
 
-	tx_desc_curr = txq->tx_curr_desc;
-	txq->tx_curr_desc = (tx_desc_curr + 1) % txq->tx_ring_size;
+	tx_desc_curr = txq->tx_curr_desc++;
+	if (txq->tx_curr_desc == txq->tx_ring_size)
+		txq->tx_curr_desc = 0;
 
 	BUG_ON(txq->tx_curr_desc == txq->tx_used_desc);
 
@@ -714,10 +683,8 @@ static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
 			desc->cmd_sts = BUFFER_OWNED_BY_DMA |
 					ZERO_PADDING | TX_LAST_DESC |
 					TX_ENABLE_INTERRUPT;
-			txq->tx_skb[tx_index] = skb;
 		} else {
 			desc->cmd_sts = BUFFER_OWNED_BY_DMA;
-			txq->tx_skb[tx_index] = NULL;
 		}
 
 		desc->l4i_chk = 0;
@@ -734,144 +701,222 @@ static inline __be16 sum16_as_be(__sum16 sum)
 	return (__force __be16)sum;
 }
 
-static void txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
+static int txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
 {
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
 	int nr_frags = skb_shinfo(skb)->nr_frags;
 	int tx_index;
 	struct tx_desc *desc;
 	u32 cmd_sts;
+	u16 l4i_chk;
 	int length;
 
 	cmd_sts = TX_FIRST_DESC | GEN_CRC | BUFFER_OWNED_BY_DMA;
-
-	tx_index = txq_alloc_desc_index(txq);
-	desc = &txq->tx_desc_area[tx_index];
-
-	if (nr_frags) {
-		txq_submit_frag_skb(txq, skb);
-
-		length = skb_headlen(skb);
-		txq->tx_skb[tx_index] = NULL;
-	} else {
-		cmd_sts |= ZERO_PADDING | TX_LAST_DESC | TX_ENABLE_INTERRUPT;
-		length = skb->len;
-		txq->tx_skb[tx_index] = skb;
-	}
-
-	desc->byte_cnt = length;
-	desc->buf_ptr = dma_map_single(NULL, skb->data, length, DMA_TO_DEVICE);
+	l4i_chk = 0;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		int mac_hdr_len;
+		int tag_bytes;
 
 		BUG_ON(skb->protocol != htons(ETH_P_IP) &&
 		       skb->protocol != htons(ETH_P_8021Q));
 
-		cmd_sts |= GEN_TCP_UDP_CHECKSUM |
-			   GEN_IP_V4_CHECKSUM   |
-			   ip_hdr(skb)->ihl << TX_IHL_SHIFT;
+		tag_bytes = (void *)ip_hdr(skb) - (void *)skb->data - ETH_HLEN;
+		if (unlikely(tag_bytes & ~12)) {
+			if (skb_checksum_help(skb) == 0)
+				goto no_csum;
+			kfree_skb(skb);
+			return 1;
+		}
 
-		mac_hdr_len = (void *)ip_hdr(skb) - (void *)skb->data;
-		switch (mac_hdr_len - ETH_HLEN) {
-		case 0:
-			break;
-		case 4:
+		if (tag_bytes & 4)
 			cmd_sts |= MAC_HDR_EXTRA_4_BYTES;
-			break;
-		case 8:
+		if (tag_bytes & 8)
 			cmd_sts |= MAC_HDR_EXTRA_8_BYTES;
-			break;
-		case 12:
-			cmd_sts |= MAC_HDR_EXTRA_4_BYTES;
-			cmd_sts |= MAC_HDR_EXTRA_8_BYTES;
-			break;
-		default:
-			if (net_ratelimit())
-				dev_printk(KERN_ERR, &txq_to_mp(txq)->dev->dev,
-				   "mac header length is %d?!\n", mac_hdr_len);
-			break;
-		}
+
+		cmd_sts |= GEN_TCP_UDP_CHECKSUM |
+			   GEN_IP_V4_CHECKSUM   |
+			   ip_hdr(skb)->ihl << TX_IHL_SHIFT;
 
 		switch (ip_hdr(skb)->protocol) {
 		case IPPROTO_UDP:
 			cmd_sts |= UDP_FRAME;
-			desc->l4i_chk = ntohs(sum16_as_be(udp_hdr(skb)->check));
+			l4i_chk = ntohs(sum16_as_be(udp_hdr(skb)->check));
 			break;
 		case IPPROTO_TCP:
-			desc->l4i_chk = ntohs(sum16_as_be(tcp_hdr(skb)->check));
+			l4i_chk = ntohs(sum16_as_be(tcp_hdr(skb)->check));
 			break;
 		default:
 			BUG();
 		}
 	} else {
+no_csum:
 		/* Errata BTS #50, IHL must be 5 if no HW checksum */
 		cmd_sts |= 5 << TX_IHL_SHIFT;
-		desc->l4i_chk = 0;
 	}
 
+	tx_index = txq_alloc_desc_index(txq);
+	desc = &txq->tx_desc_area[tx_index];
+
+	if (nr_frags) {
+		txq_submit_frag_skb(txq, skb);
+		length = skb_headlen(skb);
+	} else {
+		cmd_sts |= ZERO_PADDING | TX_LAST_DESC | TX_ENABLE_INTERRUPT;
+		length = skb->len;
+	}
+
+	desc->l4i_chk = l4i_chk;
+	desc->byte_cnt = length;
+	desc->buf_ptr = dma_map_single(NULL, skb->data, length, DMA_TO_DEVICE);
+
+	__skb_queue_tail(&txq->tx_skb, skb);
+
 	/* ensure all other descriptors are written before first cmd_sts */
 	wmb();
 	desc->cmd_sts = cmd_sts;
 
-	/* clear TX_END interrupt status */
-	wrl(mp, INT_CAUSE(mp->port_num), ~(INT_TX_END_0 << txq->index));
-	rdl(mp, INT_CAUSE(mp->port_num));
+	/* clear TX_END status */
+	mp->work_tx_end &= ~(1 << txq->index);
 
 	/* ensure all descriptors are written before poking hardware */
 	wmb();
 	txq_enable(txq);
 
 	txq->tx_desc_count += nr_frags + 1;
+
+	return 0;
 }
 
 static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
-	struct net_device_stats *stats = &dev->stats;
+	int queue;
 	struct tx_queue *txq;
-	unsigned long flags;
+	struct netdev_queue *nq;
+
+	queue = skb_get_queue_mapping(skb);
+	txq = mp->txq + queue;
+	nq = netdev_get_tx_queue(dev, queue);
 
 	if (has_tiny_unaligned_frags(skb) && __skb_linearize(skb)) {
-		stats->tx_dropped++;
+		txq->tx_dropped++;
 		dev_printk(KERN_DEBUG, &dev->dev,
 			   "failed to linearize skb with tiny "
 			   "unaligned fragment\n");
 		return NETDEV_TX_BUSY;
 	}
 
-	spin_lock_irqsave(&mp->lock, flags);
-
-	txq = mp->txq + mp->txq_primary;
-
-	if (txq->tx_ring_size - txq->tx_desc_count < MAX_DESCS_PER_SKB) {
-		spin_unlock_irqrestore(&mp->lock, flags);
-		if (txq->index == mp->txq_primary && net_ratelimit())
-			dev_printk(KERN_ERR, &dev->dev,
-				   "primary tx queue full?!\n");
+	if (txq->tx_ring_size - txq->tx_desc_count < MAX_SKB_FRAGS + 1) {
+		if (net_ratelimit())
+			dev_printk(KERN_ERR, &dev->dev, "tx queue full?!\n");
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
 
-	txq_submit_skb(txq, skb);
-	stats->tx_bytes += skb->len;
-	stats->tx_packets++;
-	dev->trans_start = jiffies;
-
-	if (txq->index == mp->txq_primary) {
+	if (!txq_submit_skb(txq, skb)) {
 		int entries_left;
 
+		txq->tx_bytes += skb->len;
+		txq->tx_packets++;
+		dev->trans_start = jiffies;
+
 		entries_left = txq->tx_ring_size - txq->tx_desc_count;
-		if (entries_left < MAX_DESCS_PER_SKB)
-			netif_stop_queue(dev);
+		if (entries_left < MAX_SKB_FRAGS + 1)
+			netif_tx_stop_queue(nq);
 	}
 
-	spin_unlock_irqrestore(&mp->lock, flags);
-
 	return NETDEV_TX_OK;
 }
 
 
+/* tx napi ******************************************************************/
+static void txq_kick(struct tx_queue *txq)
+{
+	struct mv643xx_eth_private *mp = txq_to_mp(txq);
+	struct netdev_queue *nq = netdev_get_tx_queue(mp->dev, txq->index);
+	u32 hw_desc_ptr;
+	u32 expected_ptr;
+
+	__netif_tx_lock(nq, smp_processor_id());
+
+	if (rdl(mp, TXQ_COMMAND(mp->port_num)) & (1 << txq->index))
+		goto out;
+
+	hw_desc_ptr = rdl(mp, TXQ_CURRENT_DESC_PTR(mp->port_num, txq->index));
+	expected_ptr = (u32)txq->tx_desc_dma +
+				txq->tx_curr_desc * sizeof(struct tx_desc);
+
+	if (hw_desc_ptr != expected_ptr)
+		txq_enable(txq);
+
+out:
+	__netif_tx_unlock(nq);
+
+	mp->work_tx_end &= ~(1 << txq->index);
+}
+
+static int txq_reclaim(struct tx_queue *txq, int budget, int force)
+{
+	struct mv643xx_eth_private *mp = txq_to_mp(txq);
+	struct netdev_queue *nq = netdev_get_tx_queue(mp->dev, txq->index);
+	int reclaimed;
+
+	__netif_tx_lock(nq, smp_processor_id());
+
+	reclaimed = 0;
+	while (reclaimed < budget && txq->tx_desc_count > 0) {
+		int tx_index;
+		struct tx_desc *desc;
+		u32 cmd_sts;
+		struct sk_buff *skb;
+
+		tx_index = txq->tx_used_desc;
+		desc = &txq->tx_desc_area[tx_index];
+		cmd_sts = desc->cmd_sts;
+
+		if (cmd_sts & BUFFER_OWNED_BY_DMA) {
+			if (!force)
+				break;
+			desc->cmd_sts = cmd_sts & ~BUFFER_OWNED_BY_DMA;
+		}
+
+		txq->tx_used_desc = tx_index + 1;
+		if (txq->tx_used_desc == txq->tx_ring_size)
+			txq->tx_used_desc = 0;
+
+		reclaimed++;
+		txq->tx_desc_count--;
+
+		skb = NULL;
+		if (cmd_sts & TX_LAST_DESC)
+			skb = __skb_dequeue(&txq->tx_skb);
+
+		if (cmd_sts & ERROR_SUMMARY) {
+			dev_printk(KERN_INFO, &mp->dev->dev, "tx error\n");
+			mp->dev->stats.tx_errors++;
+		}
+
+		if (cmd_sts & TX_FIRST_DESC) {
+			dma_unmap_single(NULL, desc->buf_ptr,
+					 desc->byte_cnt, DMA_TO_DEVICE);
+		} else {
+			dma_unmap_page(NULL, desc->buf_ptr,
+				       desc->byte_cnt, DMA_TO_DEVICE);
+		}
+
+		if (skb)
+			dev_kfree_skb(skb);
+	}
+
+	__netif_tx_unlock(nq);
+
+	if (reclaimed < budget)
+		mp->work_tx &= ~(1 << txq->index);
+
+	return reclaimed;
+}
+
+
 /* tx rate control **********************************************************/
 /*
  * Set total maximum TX rate (shared by all TX queues for this port)
@@ -895,14 +940,17 @@ static void tx_set_rate(struct mv643xx_eth_private *mp, int rate, int burst)
 	if (bucket_size > 65535)
 		bucket_size = 65535;
 
-	if (mp->shared->tx_bw_control_moved) {
-		wrl(mp, TX_BW_RATE_MOVED(mp->port_num), token_rate);
-		wrl(mp, TX_BW_MTU_MOVED(mp->port_num), mtu);
-		wrl(mp, TX_BW_BURST_MOVED(mp->port_num), bucket_size);
-	} else {
+	switch (mp->shared->tx_bw_control) {
+	case TX_BW_CONTROL_OLD_LAYOUT:
 		wrl(mp, TX_BW_RATE(mp->port_num), token_rate);
 		wrl(mp, TX_BW_MTU(mp->port_num), mtu);
 		wrl(mp, TX_BW_BURST(mp->port_num), bucket_size);
+		break;
+	case TX_BW_CONTROL_NEW_LAYOUT:
+		wrl(mp, TX_BW_RATE_MOVED(mp->port_num), token_rate);
+		wrl(mp, TX_BW_MTU_MOVED(mp->port_num), mtu);
+		wrl(mp, TX_BW_BURST_MOVED(mp->port_num), bucket_size);
+		break;
 	}
 }
 
@@ -934,14 +982,21 @@ static void txq_set_fixed_prio_mode(struct tx_queue *txq)
 	/*
 	 * Turn on fixed priority mode.
 	 */
-	if (mp->shared->tx_bw_control_moved)
-		off = TXQ_FIX_PRIO_CONF_MOVED(mp->port_num);
-	else
+	off = 0;
+	switch (mp->shared->tx_bw_control) {
+	case TX_BW_CONTROL_OLD_LAYOUT:
 		off = TXQ_FIX_PRIO_CONF(mp->port_num);
+		break;
+	case TX_BW_CONTROL_NEW_LAYOUT:
+		off = TXQ_FIX_PRIO_CONF_MOVED(mp->port_num);
+		break;
+	}
 
-	val = rdl(mp, off);
-	val |= 1 << txq->index;
-	wrl(mp, off, val);
+	if (off) {
+		val = rdl(mp, off);
+		val |= 1 << txq->index;
+		wrl(mp, off, val);
+	}
 }
 
 static void txq_set_wrr(struct tx_queue *txq, int weight)
@@ -953,95 +1008,147 @@ static void txq_set_wrr(struct tx_queue *txq, int weight)
 	/*
 	 * Turn off fixed priority mode.
 	 */
-	if (mp->shared->tx_bw_control_moved)
-		off = TXQ_FIX_PRIO_CONF_MOVED(mp->port_num);
-	else
+	off = 0;
+	switch (mp->shared->tx_bw_control) {
+	case TX_BW_CONTROL_OLD_LAYOUT:
 		off = TXQ_FIX_PRIO_CONF(mp->port_num);
+		break;
+	case TX_BW_CONTROL_NEW_LAYOUT:
+		off = TXQ_FIX_PRIO_CONF_MOVED(mp->port_num);
+		break;
+	}
 
-	val = rdl(mp, off);
-	val &= ~(1 << txq->index);
-	wrl(mp, off, val);
+	if (off) {
+		val = rdl(mp, off);
+		val &= ~(1 << txq->index);
+		wrl(mp, off, val);
 
-	/*
-	 * Configure WRR weight for this queue.
-	 */
-	off = TXQ_BW_WRR_CONF(mp->port_num, txq->index);
+		/*
+		 * Configure WRR weight for this queue.
+		 */
+		off = TXQ_BW_WRR_CONF(mp->port_num, txq->index);
 
-	val = rdl(mp, off);
-	val = (val & ~0xff) | (weight & 0xff);
-	wrl(mp, off, val);
+		val = rdl(mp, off);
+		val = (val & ~0xff) | (weight & 0xff);
+		wrl(mp, off, val);
+	}
 }
 
 
 /* mii management interface *************************************************/
-#define SMI_BUSY		0x10000000
-#define SMI_READ_VALID		0x08000000
-#define SMI_OPCODE_READ		0x04000000
-#define SMI_OPCODE_WRITE	0x00000000
+static irqreturn_t mv643xx_eth_err_irq(int irq, void *dev_id)
+{
+	struct mv643xx_eth_shared_private *msp = dev_id;
+
+	if (readl(msp->base + ERR_INT_CAUSE) & ERR_INT_SMI_DONE) {
+		writel(~ERR_INT_SMI_DONE, msp->base + ERR_INT_CAUSE);
+		wake_up(&msp->smi_busy_wait);
+		return IRQ_HANDLED;
+	}
+
+	return IRQ_NONE;
+}
 
-static void smi_reg_read(struct mv643xx_eth_private *mp, unsigned int addr,
-			 unsigned int reg, unsigned int *value)
+static int smi_is_done(struct mv643xx_eth_shared_private *msp)
 {
-	void __iomem *smi_reg = mp->shared_smi->base + SMI_REG;
-	unsigned long flags;
-	int i;
+	return !(readl(msp->base + SMI_REG) & SMI_BUSY);
+}
 
-	/* the SMI register is a shared resource */
-	spin_lock_irqsave(&mp->shared_smi->phy_lock, flags);
+static int smi_wait_ready(struct mv643xx_eth_shared_private *msp)
+{
+	if (msp->err_interrupt == NO_IRQ) {
+		int i;
 
-	/* wait for the SMI register to become available */
-	for (i = 0; readl(smi_reg) & SMI_BUSY; i++) {
-		if (i == 1000) {
-			printk("%s: PHY busy timeout\n", mp->dev->name);
-			goto out;
+		for (i = 0; !smi_is_done(msp); i++) {
+			if (i == 10)
+				return -ETIMEDOUT;
+			msleep(10);
 		}
-		udelay(10);
+
+		return 0;
+	}
+
+	if (!wait_event_timeout(msp->smi_busy_wait, smi_is_done(msp),
+				msecs_to_jiffies(100)))
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
+static int smi_bus_read(struct mii_bus *bus, int addr, int reg)
+{
+	struct mv643xx_eth_shared_private *msp = bus->priv;
+	void __iomem *smi_reg = msp->base + SMI_REG;
+	int ret;
+
+	if (smi_wait_ready(msp)) {
+		printk("mv643xx_eth: SMI bus busy timeout\n");
+		return -ETIMEDOUT;
 	}
 
 	writel(SMI_OPCODE_READ | (reg << 21) | (addr << 16), smi_reg);
 
-	/* now wait for the data to be valid */
-	for (i = 0; !(readl(smi_reg) & SMI_READ_VALID); i++) {
-		if (i == 1000) {
-			printk("%s: PHY read timeout\n", mp->dev->name);
-			goto out;
-		}
-		udelay(10);
+	if (smi_wait_ready(msp)) {
+		printk("mv643xx_eth: SMI bus busy timeout\n");
+		return -ETIMEDOUT;
 	}
 
-	*value = readl(smi_reg) & 0xffff;
-out:
-	spin_unlock_irqrestore(&mp->shared_smi->phy_lock, flags);
+	ret = readl(smi_reg);
+	if (!(ret & SMI_READ_VALID)) {
+		printk("mv643xx_eth: SMI bus read not valid\n");
+		return -ENODEV;
+	}
+
+	return ret & 0xffff;
 }
 
-static void smi_reg_write(struct mv643xx_eth_private *mp,
-			  unsigned int addr,
-			  unsigned int reg, unsigned int value)
+static int smi_bus_write(struct mii_bus *bus, int addr, int reg, u16 val)
 {
-	void __iomem *smi_reg = mp->shared_smi->base + SMI_REG;
-	unsigned long flags;
-	int i;
-
-	/* the SMI register is a shared resource */
-	spin_lock_irqsave(&mp->shared_smi->phy_lock, flags);
+	struct mv643xx_eth_shared_private *msp = bus->priv;
+	void __iomem *smi_reg = msp->base + SMI_REG;
 
-	/* wait for the SMI register to become available */
-	for (i = 0; readl(smi_reg) & SMI_BUSY; i++) {
-		if (i == 1000) {
-			printk("%s: PHY busy timeout\n", mp->dev->name);
-			goto out;
-		}
-		udelay(10);
+	if (smi_wait_ready(msp)) {
+		printk("mv643xx_eth: SMI bus busy timeout\n");
+		return -ETIMEDOUT;
 	}
 
 	writel(SMI_OPCODE_WRITE | (reg << 21) |
-		(addr << 16) | (value & 0xffff), smi_reg);
-out:
-	spin_unlock_irqrestore(&mp->shared_smi->phy_lock, flags);
+		(addr << 16) | (val & 0xffff), smi_reg);
+
+	if (smi_wait_ready(msp)) {
+		printk("mv643xx_eth: SMI bus busy timeout\n");
+		return -ETIMEDOUT;
+	}
+
+	return 0;
 }
 
 
-/* mib counters *************************************************************/
+/* statistics ***************************************************************/
+static struct net_device_stats *mv643xx_eth_get_stats(struct net_device *dev)
+{
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	unsigned long tx_packets = 0;
+	unsigned long tx_bytes = 0;
+	unsigned long tx_dropped = 0;
+	int i;
+
+	for (i = 0; i < mp->txq_count; i++) {
+		struct tx_queue *txq = mp->txq + i;
+
+		tx_packets += txq->tx_packets;
+		tx_bytes += txq->tx_bytes;
+		tx_dropped += txq->tx_dropped;
+	}
+
+	stats->tx_packets = tx_packets;
+	stats->tx_bytes = tx_bytes;
+	stats->tx_dropped = tx_dropped;
+
+	return stats;
+}
+
 static inline u32 mib_read(struct mv643xx_eth_private *mp, int offset)
 {
 	return rdl(mp, MIB_COUNTERS(mp->port_num) + offset);
@@ -1059,6 +1166,7 @@ static void mib_counters_update(struct mv643xx_eth_private *mp)
 {
 	struct mib_counters *p = &mp->mib_counters;
 
+	spin_lock(&mp->mib_counters_lock);
 	p->good_octets_received += mib_read(mp, 0x00);
 	p->good_octets_received += (u64)mib_read(mp, 0x04) << 32;
 	p->bad_octets_received += mib_read(mp, 0x08);
@@ -1091,6 +1199,16 @@ static void mib_counters_update(struct mv643xx_eth_private *mp)
 	p->bad_crc_event += mib_read(mp, 0x74);
 	p->collision += mib_read(mp, 0x78);
 	p->late_collision += mib_read(mp, 0x7c);
+	spin_unlock(&mp->mib_counters_lock);
+
+	mod_timer(&mp->mib_counters_timer, jiffies + 30 * HZ);
+}
+
+static void mib_counters_timer_wrapper(unsigned long _mp)
+{
+	struct mv643xx_eth_private *mp = (void *)_mp;
+
+	mib_counters_update(mp);
 }
 
 
@@ -1156,9 +1274,9 @@ static int mv643xx_eth_get_settings(struct net_device *dev, struct ethtool_cmd *
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	int err;
 
-	spin_lock_irq(&mp->lock);
-	err = mii_ethtool_gset(&mp->mii, cmd);
-	spin_unlock_irq(&mp->lock);
+	err = phy_read_status(mp->phy);
+	if (err == 0)
+		err = phy_ethtool_gset(mp->phy, cmd);
 
 	/*
 	 * The MAC does not support 1000baseT_Half.
@@ -1206,18 +1324,13 @@ static int mv643xx_eth_get_settings_phyless(struct net_device *dev, struct ethto
 static int mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
-	int err;
 
 	/*
 	 * The MAC does not support 1000baseT_Half.
 	 */
 	cmd->advertising &= ~ADVERTISED_1000baseT_Half;
 
-	spin_lock_irq(&mp->lock);
-	err = mii_ethtool_sset(&mp->mii, cmd);
-	spin_unlock_irq(&mp->lock);
-
-	return err;
+	return phy_ethtool_sset(mp->phy, cmd);
 }
 
 static int mv643xx_eth_set_settings_phyless(struct net_device *dev, struct ethtool_cmd *cmd)
@@ -1239,7 +1352,7 @@ static int mv643xx_eth_nway_reset(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
-	return mii_nway_restart(&mp->mii);
+	return genphy_restart_aneg(mp->phy);
 }
 
 static int mv643xx_eth_nway_reset_phyless(struct net_device *dev)
@@ -1249,14 +1362,7 @@ static int mv643xx_eth_nway_reset_phyless(struct net_device *dev)
 
 static u32 mv643xx_eth_get_link(struct net_device *dev)
 {
-	struct mv643xx_eth_private *mp = netdev_priv(dev);
-
-	return mii_link_ok(&mp->mii);
-}
-
-static u32 mv643xx_eth_get_link_phyless(struct net_device *dev)
-{
-	return 1;
+	return !!netif_carrier_ok(dev);
 }
 
 static void mv643xx_eth_get_strings(struct net_device *dev,
@@ -1277,9 +1383,10 @@ static void mv643xx_eth_get_ethtool_stats(struct net_device *dev,
 					  struct ethtool_stats *stats,
 					  uint64_t *data)
 {
-	struct mv643xx_eth_private *mp = dev->priv;
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	int i;
 
+	mv643xx_eth_get_stats(dev);
 	mib_counters_update(mp);
 
 	for (i = 0; i < ARRAY_SIZE(mv643xx_eth_stats); i++) {
@@ -1323,7 +1430,7 @@ static const struct ethtool_ops mv643xx_eth_ethtool_ops_phyless = {
 	.set_settings		= mv643xx_eth_set_settings_phyless,
 	.get_drvinfo		= mv643xx_eth_get_drvinfo,
 	.nway_reset		= mv643xx_eth_nway_reset_phyless,
-	.get_link		= mv643xx_eth_get_link_phyless,
+	.get_link		= mv643xx_eth_get_link,
 	.set_sg			= ethtool_op_set_sg,
 	.get_strings		= mv643xx_eth_get_strings,
 	.get_ethtool_stats	= mv643xx_eth_get_ethtool_stats,
@@ -1487,7 +1594,7 @@ static int rxq_init(struct mv643xx_eth_private *mp, int index)
 
 	size = rxq->rx_ring_size * sizeof(struct rx_desc);
 
-	if (index == mp->rxq_primary && size <= mp->rx_desc_sram_size) {
+	if (index == 0 && size <= mp->rx_desc_sram_size) {
 		rxq->rx_desc_area = ioremap(mp->rx_desc_sram_addr,
 						mp->rx_desc_sram_size);
 		rxq->rx_desc_dma = mp->rx_desc_sram_addr;
@@ -1515,20 +1622,21 @@ static int rxq_init(struct mv643xx_eth_private *mp, int index)
 
 	rx_desc = (struct rx_desc *)rxq->rx_desc_area;
 	for (i = 0; i < rxq->rx_ring_size; i++) {
-		int nexti = (i + 1) % rxq->rx_ring_size;
+		int nexti;
+
+		nexti = i + 1;
+		if (nexti == rxq->rx_ring_size)
+			nexti = 0;
+
 		rx_desc[i].next_desc_ptr = rxq->rx_desc_dma +
 					nexti * sizeof(struct rx_desc);
 	}
 
-	init_timer(&rxq->rx_oom);
-	rxq->rx_oom.data = (unsigned long)rxq;
-	rxq->rx_oom.function = rxq_refill_timer_wrapper;
-
 	return 0;
 
 
 out_free:
-	if (index == mp->rxq_primary && size <= mp->rx_desc_sram_size)
+	if (index == 0 && size <= mp->rx_desc_sram_size)
 		iounmap(rxq->rx_desc_area);
 	else
 		dma_free_coherent(NULL, size,
@@ -1546,8 +1654,6 @@ static void rxq_deinit(struct rx_queue *rxq)
 
 	rxq_disable(rxq);
 
-	del_timer_sync(&rxq->rx_oom);
-
 	for (i = 0; i < rxq->rx_ring_size; i++) {
 		if (rxq->rx_skb[i]) {
 			dev_kfree_skb(rxq->rx_skb[i]);
@@ -1561,7 +1667,7 @@ static void rxq_deinit(struct rx_queue *rxq)
 			   rxq->rx_desc_count);
 	}
 
-	if (rxq->index == mp->rxq_primary &&
+	if (rxq->index == 0 &&
 	    rxq->rx_desc_area_size <= mp->rx_desc_sram_size)
 		iounmap(rxq->rx_desc_area);
 	else
@@ -1588,7 +1694,7 @@ static int txq_init(struct mv643xx_eth_private *mp, int index)
 
 	size = txq->tx_ring_size * sizeof(struct tx_desc);
 
-	if (index == mp->txq_primary && size <= mp->tx_desc_sram_size) {
+	if (index == 0 && size <= mp->tx_desc_sram_size) {
 		txq->tx_desc_area = ioremap(mp->tx_desc_sram_addr,
 						mp->tx_desc_sram_size);
 		txq->tx_desc_dma = mp->tx_desc_sram_addr;
@@ -1601,120 +1707,97 @@ static int txq_init(struct mv643xx_eth_private *mp, int index)
 	if (txq->tx_desc_area == NULL) {
 		dev_printk(KERN_ERR, &mp->dev->dev,
 			   "can't allocate tx ring (%d bytes)\n", size);
-		goto out;
+		return -ENOMEM;
 	}
 	memset(txq->tx_desc_area, 0, size);
 
 	txq->tx_desc_area_size = size;
-	txq->tx_skb = kmalloc(txq->tx_ring_size * sizeof(*txq->tx_skb),
-								GFP_KERNEL);
-	if (txq->tx_skb == NULL) {
-		dev_printk(KERN_ERR, &mp->dev->dev,
-			   "can't allocate tx skb ring\n");
-		goto out_free;
-	}
 
 	tx_desc = (struct tx_desc *)txq->tx_desc_area;
 	for (i = 0; i < txq->tx_ring_size; i++) {
 		struct tx_desc *txd = tx_desc + i;
-		int nexti = (i + 1) % txq->tx_ring_size;
+		int nexti;
+
+		nexti = i + 1;
+		if (nexti == txq->tx_ring_size)
+			nexti = 0;
 
 		txd->cmd_sts = 0;
 		txd->next_desc_ptr = txq->tx_desc_dma +
 					nexti * sizeof(struct tx_desc);
 	}
 
-	return 0;
-
+	skb_queue_head_init(&txq->tx_skb);
 
-out_free:
-	if (index == mp->txq_primary && size <= mp->tx_desc_sram_size)
-		iounmap(txq->tx_desc_area);
-	else
-		dma_free_coherent(NULL, size,
-				  txq->tx_desc_area,
-				  txq->tx_desc_dma);
-
-out:
-	return -ENOMEM;
+	return 0;
 }
 
-static void txq_reclaim(struct tx_queue *txq, int force)
+static void txq_deinit(struct tx_queue *txq)
 {
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
-	unsigned long flags;
 
-	spin_lock_irqsave(&mp->lock, flags);
-	while (txq->tx_desc_count > 0) {
-		int tx_index;
-		struct tx_desc *desc;
-		u32 cmd_sts;
-		struct sk_buff *skb;
-		dma_addr_t addr;
-		int count;
-
-		tx_index = txq->tx_used_desc;
-		desc = &txq->tx_desc_area[tx_index];
-		cmd_sts = desc->cmd_sts;
+	txq_disable(txq);
+	txq_reclaim(txq, txq->tx_ring_size, 1);
 
-		if (cmd_sts & BUFFER_OWNED_BY_DMA) {
-			if (!force)
-				break;
-			desc->cmd_sts = cmd_sts & ~BUFFER_OWNED_BY_DMA;
-		}
+	BUG_ON(txq->tx_used_desc != txq->tx_curr_desc);
 
-		txq->tx_used_desc = (tx_index + 1) % txq->tx_ring_size;
-		txq->tx_desc_count--;
+	if (txq->index == 0 &&
+	    txq->tx_desc_area_size <= mp->tx_desc_sram_size)
+		iounmap(txq->tx_desc_area);
+	else
+		dma_free_coherent(NULL, txq->tx_desc_area_size,
+				  txq->tx_desc_area, txq->tx_desc_dma);
+}
 
-		addr = desc->buf_ptr;
-		count = desc->byte_cnt;
-		skb = txq->tx_skb[tx_index];
-		txq->tx_skb[tx_index] = NULL;
 
-		if (cmd_sts & ERROR_SUMMARY) {
-			dev_printk(KERN_INFO, &mp->dev->dev, "tx error\n");
-			mp->dev->stats.tx_errors++;
-		}
+/* netdev ops and related ***************************************************/
+static int mv643xx_eth_collect_events(struct mv643xx_eth_private *mp)
+{
+	u32 int_cause;
+	u32 int_cause_ext;
 
-		/*
-		 * Drop mp->lock while we free the skb.
-		 */
-		spin_unlock_irqrestore(&mp->lock, flags);
+	int_cause = rdl(mp, INT_CAUSE(mp->port_num)) &
+			(INT_TX_END | INT_RX | INT_EXT);
+	if (int_cause == 0)
+		return 0;
 
-		if (cmd_sts & TX_FIRST_DESC)
-			dma_unmap_single(NULL, addr, count, DMA_TO_DEVICE);
-		else
-			dma_unmap_page(NULL, addr, count, DMA_TO_DEVICE);
+	int_cause_ext = 0;
+	if (int_cause & INT_EXT)
+		int_cause_ext = rdl(mp, INT_CAUSE_EXT(mp->port_num));
 
-		if (skb)
-			dev_kfree_skb_irq(skb);
+	int_cause &= INT_TX_END | INT_RX;
+	if (int_cause) {
+		wrl(mp, INT_CAUSE(mp->port_num), ~int_cause);
+		mp->work_tx_end |= ((int_cause & INT_TX_END) >> 19) &
+				~(rdl(mp, TXQ_COMMAND(mp->port_num)) & 0xff);
+		mp->work_rx |= (int_cause & INT_RX) >> 2;
+	}
 
-		spin_lock_irqsave(&mp->lock, flags);
+	int_cause_ext &= INT_EXT_LINK_PHY | INT_EXT_TX;
+	if (int_cause_ext) {
+		wrl(mp, INT_CAUSE_EXT(mp->port_num), ~int_cause_ext);
+		if (int_cause_ext & INT_EXT_LINK_PHY)
+			mp->work_link = 1;
+		mp->work_tx |= int_cause_ext & INT_EXT_TX;
 	}
-	spin_unlock_irqrestore(&mp->lock, flags);
+
+	return 1;
 }
 
-static void txq_deinit(struct tx_queue *txq)
+static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 {
-	struct mv643xx_eth_private *mp = txq_to_mp(txq);
-
-	txq_disable(txq);
-	txq_reclaim(txq, 1);
+	struct net_device *dev = (struct net_device *)dev_id;
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
-	BUG_ON(txq->tx_used_desc != txq->tx_curr_desc);
+	if (unlikely(!mv643xx_eth_collect_events(mp)))
+		return IRQ_NONE;
 
-	if (txq->index == mp->txq_primary &&
-	    txq->tx_desc_area_size <= mp->tx_desc_sram_size)
-		iounmap(txq->tx_desc_area);
-	else
-		dma_free_coherent(NULL, txq->tx_desc_area_size,
-				  txq->tx_desc_area, txq->tx_desc_dma);
+	wrl(mp, INT_MASK(mp->port_num), 0);
+	napi_schedule(&mp->napi);
 
-	kfree(txq->tx_skb);
+	return IRQ_HANDLED;
 }
 
-
-/* netdev ops and related ***************************************************/
 static void handle_link_event(struct mv643xx_eth_private *mp)
 {
 	struct net_device *dev = mp->dev;
@@ -1731,15 +1814,12 @@ static void handle_link_event(struct mv643xx_eth_private *mp)
 			printk(KERN_INFO "%s: link down\n", dev->name);
 
 			netif_carrier_off(dev);
-			netif_stop_queue(dev);
 
-			for (i = 0; i < 8; i++) {
+			for (i = 0; i < mp->txq_count; i++) {
 				struct tx_queue *txq = mp->txq + i;
 
-				if (mp->txq_mask & (1 << i)) {
-					txq_reclaim(txq, 1);
-					txq_reset_hw_ptr(txq);
-				}
+				txq_reclaim(txq, txq->tx_ring_size, 1);
+				txq_reset_hw_ptr(txq);
 			}
 		}
 		return;
@@ -1767,119 +1847,93 @@ static void handle_link_event(struct mv643xx_eth_private *mp)
 			 speed, duplex ? "full" : "half",
 			 fc ? "en" : "dis");
 
-	if (!netif_carrier_ok(dev)) {
+	if (!netif_carrier_ok(dev))
 		netif_carrier_on(dev);
-		netif_wake_queue(dev);
-	}
 }
 
-static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
+static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 {
-	struct net_device *dev = (struct net_device *)dev_id;
-	struct mv643xx_eth_private *mp = netdev_priv(dev);
-	u32 int_cause;
-	u32 int_cause_ext;
-
-	int_cause = rdl(mp, INT_CAUSE(mp->port_num)) &
-			(INT_TX_END | INT_RX | INT_EXT);
-	if (int_cause == 0)
-		return IRQ_NONE;
-
-	int_cause_ext = 0;
-	if (int_cause & INT_EXT) {
-		int_cause_ext = rdl(mp, INT_CAUSE_EXT(mp->port_num))
-				& (INT_EXT_LINK | INT_EXT_PHY | INT_EXT_TX);
-		wrl(mp, INT_CAUSE_EXT(mp->port_num), ~int_cause_ext);
-	}
-
-	if (int_cause_ext & (INT_EXT_PHY | INT_EXT_LINK))
-		handle_link_event(mp);
+	struct mv643xx_eth_private *mp;
+	int work_done;
 
-	/*
-	 * RxBuffer or RxError set for any of the 8 queues?
-	 */
-#ifdef MV643XX_ETH_NAPI
-	if (int_cause & INT_RX) {
-		wrl(mp, INT_CAUSE(mp->port_num), ~(int_cause & INT_RX));
-		wrl(mp, INT_MASK(mp->port_num), 0x00000000);
-		rdl(mp, INT_MASK(mp->port_num));
+	mp = container_of(napi, struct mv643xx_eth_private, napi);
 
-		netif_rx_schedule(dev, &mp->napi);
-	}
-#else
-	if (int_cause & INT_RX) {
-		int i;
+	mp->work_rx_refill |= mp->work_rx_oom;
+	mp->work_rx_oom = 0;
 
-		for (i = 7; i >= 0; i--)
-			if (mp->rxq_mask & (1 << i))
-				rxq_process(mp->rxq + i, INT_MAX);
-	}
-#endif
+	work_done = 0;
+	while (work_done < budget) {
+		u8 queue_mask;
+		int queue;
+		int work_tbd;
 
-	/*
-	 * TxBuffer or TxError set for any of the 8 queues?
-	 */
-	if (int_cause_ext & INT_EXT_TX) {
-		int i;
+		if (mp->work_link) {
+			mp->work_link = 0;
+			handle_link_event(mp);
+			continue;
+		}
 
-		for (i = 0; i < 8; i++)
-			if (mp->txq_mask & (1 << i))
-				txq_reclaim(mp->txq + i, 0);
+		queue_mask = mp->work_tx | mp->work_tx_end |
+				mp->work_rx | mp->work_rx_refill;
+		if (!queue_mask) {
+			if (mv643xx_eth_collect_events(mp))
+				continue;
+			break;
+		}
 
-		/*
-		 * Enough space again in the primary TX queue for a
-		 * full packet?
-		 */
-		if (netif_carrier_ok(dev)) {
-			spin_lock(&mp->lock);
-			__txq_maybe_wake(mp->txq + mp->txq_primary);
-			spin_unlock(&mp->lock);
+		queue = fls(queue_mask) - 1;
+		queue_mask = 1 << queue;
+
+		work_tbd = budget - work_done;
+		if (work_tbd > 16)
+			work_tbd = 16;
+
+		if (mp->work_tx_end & queue_mask) {
+			txq_kick(mp->txq + queue);
+		} else if (mp->work_tx & queue_mask) {
+			work_done += txq_reclaim(mp->txq + queue, work_tbd, 0);
+			txq_maybe_wake(mp->txq + queue);
+		} else if (mp->work_rx & queue_mask) {
+			work_done += rxq_process(mp->rxq + queue, work_tbd);
+		} else if (mp->work_rx_refill & queue_mask) {
+			work_done += rxq_refill(mp->rxq + queue, work_tbd);
+		} else {
+			BUG();
 		}
 	}
 
-	/*
-	 * Any TxEnd interrupts?
-	 */
-	if (int_cause & INT_TX_END) {
-		int i;
-
-		wrl(mp, INT_CAUSE(mp->port_num), ~(int_cause & INT_TX_END));
-
-		spin_lock(&mp->lock);
-		for (i = 0; i < 8; i++) {
-			struct tx_queue *txq = mp->txq + i;
-			u32 hw_desc_ptr;
-			u32 expected_ptr;
-
-			if ((int_cause & (INT_TX_END_0 << i)) == 0)
-				continue;
+	if (work_done < budget) {
+		if (mp->work_rx_oom)
+			mod_timer(&mp->rx_oom, jiffies + (HZ / 10));
+		napi_complete(napi);
+		wrl(mp, INT_MASK(mp->port_num), INT_TX_END | INT_RX | INT_EXT);
+	}
 
-			hw_desc_ptr =
-				rdl(mp, TXQ_CURRENT_DESC_PTR(mp->port_num, i));
-			expected_ptr = (u32)txq->tx_desc_dma +
-				txq->tx_curr_desc * sizeof(struct tx_desc);
+	return work_done;
+}
 
-			if (hw_desc_ptr != expected_ptr)
-				txq_enable(txq);
-		}
-		spin_unlock(&mp->lock);
-	}
+static inline void oom_timer_wrapper(unsigned long data)
+{
+	struct mv643xx_eth_private *mp = (void *)data;
 
-	return IRQ_HANDLED;
+	napi_schedule(&mp->napi);
 }
 
 static void phy_reset(struct mv643xx_eth_private *mp)
 {
-	unsigned int data;
+	int data;
+
+	data = phy_read(mp->phy, MII_BMCR);
+	if (data < 0)
+		return;
 
-	smi_reg_read(mp, mp->phy_addr, MII_BMCR, &data);
 	data |= BMCR_RESET;
-	smi_reg_write(mp, mp->phy_addr, MII_BMCR, data);
+	if (phy_write(mp->phy, MII_BMCR, data) < 0)
+		return;
 
 	do {
-		udelay(1);
-		smi_reg_read(mp, mp->phy_addr, MII_BMCR, &data);
-	} while (data & BMCR_RESET);
+		data = phy_read(mp->phy, MII_BMCR);
+	} while (data >= 0 && data & BMCR_RESET);
 }
 
 static void port_start(struct mv643xx_eth_private *mp)
@@ -1890,7 +1944,7 @@ static void port_start(struct mv643xx_eth_private *mp)
 	/*
 	 * Perform PHY reset, if there is a PHY.
 	 */
-	if (mp->phy_addr != -1) {
+	if (mp->phy != NULL) {
 		struct ethtool_cmd cmd;
 
 		mv643xx_eth_get_settings(mp->dev, &cmd);
@@ -1907,7 +1961,7 @@ static void port_start(struct mv643xx_eth_private *mp)
 	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
 
 	pscr |= DO_NOT_FORCE_LINK_FAIL;
-	if (mp->phy_addr == -1)
+	if (mp->phy == NULL)
 		pscr |= FORCE_LINK_PASS;
 	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
 
@@ -1917,12 +1971,9 @@ static void port_start(struct mv643xx_eth_private *mp)
 	 * Configure TX path and queues.
 	 */
 	tx_set_rate(mp, 1000000000, 16777216);
-	for (i = 0; i < 8; i++) {
+	for (i = 0; i < mp->txq_count; i++) {
 		struct tx_queue *txq = mp->txq + i;
 
-		if ((mp->txq_mask & (1 << i)) == 0)
-			continue;
-
 		txq_reset_hw_ptr(txq);
 		txq_set_rate(txq, 1000000000, 16777216);
 		txq_set_fixed_prio_mode(txq);
@@ -1935,9 +1986,10 @@ static void port_start(struct mv643xx_eth_private *mp)
 
 	/*
 	 * Receive all unmatched unicast, TCP, UDP, BPDU and broadcast
-	 * frames to RX queue #0.
+	 * frames to RX queue #0, and include the pseudo-header when
+	 * calculating receive checksums.
 	 */
-	wrl(mp, PORT_CONFIG(mp->port_num), 0x00000000);
+	wrl(mp, PORT_CONFIG(mp->port_num), 0x02000000);
 
 	/*
 	 * Treat BPDUs as normal multicasts, and disable partition mode.
@@ -1947,14 +1999,11 @@ static void port_start(struct mv643xx_eth_private *mp)
 	/*
 	 * Enable the receive queues.
 	 */
-	for (i = 0; i < 8; i++) {
+	for (i = 0; i < mp->rxq_count; i++) {
 		struct rx_queue *rxq = mp->rxq + i;
 		int off = RXQ_CURRENT_DESC_PTR(mp->port_num, i);
 		u32 addr;
 
-		if ((mp->rxq_mask & (1 << i)) == 0)
-			continue;
-
 		addr = (u32)rxq->rx_desc_dma;
 		addr += rxq->rx_curr_desc * sizeof(struct rx_desc);
 		wrl(mp, off, addr);
@@ -2004,8 +2053,7 @@ static int mv643xx_eth_open(struct net_device *dev)
 	rdl(mp, INT_CAUSE_EXT(mp->port_num));
 
 	err = request_irq(dev->irq, mv643xx_eth_irq,
-			  IRQF_SHARED | IRQF_SAMPLE_RANDOM,
-			  dev->name, dev);
+			  IRQF_SHARED, dev->name, dev);
 	if (err) {
 		dev_printk(KERN_ERR, &dev->dev, "can't assign irq\n");
 		return -EAGAIN;
@@ -2013,58 +2061,49 @@ static int mv643xx_eth_open(struct net_device *dev)
 
 	init_mac_tables(mp);
 
-	for (i = 0; i < 8; i++) {
-		if ((mp->rxq_mask & (1 << i)) == 0)
-			continue;
+	napi_enable(&mp->napi);
 
+	for (i = 0; i < mp->rxq_count; i++) {
 		err = rxq_init(mp, i);
 		if (err) {
 			while (--i >= 0)
-				if (mp->rxq_mask & (1 << i))
-					rxq_deinit(mp->rxq + i);
+				rxq_deinit(mp->rxq + i);
 			goto out;
 		}
 
-		rxq_refill(mp->rxq + i);
+		rxq_refill(mp->rxq + i, INT_MAX);
 	}
 
-	for (i = 0; i < 8; i++) {
-		if ((mp->txq_mask & (1 << i)) == 0)
-			continue;
+	if (mp->work_rx_oom) {
+		mp->rx_oom.expires = jiffies + (HZ / 10);
+		add_timer(&mp->rx_oom);
+	}
 
+	for (i = 0; i < mp->txq_count; i++) {
 		err = txq_init(mp, i);
 		if (err) {
 			while (--i >= 0)
-				if (mp->txq_mask & (1 << i))
-					txq_deinit(mp->txq + i);
+				txq_deinit(mp->txq + i);
 			goto out_free;
 		}
 	}
 
-#ifdef MV643XX_ETH_NAPI
-	napi_enable(&mp->napi);
-#endif
-
 	netif_carrier_off(dev);
-	netif_stop_queue(dev);
 
 	port_start(mp);
 
 	set_rx_coal(mp, 0);
 	set_tx_coal(mp, 0);
 
-	wrl(mp, INT_MASK_EXT(mp->port_num),
-	    INT_EXT_LINK | INT_EXT_PHY | INT_EXT_TX);
-
+	wrl(mp, INT_MASK_EXT(mp->port_num), INT_EXT_LINK_PHY | INT_EXT_TX);
 	wrl(mp, INT_MASK(mp->port_num), INT_TX_END | INT_RX | INT_EXT);
 
 	return 0;
 
 
 out_free:
-	for (i = 0; i < 8; i++)
-		if (mp->rxq_mask & (1 << i))
-			rxq_deinit(mp->rxq + i);
+	for (i = 0; i < mp->rxq_count; i++)
+		rxq_deinit(mp->rxq + i);
 out:
 	free_irq(dev->irq, dev);
 
@@ -2076,12 +2115,10 @@ static void port_reset(struct mv643xx_eth_private *mp)
 	unsigned int data;
 	int i;
 
-	for (i = 0; i < 8; i++) {
-		if (mp->rxq_mask & (1 << i))
-			rxq_disable(mp->rxq + i);
-		if (mp->txq_mask & (1 << i))
-			txq_disable(mp->txq + i);
-	}
+	for (i = 0; i < mp->rxq_count; i++)
+		rxq_disable(mp->rxq + i);
+	for (i = 0; i < mp->txq_count; i++)
+		txq_disable(mp->txq + i);
 
 	while (1) {
 		u32 ps = rdl(mp, PORT_STATUS(mp->port_num));
@@ -2107,23 +2144,24 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	wrl(mp, INT_MASK(mp->port_num), 0x00000000);
 	rdl(mp, INT_MASK(mp->port_num));
 
-#ifdef MV643XX_ETH_NAPI
+	del_timer_sync(&mp->mib_counters_timer);
+
 	napi_disable(&mp->napi);
-#endif
+
+	del_timer_sync(&mp->rx_oom);
+
 	netif_carrier_off(dev);
-	netif_stop_queue(dev);
 
 	free_irq(dev->irq, dev);
 
 	port_reset(mp);
+	mv643xx_eth_get_stats(dev);
 	mib_counters_update(mp);
 
-	for (i = 0; i < 8; i++) {
-		if (mp->rxq_mask & (1 << i))
-			rxq_deinit(mp->rxq + i);
-		if (mp->txq_mask & (1 << i))
-			txq_deinit(mp->txq + i);
-	}
+	for (i = 0; i < mp->rxq_count; i++)
+		rxq_deinit(mp->rxq + i);
+	for (i = 0; i < mp->txq_count; i++)
+		txq_deinit(mp->txq + i);
 
 	return 0;
 }
@@ -2132,8 +2170,8 @@ static int mv643xx_eth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
-	if (mp->phy_addr != -1)
-		return generic_mii_ioctl(&mp->mii, if_mii(ifr), cmd, NULL);
+	if (mp->phy != NULL)
+		return phy_mii_ioctl(mp->phy, if_mii(ifr), cmd);
 
 	return -EOPNOTSUPP;
 }
@@ -2173,12 +2211,10 @@ static void tx_timeout_task(struct work_struct *ugly)
 
 	mp = container_of(ugly, struct mv643xx_eth_private, tx_timeout_task);
 	if (netif_running(mp->dev)) {
-		netif_stop_queue(mp->dev);
-
+		netif_tx_stop_all_queues(mp->dev);
 		port_reset(mp);
 		port_start(mp);
-
-		__txq_maybe_wake(mp->txq + mp->txq_primary);
+		netif_tx_wake_all_queues(mp->dev);
 	}
 }
 
@@ -2205,22 +2241,6 @@ static void mv643xx_eth_netpoll(struct net_device *dev)
 }
 #endif
 
-static int mv643xx_eth_mdio_read(struct net_device *dev, int addr, int reg)
-{
-	struct mv643xx_eth_private *mp = netdev_priv(dev);
-	int val;
-
-	smi_reg_read(mp, addr, reg, &val);
-
-	return val;
-}
-
-static void mv643xx_eth_mdio_write(struct net_device *dev, int addr, int reg, int val)
-{
-	struct mv643xx_eth_private *mp = netdev_priv(dev);
-	smi_reg_write(mp, addr, reg, val);
-}
-
 
 /* platform glue ************************************************************/
 static void
@@ -2272,14 +2292,20 @@ static void infer_hw_params(struct mv643xx_eth_shared_private *msp)
 		msp->extended_rx_coal_limit = 0;
 
 	/*
-	 * Check whether the TX rate control registers are in the
-	 * old or the new place.
+	 * Check whether the MAC supports TX rate control, and if
+	 * yes, whether its associated registers are in the old or
+	 * the new place.
 	 */
 	writel(1, msp->base + TX_BW_MTU_MOVED(0));
-	if (readl(msp->base + TX_BW_MTU_MOVED(0)) & 1)
-		msp->tx_bw_control_moved = 1;
-	else
-		msp->tx_bw_control_moved = 0;
+	if (readl(msp->base + TX_BW_MTU_MOVED(0)) & 1) {
+		msp->tx_bw_control = TX_BW_CONTROL_NEW_LAYOUT;
+	} else {
+		writel(7, msp->base + TX_BW_RATE(0));
+		if (readl(msp->base + TX_BW_RATE(0)) & 7)
+			msp->tx_bw_control = TX_BW_CONTROL_OLD_LAYOUT;
+		else
+			msp->tx_bw_control = TX_BW_CONTROL_ABSENT;
+	}
 }
 
 static int mv643xx_eth_shared_probe(struct platform_device *pdev)
@@ -2309,7 +2335,41 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	if (msp->base == NULL)
 		goto out_free;
 
-	spin_lock_init(&msp->phy_lock);
+	/*
+	 * Set up and register SMI bus.
+	 */
+	if (pd == NULL || pd->shared_smi == NULL) {
+		msp->smi_bus.priv = msp;
+		msp->smi_bus.name = "mv643xx_eth smi";
+		msp->smi_bus.read = smi_bus_read;
+		msp->smi_bus.write = smi_bus_write,
+		snprintf(msp->smi_bus.id, MII_BUS_ID_SIZE, "%d", pdev->id);
+		msp->smi_bus.dev = &pdev->dev;
+		msp->smi_bus.phy_mask = 0xffffffff;
+		if (mdiobus_register(&msp->smi_bus) < 0)
+			goto out_unmap;
+		msp->smi = msp;
+	} else {
+		msp->smi = platform_get_drvdata(pd->shared_smi);
+	}
+
+	msp->err_interrupt = NO_IRQ;
+	init_waitqueue_head(&msp->smi_busy_wait);
+
+	/*
+	 * Check whether the error interrupt is hooked up.
+	 */
+	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	if (res != NULL) {
+		int err;
+
+		err = request_irq(res->start, mv643xx_eth_err_irq,
+				  IRQF_SHARED, "mv643xx_eth", msp);
+		if (!err) {
+			writel(ERR_INT_SMI_DONE, msp->base + ERR_INT_MASK);
+			msp->err_interrupt = res->start;
+		}
+	}
 
 	/*
 	 * (Re-)program MBUS remapping windows if we are asked to.
@@ -2327,6 +2387,8 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 
 	return 0;
 
+out_unmap:
+	iounmap(msp->base);
 out_free:
 	kfree(msp);
 out:
@@ -2336,7 +2398,12 @@ out:
 static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 {
 	struct mv643xx_eth_shared_private *msp = platform_get_drvdata(pdev);
+	struct mv643xx_eth_shared_platform_data *pd = pdev->dev.platform_data;
 
+	if (pd == NULL || pd->shared_smi == NULL)
+		mdiobus_unregister(&msp->smi_bus);
+	if (msp->err_interrupt != NO_IRQ)
+		free_irq(msp->err_interrupt, msp);
 	iounmap(msp->base);
 	kfree(msp);
 
@@ -2382,33 +2449,13 @@ static void set_params(struct mv643xx_eth_private *mp,
 	else
 		uc_addr_get(mp, dev->dev_addr);
 
-	if (pd->phy_addr == -1) {
-		mp->shared_smi = NULL;
-		mp->phy_addr = -1;
-	} else {
-		mp->shared_smi = mp->shared;
-		if (pd->shared_smi != NULL)
-			mp->shared_smi = platform_get_drvdata(pd->shared_smi);
-
-		if (pd->force_phy_addr || pd->phy_addr) {
-			mp->phy_addr = pd->phy_addr & 0x3f;
-			phy_addr_set(mp, mp->phy_addr);
-		} else {
-			mp->phy_addr = phy_addr_get(mp);
-		}
-	}
-
 	mp->default_rx_ring_size = DEFAULT_RX_QUEUE_SIZE;
 	if (pd->rx_queue_size)
 		mp->default_rx_ring_size = pd->rx_queue_size;
 	mp->rx_desc_sram_addr = pd->rx_sram_addr;
 	mp->rx_desc_sram_size = pd->rx_sram_size;
 
-	if (pd->rx_queue_mask)
-		mp->rxq_mask = pd->rx_queue_mask;
-	else
-		mp->rxq_mask = 0x01;
-	mp->rxq_primary = fls(mp->rxq_mask) - 1;
+	mp->rxq_count = pd->rx_queue_count ? : 1;
 
 	mp->default_tx_ring_size = DEFAULT_TX_QUEUE_SIZE;
 	if (pd->tx_queue_size)
@@ -2416,76 +2463,63 @@ static void set_params(struct mv643xx_eth_private *mp,
 	mp->tx_desc_sram_addr = pd->tx_sram_addr;
 	mp->tx_desc_sram_size = pd->tx_sram_size;
 
-	if (pd->tx_queue_mask)
-		mp->txq_mask = pd->tx_queue_mask;
-	else
-		mp->txq_mask = 0x01;
-	mp->txq_primary = fls(mp->txq_mask) - 1;
+	mp->txq_count = pd->tx_queue_count ? : 1;
 }
 
-static int phy_detect(struct mv643xx_eth_private *mp)
+static struct phy_device *phy_scan(struct mv643xx_eth_private *mp,
+				   int phy_addr)
 {
-	unsigned int data;
-	unsigned int data2;
+	struct mii_bus *bus = &mp->shared->smi->smi_bus;
+	struct phy_device *phydev;
+	int start;
+	int num;
+	int i;
+
+	if (phy_addr == MV643XX_ETH_PHY_ADDR_DEFAULT) {
+		start = phy_addr_get(mp) & 0x1f;
+		num = 32;
+	} else {
+		start = phy_addr & 0x1f;
+		num = 1;
+	}
 
-	smi_reg_read(mp, mp->phy_addr, MII_BMCR, &data);
-	smi_reg_write(mp, mp->phy_addr, MII_BMCR, data ^ BMCR_ANENABLE);
+	phydev = NULL;
+	for (i = 0; i < num; i++) {
+		int addr = (start + i) & 0x1f;
 
-	smi_reg_read(mp, mp->phy_addr, MII_BMCR, &data2);
-	if (((data ^ data2) & BMCR_ANENABLE) == 0)
-		return -ENODEV;
+		if (bus->phy_map[addr] == NULL)
+			mdiobus_scan(bus, addr);
 
-	smi_reg_write(mp, mp->phy_addr, MII_BMCR, data);
+		if (phydev == NULL) {
+			phydev = bus->phy_map[addr];
+			if (phydev != NULL)
+				phy_addr_set(mp, addr);
+		}
+	}
 
-	return 0;
+	return phydev;
 }
 
-static int phy_init(struct mv643xx_eth_private *mp,
-		    struct mv643xx_eth_platform_data *pd)
+static void phy_init(struct mv643xx_eth_private *mp, int speed, int duplex)
 {
-	struct ethtool_cmd cmd;
-	int err;
+	struct phy_device *phy = mp->phy;
 
-	err = phy_detect(mp);
-	if (err) {
-		dev_printk(KERN_INFO, &mp->dev->dev,
-			   "no PHY detected at addr %d\n", mp->phy_addr);
-		return err;
-	}
 	phy_reset(mp);
 
-	mp->mii.phy_id = mp->phy_addr;
-	mp->mii.phy_id_mask = 0x3f;
-	mp->mii.reg_num_mask = 0x1f;
-	mp->mii.dev = mp->dev;
-	mp->mii.mdio_read = mv643xx_eth_mdio_read;
-	mp->mii.mdio_write = mv643xx_eth_mdio_write;
-
-	mp->mii.supports_gmii = mii_check_gmii_support(&mp->mii);
-
-	memset(&cmd, 0, sizeof(cmd));
-
-	cmd.port = PORT_MII;
-	cmd.transceiver = XCVR_INTERNAL;
-	cmd.phy_address = mp->phy_addr;
-	if (pd->speed == 0) {
-		cmd.autoneg = AUTONEG_ENABLE;
-		cmd.speed = SPEED_100;
-		cmd.advertising = ADVERTISED_10baseT_Half  |
-				  ADVERTISED_10baseT_Full  |
-				  ADVERTISED_100baseT_Half |
-				  ADVERTISED_100baseT_Full;
-		if (mp->mii.supports_gmii)
-			cmd.advertising |= ADVERTISED_1000baseT_Full;
+	phy_attach(mp->dev, phy->dev.bus_id, 0, PHY_INTERFACE_MODE_GMII);
+
+	if (speed == 0) {
+		phy->autoneg = AUTONEG_ENABLE;
+		phy->speed = 0;
+		phy->duplex = 0;
+		phy->advertising = phy->supported | ADVERTISED_Autoneg;
 	} else {
-		cmd.autoneg = AUTONEG_DISABLE;
-		cmd.speed = pd->speed;
-		cmd.duplex = pd->duplex;
+		phy->autoneg = AUTONEG_DISABLE;
+		phy->advertising = 0;
+		phy->speed = speed;
+		phy->duplex = duplex;
 	}
-
-	mv643xx_eth_set_settings(mp->dev, &cmd);
-
-	return 0;
+	phy_start_aneg(phy);
 }
 
 static void init_pscr(struct mv643xx_eth_private *mp, int speed, int duplex)
@@ -2499,7 +2533,7 @@ static void init_pscr(struct mv643xx_eth_private *mp, int speed, int duplex)
 	}
 
 	pscr = MAX_RX_PACKET_9700BYTE | SERIAL_PORT_CONTROL_RESERVED;
-	if (mp->phy_addr == -1) {
+	if (mp->phy == NULL) {
 		pscr |= DISABLE_AUTO_NEG_SPEED_GMII;
 		if (speed == SPEED_1000)
 			pscr |= SET_GMII_SPEED_TO_1000;
@@ -2538,7 +2572,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 		return -ENODEV;
 	}
 
-	dev = alloc_etherdev(sizeof(struct mv643xx_eth_private));
+	dev = alloc_etherdev_mq(sizeof(struct mv643xx_eth_private), 8);
 	if (!dev)
 		return -ENOMEM;
 
@@ -2549,33 +2583,47 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	mp->port_num = pd->port_number;
 
 	mp->dev = dev;
-#ifdef MV643XX_ETH_NAPI
-	netif_napi_add(dev, &mp->napi, mv643xx_eth_poll, 64);
-#endif
 
 	set_params(mp, pd);
+	dev->real_num_tx_queues = mp->txq_count;
 
-	spin_lock_init(&mp->lock);
-
-	mib_counters_clear(mp);
-	INIT_WORK(&mp->tx_timeout_task, tx_timeout_task);
-
-	if (mp->phy_addr != -1) {
-		err = phy_init(mp, pd);
-		if (err)
-			goto out;
+	if (pd->phy_addr != MV643XX_ETH_PHY_NONE)
+		mp->phy = phy_scan(mp, pd->phy_addr);
 
+	if (mp->phy != NULL) {
+		phy_init(mp, pd->speed, pd->duplex);
 		SET_ETHTOOL_OPS(dev, &mv643xx_eth_ethtool_ops);
 	} else {
 		SET_ETHTOOL_OPS(dev, &mv643xx_eth_ethtool_ops_phyless);
 	}
+
 	init_pscr(mp, pd->speed, pd->duplex);
 
 
+	mib_counters_clear(mp);
+
+	init_timer(&mp->mib_counters_timer);
+	mp->mib_counters_timer.data = (unsigned long)mp;
+	mp->mib_counters_timer.function = mib_counters_timer_wrapper;
+	mp->mib_counters_timer.expires = jiffies + 30 * HZ;
+	add_timer(&mp->mib_counters_timer);
+
+	spin_lock_init(&mp->mib_counters_lock);
+
+	INIT_WORK(&mp->tx_timeout_task, tx_timeout_task);
+
+	netif_napi_add(dev, &mp->napi, mv643xx_eth_poll, 128);
+
+	init_timer(&mp->rx_oom);
+	mp->rx_oom.data = (unsigned long)mp;
+	mp->rx_oom.function = oom_timer_wrapper;
+
+
 	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
 	BUG_ON(!res);
 	dev->irq = res->start;
 
+	dev->get_stats = mv643xx_eth_get_stats;
 	dev->hard_start_xmit = mv643xx_eth_xmit;
 	dev->open = mv643xx_eth_open;
 	dev->stop = mv643xx_eth_stop;
@@ -2590,14 +2638,8 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	dev->watchdog_timeo = 2 * HZ;
 	dev->base_addr = 0;
 
-#ifdef MV643XX_ETH_CHECKSUM_OFFLOAD_TX
-	/*
-	 * Zero copy can only work if we use Discovery II memory. Else, we will
-	 * have to map the buffers to ISA memory which is only 16 MB
-	 */
 	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM;
 	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM;
-#endif
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
@@ -2611,16 +2653,6 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	dev_printk(KERN_NOTICE, &dev->dev, "port %d with MAC address %s\n",
 		   mp->port_num, print_mac(mac, dev->dev_addr));
 
-	if (dev->features & NETIF_F_SG)
-		dev_printk(KERN_NOTICE, &dev->dev, "scatter/gather enabled\n");
-
-	if (dev->features & NETIF_F_IP_CSUM)
-		dev_printk(KERN_NOTICE, &dev->dev, "tx checksum offload\n");
-
-#ifdef MV643XX_ETH_NAPI
-	dev_printk(KERN_NOTICE, &dev->dev, "napi enabled\n");
-#endif
-
 	if (mp->tx_desc_sram_size > 0)
 		dev_printk(KERN_NOTICE, &dev->dev, "configured with sram\n");
 
@@ -2637,6 +2669,8 @@ static int mv643xx_eth_remove(struct platform_device *pdev)
 	struct mv643xx_eth_private *mp = platform_get_drvdata(pdev);
 
 	unregister_netdev(mp->dev);
+	if (mp->phy != NULL)
+		phy_detach(mp->phy);
 	flush_scheduled_work();
 	free_netdev(mp->dev);
 
diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index 7959990..eb681c0 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -64,6 +64,25 @@ static const char version2[] =
 
 /* Do we support clones that don't adhere to 14,15 of the SAprom ? */
 #define SUPPORT_NE_BAD_CLONES
+/* 0xbad = bad sig or no reset ack */
+#define BAD 0xbad
+
+#define MAX_NE_CARDS	4	/* Max number of NE cards per module */
+static struct platform_device *pdev_ne[MAX_NE_CARDS];
+static int io[MAX_NE_CARDS];
+static int irq[MAX_NE_CARDS];
+static int bad[MAX_NE_CARDS];
+
+#ifdef MODULE
+module_param_array(io, int, NULL, 0);
+module_param_array(irq, int, NULL, 0);
+module_param_array(bad, int, NULL, 0);
+MODULE_PARM_DESC(io, "I/O base address(es),required");
+MODULE_PARM_DESC(irq, "IRQ number(s)");
+MODULE_PARM_DESC(bad, "Accept card(s) with bad signatures");
+MODULE_DESCRIPTION("NE1000/NE2000 ISA/PnP Ethernet driver");
+MODULE_LICENSE("GPL");
+#endif /* MODULE */
 
 /* Do we perform extra sanity checks on stuff ? */
 /* #define NE_SANITY_CHECK */
@@ -74,6 +93,10 @@ static const char version2[] =
 /* Do we have a non std. amount of memory? (in units of 256 byte pages) */
 /* #define PACKETBUF_MEMSIZE	0x40 */
 
+/* This is set up so that no ISA autoprobe takes place. We can't guarantee
+that the ne2k probe is the last 8390 based probe to take place (as it
+is at boot) and so the probe will get confused by any other 8390 cards.
+ISA device autoprobes on a running machine are not recommended anyway. */
 #if !defined(MODULE) && (defined(CONFIG_ISA) || defined(CONFIG_M32R))
 /* Do we need a portlist for the ISA auto-probe ? */
 #define NEEDS_PORTLIST
@@ -192,8 +215,13 @@ static int __init do_ne_probe(struct net_device *dev)
 #endif
 
 	/* First check any supplied i/o locations. User knows best. <cough> */
-	if (base_addr > 0x1ff)	/* Check a single specified location. */
-		return ne_probe1(dev, base_addr);
+	if (base_addr > 0x1ff) {	/* Check a single specified location. */
+		int ret = ne_probe1(dev, base_addr);
+		if (ret)
+			printk(KERN_WARNING "ne.c: No NE*000 card found at "
+				"i/o = %#lx\n", base_addr);
+		return ret;
+	}
 	else if (base_addr != 0)	/* Don't probe at all. */
 		return -ENXIO;
 
@@ -214,28 +242,6 @@ static int __init do_ne_probe(struct net_device *dev)
 	return -ENODEV;
 }
 
-#ifndef MODULE
-struct net_device * __init ne_probe(int unit)
-{
-	struct net_device *dev = alloc_eip_netdev();
-	int err;
-
-	if (!dev)
-		return ERR_PTR(-ENOMEM);
-
-	sprintf(dev->name, "eth%d", unit);
-	netdev_boot_setup_check(dev);
-
-	err = do_ne_probe(dev);
-	if (err)
-		goto out;
-	return dev;
-out:
-	free_netdev(dev);
-	return ERR_PTR(err);
-}
-#endif
-
 static int __init ne_probe_isapnp(struct net_device *dev)
 {
 	int i;
@@ -329,7 +335,7 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 	   with an otherwise unused dev->mem_end value of "0xBAD" will
 	   cause the driver to skip these parts of the probe. */
 
-	bad_card = ((dev->base_addr != 0) && (dev->mem_end == 0xbad));
+	bad_card = ((dev->base_addr != 0) && (dev->mem_end == BAD));
 
 	/* Reset card. Who knows what dain-bramaged state it was left in. */
 
@@ -806,39 +812,84 @@ retry:
 static int __init ne_drv_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
+	int err, this_dev = pdev->id;
 	struct resource *res;
-	int err, irq;
-
-	res = platform_get_resource(pdev, IORESOURCE_IO, 0);
-	irq = platform_get_irq(pdev, 0);
-	if (!res || irq < 0)
-		return -ENODEV;
 
 	dev = alloc_eip_netdev();
 	if (!dev)
 		return -ENOMEM;
-	dev->irq = irq;
-	dev->base_addr = res->start;
+
+	/* ne.c doesn't populate resources in platform_device, but
+	 * rbtx4927_ne_init and rbtx4938_ne_init do register devices
+	 * with resources.
+	 */
+	res = platform_get_resource(pdev, IORESOURCE_IO, 0);
+	if (res) {
+		dev->base_addr = res->start;
+		dev->irq = platform_get_irq(pdev, 0);
+	} else {
+		if (this_dev < 0 || this_dev >= MAX_NE_CARDS)
+			return -EINVAL;
+		dev->base_addr = io[this_dev];
+		dev->irq = irq[this_dev];
+		dev->mem_end = bad[this_dev];
+	}
 	err = do_ne_probe(dev);
 	if (err) {
 		free_netdev(dev);
 		return err;
 	}
 	platform_set_drvdata(pdev, dev);
+
+	/* Update with any values found by probing, don't update if
+	 * resources were specified.
+	 */
+	if (!res) {
+		io[this_dev] = dev->base_addr;
+		irq[this_dev] = dev->irq;
+	}
 	return 0;
 }
 
-static int __exit ne_drv_remove(struct platform_device *pdev)
+static int ne_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 
-	unregister_netdev(dev);
-	free_irq(dev->irq, dev);
-	release_region(dev->base_addr, NE_IO_EXTENT);
-	free_netdev(dev);
+	if (dev) {
+		struct pnp_dev *idev = (struct pnp_dev *)ei_status.priv;
+		netif_device_detach(dev);
+		unregister_netdev(dev);
+		if (idev)
+			pnp_device_detach(idev);
+		/* Careful ne_drv_remove can be called twice, once from
+		 * the platform_driver.remove and again when the
+		 * platform_device is being removed.
+		 */
+		ei_status.priv = 0;
+		free_irq(dev->irq, dev);
+		release_region(dev->base_addr, NE_IO_EXTENT);
+		free_netdev(dev);
+		platform_set_drvdata(pdev, NULL);
+	}
 	return 0;
 }
 
+/* Remove unused devices or all if true. */
+static void ne_loop_rm_unreg(int all)
+{
+	int this_dev;
+	struct platform_device *pdev;
+	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
+		pdev = pdev_ne[this_dev];
+		/* No network device == unused */
+		if (pdev && (!platform_get_drvdata(pdev) || all)) {
+			ne_drv_remove(pdev);
+			platform_device_unregister(pdev);
+			pdev_ne[this_dev] = NULL;
+		}
+	}
+}
+
 #ifdef CONFIG_PM
 static int ne_drv_suspend(struct platform_device *pdev, pm_message_t state)
 {
@@ -873,7 +924,7 @@ static int ne_drv_resume(struct platform_device *pdev)
 #endif
 
 static struct platform_driver ne_driver = {
-	.remove		= __exit_p(ne_drv_remove),
+	.remove		= ne_drv_remove,
 	.suspend	= ne_drv_suspend,
 	.resume		= ne_drv_resume,
 	.driver		= {
@@ -882,91 +933,96 @@ static struct platform_driver ne_driver = {
 	},
 };
 
-static int __init ne_init(void)
+static void __init ne_add_devices(void)
 {
-	return platform_driver_probe(&ne_driver, ne_drv_probe);
-}
+	int this_dev;
+	struct platform_device *pdev;
 
-static void __exit ne_exit(void)
-{
-	platform_driver_unregister(&ne_driver);
+	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
+		if (pdev_ne[this_dev])
+			continue;
+		pdev = platform_device_register_simple(
+			DRV_NAME, this_dev, NULL, 0);
+		if (IS_ERR(pdev))
+			continue;
+		pdev_ne[this_dev] = pdev;
+	}
 }
 
 #ifdef MODULE
-#define MAX_NE_CARDS	4	/* Max number of NE cards per module */
-static struct net_device *dev_ne[MAX_NE_CARDS];
-static int io[MAX_NE_CARDS];
-static int irq[MAX_NE_CARDS];
-static int bad[MAX_NE_CARDS];	/* 0xbad = bad sig or no reset ack */
-
-module_param_array(io, int, NULL, 0);
-module_param_array(irq, int, NULL, 0);
-module_param_array(bad, int, NULL, 0);
-MODULE_PARM_DESC(io, "I/O base address(es),required");
-MODULE_PARM_DESC(irq, "IRQ number(s)");
-MODULE_PARM_DESC(bad, "Accept card(s) with bad signatures");
-MODULE_DESCRIPTION("NE1000/NE2000 ISA/PnP Ethernet driver");
-MODULE_LICENSE("GPL");
-
-/* This is set up so that no ISA autoprobe takes place. We can't guarantee
-that the ne2k probe is the last 8390 based probe to take place (as it
-is at boot) and so the probe will get confused by any other 8390 cards.
-ISA device autoprobes on a running machine are not recommended anyway. */
-
-int __init init_module(void)
+int __init init_module()
 {
-	int this_dev, found = 0;
-	int plat_found = !ne_init();
-
-	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
-		struct net_device *dev = alloc_eip_netdev();
-		if (!dev)
-			break;
-		dev->irq = irq[this_dev];
-		dev->mem_end = bad[this_dev];
-		dev->base_addr = io[this_dev];
-		if (do_ne_probe(dev) == 0) {
-			dev_ne[found++] = dev;
-			continue;
-		}
-		free_netdev(dev);
-		if (found || plat_found)
-			break;
-		if (io[this_dev] != 0)
-			printk(KERN_WARNING "ne.c: No NE*000 card found at i/o = %#x\n", io[this_dev]);
-		else
-			printk(KERN_NOTICE "ne.c: You must supply \"io=0xNNN\" value(s) for ISA cards.\n");
-		return -ENXIO;
+	int retval;
+	ne_add_devices();
+	retval = platform_driver_probe(&ne_driver, ne_drv_probe);
+	if (retval) {
+		if (io[0] == 0)
+			printk(KERN_NOTICE "ne.c: You must supply \"io=0xNNN\""
+				" value(s) for ISA cards.\n");
+		ne_loop_rm_unreg(1);
+		return retval;
 	}
-	if (found || plat_found)
-		return 0;
-	return -ENODEV;
-}
 
-static void cleanup_card(struct net_device *dev)
+	/* Unregister unused platform_devices. */
+	ne_loop_rm_unreg(0);
+	return retval;
+}
+#else /* MODULE */
+static int __init ne_init(void)
 {
-	struct pnp_dev *idev = (struct pnp_dev *)ei_status.priv;
-	if (idev)
-		pnp_device_detach(idev);
-	free_irq(dev->irq, dev);
-	release_region(dev->base_addr, NE_IO_EXTENT);
+	int retval = platform_driver_probe(&ne_driver, ne_drv_probe);
+
+	/* Unregister unused platform_devices. */
+	ne_loop_rm_unreg(0);
+	return retval;
 }
+module_init(ne_init);
 
-void __exit cleanup_module(void)
+struct net_device * __init ne_probe(int unit)
 {
 	int this_dev;
+	struct net_device *dev;
+
+	/* Find an empty slot, that is no net_device and zero io port. */
+	this_dev = 0;
+	while ((pdev_ne[this_dev] && platform_get_drvdata(pdev_ne[this_dev])) ||
+		io[this_dev]) {
+		if (++this_dev == MAX_NE_CARDS)
+			return ERR_PTR(-ENOMEM);
+	}
+
+	/* Get irq, io from kernel command line */
+	dev = alloc_eip_netdev();
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
 
-	ne_exit();
+	sprintf(dev->name, "eth%d", unit);
+	netdev_boot_setup_check(dev);
+
+	io[this_dev] = dev->base_addr;
+	irq[this_dev] = dev->irq;
+	bad[this_dev] = dev->mem_end;
+
+	free_netdev(dev);
+
+	ne_add_devices();
+
+	/* return the first device found */
 	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
-		struct net_device *dev = dev_ne[this_dev];
-		if (dev) {
-			unregister_netdev(dev);
-			cleanup_card(dev);
-			free_netdev(dev);
+		if (pdev_ne[this_dev]) {
+			dev = platform_get_drvdata(pdev_ne[this_dev]);
+			if (dev)
+				return dev;
 		}
 	}
+
+	return ERR_PTR(-ENODEV);
 }
-#else /* MODULE */
-module_init(ne_init);
-module_exit(ne_exit);
 #endif /* MODULE */
+
+static void __exit ne_exit(void)
+{
+	platform_driver_unregister(&ne_driver);
+	ne_loop_rm_unreg(1);
+}
+module_exit(ne_exit);
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 94e0b7e..e7508c1 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -60,49 +60,14 @@ int mdiobus_register(struct mii_bus *bus)
 		bus->reset(bus);
 
 	for (i = 0; i < PHY_MAX_ADDR; i++) {
-		struct phy_device *phydev;
+		bus->phy_map[i] = NULL;
+		if ((bus->phy_mask & (1 << i)) == 0) {
+			struct phy_device *phydev;
 
-		if (bus->phy_mask & (1 << i)) {
-			bus->phy_map[i] = NULL;
-			continue;
+			phydev = mdiobus_scan(bus, i);
+			if (IS_ERR(phydev))
+				err = PTR_ERR(phydev);
 		}
-
-		phydev = get_phy_device(bus, i);
-
-		if (IS_ERR(phydev))
-			return PTR_ERR(phydev);
-
-		/* There's a PHY at this address
-		 * We need to set:
-		 * 1) IRQ
-		 * 2) bus_id
-		 * 3) parent
-		 * 4) bus
-		 * 5) mii_bus
-		 * And, we need to register it */
-		if (phydev) {
-			phydev->irq = bus->irq[i];
-
-			phydev->dev.parent = bus->dev;
-			phydev->dev.bus = &mdio_bus_type;
-			snprintf(phydev->dev.bus_id, BUS_ID_SIZE, PHY_ID_FMT, bus->id, i);
-
-			phydev->bus = bus;
-
-			/* Run all of the fixups for this PHY */
-			phy_scan_fixups(phydev);
-
-			err = device_register(&phydev->dev);
-
-			if (err) {
-				printk(KERN_ERR "phy %d failed to register\n",
-						i);
-				phy_device_free(phydev);
-				phydev = NULL;
-			}
-		}
-
-		bus->phy_map[i] = phydev;
 	}
 
 	pr_info("%s: probed\n", bus->name);
@@ -122,6 +87,48 @@ void mdiobus_unregister(struct mii_bus *bus)
 }
 EXPORT_SYMBOL(mdiobus_unregister);
 
+struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr)
+{
+	struct phy_device *phydev;
+	int err;
+
+	phydev = get_phy_device(bus, addr);
+	if (IS_ERR(phydev) || phydev == NULL)
+		return phydev;
+
+	/* There's a PHY at this address
+	 * We need to set:
+	 * 1) IRQ
+	 * 2) bus_id
+	 * 3) parent
+	 * 4) bus
+	 * 5) mii_bus
+	 * And, we need to register it */
+
+	phydev->irq = bus->irq != NULL ? bus->irq[addr] : PHY_POLL;
+
+	phydev->dev.parent = bus->dev;
+	phydev->dev.bus = &mdio_bus_type;
+	snprintf(phydev->dev.bus_id, BUS_ID_SIZE, PHY_ID_FMT, bus->id, addr);
+
+	phydev->bus = bus;
+
+	/* Run all of the fixups for this PHY */
+	phy_scan_fixups(phydev);
+
+	err = device_register(&phydev->dev);
+	if (err) {
+		printk(KERN_ERR "phy %d failed to register\n", addr);
+		phy_device_free(phydev);
+		phydev = NULL;
+	}
+
+	bus->phy_map[addr] = phydev;
+
+	return phydev;
+}
+EXPORT_SYMBOL(mdiobus_scan);
+
 /**
  * mdio_bus_match - determine if given PHY driver supports the given PHY device
  * @dev: target PHY device
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 025f526..34fe7ef 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -265,7 +265,7 @@ static void r6040_free_txbufs(struct net_device *dev)
 				le32_to_cpu(lp->tx_insert_ptr->buf),
 				MAX_BUF_SIZE, PCI_DMA_TODEVICE);
 			dev_kfree_skb(lp->tx_insert_ptr->skb_ptr);
-			lp->rx_insert_ptr->skb_ptr = NULL;
+			lp->tx_insert_ptr->skb_ptr = NULL;
 		}
 		lp->tx_insert_ptr = lp->tx_insert_ptr->vndescp;
 	}
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index fe41e4e..ce10cfa 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2069,9 +2069,10 @@ static irqreturn_t sbmac_intr(int irq,void *dev_instance)
 static int sbmac_start_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct sbmac_softc *sc = netdev_priv(dev);
+	unsigned long flags;
 
 	/* lock eth irq */
-	spin_lock_irq (&sc->sbm_lock);
+	spin_lock_irqsave(&sc->sbm_lock, flags);
 
 	/*
 	 * Put the buffer on the transmit ring.  If we
@@ -2081,14 +2082,14 @@ static int sbmac_start_tx(struct sk_buff *skb, struct net_device *dev)
 	if (sbdma_add_txbuffer(&(sc->sbm_txdma),skb)) {
 		/* XXX save skb that we could not send */
 		netif_stop_queue(dev);
-		spin_unlock_irq(&sc->sbm_lock);
+		spin_unlock_irqrestore(&sc->sbm_lock, flags);
 
 		return 1;
 	}
 
 	dev->trans_start = jiffies;
 
-	spin_unlock_irq (&sc->sbm_lock);
+	spin_unlock_irqrestore(&sc->sbm_lock, flags);
 
 	return 0;
 }
@@ -2568,14 +2569,15 @@ static void sbmac_mii_poll(struct net_device *dev)
 static void sbmac_tx_timeout (struct net_device *dev)
 {
 	struct sbmac_softc *sc = netdev_priv(dev);
+	unsigned long flags;
 
-	spin_lock_irq (&sc->sbm_lock);
+	spin_lock_irqsave(&sc->sbm_lock, flags);
 
 
 	dev->trans_start = jiffies;
 	dev->stats.tx_errors++;
 
-	spin_unlock_irq (&sc->sbm_lock);
+	spin_unlock_irqrestore(&sc->sbm_lock, flags);
 
 	printk (KERN_WARNING "%s: Transmit timed out\n",dev->name);
 }
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index c7ab1b8..908f50b 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -760,7 +760,7 @@ static int qeth_get_problem(struct ccw_device *cdev, struct irb *irb)
 		if (sense[SENSE_COMMAND_REJECT_BYTE] &
 		    SENSE_COMMAND_REJECT_FLAG) {
 			QETH_DBF_TEXT(TRACE, 2, "CMDREJi");
-			return 0;
+			return 1;
 		}
 		if ((sense[2] == 0xaf) && (sense[3] == 0xfe)) {
 			QETH_DBF_TEXT(TRACE, 2, "AFFE");
@@ -884,6 +884,7 @@ static void qeth_irq(struct ccw_device *cdev, unsigned long intparm,
 		}
 		rc = qeth_get_problem(cdev, irb);
 		if (rc) {
+			qeth_clear_ipacmd_list(card);
 			qeth_schedule_recovery(card);
 			goto out;
 		}
@@ -4147,6 +4148,7 @@ static void qeth_core_remove_device(struct ccwgroup_device *gdev)
 	unsigned long flags;
 	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
 
+	QETH_DBF_TEXT(SETUP, 2, "removedv");
 	if (card->discipline.ccwgdriver) {
 		card->discipline.ccwgdriver->remove(gdev);
 		qeth_core_free_discipline(card);
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 3ac3cc1..955ba7a 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -395,7 +395,8 @@ static int qeth_l2_stop_card(struct qeth_card *card, int recovery_mode)
 	}
 	if (card->state == CARD_STATE_SOFTSETUP) {
 		qeth_l2_process_vlans(card, 1);
-		qeth_l2_del_all_mc(card);
+		if (!card->use_hard_stop)
+			qeth_l2_del_all_mc(card);
 		qeth_clear_ipacmd_list(card);
 		card->state = CARD_STATE_HARDSETUP;
 	}
@@ -559,7 +560,8 @@ static int qeth_l2_request_initial_mac(struct qeth_card *card)
 			"device %s: x%x\n", CARD_BUS_ID(card), rc);
 	}
 
-	if (card->info.guestlan) {
+	if ((card->info.type == QETH_CARD_TYPE_IQD) || 
+	    (card->info.guestlan)) {
 		rc = qeth_setadpparms_change_macaddr(card);
 		if (rc) {
 			QETH_DBF_MESSAGE(2, "couldn't get MAC address on "
@@ -825,7 +827,6 @@ static int qeth_l2_open(struct net_device *dev)
 	}
 	card->data.state = CH_STATE_UP;
 	card->state = CARD_STATE_UP;
-	card->dev->flags |= IFF_UP;
 	netif_start_queue(dev);
 
 	if (!card->lan_online && netif_carrier_ok(dev))
@@ -840,7 +841,6 @@ static int qeth_l2_stop(struct net_device *dev)
 
 	QETH_DBF_TEXT(TRACE, 4, "qethstop");
 	netif_tx_disable(dev);
-	card->dev->flags &= ~IFF_UP;
 	if (card->state == CARD_STATE_UP)
 		card->state = CARD_STATE_SOFTSETUP;
 	return 0;
@@ -1137,9 +1137,13 @@ static int qeth_l2_recover(void *ptr)
 	if (!rc)
 		PRINT_INFO("Device %s successfully recovered!\n",
 			   CARD_BUS_ID(card));
-	else
+	else {
+		rtnl_lock();
+		dev_close(card->dev);
+		rtnl_unlock();
 		PRINT_INFO("Device %s could not be recovered!\n",
 			   CARD_BUS_ID(card));
+	}
 	return 0;
 }
 
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index dd72c3c..99547de 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2795,7 +2795,6 @@ static int qeth_l3_open(struct net_device *dev)
 		return -ENODEV;
 	card->data.state = CH_STATE_UP;
 	card->state = CARD_STATE_UP;
-	card->dev->flags |= IFF_UP;
 	netif_start_queue(dev);
 
 	if (!card->lan_online && netif_carrier_ok(dev))
@@ -2809,7 +2808,6 @@ static int qeth_l3_stop(struct net_device *dev)
 
 	QETH_DBF_TEXT(TRACE, 4, "qethstop");
 	netif_tx_disable(dev);
-	card->dev->flags &= ~IFF_UP;
 	if (card->state == CARD_STATE_UP)
 		card->state = CARD_STATE_SOFTSETUP;
 	return 0;
@@ -3218,9 +3216,13 @@ static int qeth_l3_recover(void *ptr)
 	if (!rc)
 		PRINT_INFO("Device %s successfully recovered!\n",
 			   CARD_BUS_ID(card));
-	else
+	else {
+		rtnl_lock();
+		dev_close(card->dev);
+		rtnl_unlock();
 		PRINT_INFO("Device %s could not be recovered!\n",
 			   CARD_BUS_ID(card));
+	}
 	return 0;
 }
 
diff --git a/include/linux/mv643xx_eth.h b/include/linux/mv643xx_eth.h
index 1207857..cbbbe9b 100644
--- a/include/linux/mv643xx_eth.h
+++ b/include/linux/mv643xx_eth.h
@@ -17,9 +17,14 @@
 
 struct mv643xx_eth_shared_platform_data {
 	struct mbus_dram_target_info	*dram;
+	struct platform_device	*shared_smi;
 	unsigned int		t_clk;
 };
 
+#define MV643XX_ETH_PHY_ADDR_DEFAULT	0
+#define MV643XX_ETH_PHY_ADDR(x)		(0x80 | (x))
+#define MV643XX_ETH_PHY_NONE		0xff
+
 struct mv643xx_eth_platform_data {
 	/*
 	 * Pointer back to our parent instance, and our port number.
@@ -30,8 +35,6 @@ struct mv643xx_eth_platform_data {
 	/*
 	 * Whether a PHY is present, and if yes, at which address.
 	 */
-	struct platform_device	*shared_smi;
-	int			force_phy_addr;
 	int			phy_addr;
 
 	/*
@@ -49,10 +52,10 @@ struct mv643xx_eth_platform_data {
 	int			duplex;
 
 	/*
-	 * Which RX/TX queues to use.
+	 * How many RX/TX queues to use.
 	 */
-	int			rx_queue_mask;
-	int			tx_queue_mask;
+	int			rx_queue_count;
+	int			tx_queue_count;
 
 	/*
 	 * Override default RX/TX queue sizes if nonzero.
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 7224c40..5f170f5 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -410,6 +410,8 @@ int phy_start_aneg(struct phy_device *phydev);
 
 int mdiobus_register(struct mii_bus *bus);
 void mdiobus_unregister(struct mii_bus *bus);
+struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr);
+
 void phy_sanitize_settings(struct phy_device *phydev);
 int phy_stop_interrupts(struct phy_device *phydev);
 int phy_enable_interrupts(struct phy_device *phydev);
