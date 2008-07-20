From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6 4/4] ipv6 mcast: Omit redundant address family
 checks in ip6_mc_source().
Date: Sun, 20 Jul 2008 14:21:40 +0900 (JST)
Message-ID: <20080720.142140.12577519.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32825 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444AbYGTFVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 01:21:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The caller has alredy checked for them.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/mcast.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 1b28537..e7c03bc 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -367,10 +367,6 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 	int pmclocked = 0;
 	int err;
 
-	if (pgsr->gsr_group.ss_family != AF_INET6 ||
-	    pgsr->gsr_source.ss_family != AF_INET6)
-		return -EINVAL;
-
 	source = &((struct sockaddr_in6 *)&pgsr->gsr_source)->sin6_addr;
 	group = &((struct sockaddr_in6 *)&pgsr->gsr_group)->sin6_addr;
 
-- 
1.4.4.4

