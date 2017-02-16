From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: ethoc: Use eth_hw_addr_random()
Date: Thu, 16 Feb 2017 13:54:32 +0100
Message-ID: <20170216125432.9594-1-tklauser@distanz.ch>
Cc: f.fainelli@gmail.com, thierry.reding@gmail.com,
        colin.king@canonical.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:46908 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753526AbdBPMyf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:54:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use eth_hw_addr_random() to set a random dev_addr and update
addr_assign_type instead of open-coding it.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/ethoc.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index f18aba05f1c2..23d82748f52b 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -1031,7 +1031,6 @@ static int ethoc_probe(struct platform_device *pdev)
 	struct ethoc *priv = NULL;
 	int num_bd;
 	int ret = 0;
-	bool random_mac = false;
 	struct ethoc_platform_data *pdata = dev_get_platdata(&pdev->dev);
 	u32 eth_clkfreq = pdata ? pdata->eth_clkfreq : 0;
 
@@ -1169,16 +1168,11 @@ static int ethoc_probe(struct platform_device *pdev)
 	/* Check the MAC again for validity, if it still isn't choose and
 	 * program a random one.
 	 */
-	if (!is_valid_ether_addr(netdev->dev_addr)) {
-		eth_random_addr(netdev->dev_addr);
-		random_mac = true;
-	}
+	if (!is_valid_ether_addr(netdev->dev_addr))
+		eth_hw_addr_random(netdev);
 
 	ethoc_do_set_mac_address(netdev);
 
-	if (random_mac)
-		netdev->addr_assign_type = NET_ADDR_RANDOM;
-
 	/* Allow the platform setup code to adjust MII management bus clock. */
 	if (!eth_clkfreq) {
 		struct clk *clk = devm_clk_get(&pdev->dev, NULL);
-- 
2.11.0
