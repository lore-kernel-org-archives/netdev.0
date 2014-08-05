From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 12/12] Documentation: devicetree: add Broadcom Starfighter 2 binding
Date: Tue,  5 Aug 2014 15:31:46 -0700
Message-ID: <1407277906-19989-13-git-send-email-f.fainelli@gmail.com>
References: <1407277906-19989-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, linville@tuxdriver.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:57120 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753322AbaHEWcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 18:32:19 -0400
Received: by mail-pd0-f174.google.com with SMTP id fp1so2092245pdb.33
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2014 15:32:19 -0700 (PDT)
In-Reply-To: <1407277906-19989-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the binding documentation for the Broadcom Starfighter 2 integrated
switch hardware.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 .../devicetree/bindings/net/broadcom-sf2.txt       | 78 ++++++++++++++++++++++
 1 file changed, 78 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/broadcom-sf2.txt

diff --git a/Documentation/devicetree/bindings/net/broadcom-sf2.txt b/Documentation/devicetree/bindings/net/broadcom-sf2.txt
new file mode 100644
index 000000000000..30d487597ecb
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/broadcom-sf2.txt
@@ -0,0 +1,78 @@
+* Broadcom Starfighter 2 integrated swich
+
+Required properties:
+
+- compatible: should be "brcm,bcm7445-switch-v4.0"
+- reg: addresses and length of the register sets for the device, must be 6
+  pairs of register addresses and lengths
+- interrupts: interrupts for the devices, must be two interrupts
+- dsa,mii-bus: phandle to the MDIO bus controller, see dsa/dsa.txt
+- dsa,ethernet: phandle to the CPU network interface controller, see dsa/dsa.txt
+- #size-cells: must be 0
+- #address-cells: must be 2, see dsa/dsa.txt
+
+Subnodes:
+
+The integrated switch subnode should be specified according to the binding
+described in dsa/dsa.txt.
+
+Optional properties:
+
+- reg-names: litteral names for the device base register addresses, when present
+  must be: "core", "reg", "intrl2_0", "intrl2_1", "fcb", "acb"
+
+- interrupt-names: litternal names for the device interrupt lines, when present
+  must be: "switch_0" and "switch_1"
+
+- brcm,num-gphy: specify the maximum number of integrated gigabit PHYs in the
+  switch
+
+- brcm,num-rgmii-ports: specify the maximum number of RGMII interfaces supported
+  by the switch
+
+- brcm,fcb-pause-override: boolean property, if present indicates that the switch
+  supports Failover Control Block pause override capability
+
+- brcm,acb-packets-inflight: boolean property, if present indicates that the switch
+  Admission Control Block supports reporting the number of packets in-flight in a
+  switch queue
+
+Example:
+
+switch_top@f0b00000 {
+	compatible = "simple-bus";
+	#size-cells = <1>;
+	#address-cells = <1>;
+	ranges = <0 0xf0b00000 0x40804>;
+
+	ethernet_switch@0 {
+		compatible = "brcm,bcm7445-switch-v4.0";
+		#size-cells = <0>;
+		#address-cells = <2>;
+		reg = <0x0 0x40000
+			0x40000 0x110
+			0x40340 0x30
+			0x40380 0x30
+			0x40400 0x34
+			0x40600 0x208>;
+		interrupts = <0 0x18 0
+				0 0x19 0>;
+		brcm,num-gphy = <1>;
+		brcm,num-rgmii-ports = <2>;
+		brcm,fcb-pause-override;
+		brcm,acb-packets-inflight;
+
+		...
+		switch@0 {
+			reg = <0 0>;
+			#size-cells = <0>;
+			#address-cells <1>;
+
+			port@0 {
+				label = "gphy";
+				reg = <0>;
+			};
+			...
+		};
+	};
+};
-- 
1.9.1
