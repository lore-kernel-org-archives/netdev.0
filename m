From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e: Redistribute queue vectors after DCB reconfiguration
Date: Mon, 28 Apr 2014 06:52:29 -0700
Message-ID: <1398693158-2815-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <Neerav.Parikh@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:7567 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752338AbaD1Nwp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 09:52:45 -0400
In-Reply-To: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <Neerav.Parikh@intel.com>

The queue vectors are originally distributed among the total
number of queues that are configured for a given VSI. The number
of queues that are configured for a VSI depends on the number of
TCs that are enabled for the VSI at VSI setup/creation time.

But, the total number of queues that are configured for a VSI may
change based on change in the total number of TCs enabled as a
result of change in DCB configuration based on DCBX.

Hence, it is required for the queue vectors to be redistributed
when the total queues that are configured for a given VSI changes.

Without redistributing the vectors the queues that are configured
for the newly enabled TCs may not be able to do any Tx/Rx.

Change-ID: I4e780903db019e6199c7ce43627cef22c916acfe
Signed-off-by: Neerav Parikh <Neerav.Parikh@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 6f00de4..78308e0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4027,6 +4027,8 @@ static void i40e_dcb_reconfigure(struct i40e_pf *pf)
 				 pf->vsi[v]->seid);
 			/* Will try to configure as many components */
 		} else {
+			/* Re-configure VSI vectors based on updated TC map */
+			i40e_vsi_map_rings_to_vectors(pf->vsi[v]);
 			if (pf->vsi[v]->netdev)
 				i40e_dcbnl_set_all(pf->vsi[v]);
 		}
-- 
1.9.0
