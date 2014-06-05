From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/4] net: systemport: correctly check for RX_STATUS_OVFLOW flag
Date: Thu,  5 Jun 2014 10:22:16 -0700
Message-ID: <1401988938-25940-3-git-send-email-f.fainelli@gmail.com>
References: <1401988938-25940-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:45811 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489AbaFERWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 13:22:40 -0400
Received: by mail-pb0-f50.google.com with SMTP id ma3so1389781pbc.37
        for <netdev@vger.kernel.org>; Thu, 05 Jun 2014 10:22:40 -0700 (PDT)
In-Reply-To: <1401988938-25940-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were missing an and comparison with status to check whether
RX_STATUS_OVFLOW is asserted or not in the per-packet status word, fix
that.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 4dfc93fe9744..fc84aba0cde0 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -514,7 +514,7 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 
 		if (unlikely(status & (RX_STATUS_ERR | RX_STATUS_OVFLOW))) {
 			netif_err(priv, rx_err, ndev, "error packet\n");
-			if (RX_STATUS_OVFLOW)
+			if (status & RX_STATUS_OVFLOW)
 				ndev->stats.rx_over_errors++;
 			ndev->stats.rx_dropped++;
 			ndev->stats.rx_errors++;
-- 
1.9.1
