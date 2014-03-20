From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH V8 1/7] sxgbe: Add device-tree binding support document
Date: Thu, 20 Mar 2014 10:25:59 -0700
Message-ID: <012e01cf4461$79852880$6c8f7980$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem@davemloft.net>,
	'GIRISH K S' <ks.giri@samsung.com>,
	'SIVAREDDY KALLAM' <siva.kallam@samsung.com>,
	'Vipul Chandrakant' <vipul.pandya@samsung.com>,
	'Ilho Lee' <ilho215.lee@samsung.com>
To: 'netdev' <netdev@vger.kernel.org>,
	linux-samsung-soc@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:39020 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759358AbaCTR0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 13:26:11 -0400
Content-language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Siva Reddy <siva.kallam@samsung.com>

This patch adds binding document for SXGBE ethernet driver via device-tree.

Signed-off-by: Siva Reddy Kallam <siva.kallam@samsung.com>
Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 .../devicetree/bindings/net/samsung-sxgbe.txt      |   60 ++++++++++++++++++++
 1 file changed, 60 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/samsung-sxgbe.txt

diff --git a/Documentation/devicetree/bindings/net/samsung-sxgbe.txt b/Documentation/devicetree/bindings/net/samsung-sxgbe.txt
new file mode 100644
index 0000000..231acf8
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/samsung-sxgbe.txt
@@ -0,0 +1,60 @@
+* Samsung 10G Ethernet driver (SXGBE)
+
+Required properties:
+- compatible: Should be "samsung,sxgbe-v2.0a"
+- reg: Address and length of the register set for the device
+- interrupt-parent: Should be the phandle for the interrupt controller
+  that services interrupts for this device
+- interrupts: Should contain the SXGBE interrupts
+  These interrupts are ordered by fixed and follows variable
+  trasmit DMA interrupts, receive DMA interrupts and lpi interrupt.
+  index 0 - this is fixed common interrupt of SXGBE and it is always
+  available.
+  index 1 to 25 - 8 variable trasmit interrupts, variable 16 receive interrupts
+  and 1 optional lpi interrupt.
+- phy-mode: String, operation mode of the PHY interface.
+  Supported values are: "sgmii", "xgmii".
+- samsung,pbl: Integer, Programmable Burst Length.
+  Supported values are 1, 2, 4, 8, 16, or 32.
+- samsung,burst-map: Integer, Program the possible bursts supported by sxgbe
+  This is an interger and represents allowable DMA bursts when fixed burst.
+  Allowable range is 0x01-0x3F. When this field is set fixed burst is enabled.
+  When fixed length is needed for burst mode, it can be set within allowable
+  range.
+- samsung,adv-addr-mode: Boolean, Program the DMA to use Enhanced address mode.
+  When enhanced address mode is needed, it can be set.
+- samsung,force-thresh-dma-mode: Boolean, Force DMA to use the threshold mode
+  for both tx and rx.
+- samsung,force-sf-dma-mode: Boolean, Force DMA to use the Store and Forward
+  mode for both tx and rx. This flag is ignored if force-thresh-dma-mode is set.
+
+Optional properties:
+- mac-address: 6 bytes, mac address
+- max-frame-size: Maximum Transfer Unit (IEEE defined MTU), rather
+		  than the maximum frame size.
+
+Example:
+
+	aliases {
+		ethernet0 = <&sxgbe0>;
+	};
+
+	sxgbe0: ethernet@1a040000 {
+		compatible = "samsung,sxgbe-v2.0a";
+		reg = <0 0x1a040000 0 0x10000>;
+		interrupt-parent = <&gic>;
+		interrupts = <0 209 4>, <0 185 4>, <0 186 4>, <0 187 4>,
+			     <0 188 4>, <0 189 4>, <0 190 4>, <0 191 4>,
+			     <0 192 4>, <0 193 4>, <0 194 4>, <0 195 4>,
+			     <0 196 4>, <0 197 4>, <0 198 4>, <0 199 4>,
+			     <0 200 4>, <0 201 4>, <0 202 4>, <0 203 4>,
+			     <0 204 4>, <0 205 4>, <0 206 4>, <0 207 4>,
+			     <0 208 4>, <0 210 4>;
+		samsung,pbl = <0x08>
+		samsung,burst-map = <0x20>
+		samsung,adv-addr-mode = "true"
+		samsung,force-sf-dma-mode = "true"
+		mac-address = [ 00 11 22 33 44 55 ]; /* Filled in by U-Boot */
+		max-frame-size = <9000>;
+		phy-mode = "xgmii";
+	};
-- 
1.7.10.4
