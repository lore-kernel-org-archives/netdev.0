From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCH RFC 1/3] net: dt-bindings: add the amlogic,meson8b-dwmac binding
Date: Sat, 25 Jun 2016 18:50:11 +0200
Message-ID: <20160625165013.15917-2-martin.blumenstingl@googlemail.com>
References: <20160625165013.15917-1-martin.blumenstingl@googlemail.com>
Cc: carlo@caione.org, khilman@baylibre.com, robh+dt@kernel.org,
	mark.rutland@arm.com, netdev@vger.kernel.org,
	peppe.cavallaro@st.com,
	Martin Blumenstingl <martin.blumenstingl@googlemail.com>
To: linux-amlogic@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34432 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390AbcFYQuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2016 12:50:24 -0400
Received: by mail-wm0-f67.google.com with SMTP id 187so13358668wmz.1
        for <netdev@vger.kernel.org>; Sat, 25 Jun 2016 09:50:23 -0700 (PDT)
In-Reply-To: <20160625165013.15917-1-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the documentation for the DWMAC ethernet controller
found in Amlogic Meson 8b (S805) and GXBB (S905) SoCs.
Compared to the standard stmmac/dwmac configuration this requires some
some additional parameters for configuring the clock-generator
depending on the actual ethernet PHY on the board.

Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
---
 .../bindings/net/amlogic,meson8b-dwmac.txt         | 44 ++++++++++++++++++++++
 1 file changed, 44 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/amlogic,meson8b-dwmac.txt

diff --git a/Documentation/devicetree/bindings/net/amlogic,meson8b-dwmac.txt b/Documentation/devicetree/bindings/net/amlogic,meson8b-dwmac.txt
new file mode 100644
index 0000000..4164753e
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/amlogic,meson8b-dwmac.txt
@@ -0,0 +1,44 @@
+* Amlogic Meson 8b/GXBB DWMAC Ethernet controller
+
+The device inherits all the properties of the dwmac/stmmac devices
+described in the file net/stmmac.txt with the following changes.
+
+Required properties:
+- compatible: should be "amlogic,meson8b-dwmac" along with "snps,dwmac"
+	      and any applicable more detailed version number
+	      described in net/stmmac.txt
+- prg-ethernet: should contain a phandle to a syscon device mapping the
+		PRG_ETHERNET registers.
+
+
+Optional properties:
+- amlogic,enable-tx-phy-ref-clk: Enables the TX_CLK and PHY_REF_CLK
+				 clock generator.
+- amlogic,mp2-clock: Sets the frequency for the mp2_clk_out clock. See
+		     the MESON8B_DWMAC_MP2_CLOCK_* definitions in
+		     "include/dt-bindings/net/amlogic-meson8b-dwmac.h".
+- amlogic,tx-delay: Configures the TX clock delay. See the
+		    MESON8B_DWMAC_TX_CLK_DELAY_* definitions in
+		    "include/dt-bindings/net/amlogic-meson8b-dwmac.h".
+
+
+Example:
+
+#include <dt-bindings/net/amlogic-meson8b-dwmac.h>
+
+	gmac: ethernet@37000000 {
+		compatible = "amlogic,meson8b-dwmac", "snps,dwmac";
+		reg = <0x0 0xc9410000 0x0 0x10000>;
+		interrupts = <0 8 1>;
+		interrupt-names = "macirq";
+
+		clocks = <&clkc CLKID_ETH>;
+		clock-names = "stmmaceth";
+
+		phy-mode = "rgmii";
+		
+		amlogic,prg-ethernet = <&prg_ethernet>;
+		amlogic,enable-25mhz-phy-clk;
+		amlogic,mp2-clock = <MESON8B_DWMAC_MP2_CLOCK_1000MHZ>;
+		amlogic,tx-delay = <MESON8B_DWMAC_TX_CLK_DELAY_QUARTER_CYCLE>;
+	};
-- 
2.9.0
