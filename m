From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 04/10] net: ixgbe calls skb_set_hash
Date: Wed, 12 Mar 2014 19:31:24 -0700
Message-ID: <1394677890-11043-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394677890-11043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:33591 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752568AbaCMCb5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 22:31:57 -0400
In-Reply-To: <1394677890-11043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>

Drivers should call skb_set_hash to set the hash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 10b35d8..815e81e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1311,7 +1311,9 @@ static inline void ixgbe_rx_hash(struct ixgbe_ring *ring,
 				 struct sk_buff *skb)
 {
 	if (ring->netdev->features & NETIF_F_RXHASH)
-		skb->rxhash = le32_to_cpu(rx_desc->wb.lower.hi_dword.rss);
+		skb_set_hash(skb,
+			     le32_to_cpu(rx_desc->wb.lower.hi_dword.rss),
+			     PKT_HASH_TYPE_L3);
 }
 
 #ifdef IXGBE_FCOE
-- 
1.8.3.1
