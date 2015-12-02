From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH v2 net-next 1/2] ravb: add fallback compatibility strings
Date: Wed,  2 Dec 2015 14:58:32 +0900
Message-ID: <1449035913-9129-2-git-send-email-horms+renesas@verge.net.au>
References: <1449035913-9129-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	devicetree@vger.kernel.org
To: netdev@vger.kernel.org, linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1449035913-9129-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add fallback compatibility strings for R-Car Gen 2 & 3 SoC Families.
This is in keeping with the fallback scheme being adopted wherever appropriate
for drivers for Renesas SoCs.

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

---
v2
* Drop bogus typo non-fix
* include "rcar-" in generic bindings
---
 Documentation/devicetree/bindings/net/renesas,ravb.txt | 9 ++++++++-
 drivers/net/ethernet/renesas/ravb_main.c               | 2 ++
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/renesas,ravb.txt b/Documentation/devicetree/bindings/net/renesas,ravb.txt
index b486f3f5f6a3..7555116b5db2 100644
--- a/Documentation/devicetree/bindings/net/renesas,ravb.txt
+++ b/Documentation/devicetree/bindings/net/renesas,ravb.txt
@@ -7,6 +7,13 @@ Required properties:
 - compatible: "renesas,etheravb-r8a7790" if the device is a part of R8A7790 SoC.
 	      "renesas,etheravb-r8a7794" if the device is a part of R8A7794 SoC.
 	      "renesas,etheravb-r8a7795" if the device is a part of R8A7795 SoC.
+	      "renesas,etheravb-rcar-gen2" for generic R-Car Gen 2 compatible interface.
+	      "renesas,etheravb-rcar-gen3" for generic R-Car Gen 3 compatible interface.
+
+	      When compatible with the generic version, nodes must list the
+	      SoC-specific version corresponding to the platform first
+	      followed by the generic version.
+
 - reg: offset and length of (1) the register block and (2) the stream buffer.
 - interrupts: A list of interrupt-specifiers, one for each entry in
 	      interrupt-names.
@@ -37,7 +44,7 @@ Optional properties:
 Example:
 
 	ethernet@e6800000 {
-		compatible = "renesas,etheravb-r8a7795";
+		compatible = "renesas,etheravb-r8a7795", "renesas,etheravb-rcar-gen3";
 		reg = <0 0xe6800000 0 0x800>, <0 0xe6a00000 0 0x10000>;
 		interrupt-parent = <&gic>;
 		interrupts = <GIC_SPI 39 IRQ_TYPE_LEVEL_HIGH>,
diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 990dc55cdada..c12b163ed7fe 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -1656,7 +1656,9 @@ static int ravb_mdio_release(struct ravb_private *priv)
 static const struct of_device_id ravb_match_table[] = {
 	{ .compatible = "renesas,etheravb-r8a7790", .data = (void *)RCAR_GEN2 },
 	{ .compatible = "renesas,etheravb-r8a7794", .data = (void *)RCAR_GEN2 },
+	{ .compatible = "renesas,etheravb-rcar-gen2", .data = (void *)RCAR_GEN2 },
 	{ .compatible = "renesas,etheravb-r8a7795", .data = (void *)RCAR_GEN3 },
+	{ .compatible = "renesas,etheravb-rcar-gen3", .data = (void *)RCAR_GEN3 },
 	{ }
 };
 MODULE_DEVICE_TABLE(of, ravb_match_table);
-- 
2.1.4

