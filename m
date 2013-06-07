From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/2] net: minor: tcp: use tcp_skb_mss helper in tcp_tso_segment
Date: Fri,  7 Jun 2013 17:11:45 +0200
Message-ID: <1370617906-4849-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17661 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755941Ab3FGPLt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jun 2013 11:11:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have the minimal inline helper tcp_skb_mss to access
skb_shinfo(skb)->gso_size, so also use it here to get mss.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/ipv4/tcp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b5d4ad9..6a1cf95 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2905,7 +2905,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
 	oldlen = (u16)~skb->len;
 	__skb_pull(skb, thlen);
 
-	mss = skb_shinfo(skb)->gso_size;
+	mss = tcp_skb_mss(skb);
 	if (unlikely(skb->len <= mss))
 		goto out;
 
@@ -3071,7 +3071,7 @@ found:
 		flush |= *(u32 *)((u8 *)th + i) ^
 			 *(u32 *)((u8 *)th2 + i);
 
-	mss = skb_shinfo(p)->gso_size;
+	mss = tcp_skb_mss(p);
 
 	flush |= (len - 1) >= mss;
 	flush |= (ntohl(th2->seq) + skb_gro_len(p)) ^ ntohl(th->seq);
-- 
1.7.11.7
