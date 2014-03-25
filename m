From: <dinguyen@altera.com>
Subject: [PATCH 2/3] dts: socfpga: Fix ethernet entries for the stmmac
Date: Tue, 25 Mar 2014 18:34:41 -0500
Message-ID: <1395790482-3957-3-git-send-email-dinguyen@altera.com>
References: <1395790482-3957-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, devicetree@vger.kernel.org, pawel.moll@arm.com,
 srinivas.kandagatla@st.com, netdev@vger.kernel.org,
 ijc+devicetree@hellion.org.uk, robh+dt@kernel.org, arm@kernel.org,
 Dinh Nguyen <dinguyen@altera.com>, galak@codeaurora.org,
 linux-arm-kernel@lists.infradead.org
To: <dinh.linux@gmail.com>, <arnd@arndb.de>, <davem@davemloft.net>,
 <peppe.cavallaro@st.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1395790482-3957-1-git-send-email-dinguyen@altera.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Dinh Nguyen <dinguyen@altera.com>

* Replaced the parent/child DT nodes with a combined node
* Renamed the device node from 'ethernet0' to 'ethernet'
  as the standard name.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Dinh Nguyen <dinguyen@altera.com>
---
 arch/arm/boot/dts/socfpga.dtsi                |   51 +++++++++----------------
 arch/arm/boot/dts/socfpga_arria5_socdk.dts    |    5 +--
 arch/arm/boot/dts/socfpga_cyclone5_socdk.dts  |    5 +--
 arch/arm/boot/dts/socfpga_cyclone5_sockit.dts |    5 +--
 arch/arm/boot/dts/socfpga_vt.dts              |    5 +--
 5 files changed, 22 insertions(+), 49 deletions(-)

diff --git a/arch/arm/boot/dts/socfpga.dtsi b/arch/arm/boot/dts/socfpga.dtsi
index 404553c..953801c 100644
--- a/arch/arm/boot/dts/socfpga.dtsi
+++ b/arch/arm/boot/dts/socfpga.dtsi
@@ -450,43 +450,28 @@
 				};
 			};
 
-		ethernet0: ethernet0 {
-			#address-cells = <1>;
-			#size-cells = <1>;
-			compatible = "altr,socfpga-stmmac";
-			altr,sysmgr-syscon = <&sysmgr 0x60>;
+		gmac0: ethernet@ff700000 {
+			compatible = "altr,socfpga-stmmac", "snps,dwmac-3.70a", "snps,dwmac";
 			status = "disabled";
-			ranges;
-
-			gmac0: gmac0@ff700000 {
-				compatible = "snps,dwmac-3.70a", "snps,dwmac";
-				reg = <0xff700000 0x2000>;
-				interrupts = <0 115 4>;
-				interrupt-names = "macirq";
-				mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
-				clocks = <&emac0_clk>;
-				clock-names = "stmmaceth";
-			};
+			altr,sysmgr-syscon = <&sysmgr 0x60>;
+			reg = <0xff700000 0x2000>;
+			interrupts = <0 115 4>;
+			interrupt-names = "macirq";
+			mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
+			clocks = <&emac0_clk>;
+			clock-names = "stmmaceth";
 		};
 
-		ethernet1: ethernet1 {
-			#address-cells = <1>;
-			#size-cells = <1>;
-			compatible = "altr,socfpga-stmmac";
-			altr,sysmgr-syscon = <&sysmgr 0x60>;
+		gmac1: ethernet@ff702000 {
+			compatible = "altr,socfpga-stmmac", "snps,dwmac-3.70a", "snps,dwmac";
 			status = "disabled";
-			ranges;
-
-			gmac1: gmac1@ff702000 {
-				device_type = "network";
-				compatible = "snps,dwmac-3.70a", "snps,dwmac";
-				reg = <0xff702000 0x2000>;
-				interrupts = <0 120 4>;
-				interrupt-names = "macirq";
-				mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
-				clocks = <&emac1_clk>;
-				clock-names = "stmmaceth";
-			};
+			altr,sysmgr-syscon = <&sysmgr 0x60>;
+			reg = <0xff702000 0x2000>;
+			interrupts = <0 120 4>;
+			interrupt-names = "macirq";
+			mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
+			clocks = <&emac1_clk>;
+			clock-names = "stmmaceth";
 		};
 
 		L2: l2-cache@fffef000 {
diff --git a/arch/arm/boot/dts/socfpga_arria5_socdk.dts b/arch/arm/boot/dts/socfpga_arria5_socdk.dts
index 2d6b38b..a87ee1c 100644
--- a/arch/arm/boot/dts/socfpga_arria5_socdk.dts
+++ b/arch/arm/boot/dts/socfpga_arria5_socdk.dts
@@ -46,11 +46,8 @@
 	};
 };
 
-&ethernet1 {
-	status = "okay";
-};
-
 &gmac1 {
+	status = "okay";
 	phy-mode = "rgmii";
 
 	rxd0-skew-ps = <0>;
diff --git a/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts b/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts
index 26c63a0..ae16d97 100644
--- a/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts
+++ b/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts
@@ -39,11 +39,8 @@
 	};
 };
 
-&ethernet1 {
-	status = "okay";
-};
-
 &gmac1 {
+	status = "okay";
 	phy-mode = "rgmii";
 
 	rxd0-skew-ps = <0>;
diff --git a/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts b/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts
index 469bb5c..b79e2a2 100644
--- a/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts
+++ b/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts
@@ -39,11 +39,8 @@
 	};
 };
 
-&ethernet1 {
-	status = "okay";
-};
-
 &gmac1 {
+	status = "okay";
 	phy-mode = "rgmii";
 
 	rxd0-skew-ps = <0>;
diff --git a/arch/arm/boot/dts/socfpga_vt.dts b/arch/arm/boot/dts/socfpga_vt.dts
index 91f6ccf..87d6f75 100644
--- a/arch/arm/boot/dts/socfpga_vt.dts
+++ b/arch/arm/boot/dts/socfpga_vt.dts
@@ -87,10 +87,7 @@
 	};
 };
 
-&ethernet0 {
-        status = "okay";
-};
-
 &gmac0 {
+	status = "okay";
 	phy-mode = "gmii";
 };
-- 
1.7.9.5
