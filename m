From: Chris Packham <chris.packham-6g8wRflRTwXFdCa3tKVlE6U/zSkkHjvu@public.gmane.org>
Subject: [PATCH v6 4/5] arm: mvebu: Add device tree for 98DX3236 SoCs
Date: Mon, 30 Jan 2017 12:20:34 +1300
Message-ID: <20170129232035.25189-5-chris.packham@alliedtelesis.co.nz>
References: <20170129232035.25189-1-chris.packham@alliedtelesis.co.nz>
Cc: Chris Packham <chris.packham-6g8wRflRTwXFdCa3tKVlE6U/zSkkHjvu@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170129232035.25189-1-chris.packham-6g8wRflRTwXFdCa3tKVlE6U/zSkkHjvu@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The Marvell 98DX3236, 98DX3336, 98DX4521 and variants are switch ASICs
with integrated CPUs. They are similar to the Armada XP SoCs but have
different I/O interfaces.

Signed-off-by: Chris Packham <chris.packham-6g8wRflRTwXFdCa3tKVlE6U/zSkkHjvu@public.gmane.org>
Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---

Notes:
    Changes in v2:
    - Update devicetree binding documentation to reflect that 98DX3336 and
      984251 are supersets of 98DX3236.
    - disable crypto block
    - disable sdio for 98DX3236, enable for 98DX4251
    Changes in v3:
    - fix typo 4521 -> 4251
    - document prestera bindings
    - rework corediv-clock binding
    - add label to packet processor node
    - add new compatible string for DFX server
    Changes in v4:
    - Collect ack from Rob
    Changes in v5:
    - Fixup license text. Add labels to nodes.
    Changes in v6:
    - None

 .../devicetree/bindings/arm/marvell/98dx3236.txt   |  23 ++
 .../devicetree/bindings/net/marvell,prestera.txt   |  50 ++++
 arch/arm/boot/dts/armada-xp-98dx3236.dtsi          | 254 +++++++++++++++++++++
 arch/arm/boot/dts/armada-xp-98dx3336.dtsi          |  76 ++++++
 arch/arm/boot/dts/armada-xp-98dx4251.dtsi          |  90 ++++++++
 5 files changed, 493 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/arm/marvell/98dx3236.txt
 create mode 100644 Documentation/devicetree/bindings/net/marvell,prestera.txt
 create mode 100644 arch/arm/boot/dts/armada-xp-98dx3236.dtsi
 create mode 100644 arch/arm/boot/dts/armada-xp-98dx3336.dtsi
 create mode 100644 arch/arm/boot/dts/armada-xp-98dx4251.dtsi

