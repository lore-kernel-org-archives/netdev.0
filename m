From: Tony Breeds <tony@bakeyournoodle.com>
Subject: Re: [PATCH] fix IBM EMAC driver after rename.
Date: Fri, 19 Aug 2011 11:25:58 +1000
Message-ID: <20110819012558.GF19739@ozlabs.org>
References: <20110818061354.GD19739@ozlabs.org>
 <20110817.234947.611559275017926008.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:58205 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753244Ab1HSB0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Aug 2011 21:26:00 -0400
Content-Disposition: inline
In-Reply-To: <20110817.234947.611559275017926008.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 17, 2011 at 11:49:47PM -0700, David Miller wrote:

> You also need to select the dependencies, such as "ETHERNET" for this
> to be correct.

These symbols are turned on in the appropriate defconfig.  It's ben done this
was so that you can (for example) build canyonlands with or without the EMAC
driver but if you de enable the EMAC driver we ensure (via the selects) that
you get all the components you need.

In version 2 of the patch I update the defconfigs to change the
CONFIG_NET_ETHERNET to CONFIG_ETHERNET, and add the CONFIG_NET_VENDOR_IBM
guard.

From: Tony Breeds <tony@bakeyournoodle.com>
Date: Fri, 19 Aug 2011 11:12:59 +1000
Subject: [PATCH v2] fix IBM EMAC driver after rename.

In commit 9aa3283595451ca093500ff0977b106e1f465586 (ehea/ibm*: Move the
IBM drivers) the IBM_NEW_EMAC* were renames to IBM_EMAC*

The conversion was incomplete so that even if the driver was added to
the .config it wasn't built, but there were no errors).  In this commit
we also update the various defconfigs that use EMAC to use the new
Kconfig symbol, and explicitly add the NET_VENDOR_IBM guard.

We do not explicitly select the Kconfig dependencies, as this would force
EMAC on.  Doing it in the defconfig allows more flexibility.

Tested on a canyondlands board.

Signed-off-by: Tony Breeds <tony@bakeyournoodle.com>
---
 arch/powerpc/configs/40x/acadia_defconfig      |   11 +++--
 arch/powerpc/configs/40x/ep405_defconfig       |    5 +-
 arch/powerpc/configs/40x/hcu4_defconfig        |    5 +-
 arch/powerpc/configs/40x/kilauea_defconfig     |    9 ++--
 arch/powerpc/configs/40x/makalu_defconfig      |    9 ++--
 arch/powerpc/configs/40x/walnut_defconfig      |    5 +-
 arch/powerpc/configs/44x/arches_defconfig      |    9 ++--
 arch/powerpc/configs/44x/bamboo_defconfig      |    5 +-
 arch/powerpc/configs/44x/bluestone_defconfig   |    9 ++--
 arch/powerpc/configs/44x/canyonlands_defconfig |    9 ++--
 arch/powerpc/configs/44x/ebony_defconfig       |    5 +-
 arch/powerpc/configs/44x/eiger_defconfig       |    9 ++--
 arch/powerpc/configs/44x/icon_defconfig        |    5 +-
 arch/powerpc/configs/44x/katmai_defconfig      |    5 +-
 arch/powerpc/configs/44x/redwood_defconfig     |   11 +++--
 arch/powerpc/configs/44x/sam440ep_defconfig    |    5 +-
 arch/powerpc/configs/44x/sequoia_defconfig     |    5 +-
 arch/powerpc/configs/44x/taishan_defconfig     |    5 +-
 arch/powerpc/configs/44x/warp_defconfig        |    5 +-
 arch/powerpc/configs/ppc40x_defconfig          |    5 +-
 arch/powerpc/configs/ppc44x_defconfig          |    5 +-
 arch/powerpc/platforms/40x/Kconfig             |   12 +++---
 arch/powerpc/platforms/44x/Kconfig             |   54 ++++++++++++------------
 arch/powerpc/platforms/cell/Kconfig            |    8 ++--
 drivers/net/ethernet/ibm/emac/Makefile         |   12 +++---
 drivers/net/ethernet/ibm/emac/core.c           |   12 +++---
 drivers/net/ethernet/ibm/emac/core.h           |   16 ++++----
 drivers/net/ethernet/ibm/emac/debug.h          |    2 +-
 drivers/net/ethernet/ibm/emac/mal.c            |    6 +-
 drivers/net/ethernet/ibm/emac/mal.h            |    4 +-
 drivers/net/ethernet/ibm/emac/rgmii.h          |    4 +-
 drivers/net/ethernet/ibm/emac/tah.h            |    4 +-
 drivers/net/ethernet/ibm/emac/zmii.h           |    4 +-
 33 files changed, 150 insertions(+), 129 deletions(-)

diff --git a/arch/powerpc/configs/40x/acadia_defconfig b/arch/powerpc/configs/40x/acadia_defconfig
index 4182c77..ed3bab7 100644
--- a/arch/powerpc/configs/40x/acadia_defconfig
+++ b/arch/powerpc/configs/40x/acadia_defconfig
@@ -44,12 +44,13 @@ CONFIG_BLK_DEV_RAM=y
 CONFIG_BLK_DEV_RAM_SIZE=35000
 # CONFIG_MISC_DEVICES is not set
 CONFIG_NETDEVICES=y
-CONFIG_NET_ETHERNET=y
+CONFIG_ETHERNET=y
+CONFIG_NET_VENDOR_IBM=y
 CONFIG_MII=y
-CONFIG_IBM_NEW_EMAC=y
-CONFIG_IBM_NEW_EMAC_RXB=256
-CONFIG_IBM_NEW_EMAC_TXB=256
-CONFIG_IBM_NEW_EMAC_DEBUG=y
+CONFIG_IBM_EMAC=y
+CONFIG_IBM_EMAC_RXB=256
+CONFIG_IBM_EMAC_TXB=256
+CONFIG_IBM_EMAC_DEBUG=y
 # CONFIG_NETDEV_1000 is not set
 # CONFIG_NETDEV_10000 is not set
 # CONFIG_INPUT is not set
