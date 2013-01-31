From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH net v2] tcp: Update MIB counters for drops
Date: Thu, 31 Jan 2013 10:24:06 -0800
Message-ID: <1359656646-29339-1-git-send-email-subramanian.vijay@gmail.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	niveditasinghvi@gmail.com,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:47244 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930Ab3AaSYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 13:24:16 -0500
Received: by mail-pb0-f47.google.com with SMTP id rp8so1730559pbb.20
        for <netdev@vger.kernel.org>; Thu, 31 Jan 2013 10:24:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates LINUX_MIB_LISTENDROPS in tcp_v4_conn_request() and
tcp_v4_err(). tcp_v4_conn_request() in particular can drop SYNs for various
reasons which are not currently tracked.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
Changes from V1: Removed one needless update to ListenOverflows.

 net/ipv4/tcp_ipv4.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 629937d..eadb693 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -496,6 +496,7 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 		 * errors returned from accept().
 		 */
 		inet_csk_reqsk_queue_drop(sk, req, prev);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 		goto out;
 
 	case TCP_SYN_SENT:
@@ -1502,7 +1503,6 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	 */
 	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1) {
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 		goto drop;
 	}
 
@@ -1669,6 +1669,7 @@ drop_and_release:
 drop_and_free:
 	reqsk_free(req);
 drop:
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 	return 0;
 }
 EXPORT_SYMBOL(tcp_v4_conn_request);
-- 
1.7.0.4
