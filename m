From: Kishon Vijay Abraham I <kishon@ti.com>
Subject: [PATCH v2 4/5] ARM: OMAP: USB: Add phy binding information
Date: Tue, 19 Feb 2013 11:23:17 +0530
Message-ID: <1361253198-7401-5-git-send-email-kishon@ti.com>
References: <1361253198-7401-1-git-send-email-kishon@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <rob@landley.net>, <tony@atomide.com>, <linux@arm.linux.org.uk>,
	<eballetbo@gmail.com>, <javier@dowhile0.org>, <kishon@ti.com>,
	<balbi@ti.com>, <gregkh@linuxfoundation.org>,
	<akpm@linux-foundation.org>, <mchehab@redhat.com>,
	<cesarb@cesarb.net>, <davem@davemloft.net>, <arnd@arndb.de>,
	<santosh.shilimkar@ti.com>, <broonie@opensource.wolfsonmicro.com>,
	<swarren@nvidia.com>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1361253198-7401-1-git-send-email-kishon@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order for controllers to get PHY in case of non dt boot, the phy
binding information should be added in the platform specific
initialization code using phy_bind. The previously added usb_bind_phy
can't be removed yet because the musb controller continues to use the
old PHY library which has OTG in it (struct usb_phy has struct usb_otg
as member). Until we have a separate OTG state machine to handle all of
that, the new generic PHY framework and the old phy library will co-exist.

Signed-off-by: Kishon Vijay Abraham I <kishon@ti.com>
---
 arch/arm/mach-omap2/board-2430sdp.c          |    2 ++
 arch/arm/mach-omap2/board-3430sdp.c          |    2 ++
 arch/arm/mach-omap2/board-4430sdp.c          |    2 ++
 arch/arm/mach-omap2/board-cm-t35.c           |    2 ++
 arch/arm/mach-omap2/board-devkit8000.c       |    2 ++
 arch/arm/mach-omap2/board-igep0020.c         |    2 ++
 arch/arm/mach-omap2/board-ldp.c              |    2 ++
 arch/arm/mach-omap2/board-omap3beagle.c      |    2 ++
 arch/arm/mach-omap2/board-omap3evm.c         |    2 ++
 arch/arm/mach-omap2/board-omap3logic.c       |    2 ++
 arch/arm/mach-omap2/board-omap3pandora.c     |    2 ++
 arch/arm/mach-omap2/board-omap3stalker.c     |    2 ++
 arch/arm/mach-omap2/board-omap3touchbook.c   |    2 ++
 arch/arm/mach-omap2/board-omap4panda.c       |    2 ++
 arch/arm/mach-omap2/board-overo.c            |    2 ++
 arch/arm/mach-omap2/board-rm680.c            |    2 ++
 arch/arm/mach-omap2/board-zoom-peripherals.c |    2 ++
 17 files changed, 34 insertions(+)

diff --git a/arch/arm/mach-omap2/board-2430sdp.c b/arch/arm/mach-omap2/board-2430sdp.c
index 1337f2c..a28cc5b 100644
--- a/arch/arm/mach-omap2/board-2430sdp.c
+++ b/arch/arm/mach-omap2/board-2430sdp.c
@@ -28,6 +28,7 @@
 #include <linux/io.h>
 #include <linux/gpio.h>
 #include <linux/usb/phy.h>
+#include <linux/phy/phy.h>
 
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
@@ -265,6 +266,7 @@ static void __init omap_2430sdp_init(void)
 
 	omap_mux_init_signal("usb0hs_stp", OMAP_PULL_ENA | OMAP_PULL_UP);
 	usb_bind_phy("musb-hdrc.0.auto", 0, "twl4030_usb");
+	phy_bind("musb-hdrc.0.auto", 0, "twl4030_usb");
 	usb_musb_init(NULL);
 
 	board_smc91x_init();
diff --git a/arch/arm/mach-omap2/board-3430sdp.c b/arch/arm/mach-omap2/board-3430sdp.c
index 8a2e242..a4f4b8e 100644
--- a/arch/arm/mach-omap2/board-3430sdp.c
+++ b/arch/arm/mach-omap2/board-3430sdp.c
@@ -26,6 +26,7 @@
 #include <linux/mmc/host.h>
 #include <linux/platform_data/spi-omap2-mcspi.h>
 #include <linux/usb/phy.h>
