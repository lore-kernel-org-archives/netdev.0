From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 3/9] cxgb3 - Fix resources release.
Date: Fri, 16 Nov 2007 11:21:50 -0800
Message-ID: <20071116192150.31060.44605.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com,
	wenxiong@us.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:11569 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764513AbXKPTVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 14:21:55 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Remove sysfs entries before unregistering the net devices.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index d92da8f..9d14652 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2585,10 +2585,6 @@ static void __devexit remove_one(struct pci_dev *pdev)
 		sysfs_remove_group(&adapter->port[0]->dev.kobj,
 				   &cxgb3_attr_group);
 
-		for_each_port(adapter, i)
-		    if (test_bit(i, &adapter->registered_device_map))
-			unregister_netdev(adapter->port[i]);
-
 		if (is_offload(adapter)) {
 			cxgb3_adapter_unofld(adapter);
 			if (test_bit(OFFLOAD_DEVMAP_BIT,
@@ -2596,6 +2592,10 @@ static void __devexit remove_one(struct pci_dev *pdev)
 				offload_close(&adapter->tdev);
 		}
 
+		for_each_port(adapter, i)
+		    if (test_bit(i, &adapter->registered_device_map))
+			unregister_netdev(adapter->port[i]);
+
 		t3_free_sge_resources(adapter);
 		cxgb_disable_msi(adapter);
 
