From: Michal Simek <monstr@monstr.eu>
Subject: [PATCH] ll_temac: Fix poll implementation
Date: Wed, 18 Aug 2010 12:26:34 +0200
Message-ID: <1282127194-4185-1-git-send-email-monstr@monstr.eu>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Michal Simek <monstr@monstr.eu>
To: glikely@secretlab.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:43495 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223Ab0HRK0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 06:26:39 -0400
Received: by bwz11 with SMTP id 11so58396bwz.19
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 03:26:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Functions ll_temac_rx_irq and ll_temac_tx_irq
have pointer to net_device as second parameter not
pointer to temac_local.

Signed-off-by: Michal Simek <monstr@monstr.eu>
---
 drivers/net/ll_temac_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index c7b6247..bdf2149 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -902,8 +902,8 @@ temac_poll_controller(struct net_device *ndev)
 	disable_irq(lp->tx_irq);
 	disable_irq(lp->rx_irq);
 
-	ll_temac_rx_irq(lp->tx_irq, lp);
-	ll_temac_tx_irq(lp->rx_irq, lp);
+	ll_temac_rx_irq(lp->tx_irq, ndev);
+	ll_temac_tx_irq(lp->rx_irq, ndev);
 
 	enable_irq(lp->tx_irq);
 	enable_irq(lp->rx_irq);
-- 
1.5.5.6

