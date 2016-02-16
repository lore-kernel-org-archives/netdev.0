From: Sergio Prado <sergio.prado@e-labworks.com>
Subject: [PATCH net-next,V2] net: macb: make magic-packet property generic
Date: Tue, 16 Feb 2016 21:10:45 -0200
Message-ID: <1455664245-6842-1-git-send-email-sergio.prado@e-labworks.com>
Cc: Sergio Prado <sergio.prado@e-labworks.com>
To: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	nicolas.ferre@atmel.com, davem@davemloft.net,
	gregory.clement@free-electrons.com, narmstrong@baylibre.com,
	michal.simek@xilinx.com, harini.katakam@xilinx.com,
	boris.brezillon@free-electrons.com, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As requested by Rob Herring on patch
https://patchwork.ozlabs.org/patch/580862/.

This is a new property that it's still in net-next and has never been
used in production, so we are not breaking anything with the
incompatible binding change.

Signed-off-by: Sergio Prado <sergio.prado@e-labworks.com>
---
Changes v1 -> v2: add changelog comment to clarify that the existing
property has never been used in production.
---
 Documentation/devicetree/bindings/net/macb.txt | 2 +-
 drivers/net/ethernet/cadence/macb.c            | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
index c6b1cb5ffa87..b5a42df4c928 100644
--- a/Documentation/devicetree/bindings/net/macb.txt
+++ b/Documentation/devicetree/bindings/net/macb.txt
@@ -25,7 +25,7 @@ Required properties:
 
 Optional properties for PHY child node:
 - reset-gpios : Should specify the gpio for phy reset
-- cdns,magic-packet : If present, indicates that the hardware supports waking
+- magic-packet : If present, indicates that the hardware supports waking
   up via magic packet.
 
 Examples:
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 69af049e55a8..7ccf2298a5fa 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2929,7 +2929,7 @@ static int macb_probe(struct platform_device *pdev)
 		bp->jumbo_max_len = macb_config->jumbo_max_len;
 
 	bp->wol = 0;
-	if (of_get_property(np, "cdns,magic-packet", NULL))
+	if (of_get_property(np, "magic-packet", NULL))
 		bp->wol |= MACB_WOL_HAS_MAGIC_PACKET;
 	device_init_wakeup(&pdev->dev, bp->wol & MACB_WOL_HAS_MAGIC_PACKET);
 
-- 
1.9.1
