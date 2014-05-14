From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/11] ixgbe: don't check NULL for debugfs_remove_recursive
Date: Wed, 14 May 2014 01:54:19 -0700
Message-ID: <1400057663-4578-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400057663-4578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:40067 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753911AbaENIyi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 04:54:38 -0400
In-Reply-To: <1400057663-4578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The debugfs_remove_recursive function is NULL-safe, so we don't need to
check here ourselves.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
index 472b0f4..5e2c1e3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
@@ -253,8 +253,7 @@ void ixgbe_dbg_adapter_init(struct ixgbe_adapter *adapter)
  **/
 void ixgbe_dbg_adapter_exit(struct ixgbe_adapter *adapter)
 {
-	if (adapter->ixgbe_dbg_adapter)
-		debugfs_remove_recursive(adapter->ixgbe_dbg_adapter);
+	debugfs_remove_recursive(adapter->ixgbe_dbg_adapter);
 	adapter->ixgbe_dbg_adapter = NULL;
 }
 
-- 
1.9.0
