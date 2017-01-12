From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: Initialize mbox lock and list for mgmt dev
Date: Thu, 12 Jan 2017 12:23:21 +0530
Message-ID: <1484204001-19013-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, hariprasad@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:34218 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750734AbdALGxY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 01:53:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialize mbox lock and list for mgmt dev to avoid NULL pointer
dereference when cxgb_set_vf_mac is called.

And also allocate memory for private data while allocating mgmt
netdev.

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 3349e1f..e95bb6a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4516,7 +4516,8 @@ static int config_mgmt_dev(struct pci_dev *pdev)
 	int err;
 
 	snprintf(name, IFNAMSIZ, "mgmtpf%d%d", adap->adap_idx, adap->pf);
-	netdev = alloc_netdev(0, name, NET_NAME_UNKNOWN, dummy_setup);
+	netdev = alloc_netdev(sizeof(struct port_info), name, NET_NAME_UNKNOWN,
+			      dummy_setup);
 	if (!netdev)
 		return -ENOMEM;
 
@@ -4990,6 +4991,8 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		err = -ENOMEM;
 		goto free_adapter;
 	}
+	spin_lock_init(&adapter->mbox_lock);
+	INIT_LIST_HEAD(&adapter->mlist.list);
 	pci_set_drvdata(pdev, adapter);
 	return 0;
 
-- 
2.1.0
