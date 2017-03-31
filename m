From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sock: correctly test SOCK_TIMESTAMP in
 sock_recv_ts_and_drops()
Date: Fri, 31 Mar 2017 14:59:25 -0700
Message-ID: <1490997565.8750.39.camel@edumazet-glaptop3.roam.corp.google.com>
References: <f29d595f4a72d77730447be2a7c5f243fad47751.1490875313.git.pabeni@redhat.com>
         <20170330.202924.1023519735753552178.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pabeni@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33994 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754627AbdCaV72 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 17:59:28 -0400
Received: by mail-pg0-f65.google.com with SMTP id o123so20047381pga.1
        for <netdev@vger.kernel.org>; Fri, 31 Mar 2017 14:59:27 -0700 (PDT)
In-Reply-To: <20170330.202924.1023519735753552178.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

It seems the code does not match the intent.

This broke packetdrill, and probably other programs.

Fixes: 6c7c98bad488 ("sock: avoid dirtying sk_stamp, if possible")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Paolo Abeni <pabeni@redhat.com>
---
 include/net/sock.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 8e53158a7d957ea2a480cc449606dca2480b1259..66349e49d468646ce724485bb8e74952825f0d6c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2250,7 +2250,7 @@ static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
 
 	if (sk->sk_flags & FLAGS_TS_OR_DROPS || sk->sk_tsflags & TSFLAGS_ANY)
 		__sock_recv_ts_and_drops(msg, sk, skb);
-	else if (unlikely(sk->sk_flags & SOCK_TIMESTAMP))
+	else if (unlikely(sock_flag(sk, SOCK_TIMESTAMP)))
 		sk->sk_stamp = skb->tstamp;
 	else if (unlikely(sk->sk_stamp == SK_DEFAULT_STAMP))
 		sk->sk_stamp = 0;
