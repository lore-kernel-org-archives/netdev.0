From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/3] net: bcmgenet: start with carrier off
Date: Thu, 26 Jun 2014 10:26:21 -0700
Message-ID: <1403803582-13472-3-git-send-email-f.fainelli@gmail.com>
References: <1403803582-13472-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:38940 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756822AbaFZR0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 13:26:36 -0400
Received: by mail-qc0-f170.google.com with SMTP id l6so3470581qcy.15
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 10:26:36 -0700 (PDT)
In-Reply-To: <1403803582-13472-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We use the PHY library which will determine the link state for us, make
sure we start with a carrier off until libphy has completed the link
training.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index d17953cc5f49..e51e462bc8fd 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2535,6 +2535,9 @@ static int bcmgenet_probe(struct platform_device *pdev)
 	netif_set_real_num_tx_queues(priv->dev, priv->hw_params->tx_queues + 1);
 	netif_set_real_num_rx_queues(priv->dev, priv->hw_params->rx_queues + 1);
 
+	/* libphy will determine the link state */
+	netif_carrier_off(dev);
+
 	/* Turn off the main clock, WOL clock is handled separately */
 	if (!IS_ERR(priv->clk))
 		clk_disable_unprepare(priv->clk);
-- 
1.9.1
