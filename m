From: Ian Molton <ian.molton@codethink.co.uk>
Subject: [PATCH v3 6/7] DT: Convert all kirkwood boards with mv643xx that use DT
Date: Tue,  7 Aug 2012 15:34:51 +0100
Message-ID: <1344350092-24050-7-git-send-email-ian.molton@codethink.co.uk>
References: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk>
Cc: andrew@lunn.ch, thomas.petazzoni@free-electrons.com,
	ben.dooks@codethink.co.uk, arnd@arndb.de, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:50825 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754996Ab2HGOfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 10:35:09 -0400
In-Reply-To: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts all present DT capable kirkwood board configurations
to use DT to configure the mv643xx ethernet controller.

Signed-off-by: Ian Molton <ian.molton@codethink.co.uk>
---
 arch/arm/boot/dts/kirkwood-dnskw.dtsi     |    9 +++++++++
 arch/arm/boot/dts/kirkwood-dreamplug.dts  |   18 ++++++++++++++++++
 arch/arm/boot/dts/kirkwood-goflexnet.dts  |    8 ++++++++
 arch/arm/boot/dts/kirkwood-ib62x0.dts     |   10 ++++++++++
 arch/arm/boot/dts/kirkwood-iconnect.dts   |   10 ++++++++++
 arch/arm/boot/dts/kirkwood-lsxl.dtsi      |   17 +++++++++++++++++
 arch/arm/boot/dts/kirkwood-ts219-6281.dts |    8 +++++++-
 arch/arm/boot/dts/kirkwood-ts219-6282.dts |    8 +++++++-
 arch/arm/boot/dts/kirkwood-ts219.dtsi     |    3 +++
 arch/arm/mach-kirkwood/board-dnskw.c      |    7 +------
 arch/arm/mach-kirkwood/board-dreamplug.c  |   13 ++-----------
 arch/arm/mach-kirkwood/board-goflexnet.c  |    7 +------
 arch/arm/mach-kirkwood/board-ib62x0.c     |    7 +------
 arch/arm/mach-kirkwood/board-iconnect.c   |    7 +------
 arch/arm/mach-kirkwood/board-lsxl.c       |   13 ++-----------
 arch/arm/mach-kirkwood/board-ts219.c      |   10 +---------
 16 files changed, 98 insertions(+), 57 deletions(-)

diff --git a/arch/arm/boot/dts/kirkwood-dnskw.dtsi b/arch/arm/boot/dts/kirkwood-dnskw.dtsi
index 7408655..214fe0b 100644
--- a/arch/arm/boot/dts/kirkwood-dnskw.dtsi
+++ b/arch/arm/boot/dts/kirkwood-dnskw.dtsi
@@ -65,5 +65,14 @@
 				reg = <0x7b00000 0x500000>;
 			};
 		};
+
+		smi0: mdio@72000 {
+			status = "ok";
+		};
+
+		egiga0 {
+			phy_addr = <8>;
+			status = "ok";
+		};
 	};
 };
diff --git a/arch/arm/boot/dts/kirkwood-dreamplug.dts b/arch/arm/boot/dts/kirkwood-dreamplug.dts
index 26e281f..c27ed1c 100644
--- a/arch/arm/boot/dts/kirkwood-dreamplug.dts
+++ b/arch/arm/boot/dts/kirkwood-dreamplug.dts
@@ -53,6 +53,24 @@
 			status = "okay";
 			nr-ports = <1>;
 		};
+
+		smi0: mdio@72000 {
+			status = "ok";
+		};
+
+		smi1: mdio@76000 {
+			status = "ok";
+		};
+
+		egiga0 {
+			phy_addr = <0>;
+			status = "ok";
+		};
+
+		egiga1 {
+			phy_addr = <1>;
+			status = "ok";
+		};
 	};
 
 	gpio-leds {
diff --git a/arch/arm/boot/dts/kirkwood-goflexnet.dts b/arch/arm/boot/dts/kirkwood-goflexnet.dts
index 7c8238f..f03dbd0 100644
--- a/arch/arm/boot/dts/kirkwood-goflexnet.dts
+++ b/arch/arm/boot/dts/kirkwood-goflexnet.dts
@@ -50,6 +50,14 @@
 			nr-ports = <2>;
 		};
 
+		smi0: mdio@72000 {
+			status = "ok";
+		};
+
+		egiga0 {
+			phy_addr = <0>;
+			status = "ok";
+		};
 	};
 	gpio-leds {
 		compatible = "gpio-leds";
diff --git a/arch/arm/boot/dts/kirkwood-ib62x0.dts b/arch/arm/boot/dts/kirkwood-ib62x0.dts
index 66794ed..8c462a1 100644
--- a/arch/arm/boot/dts/kirkwood-ib62x0.dts
+++ b/arch/arm/boot/dts/kirkwood-ib62x0.dts
@@ -45,6 +45,16 @@
 			};
 
 		};
