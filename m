From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/13] e1000e: bad short packets received when jumbos enabled on 82579
Date: Fri,  7 Oct 2011 00:18:38 -0700
Message-ID: <1317971926-23145-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317971926-23145-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34234 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758905Ab1JGHSw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Oct 2011 03:18:52 -0400
In-Reply-To: <1317971926-23145-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When short packets are received with jumbos enabled on 82579, they can be
interpreted to have a receive address that does not match any configured
address.  This is due to a hardware bug that can be worked around by
reducing the number of IPG octets added when the packet is transferred from
the PHY to the MAC.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index ad34de0..4f70974 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1578,7 +1578,7 @@ s32 e1000_lv_jumbo_workaround_ich8lan(struct e1000_hw *hw, bool enable)
 		ret_val = e1e_wphy(hw, PHY_REG(776, 20), data);
 		if (ret_val)
 			goto out;
-		ret_val = e1e_wphy(hw, PHY_REG(776, 23), 0xFE00);
+		ret_val = e1e_wphy(hw, PHY_REG(776, 23), 0xF100);
 		if (ret_val)
 			goto out;
 		e1e_rphy(hw, HV_PM_CTRL, &data);
-- 
1.7.6.4
