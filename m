From: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Subject: [PATCH] can: rcar_can: Add r8a7795 support
Date: Mon, 29 Feb 2016 12:37:25 +0000
Message-ID: <1456749445-50766-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Cc: linux-renesas-soc@vger.kernel.org, devicetree@vger.kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	geert+renesas@glider.be, horms+renesas@verge.net.au,
	chris.paterson2@renesas.com,
	Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
To: mkl@pengutronix.de, wg@grandegger.com, robh+dt@kernel.org,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor4.renesas.com ([210.160.252.174]:25372 "EHLO
	relmlie3.idc.renesas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752150AbcB2MmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 07:42:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added r8a7795 SoC support.

Signed-off-by: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
---
Hi All,

   This patch is based on linux-can-next (tag:linux-can-next-for-4.6-20160226)

   Pinctrl & Clock related to the controller are already submitted as below:

   https://lkml.org/lkml/2016/2/25/546
   https://lkml.org/lkml/2016/2/26/452
   http://www.spinics.net/lists/arm-kernel/msg487238.html

   Changes since v1:
   * Rebased from linux-next to linux-can-next
   * Removed clock rounding hack (http://www.spinics.net/lists/netdev/msg366611.html)
   * CAN dtsi changes will be submitted separately based on linux-next (http://marc.info/?l=linux-can&m=145674764815430&w=2)

 Documentation/devicetree/bindings/net/can/rcar_can.txt | 11 +++++++++++
 drivers/net/can/Kconfig                                |  2 +-
 drivers/net/can/rcar_can.c                             |  1 +
 3 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/can/rcar_can.txt b/Documentation/devicetree/bindings/net/can/rcar_can.txt
index 65edc05..8d40ab2 100644
--- a/Documentation/devicetree/bindings/net/can/rcar_can.txt
+++ b/Documentation/devicetree/bindings/net/can/rcar_can.txt
@@ -9,8 +9,10 @@ Required properties:
 	      "renesas,can-r8a7792" if CAN controller is a part of R8A7792 SoC.
 	      "renesas,can-r8a7793" if CAN controller is a part of R8A7793 SoC.
 	      "renesas,can-r8a7794" if CAN controller is a part of R8A7794 SoC.
+	      "renesas,can-r8a7795" if CAN controller is a part of R8A7795 SoC.
 	      "renesas,rcar-gen1-can" for a generic R-Car Gen1 compatible device.
 	      "renesas,rcar-gen2-can" for a generic R-Car Gen2 compatible device.
+	      "renesas,rcar-gen3-can" for a generic R-Car Gen3 compatible device.
 	      When compatible with the generic version, nodes must list the
 	      SoC-specific version corresponding to the platform first
 	      followed by the generic version.
@@ -22,6 +24,15 @@ Required properties:
 - pinctrl-0: pin control group to be used for this controller.
 - pinctrl-names: must be "default".
 
+Required properties for "renesas,can-r8a7795" compatible:
+In R8A7795 SoC, "clkp2" can be CANFD clock. This is a div6 clock and can be
+used by both CAN and CAN FD controller at the same time. It needs to be scaled
+to maximum frequency if any of these controllers use it. This is done using
+the below properties.
+
+- assigned-clocks: phandle of clkp2(CANFD) clock.
+- assigned-clock-rates: maximum frequency of this clock.
+
 Optional properties:
 - renesas,can-clock-select: R-Car CAN Clock Source Select. Valid values are:
 			    <0x0> (default) : Peripheral clock (clkp1)
diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index 164ccde..0d40aef 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -106,7 +106,7 @@ config CAN_JANZ_ICAN3
 
 config CAN_RCAR
 	tristate "Renesas R-Car CAN controller"
-	depends on ARM
+	depends on ARCH_RENESAS || ARM
 	---help---
 	  Say Y here if you want to use CAN controller found on Renesas R-Car
 	  SoCs.
diff --git a/drivers/net/can/rcar_can.c b/drivers/net/can/rcar_can.c
index ad3d2e0..788459f 100644
--- a/drivers/net/can/rcar_can.c
+++ b/drivers/net/can/rcar_can.c
@@ -906,6 +906,7 @@ static const struct of_device_id rcar_can_of_table[] __maybe_unused = {
 	{ .compatible = "renesas,can-r8a7791" },
 	{ .compatible = "renesas,rcar-gen1-can" },
 	{ .compatible = "renesas,rcar-gen2-can" },
+	{ .compatible = "renesas,rcar-gen3-can" },
 	{ }
 };
 MODULE_DEVICE_TABLE(of, rcar_can_of_table);
-- 
1.9.1
