From: Tom Herbert <therbert@google.com>
Subject: [PATCH 11/17] net: ixgbe calls skb_get_rxhash
Date: Mon, 25 Nov 2013 21:54:33 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311252153050.23058@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f73.google.com ([209.85.216.73]:43917 "EHLO
	mail-qa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753116Ab3KZGBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 01:01:37 -0500
Received: by mail-qa0-f73.google.com with SMTP id o15so1137634qap.2
        for <netdev@vger.kernel.org>; Mon, 25 Nov 2013 22:01:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_get_rxhash to set the rxhash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index bd8f523..9973eaf 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1233,7 +1233,9 @@ static inline void ixgbe_rx_hash(struct ixgbe_ring *ring,
 				 struct sk_buff *skb)
 {
 	if (ring->netdev->features & NETIF_F_RXHASH)
-		skb->rxhash = le32_to_cpu(rx_desc->wb.lower.hi_dword.rss);
+		skb_set_rxhash(skb,
+			       le32_to_cpu(rx_desc->wb.lower.hi_dword.rss),
+			       RXHASH_TYPE_L3);
 }
 
 #ifdef IXGBE_FCOE
-- 
1.8.4.1