+#include <linux/phy/phy.h>
 
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
@@ -581,6 +582,7 @@ static void __init omap_3430sdp_init(void)
 	omap_serial_init();
 	omap_sdrc_init(hyb18m512160af6_sdrc_params, NULL);
 	usb_bind_phy("musb-hdrc.0.auto", 0, "twl4030_usb");
+	phy_bind("musb-hdrc.0.auto", 0, "twl4030_usb");
 	usb_musb_init(NULL);
 	board_smc91x_init();
 	board_flash_init(sdp_flash_partitions, chip_sel_3430, 0);
diff --git a/arch/arm/mach-omap2/board-4430sdp.c b/arch/arm/mach-omap2/board-4430sdp.c
index 8e8efcc..d5bc353 100644
--- a/arch/arm/mach-omap2/board-4430sdp.c
+++ b/arch/arm/mach-omap2/board-4430sdp.c
@@ -29,6 +29,7 @@
 #include <linux/platform_data/omap4-keypad.h>
 #include <linux/usb/musb.h>
 #include <linux/usb/phy.h>
+#include <linux/phy/phy.h>
 
 #include <asm/hardware/gic.h>
 #include <asm/mach-types.h>
@@ -698,6 +699,7 @@ static void __init omap_4430sdp_init(void)
 	omap4_twl6030_hsmmc_init(mmc);
 
 	usb_bind_phy("musb-hdrc.0.auto", 0, "omap-usb2.1.auto");
+	phy_bind("musb-hdrc.0.auto", 0, "omap-usb2.1.auto");
 	usb_musb_init(&musb_board_data);
 
 	status = omap_ethernet_init();
diff --git a/arch/arm/mach-omap2/board-cm-t35.c b/arch/arm/mach-omap2/board-cm-t35.c
index f1172f2..6860dc9 100644
--- a/arch/arm/mach-omap2/board-cm-t35.c
+++ b/arch/arm/mach-omap2/board-cm-t35.c
@@ -31,6 +31,7 @@
 #include <linux/regulator/machine.h>
 #include <linux/mmc/host.h>
 #include <linux/usb/phy.h>
+#include <linux/phy/phy.h>
 
 #include <linux/spi/spi.h>
 #include <linux/spi/tdo24m.h>
@@ -726,6 +727,7 @@ static void __init cm_t3x_common_init(void)
 	omap_twl4030_audio_init("cm-t3x");
 
 	usb_bind_phy("musb-hdrc.0.auto", 0, "twl4030_usb");
+	phy_bind("musb-hdrc.0.auto", 0, "twl4030_usb");
 	usb_musb_init(NULL);
 	cm_t35_init_usbh();
 	cm_t35_init_camera();
diff --git a/arch/arm/mach-omap2/board-devkit8000.c b/arch/arm/mach-omap2/board-devkit8000.c
index 77cade52..89c3e64 100644
--- a/arch/arm/mach-omap2/board-devkit8000.c
+++ b/arch/arm/mach-omap2/board-devkit8000.c
@@ -30,6 +30,7 @@
 #include <linux/mtd/nand.h>
 #include <linux/mmc/host.h>
 #include <linux/usb/phy.h>
+#include <linux/phy/phy.h>
 
 #include <linux/regulator/machine.h>
 #include <linux/i2c/twl.h>
@@ -624,6 +625,7 @@ static void __init devkit8000_init(void)
 	omap_ads7846_init(2, OMAP3_DEVKIT_TS_GPIO, 0, NULL);
 
 	usb_bind_phy("musb-hdrc.0.auto", 0, "twl4030_usb");
