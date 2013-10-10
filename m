From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/13] i40e: Link code updates
Date: Wed,  9 Oct 2013 23:40:59 -0700
Message-ID: <1381387271-29605-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1381387271-29605-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai <anjali.singhai@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:46635 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752197Ab3JJGlR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Oct 2013 02:41:17 -0400
In-Reply-To: <1381387271-29605-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai <anjali.singhai@intel.com>

Link events should not print to the log until the device is
administratively up.

Signed-off-by: Anjali Singhai <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 221aa47..657babe 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3703,8 +3703,11 @@ static int i40e_up_complete(struct i40e_vsi *vsi)
 
 	if ((pf->hw.phy.link_info.link_info & I40E_AQ_LINK_UP) &&
 	    (vsi->netdev)) {
+		netdev_info(vsi->netdev, "NIC Link is Up\n");
 		netif_tx_start_all_queues(vsi->netdev);
 		netif_carrier_on(vsi->netdev);
+	} else if (vsi->netdev) {
+		netdev_info(vsi->netdev, "NIC Link is Down\n");
 	}
 	i40e_service_event_schedule(pf);
 
@@ -4153,8 +4156,9 @@ static void i40e_link_event(struct i40e_pf *pf)
 	if (new_link == old_link)
 		return;
 
-	netdev_info(pf->vsi[pf->lan_vsi]->netdev,
-		    "NIC Link is %s\n", (new_link ? "Up" : "Down"));
+	if (!test_bit(__I40E_DOWN, &pf->vsi[pf->lan_vsi]->state))
+		netdev_info(pf->vsi[pf->lan_vsi]->netdev,
+			    "NIC Link is %s\n", (new_link ? "Up" : "Down"));
 
 	/* Notify the base of the switch tree connected to
 	 * the link.  Floating VEBs are not notified.
-- 
1.8.3.1
