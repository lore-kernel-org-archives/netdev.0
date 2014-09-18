From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/11] ixgbe: use e_dev_warn instead of e_err for displaying warning
Date: Thu, 18 Sep 2014 05:26:58 -0700
Message-ID: <1411043221-7163-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1411043221-7163-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43214 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752969AbaIRM1G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 08:27:06 -0400
In-Reply-To: <1411043221-7163-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

In this case, disabling DCB is not an error. We can still function, but
we just have to let the user know. In addition, since we call this
during probe before allocating our netdevice structure, we should use
e_dev_warn instead of e_warn.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 39df14f..969b979 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -1102,9 +1102,9 @@ static void ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	 * capability.
 	 */
 
-	/* disable DCB if number of TCs exceeds 1 */
+	/* Disable DCB unless we only have a single traffic class */
 	if (netdev_get_num_tc(adapter->netdev) > 1) {
-		e_err(probe, "num TCs exceeds number of queues - disabling DCB\n");
+		e_dev_warn("Number of DCB TCs exceeds number of available queues. Disabling DCB support.\n");
 		netdev_reset_tc(adapter->netdev);
 
 		if (adapter->hw.mac.type == ixgbe_mac_82598EB)
-- 
1.9.3
