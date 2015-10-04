From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/5] i40e: Fix a memory leak in X722 rss config path
Date: Sat,  3 Oct 2015 19:54:41 -0700
Message-ID: <1443927283-18456-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443927283-18456-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai <anjali.singhai@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:56975 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751097AbbJDCyq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Oct 2015 22:54:46 -0400
In-Reply-To: <1443927283-18456-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai <anjali.singhai@intel.com>

In any case free the memory allocated before exiting.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 4345fc5..5646ee8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7625,7 +7625,7 @@ static int i40e_config_rss_aq(struct i40e_vsi *vsi, const u8 *seed)
 			 "Cannot set RSS key, err %s aq_err %s\n",
 			 i40e_stat_str(&pf->hw, ret),
 			 i40e_aq_str(&pf->hw, pf->hw.aq.asq_last_status));
-		return ret;
+		goto config_rss_aq_out;
 	}
 
 	if (vsi->type == I40E_VSI_MAIN)
@@ -7639,6 +7639,8 @@ static int i40e_config_rss_aq(struct i40e_vsi *vsi, const u8 *seed)
 			 i40e_stat_str(&pf->hw, ret),
 			 i40e_aq_str(&pf->hw, pf->hw.aq.asq_last_status));
 
+config_rss_aq_out:
+	kfree(rss_lut);
 	return ret;
 }
 
-- 
2.4.3
