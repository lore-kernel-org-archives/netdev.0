From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] i40e: For VF reset (VFR and VFLR) add some more delay
Date: Tue, 14 Apr 2015 21:51:44 -0700
Message-ID: <1429073511-27664-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24240 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751280AbbDOEwF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 00:52:05 -0400
In-Reply-To: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

With a HW issue that was recently discovered, after a VFLR HW might be
indicating to us a reset completion little too early. So wait another 10
msec for cache to be cleaned up.

Change-ID: I6a24dcf5dd7ffcd6500246e717411ef58532d1e9
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 98e0921..78d1c4f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -812,6 +812,9 @@ void i40e_reset_vf(struct i40e_vf *vf, bool flr)
 		}
 	}
 
+	if (flr)
+		usleep_range(10000, 20000);
+
 	if (!rsd)
 		dev_err(&pf->pdev->dev, "VF reset check timeout on VF %d\n",
 			vf->vf_id);
-- 
1.9.3
