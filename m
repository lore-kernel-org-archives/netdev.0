From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next] tcp: remove obsolete comment about TCP_SKB_CB(skb)->when in tcp_fragment()
Date: Sat,  6 Sep 2014 11:18:20 -0400
Message-ID: <1410016700-9145-1-git-send-email-ncardwell@google.com>
Cc: edumazet@google.com, ycheng@google.com, netdev@vger.kernel.org,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f202.google.com ([209.85.213.202]:61835 "EHLO
	mail-ig0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbaIFPSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 11:18:25 -0400
Received: by mail-ig0-f202.google.com with SMTP id r2so2270283igi.1
        for <netdev@vger.kernel.org>; Sat, 06 Sep 2014 08:18:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TCP_SKB_CB(skb)->when field no longer exists as of recent change
7faee5c0d514 ("tcp: remove TCP_SKB_CB(skb)->when"). And in any case,
tcp_fragment() is called on already-transmitted packets from the
__tcp_retransmit_skb() call site, so copying timestamps of any kind
in this spot is quite sensible.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Reported-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_output.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 3b22dcb..7f1280d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1146,9 +1146,6 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
 
 	buff->ip_summed = skb->ip_summed;
 
-	/* Looks stupid, but our code really uses when of
-	 * skbs, which it never sent before. --ANK
-	 */
 	buff->tstamp = skb->tstamp;
 	tcp_fragment_tstamp(skb, buff);
 
-- 
2.1.0.rc2.206.gedb03e5
