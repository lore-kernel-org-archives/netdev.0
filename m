From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e: Fix for unused value issue found by static analysis
Date: Sun, 27 Aug 2017 17:15:57 -0700
Message-ID: <20170828001603.75876-10-jeffrey.t.kirsher@intel.com>
References: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55214 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751613AbdH1AQU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Aug 2017 20:16:20 -0400
In-Reply-To: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes an issue where an error return value is
set, but without an immediate exit, the value can be overwritten
by the following code execution.  The condition  at this point
is not fatal, so remove the error assignment and comment the
intent for future code maintainers

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 5a06cd23b9e6..0962b85ef6f3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9884,13 +9884,15 @@ static int i40e_add_vsi(struct i40e_vsi *vsi)
 			 */
 			ret = i40e_vsi_config_tc(vsi, enabled_tc);
 			if (ret) {
+				/* Single TC condition is not fatal,
+				 * message and continue
+				 */
 				dev_info(&pf->pdev->dev,
 					 "failed to configure TCs for main VSI tc_map 0x%08x, err %s aq_err %s\n",
 					 enabled_tc,
 					 i40e_stat_str(&pf->hw, ret),
 					 i40e_aq_str(&pf->hw,
 						    pf->hw.aq.asq_last_status));
-				ret = -ENOENT;
 			}
 		}
 		break;
-- 
2.14.1
