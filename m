From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 10/17] tcp: remove tcp_synack_options() socket argument
Date: Fri, 25 Sep 2015 07:39:17 -0700
Message-ID: <1443191964-923-11-git-send-email-edumazet@google.com>
References: <1443191964-923-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36455 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113AbbIYOkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 10:40:16 -0400
Received: by pablk4 with SMTP id lk4so10826789pab.3
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 07:40:16 -0700 (PDT)
In-Reply-To: <1443191964-923-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We do not use the socket in this function.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1767fe652cb5..ab03018fb621 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -612,12 +612,11 @@ static unsigned int tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 }
 
 /* Set up TCP options for SYN-ACKs. */
-static unsigned int tcp_synack_options(struct sock *sk,
-				   struct request_sock *req,
-				   unsigned int mss, struct sk_buff *skb,
-				   struct tcp_out_options *opts,
-				   const struct tcp_md5sig_key *md5,
-				   struct tcp_fastopen_cookie *foc)
+static unsigned int tcp_synack_options(struct request_sock *req,
+				       unsigned int mss, struct sk_buff *skb,
+				       struct tcp_out_options *opts,
+				       const struct tcp_md5sig_key *md5,
+				       struct tcp_fastopen_cookie *foc)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
 	unsigned int remaining = MAX_TCP_OPTION_SPACE;
@@ -2990,8 +2989,8 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	md5 = tcp_rsk(req)->af_specific->req_md5_lookup(sk, req_to_sk(req));
 #endif
 	skb_set_hash(skb, tcp_rsk(req)->txhash, PKT_HASH_TYPE_L4);
-	tcp_header_size = tcp_synack_options(sk, req, mss, skb, &opts, md5,
-					     foc) + sizeof(*th);
+	tcp_header_size = tcp_synack_options(req, mss, skb, &opts, md5, foc) +
+			  sizeof(*th);
 
 	skb_push(skb, tcp_header_size);
 	skb_reset_transport_header(skb);
-- 
2.6.0.rc2.230.g3dd15c0
