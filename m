From: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
Subject: [PATCH v6 net-next 16/17] dt-bindings: qca7000: append UART interface to binding
Date: Tue, 23 May 2017 15:12:52 +0200
Message-ID: <1495545173-22150-17-git-send-email-stefan.wahren@i2se.com>
References: <1495545173-22150-1-git-send-email-stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>,
        Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>,
        Jakub Kicinski <kubakici-5tc4TXWwyLM@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1495545173-22150-1-git-send-email-stefan.wahren-eS4NqCHxEME@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This merges the serdev binding for the QCA7000 UART driver (Ethernet over
UART) into the existing document.

Signed-off-by: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
