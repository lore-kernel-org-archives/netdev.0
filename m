From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCH v5 5/6] ARM64: dts: meson-gxbb: use the new GXBB DWMAC glue driver
Date: Tue,  6 Sep 2016 23:38:47 +0200
Message-ID: <20160906213848.17785-6-martin.blumenstingl@googlemail.com>
References: <20160904182320.671-1-martin.blumenstingl@googlemail.com>
 <20160906213848.17785-1-martin.blumenstingl@googlemail.com>
Cc: robh+dt@kernel.org, mark.rutland@arm.com, catalin.marinas@arm.com,
        will.deacon@arm.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        sboyd@codeaurora.org, manabian@gmail.com, arnd@arndb.de,
        davem@davemloft.net, b.galvani@gmail.com,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>
To: linux-amlogic@lists.infradead.org, khilman@baylibre.com,
        carlo@caione.org, mturquette@baylibre.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33459 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754980AbcIFVjo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 17:39:44 -0400
In-Reply-To: <20160906213848.17785-1-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Amlogic reference driver uses the "mc_val" devicetree property to
configure the PRG_ETHERNET_ADDR0 register. Unfortunately it uses magic
values for this configuration.
According to the datasheet the PRG_ETHERNET_ADDR0 register is at address
0xc8834108. However, the reference driver uses 0xc8834540 instead.
According to my tests, the value from the reference driver is correct.

No changes are required to the board dts files because the only
required configuration option is the phy-mode, which had to be
configured correctly before as well.

Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
---
 arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi b/arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi
index 2b47415..2e8a3d9 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi
+++ b/arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi
@@ -497,13 +497,15 @@
 		};
 
 		ethmac: ethernet@c9410000 {
-			compatible = "amlogic,meson6-dwmac", "snps,dwmac";
+			compatible = "amlogic,meson-gxbb-dwmac", "snps,dwmac";
 			reg = <0x0 0xc9410000 0x0 0x10000
 			       0x0 0xc8834540 0x0 0x4>;
 			interrupts = <0 8 1>;
 			interrupt-names = "macirq";
-			clocks = <&clkc CLKID_ETH>;
-			clock-names = "stmmaceth";
+			clocks = <&clkc CLKID_ETH>,
+				 <&clkc CLKID_FCLK_DIV2>,
+				 <&clkc CLKID_MPLL2>;
+			clock-names = "stmmaceth", "clkin0", "clkin1";
 			phy-mode = "rgmii";
 			status = "disabled";
 		};
-- 
2.9.3
