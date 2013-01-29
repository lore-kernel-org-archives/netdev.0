From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 1/5] ipv6 mcast: Use ipv6_addr_equal() in ip6_mc_source().
Date: Wed, 30 Jan 2013 07:48:23 +0900
Message-ID: <510851B7.3020407@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:54612 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751690Ab3A2WsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 17:48:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/mcast.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index f25002a..8460a1f 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -376,8 +376,7 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 			goto done;	/* err = -EADDRNOTAVAIL */
 		rv = !0;
 		for (i=0; i<psl->sl_count; i++) {
-			rv = memcmp(&psl->sl_addr[i], source,
-				sizeof(struct in6_addr));
+			rv = !ipv6_addr_equal(&psl->sl_addr[i], source);
 			if (rv == 0)
 				break;
 		}
@@ -427,7 +426,7 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 	}
 	rv = 1;	/* > 0 for insert logic below if sl_count is 0 */
 	for (i=0; i<psl->sl_count; i++) {
-		rv = memcmp(&psl->sl_addr[i], source, sizeof(struct in6_addr));
+		rv = !ipv6_addr_equal(&psl->sl_addr[i], source);
 		if (rv == 0)
 			break;
 	}
-- 
1.7.9.5
