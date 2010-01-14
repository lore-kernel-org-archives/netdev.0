From: Liu Yu <yu.liu@freescale.com>
Subject: [PATCH 1/4] dts/mpc8569mds: Cleanup tbi phy to support rtbi
Date: Thu, 14 Jan 2010 16:13:16 +0800
Message-ID: <1263456799-3306-1-git-send-email-yu.liu@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Liu Yu <yu.liu@freescale.com>,
	linuxppc-dev@lists.ozlabs.org
To: galak@kernel.crashing.org, davem@davemloft.net
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

After these change, when need to work in rtbi mode,
just change phy-connection-type to "rtbi".

Also, this work can be done by u-boot.

Signed-off-by: Liu Yu <yu.liu@freescale.com>
---
 arch/powerpc/boot/dts/mpc8569mds.dts |   47 ++++++++++++++++++++++++++++++---
 1 files changed, 42 insertions(+), 5 deletions(-)

diff --git a/arch/powerpc/boot/dts/mpc8569mds.dts b/arch/powerpc/boot/dts/mpc8569mds.dts
index 795eb36..8b72eaf 100644
--- a/arch/powerpc/boot/dts/mpc8569mds.dts
+++ b/arch/powerpc/boot/dts/mpc8569mds.dts
@@ -535,6 +535,7 @@
 			rx-clock-name = "none";
 			tx-clock-name = "clk12";
 			pio-handle = <&pio1>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&qe_phy0>;
 			phy-connection-type = "rgmii-id";
 		};
@@ -579,7 +580,7 @@
 				reg = <0x6>;
 				device_type = "ethernet-phy";
 			};
-			tbi-phy@11 {
+			tbi1: tbi-phy@11 {
 				reg = <0x11>;
 				device_type = "tbi-phy";
 			};
@@ -590,7 +591,7 @@
 			reg = <0x3520 0x18>;
 			compatible = "fsl,ucc-mdio";
 
-			tbi0: tbi-phy@15 {
+			tbi6: tbi-phy@15 {
 			reg = <0x15>;
 			device_type = "tbi-phy";
 			};
@@ -600,7 +601,7 @@
 			#size-cells = <0>;
 			reg = <0x3720 0x38>;
 			compatible = "fsl,ucc-mdio";
-			tbi1: tbi-phy@17 {
+			tbi8: tbi-phy@17 {
 				reg = <0x17>;
 				device_type = "tbi-phy";
 			};
@@ -617,10 +618,22 @@
 			rx-clock-name = "none";
 			tx-clock-name = "clk12";
 			pio-handle = <&pio3>;
+			tbi-handle = <&tbi3>;
 			phy-handle = <&qe_phy2>;
 			phy-connection-type = "rgmii-id";
 		};
 
+		mdio@2320 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0x2320 0x18>;
+			compatible = "fsl,ucc-mdio";
+			tbi3: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
 		enet1: ucc@3000 {
 			device_type = "network";
 			compatible = "ucc_geth";
@@ -632,10 +645,22 @@
 			rx-clock-name = "none";
 			tx-clock-name = "clk17";
 			pio-handle = <&pio2>;
+			tbi-handle = <&tbi2>;
 			phy-handle = <&qe_phy1>;
 			phy-connection-type = "rgmii-id";
 		};
 
+		mdio@3120 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0x3120 0x18>;
+			compatible = "fsl,ucc-mdio";
+			tbi2: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
 		enet3: ucc@3200 {
 			device_type = "network";
 			compatible = "ucc_geth";
@@ -647,10 +672,22 @@
 			rx-clock-name = "none";
 			tx-clock-name = "clk17";
 			pio-handle = <&pio4>;
+			tbi-handle = <&tbi4>;
 			phy-handle = <&qe_phy3>;
 			phy-connection-type = "rgmii-id";
 		};
 
+		mdio@3320 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0x3320 0x18>;
+			compatible = "fsl,ucc-mdio";
+			tbi4: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
 		enet5: ucc@3400 {
 			device_type = "network";
 			compatible = "ucc_geth";
@@ -661,7 +698,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			rx-clock-name = "none";
 			tx-clock-name = "none";
-			tbi-handle = <&tbi0>;
+			tbi-handle = <&tbi6>;
 			phy-handle = <&qe_phy5>;
 			phy-connection-type = "sgmii";
 		};
@@ -676,7 +713,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			rx-clock-name = "none";
 			tx-clock-name = "none";
-			tbi-handle = <&tbi1>;
+			tbi-handle = <&tbi8>;
 			phy-handle = <&qe_phy7>;
 			phy-connection-type = "sgmii";
 		};
-- 
1.6.4
