From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: hip04: Remove superfluous ether_setup after alloc_etherdev
Date: Mon, 17 Oct 2016 09:22:04 +0200
Message-ID: <20161017072204.19777-1-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:56300 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757515AbcJQHWL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 03:22:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to call ether_setup after alloc_ethdev since it was
already called there.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/hisilicon/hip04_eth.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
index 3c99ca420f57..854befde0a08 100644
--- a/drivers/net/ethernet/hisilicon/hip04_eth.c
+++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
@@ -897,7 +897,6 @@ static int hip04_mac_probe(struct platform_device *pdev)
 
 	INIT_WORK(&priv->tx_timeout_task, hip04_tx_timeout_task);
 
-	ether_setup(ndev);
 	ndev->netdev_ops = &hip04_netdev_ops;
 	ndev->ethtool_ops = &hip04_ethtool_ops;
 	ndev->watchdog_timeo = TX_TIMEOUT;
-- 
2.9.0
