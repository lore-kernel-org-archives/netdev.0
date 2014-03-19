From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 08/15] i40e: potential array underflow in i40e_vc_process_vf_msg()
Date: Tue, 18 Mar 2014 20:42:06 -0700
Message-ID: <1395200533-16908-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395200533-16908-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58703 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933747AbaCSDmT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 23:42:19 -0400
In-Reply-To: <1395200533-16908-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>

If "vf_id" is smaller than hw->func_caps.vf_base_id then it leads to
an array underflow of the pf->vf[] array.  This is unlikely to happen
unless the hardware is bad, but it's a small change and it silences a
static checker warning.

Fixes: 7efa84b7abc1 ('i40e: support VFs on PFs other than 0')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 46fc2c6..f0dc71b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1774,7 +1774,7 @@ int i40e_vc_process_vf_msg(struct i40e_pf *pf, u16 vf_id, u32 v_opcode,
 			   u32 v_retval, u8 *msg, u16 msglen)
 {
 	struct i40e_hw *hw = &pf->hw;
-	int local_vf_id = vf_id - hw->func_caps.vf_base_id;
+	unsigned int local_vf_id = vf_id - hw->func_caps.vf_base_id;
 	struct i40e_vf *vf;
 	int ret;
 
-- 
1.8.3.1