diff --git a/arch/powerpc/configs/40x/ep405_defconfig b/arch/powerpc/configs/40x/ep405_defconfig
index 2dbb293..17582a3 100644
--- a/arch/powerpc/configs/40x/ep405_defconfig
+++ b/arch/powerpc/configs/40x/ep405_defconfig
@@ -42,8 +42,9 @@ CONFIG_PROC_DEVICETREE=y
 CONFIG_BLK_DEV_RAM=y
 CONFIG_BLK_DEV_RAM_SIZE=35000
 CONFIG_NETDEVICES=y
-CONFIG_NET_ETHERNET=y
-CONFIG_IBM_NEW_EMAC=y
+CONFIG_ETHERNET=y
+CONFIG_NET_VENDOR_IBM=y
+CONFIG_IBM_EMAC=y
 # CONFIG_INPUT is not set
 # CONFIG_SERIO is not set
 # CONFIG_VT is not set
diff --git a/arch/powerpc/configs/40x/hcu4_defconfig b/arch/powerpc/configs/40x/hcu4_defconfig
index ebeb4ac..dba263c 100644
--- a/arch/powerpc/configs/40x/hcu4_defconfig
+++ b/arch/powerpc/configs/40x/hcu4_defconfig
@@ -43,8 +43,9 @@ CONFIG_PROC_DEVICETREE=y
 CONFIG_BLK_DEV_RAM=y
 CONFIG_BLK_DEV_RAM_SIZE=35000
 CONFIG_NETDEVICES=y
-CONFIG_NET_ETHERNET=y
-CONFIG_IBM_NEW_EMAC=y
+CONFIG_ETHERNET=y
+CONFIG_NET_VENDOR_IBM=y
+CONFIG_IBM_EMAC=y
 # CONFIG_INPUT is not set
 # CONFIG_SERIO is not set
 # CONFIG_VT is not set
diff --git a/arch/powerpc/configs/40x/kilauea_defconfig b/arch/powerpc/configs/40x/kilauea_defconfig
index 532ea9d..f2d4be9 100644
--- a/arch/powerpc/configs/40x/kilauea_defconfig
+++ b/arch/powerpc/configs/40x/kilauea_defconfig
@@ -51,10 +51,11 @@ CONFIG_BLK_DEV_RAM=y
 CONFIG_BLK_DEV_RAM_SIZE=35000
 # CONFIG_MISC_DEVICES is not set
 CONFIG_NETDEVICES=y
-CONFIG_NET_ETHERNET=y
-CONFIG_IBM_NEW_EMAC=y
-CONFIG_IBM_NEW_EMAC_RXB=256
-CONFIG_IBM_NEW_EMAC_TXB=256
+CONFIG_ETHERNET=y
+CONFIG_NET_VENDOR_IBM=y
+CONFIG_IBM_EMAC=y
+CONFIG_IBM_EMAC_RXB=256
+CONFIG_IBM_EMAC_TXB=256
 # CONFIG_NETDEV_1000 is not set
 # CONFIG_NETDEV_10000 is not set
 # CONFIG_INPUT is not set
diff --git a/arch/powerpc/configs/40x/makalu_defconfig b/arch/powerpc/configs/40x/makalu_defconfig
index 3c142ac..42b9793 100644
--- a/arch/powerpc/configs/40x/makalu_defconfig
+++ b/arch/powerpc/configs/40x/makalu_defconfig
@@ -43,10 +43,11 @@ CONFIG_BLK_DEV_RAM=y
 CONFIG_BLK_DEV_RAM_SIZE=35000
 # CONFIG_MISC_DEVICES is not set
 CONFIG_NETDEVICES=y
-CONFIG_NET_ETHERNET=y
-CONFIG_IBM_NEW_EMAC=y
-CONFIG_IBM_NEW_EMAC_RXB=256
-CONFIG_IBM_NEW_EMAC_TXB=256
+CONFIG_ETHERNET=y
+CONFIG_NET_VENDOR_IBM=y
+CONFIG_IBM_EMAC=y
+CONFIG_IBM_EMAC_RXB=256
+CONFIG_IBM_EMAC_TXB=256
 # CONFIG_NETDEV_1000 is not set
 # CONFIG_NETDEV_10000 is not set
 # CONFIG_INPUT is not set
diff --git a/arch/powerpc/configs/40x/walnut_defconfig b/arch/powerpc/configs/40x/walnut_defconfig
index ff57d48..aa1a4ca 100644
--- a/arch/powerpc/configs/40x/walnut_defconfig
+++ b/arch/powerpc/configs/40x/walnut_defconfig
@@ -40,8 +40,9 @@ CONFIG_PROC_DEVICETREE=y
 CONFIG_BLK_DEV_RAM=y
 CONFIG_BLK_DEV_RAM_SIZE=35000
 CONFIG_NETDEVICES=y
-CONFIG_NET_ETHERNET=y
-CONFIG_IBM_NEW_EMAC=y
+CONFIG_ETHERNET=y
+CONFIG_NET_VENDOR_IBM=y
+CONFIG_IBM_EMAC=y
 # CONFIG_INPUT is not set
 # CONFIG_SERIO is not set
 # CONFIG_VT is not set
diff --git a/arch/powerpc/configs/44x/arches_defconfig b/arch/powerpc/configs/44x/arches_defconfig
index 3ed16d5..329f9a3 100644
--- a/arch/powerpc/configs/44x/arches_defconfig
+++ b/arch/powerpc/configs/44x/arches_defconfig
@@ -44,10 +44,11 @@ CONFIG_BLK_DEV_RAM=y
 CONFIG_BLK_DEV_RAM_SIZE=35000
 # CONFIG_MISC_DEVICES is not set
 CONFIG_NETDEVICES=y
