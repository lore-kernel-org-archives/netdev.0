From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/6] ixgbe: Do not read the spoofed packets counter when not in IOV mode
Date: Mon, 24 Sep 2012 02:00:03 -0700
Message-ID: <1348477207-27030-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1348477207-27030-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:13634 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751762Ab2IXJAM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 05:00:12 -0400
In-Reply-To: <1348477207-27030-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The counter is not valid unless the controller is running in IOV mode.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 70d27a3..29465be 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5560,8 +5560,9 @@ static void ixgbe_spoof_check(struct ixgbe_adapter *adapter)
 {
 	u32 ssvpc;
 
-	/* Do not perform spoof check for 82598 */
-	if (adapter->hw.mac.type == ixgbe_mac_82598EB)
+	/* Do not perform spoof check for 82598 or if not in IOV mode */
+	if (adapter->hw.mac.type == ixgbe_mac_82598EB ||
+	    adapter->num_vfs == 0)
 		return;
 
 	ssvpc = IXGBE_READ_REG(&adapter->hw, IXGBE_SSVPC);
-- 
1.7.11.4
