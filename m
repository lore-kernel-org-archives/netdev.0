From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: [PATCH] Eliminate user-selectable CONFIG_MV643XX_ETH_[012]
Date: Tue, 20 Feb 2007 05:15:20 -0700
Message-ID: <20070220121520.GA17927@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>,
	Paul Mackerras <paulus@samba.org>,
	Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:2378 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932901AbXBTMPW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 07:15:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dale Farnsworth <dale@farnsworth.org>

Remove the use of CONFIG_MV643XX_ETH_[012] variables on most
platforms.  Instead, platform-specific code enables the ports
supported by the hardware.  After this patch, these config
variables are only used in arch/ppc, so also move them from
drivers/net/Kconfig to arch/ppc/Kconfig.

Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

---
It was a mis-feature that the supported ports were ever user-selectable.
Which ports the hardware supports should be specified by platform-specific
code, not by the user.

 arch/mips/momentum/jaguar_atx/platform.c |   21 ---------------------
 arch/mips/momentum/ocelot_3/platform.c   |   21 ---------------------
 arch/mips/momentum/ocelot_c/platform.c   |   14 --------------
 arch/ppc/Kconfig                         |   15 +++++++++++++++
 drivers/net/Kconfig                      |   21 ---------------------
 5 files changed, 15 insertions(+), 77 deletions(-)

Index: b/arch/mips/momentum/jaguar_atx/platform.c
===================================================================
--- a/arch/mips/momentum/jaguar_atx/platform.c
+++ b/arch/mips/momentum/jaguar_atx/platform.c
@@ -38,8 +38,6 @@ static struct platform_device mv643xx_et
 #define MV64x60_IRQ_ETH_1 49
 #define MV64x60_IRQ_ETH_2 50
 
-#ifdef CONFIG_MV643XX_ETH_0
-
 static struct resource mv64x60_eth0_resources[] = {
 	[0] = {
 		.name	= "eth0 irq",
@@ -72,9 +70,6 @@ static struct platform_device eth0_devic
 		.platform_data = &eth0_pd,
 	},
 };
-#endif /* CONFIG_MV643XX_ETH_0 */
-
-#ifdef CONFIG_MV643XX_ETH_1
 
 static struct resource mv64x60_eth1_resources[] = {
 	[0] = {
@@ -108,9 +103,6 @@ static struct platform_device eth1_devic
 		.platform_data = &eth1_pd,
 	},
 };
-#endif /* CONFIG_MV643XX_ETH_1 */
-
-#ifdef CONFIG_MV643XX_ETH_2
 
 static struct resource mv64x60_eth2_resources[] = {
 	[0] = {
@@ -136,19 +128,12 @@ static struct platform_device eth2_devic
 		.platform_data = &eth2_pd,
 	},
 };
-#endif /* CONFIG_MV643XX_ETH_2 */
 
 static struct platform_device *mv643xx_eth_pd_devs[] __initdata = {
 	&mv643xx_eth_shared_device,
-#ifdef CONFIG_MV643XX_ETH_0
 	&eth0_device,
-#endif
-#ifdef CONFIG_MV643XX_ETH_1
 	&eth1_device,
-#endif
-#ifdef CONFIG_MV643XX_ETH_2
 	&eth2_device,
-#endif
 };
 
 static u8 __init exchange_bit(u8 val, u8 cs)
