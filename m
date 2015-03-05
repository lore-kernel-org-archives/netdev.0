From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/14] i40e: don't spam the system log
Date: Thu,  5 Mar 2015 08:46:31 -0800
Message-ID: <1425573992-30955-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:43748 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945965AbbCEQqm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 11:46:42 -0500
In-Reply-To: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch A Williams <mitch.a.williams@intel.com>

The PF driver spams the system log with messages about VF VSI when VFs
are created, as well as each time they are reset. This is annoying, and
the information isn't even useful most of the time.

Remove this message to reduce user annoyance.

Change-ID: I8de90d05380f54b038c9c8c3265150be87c9242c
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 910c45e..1d8b94d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -403,9 +403,6 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 		u8 brdcast[ETH_ALEN] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 		vf->lan_vsi_index = vsi->idx;
 		vf->lan_vsi_id = vsi->id;
-		dev_info(&pf->pdev->dev,
-			 "VF %d assigned LAN VSI index %d, VSI id %d\n",
-			 vf->vf_id, vsi->idx, vsi->id);
 		/* If the port VLAN has been configured and then the
 		 * VF driver was removed then the VSI port VLAN
 		 * configuration was destroyed.  Check if there is
-- 
1.9.3