+
+		smi0: mdio@72000 {
+			status = "ok";
+		};
+
+		egiga0 {
+			phy_addr = <8>;
+			status = "ok";
+		};
+
 	};
 
 	gpio_keys {
diff --git a/arch/arm/boot/dts/kirkwood-iconnect.dts b/arch/arm/boot/dts/kirkwood-iconnect.dts
index 52d9470..9fc82be 100644
--- a/arch/arm/boot/dts/kirkwood-iconnect.dts
+++ b/arch/arm/boot/dts/kirkwood-iconnect.dts
@@ -30,6 +30,16 @@
 			clock-frequency = <200000000>;
 			status = "ok";
 		};
+
+		smi0: mdio@72000 {
+			status = "ok";
+		};
+
+		egiga0 {
+			phy_addr = <b>;
+			status = "ok";
+		};
+
 	};
 	gpio-leds {
 		compatible = "gpio-leds";
diff --git a/arch/arm/boot/dts/kirkwood-lsxl.dtsi b/arch/arm/boot/dts/kirkwood-lsxl.dtsi
index 8ac51c0..2f47661 100644
--- a/arch/arm/boot/dts/kirkwood-lsxl.dtsi
+++ b/arch/arm/boot/dts/kirkwood-lsxl.dtsi
@@ -40,6 +40,23 @@
 				};
 			};
 		};
+		smi0: mdio@72000 {
+			status = "ok";
+		};
+
+		smi1: mdio@76000 {
+			status = "ok";
+		};
+
+		egiga0 {
+			phy_addr = <0>;
+			status = "ok";
+		};
+
+		egiga1 {
+			phy_addr = <8>;
+			status = "ok";
+		};
 	};
 
 	gpio_keys {
diff --git a/arch/arm/boot/dts/kirkwood-ts219-6281.dts b/arch/arm/boot/dts/kirkwood-ts219-6281.dts
index ccbf327..4ca49b5 100644
--- a/arch/arm/boot/dts/kirkwood-ts219-6281.dts
+++ b/arch/arm/boot/dts/kirkwood-ts219-6281.dts
@@ -3,6 +3,12 @@
 /include/ "kirkwood-ts219.dtsi"
 
 / {
+	ocp@f1000000 {
+		egiga0 {
+			phy_addr = <8>;
+			status = "ok";
+		};
+	};
 	gpio_keys {
 		compatible = "gpio-keys";
 		#address-cells = <1>;
@@ -18,4 +24,4 @@
 			gpios = <&gpio0 16 1>;
 		};
 	};
-};
\ No newline at end of file
+};
diff --git a/arch/arm/boot/dts/kirkwood-ts219-6282.dts b/arch/arm/boot/dts/kirkwood-ts219-6282.dts
index fbe9932..40f3c61 100644
--- a/arch/arm/boot/dts/kirkwood-ts219-6282.dts
+++ b/arch/arm/boot/dts/kirkwood-ts219-6282.dts
@@ -3,6 +3,12 @@
 /include/ "kirkwood-ts219.dtsi"
 
 / {
+	ocp@f1000000 {
+		egiga0 {
+			phy_addr = <0>;
+			status = "ok";
+		};
+	};
 	gpio_keys {
 		compatible = "gpio-keys";
 		#address-cells = <1>;
@@ -18,4 +24,4 @@
 			gpios = <&gpio1 5 1>;
 		};
 	};
-};
\ No newline at end of file
+};
diff --git a/arch/arm/boot/dts/kirkwood-ts219.dtsi b/arch/arm/boot/dts/kirkwood-ts219.dtsi
index 64ea27c..06caf41 100644
--- a/arch/arm/boot/dts/kirkwood-ts219.dtsi
+++ b/arch/arm/boot/dts/kirkwood-ts219.dtsi
@@ -74,5 +74,8 @@
 			status = "okay";
 			nr-ports = <2>;
 		};
+		smi0: mdio@72000 {
+			status = "ok";
+		};
 	};
 };
diff --git a/arch/arm/mach-kirkwood/board-dnskw.c b/arch/arm/mach-kirkwood/board-dnskw.c
index 4ab3506..4d8216b 100644
--- a/arch/arm/mach-kirkwood/board-dnskw.c
+++ b/arch/arm/mach-kirkwood/board-dnskw.c
@@ -15,7 +15,6 @@
 #include <linux/init.h>
 #include <linux/platform_device.h>
 #include <linux/ata_platform.h>
-#include <linux/mv643xx_eth.h>
 #include <linux/of.h>
 #include <linux/gpio.h>
 #include <linux/input.h>
@@ -29,10 +28,6 @@
 #include "common.h"
 #include "mpp.h"
 
