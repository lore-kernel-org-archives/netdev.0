From: Keyur Chudgar <kchudgar@apm.com>
Subject: [PATCH v1 2/3] dtb: xgene: Add second SGMII based 1G interface node
Date: Tue, 17 Mar 2015 11:27:12 -0700
Message-ID: <1426616833-9671-3-git-send-email-kchudgar@apm.com>
References: <1426616833-9671-1-git-send-email-kchudgar@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Keyur Chudgar <kchudgar@apm.com>, patches@apm.com,
 linux-arm-kernel@lists.infradead.org,
 Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net,
	netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1426616833-9671-1-git-send-email-kchudgar@apm.com>
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

- Added new SGMII node for port 1
- Added port-id field

Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 arch/arm64/boot/dts/apm/apm-mustang.dts |  4 ++++
 arch/arm64/boot/dts/apm/apm-storm.dtsi  | 25 +++++++++++++++++++++++++
 2 files changed, 29 insertions(+)

diff --git a/arch/arm64/boot/dts/apm/apm-mustang.dts b/arch/arm64/boot/dts/apm/apm-mustang.dts
index 2e25de0..83578e7 100644
--- a/arch/arm64/boot/dts/apm/apm-mustang.dts
+++ b/arch/arm64/boot/dts/apm/apm-mustang.dts
@@ -45,6 +45,10 @@
 	status = "ok";
 };
 
+&sgenet1 {
+	status = "ok";
+};
+
 &xgenet {
 	status = "ok";
 };
diff --git a/arch/arm64/boot/dts/apm/apm-storm.dtsi b/arch/arm64/boot/dts/apm/apm-storm.dtsi
index a857794..c1eb691 100644
--- a/arch/arm64/boot/dts/apm/apm-storm.dtsi
+++ b/arch/arm64/boot/dts/apm/apm-storm.dtsi
@@ -186,6 +186,16 @@
 				clock-output-names = "sge0clk";
 			};
 
+			sge1clk: sge1clk@1f21c000 {
+				compatible = "apm,xgene-device-clock";
+				#clock-cells = <1>;
+				clocks = <&socplldiv2 0>;
+				reg = <0x0 0x1f21c000 0x0 0x1000>;
+				reg-names = "csr-reg";
+				csr-mask = <0xc>;
+				clock-output-names = "sge1clk";
+			};
+
 			xge0clk: xge0clk@1f61c000 {
 				compatible = "apm,xgene-device-clock";
 				#clock-cells = <1>;
@@ -635,6 +645,21 @@
 			phy-connection-type = "sgmii";
 		};
 
+		sgenet1: ethernet@1f210030 {
+			compatible = "apm,xgene1-sgenet";
+			status = "disabled";
+			reg = <0x0 0x1f210030 0x0 0xd100>,
+			      <0x0 0x1f200000 0x0 0Xc300>,
+			      <0x0 0x1B000000 0x0 0X8000>;
+			reg-names = "enet_csr", "ring_csr", "ring_cmd";
+			interrupts = <0x0 0xAC 0x4>;
+			port-id = <1>;
+			dma-coherent;
+			clocks = <&sge1clk 0>;
+			local-mac-address = [00 00 00 00 00 00];
+			phy-connection-type = "sgmii";
+		};
+
 		xgenet: ethernet@1f610000 {
 			compatible = "apm,xgene1-xgenet";
 			status = "disabled";
-- 
1.9.1
