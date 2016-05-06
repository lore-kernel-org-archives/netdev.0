From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/11] i40e: fix misleading indentation
Date: Fri,  6 May 2016 00:03:47 -0700
Message-ID: <1462518228-30527-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462518228-30527-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:40771 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757957AbcEFHGg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2016 03:06:36 -0400
In-Reply-To: <1462518228-30527-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>

Newly added code in i40e_vc_config_promiscuous_mode_msg() is indented
in a way that gcc rightly complains about:

drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c: In function 'i40e_vc_config_promiscuous_mode_msg':
drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c:1543:4: error: this 'if' clause does not guard... [-Werror=misleading-indentation]
    if (f->vlan >= 0 && f->vlan <= I40E_MAX_VLANID)
    ^~
drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c:1550:5: note: ...this statement, but the latter is misleadingly indented as if it is guarded by the 'if'
     aq_err = pf->hw.aq.asq_last_status;

>From the context, it looks like the aq_err assignment was meant to be
inside of the conditional expression, so I'm adding the appropriate
curly braces now.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 5676a8b9cd9a ("i40e: Add VF promiscuous mode driver support")
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 36aa33a..a9b04e7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1544,7 +1544,7 @@ static int i40e_vc_config_promiscuous_mode_msg(struct i40e_vf *vf,
 	} else if (i40e_getnum_vf_vsi_vlan_filters(vsi)) {
 		list_for_each_entry(f, &vsi->mac_filter_list, list) {
 			aq_ret = 0;
-			if (f->vlan >= 0 && f->vlan <= I40E_MAX_VLANID)
+			if (f->vlan >= 0 && f->vlan <= I40E_MAX_VLANID) {
 				aq_ret =
 				i40e_aq_set_vsi_uc_promisc_on_vlan(hw,
 								   vsi->seid,
@@ -1552,6 +1552,7 @@ static int i40e_vc_config_promiscuous_mode_msg(struct i40e_vf *vf,
 								   f->vlan,
 								   NULL);
 				aq_err = pf->hw.aq.asq_last_status;
+			}
 			if (aq_ret)
 				dev_err(&pf->pdev->dev,
 					"Could not add VLAN %d to Unicast promiscuous domain err %s aq_err %s\n",
-- 
2.5.5
