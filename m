From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/7] ixgbe: Reset max_vfs to zero when user request is out of range
Date: Wed,  2 May 2012 02:13:45 -0700
Message-ID: <1335950025-13294-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1335950025-13294-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:59017 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752426Ab2EBJOE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2012 05:14:04 -0400
In-Reply-To: <1335950025-13294-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

If the user request for the number of VFs in the max_vfs parameter is
out of range then reset the value to the default value of zero.  This
makes the behavior of the ixgbe driver the same as for the igb driver.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Robert Garrett <robertx.e.garrett@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e8897cc..688c7bb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -133,7 +133,7 @@ static struct notifier_block dca_notifier = {
 static unsigned int max_vfs;
 module_param(max_vfs, uint, 0);
 MODULE_PARM_DESC(max_vfs,
-		 "Maximum number of virtual functions to allocate per physical function");
+		 "Maximum number of virtual functions to allocate per physical function - default is zero and maximum value is 63");
 #endif /* CONFIG_PCI_IOV */
 
 static unsigned int allow_unsupported_sfp;
@@ -6778,9 +6778,10 @@ static void __devinit ixgbe_probe_vf(struct ixgbe_adapter *adapter,
 	/* The 82599 supports up to 64 VFs per physical function
 	 * but this implementation limits allocation to 63 so that
 	 * basic networking resources are still available to the
-	 * physical function
+	 * physical function.  If the user requests greater thn
+	 * 63 VFs then it is an error - reset to default of zero.
 	 */
-	adapter->num_vfs = (max_vfs > 63) ? 63 : max_vfs;
+	adapter->num_vfs = (max_vfs > 63) ? 0 : max_vfs;
 	ixgbe_enable_sriov(adapter, ii);
 #endif /* CONFIG_PCI_IOV */
 }
-- 
1.7.7.6
