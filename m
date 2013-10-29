From: Luka Perkov <luka@openwrt.org>
Subject: [PATCH] ethernet/arc/arc_emac: drop redundant mac address check
Date: Tue, 29 Oct 2013 02:32:20 +0100
Message-ID: <1383010340-26445-1-git-send-email-luka@openwrt.org>
Cc: abrodkin@synopsys.com, Luka Perkov <luka@openwrt.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:35813 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756824Ab3J2Bcd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Oct 2013 21:32:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Checking if MAC address is valid using is_valid_ether_addr() is already done in
of_get_mac_address(). While at it, reorganize checking so it matches checks in
other drivers.

Signed-off-by: Luka Perkov <luka@openwrt.org>
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
1.8.4.1
