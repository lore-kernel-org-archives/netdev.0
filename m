From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 5/6] net_sched: em_meta: use skb_to_full_sk() helper
Date: Sun,  8 Nov 2015 10:54:11 -0800
Message-ID: <1447008853-16060-6-git-send-email-edumazet@google.com>
References: <1447008853-16060-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Paul Moore <paul@paul-moore.com>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33725 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbbKHSyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 13:54:41 -0500
Received: by pabfh17 with SMTP id fh17so174802397pab.0
        for <netdev@vger.kernel.org>; Sun, 08 Nov 2015 10:54:41 -0800 (PST)
In-Reply-To: <1447008853-16060-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SYNACK packets might be attached to request sockets.

Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/em_meta.c | 138 ++++++++++++++++++++++++++++++++++------------------
 1 file changed, 92 insertions(+), 46 deletions(-)

diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index b5294ce20cd4..f2aabc0089da 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -343,119 +343,145 @@ META_COLLECTOR(int_sk_refcnt)
 
 META_COLLECTOR(int_sk_rcvbuf)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = skb->sk->sk_rcvbuf;
+	dst->value = sk->sk_rcvbuf;
 }
 
 META_COLLECTOR(int_sk_shutdown)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = skb->sk->sk_shutdown;
+	dst->value = sk->sk_shutdown;
 }
 
 META_COLLECTOR(int_sk_proto)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = skb->sk->sk_protocol;
+	dst->value = sk->sk_protocol;
 }
 
 META_COLLECTOR(int_sk_type)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = skb->sk->sk_type;
+	dst->value = sk->sk_type;
 }
 
 META_COLLECTOR(int_sk_rmem_alloc)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = sk_rmem_alloc_get(skb->sk);
+	dst->value = sk_rmem_alloc_get(sk);
 }
 
 META_COLLECTOR(int_sk_wmem_alloc)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = sk_wmem_alloc_get(skb->sk);
+	dst->value = sk_wmem_alloc_get(sk);
 }
 
 META_COLLECTOR(int_sk_omem_alloc)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = atomic_read(&skb->sk->sk_omem_alloc);
+	dst->value = atomic_read(&sk->sk_omem_alloc);
 }
 
 META_COLLECTOR(int_sk_rcv_qlen)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = skb->sk->sk_receive_queue.qlen;
+	dst->value = sk->sk_receive_queue.qlen;
 }
 
 META_COLLECTOR(int_sk_snd_qlen)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = skb->sk->sk_write_queue.qlen;
+	dst->value = sk->sk_write_queue.qlen;
 }
 
 META_COLLECTOR(int_sk_wmem_queued)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = skb->sk->sk_wmem_queued;
+	dst->value = sk->sk_wmem_queued;
 }
 
 META_COLLECTOR(int_sk_fwd_alloc)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = skb->sk->sk_forward_alloc;
+	dst->value = sk->sk_forward_alloc;
 }
 
 META_COLLECTOR(int_sk_sndbuf)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = skb->sk->sk_sndbuf;
+	dst->value = sk->sk_sndbuf;
 }
 
 META_COLLECTOR(int_sk_alloc)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = (__force int) skb->sk->sk_allocation;
+	dst->value = (__force int) sk->sk_allocation;
 }
 
 META_COLLECTOR(int_sk_hash)
@@ -469,92 +495,112 @@ META_COLLECTOR(int_sk_hash)
 
 META_COLLECTOR(int_sk_lingertime)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = skb->sk->sk_lingertime / HZ;
+	dst->value = sk->sk_lingertime / HZ;
 }
 
 META_COLLECTOR(int_sk_err_qlen)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = skb->sk->sk_error_queue.qlen;
+	dst->value = sk->sk_error_queue.qlen;
 }
 
 META_COLLECTOR(int_sk_ack_bl)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = skb->sk->sk_ack_backlog;
+	dst->value = sk->sk_ack_backlog;
 }
 
 META_COLLECTOR(int_sk_max_ack_bl)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = skb->sk->sk_max_ack_backlog;
+	dst->value = sk->sk_max_ack_backlog;
 }
 
 META_COLLECTOR(int_sk_prio)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = skb->sk->sk_priority;
+	dst->value = sk->sk_priority;
 }
 
 META_COLLECTOR(int_sk_rcvlowat)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = skb->sk->sk_rcvlowat;
+	dst->value = sk->sk_rcvlowat;
 }
 
 META_COLLECTOR(int_sk_rcvtimeo)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = skb->sk->sk_rcvtimeo / HZ;
+	dst->value = sk->sk_rcvtimeo / HZ;
 }
 
 META_COLLECTOR(int_sk_sndtimeo)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = skb->sk->sk_sndtimeo / HZ;
+	dst->value = sk->sk_sndtimeo / HZ;
 }
 
 META_COLLECTOR(int_sk_sendmsg_off)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = skb->sk->sk_frag.offset;
+	dst->value = sk->sk_frag.offset;
 }
 
 META_COLLECTOR(int_sk_write_pend)
 {
-	if (skip_nonlocal(skb)) {
+	const struct sock *sk = skb_to_full_sk(skb);
+
+	if (!sk) {
 		*err = -1;
 		return;
 	}
-	dst->value = skb->sk->sk_write_pending;
+	dst->value = sk->sk_write_pending;
 }
 
 /**************************************************************************
-- 
2.6.0.rc2.230.g3dd15c0
