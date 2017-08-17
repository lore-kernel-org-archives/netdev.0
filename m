From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: [PATCH net-next v2 2/2] tcp: Remove the unused parameter for tcp_try_fastopen.
Date: Wed, 16 Aug 2017 20:02:46 -0700
Message-ID: <1502938966-6345-3-git-send-email-xiangxia.m.yue@gmail.com>
References: <1502938966-6345-1-git-send-email-xiangxia.m.yue@gmail.com>
Cc: Tonghao Zhang <xiangxia.m.yue@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:38389 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751780AbdHQDDM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 23:03:12 -0400
Received: by mail-pg0-f67.google.com with SMTP id 123so7466801pga.5
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 20:03:12 -0700 (PDT)
In-Reply-To: <1502938966-6345-1-git-send-email-xiangxia.m.yue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The parameter dst of tcp_try_fastopen and tcp_fastopen_create_child is
not used anymore. We remove it.

Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
---
 include/net/tcp.h       | 3 +--
 net/ipv4/tcp_fastopen.c | 6 ++----
 net/ipv4/tcp_input.c    | 2 +-
 3 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index afdab37..a995004 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1533,8 +1533,7 @@ struct tcp_fastopen_request {
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
index ce9c7fe..e3c3322 100644
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
index 7eee2c7..21df086 100644
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
1.8.3.1
