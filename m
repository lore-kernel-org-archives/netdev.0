From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 5/5] arm/dts: am33xx: Add cpsw and mdio module nodes for AM33XX
Date: Mon, 15 Oct 2012 21:16:35 +0200
Message-ID: <b4d88ef79fb0dec95bb598aaf1f15f0a7344c435.1350327325.git.richardcochran@gmail.com>
References: <cover.1350327320.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	Arnd Bergmann <arnd@arndb.de>,
	David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Vaibhav Hiremath <hvaibhav@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:35115 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754488Ab2JOTRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 15:17:19 -0400
Received: by mail-we0-f174.google.com with SMTP id t9so3253058wey.19
        for <netdev@vger.kernel.org>; Mon, 15 Oct 2012 12:17:18 -0700 (PDT)
In-Reply-To: <cover.1350327320.git.richardcochran@gmail.com>
In-Reply-To: <cover.1350327320.git.richardcochran@gmail.com>
References: <cover.1350327320.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>

Add CPSW and MDIO related device tree data for AM33XX.
Also enable them into board/evm dts files by providing
respective phy-id.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
Signed-off-by: Vaibhav Hiremath <hvaibhav@ti.com>
---
 arch/arm/boot/dts/am335x-bone.dts |    8 ++++++
 arch/arm/boot/dts/am335x-evm.dts  |    8 ++++++
 arch/arm/boot/dts/am33xx.dtsi     |   50 +++++++++++++++++++++++++++++++++++++
 3 files changed, 66 insertions(+), 0 deletions(-)

diff --git a/arch/arm/boot/dts/am335x-bone.dts b/arch/arm/boot/dts/am335x-bone.dts
index c634f87..e233cfa 100644
--- a/arch/arm/boot/dts/am335x-bone.dts
+++ b/arch/arm/boot/dts/am335x-bone.dts
@@ -78,3 +78,11 @@
 		};
 	};
 };
+
+&cpsw_emac0 {
+	phy_id = "4a101000.mdio:00";
+};
+
+&cpsw_emac1 {
+	phy_id = "4a101000.mdio:01";
+};
diff --git a/arch/arm/boot/dts/am335x-evm.dts b/arch/arm/boot/dts/am335x-evm.dts
index 185d632..415c3b3 100644
--- a/arch/arm/boot/dts/am335x-evm.dts
+++ b/arch/arm/boot/dts/am335x-evm.dts
@@ -118,3 +118,11 @@
 		};
 	};
 };
+
+&cpsw_emac0 {
+	phy_id = "4a101000.mdio:00";
+};
+
+&cpsw_emac1 {
+	phy_id = "4a101000.mdio:01";
+};
diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
index bb31bff..f6bea04 100644
--- a/arch/arm/boot/dts/am33xx.dtsi
+++ b/arch/arm/boot/dts/am33xx.dtsi
@@ -210,5 +210,55 @@
 			interrupt-parent = <&intc>;
 			interrupts = <91>;
 		};
+
+		mac: ethernet@4A100000 {
+			compatible = "ti,cpsw";
+			ti,hwmods = "cpgmac0";
+			cpdma_channels = <8>;
+			host_port_no = <0>;
+			cpdma_reg_ofs = <0x800>;
+			cpdma_sram_ofs = <0xa00>;
+			ale_reg_ofs = <0xd00>;
+			ale_entries = <1024>;
+			host_port_reg_ofs = <0x108>;
+			hw_stats_reg_ofs = <0x900>;
+			bd_ram_ofs = <0x2000>;
+			bd_ram_size = <0x2000>;
+			no_bd_ram = <0>;
+			rx_descs = <64>;
+			mac_control = <0x20>;
+			slaves = <2>;
+			reg = <0x4a100000 0x800
+				0x4a101200 0x100
+				0x4a101000 0x100>;
+			#address-cells = <1>;
+			#size-cells = <1>;
+			interrupt-parent = <&intc>;
+			/* c0_rx_thresh_pend c0_rx_pend c0_tx_pend c0_misc_pend*/
+			interrupts = <40 41 42 43>;
+			ranges;
+			cpsw_emac0: slave@0 {
+				slave_reg_ofs = <0x208>;
+				sliver_reg_ofs = <0xd80>;
+				/* Filled in by U-Boot */
+				mac-address = [ 00 00 00 00 00 00 ];
+			};
+			cpsw_emac1: slave@1 {
+				slave_reg_ofs = <0x308>;
+				sliver_reg_ofs = <0xdc0>;
+				/* Filled in by U-Boot */
+				mac-address = [ 00 00 00 00 00 00 ];
+			};
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
+		};
 	};
 };
-- 
1.7.2.5