-CONFIG_NET_ETHERNET=y
-CONFIG_IBM_NEW_EMAC=y
-CONFIG_IBM_NEW_EMAC_RXB=256
-CONFIG_IBM_NEW_EMAC_TXB=256
+CONFIG_ETHERNET=y
+CONFIG_NET_VENDOR_IBM=y
+CONFIG_IBM_EMAC=y
+CONFIG_IBM_EMAC_RXB=256
+CONFIG_IBM_EMAC_TXB=256
 # CONFIG_NETDEV_1000 is not set
 # CONFIG_NETDEV_10000 is not set
 # CONFIG_INPUT is not set
diff --git a/arch/powerpc/configs/44x/bamboo_defconfig b/arch/powerpc/configs/44x/bamboo_defconfig
index b1b7d2c..cef7d62 100644
--- a/arch/powerpc/configs/44x/bamboo_defconfig
+++ b/arch/powerpc/configs/44x/bamboo_defconfig
@@ -32,8 +32,9 @@ CONFIG_PROC_DEVICETREE=y
 CONFIG_BLK_DEV_RAM=y
 CONFIG_BLK_DEV_RAM_SIZE=35000
 CONFIG_NETDEVICES=y
-CONFIG_NET_ETHERNET=y
-CONFIG_IBM_NEW_EMAC=y
+CONFIG_ETHERNET=y
+CONFIG_NET_VENDOR_IBM=y
+CONFIG_IBM_EMAC=y
 # CONFIG_INPUT is not set
 # CONFIG_SERIO is not set
 # CONFIG_VT is not set
diff --git a/arch/powerpc/configs/44x/bluestone_defconfig b/arch/powerpc/configs/44x/bluestone_defconfig
index 30a0a8e..20c8d26 100644
--- a/arch/powerpc/configs/44x/bluestone_defconfig
+++ b/arch/powerpc/configs/44x/bluestone_defconfig
@@ -38,10 +38,11 @@ CONFIG_PROC_DEVICETREE=y
 CONFIG_BLK_DEV_RAM=y
 CONFIG_BLK_DEV_RAM_SIZE=35000
 CONFIG_NETDEVICES=y
-CONFIG_NET_ETHERNET=y
-CONFIG_IBM_NEW_EMAC=y
-CONFIG_IBM_NEW_EMAC_RXB=256
-CONFIG_IBM_NEW_EMAC_TXB=256
+CONFIG_ETHERNET=y
+CONFIG_NET_VENDOR_IBM=y
+CONFIG_IBM_EMAC=y
+CONFIG_IBM_EMAC_RXB=256
+CONFIG_IBM_EMAC_TXB=256
 CONFIG_SERIAL_8250=y
 CONFIG_SERIAL_8250_CONSOLE=y
 CONFIG_SERIAL_8250_NR_UARTS=2
diff --git a/arch/powerpc/configs/44x/canyonlands_defconfig b/arch/powerpc/configs/44x/canyonlands_defconfig
index a46942a..d5be93e 100644
--- a/arch/powerpc/configs/44x/canyonlands_defconfig
+++ b/arch/powerpc/configs/44x/canyonlands_defconfig
@@ -49,10 +49,11 @@ CONFIG_BLK_DEV_RAM=y
 CONFIG_BLK_DEV_RAM_SIZE=35000
 # CONFIG_MISC_DEVICES is not set
 CONFIG_NETDEVICES=y
-CONFIG_NET_ETHERNET=y
-CONFIG_IBM_NEW_EMAC=y
-CONFIG_IBM_NEW_EMAC_RXB=256
-CONFIG_IBM_NEW_EMAC_TXB=256
+CONFIG_ETHERNET=y
+CONFIG_NET_VENDOR_IBM=y
+CONFIG_IBM_EMAC=y
+CONFIG_IBM_EMAC_RXB=256
+CONFIG_IBM_EMAC_TXB=256
 # CONFIG_NETDEV_1000 is not set
 # CONFIG_NETDEV_10000 is not set
 # CONFIG_INPUT is not set
diff --git a/arch/powerpc/configs/44x/ebony_defconfig b/arch/powerpc/configs/44x/ebony_defconfig
index 07d77e5..f9269fc 100644
--- a/arch/powerpc/configs/44x/ebony_defconfig
+++ b/arch/powerpc/configs/44x/ebony_defconfig
@@ -40,8 +40,9 @@ CONFIG_PROC_DEVICETREE=y
 CONFIG_BLK_DEV_RAM=y
 CONFIG_BLK_DEV_RAM_SIZE=35000
 CONFIG_NETDEVICES=y
-CONFIG_NET_ETHERNET=y
-CONFIG_IBM_NEW_EMAC=y
+CONFIG_ETHERNET=y
+CONFIG_NET_VENDOR_IBM=y
+CONFIG_IBM_EMAC=y
 # CONFIG_INPUT is not set
 # CONFIG_SERIO is not set
 # CONFIG_VT is not set
diff --git a/arch/powerpc/configs/44x/eiger_defconfig b/arch/powerpc/configs/44x/eiger_defconfig
index 2ce7e9a..9be0890 100644
--- a/arch/powerpc/configs/44x/eiger_defconfig
+++ b/arch/powerpc/configs/44x/eiger_defconfig
@@ -55,10 +55,11 @@ CONFIG_FUSION=y
 CONFIG_FUSION_SAS=y
 CONFIG_I2O=y
 CONFIG_NETDEVICES=y
-CONFIG_NET_ETHERNET=y
-CONFIG_IBM_NEW_EMAC=y
-CONFIG_IBM_NEW_EMAC_RXB=256
-CONFIG_IBM_NEW_EMAC_TXB=256
+CONFIG_ETHERNET=y
+CONFIG_NET_VENDOR_IBM=y
+CONFIG_IBM_EMAC=y
+CONFIG_IBM_EMAC_RXB=256
+CONFIG_IBM_EMAC_TXB=256
 CONFIG_E1000E=y
 # CONFIG_NETDEV_10000 is not set
 # CONFIG_INPUT is not set
