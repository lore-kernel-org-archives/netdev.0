From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/11] ixgbe: add warnings for other disabled features without MSI-X support
Date: Thu, 18 Sep 2014 05:27:00 -0700
Message-ID: <1411043221-7163-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1411043221-7163-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56568 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753540AbaIRM1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 08:27:07 -0400
In-Reply-To: <1411043221-7163-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When we can't get MSI-X vectors, we disable a few features which require
MSI-X vectors. Print warnings just like we do when disabling DCB.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 0ec22d8..ce40c77 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -1114,13 +1114,16 @@ static void ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 		adapter->temp_dcb_cfg.pfc_mode_enable = false;
 		adapter->dcb_cfg.pfc_mode_enable = false;
 	}
+
 	adapter->dcb_cfg.num_tcs.pg_tcs = 1;
 	adapter->dcb_cfg.num_tcs.pfc_tcs = 1;
 
-	/* disable SR-IOV */
+	/* Disable SR-IOV support */
+	e_dev_warn("Disabling SR-IOV support\n");
 	ixgbe_disable_sriov(adapter);
 
-	/* disable RSS */
+	/* Disable RSS */
+	e_dev_warn("Disabling RSS support\n");
 	adapter->ring_feature[RING_F_RSS].limit = 1;
 
 	/* recalculate number of queues now that many features have been
-- 
1.9.3
