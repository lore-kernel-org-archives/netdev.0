From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 2/2] netdev: mdio-octeon: Fix section mismatch errors.
Date: Thu, 24 Jun 2010 12:14:48 -0700
Message-ID: <1277406888-26309-3-git-send-email-ddaney@caviumnetworks.com>
References: <1277406888-26309-1-git-send-email-ddaney@caviumnetworks.com>
Cc: linux-mips@linux-mips.org, David Daney <ddaney@caviumnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:16167 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434Ab0FXTO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 15:14:59 -0400
In-Reply-To: <1277406888-26309-1-git-send-email-ddaney@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We started getting:

WARNING: vmlinux.o(.data+0x20bd0): Section mismatch in reference from
the variable octeon_mdiobus_driver to the function
.init.text:octeon_mdiobus_probe()

This fixes it.

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 drivers/net/phy/mdio-octeon.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
index f443d43..bd12ba9 100644
--- a/drivers/net/phy/mdio-octeon.c
+++ b/drivers/net/phy/mdio-octeon.c
@@ -85,7 +85,7 @@ static int octeon_mdiobus_write(struct mii_bus *bus, int phy_id,
 	return 0;
 }
 
-static int __init octeon_mdiobus_probe(struct platform_device *pdev)
+static int __devinit octeon_mdiobus_probe(struct platform_device *pdev)
 {
 	struct octeon_mdiobus *bus;
 	union cvmx_smix_en smi_en;
@@ -143,7 +143,7 @@ err:
 	return err;
 }
 
-static int __exit octeon_mdiobus_remove(struct platform_device *pdev)
+static int __devexit octeon_mdiobus_remove(struct platform_device *pdev)
 {
 	struct octeon_mdiobus *bus;
 	union cvmx_smix_en smi_en;
@@ -163,7 +163,7 @@ static struct platform_driver octeon_mdiobus_driver = {
 		.owner		= THIS_MODULE,
 	},
 	.probe		= octeon_mdiobus_probe,
-	.remove		= __exit_p(octeon_mdiobus_remove),
+	.remove		= __devexit_p(octeon_mdiobus_remove),
 };
 
 void octeon_mdiobus_force_mod_depencency(void)
-- 
1.6.6.1

