From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/3] ixgbevf: Set the netdev number of Tx queues
Date: Tue,  9 Oct 2012 03:13:30 -0700
Message-ID: <1349777612-30149-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1349777612-30149-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57651 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755251Ab2JIKNo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 06:13:44 -0400
In-Reply-To: <1349777612-30149-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The driver was not setting the number of real Tx queues in the net_device
structure.  This caused some serious issues such as Tx hangs and extremely
poor performance with some usages of the driver.

The issue is best observed by running:

iperf -c <host> -P <n>

Where n is greater than one.  The greater the value of n the more likely
the problem is to show up.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 0ee9bd4..de1ad50 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1747,6 +1747,7 @@ err_tx_ring_allocation:
  **/
 static int ixgbevf_set_interrupt_capability(struct ixgbevf_adapter *adapter)
 {
+	struct net_device *netdev = adapter->netdev;
 	int err = 0;
 	int vector, v_budget;
 
@@ -1775,6 +1776,12 @@ static int ixgbevf_set_interrupt_capability(struct ixgbevf_adapter *adapter)
 
 	ixgbevf_acquire_msix_vectors(adapter, v_budget);
 
+	err = netif_set_real_num_tx_queues(netdev, adapter->num_tx_queues);
+	if (err)
+		goto out;
+
+	err = netif_set_real_num_rx_queues(netdev, adapter->num_rx_queues);
+
 out:
 	return err;
 }
-- 
1.7.11.4
