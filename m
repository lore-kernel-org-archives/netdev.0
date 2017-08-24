From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: systemport: Be drop monitor friendly
Date: Thu, 24 Aug 2017 15:20:41 -0700
Message-ID: <20170824222041.8377-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, edumazet@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:32814 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753566AbdHXWUt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 18:20:49 -0400
Received: by mail-wr0-f195.google.com with SMTP id z91so471527wrc.0
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 15:20:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Utilize dev_consume_skb_any(cb->skb) in bcm_sysport_free_cb() which is
used when a TX packet is completed, as well as when the RX ring is
cleaned on shutdown. None of these two cases are packet drops, so be
drop monitor friendly.

Suggested-by: Eric Dumazet <edumazet@gmail.com>
Fixes: 80105befdb4b ("net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index dc3052751bc1..e6add99cc31c 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -597,7 +597,7 @@ static int bcm_sysport_set_coalesce(struct net_device *dev,
 
 static void bcm_sysport_free_cb(struct bcm_sysport_cb *cb)
 {
-	dev_kfree_skb_any(cb->skb);
+	dev_consume_skb_any(cb->skb);
 	cb->skb = NULL;
 	dma_unmap_addr_set(cb, dma_addr, 0);
 }
-- 
2.9.3
