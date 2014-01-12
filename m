From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net 2/2] tcp: delete redundant call of tcp_initialize_rcv_mss()
Date: Sun, 12 Jan 2014 15:54:31 +0800
Message-ID: <562fd95c0cf9a70789fca00e97e06035b94a7fb4.1389513042.git.panweiping3@gmail.com>
References: <cover.1389513042.git.panweiping3@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16602 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751017AbaALH5G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 02:57:06 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0C7v6Ft002110
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 02:57:06 -0500
Received: from localhost.localdomain.com (dhcp-17-97.nay.redhat.com [10.66.17.97])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id s0C7v2Vq005105
	for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 02:57:05 -0500
In-Reply-To: <cover.1389513042.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As both tcp_v4_syn_recv_sock() and tcp_v6_syn_recv_sock() already call
tcp_initialize_rcv_mss() for new sock, the call of it in tcp_rcv_state_process()
is redundant.

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 net/ipv4/tcp_input.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 8add6bc..8a2b5c7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5771,7 +5771,6 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		/* Prevent spurious tcp_cwnd_restart() on first data packet */
 		tp->lsndtime = tcp_time_stamp;
 
-		tcp_initialize_rcv_mss(sk);
 		tcp_fast_path_on(tp);
 		break;
 
-- 
1.7.4
