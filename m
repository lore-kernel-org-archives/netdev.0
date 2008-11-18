From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 1/2] mv643xx_eth: fix the order of mdiobus_{unregister,free}() calls
Date: Tue, 18 Nov 2008 15:28:35 +0100
Message-ID: <20081118142835.GP5006@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:41506 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbYKRO2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 09:28:37 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 0e94ed3..7a6b37b 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2434,8 +2434,8 @@ static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 	struct mv643xx_eth_shared_platform_data *pd = pdev->dev.platform_data;
 
 	if (pd == NULL || pd->shared_smi == NULL) {
-		mdiobus_free(msp->smi_bus);
 		mdiobus_unregister(msp->smi_bus);
+		mdiobus_free(msp->smi_bus);
 	}
 	if (msp->err_interrupt != NO_IRQ)
 		free_irq(msp->err_interrupt, msp);
