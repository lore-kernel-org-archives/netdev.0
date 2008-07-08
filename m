From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 02/25] ixgb: repeat 32 bit ioremap cleanup
Date: Tue, 08 Jul 2008 15:51:12 -0700
Message-ID: <20080708225112.6925.48330.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:1237 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753295AbYGHWvN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:51:13 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

this patch has been made to many other drivers in kernel to fix
the storage of 64 bit resources in 32 bit variables.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   13 +++----------
 1 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 04cac41..652c0ea 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -363,8 +363,6 @@ ixgb_probe(struct pci_dev *pdev,
 	struct net_device *netdev = NULL;
 	struct ixgb_adapter *adapter;
 	static int cards_found = 0;
-	unsigned long mmio_start;
-	int mmio_len;
 	int pci_using_dac;
 	int i;
 	int err;
@@ -405,11 +403,9 @@ ixgb_probe(struct pci_dev *pdev,
 	adapter->hw.back = adapter;
 	adapter->msg_enable = netif_msg_init(debug, DEFAULT_DEBUG_LEVEL_SHIFT);
 
-	mmio_start = pci_resource_start(pdev, BAR_0);
-	mmio_len = pci_resource_len(pdev, BAR_0);
-
-	adapter->hw.hw_addr = ioremap(mmio_start, mmio_len);
-	if(!adapter->hw.hw_addr) {
+	adapter->hw.hw_addr = ioremap(pci_resource_start(pdev, BAR_0),
+	                              pci_resource_len(pdev, BAR_0));
+	if (!adapter->hw.hw_addr) {
 		err = -EIO;
 		goto err_ioremap;
 	}
@@ -444,9 +440,6 @@ ixgb_probe(struct pci_dev *pdev,
 #endif
 
 	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
-	netdev->mem_start = mmio_start;
-	netdev->mem_end = mmio_start + mmio_len;
-	netdev->base_addr = adapter->hw.io_base;
 
 	adapter->bd_number = cards_found;
 	adapter->link_speed = 0;

