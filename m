From: Mathieu Olivari <mathieu@codeaurora.org>
Subject: [PATCH V2 5/5] net: stmmac: ipq806x: document device tree bindings
Date: Wed, 27 May 2015 11:02:50 -0700
Message-ID: <1432749770-26133-6-git-send-email-mathieu@codeaurora.org>
References: <1432749770-26133-1-git-send-email-mathieu@codeaurora.org>
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-clk@vger.kernel.org, netdev@vger.kernel.org
To: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	mturquette@linaro.org, sboyd@codeaurora.org,
	peppe.cavallaro@st.com, mathieu@codeaurora.org,
	agross@codeaurora.org, joshc@codeaurora.org,
	architt@codeaurora.org, georgi.djakov@linaro.org,
	wsa@the-dreams.de, rnayak@codeaurora.org, davem@davemloft.net,
	vbridger@opensource.altera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:45646 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753098AbbE0SDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 14:03:30 -0400
In-Reply-To: <1432749770-26133-1-git-send-email-mathieu@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the device tree bindings documentation for the QCA IPQ806x
variant of the Synopsys DesignWare MAC.

Signed-off-by: Mathieu Olivari <mathieu@codeaurora.org>
---
 .../devicetree/bindings/net/ipq806x-dwmac.txt      | 35 ++++++++++++++++++++++
 1 file changed, 35 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/ipq806x-dwmac.txt

diff --git a/Documentation/devicetree/bindings/net/ipq806x-dwmac.txt b/Documentation/devicetree/bindings/net/ipq806x-dwmac.txt
new file mode 100644
index 0000000..6d7ab4e
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/ipq806x-dwmac.txt
@@ -0,0 +1,35 @@
+* IPQ806x DWMAC Ethernet controller
+
+The device inherits all the properties of the dwmac/stmmac devices
+described in the file net/stmmac.txt with the following changes.
+
+Required properties:
+
+- compatible: should be "qcom,ipq806x-gmac" along with "snps,dwmac"
+	      and any applicable more detailed version number
+	      described in net/stmmac.txt
+
+- qcom,nss-common: should contain a phandle to a syscon device mapping the
+		   nss-common registers.
+
+- qcom,qsgmii-csr: should contain a phandle to a syscon device mapping the
+		   qsgmii-csr registers.
+
+Example:
+
+	gmac: ethernet@37000000 {
+		device_type = "network";
+		compatible = "qcom,ipq806x-gmac";
+		reg = <0x37000000 0x200000>;
+		interrupts = <GIC_SPI 220 IRQ_TYPE_LEVEL_HIGH>;
+		interrupt-names = "macirq";
+
+		qcom,nss-common = <&nss_common>;
+		qcom,qsgmii-csr = <&qsgmii_csr>;
+
+		clocks = <&gcc GMAC_CORE1_CLK>;
+		clock-names = "stmmaceth";
+
+		resets = <&gcc GMAC_CORE1_RESET>;
+		reset-names = "stmmaceth";
+	};
-- 
2.1.4
