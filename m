From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v9 1/3] Documentation: add Device tree bindings for Hisilicon hip04 ethernet
Date: Thu, 11 Dec 2014 19:42:28 +0800
Message-ID: <1418298150-4944-2-git-send-email-dingtianhong@huawei.com>
References: <1418298150-4944-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>
To: <zhangfei.gao@linaro.org>, <davem@davemloft.net>,
	<linux@arm.linux.org.uk>, <arnd@arndb.de>, <f.fainelli@gmail.com>,
	<sergei.shtylyov@cogentembedded.com>, <mark.rutland@arm.com>,
	<David.Laight@ACULAB.COM>, <eric.dumazet@gmail.com>,
	<xuwei5@hisilicon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:33199 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbaLKLnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 06:43:43 -0500
In-Reply-To: <1418298150-4944-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhangfei Gao <zhangfei.gao@linaro.org>

This patch adds the Device Tree bindings for the Hisilicon hip04
Ethernet controller, including 100M / 1000M controller.

Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
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