-static struct mv643xx_eth_platform_data dnskw_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
-};
-
 static unsigned int dnskw_mpp_config[] __initdata = {
 	MPP13_UART1_TXD,	/* Custom ... */
 	MPP14_UART1_RXD,	/* ... Controller (DNS-320 only) */
@@ -112,7 +107,7 @@ void __init dnskw_init(void)
 	kirkwood_mpp_conf(dnskw_mpp_config);
 
 	kirkwood_ehci_init();
-	kirkwood_ge00_init(&dnskw_ge00_data);
+	kirkwood_ge00_init(NULL);
 
 	platform_device_register(&dnskw_fan_device);
 
diff --git a/arch/arm/mach-kirkwood/board-dreamplug.c b/arch/arm/mach-kirkwood/board-dreamplug.c
index aeb234d..b97a112 100644
--- a/arch/arm/mach-kirkwood/board-dreamplug.c
+++ b/arch/arm/mach-kirkwood/board-dreamplug.c
@@ -15,7 +15,6 @@
 #include <linux/init.h>
 #include <linux/platform_device.h>
 #include <linux/ata_platform.h>
-#include <linux/mv643xx_eth.h>
 #include <linux/of.h>
 #include <linux/of_address.h>
 #include <linux/of_fdt.h>
@@ -34,14 +33,6 @@
 #include "common.h"
 #include "mpp.h"
 
-static struct mv643xx_eth_platform_data dreamplug_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
-};
-
-static struct mv643xx_eth_platform_data dreamplug_ge01_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(1),
-};
-
 static struct mvsdio_platform_data dreamplug_mvsdio_data = {
 	/* unfortunately the CD signal has not been connected */
 };
@@ -65,7 +56,7 @@ void __init dreamplug_init(void)
 	kirkwood_mpp_conf(dreamplug_mpp_config);
 
 	kirkwood_ehci_init();
-	kirkwood_ge00_init(&dreamplug_ge00_data);
-	kirkwood_ge01_init(&dreamplug_ge01_data);
+	kirkwood_ge00_init(NULL);
+	kirkwood_ge01_init(NULL);
 	kirkwood_sdio_init(&dreamplug_mvsdio_data);
 }
diff --git a/arch/arm/mach-kirkwood/board-goflexnet.c b/arch/arm/mach-kirkwood/board-goflexnet.c
index 413e2c8..be7437d 100644
--- a/arch/arm/mach-kirkwood/board-goflexnet.c
+++ b/arch/arm/mach-kirkwood/board-goflexnet.c
@@ -20,7 +20,6 @@
 #include <linux/init.h>
 #include <linux/platform_device.h>
 #include <linux/ata_platform.h>
-#include <linux/mv643xx_eth.h>
 #include <linux/of.h>
 #include <linux/of_address.h>
 #include <linux/of_fdt.h>
@@ -36,10 +35,6 @@
 #include "common.h"
 #include "mpp.h"
 
-static struct mv643xx_eth_platform_data goflexnet_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
-};
-
 static unsigned int goflexnet_mpp_config[] __initdata = {
 	MPP29_GPIO,	/* USB Power Enable */
 	MPP47_GPIO,	/* LED Orange */
@@ -67,5 +62,5 @@ void __init goflexnet_init(void)
 		pr_err("can't setup GPIO 29 (USB Power Enable)\n");
 	kirkwood_ehci_init();
 
-	kirkwood_ge00_init(&goflexnet_ge00_data);
+	kirkwood_ge00_init(NULL);
 }
diff --git a/arch/arm/mach-kirkwood/board-ib62x0.c b/arch/arm/mach-kirkwood/board-ib62x0.c
index cfc47f8..0a29183 100644
--- a/arch/arm/mach-kirkwood/board-ib62x0.c
+++ b/arch/arm/mach-kirkwood/board-ib62x0.c
@@ -16,7 +16,6 @@
 #include <linux/platform_device.h>
 #include <linux/mtd/partitions.h>
 #include <linux/ata_platform.h>
-#include <linux/mv643xx_eth.h>
 #include <linux/gpio.h>
 #include <linux/input.h>
 #include <asm/mach-types.h>
@@ -27,10 +26,6 @@
 
 #define IB62X0_GPIO_POWER_OFF	24
 
