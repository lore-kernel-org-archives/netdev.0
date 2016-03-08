From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 4/4] cxgb4vf: Set number of queues in pci probe only
Date: Tue,  8 Mar 2016 10:50:20 +0530
Message-ID: <1457414420-5237-5-git-send-email-hariprasad@chelsio.com>
References: <1457414420-5237-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:48167 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753971AbcCHFWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 00:22:21 -0500
In-Reply-To: <1457414420-5237-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 5a3b883..1cc8a7a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -790,10 +790,6 @@ static int cxgb4vf_open(struct net_device *dev)
 	/*
 	 * Note that this interface is up and start everything up ...
 	 */
-	netif_set_real_num_tx_queues(dev, pi->nqsets);
-	err = netif_set_real_num_rx_queues(dev, pi->nqsets);
-	if (err)
-		goto err_unwind;
 	err = link_start(dev);
 	if (err)
 		goto err_unwind;
@@ -2831,10 +2827,14 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 	 * must register at least one net device.
 	 */
 	for_each_port(adapter, pidx) {
+		struct port_info *pi = netdev_priv(adapter->port[pidx]);
 		netdev = adapter->port[pidx];
 		if (netdev == NULL)
 			continue;
 
+		netif_set_real_num_tx_queues(netdev, pi->nqsets);
+		netif_set_real_num_rx_queues(netdev, pi->nqsets);
+
 		err = register_netdev(netdev);
 		if (err) {
 			dev_warn(&pdev->dev, "cannot register net device %s,"
-- 
1.7.3
