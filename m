From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 08/12] i40e: Remove a redundant filter addition
Date: Thu,  6 Mar 2014 18:59:20 -0800
Message-ID: <1394161164-26645-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394161164-26645-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:37801 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752461AbaCGC7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 21:59:32 -0500
In-Reply-To: <1394161164-26645-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Remove a redundant filter addition to stop FW complaints about a redundant
filter removal.

Change-ID: I22bef6b682bd8d43432557e6e2b3e73ffb27b985
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 46b3507..50d0032 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1965,11 +1965,14 @@ static int i40e_vlan_rx_add_vid(struct net_device *netdev,
 
 	netdev_info(netdev, "adding %pM vid=%d\n", netdev->dev_addr, vid);
 
-	/* If the network stack called us with vid = 0, we should
-	 * indicate to i40e_vsi_add_vlan() that we want to receive
-	 * any traffic (i.e. with any vlan tag, or untagged)
+	/* If the network stack called us with vid = 0 then
+	 * it is asking to receive priority tagged packets with
+	 * vlan id 0.  Our HW receives them by default when configured
+	 * to receive untagged packets so there is no need to add an
+	 * extra filter for vlan 0 tagged packets.
 	 */
-	ret = i40e_vsi_add_vlan(vsi, vid ? vid : I40E_VLAN_ANY);
+	if (vid)
+		ret = i40e_vsi_add_vlan(vsi, vid);
 
 	if (!ret && (vid < VLAN_N_VID))
 		set_bit(vid, vsi->active_vlans);
-- 
1.8.3.1
