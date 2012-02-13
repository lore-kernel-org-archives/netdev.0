From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] e1000e: potentially incorrect return for e1000_set_d3_lplu_state_ich8lan
Date: Mon, 13 Feb 2012 13:47:42 -0800
Message-ID: <1329169670-5403-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1329169670-5403-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:40106 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755644Ab2BMVr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 16:47:57 -0500
In-Reply-To: <1329169670-5403-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

In the unlikely event that e1e_wphy() returns an error, the returned error
code is not propogated to the caller of e1000_set_d3_lplu_state_ich8lan().
With this change, there is a rare possibility that ret_val might not get
set so it must be initialized.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index ce348cd..5a55a61 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -2030,7 +2030,7 @@ static s32 e1000_set_d3_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	u32 phy_ctrl;
-	s32 ret_val;
+	s32 ret_val = 0;
 	u16 data;
 
 	phy_ctrl = er32(PHY_CTRL);
@@ -2096,7 +2096,7 @@ static s32 e1000_set_d3_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 		ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG, data);
 	}
 
-	return 0;
+	return ret_val;
 }
 
 /**
-- 
1.7.7.6
