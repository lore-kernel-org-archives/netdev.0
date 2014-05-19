From: Zhangfei Gao <zhangfei.gao@linaro.org>
Subject: [PATCH 2/3] Documentation: add Device tree bindings for Hisilicon hix5hd2 ethernet
Date: Mon, 19 May 2014 20:57:06 +0800
Message-ID: <1400504227-12047-3-git-send-email-zhangfei.gao@linaro.org>
References: <1400504227-12047-1-git-send-email-zhangfei.gao@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, Zhangfei Gao <zhangfei.gao@linaro.org>
To: davem@davemloft.net, arnd@arndb.de, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@ACULAB.COM, eric.dumazet@gmail.com,
	haifeng.yan@linaro.org, jchxue@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:43195 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932107AbaESM6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 08:58:20 -0400
Received: by mail-pb0-f54.google.com with SMTP id jt11so5894748pbb.27
        for <netdev@vger.kernel.org>; Mon, 19 May 2014 05:58:20 -0700 (PDT)
In-Reply-To: <1400504227-12047-1-git-send-email-zhangfei.gao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
---
 .../bindings/net/hisilicon-hix5hd2-net.txt         |   37 ++++++++++++++++++++
 1 file changed, 37 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hix5hd2-net.txt

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-net.txt b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-net.txt
new file mode 100644
index 0000000..16b1f0e
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-net.txt
@@ -0,0 +1,37 @@
+Hisilicon hix5hd2 Ethernet Controller
+
+Required properties:
+- compatible: should be "hisilicon,hix5hd2-mac".
+- reg : Specifies base physical address(s) and size of the device registers.
+  The first region is the mac register base and size.
+  The second region is external interface control register.
+- interrupts: Should contain the MAC interrupts
+- #address-cells: Must be <1>.
+- #size-cells: Must be <0>.
+- phy-mode: see ethernet.txt [1].
+- phy-handle: see ethernet.txt [1].
+- mac-address: see ethernet.txt [1].
+- clocks: clock phandle and specifier pair.
+
+- phy subnode: inherits from phy binding [2]
+
+[1] Documentation/devicetree/bindings/net/ethernet.txt
+[2] Documentation/devicetree/bindings/net/phy.txt
+
+Example:
+	gmac0: ethernet@f9840000 {
+		compatible = "hisilicon,hix5hd2-mac";
+		reg = <0xf9840000 0x1000>,<0xf984300c 0x4>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+		phy-handle = <&phy0>;
+		phy-mode = "mii";
+		mac-address = [00 00 00 00 00 00];
+		interrupts = <0 71 4>;
+		clocks = <&clock HIX5HD2_MAC0_CLK>;
+
+		phy0: ethernet-phy@2 {
+			reg = <2>;
+			compatible = "ethernet-phy-ieee802.3-c22";
+		};
+	};
-- 
1.7.9.5
