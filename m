From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 08/10] e1000e: i219 - k1 workaround for LPT is not required for SPT
Date: Fri, 26 Jun 2015 03:20:38 -0700
Message-ID: <1435314040-3228-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1435314040-3228-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yanir Lubetkin <yanirx.lubetkin@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40750 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752004AbbFZKUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2015 06:20:55 -0400
In-Reply-To: <1435314040-3228-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yanir Lubetkin <yanirx.lubetkin@intel.com>

In SPT hardware does not require this driver workaround.
Removed the conditional that caused K1 workaround execution on SPT.

Signed-off-by: Yanir Lubetkin <yanirx.lubetkin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 3f5b8cb..91a5a0a 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1489,8 +1489,7 @@ static s32 e1000_check_for_copper_link_ich8lan(struct e1000_hw *hw)
 	if ((hw->adapter->pdev->device == E1000_DEV_ID_PCH_LPTLP_I218_LM) ||
 	    (hw->adapter->pdev->device == E1000_DEV_ID_PCH_LPTLP_I218_V) ||
 	    (hw->adapter->pdev->device == E1000_DEV_ID_PCH_I218_LM3) ||
-	    (hw->adapter->pdev->device == E1000_DEV_ID_PCH_I218_V3) ||
-	    (hw->mac.type == e1000_pch_spt)) {
+	    (hw->adapter->pdev->device == E1000_DEV_ID_PCH_I218_V3)) {
 		ret_val = e1000_k1_workaround_lpt_lp(hw, link);
 		if (ret_val)
 			return ret_val;
-- 
2.4.3
