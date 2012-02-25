From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/11] e1000e: cleanup calls to setup_physical_interface function pointer
Date: Fri, 24 Feb 2012 21:49:54 -0800
Message-ID: <1330149000-25907-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330149000-25907-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2449 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752926Ab2BYFuE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Feb 2012 00:50:04 -0500
In-Reply-To: <1330149000-25907-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Call the MAC ops setup_physical_interface function pointer instead of the
MAC-family-specific function to conform to the rest of the driver design.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index da89e2b..fdc3be9 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -3353,7 +3353,7 @@ static s32 e1000_setup_link_ich8lan(struct e1000_hw *hw)
 		hw->fc.current_mode);
 
 	/* Continue to configure the copper link. */
-	ret_val = e1000_setup_copper_link_ich8lan(hw);
+	ret_val = hw->mac.ops.setup_physical_interface(hw);
 	if (ret_val)
 		return ret_val;
 
-- 
1.7.7.6
