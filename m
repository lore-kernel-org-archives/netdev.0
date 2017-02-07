From: Chris Packham <chris.packham@alliedtelesis.co.nz>
Subject: [PATCH v2 2/6] ARM: dts: armada-xp-98dx3236: combine dfx server nodes
Date: Wed,  8 Feb 2017 09:28:11 +1300
Message-ID: <20170207202815.20226-3-chris.packham@alliedtelesis.co.nz>
References: <20170207202815.20226-1-chris.packham@alliedtelesis.co.nz>
Cc: Chris Packham <chris.packham@alliedtelesis.co.nz>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Russell King <linux@armlinux.org.uk>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170207202815.20226-1-chris.packham@alliedtelesis.co.nz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rather than having a separate node for the dfx server add a reg property
to the parent node. This give somes compatibility with the Marvell
supplied SDK.

Signed-off-by: Chris Packham <chris.packham@alliedtelesis.co.nz>
---

Notes:
    Changes in v2:
    - none

 Documentation/devicetree/bindings/net/marvell,prestera.txt | 13 +++++--------
 arch/arm/boot/dts/armada-xp-98dx3236.dtsi                  |  8 ++------
 2 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/marvell,prestera.txt b/Documentation/devicetree/bindings/net/marvell,prestera.txt
index 5fbab29718e8..c329608fa887 100644
--- a/Documentation/devicetree/bindings/net/marvell,prestera.txt
+++ b/Documentation/devicetree/bindings/net/marvell,prestera.txt
@@ -32,19 +32,16 @@ DFX Server bindings
 -------------------
 
 Required properties:
-- compatible: must be "marvell,dfx-server"
+- compatible: must be "marvell,dfx-server", "simple-bus"
+- ranges: describes the address mapping of a memory-mapped bus.
 - reg: address and length of the register set for the device.
 
 Example:
 
-dfx-registers {
-	compatible = "simple-bus";
+dfx-server {
+	compatible = "marvell,dfx-server", "simple-bus";
 	#address-cells = <1>;
 	#size-cells = <1>;
 	ranges = <0 MBUS_ID(0x08, 0x00) 0 0x100000>;
-
-	dfx: dfx@0 {
-		compatible = "marvell,dfx-server";
-		reg = <0 0x100000>;
-	};
+	reg = <MBUS_ID(0x08, 0x00) 0 0x100000>;
 };
diff --git a/arch/arm/boot/dts/armada-xp-98dx3236.dtsi b/arch/arm/boot/dts/armada-xp-98dx3236.dtsi
index f6a03dcee5ef..bd8261fdec81 100644
--- a/arch/arm/boot/dts/armada-xp-98dx3236.dtsi
+++ b/arch/arm/boot/dts/armada-xp-98dx3236.dtsi
@@ -195,11 +195,12 @@
 			};
 		};
 
-		dfxr: dfx-registers@ac000000 {
+		dfx: dfx-server@ac000000 {
 			compatible = "simple-bus";
 			#address-cells = <1>;
 			#size-cells = <1>;
 			ranges = <0 MBUS_ID(0x08, 0x00) 0 0x100000>;
+			reg = <MBUS_ID(0x08, 0x00) 0 0x100000>;
 
 			dfx_coredivclk: corediv-clock@f8268 {
 				compatible = "marvell,mv98dx3236-corediv-clock";
@@ -208,11 +209,6 @@
 				clocks = <&mainpll>;
 				clock-output-names = "nand";
 			};
-
-			dfx: dfx@0 {
-				compatible = "marvell,dfx-server";
-				reg = <0 0x100000>;
-			};
 		};
 
 		switch: switch@a8000000 {
-- 
2.11.0.24.ge6920cf
