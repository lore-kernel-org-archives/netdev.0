From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v4 net-next 2/3] net: macb: Add NPx macb config using USRIO_DISABLED cap
Date: Mon,  4 Jan 2016 10:42:52 +0100
Message-ID: <1451900573-22657-3-git-send-email-narmstrong@baylibre.com>
References: <1451898103-21868-1-git-send-email-narmstrong@baylibre.com>
 <1451900573-22657-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net,
	harini.katakam@xilinx.com, boris.brezillon@free-electrons.com,
	alexandre.belloni@free-electrons.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, joshc@ni.com, devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:33473 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753322AbcADJnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 04:43:09 -0500
Received: by mail-wm0-f53.google.com with SMTP id f206so166039933wmf.0
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 01:43:08 -0800 (PST)
In-Reply-To: <1451900573-22657-1-git-send-email-narmstrong@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Declare a new SoC variant for NPx SoCs having USRIO_DISABLED as
capability bit.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/ethernet/cadence/macb.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index fa53bc3..a9e27a7 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2781,6 +2781,11 @@ static const struct macb_config emac_config = {
 	.init = at91ether_init,
 };
 
+static const struct macb_config npx_config = {
+	.caps = MACB_CAPS_USRIO_DISABLED,
+	.clk_init = macb_clk_init,
+	.init = macb_init,
+};
 
 static const struct macb_config zynqmp_config = {
 	.caps = MACB_CAPS_GIGABIT_MODE_AVAILABLE | MACB_CAPS_JUMBO,
@@ -2801,6 +2806,7 @@ static const struct of_device_id macb_dt_ids[] = {
 	{ .compatible = "cdns,at32ap7000-macb" },
 	{ .compatible = "cdns,at91sam9260-macb", .data = &at91sam9260_config },
 	{ .compatible = "cdns,macb" },
+	{ .compatible = "cdns,npx-macb", .data = &npx_config },
 	{ .compatible = "cdns,pc302-gem", .data = &pc302gem_config },
 	{ .compatible = "cdns,gem", .data = &pc302gem_config },
 	{ .compatible = "atmel,sama5d2-gem", .data = &sama5d2_config },
-- 
1.9.1
