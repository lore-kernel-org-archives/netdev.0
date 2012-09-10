From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH -next] net: fix net/core/sock.c build error
Date: Mon, 10 Sep 2012 09:13:07 -0700
Message-ID: <504E1193.4060809@xenotime.net>
References: <20120910172407.c5ad953c008165fcd862bd3c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120910172407.c5ad953c008165fcd862bd3c@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

Fix net/core/sock.c build error when CONFIG_INET is not enabled:

net/built-in.o: In function `sock_edemux':
(.text+0xd396): undefined reference to `inet_twsk_put'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 net/core/sock.c |    2 ++
 1 file changed, 2 insertions(+)

--- linux-next-20120910.orig/net/core/sock.c
+++ linux-next-20120910/net/core/sock.c
@@ -1525,9 +1525,11 @@ void sock_edemux(struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;
 
+#ifdef CONFIG_INET
 	if (sk->sk_state == TCP_TIME_WAIT)
 		inet_twsk_put(inet_twsk(sk));
 	else
+#endif
 		sock_put(sk);
 }
 EXPORT_SYMBOL(sock_edemux);
