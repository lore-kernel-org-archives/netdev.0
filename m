From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/11] ixgbe: Fix device ref count bug
Date: Thu, 31 Jan 2013 23:53:22 -0800
Message-ID: <1359705211-11342-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359705211-11342-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12706 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751098Ab3BAHxz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 02:53:55 -0500
In-Reply-To: <1359705211-11342-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The device lookup neglected to do a pci_dev_put() to decrement the
device reference count.

Reported-by: Elena Gurevich <elena.gurevich@toganetworks.com>
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 5989b3f..1f53675 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7758,6 +7758,8 @@ static pci_ers_result_t ixgbe_io_error_detected(struct pci_dev *pdev,
 		if (vfdev) {
 			e_dev_err("Issuing VFLR to VF %d\n", vf);
 			pci_write_config_dword(vfdev, 0xA8, 0x00008000);
+			/* Free device reference count */
+			pci_dev_put(vfdev);
 		}
 
 		pci_cleanup_aer_uncorrect_error_status(pdev);
-- 
1.7.11.7
