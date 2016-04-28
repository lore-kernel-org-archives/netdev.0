From: Yisen Zhuang <Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 3/4] Documentation: Bindings: Update DT binding for hns dsaf node
Date: Thu, 28 Apr 2016 15:09:03 +0800
Message-ID: <1461827344-52230-4-git-send-email-Yisen.Zhuang@huawei.com>
References: <1461827344-52230-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	<catalin.marinas-5wv7dgnIgG8@public.gmane.org>, <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xieqianqian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461827344-52230-1-git-send-email-Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch changes property port-id to reg in dsaf port node,
removes property cpld-ctrl-reg, and fixes some typos.

Signed-off-by: Yisen Zhuang <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 .../devicetree/bindings/net/hisilicon-hns-dsaf.txt | 28 ++++++++++------------
 1 file changed, 13 insertions(+), 15 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
index 5ccd4f0..d4b7f2e 100644
--- a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
+++ b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
@@ -13,10 +13,10 @@ Required properties:
 - interrupts: should contain the DSA Fabric and rcb interrupt.
 - reg: specifies base physical address(es) and size of the device registers.
   The first region is external interface control register base and size(optional,
-  only be used when subctrl-syscon is not exists). It is recommended using
+  only used when subctrl-syscon does not exist). It is recommended using
   subctrl-syscon rather than this address.
-  The second region is SerDes base register and size(optional, only be used when
-  serdes-syscon in port node is not exists. It is recommended using
+  The second region is SerDes base register and size(optional, only used when
+  serdes-syscon in port node does not exist). It is recommended using
   serdes-syscon rather than this address.
   The third region is the PPE register base and size.
   The fourth region is dsa fabric base register and size. It is not required for
@@ -24,8 +24,8 @@ Required properties:
 - reg-names: may be ppe-base and(or) dsaf-base. It is used to find the
   corresponding reg's index.
 
-- phy-handle: phy handle of physicl port, 0 if not any phy device. It is optional
-  attribute. If port node is exists, phy-handle in each port node will be used.
+- phy-handle: phy handle of physical port, 0 if not any phy device. It is optional
+  attribute. If port node exists, phy-handle in each port node will be used.
   see ethernet.txt [1].
 - subctrl-syscon: is syscon handle for external interface control register.
 - reset-field-offset: is offset of reset field. Its value depends on the hardware
@@ -35,14 +35,12 @@ Required properties:
 
 - port: subnodes of dsaf. A dsaf node may contain several port nodes(Depending
   on mode of dsaf). Port node contain some attributes listed below:
-- port-id: is physical port index in one dsaf.
-- phy-handle: phy handle of physicl port. It is not required if there isn't
+- reg: is physical port index in one dsaf.
+- phy-handle: phy handle of physical port. It is not required if there isn't
   phy device. see ethernet.txt [1].
 - serdes-syscon: is syscon handle for SerDes register.
-- cpld-syscon: is syscon handle for cpld register. It is not required if there
-  isn't cpld device.
-- cpld-ctrl-reg: is cpld register offset. It is not required if there isn't
-  cpld-syscon.
+- cpld-syscon: is syscon handle + register offset pair for cpld register. It is
+  not required if there isn't cpld device.
 - port-rst-offset: is offset of reset field for each port in dsaf. Its value
   depends on the hardware user manual.
 - port-mode-offset: is offset of port mode field for each port in dsaf. Its
@@ -72,14 +70,14 @@ dsaf0: dsa@c7000000 {
 	desc-num = <1024>;
 	dma-coherent;
 
-	prot@0 {
-		port-id = 0;
+	port@0 {
+		reg = 0;
 		phy-handle = <&phy0>;
 		serdes-syscon = <&serdes>;
 	};
 
-	prot@1 {
-                port-id = 1;
+	port@1 {
+                reg = 1;
                 serdes-syscon = <&serdes>;
         };
 };
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
