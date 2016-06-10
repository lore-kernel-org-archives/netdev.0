From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: [PATCH v5 3/7] binding: mdio-mux: Add DT binding doc for Broadcom MDIO bus multiplexer
Date: Fri, 10 Jun 2016 11:03:47 +0530
Message-ID: <1465536831-13023-4-git-send-email-pramod.kumar@broadcom.com>
References: <1465536831-13023-1-git-send-email-pramod.kumar@broadcom.com>
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
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34412 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570AbcFJFeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 01:34:20 -0400
Received: by mail-pa0-f50.google.com with SMTP id bz2so20242115pad.1
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 22:34:20 -0700 (PDT)
In-Reply-To: <1465536831-13023-1-git-send-email-pramod.kumar@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add DT binding doc for Broadcom MDIO bus multiplexer driver.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Acked-by: Rob Herring <robh@kernel.org>
---
 .../bindings/net/brcm,mdio-mux-iproc.txt           | 59 ++++++++++++++++++++++
 1 file changed, 59 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt

diff --git a/Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt b/Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt
new file mode 100644
index 0000000..dfe287a
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt
@@ -0,0 +1,59 @@
+Properties for an MDIO bus multiplexer found in Broadcom iProc based SoCs.
+
+This MDIO bus multiplexer defines buses that could be internal as well as
+external to SoCs and could accept MDIO transaction compatible to C-22 or
+C-45 Clause. When child bus is selected, one needs to select these two
+properties as well to generate desired MDIO transaction on appropriate bus.
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
