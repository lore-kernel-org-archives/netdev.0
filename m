From: Tony Breeds <tony@bakeyournoodle.com>
Subject: [PATCH] fix IBM EMAC driver after rename.
Date: Thu, 18 Aug 2011 16:13:55 +1000
Message-ID: <20110818061354.GD19739@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:34323 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751127Ab1HRGN6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Aug 2011 02:13:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 9aa3283595451ca093500ff0977b106e1f465586 (ehea/ibm*: Move the
IBM drivers) the IBM_NEW_EMAC* were renames to IBM_EMAC*

The conversion was incomplete so that even if the driver was added to
the .config it wasn't built, but there were no errors)

This should fix those omissions.

Tested on a canyondlands board.
---

Signed-off-by: Tony Breeds <tony@bakeyournoodle.com>
---
 arch/powerpc/platforms/40x/Kconfig     |   12 +++---
 arch/powerpc/platforms/44x/Kconfig     |   54 ++++++++++++++++----------------
 arch/powerpc/platforms/cell/Kconfig    |    8 ++--
 drivers/net/ethernet/ibm/emac/Makefile |   10 +++---
 drivers/net/ethernet/ibm/emac/core.c   |   12 +++---
 drivers/net/ethernet/ibm/emac/core.h   |   16 +++++-----
 drivers/net/ethernet/ibm/emac/debug.h  |    2 +-
 drivers/net/ethernet/ibm/emac/mal.c    |    6 ++--
 drivers/net/ethernet/ibm/emac/mal.h    |    4 +-
 drivers/net/ethernet/ibm/emac/rgmii.h  |    4 +-
 drivers/net/ethernet/ibm/emac/tah.h    |    4 +-
 drivers/net/ethernet/ibm/emac/zmii.h   |    4 +-
 12 files changed, 68 insertions(+), 68 deletions(-)

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
index 0b5c995..ed6470c 100644
--- a/drivers/net/ethernet/ibm/emac/Makefile
+++ b/drivers/net/ethernet/ibm/emac/Makefile
@@ -2,10 +2,10 @@
 # Makefile for the PowerPC 4xx on-chip ethernet driver
 #
 
-obj-$(CONFIG_IBM_NEW_EMAC) += ibm_newemac.o
+obj-$(CONFIG_IBM_EMAC) += ibm_newemac.o
 
 ibm_newemac-y := mal.o core.o phy.o
-ibm_newemac-$(CONFIG_IBM_NEW_EMAC_ZMII) += zmii.o
-ibm_newemac-$(CONFIG_IBM_NEW_EMAC_RGMII) += rgmii.o
-ibm_newemac-$(CONFIG_IBM_NEW_EMAC_TAH) += tah.o
-ibm_newemac-$(CONFIG_IBM_NEW_EMAC_DEBUG) += debug.o
+ibm_newemac-$(CONFIG_IBM_EMAC_ZMII) += zmii.o
+ibm_newemac-$(CONFIG_IBM_EMAC_RGMII) += rgmii.o
+ibm_newemac-$(CONFIG_IBM_EMAC_TAH) += tah.o
+ibm_newemac-$(CONFIG_IBM_EMAC_DEBUG) += debug.o
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