diff --git a/arch/powerpc/configs/44x/icon_defconfig b/arch/powerpc/configs/44x/icon_defconfig
index 18730ff..82f7303 100644
--- a/arch/powerpc/configs/44x/icon_defconfig
+++ b/arch/powerpc/configs/44x/icon_defconfig
@@ -56,8 +56,9 @@ CONFIG_FUSION_SAS=y
 CONFIG_FUSION_CTL=y
 CONFIG_FUSION_LOGGING=y
 CONFIG_NETDEVICES=y
-CONFIG_NET_ETHERNET=y
-CONFIG_IBM_NEW_EMAC=y
+CONFIG_ETHERNET=y
+CONFIG_NET_VENDOR_IBM=y
+CONFIG_IBM_EMAC=y
 # CONFIG_NETDEV_1000 is not set
 # CONFIG_NETDEV_10000 is not set
 # CONFIG_WLAN is not set
diff --git a/arch/powerpc/configs/44x/katmai_defconfig b/arch/powerpc/configs/44x/katmai_defconfig
index 34c0914..109562c 100644
--- a/arch/powerpc/configs/44x/katmai_defconfig
+++ b/arch/powerpc/configs/44x/katmai_defconfig
@@ -42,8 +42,9 @@ CONFIG_BLK_DEV_RAM=y
 CONFIG_BLK_DEV_RAM_SIZE=35000
 CONFIG_MACINTOSH_DRIVERS=y
 CONFIG_NETDEVICES=y
-CONFIG_NET_ETHERNET=y
-CONFIG_IBM_NEW_EMAC=y
+CONFIG_ETHERNET=y
+CONFIG_NET_VENDOR_IBM=y
+CONFIG_IBM_EMAC=y
 # CONFIG_INPUT is not set
 # CONFIG_SERIO is not set
 # CONFIG_VT is not set
diff --git a/arch/powerpc/configs/44x/redwood_defconfig b/arch/powerpc/configs/44x/redwood_defconfig
index 01cc2b1..4880281 100644
--- a/arch/powerpc/configs/44x/redwood_defconfig
+++ b/arch/powerpc/configs/44x/redwood_defconfig
@@ -53,11 +53,12 @@ CONFIG_FUSION=y
 CONFIG_FUSION_SAS=y
 CONFIG_I2O=y
 CONFIG_NETDEVICES=y
-CONFIG_NET_ETHERNET=y
-CONFIG_IBM_NEW_EMAC=y
-CONFIG_IBM_NEW_EMAC_RXB=256
-CONFIG_IBM_NEW_EMAC_TXB=256
-CONFIG_IBM_NEW_EMAC_DEBUG=y
+CONFIG_ETHERNET=y
+CONFIG_NET_VENDOR_IBM=y
+CONFIG_IBM_EMAC=y
+CONFIG_IBM_EMAC_RXB=256
+CONFIG_IBM_EMAC_TXB=256
+CONFIG_IBM_EMAC_DEBUG=y
 CONFIG_E1000E=y
 # CONFIG_NETDEV_10000 is not set
 # CONFIG_INPUT is not set
diff --git a/arch/powerpc/configs/44x/sam440ep_defconfig b/arch/powerpc/configs/44x/sam440ep_defconfig
index dfcffed..ca088cd 100644
--- a/arch/powerpc/configs/44x/sam440ep_defconfig
+++ b/arch/powerpc/configs/44x/sam440ep_defconfig
@@ -44,8 +44,9 @@ CONFIG_ATA=y
 # CONFIG_SATA_PMP is not set
 CONFIG_SATA_SIL=y
 CONFIG_NETDEVICES=y
-CONFIG_NET_ETHERNET=y
-CONFIG_IBM_NEW_EMAC=y
+CONFIG_ETHERNET=y
+CONFIG_NET_VENDOR_IBM=y
+CONFIG_IBM_EMAC=y
 # CONFIG_NETDEV_1000 is not set
 # CONFIG_NETDEV_10000 is not set
 CONFIG_INPUT_FF_MEMLESS=m
diff --git a/arch/powerpc/configs/44x/sequoia_defconfig b/arch/powerpc/configs/44x/sequoia_defconfig
index 47e399f..b7a653b 100644
--- a/arch/powerpc/configs/44x/sequoia_defconfig
+++ b/arch/powerpc/configs/44x/sequoia_defconfig
@@ -46,8 +46,9 @@ CONFIG_PROC_DEVICETREE=y
 CONFIG_BLK_DEV_RAM=y
 CONFIG_BLK_DEV_RAM_SIZE=35000
 CONFIG_NETDEVICES=y
-CONFIG_NET_ETHERNET=y
-CONFIG_IBM_NEW_EMAC=y
+CONFIG_ETHERNET=y
+CONFIG_NET_VENDOR_IBM=y
+CONFIG_IBM_EMAC=y
 # CONFIG_INPUT is not set
 # CONFIG_SERIO is not set
 # CONFIG_VT is not set
diff --git a/arch/powerpc/configs/44x/taishan_defconfig b/arch/powerpc/configs/44x/taishan_defconfig
index a6a002e..30de97f 100644
--- a/arch/powerpc/configs/44x/taishan_defconfig
+++ b/arch/powerpc/configs/44x/taishan_defconfig
@@ -40,8 +40,9 @@ CONFIG_BLK_DEV_RAM=y
 CONFIG_BLK_DEV_RAM_SIZE=35000
 CONFIG_MACINTOSH_DRIVERS=y
 CONFIG_NETDEVICES=y
-CONFIG_NET_ETHERNET=y
-CONFIG_IBM_NEW_EMAC=y
+CONFIG_ETHERNET=y
+CONFIG_NET_VENDOR_IBM=y
+CONFIG_IBM_EMAC=y
 # CONFIG_INPUT is not set
 # CONFIG_SERIO is not set
 # CONFIG_VT is not set
