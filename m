From: Eric Anholt <eric@anholt.net>
Subject: [PATCH v3 1/2] net: dsa: b53: Add compatible strings for the Cygnus-family BCM11360.
Date: Fri, 28 Apr 2017 15:22:03 -0700
Message-ID: <20170428222204.7103-1-eric@anholt.net>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com, Ray Jui <rjui@broadcom.com>,
        Scott Branden <sbranden@broadcom.com>,
        Jon Mason <jonmason@broadcom.com>,
        Eric Anholt <eric@anholt.net>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from anholt.net ([50.246.234.109]:45098 "EHLO anholt.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1425893AbdD1WWI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 18:22:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cygnus is a small family of SoCs, of which we currently have
devicetree for BCM11360 and BCM58300.  The 11360's B53 is mostly the
same as 58xx, just requiring a tiny bit of setup that was previously
missing.

v2: Reorder the entry in the docs (suggestion by Scott Branden), add
    missing '"'

Signed-off-by: Eric Anholt <eric@anholt.net>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Acked-by: Rob Herring <robh@kernel.org>
---
 Documentation/devicetree/bindings/net/dsa/b53.txt | 3 +++
 drivers/net/dsa/b53/b53_srab.c                    | 2 ++
 2 files changed, 5 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/dsa/b53.txt b/Documentation/devicetree/bindings/net/dsa/b53.txt
index d6c6e41648d4..eb679e92d525 100644
--- a/Documentation/devicetree/bindings/net/dsa/b53.txt
+++ b/Documentation/devicetree/bindings/net/dsa/b53.txt
@@ -13,6 +13,9 @@ Required properties:
       "brcm,bcm5397"
       "brcm,bcm5398"
 
+  For the BCM11360 SoC, must be:
+      "brcm,bcm11360-srab" and the mandatory "brcm,cygnus-srab" string
+
   For the BCM5310x SoCs with an integrated switch, must be one of:
       "brcm,bcm53010-srab"
       "brcm,bcm53011-srab"
diff --git a/drivers/net/dsa/b53/b53_srab.c b/drivers/net/dsa/b53/b53_srab.c
index 8a62b6a69703..c37ffd1b6833 100644
--- a/drivers/net/dsa/b53/b53_srab.c
+++ b/drivers/net/dsa/b53/b53_srab.c
@@ -364,6 +364,7 @@ static const struct of_device_id b53_srab_of_match[] = {
 	{ .compatible = "brcm,bcm53018-srab" },
 	{ .compatible = "brcm,bcm53019-srab" },
 	{ .compatible = "brcm,bcm5301x-srab" },
+	{ .compatible = "brcm,bcm11360-srab", .data = (void *)BCM58XX_DEVICE_ID },
 	{ .compatible = "brcm,bcm58522-srab", .data = (void *)BCM58XX_DEVICE_ID },
 	{ .compatible = "brcm,bcm58525-srab", .data = (void *)BCM58XX_DEVICE_ID },
 	{ .compatible = "brcm,bcm58535-srab", .data = (void *)BCM58XX_DEVICE_ID },
@@ -371,6 +372,7 @@ static const struct of_device_id b53_srab_of_match[] = {
 	{ .compatible = "brcm,bcm58623-srab", .data = (void *)BCM58XX_DEVICE_ID },
 	{ .compatible = "brcm,bcm58625-srab", .data = (void *)BCM58XX_DEVICE_ID },
 	{ .compatible = "brcm,bcm88312-srab", .data = (void *)BCM58XX_DEVICE_ID },
+	{ .compatible = "brcm,cygnus-srab", .data = (void *)BCM58XX_DEVICE_ID },
 	{ .compatible = "brcm,nsp-srab", .data = (void *)BCM58XX_DEVICE_ID },
 	{ /* sentinel */ },
 };
-- 
2.11.0
