From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] sh_eth: remove 'register_type' field from 'struct sh_eth_plat_data'
Date: Sun, 18 Aug 2013 03:13:26 +0400
Message-ID: <201308180313.26607.sergei.shtylyov@cogentembedded.com>
References: <201308180308.39941.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net, lethal@linux-sh.org,
	linux-sh@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:48895 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634Ab3HQXNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 19:13:12 -0400
Received: by mail-lb0-f177.google.com with SMTP id n6so2158905lbi.36
        for <netdev@vger.kernel.org>; Sat, 17 Aug 2013 16:13:11 -0700 (PDT)
In-Reply-To: <201308180308.39941.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the 'register_type' field of the 'sh_eth' driver's platform data is not
used by the driver anymore, it's time to remove it and  its initializers from
the SH platform code. Also  move *enum* declaring values for this  field from
<linux/sh_eth.h>  to  the  local driver's  header file as they're only needed
by the driver itself  now...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 arch/arm/mach-shmobile/board-armadillo800eva.c |    1 -
 arch/arm/mach-shmobile/board-bockw.c           |    1 -
 arch/sh/boards/board-espt.c                    |    1 -
 arch/sh/boards/board-sh7757lcr.c               |    4 ----
 arch/sh/boards/mach-ecovec24/setup.c           |    1 -
 arch/sh/boards/mach-se/7724/setup.c            |    1 -
 arch/sh/boards/mach-sh7763rdp/setup.c          |    1 -
 arch/sh/kernel/cpu/sh2/setup-sh7619.c          |    1 -
 drivers/net/ethernet/renesas/sh_eth.h          |    7 +++++++
 include/linux/sh_eth.h                         |    7 -------
 10 files changed, 7 insertions(+), 18 deletions(-)

Index: net-next/arch/arm/mach-shmobile/board-armadillo800eva.c
===================================================================
--- net-next.orig/arch/arm/mach-shmobile/board-armadillo800eva.c
+++ net-next/arch/arm/mach-shmobile/board-armadillo800eva.c
@@ -358,7 +358,6 @@ static struct platform_device usbhsf_dev
 static struct sh_eth_plat_data sh_eth_platdata = {
 	.phy			= 0x00, /* LAN8710A */
 	.edmac_endian		= EDMAC_LITTLE_ENDIAN,
-	.register_type		= SH_ETH_REG_GIGABIT,
 	.phy_interface		= PHY_INTERFACE_MODE_MII,
 };
 
Index: net-next/arch/arm/mach-shmobile/board-bockw.c
===================================================================
--- net-next.orig/arch/arm/mach-shmobile/board-bockw.c
+++ net-next/arch/arm/mach-shmobile/board-bockw.c
@@ -89,7 +89,6 @@ static struct sh_mobile_sdhi_info sdhi0_
 static struct sh_eth_plat_data ether_platform_data __initdata = {
 	.phy		= 0x01,
 	.edmac_endian	= EDMAC_LITTLE_ENDIAN,
-	.register_type	= SH_ETH_REG_FAST_RCAR,
 	.phy_interface	= PHY_INTERFACE_MODE_RMII,
 	/*
 	 * Although the LINK signal is available on the board, it's connected to
Index: net-next/arch/sh/boards/board-espt.c
===================================================================
--- net-next.orig/arch/sh/boards/board-espt.c
+++ net-next/arch/sh/boards/board-espt.c
@@ -80,7 +80,6 @@ static struct resource sh_eth_resources[
 static struct sh_eth_plat_data sh7763_eth_pdata = {
 	.phy = 0,
 	.edmac_endian = EDMAC_LITTLE_ENDIAN,
-	.register_type = SH_ETH_REG_GIGABIT,
 	.phy_interface = PHY_INTERFACE_MODE_MII,
 };
 
Index: net-next/arch/sh/boards/board-sh7757lcr.c
===================================================================
--- net-next.orig/arch/sh/boards/board-sh7757lcr.c
+++ net-next/arch/sh/boards/board-sh7757lcr.c
@@ -77,7 +77,6 @@ static struct resource sh_eth0_resources
 static struct sh_eth_plat_data sh7757_eth0_pdata = {
 	.phy = 1,
 	.edmac_endian = EDMAC_LITTLE_ENDIAN,
-	.register_type = SH_ETH_REG_FAST_SH4,
 	.set_mdio_gate = sh7757_eth_set_mdio_gate,
 };
 
@@ -106,7 +105,6 @@ static struct resource sh_eth1_resources
 static struct sh_eth_plat_data sh7757_eth1_pdata = {
 	.phy = 1,
 	.edmac_endian = EDMAC_LITTLE_ENDIAN,
-	.register_type = SH_ETH_REG_FAST_SH4,
 	.set_mdio_gate = sh7757_eth_set_mdio_gate,
 };
 
@@ -151,7 +149,6 @@ static struct resource sh_eth_giga0_reso
 static struct sh_eth_plat_data sh7757_eth_giga0_pdata = {
 	.phy = 18,
 	.edmac_endian = EDMAC_LITTLE_ENDIAN,
-	.register_type = SH_ETH_REG_GIGABIT,
 	.set_mdio_gate = sh7757_eth_giga_set_mdio_gate,
 	.phy_interface = PHY_INTERFACE_MODE_RGMII_ID,
 };
@@ -186,7 +183,6 @@ static struct resource sh_eth_giga1_reso
 static struct sh_eth_plat_data sh7757_eth_giga1_pdata = {
 	.phy = 19,
 	.edmac_endian = EDMAC_LITTLE_ENDIAN,
-	.register_type = SH_ETH_REG_GIGABIT,
 	.set_mdio_gate = sh7757_eth_giga_set_mdio_gate,
 	.phy_interface = PHY_INTERFACE_MODE_RGMII_ID,
 };
Index: net-next/arch/sh/boards/mach-ecovec24/setup.c
===================================================================
--- net-next.orig/arch/sh/boards/mach-ecovec24/setup.c
+++ net-next/arch/sh/boards/mach-ecovec24/setup.c
@@ -159,7 +159,6 @@ static struct resource sh_eth_resources[
 static struct sh_eth_plat_data sh_eth_plat = {
 	.phy = 0x1f, /* SMSC LAN8700 */
 	.edmac_endian = EDMAC_LITTLE_ENDIAN,
-	.register_type = SH_ETH_REG_FAST_SH4,
 	.phy_interface = PHY_INTERFACE_MODE_MII,
 	.ether_link_active_low = 1
 };
