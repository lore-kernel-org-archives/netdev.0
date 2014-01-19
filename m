From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net v2] tcp: delete redundant calls of tcp_mtup_init()
Date: Sun, 19 Jan 2014 20:44:46 +0800
Message-ID: <1a8e9e92721ef792aa017b89a4d6376dca5dc4f6.1390135376.git.panweiping3@gmail.com>
References: <20140114.164105.524133214769947013.davem@davemloft.net>
Cc: Weiping Pan <panweiping3@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:54767 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614AbaASMox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 07:44:53 -0500
Received: by mail-pa0-f42.google.com with SMTP id kl14so5992817pab.1
        for <netdev@vger.kernel.org>; Sun, 19 Jan 2014 04:44:53 -0800 (PST)
In-Reply-To: <20140114.164105.524133214769947013.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As tcp_rcv_state_process() has already calls tcp_mtup_init() for non-fastopen
sock, we can delete the redundant calls of tcp_mtup_init() in
tcp_{v4,v6}_syn_recv_sock().

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 net/ipv4/tcp_ipv4.c |    1 -
 net/ipv6/tcp_ipv6.c |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0672139..4176606 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1668,7 +1668,6 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	}
 	sk_setup_caps(newsk, dst);
 
-	tcp_mtup_init(newsk);
 	tcp_sync_mss(newsk, dst_mtu(dst));
 	newtp->advmss = dst_metric_advmss(dst);
 	if (tcp_sk(sk)->rx_opt.user_mss &&
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f67033b..c5b0e1f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1230,7 +1230,6 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		inet_csk(newsk)->icsk_ext_hdr_len = (newnp->opt->opt_nflen +
 						     newnp->opt->opt_flen);
 
-	tcp_mtup_init(newsk);
 	tcp_sync_mss(newsk, dst_mtu(dst));
 	newtp->advmss = dst_metric_advmss(dst);
 	if (tcp_sk(sk)->rx_opt.user_mss &&
-- 
1.7.4.4
