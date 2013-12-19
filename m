From: Chen Weilong <chenweilong@huawei.com>
Subject: [patch net-next] ipv6: cleanup for tcp_ipv6.c
Date: Thu, 19 Dec 2013 18:44:34 +0800
Message-ID: <1387449874-7628-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:27089 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751627Ab3LSKpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 05:45:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

Fix some checkpatch errors for tcp_ipv6.c

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/ipv6/tcp_ipv6.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index d955487..2fd189f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -164,12 +164,12 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	 *	connect() to INADDR_ANY means loopback (BSD'ism).
 	 */
 
-	if(ipv6_addr_any(&usin->sin6_addr))
+	if (ipv6_addr_any(&usin->sin6_addr))
 		usin->sin6_addr.s6_addr[15] = 0x1;
 
 	addr_type = ipv6_addr_type(&usin->sin6_addr);
 
-	if(addr_type & IPV6_ADDR_MULTICAST)
+	if (addr_type & IPV6_ADDR_MULTICAST)
 		return -ENETUNREACH;
 
 	if (addr_type&IPV6_ADDR_LINKLOCAL) {
@@ -336,7 +336,7 @@ static void tcp_v6_mtu_reduced(struct sock *sk)
 static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		u8 type, u8 code, int offset, __be32 info)
 {
-	const struct ipv6hdr *hdr = (const struct ipv6hdr*)skb->data;
+	const struct ipv6hdr *hdr = (const struct ipv6hdr *)skb->data;
 	const struct tcphdr *th = (struct tcphdr *)(skb->data+offset);
 	struct ipv6_pinfo *np;
 	struct sock *sk;
@@ -469,7 +469,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct sk_buff * skb;
+	struct sk_buff *skb;
 	int err = -ENOMEM;
 
 	/* First, grab a route. */
@@ -912,7 +912,7 @@ static void tcp_v6_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 }
 
 
-static struct sock *tcp_v6_hnd_req(struct sock *sk,struct sk_buff *skb)
+static struct sock *tcp_v6_hnd_req(struct sock *sk, struct sk_buff *skb)
 {
 	struct request_sock *req, **prev;
 	const struct tcphdr *th = tcp_hdr(skb);
@@ -1085,9 +1085,9 @@ drop:
 	return 0; /* don't send reset */
 }
 
-static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
-					  struct request_sock *req,
-					  struct dst_entry *dst)
+static struct sock *tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
+					 struct request_sock *req,
+					 struct dst_entry *dst)
 {
 	struct inet_request_sock *ireq;
 	struct ipv6_pinfo *newnp, *np = inet6_sk(sk);
@@ -1382,7 +1382,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 		 * otherwise we just shortcircuit this and continue with
 		 * the new socket..
 		 */
-		if(nsk != sk) {
+		if (nsk != sk) {
 			sock_rps_save_rxhash(nsk, skb);
 			if (tcp_child_process(sk, nsk, skb))
 				goto reset;
@@ -1742,7 +1742,7 @@ static void get_openreq6(struct seq_file *seq,
 		   dest->s6_addr32[2], dest->s6_addr32[3],
 		   ntohs(inet_rsk(req)->ir_rmt_port),
 		   TCP_SYN_RECV,
-		   0,0, /* could print option size, but that is af dependent. */
+		   0, 0, /* could print option size, but that is af dependent. */
 		   1,   /* timers active (only the expire timer) */
 		   jiffies_to_clock_t(ttd),
 		   req->num_timeout,
@@ -1801,7 +1801,7 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 		   atomic_read(&sp->sk_refcnt), sp,
 		   jiffies_to_clock_t(icsk->icsk_rto),
 		   jiffies_to_clock_t(icsk->icsk_ack.ato),
-		   (icsk->icsk_ack.quick << 1 ) | icsk->icsk_ack.pingpong,
+		   (icsk->icsk_ack.quick << 1) | icsk->icsk_ack.pingpong,
 		   tp->snd_cwnd,
 		   tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh
 		   );
-- 
1.7.12
