From: Atsushi Nemoto <nemoto@toshiba-tops.co.jp>
Subject: [PATCH] net: eth: altera: Fix the initial device operstate
Date: Tue, 8 Sep 2015 18:15:41 +0900
Message-ID: <20150908.181541.478844573.nemoto@toshiba-tops.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vince Bridgers <vbridger@opensource.altera.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from topsowa.toshiba-tops.co.jp ([61.200.21.19]:43740 "EHLO
	TPSSRV64.toshiba-tops.co.jp" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753171AbbIHJQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 05:16:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call netif_carrier_off() prior to register_netdev(), otherwise
userspace can see incorrect link state.

Signed-off-by: Atsushi Nemoto <nemoto@toshiba-tops.co.jp>
---
 drivers/net/ethernet/altera/altera_tse_main.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index 3ade46c..91fd718 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -1518,6 +1518,7 @@ static int altera_tse_probe(struct platform_device *pdev)
 	spin_lock_init(&priv->tx_lock);
 	spin_lock_init(&priv->rxdma_irq_lock);
 
+	netif_carrier_off(ndev);
 	ret = register_netdev(ndev);
 	if (ret) {
 		dev_err(&pdev->dev, "failed to register TSE net device\n");
-- 
