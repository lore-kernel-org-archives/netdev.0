From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v5 15/17] dt-bindings: qca7000: append UART interface to binding
Date: Wed, 10 May 2017 10:53:26 +0200
Message-ID: <1494406408-31760-16-git-send-email-stefan.wahren@i2se.com>
References: <1494406408-31760-1-git-send-email-stefan.wahren@i2se.com>
Cc: Mark Rutland <mark.rutland@arm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1494406408-31760-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This merges the serdev binding for the QCA7000 UART driver (Ethernet over
UART) into the existing document.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 .../devicetree/bindings/net/qca-qca7000.txt        | 32 ++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/qca-qca7000.txt b/Documentation/devicetree/bindings/net/qca-qca7000.txt
index a37f656..08364c3 100644
--- a/Documentation/devicetree/bindings/net/qca-qca7000.txt
+++ b/Documentation/devicetree/bindings/net/qca-qca7000.txt
@@ -54,3 +54,35 @@ ssp2: spi@80014000 {
 		local-mac-address = [ A0 B0 C0 D0 E0 F0 ];
 	};
 };
+
+(b) Ethernet over UART
+
+In order to use the QCA7000 as UART slave it must be defined as a child of a
+UART master in the device tree. It is possible to preconfigure the UART
+settings of the QCA7000 firmware, but it's not possible to change them during
+runtime.
+
+Required properties:
+- compatible        : Should be "qca,qca7000-uart"
+
+Optional properties:
+- local-mac-address : see ./ethernet.txt
+- current-speed     : current baud rate of QCA7000 which defaults to 115200
+		      if absent, see also ../serial/slave-device.txt
+
+UART Example:
+
+/* Freescale i.MX28 UART */
+auart0: serial@8006a000 {
+	compatible = "fsl,imx28-auart", "fsl,imx23-auart";
+	reg = <0x8006a000 0x2000>;
+	pinctrl-names = "default";
+	pinctrl-0 = <&auart0_2pins_a>;
+	status = "okay";
+
+	qca7000: ethernet {
+		compatible = "qca,qca7000-uart";
+		local-mac-address = [ A0 B0 C0 D0 E0 F0 ];
+		current-speed = <38400>;
+	};
+};
-- 
2.1.4
