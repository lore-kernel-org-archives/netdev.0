From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 1/2] NetXen: Driver unload fixes
Date: Wed, 21 Feb 2007 06:52:27 -0800
Message-ID: <200702211452.l1LEqRPp029800@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, netxenproj@linsyssoft.com,
	rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:13713 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751279AbXBUOw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 09:52:28 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

---

My apologizes for sending patch with wrong order/number of patches in subject line.
Now I am resending both the patches with correct line.

Thanks,
--Amit

 netxen_nic_hw.c   |    9 +++++----
 netxen_nic_main.c |    2 +-
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 7195af3..deec796 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -242,10 +242,11 @@ int netxen_nic_hw_resources(struct netxe
 	adapter->cmd_consumer = (uint32_t *) (((char *)addr) +
 					      sizeof(struct netxen_ring_ctx));
 
-	addr = pci_alloc_consistent(adapter->ahw.pdev,
-				    sizeof(struct cmd_desc_type0) *
-				    adapter->max_tx_desc_count,
-				    (dma_addr_t *) & hw->cmd_desc_phys_addr);
+	addr = netxen_alloc(adapter->ahw.pdev,
+			    sizeof(struct cmd_desc_type0) *
+			    adapter->max_tx_desc_count,
+			    (dma_addr_t *) & hw->cmd_desc_phys_addr,
+			    &adapter->ahw.cmd_desc_pdev);
 	printk("cmd_desc_phys_addr: 0x%llx\n", (u64) hw->cmd_desc_phys_addr);
 
 	if (addr == NULL) {
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 225ff55..b2fc2bc 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1155,8 +1155,8 @@ static void __exit netxen_exit_module(vo
 	/*
 	 * Wait for some time to allow the dma to drain, if any.
 	 */
-	destroy_workqueue(netxen_workq);
 	pci_unregister_driver(&netxen_driver);
+	destroy_workqueue(netxen_workq);
 }
 
 module_exit(netxen_exit_module);
