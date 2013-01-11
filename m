From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] e1000e: add missing bailout on error
Date: Fri, 11 Jan 2013 02:23:44 -0800
Message-ID: <1357899831-4168-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1357899831-4168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8893 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753907Ab3AKKYB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 05:24:01 -0500
In-Reply-To: <1357899831-4168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

...discovered during code inspection.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 15d9314..051dfda 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -2077,6 +2077,8 @@ static s32 e1000_lv_phy_workarounds_ich8lan(struct e1000_hw *hw)
 
 	/* Set MDIO slow mode before any other MDIO access */
 	ret_val = e1000_set_mdio_slow_mode_hv(hw);
+	if (ret_val)
+		return ret_val;
 
 	ret_val = hw->phy.ops.acquire(hw);
 	if (ret_val)
-- 
1.7.11.7
