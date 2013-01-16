From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] e1000e: merge multiple conditional statements into one
Date: Wed, 16 Jan 2013 01:10:27 -0800
Message-ID: <1358327427-3146-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358327427-3146-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:36112 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932518Ab3APJKv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 04:10:51 -0500
In-Reply-To: <1358327427-3146-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Cleanup a set of conditional tests.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 6aa9c5d..05538e6 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4914,12 +4914,11 @@ static int e1000_transfer_dhcp_info(struct e1000_adapter *adapter,
 	struct e1000_hw *hw =  &adapter->hw;
 	u16 length, offset;
 
-	if (vlan_tx_tag_present(skb)) {
-		if (!((vlan_tx_tag_get(skb) == adapter->hw.mng_cookie.vlan_id) &&
-		    (adapter->hw.mng_cookie.status &
-			E1000_MNG_DHCP_COOKIE_STATUS_VLAN)))
-			return 0;
-	}
+	if (vlan_tx_tag_present(skb) &&
+	    !((vlan_tx_tag_get(skb) == adapter->hw.mng_cookie.vlan_id) &&
+	      (adapter->hw.mng_cookie.status &
+	       E1000_MNG_DHCP_COOKIE_STATUS_VLAN)))
+		return 0;
 
 	if (skb->len <= MINIMUM_DHCP_PACKET_SIZE)
 		return 0;
-- 
1.7.11.7