+	phy_bind("musb-hdrc.0.auto", 0, "twl4030_usb");
 	usb_musb_init(NULL);
 	usbhs_init(&usbhs_bdata);
 	board_nand_init(devkit8000_nand_partitions,
diff --git a/arch/arm/mach-omap2/board-igep0020.c b/arch/arm/mach-omap2/board-igep0020.c
index 15e5881..2ef8b31 100644
--- a/arch/arm/mach-omap2/board-igep0020.c
+++ b/arch/arm/mach-omap2/board-igep0020.c
@@ -19,6 +19,7 @@
 #include <linux/interrupt.h>
 #include <linux/input.h>
 #include <linux/usb/phy.h>
+#include <linux/phy/phy.h>
 
 #include <linux/regulator/machine.h>
 #include <linux/regulator/fixed.h>
@@ -627,6 +628,7 @@ static void __init igep_init(void)
 	omap_sdrc_init(m65kxxxxam_sdrc_params,
 				  m65kxxxxam_sdrc_params);
 	usb_bind_phy("musb-hdrc.0.auto", 0, "twl4030_usb");
+	phy_bind("musb-hdrc.0.auto", 0, "twl4030_usb");
 	usb_musb_init(NULL);
 
 	igep_flash_init();
diff --git a/arch/arm/mach-omap2/board-ldp.c b/arch/arm/mach-omap2/board-ldp.c
index 3b5510a..c2d8cbd 100644
--- a/arch/arm/mach-omap2/board-ldp.c
+++ b/arch/arm/mach-omap2/board-ldp.c
@@ -29,6 +29,7 @@
 #include <linux/smsc911x.h>
 #include <linux/mmc/host.h>
 #include <linux/usb/phy.h>
+#include <linux/phy/phy.h>
 #include <linux/platform_data/spi-omap2-mcspi.h>
 
 #include <asm/mach-types.h>
@@ -420,6 +421,7 @@ static void __init omap_ldp_init(void)
 	omap_serial_init();
 	omap_sdrc_init(NULL, NULL);
 	usb_bind_phy("musb-hdrc.0.auto", 0, "twl4030_usb");
+	phy_bind("musb-hdrc.0.auto", 0, "twl4030_usb");
 	usb_musb_init(NULL);
 	board_nand_init(ldp_nand_partitions, ARRAY_SIZE(ldp_nand_partitions),
 			ZOOM_NAND_CS, 0, nand_default_timings);
diff --git a/arch/arm/mach-omap2/board-omap3beagle.c b/arch/arm/mach-omap2/board-omap3beagle.c
index 4616f92..6f17343 100644
--- a/arch/arm/mach-omap2/board-omap3beagle.c
+++ b/arch/arm/mach-omap2/board-omap3beagle.c
@@ -31,6 +31,7 @@
 #include <linux/mtd/nand.h>
 #include <linux/mmc/host.h>
 #include <linux/usb/phy.h>
+#include <linux/phy/phy.h>
 
 #include <linux/regulator/machine.h>
 #include <linux/i2c/twl.h>
@@ -521,6 +522,7 @@ static void __init omap3_beagle_init(void)
 				  mt46h32m32lf6_sdrc_params);
 
 	usb_bind_phy("musb-hdrc.0.auto", 0, "twl4030_usb");
+	phy_bind("musb-hdrc.0.auto", 0, "twl4030_usb");
 	usb_musb_init(NULL);
 	usbhs_init(&usbhs_bdata);
 	board_nand_init(omap3beagle_nand_partitions,
diff --git a/arch/arm/mach-omap2/board-omap3evm.c b/arch/arm/mach-omap2/board-omap3evm.c
index a198b61..bfd3927 100644
--- a/arch/arm/mach-omap2/board-omap3evm.c
+++ b/arch/arm/mach-omap2/board-omap3evm.c
@@ -42,6 +42,7 @@
 #include <linux/mmc/host.h>
 #include <linux/export.h>
 #include <linux/usb/phy.h>
+#include <linux/phy/phy.h>
 
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
@@ -736,6 +737,7 @@ static void __init omap3_evm_init(void)
 		usbhs_bdata.reset_gpio_port[1] = 135;
 	}
 	usb_bind_phy("musb-hdrc.0.auto", 0, "twl4030_usb");
