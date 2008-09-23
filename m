From: David Miller <davem@davemloft.net>
Subject: [PATCH]: tcp: Fix order of tests in tcp_retransmit_skb()
Date: Tue, 23 Sep 2008 01:34:06 -0700 (PDT)
Message-ID: <20080923.013406.65754438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55360
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754390AbYIWIeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 04:34:18 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 06B1DC8C181
	for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 01:34:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The assertion I placed in skb_queue_next() found a bug already,
but this specific case turned out to be harmless :-)

tcp: Fix order of tests in tcp_retransmit_skb()

tcp_write_queue_next() must only be made if we know that
tcp_skb_is_last() evaluates to false.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/tcp_output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index c3d58ee..a8499ef 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1932,8 +1932,8 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	/* Collapse two adjacent packets if worthwhile and we can. */
 	if (!(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_SYN) &&
 	    (skb->len < (cur_mss >> 1)) &&
-	    (tcp_write_queue_next(sk, skb) != tcp_send_head(sk)) &&
 	    (!tcp_skb_is_last(sk, skb)) &&
+	    (tcp_write_queue_next(sk, skb) != tcp_send_head(sk)) &&
 	    (skb_shinfo(skb)->nr_frags == 0 &&
 	     skb_shinfo(tcp_write_queue_next(sk, skb))->nr_frags == 0) &&
 	    (tcp_skb_pcount(skb) == 1 &&
-- 
1.5.6.5

