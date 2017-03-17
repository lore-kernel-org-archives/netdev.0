From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] net: ethoc: Use ether_addr_copy()
Date: Fri, 17 Mar 2017 11:52:15 +0100
Message-ID: <20170317105215.2148-1-tklauser@distanz.ch>
Cc: f.fainelli@gmail.com, thierry.reding@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:36614 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750926AbdCQKx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Mar 2017 06:53:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use ether_addr_copy() instead of memcpy() to set netdev->dev_addr (which
is 2-byte aligned).

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/ethoc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 23d82748f52b..e863ba74d005 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -1148,14 +1148,14 @@ static int ethoc_probe(struct platform_device *pdev)
 
 	/* Allow the platform setup code to pass in a MAC address. */
 	if (pdata) {
-		memcpy(netdev->dev_addr, pdata->hwaddr, IFHWADDRLEN);
+		ether_addr_copy(netdev->dev_addr, pdata->hwaddr);
 		priv->phy_id = pdata->phy_id;
 	} else {
 		const void *mac;
 
 		mac = of_get_mac_address(pdev->dev.of_node);
 		if (mac)
-			memcpy(netdev->dev_addr, mac, IFHWADDRLEN);
+			ether_addr_copy(netdev->dev_addr, mac);
 		priv->phy_id = -1;
 	}
 
-- 
2.11.0
