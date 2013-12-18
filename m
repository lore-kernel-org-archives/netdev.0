From: Tom Herbert <therbert@google.com>
Subject: [PATCH 08/15] net: igb calls skb_set_hash
Date: Tue, 17 Dec 2013 23:27:43 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312172325170.24419@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:34450 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249Ab3LRH1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:27:44 -0500
Received: by mail-ie0-f201.google.com with SMTP id at1so1461477iec.0
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 23:27:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_hash to set the hash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 3bc10bd..e23182a 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6606,7 +6606,9 @@ static inline void igb_rx_hash(struct igb_ring *ring,
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
1.8.5.1
