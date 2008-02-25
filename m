From: David Brownell <david-b@pacbell.net>
Subject: [patch 2.6.25-rc3] smc91x section fix
Date: Sun, 24 Feb 2008 19:34:11 -0800
Message-ID: <20080225033411.941C328DEAA@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: nico@cam.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp124.sbc.mail.sp1.yahoo.com ([69.147.64.97]:24750 "HELO
	smtp124.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751347AbYBYDeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2008 22:34:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Section fixup:

WARNING: drivers/net/built-in.o(.text+0x1a2c): Section mismatch
	in reference from the function smc_drv_probe()
	to the function .init.text:smc_probe()
The function smc_drv_probe() references
the function __init smc_probe().
This is often because smc_drv_probe lacks a __init
annotation or the annotation of smc_probe is wrong.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
---
 drivers/net/smc91x.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/smc91x.c	2008-02-24 18:50:32.000000000 -0800
+++ b/drivers/net/smc91x.c	2008-02-24 19:16:29.000000000 -0800
@@ -2121,7 +2121,7 @@ static void smc_release_datacs(struct pl
  *	0 --> there is a device
  *	anything else, error
  */
-static int smc_drv_probe(struct platform_device *pdev)
+static int __init smc_drv_probe(struct platform_device *pdev)
 {
 	struct net_device *ndev;
 	struct resource *res, *ires;
