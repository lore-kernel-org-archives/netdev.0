From: Poonam_Aggrwal-b10812 <b10812@freescale.com>
Subject: [PATCH 3/3] Modified Documentation to explain dts entries for UCC
 TDM driver.
Date: Mon, 10 Dec 2007 17:43:39 +0530 (IST)
Message-ID: <Pine.LNX.4.64.0712101739260.29623@linux121>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: michael.barkowski@freescale.com, kim.phillips@freescale.com,
	ashish.kalra@freescale.com, rich.cutler@freescale.com
To: rubini@vision.unipv.it, kumar.gala@freescale.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:62068 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756337AbXLJMNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 07:13:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Poonam Aggrwal <b10812@freescale.com>

Modified Documentation to explain new properties introduced for UCC TDM 
driver. Also two new nodes have been added "brg" and "clocks" to configure 
a BRG from device tree.

Signed-off-by: Poonam Aggrwal <b10812@freescale.com>
Signed-off-by: Ashish Kalra <ashish.kalra@freescale.com>
Signed-off-by: Kim Phillips <Kim.Phillips@freescale.com>
Signed-off-by: Michael Barkowski <michael.barkowski@freescale.com>
---
 Documentation/powerpc/booting-without-of.txt |   96 +++++++++++++++++++++++++-
 1 files changed, 94 insertions(+), 2 deletions(-)

diff --git a/Documentation/powerpc/booting-without-of.txt b/Documentation/powerpc/booting-without-of.txt
index e9a3cb1..94a6b4b 100644
--- a/Documentation/powerpc/booting-without-of.txt
+++ b/Documentation/powerpc/booting-without-of.txt
@@ -1613,8 +1613,8 @@ platforms are moved over to use the flattened-device-tree model.
 
    Required properties:
    - device_type : should be "network", "hldc", "uart", "transparent"
-    "bisync" or "atm".
-   - compatible : could be "ucc_geth" or "fsl_atm" and so on.
+    "bisync", "atm" or "tdm".
+   - compatible : could be "ucc_geth", "fsl_atm" or "fsl,ucc_tdm" and so on.
    - model : should be "UCC".
    - device-id : the ucc number(1-8), corresponding to UCCx in UM.
    - reg : Offset and length of the register set for the device
@@ -1666,7 +1666,44 @@ platforms are moved over to use the flattened-device-tree model.
 		pio-handle = <140001>;
 	};
 
+   Required properties for tdm device_type:
+   - instead of tx-clock and rx-clock following clock properties are
+     required:
+       - fsl,tdm-tx-clk : This property selects the TX clock source for TDM
+	from a bank of clocks.
+       - fsl,tdm-rx-clk : This property selects the RX clock source for TDM
+	from a bank of clocks.
+       - fsl,tdm-tx-sync : This property selects the TX Frame sync source
+	for TDM from a bank of clocks.
+       - fsl,tdm-rx-sync : This property selects the TX Frame sync source
+	for TDM from a bank of clocks.
+
+       All the above mentioned properties are string type with possible
+       values
+       "CLK1", "CLK2", "CLK3"..."CLK24" and so on
+       "BRG1", "BRG2", "BRG3"..."BRG16" and so on
+
+  - fsl,tdm-num : TDM to be used (1,2,3 or 4 for TDMA TDMB TDMC TDMD)
+  - fsl,si-num :  Serial Interface to be used.
 
+   Example:
+	ucc@2000 {
+		device_type = "tdm";
+		compatible = "fsl,ucc-tdm";
+		model = "UCC";
+		device-id = <1>;
+		fsl,tdm-num = <1>;
+		fsl,si-num = <1>;
+		fsl,tdm-tx-clk = "CLK1";
+		fsl,tdm-rx-clk = "CLK1";
+		fsl,tdm-tx-sync = "BRG9";
+		fsl,tdm-rx-sync = "BRG9";
+		reg = <2000 200>;
+		interrupts = <20>;
+		interrupt-parent = <&qeic>;
+		pio-handle = <&ucc1pio>;
+	};
+
    v) Parallel I/O Ports
 
    This node configures Parallel I/O ports for CPUs with QE support.
@@ -1772,6 +1809,61 @@ platforms are moved over to use the flattened-device-tree model.
 		};
 	};
 
+  viii) Clocks (clocks)
+	This node specifies the frequency values for all the external clocks
+	viz CLK1 to CLK24 in Hz.
+
+  Required Properties:
+  - compatible : should be "fsl,cpm-clocks".
+  - #clock-cells : It specifies the number of cells occupied by clock-frequency
+    property. Currently #clock-cells = 1 is only supported and implemented.
+    This property is kept for future in case we need frequencies higher than
+    4 GHz.
+  - clock-frequency : It is a list of u32 values to represent the frequency
+    of each external clock(CLK1 to CLK24) in Hz.Each entry occupies
+    number of cells specified by #clock-cells property(1 for now).
+
+  Example:
+
+		clocks {
+			compatible = "fsl,cpm-clocks";
+			#clock-cells = <1>;
+			/* clock freqs in Hz(for CLK1~CLK24).
+			 * CLK11 is 1024KHz,
+			 * all other clocks unused
+			 */
+			clock-frequency = <0 0 0 0 0 0
+					   0 0 0 0 0 d#1024000 0
+					   0 0 0 0 0 0
+					   0 0 0 0 0 0>;
+		};
+
+  ix) Baud Rate Generator (BRG)
+
+  Required properties:
+  - compatible : shpuld be "fsl,cpm-brg"
+  - fsl,brg-sources : define the input clock for all 16 BRGs. The input
+    clock source could be 1 to 24 for CLK1 to CLK24. Zero means that the
+    particular BRG will be driven by QE clock(BRGCLK).
+  - reg : This property defines the address and size of the memory-mapped
+    registers of the BRG.
+
+  Example:
+
+		brg@640 {
+			compatible = "fsl,qe-brg";
+			/* input clock sources for all the 16 BRGs.
+			 * 1-24 for CLK1 to CLK24.
+			 * BRG9 uses CLK11 others use
+			 * the QE clock.
+			 */
+			fsl,brg-sources = <0 0 0 0 0 0 0 0
+					   b 0 0 0 0 0 0 0>;
+			reg = <640 7f>;
+		};
+
+    In the above entry, for BRG9 the input clock is 0xb(decimal 11) ie QE_CLK11.
+
    j) CFI or JEDEC memory-mapped NOR flash
 
     Flash chips (Memory Technology Devices) are often used for solid state
-- 
1.5.2.4

