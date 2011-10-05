From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/10] ixgbe: fix driver version initialization in firmware
Date: Wed,  5 Oct 2011 03:20:19 -0700
Message-ID: <1317810024-20846-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317810024-20846-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41269 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932963Ab1JEKUb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Oct 2011 06:20:31 -0400
In-Reply-To: <1317810024-20846-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch fixes an issue with storing the driver version for the
firmware. If the os does not support the particular firmware
management tools, the firmware requires a driver version to be written
as 0xFFFFFFFF rather than the actual driver version.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ed92272..1a3b91f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7587,10 +7587,12 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 			ixgbe_vf_configuration(pdev, (i | 0x10000000));
 	}
 
-	/* Inform firmware of driver version */
+	/* firmware requires driver version to be 0xFFFFFFFF
+	 * since os does not support feature
+	 */
 	if (hw->mac.ops.set_fw_drv_ver)
-		hw->mac.ops.set_fw_drv_ver(hw, MAJ, MIN, BUILD,
-					   FW_CEM_UNUSED_VER);
+		hw->mac.ops.set_fw_drv_ver(hw, 0xFF, 0xFF, 0xFF,
+					   0xFF);
 
 	/* add san mac addr to netdev */
 	ixgbe_add_sanmac_netdev(netdev);
-- 
1.7.6.4