diff --git a/arch/powerpc/configs/44x/warp_defconfig b/arch/powerpc/configs/44x/warp_defconfig
index abf74dc..105bc56 100644
--- a/arch/powerpc/configs/44x/warp_defconfig
+++ b/arch/powerpc/configs/44x/warp_defconfig
@@ -54,9 +54,10 @@ CONFIG_BLK_DEV_SD=y
 CONFIG_SCSI_SPI_ATTRS=y
 # CONFIG_SCSI_LOWLEVEL is not set
 CONFIG_NETDEVICES=y
-CONFIG_NET_ETHERNET=y
+CONFIG_ETHERNET=y
+CONFIG_NET_VENDOR_IBM=y
 CONFIG_MII=y
-CONFIG_IBM_NEW_EMAC=y
+CONFIG_IBM_EMAC=y
 # CONFIG_NETDEV_1000 is not set
 # CONFIG_NETDEV_10000 is not set
 # CONFIG_INPUT is not set
diff --git a/arch/powerpc/configs/ppc40x_defconfig b/arch/powerpc/configs/ppc40x_defconfig
index bfd634b..7cb703b 100644
--- a/arch/powerpc/configs/ppc40x_defconfig
+++ b/arch/powerpc/configs/ppc40x_defconfig
@@ -50,8 +50,9 @@ CONFIG_BLK_DEV_RAM=y
 CONFIG_BLK_DEV_RAM_SIZE=35000
 CONFIG_XILINX_SYSACE=m
 CONFIG_NETDEVICES=y
-CONFIG_NET_ETHERNET=y
-CONFIG_IBM_NEW_EMAC=y
+CONFIG_ETHERNET=y
+CONFIG_NET_VENDOR_IBM=y
+CONFIG_IBM_EMAC=y
 # CONFIG_INPUT is not set
 CONFIG_SERIO=m
 # CONFIG_SERIO_I8042 is not set
diff --git a/arch/powerpc/configs/ppc44x_defconfig b/arch/powerpc/configs/ppc44x_defconfig
index 4713320..6cdf1c0 100644
--- a/arch/powerpc/configs/ppc44x_defconfig
+++ b/arch/powerpc/configs/ppc44x_defconfig
@@ -63,8 +63,9 @@ CONFIG_BLK_DEV_SD=m
 # CONFIG_SCSI_LOWLEVEL is not set
 CONFIG_NETDEVICES=y
 CONFIG_TUN=m
-CONFIG_NET_ETHERNET=y
-CONFIG_IBM_NEW_EMAC=y
+CONFIG_ETHERNET=y
+CONFIG_NET_VENDOR_IBM=y
+CONFIG_IBM_EMAC=y
 # CONFIG_INPUT is not set
 CONFIG_SERIO=m
 # CONFIG_SERIO_I8042 is not set
diff --git a/arch/powerpc/platforms/40x/Kconfig b/arch/powerpc/platforms/40x/Kconfig
index d733d7c..b5d8706 100644
--- a/arch/powerpc/platforms/40x/Kconfig
+++ b/arch/powerpc/platforms/40x/Kconfig
@@ -130,21 +130,21 @@ config 405GP
 	bool
 	select IBM405_ERR77
 	select IBM405_ERR51
-	select IBM_NEW_EMAC_ZMII
+	select IBM_EMAC_ZMII
 
 config 405EP
 	bool
 
 config 405EX
 	bool
-	select IBM_NEW_EMAC_EMAC4
-	select IBM_NEW_EMAC_RGMII
+	select IBM_EMAC_EMAC4
+	select IBM_EMAC_RGMII
 
 config 405EZ
 	bool
-	select IBM_NEW_EMAC_NO_FLOW_CTRL
-	select IBM_NEW_EMAC_MAL_CLR_ICINTSTAT
-	select IBM_NEW_EMAC_MAL_COMMON_ERR
+	select IBM_EMAC_NO_FLOW_CTRL
+	select IBM_EMAC_MAL_CLR_ICINTSTAT
+	select IBM_EMAC_MAL_COMMON_ERR
 
 config 405GPR
 	bool
diff --git a/arch/powerpc/platforms/44x/Kconfig b/arch/powerpc/platforms/44x/Kconfig
index e958b6f..762322c 100644
--- a/arch/powerpc/platforms/44x/Kconfig
+++ b/arch/powerpc/platforms/44x/Kconfig
@@ -23,7 +23,7 @@ config BLUESTONE
 	default n
 	select PPC44x_SIMPLE
 	select APM821xx
-	select IBM_NEW_EMAC_RGMII
+	select IBM_EMAC_RGMII
 	help
 	  This option enables support for the APM APM821xx Evaluation board.
 
@@ -122,8 +122,8 @@ config CANYONLANDS
 	select PPC4xx_PCI_EXPRESS
 	select PCI_MSI
 	select PPC4xx_MSI
-	select IBM_NEW_EMAC_RGMII
-	select IBM_NEW_EMAC_ZMII
+	select IBM_EMAC_RGMII
+	select IBM_EMAC_ZMII
 	help
 	  This option enables support for the AMCC PPC460EX evaluation board.
 
@@ -135,8 +135,8 @@ config GLACIER
 	select 460EX # Odd since it uses 460GT but the effects are the same
 	select PCI
 	select PPC4xx_PCI_EXPRESS
-	select IBM_NEW_EMAC_RGMII
-	select IBM_NEW_EMAC_ZMII
+	select IBM_EMAC_RGMII
+	select IBM_EMAC_ZMII
 	help
 	  This option enables support for the AMCC PPC460GT evaluation board.
 
@@ -161,7 +161,7 @@ config EIGER
 	select 460SX
 	select PCI
 	select PPC4xx_PCI_EXPRESS
-	select IBM_NEW_EMAC_RGMII
+	select IBM_EMAC_RGMII
 	help
 	  This option enables support for the AMCC PPC460SX evaluation board.
 
@@ -260,59 +260,59 @@ config 440EP
 	bool
 	select PPC_FPU
 	select IBM440EP_ERR42
-	select IBM_NEW_EMAC_ZMII
+	select IBM_EMAC_ZMII
 	select USB_ARCH_HAS_OHCI
 
 config 440EPX
 	bool
 	select PPC_FPU
