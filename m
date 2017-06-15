From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] intel: i40e: virtchnl: fix incorrect variable assignment
Date: Wed, 14 Jun 2017 21:38:26 -0500
Message-ID: <20170615023826.GA8136@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix incorrect variable assignment.
Based on line 1511: aq_ret = I40_ERR_PARAM; the correct variable to be
used in this instance is aq_ret instead of ret. Also, variable ret is
updated at line 1602 just before return, so assigning a value to this
variable in this code block is useless.

Addresses-Coverity-ID: 1397693
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 6bee254..fb1f018 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1567,7 +1567,7 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 			dev_err(&pf->pdev->dev,
 				"VF %d requested polling mode: this feature is supported only when the device is running in single function per port (SFP) mode\n",
 				 vf->vf_id);
-			ret = I40E_ERR_PARAM;
+			aq_ret = I40E_ERR_PARAM;
 			goto err;
 		}
 		vfres->vf_offload_flags |= VIRTCHNL_VF_OFFLOAD_RX_POLLING;
-- 
2.5.0
