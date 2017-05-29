From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v8 net-next 16/17] dt-bindings: qca7000: append UART interface to binding
Date: Mon, 29 May 2017 13:57:24 +0200
Message-ID: <1496059045-13572-17-git-send-email-stefan.wahren@i2se.com>
References: <1496059045-13572-1-git-send-email-stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Jakub Kicinski <kubakici@wp.pl>, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496059045-13572-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This merges the serdev binding for the QCA7000 UART driver (Ethernet over
UART) into the existing document.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 .../devicetree/bindings/net/qca,qca7000.txt        | 32 ++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/qca,qca7000.txt b/Documentation/devicetree/bindings/net/qca,qca7000.txt
index a37f656..6d9efb2 100644
--- a/Documentation/devicetree/bindings/net/qca,qca7000.txt
+++ b/Documentation/devicetree/bindings/net/qca,qca7000.txt
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
+- compatible        : Should be "qca,qca7000"
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
+		compatible = "qca,qca7000";
+		local-mac-address = [ A0 B0 C0 D0 E0 F0 ];
+		current-speed = <38400>;
+	};
+};
-- 
2.1.4
