From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH net-next v2 1/2] net: tcp_ipv6 do some cleanup
Date: Mon, 24 Mar 2014 09:36:00 +0800
Message-ID: <1395624961-10128-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wang Yufen <wangyufen@huawei.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:51046 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917AbaCXBgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2014 21:36:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Yufen <wangyufen@huawei.com>


Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 net/ipv6/tcp_ipv6.c | 22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3277680..f6f38fe 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -39,7 +39,7 @@
 #include <linux/ipsec.h>
 #include <linux/times.h>
 #include <linux/slab.h>
-
+#include <linux/uaccess.h>
 #include <linux/ipv6.h>
 #include <linux/icmpv6.h>
 #include <linux/random.h>
@@ -65,8 +65,6 @@
 #include <net/tcp_memcontrol.h>
 #include <net/busy_poll.h>
 
-#include <asm/uaccess.h>
-
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 
@@ -532,7 +530,7 @@ static struct tcp_md5sig_key *tcp_v6_reqsk_md5_lookup(struct sock *sk,
 	return tcp_v6_md5_do_lookup(sk, &inet_rsk(req)->ir_v6_rmt_addr);
 }
 
-static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
+static int tcp_v6_parse_md5_keys(struct sock *sk, char __user *optval,
 				  int optlen)
 {
 	struct tcp_md5sig cmd;
@@ -717,7 +715,7 @@ struct request_sock_ops tcp6_request_sock_ops __read_mostly = {
 	.send_ack	=	tcp_v6_reqsk_send_ack,
 	.destructor	=	tcp_v6_reqsk_destructor,
 	.send_reset	=	tcp_v6_send_reset,
-	.syn_ack_timeout = 	tcp_syn_ack_timeout,
+	.syn_ack_timeout =	tcp_syn_ack_timeout,
 };
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -1261,7 +1259,8 @@ static struct sock *tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Copy over the MD5 key from the original socket */
-	if ((key = tcp_v6_md5_do_lookup(sk, &newsk->sk_v6_daddr)) != NULL) {
+	key = tcp_v6_md5_do_lookup(sk, &newsk->sk_v6_daddr);
+	if (key != NULL) {
 		/* We're using one, so create a matching key
 		 * on the newsk structure. If we fail to get
 		 * memory, then we end up not copying the key
@@ -1305,9 +1304,8 @@ static __sum16 tcp_v6_checksum_init(struct sk_buff *skb)
 					      &ipv6_hdr(skb)->saddr,
 					      &ipv6_hdr(skb)->daddr, 0));
 
-	if (skb->len <= 76) {
+	if (skb->len <= 76)
 		return __skb_checksum_complete(skb);
-	}
 	return 0;
 }
 
@@ -1337,7 +1335,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 		return tcp_v4_do_rcv(sk, skb);
 
 #ifdef CONFIG_TCP_MD5SIG
-	if (tcp_v6_inbound_md5_hash (sk, skb))
+	if (tcp_v6_inbound_md5_hash(sk, skb))
 		goto discard;
 #endif
 
@@ -1604,7 +1602,8 @@ do_time_wait:
 		break;
 	case TCP_TW_RST:
 		goto no_tcp_socket;
-	case TCP_TW_SUCCESS:;
+	case TCP_TW_SUCCESS:
+		;
 	}
 	goto discard_it;
 }
@@ -1649,7 +1648,7 @@ static void tcp_v6_early_demux(struct sk_buff *skb)
 static struct timewait_sock_ops tcp6_timewait_sock_ops = {
 	.twsk_obj_size	= sizeof(struct tcp6_timewait_sock),
 	.twsk_unique	= tcp_twsk_unique,
-	.twsk_destructor= tcp_twsk_destructor,
+	.twsk_destructor = tcp_twsk_destructor,
 };
 
 static const struct inet_connection_sock_af_ops ipv6_specific = {
@@ -1683,7 +1682,6 @@ static const struct tcp_sock_af_ops tcp_sock_ipv6_specific = {
 /*
  *	TCP over IPv4 via INET6 API
  */
-
 static const struct inet_connection_sock_af_ops ipv6_mapped = {
 	.queue_xmit	   = ip_queue_xmit,
 	.send_check	   = tcp_v4_send_check,
-- 
1.7.12
