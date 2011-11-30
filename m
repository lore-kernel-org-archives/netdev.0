From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: [PATCH net-next v5 4/4] powerpc: tqm8548/tqm8xx: add and update CAN
 device nodes
Date: Wed, 30 Nov 2011 09:18:14 +0100
Message-ID: <1322641094-12175-5-git-send-email-wg@grandegger.com>
References: <1322641094-12175-1-git-send-email-wg@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stanislav Yelenskiy <stanislavelensky-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, IreneV <boir1-o+MxOtu4lMCHXe+LvDLADg@public.gmane.org>,
 socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1322641094-12175-1-git-send-email-wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch enables or updates support for the CC770 and AN82527
CAN controller on the TQM8548 and TQM8xx boards.

CC: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
CC: linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
CC: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Signed-off-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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
