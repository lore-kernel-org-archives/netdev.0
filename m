From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/9] igb: Workaround for global device reset problem on 82580.
Date: Sat,  1 Dec 2012 03:53:33 -0800
Message-ID: <1354362817-26168-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1354362817-26168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:27557 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751646Ab2LALx5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2012 06:53:57 -0500
In-Reply-To: <1354362817-26168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

Due to a hw errata, the global device reset doesn't always work on 82580
devices.  This patch works around the problem not trying to do a global
device reset on these devices.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 8c12dbd..db40b68 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -1927,6 +1927,12 @@ static s32 igb_reset_hw_82580(struct e1000_hw *hw)
 
 	hw->dev_spec._82575.global_device_reset = false;
 
+	/* due to hw errata, global device reset doesn't always
+	 * work on 82580
+	 */
+	if (hw->mac.type == e1000_82580)
+		global_device_reset = false;
+
 	/* Get current control state. */
 	ctrl = rd32(E1000_CTRL);
 
-- 
1.7.11.7