Index: net-next/arch/sh/boards/mach-se/7724/setup.c
===================================================================
--- net-next.orig/arch/sh/boards/mach-se/7724/setup.c
+++ net-next/arch/sh/boards/mach-se/7724/setup.c
@@ -377,7 +377,6 @@ static struct resource sh_eth_resources[
 static struct sh_eth_plat_data sh_eth_plat = {
 	.phy = 0x1f, /* SMSC LAN8187 */
 	.edmac_endian = EDMAC_LITTLE_ENDIAN,
-	.register_type = SH_ETH_REG_FAST_SH4,
 	.phy_interace = PHY_INTERFACE_MODE_MII,
 };
 
Index: net-next/arch/sh/boards/mach-sh7763rdp/setup.c
===================================================================
--- net-next.orig/arch/sh/boards/mach-sh7763rdp/setup.c
+++ net-next/arch/sh/boards/mach-sh7763rdp/setup.c
@@ -88,7 +88,6 @@ static struct resource sh_eth_resources[
 static struct sh_eth_plat_data sh7763_eth_pdata = {
 	.phy = 1,
 	.edmac_endian = EDMAC_LITTLE_ENDIAN,
-	.register_type = SH_ETH_REG_GIGABIT,
 	.phy_interface = PHY_INTERFACE_MODE_MII,
 };
 
Index: net-next/arch/sh/kernel/cpu/sh2/setup-sh7619.c
===================================================================
--- net-next.orig/arch/sh/kernel/cpu/sh2/setup-sh7619.c
+++ net-next/arch/sh/kernel/cpu/sh2/setup-sh7619.c
@@ -114,7 +114,6 @@ static struct platform_device scif2_devi
 static struct sh_eth_plat_data eth_platform_data = {
 	.phy		= 1,
 	.edmac_endian	= EDMAC_LITTLE_ENDIAN,
-	.register_type	= SH_ETH_REG_FAST_SH3_SH2,
 	.phy_interace	= PHY_INTERFACE_MODE_MII,
 };
 
Index: net-next/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net-next/drivers/net/ethernet/renesas/sh_eth.h
@@ -157,6 +157,13 @@ enum {
 	SH_ETH_MAX_REGISTER_OFFSET,
 };
 
+enum {
+	SH_ETH_REG_GIGABIT,
+	SH_ETH_REG_FAST_RCAR,
+	SH_ETH_REG_FAST_SH4,
+	SH_ETH_REG_FAST_SH3_SH2
+};
+
 /* Driver's parameters */
 #if defined(CONFIG_CPU_SH4) || defined(CONFIG_ARCH_SHMOBILE)
 #define SH4_SKB_RX_ALIGN	32
Index: net-next/include/linux/sh_eth.h
===================================================================
--- net-next.orig/include/linux/sh_eth.h
+++ net-next/include/linux/sh_eth.h
@@ -5,17 +5,10 @@
 #include <linux/if_ether.h>
 
 enum {EDMAC_LITTLE_ENDIAN, EDMAC_BIG_ENDIAN};
-enum {
-	SH_ETH_REG_GIGABIT,
-	SH_ETH_REG_FAST_RCAR,
-	SH_ETH_REG_FAST_SH4,
-	SH_ETH_REG_FAST_SH3_SH2
-};
 
 struct sh_eth_plat_data {
 	int phy;
 	int edmac_endian;
-	int register_type;
 	phy_interface_t phy_interface;
 	void (*set_mdio_gate)(void *addr);
 
