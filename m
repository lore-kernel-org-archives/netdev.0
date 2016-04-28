From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH v2 net-next 1/2] tcp: remove an unnecessary check in tcp_tx_timestamp
Date: Wed, 27 Apr 2016 23:39:00 -0400
Message-ID: <1461814741-848-2-git-send-email-soheil.kdev@gmail.com>
References: <1461814741-848-1-git-send-email-soheil.kdev@gmail.com>
Cc: kafai@fb.com, willemb@google.com, edumazet@google.com,
	ycheng@google.com, ncardwell@google.com,
	Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35629 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751710AbcD1DjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 23:39:07 -0400
Received: by mail-qk0-f196.google.com with SMTP id b63so4781331qkg.2
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 20:39:07 -0700 (PDT)
In-Reply-To: <1461814741-848-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

Remove the redundant check for sk->sk_tsflags in tcp_tx_timestamp.

tcp_tx_timestamp() receives the tsflags as a parameter. As a
result the "sk->sk_tsflags || tsflags" is redundant, since
tsflags already includes sk->sk_tsflags plus overrides from
control messages.

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
