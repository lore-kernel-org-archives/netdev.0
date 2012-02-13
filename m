From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] e1000e: cleanup: remove unnecessary variable ret_val
Date: Mon, 13 Feb 2012 13:47:44 -0800
Message-ID: <1329169670-5403-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1329169670-5403-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:40106 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755678Ab2BMVr6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 16:47:58 -0500
In-Reply-To: <1329169670-5403-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

ret_val gets initialized to -E1000_ERR_NVM and never set differently, so
get rid of it and just return -E1000_ERR_NVM.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index f5d7282..c80ef41 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -2308,7 +2308,6 @@ static s32 e1000_flash_cycle_ich8lan(struct e1000_hw *hw, u32 timeout)
 {
 	union ich8_hws_flash_ctrl hsflctl;
 	union ich8_hws_flash_status hsfsts;
-	s32 ret_val = -E1000_ERR_NVM;
 	u32 i = 0;
 
 	/* Start a cycle by writing 1 in Flash Cycle Go in Hw Flash Control */
@@ -2327,7 +2326,7 @@ static s32 e1000_flash_cycle_ich8lan(struct e1000_hw *hw, u32 timeout)
 	if (hsfsts.hsf_status.flcdone == 1 && hsfsts.hsf_status.flcerr == 0)
 		return 0;
 
-	return ret_val;
+	return -E1000_ERR_NVM;
 }
 
 /**
-- 
1.7.7.6
