From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH RFC v4 07/10] dt-bindings: net: add binding for QCA7000 UART
Date: Mon, 27 Mar 2017 15:37:25 +0200
Message-ID: <1490621848-24828-8-git-send-email-stefan.wahren@i2se.com>
References: <1490621848-24828-1-git-send-email-stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Marcel Holtmann <marcel@holtmann.org>,
        Sebastian Reichel <sre@kernel.org>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:60234 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752278AbdC0Nkg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 09:40:36 -0400
In-Reply-To: <1490621848-24828-1-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the serdev binding for the QCA7000 UART driver (Ethernet over UART).

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---

According to this binding are still some questions:

Where should be the optional hardware flow control defined (at master or slave side)?

Is it okay to have two bindings (qca-qca7000-spi and qca-qca7000-uart) or should they be merged?


 .../devicetree/bindings/net/qca-qca7000-uart.txt   | 31 ++++++++++++++++++++++
 1 file changed, 31 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/qca-qca7000-uart.txt

diff --git a/Documentation/devicetree/bindings/net/qca-qca7000-uart.txt b/Documentation/devicetree/bindings/net/qca-qca7000-uart.txt
new file mode 100644
index 0000000..f2e0450
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/qca-qca7000-uart.txt
@@ -0,0 +1,31 @@
+* Qualcomm QCA7000 (Ethernet over UART protocol)
+
+Note: This binding applies in case the QCA7000 is configured as a
+UART slave device. It is possible to preconfigure the UART settings
+of the QCA7000 firmware, which can't be changed during runtime.
+
+Required properties:
+- compatible        : Should be "qca,qca7000-uart"
+
+Optional properties:
+- local-mac-address : 6 bytes, Specifies MAC address
+- current-speed     : Specifies the serial device speed in
+		      bits per second (default = 115200), which is
+		      predefined by the QCA7000 firmware configuration
+
+Example:
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