-	select IBM_NEW_EMAC_EMAC4
-	select IBM_NEW_EMAC_RGMII
-	select IBM_NEW_EMAC_ZMII
+	select IBM_EMAC_EMAC4
+	select IBM_EMAC_RGMII
+	select IBM_EMAC_ZMII
 
 config 440GRX
 	bool
-	select IBM_NEW_EMAC_EMAC4
-	select IBM_NEW_EMAC_RGMII
-	select IBM_NEW_EMAC_ZMII
+	select IBM_EMAC_EMAC4
+	select IBM_EMAC_RGMII
+	select IBM_EMAC_ZMII
 
 config 440GP
 	bool
-	select IBM_NEW_EMAC_ZMII
+	select IBM_EMAC_ZMII
 
 config 440GX
 	bool
-	select IBM_NEW_EMAC_EMAC4
-	select IBM_NEW_EMAC_RGMII
-	select IBM_NEW_EMAC_ZMII #test only
-	select IBM_NEW_EMAC_TAH  #test only
+	select IBM_EMAC_EMAC4
+	select IBM_EMAC_RGMII
+	select IBM_EMAC_ZMII #test only
+	select IBM_EMAC_TAH  #test only
 
 config 440SP
 	bool
 
 config 440SPe
 	bool
-	select IBM_NEW_EMAC_EMAC4
+	select IBM_EMAC_EMAC4
 
 config 460EX
 	bool
 	select PPC_FPU
-	select IBM_NEW_EMAC_EMAC4
-	select IBM_NEW_EMAC_TAH
+	select IBM_EMAC_EMAC4
+	select IBM_EMAC_TAH
 
 config 460SX
 	bool
 	select PPC_FPU
-	select IBM_NEW_EMAC_EMAC4
-	select IBM_NEW_EMAC_RGMII
-	select IBM_NEW_EMAC_ZMII
-	select IBM_NEW_EMAC_TAH
+	select IBM_EMAC_EMAC4
+	select IBM_EMAC_RGMII
+	select IBM_EMAC_ZMII
+	select IBM_EMAC_TAH
 
 config APM821xx
 	bool
 	select PPC_FPU
-	select IBM_NEW_EMAC_EMAC4
-	select IBM_NEW_EMAC_TAH
+	select IBM_EMAC_EMAC4
+	select IBM_EMAC_TAH
 
 # 44x errata/workaround config symbols, selected by the CPU models above
 config IBM440EP_ERR42
diff --git a/arch/powerpc/platforms/cell/Kconfig b/arch/powerpc/platforms/cell/Kconfig
index 67d5009..2e7ff0c 100644
--- a/arch/powerpc/platforms/cell/Kconfig
+++ b/arch/powerpc/platforms/cell/Kconfig
@@ -17,10 +17,10 @@ config PPC_CELL_NATIVE
 	select PPC_CELL_COMMON
 	select MPIC
 	select PPC_IO_WORKAROUNDS
-	select IBM_NEW_EMAC_EMAC4
-	select IBM_NEW_EMAC_RGMII
-	select IBM_NEW_EMAC_ZMII #test only
-	select IBM_NEW_EMAC_TAH  #test only
+	select IBM_EMAC_EMAC4
+	select IBM_EMAC_RGMII
+	select IBM_EMAC_ZMII #test only
+	select IBM_EMAC_TAH  #test only
 	default n
 
 config PPC_IBM_CELL_BLADE
diff --git a/drivers/net/ethernet/ibm/emac/Makefile b/drivers/net/ethernet/ibm/emac/Makefile
index 0b5c995..eba2183 100644
--- a/drivers/net/ethernet/ibm/emac/Makefile
+++ b/drivers/net/ethernet/ibm/emac/Makefile
@@ -2,10 +2,10 @@
 # Makefile for the PowerPC 4xx on-chip ethernet driver
 #
 
-obj-$(CONFIG_IBM_NEW_EMAC) += ibm_newemac.o
+obj-$(CONFIG_IBM_EMAC) += ibm_emac.o
 
-ibm_newemac-y := mal.o core.o phy.o
-ibm_newemac-$(CONFIG_IBM_NEW_EMAC_ZMII) += zmii.o
-ibm_newemac-$(CONFIG_IBM_NEW_EMAC_RGMII) += rgmii.o
-ibm_newemac-$(CONFIG_IBM_NEW_EMAC_TAH) += tah.o
-ibm_newemac-$(CONFIG_IBM_NEW_EMAC_DEBUG) += debug.o
+ibm_emac-y := mal.o core.o phy.o
+ibm_emac-$(CONFIG_IBM_EMAC_ZMII) += zmii.o
+ibm_emac-$(CONFIG_IBM_EMAC_RGMII) += rgmii.o
+ibm_emac-$(CONFIG_IBM_EMAC_TAH) += tah.o
+ibm_emac-$(CONFIG_IBM_EMAC_DEBUG) += debug.o
diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 70cb7d8..6e014ae 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -90,7 +90,7 @@ MODULE_LICENSE("GPL");
 /* If packet size is less than this number, we allocate small skb and copy packet
  * contents into it instead of just sending original big skb up
  */
