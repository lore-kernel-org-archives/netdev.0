From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH 6/8] net/at91_ether: drop board_data private struct member
Date: Wed,  7 Nov 2012 19:14:55 +0100
Message-ID: <1352312097-31320-7-git-send-email-manabian@gmail.com>
References: <1352312097-31320-1-git-send-email-manabian@gmail.com>
Cc: plagnioj@jcrosoft.com, netdev@vger.kernel.org,
	Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:60048 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732Ab2KGSPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 13:15:18 -0500
Received: by mail-lb0-f174.google.com with SMTP id n3so1512078lbo.19
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2012 10:15:18 -0800 (PST)
In-Reply-To: <1352312097-31320-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No longer used after gpio phy interrupt support was
removed from at91_ether.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/cadence/at91_ether.c | 2 --
 drivers/net/ethernet/cadence/macb.h       | 7 +------
 2 files changed, 1 insertion(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 65a9afa..67b66c4 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -387,8 +387,6 @@ static int __init at91ether_probe(struct platform_device *pdev)
 	lp = netdev_priv(dev);
 	lp->pdev = pdev;
 	lp->dev = dev;
-	if (board_data)
-		lp->board_data = *board_data;
 	spin_lock_init(&lp->lock);
 
 	dev->base_addr = regs->start;		/* physical base address */
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 97f74dd..864e380 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -557,12 +557,7 @@ struct macb {
 
 	phy_interface_t		phy_interface;
 
-	/* at91_private */
-	struct macb_platform_data board_data;	/* board-specific
-						 * configuration (shared with
-						 * macb for common data */
-
-	/* Transmit */
+	/* AT91RM9200 transmit */
 	struct sk_buff *skb;			/* holds skb until xmit interrupt completes */
 	dma_addr_t skb_physaddr;		/* phys addr from pci_map_single */
 	int skb_length;				/* saved skb length for pci_unmap_single */
-- 
1.8.0
