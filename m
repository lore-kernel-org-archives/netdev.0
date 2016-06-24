From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [PATCH] net: smc91x: ACPI Enable lan91x adapters
Date: Fri, 24 Jun 2016 08:16:21 -0500
Message-ID: <1466774181-24309-1-git-send-email-jeremy.linton@arm.com>
Cc: nico@fluxnic.net, davem@davemloft.net, robert.jarzmik@free.fr,
	fw@strlen.de, felipe.balbi@linux.intel.com, arnd@arndb.de,
	ahs3@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:58660 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751315AbcFXNQX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2016 09:16:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable lan91x adapters in some ARM machines and models
when booted with an ACPI kernel.

Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
---
 drivers/net/ethernet/smsc/smc91x.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 18ac52d..fcf69f9 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2203,6 +2203,12 @@ static const struct of_device_id smc91x_match[] = {
 };
 MODULE_DEVICE_TABLE(of, smc91x_match);
 
+static const struct acpi_device_id smsc91x_acpi_match[] = {
+	{ "LNRO0003", 0 },
+	{ }
+};
+MODULE_DEVICE_TABLE(acpi, smsc91x_acpi_match);
+
 /**
  * of_try_set_control_gpio - configure a gpio if it exists
  */
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
@@ -2479,6 +2485,7 @@ static struct platform_driver smc_driver = {
 		.name	= CARDNAME,
 		.pm	= &smc_drv_pm_ops,
 		.of_match_table = of_match_ptr(smc91x_match),
+		.acpi_match_table = smsc91x_acpi_match,
 	},
 };
 
-- 
2.5.5
