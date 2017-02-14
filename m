From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: hip04: Omit private ndo_get_stats function
Date: Tue, 14 Feb 2017 15:10:06 +0100
Message-ID: <20170214141006.11510-1-tklauser@distanz.ch>
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:57784 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753086AbdBNOKV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Feb 2017 09:10:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hip04_get_stats() just returns dev->stats so we can leave it
out altogether and let dev_get_stats() do the job.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/hisilicon/hip04_eth.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
index 6e50ec82b3d8..0cec06bec63e 100644
--- a/drivers/net/ethernet/hisilicon/hip04_eth.c
+++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
@@ -701,11 +701,6 @@ static void hip04_tx_timeout_task(struct work_struct *work)
 	hip04_mac_open(priv->ndev);
 }
 
-static struct net_device_stats *hip04_get_stats(struct net_device *ndev)
-{
-	return &ndev->stats;
-}
-
 static int hip04_get_coalesce(struct net_device *netdev,
 			      struct ethtool_coalesce *ec)
 {
@@ -764,7 +759,6 @@ static const struct ethtool_ops hip04_ethtool_ops = {
 static const struct net_device_ops hip04_netdev_ops = {
 	.ndo_open		= hip04_mac_open,
 	.ndo_stop		= hip04_mac_stop,
-	.ndo_get_stats		= hip04_get_stats,
 	.ndo_start_xmit		= hip04_mac_start_xmit,
 	.ndo_set_mac_address	= hip04_set_mac_address,
 	.ndo_tx_timeout         = hip04_timeout,
-- 
2.11.0
