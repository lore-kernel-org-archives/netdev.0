From: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Subject: [PATCH v11 5/5] powerpc: Fix up fsl-flexcan device tree binding.
Date: Wed, 10 Aug 2011 11:27:50 -0500
Message-ID: <1312993670-23999-6-git-send-email-holt@sgi.com>
References: <1312993670-23999-1-git-send-email-holt@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: , netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>, Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Scott Wood <scottwood-KZfg59tc24x4beGV+Eop3g@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1312993670-23999-1-git-send-email-holt-sJ/iWh9BUns@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch cleans up the documentation of the device-tree binding for
the Flexcan devices on Freescale's PowerPC and ARM cores. Extra
properties are not needed as the frequency of the source clock is
fixed, there is not external divider beyond what the driver already
works with, and the clock source can not be selected.

Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
To: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
To: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
Cc: PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
---
 .../devicetree/bindings/net/can/fsl-flexcan.txt    |   70 ++++----------------
 arch/powerpc/boot/dts/p1010rdb.dts                 |   10 +--
 arch/powerpc/boot/dts/p1010si.dtsi                 |   10 +--
 3 files changed, 19 insertions(+), 71 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt b/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
index 1a729f0..869f4ca 100644
--- a/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
+++ b/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
@@ -1,61 +1,17 @@
-CAN Device Tree Bindings
-------------------------
-2011 Freescale Semiconductor, Inc.
+Flexcan CAN contoller on Freescale's ARM and PowerPC processors
 
-fsl,flexcan-v1.0 nodes
------------------------
-In addition to the required compatible-, reg- and interrupt-properties, you can
-also specify which clock source shall be used for the controller.
+Required properties:
 
-CPI Clock- Can Protocol Interface Clock
-	This CLK_SRC bit of CTRL(control register) selects the clock source to
-	the CAN Protocol Interface(CPI) to be either the peripheral clock
-	(driven by the PLL) or the crystal oscillator clock. The selected clock
-	is the one fed to the prescaler to generate the Serial Clock (Sclock).
-	The PRESDIV field of CTRL(control register) controls a prescaler that
-	generates the Serial Clock (Sclock), whose period defines the
-	time quantum used to compose the CAN waveform.
+- compatible : Should be "fsl,flexcan" and optionally
+               "fsl,flexcan-<processor>"
+- reg : Offset and length of the register set for this device
+- interrupts : Interrupt tuple for this device
 
-Can Engine Clock Source
-	There are two sources for CAN clock
-	- Platform Clock  It represents the bus clock
-	- Oscillator Clock
+Example:
 
-	Peripheral Clock (PLL)
-	--------------
-		     |
-		    ---------		      -------------
-		    |       |CPI Clock	      | Prescaler |       Sclock
-		    |       |---------------->| (1.. 256) |------------>
-		    ---------		      -------------
-                     |  |
-	--------------  ---------------------CLK_SRC
-	Oscillator Clock
-
-- fsl,flexcan-clock-source : CAN Engine Clock Source.This property selects
-			     the peripheral clock. PLL clock is fed to the
-			     prescaler to generate the Serial Clock (Sclock).
-			     Valid values are "oscillator" and "platform"
-			     "oscillator": CAN engine clock source is oscillator clock.
-			     "platform" The CAN engine clock source is the bus clock
-		             (platform clock).
-
-- fsl,flexcan-clock-divider : for the reference and system clock, an additional
-			      clock divider can be specified.
-- clock-frequency: frequency required to calculate the bitrate for FlexCAN.
-
-Note:
-	- v1.0 of flexcan-v1.0 represent the IP block version for P1010 SOC.
-	- P1010 does not have oscillator as the Clock Source.So the default
-	  Clock Source is platform clock.
-Examples:
-
-	can0@1c000 {
-		compatible = "fsl,flexcan-v1.0";
-		reg = <0x1c000 0x1000>;
-		interrupts = <48 0x2>;
-		interrupt-parent = <&mpic>;
-		fsl,flexcan-clock-source = "platform";
-		fsl,flexcan-clock-divider = <2>;
-		clock-frequency = <fixed by u-boot>;
-	};
+  can@1c000 {
+          compatible = "fsl,p1010-flexcan", "fsl,flexcan";
+          reg = <0x1c000 0x1000>;
+          interrupts = <48 0x2>;
+          interrupt-parent = <&mpic>;
+  };
diff --git a/arch/powerpc/boot/dts/p1010rdb.dts b/arch/powerpc/boot/dts/p1010rdb.dts
index 6b33b73..d6c669c 100644
--- a/arch/powerpc/boot/dts/p1010rdb.dts
+++ b/arch/powerpc/boot/dts/p1010rdb.dts
@@ -23,6 +23,8 @@
 		ethernet2 = &enet2;
 		pci0 = &pci0;
 		pci1 = &pci1;
+		can0 = &can0;
+		can1 = &can1;
 	};
 
 	memory {
@@ -169,14 +171,6 @@
 			};
 		};
 
-		can0@1c000 {
-			fsl,flexcan-clock-source = "platform";
-		};
-
-		can1@1d000 {
-			fsl,flexcan-clock-source = "platform";
-		};
-
 		usb@22000 {
 			phy_type = "utmi";
 		};
diff --git a/arch/powerpc/boot/dts/p1010si.dtsi b/arch/powerpc/boot/dts/p1010si.dtsi
index 7f51104..f00076b 100644
--- a/arch/powerpc/boot/dts/p1010si.dtsi
+++ b/arch/powerpc/boot/dts/p1010si.dtsi
@@ -140,20 +140,18 @@
 			interrupt-parent = <&mpic>;
 		};
 
-		can0@1c000 {
-			compatible = "fsl,flexcan-v1.0";
+		can0: can@1c000 {
+			compatible = "fsl,p1010-flexcan", "fsl,flexcan";
 			reg = <0x1c000 0x1000>;
 			interrupts = <48 0x2>;
 			interrupt-parent = <&mpic>;
-			fsl,flexcan-clock-divider = <2>;
 		};
 
-		can1@1d000 {
-			compatible = "fsl,flexcan-v1.0";
+		can1: can@1d000 {
+			compatible = "fsl,p1010-flexcan", "fsl,flexcan";
 			reg = <0x1d000 0x1000>;
 			interrupts = <61 0x2>;
 			interrupt-parent = <&mpic>;
-			fsl,flexcan-clock-divider = <2>;
 		};
 
 		L2: l2-cache-controller@20000 {
-- 
1.7.2.1
