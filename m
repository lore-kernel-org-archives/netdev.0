From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 05/15] i40e: remove BUG_ON from FCoE setup
Date: Wed, 25 Nov 2015 10:21:09 -0800
Message-ID: <1448475679-57194-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448475679-57194-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23563 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751872AbbKYSVX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2015 13:21:23 -0500
In-Reply-To: <1448475679-57194-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

There's no need to kill the kernel thread here. If this condition was
true, the probe() would have died long before we got here. In any case,
we'll get the same result when this code tries to use the VSI pointer
being checked.

Prompted by a recent Linus diatribe.

Change-ID: I62f531cac34d4fc28ff9657d5b2d9523ae5e33a4
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
index fe5d9bf..579a46c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
@@ -1544,8 +1544,6 @@ void i40e_fcoe_vsi_setup(struct i40e_pf *pf)
 	if (!(pf->flags & I40E_FLAG_FCOE_ENABLED))
 		return;
 
-	BUG_ON(!pf->vsi[pf->lan_vsi]);
-
 	for (i = 0; i < pf->num_alloc_vsi; i++) {
 		vsi = pf->vsi[i];
 		if (vsi && vsi->type == I40E_VSI_FCOE) {
-- 
2.5.0
