From: Dan McGee <dpmcgee@gmail.com>
Subject: [PATCH] Disable TCP_DEBUG and FASTRETRANS_DEBUG by default
Date: Mon, 17 Oct 2011 15:25:24 -0500
Message-ID: <1318883125-29500-1-git-send-email-dpmcgee@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If these are truly debug options, they should be turned off by default
and can be tweaked if necessary. Fix one usage of the flag to use #if
instead of #ifdef so defining to zero is acceptable.

Signed-off-by: Dan McGee <dpmcgee@gmail.com>
---
 include/net/tcp.h    |    4 ++--
 net/ipv4/tcp_timer.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index acc620a..15236d0 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -18,8 +18,8 @@
 #ifndef _TCP_H
 #define _TCP_H
 
-#define TCP_DEBUG 1
-#define FASTRETRANS_DEBUG 1
+#define TCP_DEBUG 0
+#define FASTRETRANS_DEBUG 0
 
 #include <linux/list.h>
 #include <linux/tcp.h>
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index ecd44b0..31669e7 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -334,7 +334,7 @@ void tcp_retransmit_timer(struct sock *sk)
 		 * connection. If the socket is an orphan, time it out,
 		 * we cannot allow such beasts to hang infinitely.
 		 */
-#ifdef TCP_DEBUG
+#if TCP_DEBUG
 		struct inet_sock *inet = inet_sk(sk);
 		if (sk->sk_family == AF_INET) {
 			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Peer %pI4:%u/%u unexpectedly shrunk window %u:%u (repaired)\n",
-- 
1.7.7
