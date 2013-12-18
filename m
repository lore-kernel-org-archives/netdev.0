From: Tom Herbert <therbert@google.com>
Subject: [PATCH 09/15] net: ixgbe calls skb_set_hash
Date: Tue, 17 Dec 2013 23:28:03 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312172324380.24772@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f73.google.com ([209.85.216.73]:55073 "EHLO
	mail-qa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705Ab3LRH2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:28:05 -0500
Received: by mail-qa0-f73.google.com with SMTP id o15so13665qap.2
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 23:28:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_hash to set the hash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index cc06854..cbe5f3d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1233,7 +1233,9 @@ static inline void ixgbe_rx_hash(struct ixgbe_ring *ring,
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
1.8.5.1
