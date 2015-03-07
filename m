From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40e: Simplify code for rss_size_max config
Date: Sat,  7 Mar 2015 07:03:20 -0800
Message-ID: <1425740603-11280-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425740603-11280-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:31672 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751779AbbCGPDb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Mar 2015 10:03:31 -0500
In-Reply-To: <1425740603-11280-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

We initialize the pf->rss_size_max in sw_init now
and hence this code can be simplified.

Change-ID: I1a7abc837604a40bc65e6c6b21190b909ed6bb21
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 77099ed..f2f3d89 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7398,13 +7398,10 @@ static int i40e_config_rss(struct i40e_pf *pf)
 
 	/* Check capability and Set table size and register per hw expectation*/
 	reg_val = rd32(hw, I40E_PFQF_CTL_0);
-	if (hw->func_caps.rss_table_size == 512) {
+	if (pf->rss_table_size == 512)
 		reg_val |= I40E_PFQF_CTL_0_HASHLUTSIZE_512;
-		pf->rss_table_size = 512;
-	} else {
-		pf->rss_table_size = 128;
+	else
 		reg_val &= ~I40E_PFQF_CTL_0_HASHLUTSIZE_512;
-	}
 	wr32(hw, I40E_PFQF_CTL_0, reg_val);
 
 	/* Populate the LUT with max no. of queues in round robin fashion */
-- 
1.9.3
