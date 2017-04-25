From: Eric Anholt <eric@anholt.net>
Subject: [PATCH v2 2/2] ARM: dts: Add the ethernet and ethernet PHY to the cygnus core DT.
Date: Tue, 25 Apr 2017 16:53:57 -0700
Message-ID: <20170425235357.7690-2-eric@anholt.net>
References: <20170425235357.7690-1-eric@anholt.net>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com, Ray Jui <rjui@broadcom.com>,
        Scott Branden <sbranden@broadcom.com>,
        Jon Mason <jonmason@broadcom.com>,
        Eric Anholt <eric@anholt.net>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170425235357.7690-1-eric@anholt.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cygnus has a single AMAC controller connected to the B53 switch with 2
PHYs.  On the BCM911360_EP platform, those two PHYs are connected to
the external ethernet jacks.

Signed-off-by: Eric Anholt <eric@anholt.net>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---

v2: Call the node "switch", just call the ports "port" (suggestions by
    Florian), drop max-speed on the phys (suggestion by Andrew Lunn),
    call the other nodes "ethernet" and "ethernet-phy" (suggestions by
    Sergei Shtylyov)

 arch/arm/boot/dts/bcm-cygnus.dtsi      | 58 ++++++++++++++++++++++++++++++++++
 arch/arm/boot/dts/bcm911360_entphn.dts |  8 +++++
 2 files changed, 66 insertions(+)

diff --git a/arch/arm/boot/dts/bcm-cygnus.dtsi b/arch/arm/boot/dts/bcm-cygnus.dtsi
index 009f1346b817..9fd89be0f5e0 100644
--- a/arch/arm/boot/dts/bcm-cygnus.dtsi
+++ b/arch/arm/boot/dts/bcm-cygnus.dtsi
@@ -142,6 +142,54 @@
 			interrupts = <0>;
 		};
 
+		mdio: mdio@18002000 {
+			compatible = "brcm,iproc-mdio";
+			reg = <0x18002000 0x8>;
+			#size-cells = <1>;
+			#address-cells = <0>;
+
+			gphy0: ethernet-phy@0 {
+				reg = <0>;
+			};
+
+			gphy1: ethernet-phy@1 {
+				reg = <1>;
+			};
+		};
+
+		switch: switch@18007000 {
+			compatible = "brcm,bcm11360-srab", "brcm,cygnus-srab";
+			reg = <0x18007000 0x1000>;
+			status = "disabled";
+
+			ports {
+				#address-cells = <1>;
+				#size-cells = <0>;
+
+				port@0 {
+					reg = <0>;
+					phy-handle = <&gphy0>;
+					phy-mode = "rgmii";
+				};
+
+				port@1 {
+					reg = <1>;
+					phy-handle = <&gphy1>;
+					phy-mode = "rgmii";
+				};
+
+				port@8 {
+					reg = <8>;
+					label = "cpu";
+					ethernet = <&eth0>;
+					fixed-link {
+						speed = <1000>;
+						full-duplex;
+					};
+				};
+			};
+		};
+
 		i2c0: i2c@18008000 {
 			compatible = "brcm,cygnus-iproc-i2c", "brcm,iproc-i2c";
 			reg = <0x18008000 0x100>;
@@ -295,6 +343,16 @@
 			status = "disabled";
 		};
 
+		eth0: ethernet@18042000 {
+			compatible = "brcm,amac";
+			reg = <0x18042000 0x1000>,
+			      <0x18110000 0x1000>;
+			reg-names = "amac_base", "idm_base";
+			interrupts = <GIC_SPI 110 IRQ_TYPE_LEVEL_HIGH>;
+			max-speed = <1000>;
+			status = "disabled";
+		};
+
 		nand: nand@18046000 {
 			compatible = "brcm,nand-iproc", "brcm,brcmnand-v6.1";
 			reg = <0x18046000 0x600>, <0xf8105408 0x600>,
diff --git a/arch/arm/boot/dts/bcm911360_entphn.dts b/arch/arm/boot/dts/bcm911360_entphn.dts
index 8b3800f46288..e037dea63f4a 100644
--- a/arch/arm/boot/dts/bcm911360_entphn.dts
+++ b/arch/arm/boot/dts/bcm911360_entphn.dts
@@ -57,6 +57,14 @@
 	};
 };
 
+&eth0 {
+	status = "okay";
+};
+
+&switch {
+	status = "okay";
+};
+
 &uart3 {
 	status = "okay";
 };
-- 
2.11.0
