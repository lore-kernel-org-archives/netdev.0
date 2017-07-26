From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] i40e: fix odd formatting and indent
Date: Wed, 26 Jul 2017 03:31:15 -0700
Message-ID: <20170726103123.76743-7-jeffrey.t.kirsher@intel.com>
References: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5454 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751591AbdGZKdz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 06:33:55 -0400
In-Reply-To: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The compiler warned on an oddly indented bit of code, and when
investigating that, noted that the functions themselves had
an odd flow. The if condition was checked, and would exclude
a call to AQ, but then the aq_ret would be checked unconditionally
which just looks really weird, and is likely to cause objections.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index ba327e90f32a..2e261bb59d10 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1741,16 +1741,14 @@ static int i40e_vc_config_promiscuous_mode_msg(struct i40e_vf *vf,
 							    NULL);
 	} else if (i40e_getnum_vf_vsi_vlan_filters(vsi)) {
 		hash_for_each(vsi->mac_filter_hash, bkt, f, hlist) {
-			aq_ret = 0;
-			if (f->vlan >= 0 && f->vlan <= I40E_MAX_VLANID) {
-				aq_ret =
-				i40e_aq_set_vsi_uc_promisc_on_vlan(hw,
-								   vsi->seid,
-								   alluni,
-								   f->vlan,
-								   NULL);
-				aq_err = pf->hw.aq.asq_last_status;
-			}
+			if (f->vlan < 0 || f->vlan > I40E_MAX_VLANID)
+				continue;
+			aq_ret = i40e_aq_set_vsi_uc_promisc_on_vlan(hw,
+								    vsi->seid,
+								    alluni,
+								    f->vlan,
+								    NULL);
+			aq_err = pf->hw.aq.asq_last_status;
 			if (aq_ret)
 				dev_err(&pf->pdev->dev,
 					"Could not add VLAN %d to Unicast promiscuous domain err %s aq_err %s\n",
-- 
2.13.3
