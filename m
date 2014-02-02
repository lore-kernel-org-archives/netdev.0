From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 1/3] net: ethernet: sunxi: Add new compatibles
Date: Sun,  2 Feb 2014 14:49:11 +0100
Message-ID: <1391348953-10662-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Maxime Ripard <maxime.ripard@free-electrons.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:49898 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751577AbaBCIaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 03:30:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Allwinner A10 compatibles were following a slightly different compatible
patterns than the rest of the SoCs for historical reasons. Add compatibles
matching the other pattern to the ethernet driver for consistency, and keep the
older one for backward compatibility.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 Documentation/devicetree/bindings/net/allwinner,sun4i-emac.txt | 5 +++--
 drivers/net/ethernet/allwinner/sun4i-emac.c                    | 3 +++
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/allwinner,sun4i-emac.txt b/Documentation/devicetree/bindings/net/allwinner,sun4i-emac.txt
index b90bfcd..863d5b81 100644
--- a/Documentation/devicetree/bindings/net/allwinner,sun4i-emac.txt
+++ b/Documentation/devicetree/bindings/net/allwinner,sun4i-emac.txt
@@ -1,7 +1,8 @@
 * Allwinner EMAC ethernet controller
 
 Required properties:
-- compatible: should be "allwinner,sun4i-emac".
+- compatible: should be "allwinner,sun4i-a10-emac" (Deprecated:
+              "allwinner,sun4i-emac")
 - reg: address and length of the register set for the device.
 - interrupts: interrupt for the device
 - phy: A phandle to a phy node defining the PHY address (as the reg
@@ -14,7 +15,7 @@ Optional properties:
 Example:
 
 emac: ethernet@01c0b000 {
-       compatible = "allwinner,sun4i-emac";
+       compatible = "allwinner,sun4i-a10-emac";
        reg = <0x01c0b000 0x1000>;
        interrupts = <55>;
        clocks = <&ahb_gates 17>;
diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index 46dfb13..6673106 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -930,6 +930,9 @@ static int emac_resume(struct platform_device *dev)
 }
 
 static const struct of_device_id emac_of_match[] = {
+	{.compatible = "allwinner,sun4i-a10-emac",},
+
+	/* Deprecated */
 	{.compatible = "allwinner,sun4i-emac",},
 	{},
 };
-- 
1.8.4.2
