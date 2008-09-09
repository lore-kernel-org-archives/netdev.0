From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 09/24] ixgbe: fix pci_resource allocation as in other
	drivers
Date: Mon, 08 Sep 2008 21:47:56 -0700
Message-ID: <20080909044756.18904.15154.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:55949 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928AbYIIEr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 00:47:59 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1867494wfd.4
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 21:47:58 -0700 (PDT)
In-Reply-To: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Form: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   10 ++--------
 1 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 2c8895e..0269115 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3605,7 +3605,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	struct ixgbe_adapter *adapter = NULL;
 	struct ixgbe_hw *hw;
 	const struct ixgbe_info *ii = ixgbe_info_tbl[ent->driver_data];
-	unsigned long mmio_start, mmio_len;
 	static int cards_found;
 	int i, err, pci_using_dac;
 	u16 link_status, link_speed, link_width;
@@ -3657,10 +3656,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	hw->back = adapter;
 	adapter->msg_enable = (1 << DEFAULT_DEBUG_LEVEL_SHIFT) - 1;
 
-	mmio_start = pci_resource_start(pdev, 0);
-	mmio_len = pci_resource_len(pdev, 0);
-
-	hw->hw_addr = ioremap(mmio_start, mmio_len);
+	hw->hw_addr = ioremap(pci_resource_start(pdev, 0),
+	                      pci_resource_len(pdev, 0));
 	if (!hw->hw_addr) {
 		err = -EIO;
 		goto err_ioremap;
@@ -3690,9 +3687,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 #endif
 	strcpy(netdev->name, pci_name(pdev));
 
-	netdev->mem_start = mmio_start;
-	netdev->mem_end = mmio_start + mmio_len;
-
 	adapter->bd_number = cards_found;
 
 	/* PCI config space info */

