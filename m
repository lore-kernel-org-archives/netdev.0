From: Zhangfei Gao <zhangfei.gao@linaro.org>
Subject: [PATCH 1/3] Documentation: add Device tree bindings for Hisilicon hip04 ethernet
Date: Fri, 21 Mar 2014 23:09:28 +0800
Message-ID: <1395414570-25515-2-git-send-email-zhangfei.gao@linaro.org>
References: <1395414570-25515-1-git-send-email-zhangfei.gao@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, Zhangfei Gao <zhangfei.gao@linaro.org>
To: "David S. Miller" <davem@davemloft.net>, linux@arm.linux.org.uk,
	arnd@arndb.de, f.fainelli@gmail.com, mark.rutland@arm.com,
	sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:44652 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760459AbaCUPKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 11:10:02 -0400
Received: by mail-ie0-f169.google.com with SMTP id to1so2595885ieb.0
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 08:10:02 -0700 (PDT)
In-Reply-To: <1395414570-25515-1-git-send-email-zhangfei.gao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the Device Tree bindings for the Hisilicon hip04
Ethernet controller, including 100M / 1000M controller.

Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
---
 .../bindings/net/hisilicon-hip04-net.txt           |  107 ++++++++++++++++++++
 1 file changed, 107 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt b/Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt
new file mode 100644
index 0000000..22838b2
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt
@@ -0,0 +1,107 @@
+Hisilicon hip04 Ethernet Controller
+
+* Ethernet controller node
+
+Required properties:
+- compatible: should be "hisilicon,hip04-mac".
+- reg: address and length of the register set for the device.
+- interrupts: interrupt for the device.
+- port-handle: phandle, specifies a reference to a node representing
+  the connected port
+- Inherets from ethernet common binding [1]
+[1] Documentation/devicetree/bindings/net/ethernet.txt
+
+
+* Ethernet ppe node:
+Control rx & tx fifos of all ethernet controllers.
+Have 2048 recv channels shared by all ethernet controllers, only if no overlap.
+Each controller's start recv channel is alisa_id * RX_DESC_NUM.
+
+Required properties:
+- #address-cells : Should be <1>
+- #size-cells : Should be <0>
+- compatible: "hisilicon,hip04-ppe"
+- reg: address and length of the register set for the device.
+
+==Child node==
+
+Required properties:
+- reg: port physical number, range from 0 to 0x1f
+
+
+* MDIO bus node:
+
+Required properties:
+
+- compatible: should be "hisilicon,hip04-mdio", "ethernet-phy-ieee802.3-c22".
+- Inherets from MDIO bus node binding [2]
+[2] Documentation/devicetree/bindings/net/phy.txt
+
+Example:
+	aliases {
+		ethernet0 = &fe;
+		ethernet1 = &ge0;
+		ethernet2 = &ge8;
+	};
+
+	mdio {
+		compatible = "hisilicon,hip04-mdio", "ethernet-phy-ieee802.3-c22";
+		reg = <0x28f1000 0x1000>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		phy0: ethernet-phy@0 {
+			reg = <0>;
+			marvell,reg-init = <18 0x14 0 0x8001>;
+		};
+
+		phy1: ethernet-phy@1 {
+			reg = <1>;
+			marvell,reg-init = <18 0x14 0 0x8001>;
+		};
+	};
+
+	ppe: ppe@28c0000 {
+		compatible = "hisilicon,hip04-ppe";
+		reg = <0x28c0000 0x10000>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		eth0_port: port@1f {
+			reg = <0x1f>;
+		};
+
+		eth1_port: port@0 {
+			reg = <0>;
+		};
+
+		eth2_port: port@8 {
+			reg = <8>;
+		};
+	};
+
+	fe: ethernet@28b0000 {
+		compatible = "hisilicon,hip04-mac";
+		reg = <0x28b0000 0x10000>;
+		interrupts = <0 413 4>;
+		phy-mode = "mii";
+		port-handle = <&eth0_port>;
+	};
+
+	ge0: ethernet@2800000 {
+		compatible = "hisilicon,hip04-mac";
+		reg = <0x2800000 0x10000>;
+		interrupts = <0 402 4>;
+		phy-mode = "sgmii";
+		port-handle = <&eth1_port>;
+		phy-handle = <&phy0>;
+	};
+
+	ge8: ethernet@2880000 {
+		compatible = "hisilicon,hip04-mac";
+		reg = <0x2880000 0x10000>;
+		interrupts = <0 410 4>;
+		phy-mode = "sgmii";
+		port-handle = <&eth2_port>;
+		phy-handle = <&phy1>;
+	};
-- 
1.7.9.5
