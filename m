From: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next v11 1/3] Documentation: add Device tree bindings for Hisilicon hip04 ethernet
Date: Mon, 12 Jan 2015 16:03:50 +0800
Message-ID: <1421049832-6224-2-git-send-email-dingtianhong@huawei.com>
References: <1421049832-6224-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
To: <arnd-r2nGTMty4D4@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1421049832-6224-1-git-send-email-dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Zhangfei Gao <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>

This patch adds the Device Tree bindings for the Hisilicon hip04
Ethernet controller, including 100M / 1000M controller.

Signed-off-by: Zhangfei Gao <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Signed-off-by: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 .../bindings/net/hisilicon-hip04-net.txt           | 88 ++++++++++++++++++++++
 1 file changed, 88 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt b/Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt
new file mode 100644
index 0000000..988fc69
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt
@@ -0,0 +1,88 @@
+Hisilicon hip04 Ethernet Controller
+
+* Ethernet controller node
+
+Required properties:
+- compatible: should be "hisilicon,hip04-mac".
+- reg: address and length of the register set for the device.
+- interrupts: interrupt for the device.
+- port-handle: <phandle port channel>
+	phandle, specifies a reference to the syscon ppe node
+	port, port number connected to the controller
+	channel, recv channel start from channel * number (RX_DESC_NUM)
+- phy-mode: see ethernet.txt [1].
+
+Optional properties:
+- phy-handle: see ethernet.txt [1].
+
+[1] Documentation/devicetree/bindings/net/ethernet.txt
+
+
+* Ethernet ppe node:
+Control rx & tx fifos of all ethernet controllers.
+Have 2048 recv channels shared by all ethernet controllers, only if no overlap.
+Each controller's recv channel start from channel * number (RX_DESC_NUM).
+
+Required properties:
+- compatible: "hisilicon,hip04-ppe", "syscon".
+- reg: address and length of the register set for the device.
+
+
+* MDIO bus node:
+
+Required properties:
+
+- compatible: should be "hisilicon,hip04-mdio".
+- Inherits from MDIO bus node binding [2]
+[2] Documentation/devicetree/bindings/net/phy.txt
+
+Example:
+	mdio {
+		compatible = "hisilicon,hip04-mdio";
+		reg = <0x28f1000 0x1000>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		phy0: ethernet-phy@0 {
+			compatible = "ethernet-phy-ieee802.3-c22";
+			reg = <0>;
+			marvell,reg-init = <18 0x14 0 0x8001>;
+		};
+
+		phy1: ethernet-phy@1 {
+			compatible = "ethernet-phy-ieee802.3-c22";
+			reg = <1>;
+			marvell,reg-init = <18 0x14 0 0x8001>;
+		};
+	};
+
+	ppe: ppe@28c0000 {
+		compatible = "hisilicon,hip04-ppe", "syscon";
+		reg = <0x28c0000 0x10000>;
+	};
+
+	fe: ethernet@28b0000 {
+		compatible = "hisilicon,hip04-mac";
+		reg = <0x28b0000 0x10000>;
+		interrupts = <0 413 4>;
+		phy-mode = "mii";
+		port-handle = <&ppe 31 0>;
+	};
+
+	ge0: ethernet@2800000 {
+		compatible = "hisilicon,hip04-mac";
+		reg = <0x2800000 0x10000>;
+		interrupts = <0 402 4>;
+		phy-mode = "sgmii";
+		port-handle = <&ppe 0 1>;
+		phy-handle = <&phy0>;
+	};
+
+	ge8: ethernet@2880000 {
+		compatible = "hisilicon,hip04-mac";
+		reg = <0x2880000 0x10000>;
+		interrupts = <0 410 4>;
+		phy-mode = "sgmii";
+		port-handle = <&ppe 8 2>;
+		phy-handle = <&phy1>;
+	};
-- 
1.8.0


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
