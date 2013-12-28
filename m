From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v4 12/16] i40e: fix error return
Date: Fri, 27 Dec 2013 19:22:16 -0800
Message-ID: <1388200940-9113-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388200940-9113-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:32854 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755047Ab3L1DWn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Dec 2013 22:22:43 -0500
In-Reply-To: <1388200940-9113-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If the VF asks to add an invalid MAC address, tell it that instead of
just using a generic return code.

Change-Id: I366aff5449fa5874ad51e2734cac2a71783ab14b
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 1a7052a..4386a2f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1340,7 +1340,7 @@ static int i40e_vc_add_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 		    is_zero_ether_addr(al->list[i].addr)) {
 			dev_err(&pf->pdev->dev, "invalid VF MAC addr %pMAC\n",
 				al->list[i].addr);
-			aq_ret = I40E_ERR_PARAM;
+			aq_ret = I40E_ERR_INVALID_MAC_ADDR;
 			goto error_param;
 		}
 	}
-- 
1.8.3.1
