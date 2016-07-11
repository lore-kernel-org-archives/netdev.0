From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [PATCH v2] net: smc91x: ACPI Enable lan91x adapters
Date: Mon, 11 Jul 2016 10:28:40 -0500
Message-ID: <1468250920-29814-1-git-send-email-jeremy.linton@arm.com>
Cc: nico@fluxnic.net, robert.jarzmik@free.fr,
	felipe.balbi@linux.intel.com, fw@strlen.de, arnd@arndb.de,
	steve.capper@arm.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:53763 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753898AbcGKP2r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2016 11:28:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable lan91x adapters in some ARM machines and models
when booted with an ACPI kernel.

Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
---
 drivers/net/ethernet/smsc/smc91x.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 18ac52d..726b80f 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2195,6 +2195,12 @@ static void smc_release_datacs(struct platform_device *pdev, struct net_device *
 	}
 }
 
+static const struct acpi_device_id smc91x_acpi_match[] = {
+	{ "LNRO0003", 0 },
+	{ }
+};
+MODULE_DEVICE_TABLE(acpi, smc91x_acpi_match);
+
 #if IS_BUILTIN(CONFIG_OF)
 static const struct of_device_id smc91x_match[] = {
 	{ .compatible = "smsc,lan91c94", },
@@ -2274,7 +2280,6 @@ static int smc_drv_probe(struct platform_device *pdev)
 #if IS_BUILTIN(CONFIG_OF)
 	match = of_match_device(of_match_ptr(smc91x_match), &pdev->dev);
 	if (match) {
-		struct device_node *np = pdev->dev.of_node;
 		u32 val;
 
 		/* Optional pwrdwn GPIO configured? */
@@ -2300,7 +2305,8 @@ static int smc_drv_probe(struct platform_device *pdev)
 			usleep_range(750, 1000);
 
 		/* Combination of IO widths supported, default to 16-bit */
-		if (!of_property_read_u32(np, "reg-io-width", &val)) {
+		if (!device_property_read_u32(&pdev->dev, "reg-io-width",
+					      &val)) {
 			if (val & 1)
 				lp->cfg.flags |= SMC91X_USE_8BIT;
 			if ((val == 0) || (val & 2))
@@ -2478,7 +2484,8 @@ static struct platform_driver smc_driver = {
 	.driver		= {
 		.name	= CARDNAME,
 		.pm	= &smc_drv_pm_ops,
-		.of_match_table = of_match_ptr(smc91x_match),
+		.of_match_table   = of_match_ptr(smc91x_match),
+		.acpi_match_table = smc91x_acpi_match,
 	},
 };
 
-- 
2.5.5
