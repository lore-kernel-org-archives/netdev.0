From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/5] Documentation: dt: bindings: Update Broadcom 7445 switch document
Date: Thu, 18 Aug 2016 15:30:13 -0700
Message-ID: <1471559416-13249-3-git-send-email-f.fainelli@gmail.com>
References: <1471559416-13249-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34886 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754296AbcHSBAq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 21:00:46 -0400
Received: by mail-pf0-f195.google.com with SMTP id h186so551674pfg.2
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 18:00:45 -0700 (PDT)
In-Reply-To: <1471559416-13249-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Document the updated binding which conforms to the new DSA binding in
net/dsa/dsa.txt.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 .../bindings/net/brcm,bcm7445-switch-v4.0.txt      | 45 +++++++++++++++++++++-
 1 file changed, 44 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/brcm,bcm7445-switch-v4.0.txt b/Documentation/devicetree/bindings/net/brcm,bcm7445-switch-v4.0.txt
index 30d487597ecb..fb40891ee606 100644
--- a/Documentation/devicetree/bindings/net/brcm,bcm7445-switch-v4.0.txt
+++ b/Documentation/devicetree/bindings/net/brcm,bcm7445-switch-v4.0.txt
@@ -6,9 +6,13 @@ Required properties:
 - reg: addresses and length of the register sets for the device, must be 6
   pairs of register addresses and lengths
 - interrupts: interrupts for the devices, must be two interrupts
+- #address-cells: must be 1, see dsa/dsa.txt
+- #size-cells: must be 0, see dsa/dsa.txt
+
+Deprecated binding required properties:
+
 - dsa,mii-bus: phandle to the MDIO bus controller, see dsa/dsa.txt
 - dsa,ethernet: phandle to the CPU network interface controller, see dsa/dsa.txt
-- #size-cells: must be 0
 - #address-cells: must be 2, see dsa/dsa.txt
 
 Subnodes:
@@ -48,6 +52,45 @@ switch_top@f0b00000 {
 	ethernet_switch@0 {
 		compatible = "brcm,bcm7445-switch-v4.0";
 		#size-cells = <0>;
+		#address-cells = <1>;
+		reg = <0x0 0x40000
+			0x40000 0x110
+			0x40340 0x30
+			0x40380 0x30
+			0x40400 0x34
+			0x40600 0x208>;
+		reg-names = "core", "reg", intrl2_0", "intrl2_1",
+			    "fcb, "acb";
+		interrupts = <0 0x18 0
+				0 0x19 0>;
+		brcm,num-gphy = <1>;
+		brcm,num-rgmii-ports = <2>;
+		brcm,fcb-pause-override;
+		brcm,acb-packets-inflight;
+
+		ports {
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			port@0 {
+				label = "gphy";
+				reg = <0>;
+			};
+		};
+	};
+};
+
+Example using the old DSA DeviceTree binding:
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
 		#address-cells = <2>;
 		reg = <0x0 0x40000
 			0x40000 0x110
-- 
2.7.4
