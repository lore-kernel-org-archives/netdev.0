From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH/RFC net] ravb: Remove Rx overflow log messages
Date: Thu, 12 Jan 2017 09:41:10 +0100
Message-ID: <1484210470-3095-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:40319 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750886AbdALIml (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 03:42:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>

Remove Rx overflow log messages as in an environment where logging results
in network traffic logging may cause further overflows.

Fixes: c156633f1353 ("Renesas Ethernet AVB driver proper")
Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
[simon: reworked changelog]
Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
---
 drivers/net/ethernet/renesas/ravb_main.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 92d7692c840d..5e5ad978eab9 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -926,14 +926,10 @@ static int ravb_poll(struct napi_struct *napi, int budget)
 	/* Receive error message handling */
 	priv->rx_over_errors =  priv->stats[RAVB_BE].rx_over_errors;
 	priv->rx_over_errors += priv->stats[RAVB_NC].rx_over_errors;
-	if (priv->rx_over_errors != ndev->stats.rx_over_errors) {
+	if (priv->rx_over_errors != ndev->stats.rx_over_errors)
 		ndev->stats.rx_over_errors = priv->rx_over_errors;
-		netif_err(priv, rx_err, ndev, "Receive Descriptor Empty\n");
-	}
-	if (priv->rx_fifo_errors != ndev->stats.rx_fifo_errors) {
+	if (priv->rx_fifo_errors != ndev->stats.rx_fifo_errors)
 		ndev->stats.rx_fifo_errors = priv->rx_fifo_errors;
-		netif_err(priv, rx_err, ndev, "Receive FIFO Overflow\n");
-	}
 out:
 	return budget - quota;
 }
-- 
2.7.0.rc3.207.g0ac5344
