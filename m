From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH net-next 1/3] dt-bindings: net: sh_eth: add R-Car Gen[12] fallback compatibility strings
Date: Tue, 17 Oct 2017 09:47:45 +0200
Message-ID: <20171017074747.24159-2-horms+renesas@verge.net.au>
References: <20171017074747.24159-1-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        Simon Horman <horms+renesas@verge.net.au>
To: David Miller <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:41349 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757935AbdJQHsG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 03:48:06 -0400
In-Reply-To: <20171017074747.24159-1-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add fallback compatibility strings for R-Car Gen 1 and 2.

In the case of Renesas R-Car hardware we know that there are generations of
SoCs, f.e. Gen 1 and 2. But beyond that its not clear what the relationship
between IP blocks might be. For example, I believe that r8a7790 is older
than r8a7791 but that doesn't imply that the latter is a descendant of the
former or vice versa.

We can, however, by examining the documentation and behaviour of the
hardware at run-time observe that the current driver implementation appears
to be compatible with the IP blocks on SoCs within a given generation.

For the above reasons and convenience when enabling new SoCs a
per-generation fallback compatibility string scheme being adopted for
drivers for Renesas SoCs.

Note that R-Car Gen2 and RZ/G1 have many compatible IP blocks.  The
approach that has been consistently taken for other IP blocks is to name
common code, compatibility strings and so on after Rcar Gen2.

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
---
 Documentation/devicetree/bindings/net/sh_eth.txt | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/sh_eth.txt b/Documentation/devicetree/bindings/net/sh_eth.txt
index 0115c85a2425..48cab94dd056 100644
--- a/Documentation/devicetree/bindings/net/sh_eth.txt
+++ b/Documentation/devicetree/bindings/net/sh_eth.txt
@@ -4,7 +4,8 @@ This file provides information on what the device node for the SH EtherMAC
 interface contains.
 
 Required properties:
-- compatible: "renesas,gether-r8a7740" if the device is a part of R8A7740 SoC.
+- compatible: Must contain one or more of the following:
+	      "renesas,gether-r8a7740" if the device is a part of R8A7740 SoC.
 	      "renesas,ether-r8a7743"  if the device is a part of R8A7743 SoC.
 	      "renesas,ether-r8a7745"  if the device is a part of R8A7745 SoC.
 	      "renesas,ether-r8a7778"  if the device is a part of R8A7778 SoC.
@@ -14,6 +15,14 @@ Required properties:
 	      "renesas,ether-r8a7793"  if the device is a part of R8A7793 SoC.
 	      "renesas,ether-r8a7794"  if the device is a part of R8A7794 SoC.
 	      "renesas,ether-r7s72100" if the device is a part of R7S72100 SoC.
+              "renesas,rcar-gen1-ether" for a generic R-Car Gen1 device.
+              "renesas,rcar-gen2-ether" for a generic R-Car Gen2 or RZ/G1
+	                                device.
+
+	      When compatible with the generic version nodes must list
+	      the SoC-specific version corresponding to the platform
+	      first followed by the generic version.
+
 - reg: offset and length of (1) the E-DMAC/feLic register block (required),
        (2) the TSU register block (optional).
 - interrupts: interrupt specifier for the sole interrupt.
@@ -36,7 +45,8 @@ Optional properties:
 Example (Lager board):
 
 	ethernet@ee700000 {
-		compatible = "renesas,ether-r8a7790";
+		compatible = "renesas,ether-r8a7790",
+		             "renesas,rcar-gen2-ether";
 		reg = <0 0xee700000 0 0x400>;
 		interrupt-parent = <&gic>;
 		interrupts = <0 162 IRQ_TYPE_LEVEL_HIGH>;
-- 
2.11.0
