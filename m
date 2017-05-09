From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] ipv6/dccp: do not inherit ipv6_mc_list from parent
Date: Tue,  9 May 2017 16:59:54 -0700
Message-ID: <1494374394-24373-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: edumazet@google.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36603 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750734AbdEJAAX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 20:00:23 -0400
Received: by mail-pg0-f67.google.com with SMTP id 64so1797331pgb.3
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 17:00:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Like commit 657831ffc38e ("dccp/tcp: do not inherit mc_list from parent")
we should clear ipv6_mc_list etc. for IPv6 sockets too.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/dccp/ipv6.c     | 6 ++++++
 net/ipv6/tcp_ipv6.c | 2 ++
 2 files changed, 8 insertions(+)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index d9b6a4e..b6bbb71 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -426,6 +426,9 @@ static struct sock *dccp_v6_request_recv_sock(const struct sock *sk,
 		newsk->sk_backlog_rcv = dccp_v4_do_rcv;
 		newnp->pktoptions  = NULL;
 		newnp->opt	   = NULL;
+		newnp->ipv6_mc_list = NULL;
+		newnp->ipv6_ac_list = NULL;
+		newnp->ipv6_fl_list = NULL;
 		newnp->mcast_oif   = inet6_iif(skb);
 		newnp->mcast_hops  = ipv6_hdr(skb)->hop_limit;
 
@@ -490,6 +493,9 @@ static struct sock *dccp_v6_request_recv_sock(const struct sock *sk,
 	/* Clone RX bits */
 	newnp->rxopt.all = np->rxopt.all;
 
+	newnp->ipv6_mc_list = NULL;
+	newnp->ipv6_ac_list = NULL;
+	newnp->ipv6_fl_list = NULL;
 	newnp->pktoptions = NULL;
 	newnp->opt	  = NULL;
 	newnp->mcast_oif  = inet6_iif(skb);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index aeb9497..df5a9ff 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1062,6 +1062,7 @@ static struct sock *tcp_v6_syn_recv_sock(const struct sock *sk, struct sk_buff *
 		newtp->af_specific = &tcp_sock_ipv6_mapped_specific;
 #endif
 
+		newnp->ipv6_mc_list = NULL;
 		newnp->ipv6_ac_list = NULL;
 		newnp->ipv6_fl_list = NULL;
 		newnp->pktoptions  = NULL;
@@ -1131,6 +1132,7 @@ static struct sock *tcp_v6_syn_recv_sock(const struct sock *sk, struct sk_buff *
 	   First: no IPv4 options.
 	 */
 	newinet->inet_opt = NULL;
+	newnp->ipv6_mc_list = NULL;
 	newnp->ipv6_ac_list = NULL;
 	newnp->ipv6_fl_list = NULL;
 
-- 
2.5.5
