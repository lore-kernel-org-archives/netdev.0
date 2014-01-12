From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net 1/2] tcp: delete redundant calls of tcp_mtup_init()
Date: Sun, 12 Jan 2014 15:54:30 +0800
Message-ID: <8164bb360e0970c6500368b6601ba5cadb154acf.1389513042.git.panweiping3@gmail.com>
References: <cover.1389513042.git.panweiping3@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63022 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751058AbaALH5F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 02:57:05 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0C7v5eR000570
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 02:57:05 -0500
Received: from localhost.localdomain.com (dhcp-17-97.nay.redhat.com [10.66.17.97])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id s0C7v2Vp005105
	for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 02:57:04 -0500
In-Reply-To: <cover.1389513042.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As both tcp_v4_syn_recv_sock() and tcp_v6_syn_recv_sock() already call
tcp_mtup_init() for new sock, the calls of it in tcp_rcv_state_process() and
tcp_v4_conn_req_fastopen() are redundant.

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 net/ipv4/tcp_input.c |    1 -
 net/ipv4/tcp_ipv4.c  |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c53b7f3..8add6bc 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5731,7 +5731,6 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 			icsk->icsk_af_ops->rebuild_header(sk);
 			tcp_init_congestion_control(sk);
 
-			tcp_mtup_init(sk);
 			tp->copied_seq = tp->rcv_nxt;
 			tcp_init_buffer_space(sk);
 		}
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0672139..6578047 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1410,7 +1410,6 @@ static int tcp_v4_conn_req_fastopen(struct sock *sk,
 	/* Now finish processing the fastopen child socket. */
 	inet_csk(child)->icsk_af_ops->rebuild_header(child);
 	tcp_init_congestion_control(child);
-	tcp_mtup_init(child);
 	tcp_init_metrics(child);
 	tcp_init_buffer_space(child);
 
-- 
1.7.4
