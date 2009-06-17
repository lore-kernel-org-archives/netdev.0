From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/9] sky2: turn off pause during shutdown
Date: Wed, 17 Jun 2009 10:30:32 -0700
Message-ID: <20090617173139.536423149@vyatta.com>
References: <20090617173031.703636683@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:45314 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758462AbZFQReE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 13:34:04 -0400
Content-Disposition: inline; filename=sky2-gmac-shut.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This unblocks the chip if it is stuck in pause cycle during
shutdown.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2009-06-17 10:29:17.292748274 -0700
+++ b/drivers/net/sky2.c	2009-06-17 10:29:50.630937431 -0700
@@ -1808,7 +1808,8 @@ static int sky2_down(struct net_device *
 
 	synchronize_irq(hw->pdev->irq);
 
-	sky2_gmac_reset(hw, port);
+	/* Force flow control off */
+	sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_OFF);
 
 	/* Stop transmitter */
 	sky2_write32(hw, Q_ADDR(txqaddr[port], Q_CSR), BMU_STOP);

-- 

