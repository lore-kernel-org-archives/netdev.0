From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH net-next 1/2] tcp: remove an unnecessary check in tcp_tx_timestamp
Date: Mon, 25 Apr 2016 16:51:12 -0400
Message-ID: <1461617473-11349-1-git-send-email-soheil.kdev@gmail.com>
Cc: kafai@fb.com, willemb@google.com, edumazet@google.com,
	ycheng@google.com, ncardwell@google.com,
	Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:32834 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964853AbcDYUvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 16:51:33 -0400
Received: by mail-qk0-f196.google.com with SMTP id q184so11384590qkf.0
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 13:51:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

tcp_tx_timestamp() receives tsflags as a parameter. tsflags
is initialized to sk->sk_tsflags and is overridden by control
messages. As a result the "sk->sk_tsflags || tsflags" is the
same expression as "tsflags"

Remove the redundant check for sk->sk_tsflags in tcp_tx_timestamp.

Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 net/ipv4/tcp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4d73858..3c542dc 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -430,7 +430,7 @@ EXPORT_SYMBOL(tcp_init_sock);
 
 static void tcp_tx_timestamp(struct sock *sk, u16 tsflags, struct sk_buff *skb)
 {
-	if (sk->sk_tsflags || tsflags) {
+	if (tsflags) {
 		struct skb_shared_info *shinfo = skb_shinfo(skb);
 		struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
 
-- 
2.8.0.rc3.226.g39d4020