+	phy_bind("musb-hdrc.0.auto", 0, "twl4030_usb");
 	usb_musb_init(&musb_board_data);
 	usbhs_init(&usbhs_bdata);
 	board_nand_init(omap3evm_nand_partitions,
diff --git a/arch/arm/mach-omap2/board-omap3logic.c b/arch/arm/mach-omap2/board-omap3logic.c
index 9409eb8..64d4daf 100644
--- a/arch/arm/mach-omap2/board-omap3logic.c
+++ b/arch/arm/mach-omap2/board-omap3logic.c
@@ -30,6 +30,7 @@
 #include <linux/i2c/twl.h>
 #include <linux/mmc/host.h>
 #include <linux/usb/phy.h>
+#include <linux/phy/phy.h>
 
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
@@ -217,6 +218,7 @@ static void __init omap3logic_init(void)
 	board_smsc911x_init();
 
 	usb_bind_phy("musb-hdrc.0.auto", 0, "twl4030_usb");
+	phy_bind("musb-hdrc.0.auto", 0, "twl4030_usb");
 	usb_musb_init(NULL);
 
 	/* Ensure SDRC pins are mux'd for self-refresh */
diff --git a/arch/arm/mach-omap2/board-omap3pandora.c b/arch/arm/mach-omap2/board-omap3pandora.c
index 1ac3e81..b391107 100644
--- a/arch/arm/mach-omap2/board-omap3pandora.c
+++ b/arch/arm/mach-omap2/board-omap3pandora.c
@@ -36,6 +36,7 @@
 #include <linux/mmc/card.h>
 #include <linux/regulator/fixed.h>
 #include <linux/usb/phy.h>
+#include <linux/phy/phy.h>
 #include <linux/platform_data/spi-omap2-mcspi.h>
 
 #include <asm/mach-types.h>
@@ -603,6 +604,7 @@ static void __init omap3pandora_init(void)
 	omap_ads7846_init(1, OMAP3_PANDORA_TS_GPIO, 0, NULL);
 	usbhs_init(&usbhs_bdata);
 	usb_bind_phy("musb-hdrc.0.auto", 0, "twl4030_usb");
+	phy_bind("musb-hdrc.0.auto", 0, "twl4030_usb");
 	usb_musb_init(NULL);
 	gpmc_nand_init(&pandora_nand_data, NULL);
 
diff --git a/arch/arm/mach-omap2/board-omap3stalker.c b/arch/arm/mach-omap2/board-omap3stalker.c
index 63cb204..8f22977 100644
--- a/arch/arm/mach-omap2/board-omap3stalker.c
+++ b/arch/arm/mach-omap2/board-omap3stalker.c
@@ -34,6 +34,7 @@
 #include <linux/smsc911x.h>
 #include <linux/i2c/at24.h>
 #include <linux/usb/phy.h>
+#include <linux/phy/phy.h>
 
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
@@ -406,6 +407,7 @@ static void __init omap3_stalker_init(void)
 	omap_serial_init();
 	omap_sdrc_init(mt46h32m32lf6_sdrc_params, NULL);
 	usb_bind_phy("musb-hdrc.0.auto", 0, "twl4030_usb");
+	phy_bind("musb-hdrc.0.auto", 0, "twl4030_usb");
 	usb_musb_init(NULL);
 	usbhs_init(&usbhs_bdata);
 	omap_ads7846_init(1, OMAP3_STALKER_TS_GPIO, 310, NULL);
diff --git a/arch/arm/mach-omap2/board-omap3touchbook.c b/arch/arm/mach-omap2/board-omap3touchbook.c
index 6b22ce3..acd82e4 100644
--- a/arch/arm/mach-omap2/board-omap3touchbook.c
+++ b/arch/arm/mach-omap2/board-omap3touchbook.c
@@ -29,6 +29,7 @@
 #include <linux/mtd/nand.h>
 #include <linux/mmc/host.h>
 #include <linux/usb/phy.h>
+#include <linux/phy/phy.h>
 
 #include <linux/platform_data/spi-omap2-mcspi.h>
 #include <linux/spi/spi.h>
@@ -367,6 +368,7 @@ static void __init omap3_touchbook_init(void)
 	/* Touchscreen and accelerometer */
 	omap_ads7846_init(4, OMAP3_TS_GPIO, 310, &ads7846_pdata);
 	usb_bind_phy("musb-hdrc.0.auto", 0, "twl4030_usb");
+	phy_bind("musb-hdrc.0.auto", 0, "twl4030_usb");
 	usb_musb_init(NULL);
 	usbhs_init(&usbhs_bdata);
 	board_nand_init(omap3touchbook_nand_partitions,
diff --git a/arch/arm/mach-omap2/board-omap4panda.c b/arch/arm/mach-omap2/board-omap4panda.c
index 40184cc..7fe4363 100644
--- a/arch/arm/mach-omap2/board-omap4panda.c
+++ b/arch/arm/mach-omap2/board-omap4panda.c
@@ -31,6 +31,7 @@
 #include <linux/ti_wilink_st.h>
 #include <linux/usb/musb.h>
 #include <linux/usb/phy.h>
+#include <linux/phy/phy.h>
 #include <linux/wl12xx.h>
 #include <linux/platform_data/omap-abe-twl6040.h>
 
@@ -449,6 +450,7 @@ static void __init omap4_panda_init(void)
 	omap4_twl6030_hsmmc_init(mmc);
 	omap4_ehci_init();
 	usb_bind_phy("musb-hdrc.0.auto", 0, "omap-usb2.1.auto");
+	phy_bind("musb-hdrc.0.auto", 0, "omap-usb2.1.auto");
 	usb_musb_init(&musb_board_data);
 	omap4_panda_display_init();
 }
diff --git a/arch/arm/mach-omap2/board-overo.c b/arch/arm/mach-omap2/board-overo.c
index 7e43ff3..92835cc 100644
--- a/arch/arm/mach-omap2/board-overo.c
+++ b/arch/arm/mach-omap2/board-overo.c
@@ -37,6 +37,7 @@
 #include <linux/mtd/partitions.h>
 #include <linux/mmc/host.h>
 #include <linux/usb/phy.h>
+#include <linux/phy/phy.h>
 
 #include <linux/platform_data/mtd-nand-omap2.h>
 #include <linux/platform_data/spi-omap2-mcspi.h>
@@ -501,6 +502,7 @@ static void __init overo_init(void)
 	board_nand_init(overo_nand_partitions,
 			ARRAY_SIZE(overo_nand_partitions), NAND_CS, 0, NULL);
 	usb_bind_phy("musb-hdrc.0.auto", 0, "twl4030_usb");
+	phy_bind("musb-hdrc.0.auto", 0, "twl4030_usb");
 	usb_musb_init(NULL);
 	usbhs_init(&usbhs_bdata);
 	overo_spi_init();
diff --git a/arch/arm/mach-omap2/board-rm680.c b/arch/arm/mach-omap2/board-rm680.c
index f8a272c..ed854ca 100644
--- a/arch/arm/mach-omap2/board-rm680.c
+++ b/arch/arm/mach-omap2/board-rm680.c
@@ -19,6 +19,7 @@
 #include <linux/regulator/consumer.h>
 #include <linux/platform_data/mtd-onenand-omap2.h>
 #include <linux/usb/phy.h>
+#include <linux/phy/phy.h>
 
 #include <asm/mach/arch.h>
 #include <asm/mach-types.h>
@@ -136,6 +137,7 @@ static void __init rm680_init(void)
 	omap_sdrc_init(sdrc_params, sdrc_params);
 
 	usb_bind_phy("musb-hdrc.0.auto", 0, "twl4030_usb");
+	phy_bind("musb-hdrc.0.auto", 0, "twl4030_usb");
 	usb_musb_init(NULL);
 	rm680_peripherals_init();
 }
diff --git a/arch/arm/mach-omap2/board-zoom-peripherals.c b/arch/arm/mach-omap2/board-zoom-peripherals.c
index dc5498b..2093e25 100644
--- a/arch/arm/mach-omap2/board-zoom-peripherals.c
+++ b/arch/arm/mach-omap2/board-zoom-peripherals.c
@@ -21,6 +21,7 @@
 #include <linux/mmc/host.h>
 #include <linux/platform_data/gpio-omap.h>
 #include <linux/usb/phy.h>
+#include <linux/phy/phy.h>
 
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
@@ -300,6 +301,7 @@ void __init zoom_peripherals_init(void)
 	omap_i2c_init();
 	platform_device_register(&omap_vwlan_device);
 	usb_bind_phy("musb-hdrc.0.auto", 0, "twl4030_usb");
+	phy_bind("musb-hdrc.0.auto", 0, "twl4030_usb");
 	usb_musb_init(NULL);
 	enable_board_wakeup_source();
 	omap_serial_init();
-- 
1.7.10.4
