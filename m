From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 3/4] ipg: fix queue stop condition in the xmit handler
Date: Fri, 11 Jan 2008 00:37:52 +0100
Message-ID: <20080110233752.GD13315@electric-eye.fr.zoreil.com>
References: <20080110233508.GA13315@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux@horizon.com, jeff@garzik.org,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:42969 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753275AbYAJX4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 18:56:00 -0500
Content-Disposition: inline
In-Reply-To: <20080110233508.GA13315@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ipg.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index 9752902..b234b29 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -1994,7 +1994,7 @@ static int ipg_nic_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	ipg_w32(IPG_DC_TX_DMA_POLL_NOW, DMA_CTRL);
 
 	if (sp->tx_current == (sp->tx_dirty + IPG_TFDLIST_LENGTH))
-		netif_wake_queue(dev);
+		netif_stop_queue(dev);
 
 	spin_unlock_irqrestore(&sp->lock, flags);
 
-- 
1.5.3.3

