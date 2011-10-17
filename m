From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/6] igbvf: Fix trunk vlan
Date: Mon, 17 Oct 2011 05:20:57 -0700
Message-ID: <1318854062-3628-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318854062-3628-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jiri Pirko <jpirko@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33845 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752834Ab1JQMVG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 08:21:06 -0400
In-Reply-To: <1318854062-3628-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Changes to clean up the VLAN Rx path by Jiri Pirko broke trunk VLAN.
Trunk VLANs in a VF driver are those set using

"ip link set <pfdev> vf <n> <vlanid>"

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
CC: Jiri Pirko <jpirko@redhat.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/netdev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 32b3044..23cc40f 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -102,8 +102,8 @@ static void igbvf_receive_skb(struct igbvf_adapter *adapter,
 {
 	if (status & E1000_RXD_STAT_VP) {
 		u16 vid = le16_to_cpu(vlan) & E1000_RXD_SPC_VLAN_MASK;
-
-		__vlan_hwaccel_put_tag(skb, vid);
+		if (test_bit(vid, adapter->active_vlans))
+			__vlan_hwaccel_put_tag(skb, vid);
 	}
 	netif_receive_skb(skb);
 }
-- 
1.7.6.4
