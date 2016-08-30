From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 4/4] net: smc91x: remove neponset specific oscillator hack
Date: Tue, 30 Aug 2016 11:52:50 +0100
Message-ID: <E1begew-00077B-LY@rmk-PC.armlinux.org.uk>
References: <20160830105117.GM1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Nicolas Pitre <nico@fluxnic.net>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:36589 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758030AbcH3Kw4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 06:52:56 -0400
In-Reply-To: <20160830105117.GM1041@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the neponset specific oscillator hack from the smc91x driver,
relying instead on the gpio controls provided.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/ethernet/smsc/smc91x.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 43dbc1c7b9a5..e53aa640f0d7 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -92,11 +92,6 @@ static const char version[] =
 
 #include "smc91x.h"
 
-#if defined(CONFIG_ASSABET_NEPONSET)
-#include <mach/assabet.h>
-#include <mach/neponset.h>
-#endif
-
 #ifndef SMC_NOWAIT
 # define SMC_NOWAIT		0
 #endif
@@ -2384,10 +2379,6 @@ static int smc_drv_probe(struct platform_device *pdev)
 	ret = smc_request_attrib(pdev, ndev);
 	if (ret)
 		goto out_release_io;
-#if defined(CONFIG_ASSABET_NEPONSET)
-	if (machine_is_assabet() && machine_has_neponset())
-		neponset_ncr_set(NCR_ENET_OSC_EN);
-#endif
 	if (lp->xtal) {
 		ret = clk_prepare_enable(lp->xtal);
 		if (ret)
-- 
2.1.0
