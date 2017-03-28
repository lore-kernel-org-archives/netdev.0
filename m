From: Aviad Yehezkel <aviadye@mellanox.com>
Subject: [RFC TLS Offload Support 02/15] tcp: export do_tcp_sendpages function
Date: Tue, 28 Mar 2017 16:26:19 +0300
Message-ID: <1490707592-1430-3-git-send-email-aviadye@mellanox.com>
References: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Cc: matanb@mellanox.com, liranl@mellanox.com, haggaie@mellanox.com,
        tom@herbertland.com, herbert@gondor.apana.org.au, nmav@gnults.org,
        fridolin.pokorny@gmail.com, ilant@mellanox.com,
        kliteyn@mellanox.com, linux-crypto@vger.kernel.org,
        saeedm@mellanox.com, aviadye@dev.mellanox.co.il
To: davem@davemloft.net, aviadye@mellanox.com, ilyal@mellanox.com,
        borisp@mellanox.com, davejwatson@fb.com, netdev@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We will use it via tls new code.

Signed-off-by: Aviad Yehezkel <aviadye@mellanox.com>
Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
Signed-off-by: Boris Pismenny <borisp@mellanox.com>
---
 include/net/tcp.h | 2 ++
 net/ipv4/tcp.c    | 5 +++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 207147b..3a72d4c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -348,6 +348,8 @@ int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw);
 int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size);
 int tcp_sendpage(struct sock *sk, struct page *page, int offset, size_t size,
 		 int flags);
+ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
+		 size_t size, int flags);
 void tcp_release_cb(struct sock *sk);
 void tcp_wfree(struct sk_buff *skb);
 void tcp_write_timer_handler(struct sock *sk);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1149b48..302fee9 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -873,8 +873,8 @@ static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
 	return mss_now;
 }
 
-static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
-				size_t size, int flags)
+ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
+			 size_t size, int flags)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int mss_now, size_goal;
@@ -1003,6 +1003,7 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 	}
 	return sk_stream_error(sk, flags, err);
 }
+EXPORT_SYMBOL(do_tcp_sendpages);
 
 int tcp_sendpage(struct sock *sk, struct page *page, int offset,
 		 size_t size, int flags)
-- 
2.7.4
