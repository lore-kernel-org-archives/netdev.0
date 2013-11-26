From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 11/17] net: ixgbe calls skb_set_rxhash
Date: Tue, 26 Nov 2013 09:31:23 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311260928030.21138@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f74.google.com ([209.85.160.74]:34702 "EHLO
	mail-pb0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752318Ab3KZRbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 12:31:24 -0500
Received: by mail-pb0-f74.google.com with SMTP id uo5so841271pbc.1
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 09:31:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_rxhash to set the rxhash and its type
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
