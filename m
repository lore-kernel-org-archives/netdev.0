From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH 2/2] ipv6: use sk_v6_copy_addrs when memcpy struct ipv6_pinfo
Date: Tue, 19 Nov 2013 10:47:27 +0800
Message-ID: <1384829247-8624-3-git-send-email-wangweidong1@huawei.com>
References: <1384829247-8624-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dccp@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>, <dingtianhong@huawei.com>
To: <davem@davemloft.net>, <gerrit@erg.abdn.ac.uk>,
	<kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<vyasevich@gmail.com>, <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:62936 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467Ab3KSCsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 21:48:52 -0500
In-Reply-To: <1384829247-8624-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit efe4208f ("ipv6: make lookups simpler and faster") remove
the daddr and rcv_saddr from struct ipv6_pinfo. When use memcpy
the ipv6_pinfo, we lose the sk_v6_daddr and sk_v6_rcv_saddr, so
use the sk_v6_copy_addrs when needed.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/dccp/ipv6.c     | 4 ++++
 net/ipv6/tcp_ipv6.c | 4 ++++
 net/sctp/ipv6.c     | 4 ++++
 3 files changed, 12 insertions(+)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 4ac71ff..90182a8 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -465,6 +465,10 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 		newnp = inet6_sk(newsk);
 
 		memcpy(newnp, np, sizeof(struct ipv6_pinfo));
+		/* Don't forget copy the rcv_saddr and daddr when
+		 * copy ipv6_pinfo.
+		 */
+		sk_v6_copy_addrs(newsk, sk);
 
 		ipv6_addr_set_v4mapped(newinet->inet_daddr, &newsk->sk_v6_daddr);
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 0740f93..83d011e 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1116,6 +1116,10 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		newtp = tcp_sk(newsk);
 
 		memcpy(newnp, np, sizeof(struct ipv6_pinfo));
+		/* Don't forget copy the rcv_saddr and daddr when
+		 * copy ipv6_pinfo.
+		 */
+		sk_v6_copy_addrs(newsk, sk);
 
 		ipv6_addr_set_v4mapped(newinet->inet_daddr, &newsk->sk_v6_daddr);
 
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 7567e6f..b76f143 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -656,6 +656,10 @@ static struct sock *sctp_v6_create_accept_sk(struct sock *sk,
 	newnp = inet6_sk(newsk);
 
 	memcpy(newnp, np, sizeof(struct ipv6_pinfo));
+	/* Don't forget copy the rcv_saddr and daddr when
+	 * copy ipv6_pinfo.
+	 */
+	sk_v6_copy_addrs(newsk, sk);
 
 	/* Initialize sk's sport, dport, rcv_saddr and daddr for getsockname()
 	 * and getpeername().
-- 
1.7.12
