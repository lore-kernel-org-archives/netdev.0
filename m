From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/3] ARM: dts: Enable SRAB switch and GMACs on 5301x DTS
Date: Fri,  8 Jul 2016 11:48:51 -0700
Message-ID: <1468003735-26895-2-git-send-email-f.fainelli@gmail.com>
References: <1468003735-26895-1-git-send-email-f.fainelli@gmail.com>
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
	vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1468003735-26895-1-git-send-email-f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add the Switch Register Access Block which is a special piece of
hardware allowing us to perform indirect read/writes towards the
integrated BCM5301X Ethernet switch.

We also add the 4 Gigabit MAC Device Tree nodes within the brcm,bus-axi
bus node to get proper binding between the BCMA instantiated core and
the Device Tree nodes. We will need that to be able to reference
Ethernet Device Tree nodes in a future patch adding the switch ports
layout.

Signed-off-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 arch/arm/boot/dts/bcm5301x.dtsi | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/arch/arm/boot/dts/bcm5301x.dtsi b/arch/arm/boot/dts/bcm5301x.dtsi
index 7d4d29bf0ed3..9fb565841004 100644
--- a/arch/arm/boot/dts/bcm5301x.dtsi
+++ b/arch/arm/boot/dts/bcm5301x.dtsi
@@ -239,6 +239,22 @@
 				status = "disabled";
 			};
 		};
+
+		gmac0: ethernet@24000 {
+			reg = <0x24000 0x800>;
+		};
+
+		gmac1: ethernet@25000 {
+			reg = <0x25000 0x800>;
+		};
+
+		gmac2: ethernet@26000 {
+			reg = <0x26000 0x800>;
+		};
+
+		gmac3: ethernet@27000 {
+			reg = <0x27000 0x800>;
+		};
 	};
 
 	lcpll0: lcpll0@1800c100 {
@@ -260,6 +276,17 @@
 				     "sata2";
 	};
 
+	srab: srab@18007000 {
+		compatible = "brcm,bcm5301x-srab";
+		reg = <0x18007000 0x1000>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		status = "disabled";
+
+		/* ports are defined in board DTS */
+	};
+
 	nand: nand@18028000 {
 		compatible = "brcm,nand-iproc", "brcm,brcmnand-v6.1", "brcm,brcmnand";
 		reg = <0x18028000 0x600>, <0x1811a408 0x600>, <0x18028f00 0x20>;
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
