From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: [PATCH 1/3] dt-bindings: net: c_can: Update binding for clock and power-domains property
Date: Wed, 2 Aug 2017 15:18:20 -0500
Message-ID: <20170802201822.11532-2-fcooper@ti.com>
References: <20170802201822.11532-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Franklin S Cooper Jr <fcooper@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <ssantosh@kernel.org>, <linux@armlinux.org.uk>,
        <linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
        <devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170802201822.11532-1-fcooper@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CAN driver uses the clk_get_rate call to determine the frequency of the
functional clock. OMAP based SoCs do not require the clock property since
hwmod already handles creating a "fck" clock thats accessible to drivers.
However, this isn't the case for 66AK2G which makes the clocks property
require for that SoC.

66AK2G requires a new property. Therefore, update the binding to also make
this property requirement clear. Also clarify that for OMAP based SoCs
ti,hwmod is a required property.

Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
---
 Documentation/devicetree/bindings/net/can/c_can.txt | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/can/c_can.txt b/Documentation/devicetree/bindings/net/can/c_can.txt
index 5a1d8b0..2d50425 100644
--- a/Documentation/devicetree/bindings/net/can/c_can.txt
+++ b/Documentation/devicetree/bindings/net/can/c_can.txt
@@ -11,9 +11,20 @@ Required properties:
 - interrupts		: property with a value describing the interrupt
 			  number
 
-Optional properties:
+The following are mandatory properties for DRA7x, AM33xx and AM43xx SoCs only:
 - ti,hwmods		: Must be "d_can<n>" or "c_can<n>", n being the
 			  instance number
+
+The following are mandatory properties for Keystone 2 66AK2G SoCs only:
+- power-domains		: Should contain a phandle to a PM domain provider node
+			  and an args specifier containing the DCAN device id
+			  value. This property is as per the binding,
+			  Documentation/devicetree/bindings/soc/ti/sci-pm-domain.txt
+- clocks		: CAN functional clock phandle. This property is as per the
+			  binding,
+			  Documentation/devicetree/bindings/clock/ti,sci-clk.txt
+
+Optional properties:
 - syscon-raminit	: Handle to system control region that contains the
 			  RAMINIT register, register offset to the RAMINIT
 			  register and the CAN instance number (0 offset).
-- 
2.9.4.dirty