diff --git a/Documentation/devicetree/bindings/arm/marvell/98dx3236.txt b/Documentation/devicetree/bindings/arm/marvell/98dx3236.txt
new file mode 100644
index 000000000000..64e8c73fc5ab
--- /dev/null
+++ b/Documentation/devicetree/bindings/arm/marvell/98dx3236.txt
@@ -0,0 +1,23 @@
+Marvell 98DX3236, 98DX3336 and 98DX4251 Platforms Device Tree Bindings
+----------------------------------------------------------------------
+
+Boards with a SoC of the Marvell 98DX3236, 98DX3336 and 98DX4251 families
+shall have the following property:
+
+Required root node property:
+
+compatible: must contain "marvell,armadaxp-98dx3236"
+
+In addition, boards using the Marvell 98DX3336 SoC shall have the
+following property:
+
+Required root node property:
+
+compatible: must contain "marvell,armadaxp-98dx3336"
+
+In addition, boards using the Marvell 98DX4251 SoC shall have the
+following property:
+
+Required root node property:
+
+compatible: must contain "marvell,armadaxp-98dx4251"
diff --git a/Documentation/devicetree/bindings/net/marvell,prestera.txt b/Documentation/devicetree/bindings/net/marvell,prestera.txt
new file mode 100644
index 000000000000..5fbab29718e8
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/marvell,prestera.txt
@@ -0,0 +1,50 @@
+Marvell Prestera Switch Chip bindings
+-------------------------------------
+
+Required properties:
+- compatible: one of the following
+	"marvell,prestera-98dx3236",
+	"marvell,prestera-98dx3336",
+	"marvell,prestera-98dx4251",
+- reg: address and length of the register set for the device.
+- interrupts: interrupt for the device
+
+Optional properties:
+- dfx: phandle reference to the "DFX Server" node
+
+Example:
+
+switch {
+	compatible = "simple-bus";
+	#address-cells = <1>;
+	#size-cells = <1>;
+	ranges = <0 MBUS_ID(0x03, 0x00) 0 0x100000>;
+
+	packet-processor@0 {
+		compatible = "marvell,prestera-98dx3236";
+		reg = <0 0x4000000>;
+		interrupts = <33>, <34>, <35>;
+		dfx = <&dfx>;
+	};
+};
+
+DFX Server bindings
+-------------------
+
+Required properties:
+- compatible: must be "marvell,dfx-server"
+- reg: address and length of the register set for the device.
+
+Example:
+
+dfx-registers {
+	compatible = "simple-bus";
+	#address-cells = <1>;
+	#size-cells = <1>;
+	ranges = <0 MBUS_ID(0x08, 0x00) 0 0x100000>;
+
+	dfx: dfx@0 {
+		compatible = "marvell,dfx-server";
+		reg = <0 0x100000>;
+	};
+};
diff --git a/arch/arm/boot/dts/armada-xp-98dx3236.dtsi b/arch/arm/boot/dts/armada-xp-98dx3236.dtsi
new file mode 100644
index 000000000000..9461128fae24
--- /dev/null
+++ b/arch/arm/boot/dts/armada-xp-98dx3236.dtsi
@@ -0,0 +1,254 @@
+/*
+ * Device Tree Include file for Marvell 98dx3236 family SoC
+ *
+ * Copyright (C) 2016 Allied Telesis Labs
+ *
+ * This file is dual-licensed: you can use it either under the terms
+ * of the GPL or the X11 license, at your option. Note that this dual
+ * licensing only applies to this file, and not this project as a
+ * whole.
+ *
+ *  a) This file is free software; you can redistribute it and/or
+ *     modify it under the terms of the GNU General Public License as
+ *     published by the Free Software Foundation; either version 2 of the
+ *     License, or (at your option) any later version.
+ *
+ *     This file is distributed in the hope that it will be useful,
+ *     but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *     GNU General Public License for more details.
+ *
+ * Or, alternatively,
+ *
+ *  b) Permission is hereby granted, free of charge, to any person
+ *     obtaining a copy of this software and associated documentation
+ *     files (the "Software"), to deal in the Software without
+ *     restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or
+ *     sell copies of the Software, and to permit persons to whom the
+ *     Software is furnished to do so, subject to the following
+ *     conditions:
+ *
+ *     The above copyright notice and this permission notice shall be
+ *     included in all copies or substantial portions of the Software.
+ *
+ *     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ *     EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
+ *     OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ *     NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
+ *     HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
+ *     WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ *     FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
+ *     OTHER DEALINGS IN THE SOFTWARE.
+ *
+ * Contains definitions specific to the 98dx3236 SoC that are not
+ * common to all Armada XP SoCs.
+ */
+
+#include "armada-xp.dtsi"
+
+/ {
+	model = "Marvell 98DX3236 SoC";
+	compatible = "marvell,armadaxp-98dx3236", "marvell,armadaxp", "marvell,armada-370-xp";
+
+	aliases {
+		gpio0 = &gpio0;
+		gpio1 = &gpio1;
+		gpio2 = &gpio2;
+	};
+
+	cpus {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		enable-method = "marvell,98dx3236-smp";
+
+		cpu@0 {
+			device_type = "cpu";
+			compatible = "marvell,sheeva-v7";
+			reg = <0>;
+			clocks = <&cpuclk 0>;
+			clock-latency = <1000000>;
+		};
+	};
+
+	soc {
+		ranges = <MBUS_ID(0xf0, 0x01) 0 0 0xf1000000 0x100000
+			  MBUS_ID(0x01, 0x1d) 0 0 0xfff00000 0x100000
+			  MBUS_ID(0x01, 0x2f) 0 0 0xf0000000 0x1000000
+			  MBUS_ID(0x03, 0x00) 0 0 0xa8000000 0x4000000
+			  MBUS_ID(0x08, 0x00) 0 0 0xac000000 0x100000>;
+
+		/*
+		 * 98DX3236 has 1 x1 PCIe unit Gen2.0
+		 */
+		pciec: pcie-controller@82000000 {
+			compatible = "marvell,armada-xp-pcie";
+			status = "disabled";
+			device_type = "pci";
+
+			#address-cells = <3>;
+			#size-cells = <2>;
+
+			msi-parent = <&mpic>;
+			bus-range = <0x00 0xff>;
+
+			ranges =
+			       <0x82000000 0 0x40000 MBUS_ID(0xf0, 0x01) 0x40000 0 0x00002000   /* Port 0.0 registers */
+				0x82000000 0x1 0       MBUS_ID(0x04, 0xe8) 0 1 0 /* Port 0.0 MEM */
+				0x81000000 0x1 0       MBUS_ID(0x04, 0xe0) 0 1 0 /* Port 0.0 IO  */
+				0x82000000 0x2 0       MBUS_ID(0x04, 0xd8) 0 1 0 /* Port 0.1 MEM */>;
+
+			pcie1: pcie@1,0 {
+				device_type = "pci";
+				assigned-addresses = <0x82000800 0 0x40000 0 0x2000>;
+				reg = <0x0800 0 0 0 0>;
+				#address-cells = <3>;
+				#size-cells = <2>;
+				#interrupt-cells = <1>;
+				ranges = <0x82000000 0 0 0x82000000 0x1 0 1 0
+					  0x81000000 0 0 0x81000000 0x1 0 1 0>;
+				interrupt-map-mask = <0 0 0 0>;
+				interrupt-map = <0 0 0 0 &mpic 58>;
+				marvell,pcie-port = <0>;
+				marvell,pcie-lane = <0>;
+				clocks = <&gateclk 5>;
+				status = "disabled";
+			};
+		};
+
+		internal-regs {
+			coreclk: mvebu-sar@18230 {
+				compatible = "marvell,mv98dx3236-core-clock";
+			};
+
+			cpuclk: clock-complex@18700 {
+				compatible = "marvell,mv98dx3236-cpu-clock";
+			};
+
+			corediv-clock@18740 {
+				status = "disabled";
+			};
+
+			xor@60900 {
+				status = "disabled";
+			};
+
+			crypto@90000 {
+				status = "disabled";
+			};
+
+			xor@f0900 {
+				status = "disabled";
+			};
+
+			xor@f0800 {
+				compatible = "marvell,orion-xor";
+				reg = <0xf0800 0x100
+				       0xf0a00 0x100>;
+				clocks = <&gateclk 22>;
+				status = "okay";
+
+				xor10 {
+					interrupts = <51>;
+					dmacap,memcpy;
+					dmacap,xor;
+				};
+				xor11 {
+					interrupts = <52>;
+					dmacap,memcpy;
+					dmacap,xor;
+					dmacap,memset;
+				};
+			};
+
+			gpio0: gpio@18100 {
+				compatible = "marvell,orion-gpio";
+				reg = <0x18100 0x40>;
+				ngpios = <32>;
+				gpio-controller;
+				#gpio-cells = <2>;
+				interrupt-controller;
+				#interrupt-cells = <2>;
+				interrupts = <82>, <83>, <84>, <85>;
+			};
+
+			/* does not exist */
+			gpio1: gpio@18140 {
+				compatible = "marvell,orion-gpio";
+				reg = <0x18140 0x40>;
+				status = "disabled";
+			};
+
+			gpio2: gpio@18180 { /* rework some properties */
+				compatible = "marvell,orion-gpio";
+				reg = <0x18180 0x40>;
+				ngpios = <1>; /* only gpio #32 */
+				gpio-controller;
+				#gpio-cells = <2>;
+				interrupt-controller;
+				#interrupt-cells = <2>;
+				interrupts = <87>;
+			};
+
+			nand: nand@d0000 {
+				clocks = <&dfx_coredivclk 0>;
+			};
+		};
+
+		dfxr: dfx-registers@ac000000 {
+			compatible = "simple-bus";
+			#address-cells = <1>;
+			#size-cells = <1>;
+			ranges = <0 MBUS_ID(0x08, 0x00) 0 0x100000>;
+
+                        dfx_coredivclk: corediv-clock@f8268 {
+                                compatible = "marvell,mv98dx3236-corediv-clock";
+                                reg = <0xf8268 0xc>;
+                                #clock-cells = <1>;
+                                clocks = <&mainpll>;
+                                clock-output-names = "nand";
+                        };
+
+			dfx: dfx@0 {
+				compatible = "marvell,dfx-server";
+				reg = <0 0x100000>;
+			};
+		};
+
+		switch: switch@a8000000 {
+			compatible = "simple-bus";
+			#address-cells = <1>;
+			#size-cells = <1>;
+			ranges = <0 MBUS_ID(0x03, 0x00) 0 0x100000>;
+
+			pp0: packet-processor@0 {
+				compatible = "marvell,prestera-98dx3236";
+				reg = <0 0x4000000>;
+				interrupts = <33>, <34>, <35>;
+				dfx = <&dfx>;
+			};
+		};
+	};
+};
+
+&pinctrl {
+	compatible = "marvell,98dx3236-pinctrl";
+
+	spi0_pins: spi0-pins {
+		marvell,pins = "mpp0", "mpp1",
+			       "mpp2", "mpp3";
+		marvell,function = "spi0";
+	};
+};
+
+&sdio {
+	status = "disabled";
+};
+
+&crypto_sram0 {
+	status = "disabled";
+};
+
+&crypto_sram1 {
+	status = "disabled";
+};
diff --git a/arch/arm/boot/dts/armada-xp-98dx3336.dtsi b/arch/arm/boot/dts/armada-xp-98dx3336.dtsi
new file mode 100644
index 000000000000..e1580afdc260
--- /dev/null
+++ b/arch/arm/boot/dts/armada-xp-98dx3336.dtsi
@@ -0,0 +1,76 @@
+/*
+ * Device Tree Include file for Marvell 98dx3336 family SoC
+ *
+ * Copyright (C) 2016 Allied Telesis Labs
+ *
+ * This file is dual-licensed: you can use it either under the terms
+ * of the GPL or the X11 license, at your option. Note that this dual
+ * licensing only applies to this file, and not this project as a
+ * whole.
+ *
+ *  a) This file is free software; you can redistribute it and/or
+ *     modify it under the terms of the GNU General Public License as
+ *     published by the Free Software Foundation; either version 2 of the
+ *     License, or (at your option) any later version.
+ *
+ *     This file is distributed in the hope that it will be useful,
+ *     but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *     GNU General Public License for more details.
+ *
+ * Or, alternatively,
+ *
+ *  b) Permission is hereby granted, free of charge, to any person
+ *     obtaining a copy of this software and associated documentation
+ *     files (the "Software"), to deal in the Software without
+ *     restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or
+ *     sell copies of the Software, and to permit persons to whom the
+ *     Software is furnished to do so, subject to the following
+ *     conditions:
+ *
+ *     The above copyright notice and this permission notice shall be
+ *     included in all copies or substantial portions of the Software.
+ *
+ *     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ *     EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
+ *     OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ *     NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
+ *     HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
+ *     WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ *     FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
+ *     OTHER DEALINGS IN THE SOFTWARE.
+ *
+ * Contains definitions specific to the 98dx3236 SoC that are not
+ * common to all Armada XP SoCs.
+ */
+
+#include "armada-xp-98dx3236.dtsi"
+
+/ {
+	model = "Marvell 98DX3336 SoC";
+	compatible = "marvell,armadaxp-98dx3336", "marvell,armadaxp-98dx3236", "marvell,armadaxp", "marvell,armada-370-xp";
+
+	cpus {
+		cpu@1 {
+			device_type = "cpu";
+			compatible = "marvell,sheeva-v7";
+			reg = <1>;
+			clocks = <&cpuclk 1>;
+			clock-latency = <1000000>;
+		};
+	};
+
+	soc {
+		internal-regs {
+			resume@20980 {
+				compatible = "marvell,98dx3336-resume-ctrl";
+				reg = <0x20980 0x10>;
+			};
+		};
+	};
+};
+
+&pp0 {
+	compatible = "marvell,prestera-98dx3336";
+};
diff --git a/arch/arm/boot/dts/armada-xp-98dx4251.dtsi b/arch/arm/boot/dts/armada-xp-98dx4251.dtsi
new file mode 100644
index 000000000000..4b0533a4ccb7
--- /dev/null
+++ b/arch/arm/boot/dts/armada-xp-98dx4251.dtsi
@@ -0,0 +1,90 @@
+/*
+ * Device Tree Include file for Marvell 98dx4521 family SoC
+ *
+ * Copyright (C) 2016 Allied Telesis Labs
+ *
+ * This file is dual-licensed: you can use it either under the terms
+ * of the GPL or the X11 license, at your option. Note that this dual
+ * licensing only applies to this file, and not this project as a
+ * whole.
+ *
+ *  a) This file is free software; you can redistribute it and/or
+ *     modify it under the terms of the GNU General Public License as
+ *     published by the Free Software Foundation; either version 2 of the
+ *     License, or (at your option) any later version.
+ *
+ *     This file is distributed in the hope that it will be useful,
+ *     but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *     GNU General Public License for more details.
+ *
+ * Or, alternatively,
+ *
+ *  b) Permission is hereby granted, free of charge, to any person
+ *     obtaining a copy of this software and associated documentation
+ *     files (the "Software"), to deal in the Software without
+ *     restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or
+ *     sell copies of the Software, and to permit persons to whom the
+ *     Software is furnished to do so, subject to the following
+ *     conditions:
+ *
+ *     The above copyright notice and this permission notice shall be
+ *     included in all copies or substantial portions of the Software.
+ *
+ *     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ *     EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
+ *     OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ *     NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
+ *     HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
+ *     WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ *     FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
+ *     OTHER DEALINGS IN THE SOFTWARE.
+ *
+ * Contains definitions specific to the 98dx4521 SoC that are not
+ * common to all Armada XP SoCs.
+ */
+
+#include "armada-xp-98dx3236.dtsi"
+
+/ {
+	model = "Marvell 98DX4251 SoC";
+	compatible = "marvell,armadaxp-98dx4521", "marvell,armadaxp-98dx3236", "marvell,armadaxp", "marvell,armada-370-xp";
+
+	cpus {
+		cpu@1 {
+			device_type = "cpu";
+			compatible = "marvell,sheeva-v7";
+			reg = <1>;
+			clocks = <&cpuclk 1>;
+			clock-latency = <1000000>;
+		};
+	};
+
+	soc {
+		internal-regs {
+			resume@20980 {
+				compatible = "marvell,98dx3336-resume-ctrl";
+				reg = <0x20980 0x10>;
+			};
+		};
+	};
+};
+
+&sdio {
+	status = "okay";
+};
+
+&pinctrl {
+	compatible = "marvell,98dx4251-pinctrl";
+
+	sdio_pins: sdio-pins {
+		marvell,pins = "mpp5", "mpp6", "mpp7",
+			       "mpp8", "mpp9", "mpp10";
+		marvell,function = "sd0";
+	};
+};
+
+&pp0 {
+	compatible = "marvell,prestera-98dx4251";
+};
-- 
2.11.0.24.ge6920cf

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
