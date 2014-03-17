From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH V3 1/8] sxgbe: Add device-tree binding support document
Date: Mon, 17 Mar 2014 13:43:37 -0700
Message-ID: <00c001cf4221$96e667f0$c4b337d0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, siva.kallam@samsung.com,
	vipul.pandya@samsung.com, ks.giri@samsung.com,
	ilho215.lee@samsung.com
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:58218 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229AbaCQUnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 16:43:50 -0400
Content-language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Siva Reddy <siva.kallam@samsung.com>

This patch adds binding document for SXGBE ethernet driver via device-tree.

Signed-off-by: Siva Reddy Kallam <siva.kallam@samsung.com>
Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 .../devicetree/bindings/net/samsung-sxgbe.txt      |   53 ++++++++++++++++++++
 1 file changed, 53 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/samsung-sxgbe.txt

diff --git a/Documentation/devicetree/bindings/net/samsung-sxgbe.txt b/Documentation/devicetree/bindings/net/samsung-sxgbe.txt
new file mode 100644
index 0000000..ca27947
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/samsung-sxgbe.txt
@@ -0,0 +1,53 @@
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
+  Supported values are: "xaui", "gmii".
+- samsung,pbl: Integer, Programmable Burst Length.
+  Supported values are 1, 2, 4, 8, 16, or 32.
+- samsung,fixed-burst: Boolean, Program the DMA to use the fixed burst mode
+- samsung,burst-map: Integer, Program the possible bursts supported by sxgbe
+  This is an interger and represents allowable DMA bursts when fixed burst.
+  Allowable range is 0x00-0x3F. This field is valid only when fixed burst is
+  enabled, otherwise ignored.
+- samsung,adv-addr-mode: Boolean, Program the DMA to use Enhanced address mode.
+- samsung,force_thresh_dma_mode: Boolean, Force DMA to use the threshold mode
+  for both tx and rx
+- samsung,force_sf_dma_mode: Boolean, Force DMA to use the Store and Forward
+  mode for both tx and rx. This flag is ignored if force_thresh_dma_mode is set.
+- samsung,phy-addr: Integer, Address of the PHY attached with SXGBE.
+
+Optional properties:
+- mac-address: 6 bytes, mac address
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
+		mac-address = [000000000000]; /* Filled in by U-Boot */
+		phy-mode = "xaui";
+	};
-- 
1.7.10.4
