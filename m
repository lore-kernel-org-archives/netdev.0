From: Joe Perches <joe@perches.com>
Subject: [PATCH] net: tcp_input: Neaten DBGUNDO
Date: Sun, 10 Sep 2017 19:02:25 -0700
Message-ID: <fcac7d078947b59e47ad4474d2c60d4fd3395bcd.1505095255.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the #ifdef into the static void function so that the use
of DBGUNDO is validated when FASTRETRANS_DEBUG <= 1.

Remove the now unnecessary #else and #define DBGUNDO.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv4/tcp_input.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c5d7656beeee..bddf724f5c02 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2333,9 +2333,9 @@ static bool tcp_any_retrans_done(const struct sock *sk)
 	return false;
 }
 
-#if FASTRETRANS_DEBUG > 1
 static void DBGUNDO(struct sock *sk, const char *msg)
 {
+#if FASTRETRANS_DEBUG > 1
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_sock *inet = inet_sk(sk);
 
@@ -2357,10 +2357,8 @@ static void DBGUNDO(struct sock *sk, const char *msg)
 			 tp->packets_out);
 	}
 #endif
-}
-#else
-#define DBGUNDO(x...) do { } while (0)
 #endif
+}
 
 static void tcp_undo_cwnd_reduction(struct sock *sk, bool unmark_loss)
 {
-- 
2.10.0.rc2.1.g053435c
