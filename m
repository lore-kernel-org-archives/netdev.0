From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] ixgbe: add comment noting recalculation of queues
Date: Fri, 29 Aug 2014 02:30:19 -0700
Message-ID: <1409304620-23251-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53254 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752877AbaH2Jaa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 05:30:30 -0400
In-Reply-To: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Since we previously called ixgbe_set_num_queues just prior to attempting
to set our interrupt scheme, it may be non obvious why we have to call
it again inside the function. Add a comment which helps make it more
obvious that we are resetting features based on the fact that we do not
have MSI-X enabled, and cannot use the previous settings.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 2d9451e..ae36fd6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -1086,6 +1086,11 @@ static void ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 			return;
 	}
 
+	/* At this point, we do not have MSI-X capabilities. We need to
+	 * reconfigure or disable various features which require MSI-X
+	 * capability.
+	 */
+
 	/* disable DCB if number of TCs exceeds 1 */
 	if (netdev_get_num_tc(adapter->netdev) > 1) {
 		e_err(probe, "num TCs exceeds number of queues - disabling DCB\n");
@@ -1107,6 +1112,9 @@ static void ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	/* disable RSS */
 	adapter->ring_feature[RING_F_RSS].limit = 1;
 
+	/* recalculate number of queues now that many features have been
+	 * changed or disabled.
+	 */
 	ixgbe_set_num_queues(adapter);
 	adapter->num_q_vectors = 1;
 
-- 
1.9.3
