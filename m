From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH] cxgb4/cxgb4vf: Assign netdev->dev_port with port ID
Date: Thu,  8 Dec 2016 18:09:23 +0530
Message-ID: <1481200763-15799-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, Arjun V <arjun@chelsio.com>,
        Casey Leedom <leedom@chelsio.com>,
        Hariprasad Shenai <hariprasad@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:30459 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751064AbcLHMoa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 07:44:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjun V <arjun@chelsio.com>

Added missing dev_port assignment in cxgb4vf driver.
Also made dev_port assignment of cxgb4 in sync with cxgb4vf driver.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Arjun V <arjun@chelsio.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c     | 1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c          | 1 -
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c | 1 +
 3 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 48113c6..66c37fa 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4921,6 +4921,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 */
 	for_each_port(adapter, i) {
 		pi = adap2pinfo(adapter, i);
+		adapter->port[i]->dev_port = pi->lport;
 		netif_set_real_num_tx_queues(adapter->port[i], pi->nqsets);
 		netif_set_real_num_rx_queues(adapter->port[i], pi->nqsets);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 20dec85..e813951 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -7851,7 +7851,6 @@ int t4_port_init(struct adapter *adap, int mbox, int pf, int vf)
 			return ret;
 
 		memcpy(adap->port[i]->dev_addr, addr, ETH_ALEN);
-		adap->port[i]->dev_port = j;
 		j++;
 	}
 	return 0;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index fa43e06d..0d1a134 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2960,6 +2960,7 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 
 		netdev->netdev_ops = &cxgb4vf_netdev_ops;
 		netdev->ethtool_ops = &cxgb4vf_ethtool_ops;
+		netdev->dev_port = pi->port_id;
 
 		/*
 		 * Initialize the hardware/software state for the port.
-- 
2.1.0
