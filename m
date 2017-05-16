From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: keep carrier off after registering netdev
Date: Tue, 16 May 2017 21:26:25 +0530
Message-ID: <1494950185-15356-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com,
        Surendra Mobiya <surendra@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:47317 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750777AbdEPP4x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 11:56:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Surendra Mobiya <surendra@chelsio.com>

Mark carrier off after registering netdev to ensure that vlan device
picks up the correct state of the carrier

Signed-off-by: Surendra Mobiya <surendra@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 4249ffb..316ba8b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4954,6 +4954,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 			break;
 		adapter->chan_map[pi->tx_chan] = i;
 		print_port_info(adapter->port[i]);
+		netif_carrier_off(adapter->port[i]);
 	}
 	if (i == 0) {
 		dev_err(&pdev->dev, "could not register any net devices\n");
-- 
2.1.0
