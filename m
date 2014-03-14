From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 11/14] i40e: Bug fix for FDIR replay logic
Date: Fri, 14 Mar 2014 16:34:32 -0700
Message-ID: <1394840075-6851-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394840075-6851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29252 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756504AbaCNXfI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 19:35:08 -0400
In-Reply-To: <1394840075-6851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

The FDIR replay logic was being run a little too soon (before the
queues were enabled) and hence the tail bump was not effective till
a later transaction happened on the queue.

Change-ID: Icfd7cd2e79fc3cae3cbd3f703a2b3a148b4e7bf6
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 6185856..669715b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2456,8 +2456,6 @@ static int i40e_vsi_configure(struct i40e_vsi *vsi)
 	i40e_set_vsi_rx_mode(vsi);
 	i40e_restore_vlan(vsi);
 	i40e_vsi_config_dcb_rings(vsi);
-	if (vsi->type == I40E_VSI_FDIR)
-		i40e_fdir_filter_restore(vsi);
 	err = i40e_vsi_configure_tx(vsi);
 	if (!err)
 		err = i40e_vsi_configure_rx(vsi);
@@ -4088,6 +4086,10 @@ static int i40e_up_complete(struct i40e_vsi *vsi)
 	} else if (vsi->netdev) {
 		netdev_info(vsi->netdev, "NIC Link is Down\n");
 	}
+
+	/* replay FDIR SB filters */
+	if (vsi->type == I40E_VSI_FDIR)
+		i40e_fdir_filter_restore(vsi);
 	i40e_service_event_schedule(pf);
 
 	return 0;
-- 
1.8.3.1