-static struct mv643xx_eth_platform_data ib62x0_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
-};
-
 static unsigned int ib62x0_mpp_config[] __initdata = {
 	MPP0_NF_IO2,
 	MPP1_NF_IO3,
@@ -62,7 +57,7 @@ void __init ib62x0_init(void)
 	kirkwood_mpp_conf(ib62x0_mpp_config);
 
 	kirkwood_ehci_init();
-	kirkwood_ge00_init(&ib62x0_ge00_data);
+	kirkwood_ge00_init(NULL);
 	if (gpio_request(IB62X0_GPIO_POWER_OFF, "ib62x0:power:off") == 0 &&
 	    gpio_direction_output(IB62X0_GPIO_POWER_OFF, 0) == 0)
 		pm_power_off = ib62x0_power_off;
diff --git a/arch/arm/mach-kirkwood/board-iconnect.c b/arch/arm/mach-kirkwood/board-iconnect.c
index d7a9198..220f0d4 100644
--- a/arch/arm/mach-kirkwood/board-iconnect.c
+++ b/arch/arm/mach-kirkwood/board-iconnect.c
@@ -17,7 +17,6 @@
 #include <linux/of_irq.h>
 #include <linux/of_platform.h>
 #include <linux/mtd/partitions.h>
-#include <linux/mv643xx_eth.h>
 #include <linux/gpio.h>
 #include <linux/input.h>
 #include <linux/gpio_keys.h>
@@ -26,10 +25,6 @@
 #include "common.h"
 #include "mpp.h"
 
-static struct mv643xx_eth_platform_data iconnect_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(11),
-};
-
 static unsigned int iconnect_mpp_config[] __initdata = {
 	MPP12_GPIO,
 	MPP35_GPIO,
@@ -92,7 +87,7 @@ void __init iconnect_init(void)
 	kirkwood_nand_init(ARRAY_AND_SIZE(iconnect_nand_parts), 25);
 
 	kirkwood_ehci_init();
-	kirkwood_ge00_init(&iconnect_ge00_data);
+	kirkwood_ge00_init(NULL);
 
 	platform_device_register(&iconnect_button_device);
 }
diff --git a/arch/arm/mach-kirkwood/board-lsxl.c b/arch/arm/mach-kirkwood/board-lsxl.c
index 83d8975..60331d1 100644
--- a/arch/arm/mach-kirkwood/board-lsxl.c
+++ b/arch/arm/mach-kirkwood/board-lsxl.c
@@ -18,7 +18,6 @@
 #include <linux/ata_platform.h>
 #include <linux/spi/flash.h>
 #include <linux/spi/spi.h>
-#include <linux/mv643xx_eth.h>
 #include <linux/gpio.h>
 #include <linux/gpio-fan.h>
 #include <linux/input.h>
@@ -28,14 +27,6 @@
 #include "common.h"
 #include "mpp.h"
 
-static struct mv643xx_eth_platform_data lsxl_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
-};
-
-static struct mv643xx_eth_platform_data lsxl_ge01_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
-};
-
 static unsigned int lsxl_mpp_config[] __initdata = {
 	MPP10_GPO,	/* HDD Power Enable */
 	MPP11_GPIO,	/* USB Vbus Enable */
@@ -126,8 +117,8 @@ void __init lsxl_init(void)
 	gpio_set_value(LSXL_GPIO_HDD_POWER, 1);
 
 	kirkwood_ehci_init();
-	kirkwood_ge00_init(&lsxl_ge00_data);
-	kirkwood_ge01_init(&lsxl_ge01_data);
+	kirkwood_ge00_init(NULL);
+	kirkwood_ge01_init(NULL);
 	platform_device_register(&lsxl_fan_device);
 
 	/* register power-off method */
diff --git a/arch/arm/mach-kirkwood/board-ts219.c b/arch/arm/mach-kirkwood/board-ts219.c
index 1750e68..7e7fe6c 100644
--- a/arch/arm/mach-kirkwood/board-ts219.c
+++ b/arch/arm/mach-kirkwood/board-ts219.c
@@ -18,7 +18,6 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/platform_device.h>
-#include <linux/mv643xx_eth.h>
 #include <linux/ata_platform.h>
 #include <linux/gpio_keys.h>
 #include <linux/input.h>
@@ -29,10 +28,6 @@
 #include "mpp.h"
 #include "tsx1x-common.h"
 
-static struct mv643xx_eth_platform_data qnap_ts219_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
-};
-
 static unsigned int qnap_ts219_mpp_config[] __initdata = {
 	MPP0_SPI_SCn,
 	MPP1_SPI_MOSI,
@@ -62,10 +57,7 @@ void __init qnap_dt_ts219_init(void)
 	kirkwood_mpp_conf(qnap_ts219_mpp_config);
 
 	kirkwood_pcie_id(&dev, &rev);
-	if (dev == MV88F6282_DEV_ID)
-		qnap_ts219_ge00_data.phy_addr = MV643XX_ETH_PHY_ADDR(0);
-
-	kirkwood_ge00_init(&qnap_ts219_ge00_data);
+	kirkwood_ge00_init(NULL);
 	kirkwood_ehci_init();
 
 	pm_power_off = qnap_tsx1x_power_off;
-- 
1.7.9.5
