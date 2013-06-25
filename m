From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: remove invalid __rcu annotation
Date: Tue, 25 Jun 2013 01:21:06 -0700
Message-ID: <1372148466.3301.85.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jerry Chu <hkchu@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:42936 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767Ab3FYIVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 04:21:09 -0400
Received: by mail-la0-f46.google.com with SMTP id eg20so11713939lab.19
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 01:21:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

struct tcp_fastopen_context has a field named tfm, which is a pointer
to a crypto_cipher structure.

It currently has a __rcu annotation, which is not needed at all.

tcp_fastopen_ctx is the pointer fetched by rcu_dereference(), but once
we have a pointer to current tcp_fastopen_context, we do not use/need
rcu_dereference() to access tfm.

This fixes a lot of sparse errors like the following :

net/ipv4/tcp_fastopen.c:21:31: warning: incorrect type in argument 1 (different address spaces)
net/ipv4/tcp_fastopen.c:21:31:    expected struct crypto_cipher *tfm
net/ipv4/tcp_fastopen.c:21:31:    got struct crypto_cipher [noderef] <asn:4>*tfm

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jerry Chu <hkchu@google.com>
---
 include/net/tcp.h |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5bba80f..3239997 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1319,9 +1319,9 @@ void tcp_fastopen_cookie_gen(__be32 addr, struct tcp_fastopen_cookie *foc);
 
 /* Fastopen key context */
 struct tcp_fastopen_context {
-	struct crypto_cipher __rcu	*tfm;
-	__u8				key[TCP_FASTOPEN_KEY_LENGTH];
-	struct rcu_head			rcu;
+	struct crypto_cipher	*tfm;
+	__u8			key[TCP_FASTOPEN_KEY_LENGTH];
+	struct rcu_head		rcu;
 };
 
 /* write queue abstraction */
