From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: dsa: b53: Add support for BCM585xx/586xx/88312 integrated switch
Date: Fri,  8 Jul 2016 11:39:13 -0700
Message-ID: <1468003153-14026-3-git-send-email-f.fainelli@gmail.com>
References: <1468003153-14026-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, jon.mason@broadcom.com, andrew@lunn.ch,
	zajec5@gmail.com, vivien.didelot@savoirfairelinux.com,
	bcm-kernel-feedback-list@broadcom.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35394 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755755AbcGHSkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 14:40:18 -0400
Received: by mail-pa0-f66.google.com with SMTP id dx3so8544417pab.2
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 11:39:56 -0700 (PDT)
In-Reply-To: <1468003153-14026-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the SRAB, core driver and binding document to support the
BCM585xx/586xx/88312 integrated switch (Northstar Plus SoCs family).

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/devicetree/bindings/net/dsa/b53.txt |  9 +++++++++
 drivers/net/dsa/b53/b53_common.c                  | 12 ++++++++++++
 drivers/net/dsa/b53/b53_priv.h                    |  1 +
 drivers/net/dsa/b53/b53_srab.c                    |  8 ++++++++
 4 files changed, 30 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/dsa/b53.txt b/Documentation/devicetree/bindings/net/dsa/b53.txt
index ca752db14dff..d6c6e41648d4 100644
--- a/Documentation/devicetree/bindings/net/dsa/b53.txt
+++ b/Documentation/devicetree/bindings/net/dsa/b53.txt
@@ -20,6 +20,15 @@ Required properties:
       "brcm,bcm53018-srab"
       "brcm,bcm53019-srab" and the mandatory "brcm,bcm5301x-srab" string
 
+  For the BCM585xx/586XX/88312 SoCs with an integrated switch, must be one of:
+      "brcm,bcm58522-srab"
+      "brcm,bcm58523-srab"
+      "brcm,bcm58525-srab"
+      "brcm,bcm58622-srab"
+      "brcm,bcm58623-srab"
+      "brcm,bcm58625-srab"
+      "brcm,bcm88312-srab" and the mandatory "brcm,nsp-srab string
+
   For the BCM63xx/33xx SoCs with an integrated switch, must be one of:
       "brcm,bcm3384-switch"
       "brcm,bcm6328-switch"
diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 444de66667b9..bda37d336736 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1581,6 +1581,18 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
 		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
 	},
+	{
+		.chip_id = BCM58XX_DEVICE_ID,
+		.dev_name = "BCM585xx/586xx/88312",
+		.vlans	= 4096,
+		.enabled_ports = 0x1ff,
+		.arl_entries = 4,
+		.cpu_port = B53_CPU_PORT_25,
+		.vta_regs = B53_VTA_REGS,
+		.duplex_reg = B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+	},
 };
 
 static int b53_switch_init(struct b53_device *dev)
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index 5d8c602fb877..835a744f206e 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -59,6 +59,7 @@ enum {
 	BCM53012_DEVICE_ID = 0x53012,
 	BCM53018_DEVICE_ID = 0x53018,
 	BCM53019_DEVICE_ID = 0x53019,
+	BCM58XX_DEVICE_ID = 0x5800,
 };
 
 #define B53_N_PORTS	9
diff --git a/drivers/net/dsa/b53/b53_srab.c b/drivers/net/dsa/b53/b53_srab.c
index de2b9e710041..2b304eaeb8e8 100644
--- a/drivers/net/dsa/b53/b53_srab.c
+++ b/drivers/net/dsa/b53/b53_srab.c
@@ -364,6 +364,14 @@ static const struct of_device_id b53_srab_of_match[] = {
 	{ .compatible = "brcm,bcm53018-srab" },
 	{ .compatible = "brcm,bcm53019-srab" },
 	{ .compatible = "brcm,bcm5301x-srab" },
+	{ .compatible = "brcm,bcm58522-srab", .data = (void *)BCM58XX_DEVICE_ID },
+	{ .compatible = "brcm,bcm58525-srab", .data = (void *)BCM58XX_DEVICE_ID },
+	{ .compatible = "brcm,bcm58535-srab", .data = (void *)BCM58XX_DEVICE_ID },
+	{ .compatible = "brcm,bcm58622-srab", .data = (void *)BCM58XX_DEVICE_ID },
+	{ .compatible = "brcm,bcm58623-srab", .data = (void *)BCM58XX_DEVICE_ID },
+	{ .compatible = "brcm,bcm58625-srab", .data = (void *)BCM58XX_DEVICE_ID },
+	{ .compatible = "brcm,bcm88312-srab", .data = (void *)BCM58XX_DEVICE_ID },
+	{ .compatible = "brcm,nsp-srab", .data = (void *)BCM58XX_DEVICE_ID },
 	{ /* sentinel */ },
 };
 MODULE_DEVICE_TABLE(of, b53_srab_of_match);
-- 
2.7.4
