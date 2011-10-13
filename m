From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] igb: fix skb truesize underestimation
Date: Thu, 13 Oct 2011 19:56:41 +0200
Message-ID: <1318528601.2393.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49531 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756641Ab1JMR4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 13:56:24 -0400
Received: by wyg34 with SMTP id 34so2145042wyg.19
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 10:56:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

e1000 allocates half a page per skb fragment. We must account
PAGE_SIZE/2 increments on skb->truesize, not the actual frag length.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 10670f9..1adcdf8 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5946,7 +5946,7 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, int budget)
 
 			skb->len += length;
 			skb->data_len += length;
-			skb->truesize += length;
+			skb->truesize += PAGE_SIZE / 2;
 
 			if ((page_count(buffer_info->page) != 1) ||
 			    (page_to_nid(buffer_info->page) != current_node))
