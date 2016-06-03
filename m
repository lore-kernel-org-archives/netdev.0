From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: [PATCH v3 RESEND 4/7] dt:mdio-mux: Add mdio multiplexer driver node
Date: Fri,  3 Jun 2016 21:33:03 +0530
Message-ID: <1464969786-22742-5-git-send-email-pramod.kumar@broadcom.com>
References: <1464969786-22742-1-git-send-email-pramod.kumar@broadcom.com>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Pramod Kumar <pramod.kumar@broadcom.com>
To: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464969786-22742-1-git-send-email-pramod.kumar@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add integrated MDIO multiplexer driver node which contains
two mux PCIe bus and one ethernet bus along with phys
lying on these bus.

Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
---
 arch/arm64/boot/dts/broadcom/ns2-svk.dts | 12 ++++++++++++
 arch/arm64/boot/dts/broadcom/ns2.dtsi    | 31 +++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+)

diff --git a/arch/arm64/boot/dts/broadcom/ns2-svk.dts b/arch/arm64/boot/dts/broadcom/ns2-svk.dts
index 54ca40c..71f8503 100644
--- a/arch/arm64/boot/dts/broadcom/ns2-svk.dts
+++ b/arch/arm64/boot/dts/broadcom/ns2-svk.dts
@@ -132,3 +132,15 @@
 		#size-cells = <1>;
 	};
 };
+
+&mdio_mux_iproc {
+	mdio@10 {
+		reg = <0x10>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		gphy0: eth-phy@10 {
+			reg = <0x10>;
+		};
+	};
+};
diff --git a/arch/arm64/boot/dts/broadcom/ns2.dtsi b/arch/arm64/boot/dts/broadcom/ns2.dtsi
index ec68ec1..9f20a66 100644
--- a/arch/arm64/boot/dts/broadcom/ns2.dtsi
+++ b/arch/arm64/boot/dts/broadcom/ns2.dtsi
@@ -263,6 +263,37 @@
 				      IRQ_TYPE_LEVEL_HIGH)>;
 		};
 
+		mdio_mux_iproc: mdio-mux@6602023c {
+			compatible = "brcm,mdio-mux-iproc";
+			reg = <0x6602023c 0x14>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			mdio@0 {
+				reg = <0x0>;
+				#address-cells = <1>;
+				#size-cells = <0>;
+
+				pci_phy0: pci-phy@0 {
+					compatible = "brcm,ns2-pcie-phy";
+					reg = <0x0>;
+					#phy-cells = <0>;
+				};
+			};
+
+			mdio@7 {
+				reg = <0x7>;
+				#address-cells = <1>;
+				#size-cells = <0>;
+
+				pci_phy1: pci-phy@0 {
+					compatible = "brcm,ns2-pcie-phy";
+					reg = <0x0>;
+					#phy-cells = <0>;
+				};
+			};
+		};
+
 		timer0: timer@66030000 {
 			compatible = "arm,sp804", "arm,primecell";
 			reg = <0x66030000 0x1000>;
-- 
1.9.1
