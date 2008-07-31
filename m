From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] inet6: Fix paramater issue of inet6_csk_xmit
Date: Thu, 31 Jul 2008 17:56:25 +0800
Message-ID: <48918C49.4070708@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53713 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752705AbYGaJ6L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2008 05:58:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet6_csk_xmit() has a paramater ipfragok, but never pass to
ip6_xmit(), always call it with ipfragok = 0.

This patch fixed this problem by instead 0 of ipfragok.

Compiled test only.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/ipv6/inet6_connection_sock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 87801cc..2b5e1fb 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -233,7 +233,7 @@ int inet6_csk_xmit(struct sk_buff *skb, int ipfragok)
 	/* Restore final destination back after routing done */
 	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
 
-	return ip6_xmit(sk, skb, &fl, np->opt, 0);
+	return ip6_xmit(sk, skb, &fl, np->opt, ipfragok);
 }
 
 EXPORT_SYMBOL_GPL(inet6_csk_xmit);
-- 
1.5.3.8



