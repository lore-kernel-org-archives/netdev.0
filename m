From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH net-next v2 4/4] powerpc: tqm8548/tqm8xx: add and update CAN device nodes
Date: Fri, 25 Nov 2011 10:43:24 +0100
Message-ID: <1322214204-1121-5-git-send-email-wg@grandegger.com>
References: <1322214204-1121-1-git-send-email-wg@grandegger.com>
Cc: linux-can@vger.kernel.org, socketcan-users@lists.berlios.de,
	IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	devicetree-discuss@lists.ozlabs.org, linuxppc-dev@ozlabs.org,
	Kumar Gala <galak@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1322214204-1121-1-git-send-email-wg@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch enables or updates support for the CC770 and AN82527
CAN controller on the TQM8548 and TQM8xx boards.

CC: devicetree-discuss@lists.ozlabs.org
CC: linuxppc-dev@ozlabs.org
CC: Kumar Gala <galak@kernel.crashing.org>
Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
---
 arch/powerpc/boot/dts/tqm8548-bigflash.dts |   19 ++++++++++++++-----
 arch/powerpc/boot/dts/tqm8548.dts          |   19 ++++++++++++++-----
 arch/powerpc/boot/dts/tqm8xx.dts           |   25 +++++++++++++++++++++++++
 3 files changed, 53 insertions(+), 10 deletions(-)

diff --git a/arch/powerpc/boot/dts/tqm8548-bigflash.dts b/arch/powerpc/boot/dts/tqm8548-bigflash.dts
index 9452c3c..d918752 100644
--- a/arch/powerpc/boot/dts/tqm8548-bigflash.dts
+++ b/arch/powerpc/boot/dts/tqm8548-bigflash.dts
@@ -352,7 +352,7 @@
 		ranges = <
 			0 0x0 0xfc000000 0x04000000	// NOR FLASH bank 1
 			1 0x0 0xf8000000 0x08000000	// NOR FLASH bank 0
-			2 0x0 0xa3000000 0x00008000	// CAN (2 x i82527)
+			2 0x0 0xa3000000 0x00008000	// CAN (2 x CC770)
 			3 0x0 0xa3010000 0x00008000	// NAND FLASH
 
 		>;
@@ -393,18 +393,27 @@
 		};
 
 		/* Note: CAN support needs be enabled in U-Boot */
-		can0@2,0 {
-			compatible = "intel,82527"; // Bosch CC770
+		can@2,0 {
+			compatible = "bosch,cc770"; // Bosch CC770
 			reg = <2 0x0 0x100>;
 			interrupts = <4 1>;
 			interrupt-parent = <&mpic>;
+			bosch,external-clock-frequency = <16000000>;
+			bosch,disconnect-rx1-input;
+			bosch,disconnect-tx1-output;
+			bosch,iso-low-speed-mux;
+			bosch,clock-out-frequency = <16000000>;
 		};
 
-		can1@2,100 {
-			compatible = "intel,82527"; // Bosch CC770
+		can@2,100 {
+			compatible = "bosch,cc770"; // Bosch CC770
 			reg = <2 0x100 0x100>;
 			interrupts = <4 1>;
 			interrupt-parent = <&mpic>;
+			bosch,external-clock-frequency = <16000000>;
+			bosch,disconnect-rx1-input;
+			bosch,disconnect-tx1-output;
+			bosch,iso-low-speed-mux;
 		};
 
 		/* Note: NAND support needs to be enabled in U-Boot */
diff --git a/arch/powerpc/boot/dts/tqm8548.dts b/arch/powerpc/boot/dts/tqm8548.dts
index 619776f..988d887 100644
--- a/arch/powerpc/boot/dts/tqm8548.dts
+++ b/arch/powerpc/boot/dts/tqm8548.dts
@@ -352,7 +352,7 @@
 		ranges = <
 			0 0x0 0xfc000000 0x04000000	// NOR FLASH bank 1
 			1 0x0 0xf8000000 0x08000000	// NOR FLASH bank 0
-			2 0x0 0xe3000000 0x00008000	// CAN (2 x i82527)
+			2 0x0 0xe3000000 0x00008000	// CAN (2 x CC770)
 			3 0x0 0xe3010000 0x00008000	// NAND FLASH
 
 		>;
@@ -393,18 +393,27 @@
 		};
 
 		/* Note: CAN support needs be enabled in U-Boot */
-		can0@2,0 {
-			compatible = "intel,82527"; // Bosch CC770
+		can@2,0 {
+			compatible = "bosch,cc770"; // Bosch CC770
 			reg = <2 0x0 0x100>;
 			interrupts = <4 1>;
 			interrupt-parent = <&mpic>;
+			bosch,external-clock-frequency = <16000000>;
+			bosch,disconnect-rx1-input;
+			bosch,disconnect-tx1-output;
+			bosch,iso-low-speed-mux;
+			bosch,clock-out-frequency = <16000000>;
 		};
 
-		can1@2,100 {
-			compatible = "intel,82527"; // Bosch CC770
+		can@2,100 {
+			compatible = "bosch,cc770"; // Bosch CC770
 			reg = <2 0x100 0x100>;
 			interrupts = <4 1>;
 			interrupt-parent = <&mpic>;
+			bosch,external-clock-frequency = <16000000>;
+			bosch,disconnect-rx1-input;
+			bosch,disconnect-tx1-output;
+			bosch,iso-low-speed-mux;
 		};
 
 		/* Note: NAND support needs to be enabled in U-Boot */
diff --git a/arch/powerpc/boot/dts/tqm8xx.dts b/arch/powerpc/boot/dts/tqm8xx.dts
index f6da7ec..c3dba25 100644
--- a/arch/powerpc/boot/dts/tqm8xx.dts
+++ b/arch/powerpc/boot/dts/tqm8xx.dts
@@ -57,6 +57,7 @@
 
 		ranges = <
 			0x0 0x0 0x40000000 0x800000
+			0x3 0x0 0xc0000000 0x200
 		>;
 
 		flash@0,0 {
@@ -67,6 +68,30 @@
 			bank-width = <4>;
 			device-width = <2>;
 		};
+
+		/* Note: CAN support needs be enabled in U-Boot */
+		can@3,0 {
+			compatible = "intc,82527";
+			reg = <3 0x0 0x80>;
+			interrupts = <8 1>;
+			interrupt-parent = <&PIC>;
+			bosch,external-clock-frequency = <16000000>;
+			bosch,disconnect-rx1-input;
+			bosch,disconnect-tx1-output;
+			bosch,iso-low-speed-mux;
+			bosch,clock-out-frequency = <16000000>;
+		};
+
+		can@3,100 {
+			compatible = "intc,82527";
+			reg = <3 0x100 0x80>;
+			interrupts = <8 1>;
+			interrupt-parent = <&PIC>;
+			bosch,external-clock-frequency = <16000000>;
+			bosch,disconnect-rx1-input;
+			bosch,disconnect-tx1-output;
+			bosch,iso-low-speed-mux;
+		};
 	};
 
 	soc@fff00000 {
-- 
1.7.4.1

