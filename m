From: Zhangfei Gao <zhangfei.gao@linaro.org>
Subject: [PATCH v2 1/2] Documentation: add Device tree bindings for Hisilicon hix5hd2 ethernet
Date: Tue, 27 May 2014 20:44:26 +0800
Message-ID: <1401194667-14445-2-git-send-email-zhangfei.gao@linaro.org>
References: <1401194667-14445-1-git-send-email-zhangfei.gao@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, Zhangfei Gao <zhangfei.gao@linaro.org>
To: davem@davemloft.net, arnd@arndb.de, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@ACULAB.COM, eric.dumazet@gmail.com,
	haifeng.yan@linaro.org, jchxue@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:61211 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831AbaE0Moo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 08:44:44 -0400
Received: by mail-pb0-f42.google.com with SMTP id md12so9254329pbc.29
        for <netdev@vger.kernel.org>; Tue, 27 May 2014 05:44:44 -0700 (PDT)
In-Reply-To: <1401194667-14445-1-git-send-email-zhangfei.gao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
---
 .../bindings/net/hisilicon-hix5hd2-gmac.txt        |   36 ++++++++++++++++++++
 1 file changed, 36 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
new file mode 100644
index 0000000..5fe3835
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
@@ -0,0 +1,36 @@
+Hisilicon hix5hd2 gmac controller
+
+Required properties:
+- compatible: should be "hisilicon,hix5hd2-gmac".
+- reg: specifies base physical address(s) and size of the device registers.
+  The first region is the MAC register base and size.
+  The second region is external interface control register.
+- interrupts: should contain the MAC interrupts
+- #address-cells: must be <1>.
+- #size-cells: must be <0>.
+- phy-mode: see ethernet.txt [1].
+- phy-handle: see ethernet.txt [1].
+- mac-address: see ethernet.txt [1].
+- clocks: clock phandle and specifier pair.
+
+- PHY subnode: inherits from phy binding [2]
+
+[1] Documentation/devicetree/bindings/net/ethernet.txt
+[2] Documentation/devicetree/bindings/net/phy.txt
+
+Example:
+	gmac0: ethernet@f9840000 {
+		compatible = "hisilicon,hix5hd2-gmac";
+		reg = <0xf9840000 0x1000>,<0xf984300c 0x4>;
+		interrupts = <0 71 4>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+		phy-mode = "mii";
+		phy-handle = <&phy2>;
+		mac-address = [00 00 00 00 00 00];
+		clocks = <&clock HIX5HD2_MAC0_CLK>;
+
+		phy2: ethernet-phy@2 {
+			reg = <2>;
+		};
+	};
-- 
1.7.9.5
