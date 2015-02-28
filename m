From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/18] i40e: Register DCBNL ops in MFP mode
Date: Sat, 28 Feb 2015 03:29:47 -0800
Message-ID: <1425122989-354-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49619 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751464AbbB1LaB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Feb 2015 06:30:01 -0500
In-Reply-To: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

Allow DCBNL operations in MFP mode to allow query of port DCB settings
via all the PFs and register iSCSI APP on iSCSI enabled PF.

Change-ID: I34cc39b4665d0a631847d4079350d3814f02381e
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c b/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c
index f4070b5..b066550 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c
@@ -305,9 +305,7 @@ void i40e_dcbnl_setup(struct i40e_vsi *vsi)
 	if (!(pf->flags & I40E_FLAG_DCB_CAPABLE))
 		return;
 
-	/* Do not setup DCB NL ops for MFP mode */
-	if (!(pf->flags & I40E_FLAG_MFP_ENABLED))
-		dev->dcbnl_ops = &dcbnl_ops;
+	dev->dcbnl_ops = &dcbnl_ops;
 
 	/* Set initial IEEE DCB settings */
 	i40e_dcbnl_set_all(vsi);
-- 
1.9.3
