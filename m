From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: [PATCH net-next v3 2/2] tcp: Remove the unused parameter for tcp_try_fastopen.
Date: Mon, 21 Aug 2017 23:33:49 -0700
Message-ID: <1503383629-12392-3-git-send-email-xiangxia.m.yue@gmail.com>
References: <1503383629-12392-1-git-send-email-xiangxia.m.yue@gmail.com>
Cc: eric.dumazet@gmail.com, Tonghao Zhang <xiangxia.m.yue@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34692 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754635AbdHVGeL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 02:34:11 -0400
Received: by mail-pf0-f196.google.com with SMTP id w127so1225228pfd.1
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 23:34:11 -0700 (PDT)
In-Reply-To: <1503383629-12392-1-git-send-email-xiangxia.m.yue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
---
 include/net/tcp.h       | 3 +--
 net/ipv4/tcp_fastopen.c | 6 ++----
 net/ipv4/tcp_input.c    | 2 +-
 3 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index afdab3781425..a995004ae946 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1533,8 +1533,7 @@ int tcp_fastopen_reset_cipher(void *key, unsigned int len);
 void tcp_fastopen_add_skb(struct sock *sk, struct sk_buff *skb);
 struct sock *tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 			      struct request_sock *req,
-			      struct tcp_fastopen_cookie *foc,
-			      struct dst_entry *dst);
+			      struct tcp_fastopen_cookie *foc);
 void tcp_fastopen_init_key_once(bool publish);
 bool tcp_fastopen_cookie_check(struct sock *sk, u16 *mss,
 			     struct tcp_fastopen_cookie *cookie);
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index ce9c7fef200f..e3c33220c418 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -171,7 +171,6 @@ void tcp_fastopen_add_skb(struct sock *sk, struct sk_buff *skb)
 
 static struct sock *tcp_fastopen_create_child(struct sock *sk,
 					      struct sk_buff *skb,
-					      struct dst_entry *dst,
 					      struct request_sock *req)
 {
 	struct tcp_sock *tp;
@@ -278,8 +277,7 @@ static bool tcp_fastopen_queue_check(struct sock *sk)
  */
 struct sock *tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 			      struct request_sock *req,
-			      struct tcp_fastopen_cookie *foc,
-			      struct dst_entry *dst)
+			      struct tcp_fastopen_cookie *foc)
 {
 	struct tcp_fastopen_cookie valid_foc = { .len = -1 };
 	bool syn_data = TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq + 1;
@@ -312,7 +310,7 @@ struct sock *tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 		 * data in SYN_RECV state.
 		 */
 fastopen:
-		child = tcp_fastopen_create_child(sk, skb, dst, req);
+		child = tcp_fastopen_create_child(sk, skb, req);
 		if (child) {
 			foc->len = -1;
 			NET_INC_STATS(sock_net(sk),
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9397e989e1d1..6bd1f0f56e8b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6151,7 +6151,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	tcp_openreq_init_rwin(req, sk, dst);
 	if (!want_cookie) {
 		tcp_reqsk_record_syn(sk, req, skb);
-		fastopen_sk = tcp_try_fastopen(sk, skb, req, &foc, dst);
+		fastopen_sk = tcp_try_fastopen(sk, skb, req, &foc);
 	}
 	if (fastopen_sk) {
 		af_ops->send_synack(fastopen_sk, dst, &fl, req,
-- 
2.13.4
