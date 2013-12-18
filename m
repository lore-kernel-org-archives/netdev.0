From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 5/5] ixgbe: fix for unused variable warning with certain config
Date: Tue, 17 Dec 2013 23:19:46 -0800
Message-ID: <1387351186-23389-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387351186-23389-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:18475 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751586Ab3LRHTu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 02:19:50 -0500
In-Reply-To: <1387351186-23389-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

If CONFIG_PCI_IOV isn't defined we get an "unused variable" warining so
now wrap the variable declaration like it's usage already was.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Acked-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index d6f0c0d..72084f7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -291,7 +291,9 @@ static int ixgbe_pci_sriov_disable(struct pci_dev *dev)
 {
 	struct ixgbe_adapter *adapter = pci_get_drvdata(dev);
 	int err;
+#ifdef CONFIG_PCI_IOV
 	u32 current_flags = adapter->flags;
+#endif
 
 	err = ixgbe_disable_sriov(adapter);
 
-- 
1.8.3.1
