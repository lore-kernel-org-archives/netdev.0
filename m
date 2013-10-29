From: Luka Perkov <luka@openwrt.org>
Subject: [PATCH v2] arc_emac: drop redundant mac address check
Date: Wed, 30 Oct 2013 00:11:00 +0100
Message-ID: <1383088260-25422-1-git-send-email-luka@openwrt.org>
Cc: Luka Perkov <luka@openwrt.org>,
	Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:33309 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751834Ab3J2XLI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 19:11:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Checking if MAC address is valid using is_valid_ether_addr() is already done in
of_get_mac_address(). While at it, reorganize checking so it matches checks in
other drivers.

Signed-off-by: Luka Perkov <luka@openwrt.org>
CC: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
CC: David Miller <davem@davemloft.net>
---
v1->v2:

 * cosmetic commit message fix based on comment from David Miller
---
 drivers/net/ethernet/arc/emac_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 9e16014..d818ded 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -725,10 +725,10 @@ static int arc_emac_probe(struct platform_device *pdev)
 	/* Get MAC address from device tree */
 	mac_addr = of_get_mac_address(pdev->dev.of_node);
 
-	if (!mac_addr || !is_valid_ether_addr(mac_addr))
-		eth_hw_addr_random(ndev);
-	else
+	if (mac_addr)
 		memcpy(ndev->dev_addr, mac_addr, ETH_ALEN);
+	else
+		eth_hw_addr_random(ndev);
 
 	dev_info(&pdev->dev, "MAC address is now %pM\n", ndev->dev_addr);
 
-- 
1.8.4.2
