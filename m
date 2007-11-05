From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 5/7] sky2: remove unneeded mask update
Date: Mon, 05 Nov 2007 15:52:12 -0800
Message-ID: <20071105235340.198117318@linux-foundation.org>
References: <20071105235207.799504040@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49650 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754671AbXKEX5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 18:57:04 -0500
Content-Disposition: inline; filename=sky2-no-phy-irq-mask.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IRQ's is already masked on shutdown, and on startup avoid
touching PHY until after phy_init().

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-11-05 15:05:01.000000000 -0800
+++ b/drivers/net/sky2.c	2007-11-05 15:05:03.000000000 -0800
@@ -288,8 +288,6 @@ static void sky2_gmac_reset(struct sky2_
 
 	/* disable all GMAC IRQ's */
 	sky2_write8(hw, SK_REG(port, GMAC_IRQ_MSK), 0);
-	/* disable PHY IRQs */
-	gm_phy_write(hw, port, PHY_MARV_INT_MASK, 0);
 
 	gma_write16(hw, port, GM_MC_ADDR_H1, 0);	/* clear MC hash */
 	gma_write16(hw, port, GM_MC_ADDR_H2, 0);

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

