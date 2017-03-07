From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: mediatek: Use eth_hw_addr_random()
Date: Tue,  7 Mar 2017 16:27:10 +0100
Message-ID: <20170307152710.19458-1-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: Felix Fietkau <nbd@openwrt.org>, John Crispin <blogic@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:55280 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755419AbdCGPec (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Mar 2017 10:34:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use eth_hw_addr_random() to set a random dev_addr and update
addr_assign_type instead of open-coding it.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 9e757684816d..bf6317eca2f6 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1908,10 +1908,9 @@ static int __init mtk_init(struct net_device *dev)
 
 	/* If the mac address is invalid, use random mac address  */
 	if (!is_valid_ether_addr(dev->dev_addr)) {
-		random_ether_addr(dev->dev_addr);
+		eth_hw_addr_random(dev);
 		dev_err(eth->dev, "generated random MAC address %pM\n",
 			dev->dev_addr);
-		dev->addr_assign_type = NET_ADDR_RANDOM;
 	}
 
 	return mtk_phy_connect(dev);
-- 
2.11.0
