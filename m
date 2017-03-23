From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/3] net: systemport: Simplify circular pointer arithmetic
Date: Thu, 23 Mar 2017 10:36:48 -0700
Message-ID: <20170323173648.21143-4-f.fainelli@gmail.com>
References: <20170323173648.21143-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35704 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755341AbdCWRiN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 13:38:13 -0400
Received: by mail-wr0-f193.google.com with SMTP id u108so32229510wrb.2
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 10:38:12 -0700 (PDT)
In-Reply-To: <20170323173648.21143-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to c298ede2fe21 ("net: bcmgenet: simplify circular pointer
arithmetic") we don't need to complex arthimetic since we always have a
ring size that is a power of 2.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index c915bcfae0af..61e26c6b26ab 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -682,11 +682,7 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 		p_index = rdma_readl(priv, RDMA_CONS_INDEX);
 	p_index &= RDMA_PROD_INDEX_MASK;
 
-	if (p_index < priv->rx_c_index)
-		to_process = (RDMA_CONS_INDEX_MASK + 1) -
-			priv->rx_c_index + p_index;
-	else
-		to_process = p_index - priv->rx_c_index;
+	to_process = (p_index - priv->rx_c_index) & RDMA_CONS_INDEX_MASK;
 
 	netif_dbg(priv, rx_status, ndev,
 		  "p_index=%d rx_c_index=%d to_process=%d\n",
-- 
2.9.3
