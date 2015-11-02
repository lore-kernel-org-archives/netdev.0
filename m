From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: avoid NULL deref in inet_ctl_sock_destroy()
Date: Mon, 02 Nov 2015 07:50:07 -0800
Message-ID: <1446479407.23275.12.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34561 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754024AbbKBPuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 10:50:09 -0500
Received: by padec8 with SMTP id ec8so43061709pad.1
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 07:50:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Under low memory conditions, tcp_sk_init() and icmp_sk_init()
can both iterate on all possible cpus and call inet_ctl_sock_destroy(),
with eventual NULL pointer.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
---
 include/net/inet_common.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index 279f83591971..109e3ee9108c 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -41,7 +41,8 @@ int inet_recv_error(struct sock *sk, struct msghdr *msg, int len,
 
 static inline void inet_ctl_sock_destroy(struct sock *sk)
 {
-	sock_release(sk->sk_socket);
+	if (sk)
+		sock_release(sk->sk_socket);
 }
 
 #endif
