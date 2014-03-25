From: Byungho An <bh74.an-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH V14 1/7] sxgbe: Add device-tree binding support document
Date: Tue, 25 Mar 2014 12:10:51 -0700
Message-ID: <01ad01cf485d$f1894fa0$d49beee0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	'GIRISH K S' <ks.giri-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	'SIVAREDDY KALLAM' <siva.kallam-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	'Vipul Chandrakant' <vipul.pandya-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	'Ilho Lee' <ilho215.lee-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-language: en-us
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Siva Reddy <siva.kallam-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>

This patch adds binding document for SXGBE ethernet driver via device-tree.

Signed-off-by: Siva Reddy Kallam <siva.kallam-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Byungho An <bh74.an-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
---
 .../devicetree/bindings/net/samsung-sxgbe.txt      |   52 ++++++++++++++++++++
 1 file changed, 52 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/samsung-sxgbe.txt

diff --git a/Documentation/devicetree/bindings/net/samsung-sxgbe.txt b/Documentation/devicetree/bindings/net/samsung-sxgbe.txt
new file mode 100644
index 0000000..989f6c9
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/samsung-sxgbe.txt
@@ -0,0 +1,52 @@
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
+		mac-address = [ 00 11 22 33 44 55 ]; /* Filled in by U-Boot */
+		max-frame-size = <9000>;
+		phy-mode = "xgmii";
+	};
-- 
1.7.10.4


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
