From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/6] net: bcmgenet: Use correct dev_id for free_irq
Date: Thu, 16 Jul 2015 15:51:15 -0700
Message-ID: <1437087079-21678-3-git-send-email-f.fainelli@gmail.com>
References: <1437087079-21678-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33833 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755810AbbGPWxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 18:53:21 -0400
Received: by pacan13 with SMTP id an13so50123760pac.1
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 15:53:21 -0700 (PDT)
In-Reply-To: <1437087079-21678-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bcmgenet_open()'s error path call free_irq() with a dev_id argument
different from the one we used to call request_irq() with, this will
make us trip over the warning in kernel/irq/manage.c:__free_irq()

Fixes: 1c1008c793fa4 ("net: bcmgenet: add main driver file")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 674f374dceee..c634ddbbd21d 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2695,7 +2695,7 @@ static int bcmgenet_open(struct net_device *dev)
 	return 0;
 
 err_irq0:
-	free_irq(priv->irq0, dev);
+	free_irq(priv->irq0, priv);
 err_fini_dma:
 	bcmgenet_fini_dma(priv);
 err_clk_disable:
-- 
2.1.0
