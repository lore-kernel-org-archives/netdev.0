From: Kejian Yan <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [patch v3 net-next 1/2] dts: hisi: fixes no syscon fault when init mdio
Date: Wed, 13 Jan 2016 11:01:12 +0800
Message-ID: <1452654073-28039-3-git-send-email-yankejian@huawei.com>
References: <1452654073-28039-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	<mark.rutland-5wv7dgnIgG8@public.gmane.org>, <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	<galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
	<will.deacon-5wv7dgnIgG8@public.gmane.org>, <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
	<liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <arnd-r2nGTMty4D4@public.gmane.org>, <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	<lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1452654073-28039-1-git-send-email-yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

When linux start up, we get the log below:
"Hi-HNS_MDIO 803c0000.mdio: no syscon hisilicon,peri-c-subctrl
mdio_bus mdio@803c0000: mdio sys ctl reg has not maped"

The source code about the subctrl is dealt syscon, but dts doesn't.
It cause such fault, so this patch adds the syscon info on dts files to
fixes it.

Signed-off-by: Kejian Yan <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
change log:
v3:
 1) uses capital letter at the beginning of sentences
 2) updates the right device node name

v2:
 1) updates the related documented in the binding as well
 2) uses the normal naming conventions using '-' instead of '_'

v1:
 first submit

v2 patch link: https://lkml.org/lkml/2015/12/7/80
v1 patch link: https://lkml.org/lkml/2015/11/28/3
---
 .../devicetree/bindings/arm/hisilicon/hisilicon.txt      | 16 ++++++++++++++++
 arch/arm64/boot/dts/hisilicon/hip05.dtsi                 |  5 +++++
 arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi             |  4 ++--
 3 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/arm/hisilicon/hisilicon.txt b/Documentation/devicetree/bindings/arm/hisilicon/hisilicon.txt
index 6ac7c00..e3ccab1 100644
--- a/Documentation/devicetree/bindings/arm/hisilicon/hisilicon.txt
+++ b/Documentation/devicetree/bindings/arm/hisilicon/hisilicon.txt
@@ -187,6 +187,22 @@ Example:
 		reg = <0xb0000000 0x10000>;
 	};
 
+Hisilicon HiP05 PERISUB system controller
+
+Required properties:
+- compatible : "hisilicon,hip05-perisubc", "syscon";
+- reg : Register address and size
+
+The HiP05 PERISUB system controller is shared by peripheral controllers in
+HiP05 Soc to implement some basic configurations. The peripheral
+controllers include mdio, ddr, iic, uart, timer and so on.
+
+Example:
+	/* for HiP05 perisub-ctrl-c system */
+	peri_c_subctrl: syscon@80000000 {
+		compatible = "hisilicon,hip05-perisubc", "syscon";
+		reg = <0x0 0x80000000 0x0 0x10000>;
+	};
 -----------------------------------------------------------------------
 Hisilicon CPU controller
 
diff --git a/arch/arm64/boot/dts/hisilicon/hip05.dtsi b/arch/arm64/boot/dts/hisilicon/hip05.dtsi
index 4ff16d0..c1ea999 100644
--- a/arch/arm64/boot/dts/hisilicon/hip05.dtsi
+++ b/arch/arm64/boot/dts/hisilicon/hip05.dtsi
@@ -246,6 +246,11 @@
 			clock-frequency = <200000000>;
 		};
 
+		peri_c_subctrl: syscon@80000000 {
+			compatible = "hisilicon,hip05-perisubc", "syscon";
+			reg = < 0x0 0x80000000 0x0 0x10000>;
+		};
+
 		uart0: uart@80300000 {
 			compatible = "snps,dw-apb-uart";
 			reg = <0x0 0x80300000 0x0 0x10000>;
diff --git a/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
index 606dd5a..da7b6e6 100644
--- a/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
+++ b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
@@ -10,8 +10,8 @@ soc0: soc@000000000 {
 		#address-cells = <1>;
 		#size-cells = <0>;
 		compatible = "hisilicon,hns-mdio";
-		reg = <0x0 0x803c0000 0x0 0x10000
-		       0x0 0x80000000 0x0 0x10000>;
+		reg = <0x0 0x803c0000 0x0 0x10000>;
+		subctrl-vbase = <&peri_c_subctrl>;
 
 		soc0_phy0: ethernet-phy@0 {
 			reg = <0x0>;
-- 
2.4.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
