From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH V5 7/7] arm/dts: am33xx: Add CPSW and MDIO module nodes for AM33XX
Date: Thu, 15 Nov 2012 00:38:00 +0530
Message-ID: <1352920080-6179-8-git-send-email-mugunthanvnm@ti.com>
References: <1352920080-6179-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <b-cousson@ti.com>, <paul@pwsan.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Vaibhav Hiremath <hvaibhav@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1352920080-6179-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add CPSW and MDIO related device tree data for AM33XX.
Also enable them into board/evm dts files by providing
respective phy-id.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
Signed-off-by: Vaibhav Hiremath <hvaibhav@ti.com>
Cc: Benoit Cousson <b-cousson@ti.com>
Acked-by: Peter Korsgaard <jacmet@sunsite.dk>
Acked-by: Richard Cochran <richardcochran@gmail.com>
---
 arch/arm/boot/dts/am335x-bone.dts |    8 ++++++
 arch/arm/boot/dts/am335x-evm.dts  |    8 ++++++
 arch/arm/boot/dts/am33xx.dtsi     |   48 +++++++++++++++++++++++++++++++++++++
 3 files changed, 64 insertions(+), 0 deletions(-)

diff --git a/arch/arm/boot/dts/am335x-bone.dts b/arch/arm/boot/dts/am335x-bone.dts
index c634f87..4fcd218 100644
--- a/arch/arm/boot/dts/am335x-bone.dts
+++ b/arch/arm/boot/dts/am335x-bone.dts
@@ -78,3 +78,11 @@
 		};
 	};
 };
+
+&cpsw_emac0 {
+	phy_id = <&davinci_mdio>, <0>;
+};
+
+&cpsw_emac1 {
+	phy_id = <&davinci_mdio>, <1>;
+};
diff --git a/arch/arm/boot/dts/am335x-evm.dts b/arch/arm/boot/dts/am335x-evm.dts
index 185d632..366d929 100644
--- a/arch/arm/boot/dts/am335x-evm.dts
+++ b/arch/arm/boot/dts/am335x-evm.dts
@@ -118,3 +118,11 @@
 		};
 	};
 };
+
+&cpsw_emac0 {
+	phy_id = <&davinci_mdio>, <0>;
+};
+
+&cpsw_emac1 {
+	phy_id = <&davinci_mdio>, <1>;
+};
diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
index bb31bff..a4615b4 100644
--- a/arch/arm/boot/dts/am33xx.dtsi
+++ b/arch/arm/boot/dts/am33xx.dtsi
@@ -210,5 +210,53 @@
 			interrupt-parent = <&intc>;
 			interrupts = <91>;
 		};
+
+		mac: ethernet@4a100000 {
+			compatible = "ti,cpsw";
+			ti,hwmods = "cpgmac0";
+			cpdma_channels = <8>;
+			ale_entries = <1024>;
+			bd_ram_size = <0x2000>;
+			no_bd_ram = <0>;
+			rx_descs = <64>;
+			mac_control = <0x20>;
+			slaves = <2>;
+			cpts_active_slave = <0>;
+			cpts_clock_mult = <0x80000000>;
+			cpts_clock_shift = <29>;
+			reg = <0x4a100000 0x800
+			       0x4a101200 0x100>;
+			#address-cells = <1>;
+			#size-cells = <1>;
+			interrupt-parent = <&intc>;
+			/*
+			 * c0_rx_thresh_pend
+			 * c0_rx_pend
+			 * c0_tx_pend
+			 * c0_misc_pend
+			 */
+			interrupts = <40 41 42 43>;
+			ranges;
+
+			davinci_mdio: mdio@4a101000 {
+				compatible = "ti,davinci_mdio";
+				#address-cells = <1>;
+				#size-cells = <0>;
+				ti,hwmods = "davinci_mdio";
+				bus_freq = <1000000>;
+				reg = <0x4a101000 0x100>;
+			};
+
+			cpsw_emac0: slave@4a100200 {
+				/* Filled in by U-Boot */
+				mac-address = [ 00 00 00 00 00 00 ];
+			};
+
+			cpsw_emac1: slave@4a100300 {
+				/* Filled in by U-Boot */
+				mac-address = [ 00 00 00 00 00 00 ];
+			};
+
+		};
 	};
 };
-- 
1.7.0.4

