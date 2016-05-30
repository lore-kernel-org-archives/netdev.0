From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: [PATCH 4/7] DT:mdio-mux: Add mdio multiplexer driver node
Date: Mon, 30 May 2016 12:40:48 +0530
Message-ID: <1464592251-2688-5-git-send-email-pramod.kumar@broadcom.com>
References: <1464592251-2688-1-git-send-email-pramod.kumar@broadcom.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33342 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754219AbcE3HKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 03:10:50 -0400
Received: by mail-pf0-f173.google.com with SMTP id b124so61942431pfb.0
        for <netdev@vger.kernel.org>; Mon, 30 May 2016 00:10:44 -0700 (PDT)
In-Reply-To: <1464592251-2688-1-git-send-email-pramod.kumar@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add integrated MDIO multiplexer driver node which contains
two mux PCIe bus and one ethernet bus along with phys
lying on these bus.

Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
---
 arch/arm64/boot/dts/broadcom/ns2-svk.dts | 12 ++++++++++++
 arch/arm64/boot/dts/broadcom/ns2.dtsi    | 32 ++++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+)

diff --git a/arch/arm64/boot/dts/broadcom/ns2-svk.dts b/arch/arm64/boot/dts/broadcom/ns2-svk.dts
index ce0ab84..8f6a6cc 100644
--- a/arch/arm64/boot/dts/broadcom/ns2-svk.dts
+++ b/arch/arm64/boot/dts/broadcom/ns2-svk.dts
@@ -87,3 +87,15 @@
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
index 6f81c9d..efc320a 100644
--- a/arch/arm64/boot/dts/broadcom/ns2.dtsi
+++ b/arch/arm64/boot/dts/broadcom/ns2.dtsi
@@ -330,6 +330,38 @@
 			      <0x65260000 0x1000>;
 		};
 
+		mdio_mux_iproc: mdio_mux_iproc@6602023c {
+			compatible = "brcm,mdio-mux-iproc";
+			reg = <0x6602023c 0x14>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+			mdio-integrated-mux;
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
