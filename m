From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/13] i40e: convert to cpu from le16 to generate switch_id correctly
Date: Sat, 18 Feb 2017 22:33:36 -0800
Message-ID: <20170219063341.8039-9-jeffrey.t.kirsher@intel.com>
References: <20170219063341.8039-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:19155 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751126AbdBSGeN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Feb 2017 01:34:13 -0500
In-Reply-To: <20170219063341.8039-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

On Big Endian platforms we would incorrectly calculate the wrong switch
id since we did not properly convert the le16 value into CPU format.
Caught by sparse.

Change-ID: I69a2f9fa064a0a91691f7d0e6fcc206adceb8e36
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index f1f41f12902f..267ad2588255 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -974,7 +974,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			struct i40e_dcbx_config *r_cfg =
 						&pf->hw.remote_dcbx_config;
 			int i, ret;
-			u32 switch_id;
+			u16 switch_id;
 
 			bw_data = kzalloc(sizeof(
 				    struct i40e_aqc_query_port_ets_config_resp),
@@ -986,7 +986,8 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 
 			vsi = pf->vsi[pf->lan_vsi];
 			switch_id =
-				vsi->info.switch_id & I40E_AQ_VSI_SW_ID_MASK;
+				le16_to_cpu(vsi->info.switch_id) &
+					    I40E_AQ_VSI_SW_ID_MASK;
 
 			ret = i40e_aq_query_port_ets_config(&pf->hw,
 							    switch_id,
-- 
2.11.0
