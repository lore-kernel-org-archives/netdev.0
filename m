From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e: Fix static analysis tool warning
Date: Thu, 18 Aug 2016 14:57:27 -0700
Message-ID: <1471557456-136741-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Dave Ertman <david.m.ertman@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55969 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752784AbcHSAsd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 20:48:33 -0400
In-Reply-To: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Ertman <david.m.ertman@intel.com>

This patch fixes a problem where a static analysis tool generates
a warning for "INVARIANT_CONDITION: Expression 'enabled_tc' used
in the condition always yields the same result."

Without this patch, the driver will not pass the static analysis
tool checks without generating warnings.

This patch fixes the problem by eliminating the irrelevant check
and redundant assignment for the value of enabled_tc.

Change-ID: Ia7d44cb050f507df7de333e96369d322e08bf408
Signed-off-by: Dave Ertman <david.m.ertman@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 9f9d24f..8c68ac1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4617,7 +4617,7 @@ static u8 i40e_dcb_get_enabled_tc(struct i40e_dcbx_config *dcbcfg)
 static u8 i40e_pf_get_num_tc(struct i40e_pf *pf)
 {
 	struct i40e_hw *hw = &pf->hw;
-	u8 i, enabled_tc;
+	u8 i, enabled_tc = 1;
 	u8 num_tc = 0;
 	struct i40e_dcbx_config *dcbcfg = &hw->local_dcbx_config;
 
@@ -4635,8 +4635,6 @@ static u8 i40e_pf_get_num_tc(struct i40e_pf *pf)
 	else
 		return 1; /* Only TC0 */
 
-	/* At least have TC0 */
-	enabled_tc = (enabled_tc ? enabled_tc : 0x1);
 	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
 		if (enabled_tc & BIT(i))
 			num_tc++;
-- 
2.7.4
