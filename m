From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH] ipv6: nullify ipv6_ac_list and ipv6_fl_list when creating
 new socket
Date: Sun, 25 Sep 2011 20:21:30 +0800
Message-ID: <4E7F1CCA.5000104@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:47064 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752376Ab1IYMVd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Sep 2011 08:21:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6_ac_list and ipv6_fl_list from listening socket are inadvertently
shared with new socket created for connection.

Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
---
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3c9fa61..79cc646 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1383,6 +1383,8 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		newtp->af_specific = &tcp_sock_ipv6_mapped_specific;
 #endif
 
+		newnp->ipv6_ac_list = NULL;
+		newnp->ipv6_fl_list = NULL;
 		newnp->pktoptions  = NULL;
 		newnp->opt	   = NULL;
 		newnp->mcast_oif   = inet6_iif(skb);
@@ -1447,6 +1449,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	   First: no IPv4 options.
 	 */
 	newinet->inet_opt = NULL;
+	newnp->ipv6_ac_list = NULL;
 	newnp->ipv6_fl_list = NULL;
 
 	/* Clone RX bits */
