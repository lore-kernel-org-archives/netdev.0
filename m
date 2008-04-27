From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/6] sis190: hard-code the alignment of tiny packets
Date: Sun, 27 Apr 2008 19:02:38 +0200
Message-ID: <20080427170238.GC26953@electric-eye.fr.zoreil.com>
References: <20080427170023.GA26953@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60969 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755924AbYD0RVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 13:21:52 -0400
Content-Disposition: inline
In-Reply-To: <20080427170023.GA26953@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no DMA involved here. Align the IP header without condition.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/sis190.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 0d6aa1f..248c385 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -526,9 +526,9 @@ static inline int sis190_try_rx_copy(struct sk_buff **sk_buff, int pkt_size,
 	if (pkt_size < rx_copybreak) {
 		struct sk_buff *skb;
 
-		skb = dev_alloc_skb(pkt_size + NET_IP_ALIGN);
+		skb = dev_alloc_skb(pkt_size + 2);
 		if (skb) {
-			skb_reserve(skb, NET_IP_ALIGN);
+			skb_reserve(skb, 2);
 			skb_copy_to_linear_data(skb, sk_buff[0]->data, pkt_size);
 			*sk_buff = skb;
 			sis190_give_to_asic(desc, rx_buf_sz);
-- 
1.5.3.3

