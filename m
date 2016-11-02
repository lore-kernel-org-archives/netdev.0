From: Jon Mason <jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v5 7/7] arm64: dts: NS2: add AMAC ethernet support
Date: Wed,  2 Nov 2016 13:08:08 -0400
Message-ID: <1478106488-11779-8-git-send-email-jon.mason@broadcom.com>
References: <1478106488-11779-1-git-send-email-jon.mason@broadcom.com>
Cc: rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org, bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1478106488-11779-1-git-send-email-jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add support for the AMAC ethernet to the Broadcom Northstar2 SoC device
tree

Signed-off-by: Jon Mason <jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
---
 arch/arm64/boot/dts/broadcom/ns2-svk.dts |  5 +++++
 arch/arm64/boot/dts/broadcom/ns2.dtsi    | 12 ++++++++++++
 2 files changed, 17 insertions(+)

diff --git a/arch/arm64/boot/dts/broadcom/ns2-svk.dts b/arch/arm64/boot/dts/broadcom/ns2-svk.dts
index 2d7872a..2e4d90d 100644
--- a/arch/arm64/boot/dts/broadcom/ns2-svk.dts
+++ b/arch/arm64/boot/dts/broadcom/ns2-svk.dts
@@ -56,6 +56,10 @@
 	};
 };
 
+&enet {
+	status = "ok";
+};
+
 &pci_phy0 {
 	status = "ok";
 };
@@ -172,6 +176,7 @@
 &mdio_mux_iproc {
 	mdio@10 {
 		gphy0: eth-phy@10 {
+			enet-phy-lane-swap;
 			reg = <0x10>;
 		};
 	};
diff --git a/arch/arm64/boot/dts/broadcom/ns2.dtsi b/arch/arm64/boot/dts/broadcom/ns2.dtsi
index d95dc40..773ed59 100644
--- a/arch/arm64/boot/dts/broadcom/ns2.dtsi
+++ b/arch/arm64/boot/dts/broadcom/ns2.dtsi
@@ -191,6 +191,18 @@
 
 		#include "ns2-clock.dtsi"
 
+		enet: ethernet@61000000 {
+			compatible = "brcm,ns2-amac";
+			reg = <0x61000000 0x1000>,
+			      <0x61090000 0x1000>,
+			      <0x61030000 0x100>;
+			reg-names = "amac_base", "idm_base", "nicpm_base";
+			interrupts = <GIC_SPI 341 IRQ_TYPE_LEVEL_HIGH>;
+			phy-handle = <&gphy0>;
+			phy-mode = "rgmii";
+			status = "disabled";
+		};
+
 		dma0: dma@61360000 {
 			compatible = "arm,pl330", "arm,primecell";
 			reg = <0x61360000 0x1000>;
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
