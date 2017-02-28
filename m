From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: axienet: use eth_hw_addr_random()
Date: Tue, 28 Feb 2017 12:21:12 +0100
Message-ID: <20170228112112.29450-1-tklauser@distanz.ch>
Cc: michal.simek@xilinx.com, soren.brinkmann@xilinx.com,
        netdev@vger.kernel.org
To: anirudh@xilinx.com, John.Linn@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:34818 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751625AbdB1LVc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Feb 2017 06:21:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use eth_hw_addr_random() to set a random MAC address in order to make
sure ndev->addr_assign_type will be properly set to NET_ADDR_RANDOM.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index b96e96919e31..33c595f4691d 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -301,7 +301,7 @@ static void axienet_set_mac_address(struct net_device *ndev,
 	if (address)
 		memcpy(ndev->dev_addr, address, ETH_ALEN);
 	if (!is_valid_ether_addr(ndev->dev_addr))
-		eth_random_addr(ndev->dev_addr);
+		eth_hw_addr_random(ndev);
 
 	/* Set up unicast MAC address filter set its mac address */
 	axienet_iow(lp, XAE_UAW0_OFFSET,
-- 
2.11.0
