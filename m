From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] ipv4: clear all TCP_SKB_CB before passing to network layer
Date: Fri, 17 Oct 2014 10:49:29 -0700
Message-ID: <1413568169-4123-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: davem@davemloft.net, Cong Wang <xiyou.wangcong@gmail.com>,
	Krzysztof Kolasa <kkolasa@winsoft.pl>,
	Eric Dumazet <edumazet@google.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:57403 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638AbaJQRtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 13:49:36 -0400
Received: by mail-pa0-f42.google.com with SMTP id bj1so1247874pad.1
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2014 10:49:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>

Probably not a big deal, but IP is not the only network protocol,
don't clear skb->cb just for IP.

Also, IPv6 header is not always defined in struct tcp_skb_cb.

Cc: Krzysztof Kolasa <kkolasa@winsoft.pl>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/tcp_output.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e13d778..ee356e5 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1005,9 +1005,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	/* Our usage of tstamp should remain private */
 	skb->tstamp.tv64 = 0;
 
-	/* Cleanup our debris for IP stacks */
-	memset(skb->cb, 0, max(sizeof(struct inet_skb_parm),
-			       sizeof(struct inet6_skb_parm)));
+	memset(TCP_SKB_CB(skb), 0, sizeof(*TCP_SKB_CB(skb)));
 
 	err = icsk->icsk_af_ops->queue_xmit(sk, skb, &inet->cork.fl);
 
-- 
1.8.3.1
