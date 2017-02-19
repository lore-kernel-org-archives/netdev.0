From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/13] i40e: remove unnecessary call to i40e_update_link_info
Date: Sat, 18 Feb 2017 22:33:31 -0800
Message-ID: <20170219063341.8039-4-jeffrey.t.kirsher@intel.com>
References: <20170219063341.8039-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:52390 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750925AbdBSGeL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Feb 2017 01:34:11 -0500
In-Reply-To: <20170219063341.8039-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This call is made just prior to running i40e_link_event. In
i40e_link_event, we set hw->phy.get_link_info to true just prior to
calling i40e_get_link_status, which conveniently runs
i40e_update_link_info for us. Thus, we are running i40e_update_link_info
twice, which seems like something we don't need to do...

Change-ID: I36467a570f44b7546d218c99e134ff97c2709315
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e9335af4cc28..a6dca5822cff 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10761,7 +10761,6 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit)
 		i40e_pf_config_rss(pf);
 
 	/* fill in link information and enable LSE reporting */
-	i40e_update_link_info(&pf->hw);
 	i40e_link_event(pf);
 
 	/* Initialize user-specific link properties */
-- 
2.11.0
