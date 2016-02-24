From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH can-next v2 1/2] CAN: rcar: add gen[12] fallback compatibility strings
Date: Wed, 24 Feb 2016 10:56:32 +0900
Message-ID: <1456278993-9899-2-git-send-email-horms+renesas@verge.net.au>
References: <1456278993-9899-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	Simon Horman <horms+renesas@verge.net.au>
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1456278993-9899-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add fallback compatibility string for R-Car Gen 1 and Gen2.

In the case of Renesas R-Car hardware we know that there are generations of
SoCs, e.g. Gen 1 and Gen 2. But beyond that its not clear what the
relationship between IP blocks might be. For example, I believe that
r8a7779 is older than r8a7778 but that doesn't imply that the latter is a
descendant of the former or vice versa.

We can, however, by examining the documentation and behaviour of the
hardware at run-time observe that the current driver implementation appears
to be compatible with the IP blocks on SoCs within a given generation.

For the above reasons and convenience when enabling new SoCs a
per-generation fallback compatibility string scheme being adopted for
drivers for Renesas SoCs.

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
Acked-by: Rob Herring <robh@kernel.org>

--
v2
* Added Ack from Rob Herring
* Place 'can' at the end of new compatibility strings,
  this is in keeping with current guidelines for compatibility string names.
* Describe use of fallback compatibility strings in conjunction with
  per-SoC compatibility strings
* Enhanced changelog text
---
 Documentation/devicetree/bindings/net/can/rcar_can.txt | 8 +++++++-
 drivers/net/can/rcar_can.c                             | 2 ++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/can/rcar_can.txt b/Documentation/devicetree/bindings/net/can/rcar_can.txt
index 002d8440bf66..f2172fb42cd8 100644
--- a/Documentation/devicetree/bindings/net/can/rcar_can.txt
+++ b/Documentation/devicetree/bindings/net/can/rcar_can.txt
@@ -6,6 +6,12 @@ Required properties:
 	      "renesas,can-r8a7779" if CAN controller is a part of R8A7779 SoC.
 	      "renesas,can-r8a7790" if CAN controller is a part of R8A7790 SoC.
 	      "renesas,can-r8a7791" if CAN controller is a part of R8A7791 SoC.
+	      "renesas,rcar-gen1-can" for a generic R-Car Gen1 compatible device.
+	      "renesas,rcar-gen2-can" for a generic R-Car Gen2 compatible device.
+	      When compatible with the generic version, nodes must list the
+	      SoC-specific version corresponding to the platform first
+	      followed by the generic version.
+
 - reg: physical base address and size of the R-Car CAN register map.
 - interrupts: interrupt specifier for the sole interrupt.
 - clocks: phandles and clock specifiers for 3 CAN clock inputs.
@@ -25,7 +31,7 @@ Example
 SoC common .dtsi file:
 
 	can0: can@e6e80000 {
-		compatible = "renesas,can-r8a7791";
+		compatible = "renesas,can-r8a7791", "renesas,rcar-gen2-can";
 		reg = <0 0xe6e80000 0 0x1000>;
 		interrupts = <0 186 IRQ_TYPE_LEVEL_HIGH>;
 		clocks = <&mstp9_clks R8A7791_CLK_RCAN0>,
diff --git a/drivers/net/can/rcar_can.c b/drivers/net/can/rcar_can.c
index bc46be39549d..ad3d2e0cb191 100644
--- a/drivers/net/can/rcar_can.c
+++ b/drivers/net/can/rcar_can.c
@@ -904,6 +904,8 @@ static const struct of_device_id rcar_can_of_table[] __maybe_unused = {
 	{ .compatible = "renesas,can-r8a7779" },
 	{ .compatible = "renesas,can-r8a7790" },
 	{ .compatible = "renesas,can-r8a7791" },
+	{ .compatible = "renesas,rcar-gen1-can" },
+	{ .compatible = "renesas,rcar-gen2-can" },
 	{ }
 };
 MODULE_DEVICE_TABLE(of, rcar_can_of_table);
-- 
2.1.4

