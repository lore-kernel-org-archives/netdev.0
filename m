From: Kishon Vijay Abraham I <kishon@ti.com>
Subject: [PATCH v5 5/6] ARM: dts: omap: update usb_otg_hs data
Date: Wed, 3 Apr 2013 18:23:53 +0530
Message-ID: <1364993634-6378-6-git-send-email-kishon@ti.com>
References: <1364993634-6378-1-git-send-email-kishon@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<cesarb@cesarb.net>, <linux-usb@vger.kernel.org>,
	<linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<tony@atomide.com>, <grant.likely@secretlab.ca>,
	<rob.herring@calxeda.com>, <b-cousson@ti.com>,
	<linux@arm.linux.org.uk>, <eballetbo@gmail.com>,
	<javier@dowhile0.org>, <kishon@ti.com>, <mchehab@redhat.com>,
	<santosh.shilimkar@ti.com>, <broonie@opensource.wolfsonmicro.com>,
	<swarren@nvidia.com>, <linux-doc@vger.kernel.org>,
	<devicetree-discuss@lists.ozlabs.org>,
	<linux-arm-kernel@lists.infradead.org>
To: <balbi@ti.com>, <gregkh@linuxfoundation.org>, <arnd@arndb.de>,
	<akpm@linux-foundation.org>, <swarren@wwwdotorg.org>,
	<sylvester.nawrocki@gmail.com>, <rob@landley.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364993634-6378-1-git-send-email-kishon@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Updated the usb_otg_hs dt data to include the *phy* and *phy-names*
binding in order for the driver to use the new generic PHY framework.
Also updated the Documentation to include the binding information.
The PHY binding information can be found at
Documentation/devicetree/bindings/phy/phy-bindings.txt

Signed-off-by: Kishon Vijay Abraham I <kishon@ti.com>
---
 Documentation/devicetree/bindings/usb/omap-usb.txt |    5 +++++
 Documentation/devicetree/bindings/usb/usb-phy.txt  |    6 ++++++
 arch/arm/boot/dts/omap3.dtsi                       |    2 ++
 arch/arm/boot/dts/omap4.dtsi                       |    3 +++
 arch/arm/boot/dts/twl4030.dtsi                     |    1 +
 5 files changed, 17 insertions(+)

diff --git a/Documentation/devicetree/bindings/usb/omap-usb.txt b/Documentation/devicetree/bindings/usb/omap-usb.txt
index abce256..9324e79 100644
--- a/Documentation/devicetree/bindings/usb/omap-usb.txt
+++ b/Documentation/devicetree/bindings/usb/omap-usb.txt
@@ -19,6 +19,9 @@ OMAP MUSB GLUE
  - power : Should be "50". This signifies the controller can supply upto
    100mA when operating in host mode.
  - usb-phy : the phandle for the PHY device
+ - phys : the phandle for the PHY device (used by generic PHY framework)
+ - phy-names : the names of the PHY corresponding to the PHYs present in the
+   *phy* phandle.
 
 Optional properties:
  - ctrl-module : phandle of the control module this glue uses to write to
@@ -33,6 +36,8 @@ usb_otg_hs: usb_otg_hs@4a0ab000 {
 	num_eps = <16>;
 	ram_bits = <12>;
 	ctrl-module = <&omap_control_usb>;
+	phys = <&usb2_phy>;
+	phy-names = "usb2-phy";
 };
 
 Board specific device node entry
diff --git a/Documentation/devicetree/bindings/usb/usb-phy.txt b/Documentation/devicetree/bindings/usb/usb-phy.txt
index 61496f5..c0245c8 100644
--- a/Documentation/devicetree/bindings/usb/usb-phy.txt
+++ b/Documentation/devicetree/bindings/usb/usb-phy.txt
@@ -5,6 +5,8 @@ OMAP USB2 PHY
 Required properties:
  - compatible: Should be "ti,omap-usb2"
  - reg : Address and length of the register set for the device.
+ - #phy-cells: determine the number of cells that should be given in the
+   phandle while referencing this phy.
 
 Optional properties:
  - ctrl-module : phandle of the control module used by PHY driver to power on
@@ -16,6 +18,7 @@ usb2phy@4a0ad080 {
 	compatible = "ti,omap-usb2";
 	reg = <0x4a0ad080 0x58>;
 	ctrl-module = <&omap_control_usb>;
+	#phy-cells = <0>;
 };
 
 OMAP USB3 PHY
@@ -25,6 +28,8 @@ Required properties:
  - reg : Address and length of the register set for the device.
  - reg-names: The names of the register addresses corresponding to the registers
    filled in "reg".
+ - #phy-cells: determine the number of cells that should be given in the
+   phandle while referencing this phy.
 
 Optional properties:
  - ctrl-module : phandle of the control module used by PHY driver to power on
@@ -39,4 +44,5 @@ usb3phy@4a084400 {
 	      <0x4a084c00 0x40>;
 	reg-names = "phy_rx", "phy_tx", "pll_ctrl";
 	ctrl-module = <&omap_control_usb>;
+	#phy-cells = <0>;
 };
diff --git a/arch/arm/boot/dts/omap3.dtsi b/arch/arm/boot/dts/omap3.dtsi
index 1e21565..dd7d2ff 100644
--- a/arch/arm/boot/dts/omap3.dtsi
+++ b/arch/arm/boot/dts/omap3.dtsi
@@ -405,6 +405,8 @@
 			interrupt-names = "mc", "dma";
 			ti,hwmods = "usb_otg_hs";
 			usb-phy = <&usb2_phy>;
+			phys = <&usb2_phy>;
+			phy-names = "usb2-phy";
 			multipoint = <1>;
 			num-eps = <16>;
 			ram-bits = <12>;
diff --git a/arch/arm/boot/dts/omap4.dtsi b/arch/arm/boot/dts/omap4.dtsi
index 06d044e..64cd000 100644
--- a/arch/arm/boot/dts/omap4.dtsi
+++ b/arch/arm/boot/dts/omap4.dtsi
@@ -442,6 +442,7 @@
 				compatible = "ti,omap-usb2";
 				reg = <0x4a0ad080 0x58>;
 				ctrl-module = <&omap_control_usb>;
+				#phy-cells = <0>;
 			};
 		};
 
@@ -550,6 +551,8 @@
 			interrupt-names = "mc", "dma";
 			ti,hwmods = "usb_otg_hs";
 			usb-phy = <&usb2_phy>;
+			phys = <&usb2_phy>;
+			phy-names = "usb2-phy";
 			multipoint = <1>;
 			num-eps = <16>;
 			ram-bits = <12>;
diff --git a/arch/arm/boot/dts/twl4030.dtsi b/arch/arm/boot/dts/twl4030.dtsi
index 398d2c3..6f71de7 100644
--- a/arch/arm/boot/dts/twl4030.dtsi
+++ b/arch/arm/boot/dts/twl4030.dtsi
@@ -74,5 +74,6 @@
 		usb1v8-supply = <&vusb1v8>;
 		usb3v1-supply = <&vusb3v1>;
 		usb_mode = <1>;
+		#phy-cells = <0>;
 	};
 };
-- 
1.7.10.4