-#define EMAC_RX_COPY_THRESH		CONFIG_IBM_NEW_EMAC_RX_COPY_THRESHOLD
+#define EMAC_RX_COPY_THRESH		CONFIG_IBM_EMAC_RX_COPY_THRESHOLD
 
 /* Since multiple EMACs share MDIO lines in various ways, we need
  * to avoid re-using the same PHY ID in cases where the arch didn't
@@ -1618,7 +1618,7 @@ static void emac_parse_rx_error(struct emac_instance *dev, u16 ctrl)
 static inline void emac_rx_csum(struct emac_instance *dev,
 				struct sk_buff *skb, u16 ctrl)
 {
-#ifdef CONFIG_IBM_NEW_EMAC_TAH
+#ifdef CONFIG_IBM_EMAC_TAH
 	if (!ctrl && dev->tah_dev) {
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 		++dev->stats.rx_packets_csum;
@@ -2577,7 +2577,7 @@ static int __devinit emac_init_config(struct emac_instance *dev)
 		    of_device_is_compatible(np, "ibm,emac-440gr"))
 			dev->features |= EMAC_FTR_440EP_PHY_CLK_FIX;
 		if (of_device_is_compatible(np, "ibm,emac-405ez")) {
-#ifdef CONFIG_IBM_NEW_EMAC_NO_FLOW_CTRL
+#ifdef CONFIG_IBM_EMAC_NO_FLOW_CTRL
 			dev->features |= EMAC_FTR_NO_FLOW_CONTROL_40x;
 #else
 			printk(KERN_ERR "%s: Flow control not disabled!\n",
@@ -2601,7 +2601,7 @@ static int __devinit emac_init_config(struct emac_instance *dev)
 
 	/* Enable TAH/ZMII/RGMII features as found */
 	if (dev->tah_ph != 0) {
-#ifdef CONFIG_IBM_NEW_EMAC_TAH
+#ifdef CONFIG_IBM_EMAC_TAH
 		dev->features |= EMAC_FTR_HAS_TAH;
 #else
 		printk(KERN_ERR "%s: TAH support not enabled !\n",
@@ -2611,7 +2611,7 @@ static int __devinit emac_init_config(struct emac_instance *dev)
 	}
 
 	if (dev->zmii_ph != 0) {
-#ifdef CONFIG_IBM_NEW_EMAC_ZMII
+#ifdef CONFIG_IBM_EMAC_ZMII
 		dev->features |= EMAC_FTR_HAS_ZMII;
 #else
 		printk(KERN_ERR "%s: ZMII support not enabled !\n",
@@ -2621,7 +2621,7 @@ static int __devinit emac_init_config(struct emac_instance *dev)
 	}
 
 	if (dev->rgmii_ph != 0) {
-#ifdef CONFIG_IBM_NEW_EMAC_RGMII
+#ifdef CONFIG_IBM_EMAC_RGMII
 		dev->features |= EMAC_FTR_HAS_RGMII;
 #else
 		printk(KERN_ERR "%s: RGMII support not enabled !\n",
diff --git a/drivers/net/ethernet/ibm/emac/core.h b/drivers/net/ethernet/ibm/emac/core.h
index 4fec084..fa3ec57 100644
--- a/drivers/net/ethernet/ibm/emac/core.h
+++ b/drivers/net/ethernet/ibm/emac/core.h
@@ -47,8 +47,8 @@
 #include "tah.h"
 #include "debug.h"
 
-#define NUM_TX_BUFF			CONFIG_IBM_NEW_EMAC_TXB
-#define NUM_RX_BUFF			CONFIG_IBM_NEW_EMAC_RXB
+#define NUM_TX_BUFF			CONFIG_IBM_EMAC_TXB
+#define NUM_RX_BUFF			CONFIG_IBM_EMAC_RXB
 
 /* Simple sanity check */
 #if NUM_TX_BUFF > 256 || NUM_RX_BUFF > 256
@@ -72,7 +72,7 @@ static inline int emac_rx_size(int mtu)
 #define EMAC_DMA_ALIGN(x)		ALIGN((x), dma_get_cache_alignment())
 
 #define EMAC_RX_SKB_HEADROOM		\
-	EMAC_DMA_ALIGN(CONFIG_IBM_NEW_EMAC_RX_SKB_HEADROOM)
+	EMAC_DMA_ALIGN(CONFIG_IBM_EMAC_RX_SKB_HEADROOM)
 
 /* Size of RX skb for the given MTU */
 static inline int emac_rx_skb_size(int mtu)
@@ -335,21 +335,21 @@ enum {
 	EMAC_FTRS_ALWAYS	= 0,
 
 	EMAC_FTRS_POSSIBLE	=
-#ifdef CONFIG_IBM_NEW_EMAC_EMAC4
+#ifdef CONFIG_IBM_EMAC_EMAC4
 	    EMAC_FTR_EMAC4	| EMAC_FTR_EMAC4SYNC	|
 	    EMAC_FTR_HAS_NEW_STACR	|
 	    EMAC_FTR_STACR_OC_INVERT | EMAC_FTR_440GX_PHY_CLK_FIX |
 #endif
-#ifdef CONFIG_IBM_NEW_EMAC_TAH
+#ifdef CONFIG_IBM_EMAC_TAH
 	    EMAC_FTR_HAS_TAH	|
 #endif
-#ifdef CONFIG_IBM_NEW_EMAC_ZMII
+#ifdef CONFIG_IBM_EMAC_ZMII
 	    EMAC_FTR_HAS_ZMII	|
 #endif
-#ifdef CONFIG_IBM_NEW_EMAC_RGMII
+#ifdef CONFIG_IBM_EMAC_RGMII
 	    EMAC_FTR_HAS_RGMII	|
 #endif
-#ifdef CONFIG_IBM_NEW_EMAC_NO_FLOW_CTRL
+#ifdef CONFIG_IBM_EMAC_NO_FLOW_CTRL
 	    EMAC_FTR_NO_FLOW_CONTROL_40x |
 #endif
 	EMAC_FTR_460EX_PHY_CLK_FIX |
diff --git a/drivers/net/ethernet/ibm/emac/debug.h b/drivers/net/ethernet/ibm/emac/debug.h
index e596c77..90477fe 100644
--- a/drivers/net/ethernet/ibm/emac/debug.h
+++ b/drivers/net/ethernet/ibm/emac/debug.h
@@ -24,7 +24,7 @@
 
 #include "core.h"
 
-#if defined(CONFIG_IBM_NEW_EMAC_DEBUG)
+#if defined(CONFIG_IBM_EMAC_DEBUG)
 
 struct emac_instance;
 struct mal_instance;
diff --git a/drivers/net/ethernet/ibm/emac/mal.c b/drivers/net/ethernet/ibm/emac/mal.c
index d268f40..f3c50b9 100644
--- a/drivers/net/ethernet/ibm/emac/mal.c
+++ b/drivers/net/ethernet/ibm/emac/mal.c
@@ -577,8 +577,8 @@ static int __devinit mal_probe(struct platform_device *ofdev)
 	}
 
 	if (of_device_is_compatible(ofdev->dev.of_node, "ibm,mcmal-405ez")) {
-#if defined(CONFIG_IBM_NEW_EMAC_MAL_CLR_ICINTSTAT) && \
-		defined(CONFIG_IBM_NEW_EMAC_MAL_COMMON_ERR)
+#if defined(CONFIG_IBM_EMAC_MAL_CLR_ICINTSTAT) && \
+		defined(CONFIG_IBM_EMAC_MAL_COMMON_ERR)
 		mal->features |= (MAL_FTR_CLEAR_ICINTSTAT |
 				MAL_FTR_COMMON_ERR_INT);
 #else
@@ -616,7 +616,7 @@ static int __devinit mal_probe(struct platform_device *ofdev)
 	init_dummy_netdev(&mal->dummy_dev);
 
 	netif_napi_add(&mal->dummy_dev, &mal->napi, mal_poll,
-		       CONFIG_IBM_NEW_EMAC_POLL_WEIGHT);
+		       CONFIG_IBM_EMAC_POLL_WEIGHT);
 
 	/* Load power-on reset defaults */
 	mal_reset(mal);
diff --git a/drivers/net/ethernet/ibm/emac/mal.h b/drivers/net/ethernet/ibm/emac/mal.h
index 6608421..d06f985 100644
--- a/drivers/net/ethernet/ibm/emac/mal.h
+++ b/drivers/net/ethernet/ibm/emac/mal.h
@@ -245,10 +245,10 @@ enum {
 	MAL_FTRS_ALWAYS = 0,
 
 	MAL_FTRS_POSSIBLE =
-#ifdef CONFIG_IBM_NEW_EMAC_MAL_CLR_ICINTSTAT
+#ifdef CONFIG_IBM_EMAC_MAL_CLR_ICINTSTAT
 		MAL_FTR_CLEAR_ICINTSTAT |
 #endif
-#ifdef CONFIG_IBM_NEW_EMAC_MAL_COMMON_ERR
+#ifdef CONFIG_IBM_EMAC_MAL_COMMON_ERR
 		MAL_FTR_COMMON_ERR_INT |
 #endif
 		0,
diff --git a/drivers/net/ethernet/ibm/emac/rgmii.h b/drivers/net/ethernet/ibm/emac/rgmii.h
index d697990..9296b6c 100644
--- a/drivers/net/ethernet/ibm/emac/rgmii.h
+++ b/drivers/net/ethernet/ibm/emac/rgmii.h
@@ -54,7 +54,7 @@ struct rgmii_instance {
 	struct platform_device		*ofdev;
 };
 
-#ifdef CONFIG_IBM_NEW_EMAC_RGMII
+#ifdef CONFIG_IBM_EMAC_RGMII
 
 extern int rgmii_init(void);
 extern void rgmii_exit(void);
@@ -77,6 +77,6 @@ extern void *rgmii_dump_regs(struct platform_device *ofdev, void *buf);
 # define rgmii_set_speed(x,y,z)	do { } while(0)
 # define rgmii_get_regs_len(x)	0
 # define rgmii_dump_regs(x,buf)	(buf)
-#endif				/* !CONFIG_IBM_NEW_EMAC_RGMII */
+#endif				/* !CONFIG_IBM_EMAC_RGMII */
 
 #endif /* __IBM_NEWEMAC_RGMII_H */
diff --git a/drivers/net/ethernet/ibm/emac/tah.h b/drivers/net/ethernet/ibm/emac/tah.h
index 61dbeca..3437ab4 100644
--- a/drivers/net/ethernet/ibm/emac/tah.h
+++ b/drivers/net/ethernet/ibm/emac/tah.h
@@ -70,7 +70,7 @@ struct tah_instance {
 #define TAH_MR_DTFP		0x00100000
 #define TAH_MR_DIG		0x00080000
 
-#ifdef CONFIG_IBM_NEW_EMAC_TAH
+#ifdef CONFIG_IBM_EMAC_TAH
 
 extern int tah_init(void);
 extern void tah_exit(void);
@@ -90,6 +90,6 @@ extern void *tah_dump_regs(struct platform_device *ofdev, void *buf);
 # define tah_get_regs_len(x)	0
 # define tah_dump_regs(x,buf)	(buf)
 
-#endif				/* !CONFIG_IBM_NEW_EMAC_TAH */
+#endif				/* !CONFIG_IBM_EMAC_TAH */
 
 #endif /* __IBM_NEWEMAC_TAH_H */
diff --git a/drivers/net/ethernet/ibm/emac/zmii.h b/drivers/net/ethernet/ibm/emac/zmii.h
index 1333fa2..ceaed82 100644
--- a/drivers/net/ethernet/ibm/emac/zmii.h
+++ b/drivers/net/ethernet/ibm/emac/zmii.h
@@ -51,7 +51,7 @@ struct zmii_instance {
 	struct platform_device		*ofdev;
 };
 
-#ifdef CONFIG_IBM_NEW_EMAC_ZMII
+#ifdef CONFIG_IBM_EMAC_ZMII
 
 extern int zmii_init(void);
 extern void zmii_exit(void);
@@ -73,6 +73,6 @@ extern void *zmii_dump_regs(struct platform_device *ofdev, void *buf);
 # define zmii_set_speed(x,y,z)	do { } while(0)
 # define zmii_get_regs_len(x)	0
 # define zmii_dump_regs(x,buf)	(buf)
-#endif				/* !CONFIG_IBM_NEW_EMAC_ZMII */
+#endif				/* !CONFIG_IBM_EMAC_ZMII */
 
 #endif /* __IBM_NEWEMAC_ZMII_H */
-- 
1.7.6

Yours Tony
