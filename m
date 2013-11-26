From: Tom Herbert <therbert@google.com>
Subject: [PATCH 10/17] net: igb calls skb_get_rxhash
Date: Mon, 25 Nov 2013 21:54:28 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311252153020.22983@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:56691 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140Ab3KZFy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 00:54:29 -0500
Received: by mail-oa0-f73.google.com with SMTP id i4so1115408oah.4
        for <netdev@vger.kernel.org>; Mon, 25 Nov 2013 21:54:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_get_rxhash to set the rxhash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index ebe6370..4e8e2b2 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6412,7 +6412,9 @@ static inline void igb_rx_hash(struct igb_ring *ring,
 			       struct sk_buff *skb)
 {
 	if (ring->netdev->features & NETIF_F_RXHASH)
-		skb->rxhash = le32_to_cpu(rx_desc->wb.lower.hi_dword.rss);
+		skb_set_rxhash(skb,
+			       le32_to_cpu(rx_desc->wb.lower.hi_dword.rss),
+			       RXHASH_TYPE_L3);
 }
 
 /**
-- 
1.8.4.1
