From: Tony Lindgren <tony@atomide.com>
Subject: [PATCH 6/6] net: davinci_emac: Add support for emac on dm816x
Date: Thu, 15 Jan 2015 14:45:14 -0800
Message-ID: <1421361914-4612-7-git-send-email-tony@atomide.com>
References: <1421361914-4612-1-git-send-email-tony@atomide.com>
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	Brian Hutchinson <b.hutchman@gmail.com>,
	Felipe Balbi <balbi@ti.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1421361914-4612-1-git-send-email-tony@atomide.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On dm816x we have two emac controllers with separate memory
areas.

Cc: Brian Hutchinson <b.hutchman@gmail.com>
Cc: Felipe Balbi <balbi@ti.com>
Signed-off-by: Tony Lindgren <tony@atomide.com>
---
 Documentation/devicetree/bindings/net/davinci_emac.txt | 3 ++-
 drivers/net/ethernet/ti/davinci_emac.c                 | 5 +++++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/davinci_emac.txt b/Documentation/devicetree/bindings/net/davinci_emac.txt
index 0328088..24c5cda 100644
--- a/Documentation/devicetree/bindings/net/davinci_emac.txt
+++ b/Documentation/devicetree/bindings/net/davinci_emac.txt
@@ -4,7 +4,8 @@ This file provides information, what the device node
 for the davinci_emac interface contains.
 
 Required properties:
-- compatible: "ti,davinci-dm6467-emac" or "ti,am3517-emac"
+- compatible: "ti,davinci-dm6467-emac", "ti,am3517-emac" or
+  "ti,dm816-emac"
 - reg: Offset and length of the register set for the device
 - ti,davinci-ctrl-reg-offset: offset to control register
 - ti,davinci-ctrl-mod-reg-offset: offset to control module register
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 1e5ea81..5fae435 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -2120,9 +2120,14 @@ static const struct emac_platform_data am3517_emac_data = {
 	.hw_ram_addr		= 0x01e20000,
 };
 
+static const struct emac_platform_data dm816_emac_data = {
+	.version		= EMAC_VERSION_2,
+};
+
 static const struct of_device_id davinci_emac_of_match[] = {
 	{.compatible = "ti,davinci-dm6467-emac", },
 	{.compatible = "ti,am3517-emac", .data = &am3517_emac_data, },
+	{.compatible = "ti,dm816-emac", .data = &dm816_emac_data, },
 	{},
 };
 MODULE_DEVICE_TABLE(of, davinci_emac_of_match);
-- 
2.1.4

