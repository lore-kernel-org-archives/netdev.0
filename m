From: Alban <albeu@free.fr>
Subject: [PATCH 1/7] Documentation: dt: net: Update the ath9k binding for SoC devices
Date: Mon, 13 Mar 2017 22:05:09 +0100
Message-ID: <1489439116-4233-1-git-send-email-albeu@free.fr>
Cc: John Crispin <john@phrozen.org>, Alban <albeu@free.fr>,
        Kalle Valo <kvalo@codeaurora.org>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current binding only cover PCI devices so extend it for SoC devices.

Most SoC platforms use an MTD partition for the calibration data
instead of an EEPROM. The qca,no-eeprom property was added to allow
loading the EEPROM content using firmware loading. This new binding
replace this hack with NVMEM cells, so we also mark the qca,no-eeprom
property as deprecated in case anyone ever used it.

Signed-off-by: Alban <albeu@free.fr>
---
 .../devicetree/bindings/net/wireless/qca,ath9k.txt | 41 ++++++++++++++++++++--
 1 file changed, 38 insertions(+), 3 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/wireless/qca,ath9k.txt b/Documentation/devicetree/bindings/net/wireless/qca,ath9k.txt
index b7396c8..61f5f6d 100644
--- a/Documentation/devicetree/bindings/net/wireless/qca,ath9k.txt
+++ b/Documentation/devicetree/bindings/net/wireless/qca,ath9k.txt
@@ -27,16 +27,34 @@ Required properties:
 			- 0034 for AR9462
 			- 0036 for AR9565
 			- 0037 for AR9485
+		For SoC devices the compatible should be "qca,<soctype>-wmac"
+		and one of the following fallbacks:
+			- "qca,ar9100-wmac"
+			- "qca,ar9330-wmac"
+			- "qca,ar9340-wmac"
+			- "qca,qca9550-wmac"
+			- "qca,qca9530-wmac"
 - reg: Address and length of the register set for the device.
 
+Required properties for SoC devices:
+- interrupt-parent: phandle of the parent interrupt controller.
+- interrupts: Interrupt specifier for the controllers interrupt.
+
 Optional properties:
+- mac-address: See ethernet.txt in the parent directory
+- local-mac-address: See ethernet.txt in the parent directory
+- clock-names: has to be "ref"
+- clocks: phandle of the reference clock
+- resets: phandle of the reset line
+- nvmem-cell-names: has to be "eeprom" and/or "address"
+- nvmem-cells: phandle to the eeprom nvmem cell and/or to the mac address
+		nvmem cell.
+
+Deprecated properties:
 - qca,no-eeprom: Indicates that there is no physical EEPROM connected to the
 			ath9k wireless chip (in this case the calibration /
 			EEPROM data will be loaded from userspace using the
 			kernel firmware loader).
-- mac-address: See ethernet.txt in the parent directory
-- local-mac-address: See ethernet.txt in the parent directory
-
 
 In this example, the node is defined as child node of the PCI controller:
 &pci0 {
@@ -46,3 +64,20 @@ In this example, the node is defined as child node of the PCI controller:
 		qca,no-eeprom;
 	};
 };
+
+In this example it is defined as a SoC device:
+	wmac@180c0000 {
+		compatible = "qca,ar9132-wmac", "qca,ar9100-wmac";
+		reg = <0x180c0000 0x30000>;
+
+		interrupt-parent = <&cpuintc>;
+		interrupts = <2>;
+
+		clock-names = "ref";
+		clocks = <&extosc>;
+
+		nvmem-cell-names = "eeprom", "address";
+		nvmem-cells = <&wmac_eeprom>, <&wmac_address>;
+
+		resets = <&rst 22>;
+	};
-- 
2.7.4
