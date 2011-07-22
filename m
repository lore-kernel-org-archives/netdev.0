From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] acenic: include NET_SKB_PAD headroom to incoming skbs
Date: Fri, 22 Jul 2011 07:28:53 +0200
Message-ID: <1311312533.3886.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58630 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827Ab1GVF26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 01:28:58 -0400
Received: by wwe5 with SMTP id 5so1860661wwe.1
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2011 22:28:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some workloads need some headroom (NET_SKB_PAD) to avoid expensive
reallocations.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/acenic.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 02fcb5c..536038b 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -1657,7 +1657,7 @@ static void ace_load_std_rx_ring(struct ace_private *ap, int nr_bufs)
 		struct rx_desc *rd;
 		dma_addr_t mapping;
 
-		skb = alloc_skb(ACE_STD_BUFSIZE + NET_IP_ALIGN, GFP_ATOMIC);
+		skb = dev_alloc_skb(ACE_STD_BUFSIZE + NET_IP_ALIGN);
 		if (!skb)
 			break;
 
@@ -1718,7 +1718,7 @@ static void ace_load_mini_rx_ring(struct ace_private *ap, int nr_bufs)
 		struct rx_desc *rd;
 		dma_addr_t mapping;
 
-		skb = alloc_skb(ACE_MINI_BUFSIZE + NET_IP_ALIGN, GFP_ATOMIC);
+		skb = dev_alloc_skb(ACE_MINI_BUFSIZE + NET_IP_ALIGN);
 		if (!skb)
 			break;
 
@@ -1774,7 +1774,7 @@ static void ace_load_jumbo_rx_ring(struct ace_private *ap, int nr_bufs)
 		struct rx_desc *rd;
 		dma_addr_t mapping;
 
-		skb = alloc_skb(ACE_JUMBO_BUFSIZE + NET_IP_ALIGN, GFP_ATOMIC);
+		skb = dev_alloc_skb(ACE_JUMBO_BUFSIZE + NET_IP_ALIGN);
 		if (!skb)
 			break;
 


