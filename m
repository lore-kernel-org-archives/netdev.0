From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH RFC 1/2] Documentation: add Device tree bindings for QCA7000
Date: Mon, 28 Apr 2014 19:54:56 +0200
Message-ID: <1398707697-43785-2-git-send-email-stefan.wahren@i2se.com>
References: <1398707697-43785-1-git-send-email-stefan.wahren@i2se.com>
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: davem@davemloft.net, robh+dt@kernel.org, pawel.moll@arm.org,
	mark.rutland@arm.org, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:56913 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755551AbaD1Tnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 15:43:45 -0400
In-Reply-To: <1398707697-43785-1-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the Device tree bindings for the Ethernet over SPI
protocol driver of the Qualcomm QCA7000 HomePlug GreenPHY.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 .../devicetree/bindings/net/qca-qca7000-spi.txt    |   51 ++++++++++++++++++++
 1 file changed, 51 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/qca-qca7000-spi.txt

diff --git a/Documentation/devicetree/bindings/net/qca-qca7000-spi.txt b/Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
new file mode 100644
index 0000000..132c10f
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
@@ -0,0 +1,51 @@
+* Qualcomm QCA7000 (Ethernet over SPI protocol)
+
+Note: The QCA7000 is useable as a SPI device. In this case it must be defined
+as a child of a spi master in the device tree.
+
+Required properties:
+- compatible : Should be "qca,qca7000"
+- reg : Should specify the SPI chip select
+- intr-gpios : Should specify the GPIO for SPI interrupt
+- spi-cpha : Must be set
+- spi-cpol: Must be set
+
+Optional properties:
+- spi-max-frequency : Maximum frequency of the SPI bus the chip can operate at.
+  Numbers smaller than 1000000 or greater than 16000000 are invalid. Missing
+  the property will set the SPI frequency to 8000000 Hertz.
+- local-mac-address: 6 bytes, mac address
+- qca,legacy-mode : Should specify the data transfer mode of the QCA7000
+  (0 = burst mode, 1 = legacy mode). Missing the property will use the
+  burst mode.
+- linux,burst-length : Number of data bytes per burst. Numbers smaller than 1
+  or greater than 5000 are invalid. Missing the property will set the
+  burst length to 5000 bytes. This property has only an effect in burst mode.
+- linux,pluggable-connection : Should be set to skip signature check while
+  probing. This property is useful if the SPI master and QCA7000 are not on the
+  same board.
+
+Example:
+
+/* Freescale i.MX28 SPI master*/
+ssp2: ssp@80014000 {
+	#address-cells = <1>;
+	#size-cells = <0>;
+	compatible = "fsl,imx28-spi";
+	pinctrl-names = "default";
+	pinctrl-0 = <&spi2_pins_a>;
+	status = "okay";
+
+	qca7000@0 {
+		compatible = "qca,qca7000";
+		reg = <0x0>;
+		spi-cpha;                         /* SPI mode: CPHA=1 */
+		spi-cpol;                         /* SPI mode: CPOL=1 */
+		spi-max-frequency = <8000000>;    /* freq: 8 MHz */
+		intr-gpios = <&gpio3 25 0>;       /* GPIO3_25 */
+		qca,legacy-mode = <0>;            /* Burst mode */
+		local-mac-address = [ A0 B0 C0 D0 E0 F0 ];
+		linux,burst-length = <5000>;
+		linux,pluggable-connection;
+	};
+};
-- 
1.7.10.4
