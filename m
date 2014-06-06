From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/13] i40e: increase reset wait time
Date: Fri,  6 Jun 2014 02:04:16 -0700
Message-ID: <1402045462-10304-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5078 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752386AbaFFJFb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2014 05:05:31 -0400
In-Reply-To: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The wait time was originally too optimistic and the resets were failing
after EMPR.  This increases the loop count to wait considerably longer.
This won't delay the actual wait longer than really needed, just allows
us to poll more times as needed.

Change-ID: If7b96f55cc25b8d06cbbe8665259d250188c53d7
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 36607b0..fd2b573 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -734,7 +734,7 @@ static enum i40e_media_type i40e_get_media_type(struct i40e_hw *hw)
 }
 
 #define I40E_PF_RESET_WAIT_COUNT_A0	200
-#define I40E_PF_RESET_WAIT_COUNT	10
+#define I40E_PF_RESET_WAIT_COUNT	100
 /**
  * i40e_pf_reset - Reset the PF
  * @hw: pointer to the hardware structure
-- 
1.9.3
