From: Ingo Molnar <mingo@elte.hu>
Subject: [patch] clean up tcp_sk(), 2.6.0
Date: Tue, 30 Dec 2003 17:32:30 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20031230163230.GA12553@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org


i recently wasted a few hours on a bug where i used "tcp_sk(sock)"
instead of "tcp_sk(sock->sk)" - the former, while being blatantly
incorrect, compiles just fine on 2.6.0. The patch below is equivalent to
the define but is also type-safe. Compiles cleanly & boots fine on
2.6.0.

	Ingo

--- linux/include/linux/tcp.h.orig
+++ linux/include/linux/tcp.h
@@ -386,7 +386,10 @@ struct tcp_sock {
 	struct tcp_opt	  tcp;
 };
 
-#define tcp_sk(__sk) (&((struct tcp_sock *)__sk)->tcp)
+static inline struct tcp_opt * tcp_sk(const struct sock *__sk)
+{
+	return &((struct tcp_sock *)__sk)->tcp;
+}
 
 #endif
 
