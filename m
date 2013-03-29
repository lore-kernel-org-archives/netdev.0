From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/4] ARM: kirkwood: add device node entries for the gigabit interfaces
Date: Fri, 29 Mar 2013 19:14:37 +0100
Message-ID: <1364580879-4297-3-git-send-email-florian@openwrt.org>
References: <1364580879-4297-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@lists.ozlabs.org,
	thomas.petazzoni@free-electrons.com, jm@lentin.co.uk,
	moinejf@free.fr, sebastian.hesselbarth@gmail.com,
	buytenh@wantstofly.org, andrew@lunn.ch, jason@lakedaemon.net,
	grant.likely@secretlab.ca, rob.herring@calxeda.com,
	Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:34624 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756407Ab3C2SO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Mar 2013 14:14:56 -0400
In-Reply-To: <1364580879-4297-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies kirkwood.dtsi to specify the various gigabit
interfaces nodes available on kirkwood devices. They are disabled by
default and should be enabled on a per-board basis. egiga0 and egiga1
aliases are defined for convenience. The mdio node is also present and
should be enabled on a per-board basis as well.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 arch/arm/boot/dts/kirkwood.dtsi |   46 +++++++++++++++++++++++++++++++++++++++
 arch/arm/mach-kirkwood/common.c |    4 ++--
 2 files changed, 48 insertions(+), 2 deletions(-)

diff --git a/arch/arm/boot/dts/kirkwood.dtsi b/arch/arm/boot/dts/kirkwood.dtsi
index fada7e6..e0860f8 100644
--- a/arch/arm/boot/dts/kirkwood.dtsi
+++ b/arch/arm/boot/dts/kirkwood.dtsi
@@ -7,6 +7,8 @@
 	aliases {
 	       gpio0 = &gpio0;
 	       gpio1 = &gpio1;
+	       egiga0 = &egiga0;
+	       egiga1 = &egiga1;
 	};
 	intc: interrupt-controller {
 		compatible = "marvell,orion-intc", "marvell,intc";
@@ -202,5 +204,49 @@
 			clocks = <&gate_clk 4>;
 			status = "disabled";
 		};
+
+		mdio@72004 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "marvell,orion-mdio";
+			reg = <0x72004 0x84>;
+			status = "disabled";
+		};
+
+		ethernet-group@70000 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "marvell,mv643xx-eth-block";
+			reg = <0x70000 0x4000>;
+			tx-csum-limit = <1600>;
+			status = "disabled";
+
+			egiga0: egiga0@0 {
+				device_type = "network";
+				compatible = "marvell,mv643xx-eth";
+				reg = <0>;
+				interrupts = <11>;
+				clocks = <&gate_clk 0>;
+				clock-names = "0";
+			};
+		};
+
+		ethernet-group@74000 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "marvell,mv643xx-eth-block";
+			reg = <0x74000 0x4000>;
+			tx-csum-limit = <1600>;
+			status = "disabled";
+
+			egiga1: egiga1@0 {
+				device_type = "network";
+				compatible = "marvell,mv643xx-eth";
+				reg = <0>;
+				interrupts = <15>;
+				clocks = <&gate_clk 19>;
+				clock-names = "1";
+			};
+		};
 	};
 };
diff --git a/arch/arm/mach-kirkwood/common.c b/arch/arm/mach-kirkwood/common.c
index 49792a0..a606f9f 100644
--- a/arch/arm/mach-kirkwood/common.c
+++ b/arch/arm/mach-kirkwood/common.c
@@ -251,8 +251,8 @@ void __init kirkwood_clk_init(void)
 	/* clkdev entries, mapping clks to devices */
 	orion_clkdev_add(NULL, "orion_spi.0", runit);
 	orion_clkdev_add(NULL, "orion_spi.1", runit);
-	orion_clkdev_add(NULL, MV643XX_ETH_NAME ".0", ge0);
-	orion_clkdev_add(NULL, MV643XX_ETH_NAME ".1", ge1);
+	orion_clkdev_add("0", MV643XX_ETH_NAME ".0", ge0);
+	orion_clkdev_add("1", MV643XX_ETH_NAME ".1", ge1);
 	orion_clkdev_add(NULL, "orion_wdt", tclk);
 	orion_clkdev_add("0", "sata_mv.0", sata0);
 	orion_clkdev_add("1", "sata_mv.0", sata1);
-- 
1.7.10.4
