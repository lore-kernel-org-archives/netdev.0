From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/13] net: igb calls skb_set_hash
Date: Tue, 11 Mar 2014 22:53:27 -0700
Message-ID: <1394603618-1044-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394603618-1044-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33779 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754579AbaCLFxl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 01:53:41 -0400
In-Reply-To: <1394603618-1044-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>

Drivers should call skb_set_hash to set the hash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 3384156..a96beb6 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6620,7 +6620,9 @@ static inline void igb_rx_hash(struct igb_ring *ring,
 			       struct sk_buff *skb)
 {
 	if (ring->netdev->features & NETIF_F_RXHASH)
-		skb->rxhash = le32_to_cpu(rx_desc->wb.lower.hi_dword.rss);
+		skb_set_hash(skb,
+			     le32_to_cpu(rx_desc->wb.lower.hi_dword.rss),
+			     PKT_HASH_TYPE_L3);
 }
 
 /**
-- 
1.8.3.1
