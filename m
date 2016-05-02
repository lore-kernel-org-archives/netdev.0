From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] i40e: Prevent falling to promiscuous if the VF is not trusted
Date: Sun,  1 May 2016 17:06:09 -0700
Message-ID: <1462147581-135254-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462147581-135254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:63264 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751713AbcEBAGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 May 2016 20:06:24 -0400
In-Reply-To: <1462147581-135254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

With this change a non trusted VF can never fall to promiscuous
mode when there is no room for a MAC/VLAN filter.

Change-Id: I8a155aa25c0bcdc6093414920c9ade4ee0bd20e8
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 39b3b56..a45748e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2098,6 +2098,12 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 		}
 	}
 
+	/* if the VF is not trusted do not do promisc */
+	if ((vsi->type == I40E_VSI_SRIOV) && !pf->vf[vsi->vf_id].trusted) {
+		clear_bit(__I40E_FILTER_OVERFLOW_PROMISC, &vsi->state);
+		goto out;
+	}
+
 	/* check for changes in promiscuous modes */
 	if (changed_flags & IFF_ALLMULTI) {
 		bool cur_multipromisc;
-- 
2.5.5
