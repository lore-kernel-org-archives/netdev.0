From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/16] i40e: delete netdev after deleting napi and vectors
Date: Fri, 14 Mar 2014 02:47:14 -0700
Message-ID: <1394790446-31591-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394790446-31591-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26976 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755916AbaCNJra (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 05:47:30 -0400
In-Reply-To: <1394790446-31591-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

We've been deleting the netdev before getting around to deleting the napi
structs.  Unfortunately, we then didn't delete the napi structs because we
have a check for netdev, thus we were leaving garbage around in the system.

Change-ID: Ife540176f6c9f801147495b3f2d2ac2e61ddcc58
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 43d391b..a3f122e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6806,8 +6806,6 @@ int i40e_vsi_release(struct i40e_vsi *vsi)
 			if (vsi->netdev) {
 				/* results in a call to i40e_close() */
 				unregister_netdev(vsi->netdev);
-				free_netdev(vsi->netdev);
-				vsi->netdev = NULL;
 			}
 		} else {
 			if (!test_and_set_bit(__I40E_DOWN, &vsi->state))
@@ -6826,6 +6824,10 @@ int i40e_vsi_release(struct i40e_vsi *vsi)
 
 	i40e_vsi_delete(vsi);
 	i40e_vsi_free_q_vectors(vsi);
+	if (vsi->netdev) {
+		free_netdev(vsi->netdev);
+		vsi->netdev = NULL;
+	}
 	i40e_vsi_clear_rings(vsi);
 	i40e_vsi_clear(vsi);
 
-- 
1.8.3.1
