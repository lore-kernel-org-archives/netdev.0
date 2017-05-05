From: Sebastian Reichel <sebastian.reichel@collabora.co.uk>
Subject: [PATCHv4] wlcore: add wl1285 compatible
Date: Fri,  5 May 2017 16:15:53 +0200
Message-ID: <20170505141553.2605-1-sebastian.reichel@collabora.co.uk>
Cc: Sebastian Reichel <sre@kernel.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        Tony Lindgren <tony@atomide.com>,
        Marcel Holtmann <marcel@holtmann.org>,
        Rob Herring <robh+dt@kernel.org>,
        linux-wireless@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Sebastian Reichel <sebastian.reichel@collabora.co.uk>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([46.235.227.227]:39497 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751215AbdEEOQE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 10:16:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Motorola Droid 4 uses a WL1285C. With differences between the
chips not being public let's add explicit binding for wl1285
instead of relying on wl1283 being very similar.

Reviewed-by: Rob Herring <robh@kernel.org>
Acked-by: Kalle Valo <kvalo@codeaurora.org>
Acked-by: Tony Lindgren <tony@atomide.com>
Signed-off-by: Sebastian Reichel <sebastian.reichel@collabora.co.uk>
---
Hi Dave,

I previously send this in two patches, but its hard to apply without
requiring multiple kernel releases (the driver must be updated before
the DTS change). Since the actual change is not very complex Marcel
Holtmann & Tony Lindgren suggested, that I send this directly to you
in a single patch for inclusion into 4.12. This also means, that the
remaining series can be queued normally for 4.13.

Changes since PATCHv3:
 - add netdev@vger.kernel.org to cc
 - add Acked-By from Tony & Kalle
Changes since PATCHv2:
 - merge patch for DTS and driver
 - add Acked-By from Rob
Changes since PATCHv1:
 - patches did not exist in patchv1

-- Sebastian
---
 Documentation/devicetree/bindings/net/wireless/ti,wlcore.txt | 1 +
 arch/arm/boot/dts/omap4-droid4-xt894.dts                     | 2 +-
 drivers/net/wireless/ti/wlcore/sdio.c                        | 1 +
 drivers/net/wireless/ti/wlcore/spi.c                         | 1 +
 4 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/wireless/ti,wlcore.txt b/Documentation/devicetree/bindings/net/wireless/ti,wlcore.txt
index 2a3d90de18ee..7b2cbb14113e 100644
--- a/Documentation/devicetree/bindings/net/wireless/ti,wlcore.txt
+++ b/Documentation/devicetree/bindings/net/wireless/ti,wlcore.txt
@@ -10,6 +10,7 @@ Required properties:
     * "ti,wl1273"
     * "ti,wl1281"
     * "ti,wl1283"
+    * "ti,wl1285"
     * "ti,wl1801"
     * "ti,wl1805"
     * "ti,wl1807"
diff --git a/arch/arm/boot/dts/omap4-droid4-xt894.dts b/arch/arm/boot/dts/omap4-droid4-xt894.dts
index 89eb607f4a9e..c09b51d6ccf7 100644
--- a/arch/arm/boot/dts/omap4-droid4-xt894.dts
+++ b/arch/arm/boot/dts/omap4-droid4-xt894.dts
@@ -301,7 +301,7 @@
 	#address-cells = <1>;
 	#size-cells = <0>;
 	wlcore: wlcore@2 {
-		compatible = "ti,wl1283";
+		compatible = "ti,wl1285";
 		reg = <2>;
 		interrupt-parent = <&gpio4>;
 		interrupts = <4 IRQ_TYPE_LEVEL_HIGH>; /* gpio100 */
diff --git a/drivers/net/wireless/ti/wlcore/sdio.c b/drivers/net/wireless/ti/wlcore/sdio.c
index 287023ef4a78..2fb38717346f 100644
--- a/drivers/net/wireless/ti/wlcore/sdio.c
+++ b/drivers/net/wireless/ti/wlcore/sdio.c
@@ -237,6 +237,7 @@ static const struct of_device_id wlcore_sdio_of_match_table[] = {
 	{ .compatible = "ti,wl1273", .data = &wl127x_data },
 	{ .compatible = "ti,wl1281", .data = &wl128x_data },
 	{ .compatible = "ti,wl1283", .data = &wl128x_data },
+	{ .compatible = "ti,wl1285", .data = &wl128x_data },
 	{ .compatible = "ti,wl1801", .data = &wl18xx_data },
 	{ .compatible = "ti,wl1805", .data = &wl18xx_data },
 	{ .compatible = "ti,wl1807", .data = &wl18xx_data },
diff --git a/drivers/net/wireless/ti/wlcore/spi.c b/drivers/net/wireless/ti/wlcore/spi.c
index f949ad2bd898..1f5d9ebb0925 100644
--- a/drivers/net/wireless/ti/wlcore/spi.c
+++ b/drivers/net/wireless/ti/wlcore/spi.c
@@ -433,6 +433,7 @@ static const struct of_device_id wlcore_spi_of_match_table[] = {
 	{ .compatible = "ti,wl1273", .data = &wl127x_data},
 	{ .compatible = "ti,wl1281", .data = &wl128x_data},
 	{ .compatible = "ti,wl1283", .data = &wl128x_data},
+	{ .compatible = "ti,wl1285", .data = &wl128x_data},
 	{ .compatible = "ti,wl1801", .data = &wl18xx_data},
 	{ .compatible = "ti,wl1805", .data = &wl18xx_data},
 	{ .compatible = "ti,wl1807", .data = &wl18xx_data},
-- 
2.11.0
