From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: add a prefetch in socket backlog processing
Date: Tue, 01 May 2012 04:07:09 +0200
Message-ID: <1335838029.11396.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:33377 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881Ab2EACHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 22:07:15 -0400
Received: by wejx9 with SMTP id x9so2143462wej.19
        for <netdev@vger.kernel.org>; Mon, 30 Apr 2012 19:07:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCP or UDP stacks have big enough latencies that prefetching next
pointer is worth it.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/sock.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/sock.c b/net/core/sock.c
index 836bca6..1a88351 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1700,6 +1700,7 @@ static void __release_sock(struct sock *sk)
 		do {
 			struct sk_buff *next = skb->next;
 
+			prefetch(next);
 			WARN_ON_ONCE(skb_dst_is_noref(skb));
 			skb->next = NULL;
 			sk_backlog_rcv(sk, skb);
