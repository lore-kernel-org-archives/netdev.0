From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 15/18] arm64: dts: marvell: add a reference to the sysctrl syscon in the ppv2 node
Date: Mon, 24 Jul 2017 15:48:45 +0200
Message-ID: <20170724134848.19330-16-antoine.tenart@free-electrons.com>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47410 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755864AbdGXNuI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 09:50:08 -0400
In-Reply-To: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The network driver on Marvell SoC (7k/8k) needs to access some registers
in the system controller to configure its ports at runtime. This patch
adds a phandle reference to the syscon system controller node in the
ppv2 node.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---

@Dave: Hi! This patch should go through the mvebu tree. Thanks!

 arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi | 1 +
 arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi  | 1 +
 2 files changed, 2 insertions(+)

diff --git a/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi b/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi
index ebbdb3c97b7f..9278ba63b8ee 100644
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
index a9ac5fc6def7..3515817b85f3 100644
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
2.13.3