@@ -215,15 +200,9 @@ static int __init mv643xx_eth_add_pds(vo
 	int ret;
 
 	get_mac(mac);
-#ifdef CONFIG_MV643XX_ETH_0
 	eth_mac_add(eth1_mac_addr, mac, 0);
-#endif
-#ifdef CONFIG_MV643XX_ETH_1
 	eth_mac_add(eth1_mac_addr, mac, 1);
-#endif
-#ifdef CONFIG_MV643XX_ETH_2
 	eth_mac_add(eth2_mac_addr, mac, 2);
-#endif
 	ret = platform_add_devices(mv643xx_eth_pd_devs,
 			ARRAY_SIZE(mv643xx_eth_pd_devs));
 
Index: b/arch/mips/momentum/ocelot_3/platform.c
===================================================================
--- a/arch/mips/momentum/ocelot_3/platform.c
+++ b/arch/mips/momentum/ocelot_3/platform.c
@@ -38,8 +38,6 @@ static struct platform_device mv643xx_et
 #define MV64x60_IRQ_ETH_1 49
 #define MV64x60_IRQ_ETH_2 50
 
-#ifdef CONFIG_MV643XX_ETH_0
-
 static struct resource mv64x60_eth0_resources[] = {
 	[0] = {
 		.name	= "eth0 irq",
@@ -72,9 +70,6 @@ static struct platform_device eth0_devic
 		.platform_data = &eth0_pd,
 	},
 };
-#endif /* CONFIG_MV643XX_ETH_0 */
-
-#ifdef CONFIG_MV643XX_ETH_1
 
 static struct resource mv64x60_eth1_resources[] = {
 	[0] = {
@@ -108,9 +103,6 @@ static struct platform_device eth1_devic
 		.platform_data = &eth1_pd,
 	},
 };
-#endif /* CONFIG_MV643XX_ETH_1 */
-
-#ifdef CONFIG_MV643XX_ETH_2
 
 static struct resource mv64x60_eth2_resources[] = {
 	[0] = {
@@ -136,19 +128,12 @@ static struct platform_device eth2_devic
 		.platform_data = &eth2_pd,
 	},
 };
-#endif /* CONFIG_MV643XX_ETH_2 */
 
 static struct platform_device *mv643xx_eth_pd_devs[] __initdata = {
 	&mv643xx_eth_shared_device,
-#ifdef CONFIG_MV643XX_ETH_0
 	&eth0_device,
-#endif
-#ifdef CONFIG_MV643XX_ETH_1
 	&eth1_device,
-#endif
-#ifdef CONFIG_MV643XX_ETH_2
 	&eth2_device,
-#endif
 };
 
 static u8 __init exchange_bit(u8 val, u8 cs)
@@ -215,15 +200,9 @@ static int __init mv643xx_eth_add_pds(vo
 	int ret;
 
 	get_mac(mac);
-#ifdef CONFIG_MV643XX_ETH_0
 	eth_mac_add(eth1_mac_addr, mac, 0);
-#endif
-#ifdef CONFIG_MV643XX_ETH_1
 	eth_mac_add(eth1_mac_addr, mac, 1);
-#endif
-#ifdef CONFIG_MV643XX_ETH_2
 	eth_mac_add(eth2_mac_addr, mac, 2);
-#endif
 	ret = platform_add_devices(mv643xx_eth_pd_devs,
 			ARRAY_SIZE(mv643xx_eth_pd_devs));
 
Index: b/arch/mips/momentum/ocelot_c/platform.c
===================================================================
--- a/arch/mips/momentum/ocelot_c/platform.c
+++ b/arch/mips/momentum/ocelot_c/platform.c
@@ -37,8 +37,6 @@ static struct platform_device mv643xx_et
 #define MV64x60_IRQ_ETH_0 48
 #define MV64x60_IRQ_ETH_1 49
 
-#ifdef CONFIG_MV643XX_ETH_0
-
 static struct resource mv64x60_eth0_resources[] = {
 	[0] = {
 		.name	= "eth0 irq",
@@ -71,9 +69,6 @@ static struct platform_device eth0_devic
 		.platform_data = &eth0_pd,
 	},
 };
-#endif /* CONFIG_MV643XX_ETH_0 */
-
-#ifdef CONFIG_MV643XX_ETH_1
 
 static struct resource mv64x60_eth1_resources[] = {
 	[0] = {
@@ -107,16 +102,11 @@ static struct platform_device eth1_devic
 		.platform_data = &eth1_pd,
 	},
 };
-#endif /* CONFIG_MV643XX_ETH_1 */
 
 static struct platform_device *mv643xx_eth_pd_devs[] __initdata = {
 	&mv643xx_eth_shared_device,
-#ifdef CONFIG_MV643XX_ETH_0
 	&eth0_device,
-#endif
-#ifdef CONFIG_MV643XX_ETH_1
 	&eth1_device,
-#endif
 	/* The third port is not wired up on the Ocelot C */
 };
 
@@ -184,12 +174,8 @@ static int __init mv643xx_eth_add_pds(vo
 	int ret;
 
 	get_mac(mac);
-#ifdef CONFIG_MV643XX_ETH_0
 	eth_mac_add(eth1_mac_addr, mac, 0);
-#endif
-#ifdef CONFIG_MV643XX_ETH_1
 	eth_mac_add(eth1_mac_addr, mac, 1);
-#endif
 	ret = platform_add_devices(mv643xx_eth_pd_devs,
 			ARRAY_SIZE(mv643xx_eth_pd_devs));
 
Index: b/arch/ppc/Kconfig
===================================================================
--- a/arch/ppc/Kconfig
+++ b/arch/ppc/Kconfig
@@ -845,6 +845,21 @@ config MV64X60
 	select PPC_INDIRECT_PCI
 	default y
 
+config MV643XX_ETH_0
+	bool
+	depends on MV643XX_ETH && (KATANA || RADSTONE_PPC7D || EV64360 || HDPU)
+	default y
+
+config MV643XX_ETH_1
+	bool
+	depends on MV643XX_ETH && (KATANA || RADSTONE_PPC7D || EV64360)
+	default y
+
+config MV643XX_ETH_2
+	bool
+	depends on MV643XX_ETH && (KATANA || RADSTONE_PPC7D || EV64360)
+	default y
+
 menu "Set bridge options"
 	depends on MV64X60
 
Index: b/drivers/net/Kconfig
===================================================================
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2305,27 +2305,6 @@ config MV643XX_ETH
 	  chipset which is used in the Momenco Ocelot C and Jaguar ATX and
 	  Pegasos II, amongst other PPC and MIPS boards.
 
-config MV643XX_ETH_0
-	bool "MV-643XX Port 0"
-	depends on MV643XX_ETH
-	help
-	  This enables support for Port 0 of the Marvell MV643XX Gigabit
-	  Ethernet.
-
-config MV643XX_ETH_1
-	bool "MV-643XX Port 1"
-	depends on MV643XX_ETH
-	help
-	  This enables support for Port 1 of the Marvell MV643XX Gigabit
-	  Ethernet.
-
-config MV643XX_ETH_2
-	bool "MV-643XX Port 2"
-	depends on MV643XX_ETH
-	help
-	  This enables support for Port 2 of the Marvell MV643XX Gigabit
-	  Ethernet.
-
 config QLA3XXX
 	tristate "QLogic QLA3XXX Network Driver Support"
 	depends on PCI
