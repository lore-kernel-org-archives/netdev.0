From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: [PATCH 2/6] Documentation: DT binding doc for iProc Shared MDIO Controller.
Date: Thu, 21 Apr 2016 14:48:39 +0530
Message-ID: <1461230323-27891-3-git-send-email-pramod.kumar@broadcom.com>
References: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
Cc: BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Suzuki K Poulose <suzuki.poulose@arm.com>,
	Punit Agrawal <punit.agrawal@arm.com>,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Pramod Kumar <pramod.kumar@broadcom.com>
To: Rob Herring <robh+dt@kernel.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Chen-Yu Tsai <wens@csie.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add DT binding doc for iProc Shared MDIO Controller which
populate all masters to Shared MDIO framework.

Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
Reviewed-by: Ray Jui <ray.jui@broadcom.com>
Reviewed-by: Scott Branden <scott.branden@broadcom.com>
---
 .../bindings/bus/brcm,iproc-shared-mdio.txt        | 76 ++++++++++++++++++++++
 1 file changed, 76 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/bus/brcm,iproc-shared-mdio.txt

diff --git a/Documentation/devicetree/bindings/bus/brcm,iproc-shared-mdio.txt b/Documentation/devicetree/bindings/bus/brcm,iproc-shared-mdio.txt
new file mode 100644
index 0000000..f455f3d
--- /dev/null
+++ b/Documentation/devicetree/bindings/bus/brcm,iproc-shared-mdio.txt
@@ -0,0 +1,76 @@
+Broadcom iProc Shared MDIO Controller
+
+Required properties:
+- compatible:
+    "brcm,iproc-shared-mdio" for shared MDIO controller.
+- reg: specifies the base physical address and size of the registers
+- reg-names: should be "mdio"
+- #address-cells: must be 1.
+- #size-cells: must be 0.
+
+optional:
+child nodes: Masters are represented as a child node of shared MDIO controller
+and all the PHYs handled by this master are represented as its child node.
+
+Master nodes properties are defined as-
+
+Required properties:
+- compatible: Used to match driver of this PHY.
+- reg: MDIO master ID.
+- #address-cells: must be 1.
+- #size-cells: must be 0.
+
+optional:
+-brcm,phy-internal: if presents, PHYs are internal. Absence shows phy is
+external.
+-brcm,is-c45: if presents, Controller uses Clause-45 to issue MDIO transaction.
+else Controller uses Clause-22 for transactions.
+
+PHY nodes are represented as the child node of Master. Child nodes properties
+are defined as-
+
+Required properties:
+-reg: phy id of attached PHY.
+
+optional:
+There could be additional properties required to configure the specific phy like
+phy-mode in case of gpphy node below. These should be defined here and used by
+respective drivers.
+
+Example:
+iproc_mdio: iproc_mdio@663f0000 {
+	compatible = "brcm,iproc-shared-mdio";
+	reg = <0x6602023c 0x14>;
+	reg-names = "mdio";
+	#address-cells = <1>;
+	#size-cells = <0>;
+
+	sata-master@6 {
+		compatible = "brcm,iproc-ns2-sata-phy";
+		reg = <0x6>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+		brcm,phy-internal;
+
+		sata_phy0: sata-phy@1 {
+			reg = <0x1>;
+			#phy-cells = <0>;
+		};
+
+		sata_phy1: sata-phy@2 {
+			reg = <0x2>;
+			#phy-cells = <0>;
+		};
+	};
+
+	eth-master@0 {
+		compatible = "brcm,iproc-mdio-master-eth";
+		reg = <0x0>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+		gphy0: eth-phy@10 {
+			reg = <0x10>;
+			phy-mode = "mii";
+		};
+	};
+};
-- 
1.9.1
