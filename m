From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/25] fm10k: allow creation of VLAN on default vid
Date: Tue, 14 Apr 2015 16:50:53 -0700
Message-ID: <1429055471-401-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jacob Keller <jacob.e.keller@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:51346 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754407AbbDNXvT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 19:51:19 -0400
In-Reply-To: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously, the user was not allowed to create a VLAN interface on top
of the switch default vid.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 702d845..6981964 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -770,15 +770,15 @@ static int fm10k_update_vid(struct net_device *netdev, u16 vid, bool set)
 	if (hw->mac.vlan_override)
 		return -EACCES;
 
-	/* if default VLAN is already present do nothing */
-	if (vid == hw->mac.default_vid)
-		return -EBUSY;
-
 	/* update active_vlans bitmask */
 	set_bit(vid, interface->active_vlans);
 	if (!set)
 		clear_bit(vid, interface->active_vlans);
 
+	/* if default VLAN is already present do nothing */
+	if (vid == hw->mac.default_vid)
+		return 0;
+
 	fm10k_mbx_lock(interface);
 
 	/* only need to update the VLAN if not in promiscuous mode */
-- 
1.9.3
