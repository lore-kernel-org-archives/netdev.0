From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40e: Use correct flag to enable egress traffic for unicast promisc
Date: Sun, 27 Aug 2017 17:15:52 -0700
Message-ID: <20170828001603.75876-5-jeffrey.t.kirsher@intel.com>
References: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55214 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751662AbdH1AQS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Aug 2017 20:16:18 -0400
In-Reply-To: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

Albeit, we usually set true promiscuous mode for both multicast and
unicast at the same time - however, it is possible to set it
individually, so using allmulti flag which is only for allmulticast might
caused unwanted behavior in mirroring egress traffic promiscuous for
unicast in VF.

Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 057c77be96e4..27d87bef4ba3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1758,7 +1758,7 @@ static int i40e_vc_config_promiscuous_mode_msg(struct i40e_vf *vf,
 		}
 	} else {
 		aq_ret = i40e_aq_set_vsi_unicast_promiscuous(hw, vsi->seid,
-							     allmulti, NULL,
+							     alluni, NULL,
 							     true);
 		aq_err = pf->hw.aq.asq_last_status;
 		if (aq_ret) {
-- 
2.14.1
