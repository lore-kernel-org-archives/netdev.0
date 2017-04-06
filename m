From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/7] fm10k: correctly check if interface is removed
Date: Thu,  6 Apr 2017 00:54:50 -0700
Message-ID: <20170406075456.27757-2-jeffrey.t.kirsher@intel.com>
References: <20170406075456.27757-1-jeffrey.t.kirsher@intel.com>
Cc: Phil Turnbull <phil.turnbull@oracle.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27550 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756682AbdDFHzF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 03:55:05 -0400
In-Reply-To: <20170406075456.27757-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Turnbull <phil.turnbull@oracle.com>

FM10K_REMOVED expects a hardware address, not a 'struct fm10k_hw'.

Fixes: 5cb8db4a4cbc ("fm10k: Add support for VF")
Signed-off-by: Phil Turnbull <phil.turnbull@oracle.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 0c84fef750f4..078e8d93db5a 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -939,7 +939,7 @@ static void fm10k_self_test(struct net_device *dev,
 
 	memset(data, 0, sizeof(*data) * FM10K_TEST_LEN);
 
-	if (FM10K_REMOVED(hw)) {
+	if (FM10K_REMOVED(hw->hw_addr)) {
 		netif_err(interface, drv, dev,
 			  "Interface removed - test blocked\n");
 		eth_test->flags |= ETH_TEST_FL_FAILED;
-- 
2.12.2
