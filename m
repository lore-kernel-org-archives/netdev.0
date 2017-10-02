From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/13] fm10k: move fm10k_prepare_for_reset and fm10k_handle_reset
Date: Mon,  2 Oct 2017 08:42:35 -0700
Message-ID: <20171002154236.84043-13-jeffrey.t.kirsher@intel.com>
References: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58698 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751811AbdJBPnA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 11:43:00 -0400
In-Reply-To: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

A future patch needs these functions defined earlier in the file. Move
them closer to above where they will be called.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 58 ++++++++++++++--------------
 1 file changed, 29 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 6c2c4bffaedf..41335154d6b1 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -132,35 +132,6 @@ static void fm10k_service_timer(unsigned long data)
 	fm10k_service_event_schedule(interface);
 }
 
-static void fm10k_detach_subtask(struct fm10k_intfc *interface)
-{
-	struct net_device *netdev = interface->netdev;
-	u32 __iomem *hw_addr;
-	u32 value;
-
-	/* do nothing if device is still present or hw_addr is set */
-	if (netif_device_present(netdev) || interface->hw.hw_addr)
-		return;
-
-	/* check the real address space to see if we've recovered */
-	hw_addr = READ_ONCE(interface->uc_addr);
-	value = readl(hw_addr);
-	if (~value) {
-		interface->hw.hw_addr = interface->uc_addr;
-		netif_device_attach(netdev);
-		set_bit(FM10K_FLAG_RESET_REQUESTED, interface->flags);
-		netdev_warn(netdev, "PCIe link restored, device now attached\n");
-		return;
-	}
-
-	rtnl_lock();
-
-	if (netif_running(netdev))
-		dev_close(netdev);
-
-	rtnl_unlock();
-}
-
 static void fm10k_prepare_for_reset(struct fm10k_intfc *interface)
 {
 	struct net_device *netdev = interface->netdev;
@@ -270,6 +241,35 @@ static int fm10k_handle_reset(struct fm10k_intfc *interface)
 	return err;
 }
 
+static void fm10k_detach_subtask(struct fm10k_intfc *interface)
+{
+	struct net_device *netdev = interface->netdev;
+	u32 __iomem *hw_addr;
+	u32 value;
+
+	/* do nothing if device is still present or hw_addr is set */
+	if (netif_device_present(netdev) || interface->hw.hw_addr)
+		return;
+
+	/* check the real address space to see if we've recovered */
+	hw_addr = READ_ONCE(interface->uc_addr);
+	value = readl(hw_addr);
+	if (~value) {
+		interface->hw.hw_addr = interface->uc_addr;
+		netif_device_attach(netdev);
+		set_bit(FM10K_FLAG_RESET_REQUESTED, interface->flags);
+		netdev_warn(netdev, "PCIe link restored, device now attached\n");
+		return;
+	}
+
+	rtnl_lock();
+
+	if (netif_running(netdev))
+		dev_close(netdev);
+
+	rtnl_unlock();
+}
+
 static void fm10k_reinit(struct fm10k_intfc *interface)
 {
 	int err;
-- 
2.14.2
