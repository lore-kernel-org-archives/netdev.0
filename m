From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/11] e1000e: conditionally restart autoneg on 82577/8/9 when setting LPLU state
Date: Thu, 26 Jan 2012 19:08:43 -0800
Message-ID: <1327633729-14086-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1327633729-14086-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35567 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754738Ab2A0DIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 22:08:55 -0500
In-Reply-To: <1327633729-14086-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When setting the Low Power Link Up (LPLU, a.k.a. reverse auto-negotiation)
on 82577/8278/82579, do not restart auto-negotiation if reset of the Phy is
blocked by the Manageability Engine.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index d99548c..6a6e6f6 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1921,7 +1921,9 @@ static s32 e1000_set_lplu_state_pchlan(struct e1000_hw *hw, bool active)
 	else
 		oem_reg &= ~HV_OEM_BITS_LPLU;
 
-	oem_reg |= HV_OEM_BITS_RESTART_AN;
+	if (!e1000_check_reset_block(hw))
+		oem_reg |= HV_OEM_BITS_RESTART_AN;
+
 	ret_val = e1e_wphy(hw, HV_OEM_BITS, oem_reg);
 
 out:
-- 
1.7.7.6
