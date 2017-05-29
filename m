From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v8 net-next 13/17] dt-bindings: qca7000-spi: Rework binding
Date: Mon, 29 May 2017 13:57:21 +0200
Message-ID: <1496059045-13572-14-git-send-email-stefan.wahren@i2se.com>
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

In preparation for the QCA7000 UART binding rework the binding document.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 .../devicetree/bindings/net/qca-qca7000-spi.txt    | 49 +++++++++++++---------
 1 file changed, 29 insertions(+), 20 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/qca-qca7000-spi.txt b/Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
index c74989c..a37f656 100644
--- a/Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
+++ b/Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
@@ -1,29 +1,38 @@
-* Qualcomm QCA7000 (Ethernet over SPI protocol)
+* Qualcomm QCA7000
 
-Note: The QCA7000 is useable as a SPI device. In this case it must be defined
-as a child of a SPI master in the device tree.
+The QCA7000 is a serial-to-powerline bridge with a host interface which could
+be configured either as SPI or UART slave. This configuration is done by
+the QCA7000 firmware.
+
+(a) Ethernet over SPI
+
+In order to use the QCA7000 as SPI device it must be defined as a child of a
+SPI master in the device tree.
 
 Required properties:
-- compatible : Should be "qca,qca7000"
-- reg : Should specify the SPI chip select
-- interrupts : The first cell should specify the index of the source interrupt
-  and the second cell should specify the trigger type as rising edge
-- spi-cpha : Must be set
-- spi-cpol: Must be set
+- compatible	    : Should be "qca,qca7000"
+- reg		    : Should specify the SPI chip select
+- interrupts	    : The first cell should specify the index of the source
+		      interrupt and the second cell should specify the trigger
+		      type as rising edge
+- spi-cpha	    : Must be set
+- spi-cpol	    : Must be set
 
 Optional properties:
-- interrupt-parent : Specify the pHandle of the source interrupt
+- interrupt-parent  : Specify the pHandle of the source interrupt
 - spi-max-frequency : Maximum frequency of the SPI bus the chip can operate at.
-  Numbers smaller than 1000000 or greater than 16000000 are invalid. Missing
-  the property will set the SPI frequency to 8000000 Hertz.
-- local-mac-address: 6 bytes, MAC address
-- qca,legacy-mode : Set the SPI data transfer of the QCA7000 to legacy mode.
-  In this mode the SPI master must toggle the chip select between each data
-  word. In burst mode these gaps aren't necessary, which is faster.
-  This setting depends on how the QCA7000 is setup via GPIO pin strapping.
-  If the property is missing the driver defaults to burst mode.
-
-Example:
+		      Numbers smaller than 1000000 or greater than 16000000
+		      are invalid. Missing the property will set the SPI
+		      frequency to 8000000 Hertz.
+- local-mac-address : see ./ethernet.txt
+- qca,legacy-mode   : Set the SPI data transfer of the QCA7000 to legacy mode.
+		      In this mode the SPI master must toggle the chip select
+		      between each data word. In burst mode these gaps aren't
+		      necessary, which is faster. This setting depends on how
+		      the QCA7000 is setup via GPIO pin strapping. If the
+		      property is missing the driver defaults to burst mode.
+
+SPI Example:
 
 /* Freescale i.MX28 SPI master*/
 ssp2: spi@80014000 {
-- 
2.1.4
