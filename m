From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v2 09/10] arm64: dts: marvell: add a reference to the sysctrl syscon in the ppv2 node
Date: Tue, 22 Aug 2017 19:08:29 +0200
Message-ID: <20170822170830.32413-10-antoine.tenart@free-electrons.com>
References: <20170822170830.32413-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:38567 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751716AbdHVRIv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 13:08:51 -0400
In-Reply-To: <20170822170830.32413-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The network driver on Marvell SoC (7k/8k) needs to access some registers
in the system controller to configure its ports at runtime. This patch
adds a phandle reference to the syscon system controller node in the
ppv2 node.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
Tested-by: Marcin Wojtas <mw@semihalf.com>
---
 arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi | 1 +
 arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi  | 1 +
 2 files changed, 2 insertions(+)

diff --git a/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi b/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi
index 4c68605675a8..18299e164cb7 100644
--- a/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi
+++ b/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi
@@ -65,6 +65,7 @@
 				reg = <0x0 0x100000>, <0x129000 0xb000>;
 				clocks = <&cpm_clk 1 3>, <&cpm_clk 1 9>, <&cpm_clk 1 5>;
 				clock-names = "pp_clk", "gop_clk", "mg_clk";
+				marvell,system-controller = <&cpm_syscon0>;
 				status = "disabled";
 				dma-coherent;
 
diff --git a/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi b/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
index 923f354b02f0..5ae8fa575859 100644
--- a/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
+++ b/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
@@ -72,6 +72,7 @@
 				reg = <0x0 0x100000>, <0x129000 0xb000>;
 				clocks = <&cps_clk 1 3>, <&cps_clk 1 9>, <&cps_clk 1 5>;
 				clock-names = "pp_clk", "gop_clk", "mg_clk";
+				marvell,system-controller = <&cps_syscon0>;
 				status = "disabled";
 				dma-coherent;
 
-- 
2.13.5
