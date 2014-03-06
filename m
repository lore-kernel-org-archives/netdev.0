From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/13] i40e: Prevent overflow due to kzalloc
Date: Wed,  5 Mar 2014 20:21:35 -0800
Message-ID: <1394079704-1108-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394079704-1108-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55320 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753162AbaCFEVw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 23:21:52 -0500
In-Reply-To: <1394079704-1108-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

To prevent the possibility of overflow due multiplication of number and size
use kcalloc instead of kzalloc.

Change-ID: Ibe4d81ed7d9738d3bbe66ee4844ff9be817e8080
Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 189e250..42cc6ba 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -858,7 +858,7 @@ int i40e_alloc_vfs(struct i40e_pf *pf, u16 num_alloc_vfs)
 		}
 	}
 	/* allocate memory */
-	vfs = kzalloc(num_alloc_vfs * sizeof(struct i40e_vf), GFP_KERNEL);
+	vfs = kcalloc(num_alloc_vfs, sizeof(struct i40e_vf), GFP_KERNEL);
 	if (!vfs) {
 		ret = -ENOMEM;
 		goto err_alloc;
-- 
1.8.3.1
