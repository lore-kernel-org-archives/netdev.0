From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/14] ixgbe: Limit number of reported VFs to device specific value
Date: Wed, 23 Jan 2013 14:44:49 -0800
Message-ID: <1358981090-5794-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358981090-5794-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Donald Dutile <ddutile@redhat.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:61771 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752421Ab3AWWpX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 17:45:23 -0500
In-Reply-To: <1358981090-5794-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Donald Dutile <ddutile@redhat.com>

ixgbe claims it supports 64 VFs in its SRIOV capability
structure, but the driver only supports 63.  Adjust it
so sysfs sriov configuration checking will check with
the proper totalvf value.

Signed-off-by: Donald Dutile <ddutile@redhat.com>
Acked-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 5e3ed33..5989b3f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7389,6 +7389,7 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	ixgbe_init_mbx_params_pf(hw);
 	memcpy(&hw->mbx.ops, ii->mbx_ops, sizeof(hw->mbx.ops));
 	ixgbe_enable_sriov(adapter);
+	pci_sriov_set_totalvfs(pdev, 63);
 skip_sriov:
 
 #endif
-- 
1.7.11.7
