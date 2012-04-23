From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: skb_free_datagram_locked() consumes skb
Date: Mon, 23 Apr 2012 10:09:27 +0200
Message-ID: <1335168567.3293.20.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:50205 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090Ab2DWIJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 04:09:31 -0400
Received: by bkcik5 with SMTP id ik5so8348795bkc.19
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2012 01:09:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

All skb_free_datagram_locked() callers consume skb, not drop it.
Noticed on dropwatch session polluted by UDP false positives.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/datagram.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index ae6acf6..402c964 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -248,7 +248,7 @@ void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb)
 	unlock_sock_fast(sk, slow);
 
 	/* skb is now orphaned, can be freed outside of locked section */
-	trace_kfree_skb(skb, skb_free_datagram_locked);
+	trace_consume_skb(skb);
 	__kfree_skb(skb);
 }
 EXPORT_SYMBOL(skb_free_datagram_locked);
