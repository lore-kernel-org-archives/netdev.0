From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next v2] cxgb4: keep carrier off before registering netdev
Date: Tue, 30 May 2017 11:32:06 +0530
Message-ID: <1496124126-18597-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com,
        Surendra Mobiya <surendra@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:27477 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750720AbdE3GDQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 02:03:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Surendra Mobiya <surendra@chelsio.com>

Mark carrier off before registering netdev to ensure that vlan device
picks up the correct state of the carrier

Signed-off-by: Surendra Mobiya <surendra@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
v2:
- keep carrier off before registering netdev not after

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 2ae54d5..06c3414 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4956,6 +4956,8 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		netif_set_real_num_tx_queues(adapter->port[i], pi->nqsets);
 		netif_set_real_num_rx_queues(adapter->port[i], pi->nqsets);
 
+		netif_carrier_off(adapter->port[i]);
+
 		err = register_netdev(adapter->port[i]);
 		if (err)
 			break;
-- 
2.1.0
