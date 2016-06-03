From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: [PATCH v3 3/7] binding: mdio-mux: Add DT binding doc for Broadcom MDIO bus mutiplexer
Date: Fri,  3 Jun 2016 20:56:04 +0530
Message-ID: <1464967568-27562-4-git-send-email-pramod.kumar@broadcom.com>
References: <1464967568-27562-1-git-send-email-pramod.kumar@broadcom.com>
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
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35557 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422656AbcFCP0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 11:26:48 -0400
Received: by mail-pf0-f171.google.com with SMTP id g64so44785788pfb.2
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 08:26:47 -0700 (PDT)
In-Reply-To: <1464967568-27562-1-git-send-email-pramod.kumar@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add DT binding doc for Broadcom MDIO bus mutiplexer driver.

Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
---
 .../bindings/net/brcm,mdio-mux-iproc.txt           | 59 ++++++++++++++++++++++
 1 file changed, 59 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt

diff --git a/Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt b/Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt
new file mode 100644
index 0000000..7c53278
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt
@@ -0,0 +1,59 @@
+Properties for an MDIO bus mutiplexer found in Broadcom iProc based SoCs.
+
+This MDIO bus multiplexer defines buses that could be internal as well as
+external to SoCs and could accept MDIO transaction compatible to C-22 or
+C-45 Clause. When child bus is selected, one needs to select these two
+properties as well to generate desired MDIO trascation on appropriate bus.
+
+Required properties in addition to the generic multiplexer properties:
+
+MDIO multiplexer node:
+- compatible: brcm,mdio-mux-iproc.
+
+Every non-ethernet PHY requires a compatible so that it could be probed based
+on this compatible string.
+
+Additional information regarding generic multiplexer properties can be found
+at- Documentation/devicetree/bindings/net/mdio-mux.txt
+
+
+for example:
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
+			mdio@10 {
+				reg = <0x10>;
+				#address-cells = <1>;
+				#size-cells = <0>;
+
+				gphy0: eth-phy@10 {
+					reg = <0x10>;
+				};
+			};
+		};
-- 
1.9.1
