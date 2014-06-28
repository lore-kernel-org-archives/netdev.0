From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [PATCH net-next] tcp: tcp_conn_request: fix build error when IPv6 is disabled
Date: Sat, 28 Jun 2014 21:20:54 +0300
Message-ID: <1403979654-7738-1-git-send-email-octavian.purdila@intel.com>
Cc: netdev@vger.kernel.org,
	Octavian Purdila <octavian.purdila@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49184 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752015AbaF1SVH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Jun 2014 14:21:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes build error introduced by commit 1fb6f159fd21c64 (tcp: add
tcp_conn_request):

net/ipv4/tcp_input.c: In function 'pr_drop_req':
net/ipv4/tcp_input.c:5889:130: error: 'struct sock_common' has no member named 'skc_v6_daddr'

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
---
 net/ipv4/tcp_input.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 97e48d6..bb68496 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5885,9 +5885,11 @@ static inline void pr_drop_req(struct request_sock *req, __u16 port, int family)
 	if (family == AF_INET)
 		LIMIT_NETDEBUG(KERN_DEBUG pr_fmt("drop open request from %pI4/%u\n"),
 			       &ireq->ir_rmt_addr, port);
-	else
+#if IS_ENABLED(CONFIG_IPV6)
+	else if (family == AF_INET6)
 		LIMIT_NETDEBUG(KERN_DEBUG pr_fmt("drop open request from %pI6/%u\n"),
 			       &ireq->ir_v6_rmt_addr, port);
+#endif
 }
 
 int tcp_conn_request(struct request_sock_ops *rsk_ops,
-- 
1.8.3.2
