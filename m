From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] igb: Always enable VLAN 0 even if 8021q is not loaded
Date: Mon, 15 Feb 2016 19:21:49 -0800
Message-ID: <1455592915-82261-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455592915-82261-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35022 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753341AbcBPDWE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2016 22:22:04 -0500
In-Reply-To: <1455592915-82261-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This patch makes it so that we always add VLAN 0.  This is important as we
need to guarantee the PF can receive untagged frames in the case of SR-IOV
being enabled but VLAN filtering not being enabled in the kernel.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 9461480..f3e1738 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7177,11 +7177,12 @@ static int igb_vlan_rx_kill_vid(struct net_device *netdev,
 
 static void igb_restore_vlan(struct igb_adapter *adapter)
 {
-	u16 vid;
+	u16 vid = 1;
 
 	igb_vlan_mode(adapter->netdev, adapter->netdev->features);
+	igb_vlan_rx_add_vid(adapter->netdev, htons(ETH_P_8021Q), 0);
 
-	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
+	for_each_set_bit_from(vid, adapter->active_vlans, VLAN_N_VID)
 		igb_vlan_rx_add_vid(adapter->netdev, htons(ETH_P_8021Q), vid);
 }
 
-- 
2.5.0
