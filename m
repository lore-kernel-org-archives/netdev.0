From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: sctp_probe: simplify code by using %pISc format specifier
Date: Thu, 22 Aug 2013 17:12:50 +0200
Message-ID: <1377184370-13721-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31473 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753217Ab3HVPMy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 11:12:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can simply use the %pISc format specifier that was recently added
and thus remove some code that distinguishes between IPv4 and IPv6.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/probe.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/sctp/probe.c b/net/sctp/probe.c
index e62c225..cd72ae5 100644
--- a/net/sctp/probe.c
+++ b/net/sctp/probe.c
@@ -155,13 +155,8 @@ static sctp_disposition_t jsctp_sf_eat_sack(struct net *net,
 			if (sp == asoc->peer.primary_path)
 				printl("*");
 
-			if (sp->ipaddr.sa.sa_family == AF_INET)
-				printl("%pI4 ", &sp->ipaddr.v4.sin_addr);
-			else
-				printl("%pI6 ", &sp->ipaddr.v6.sin6_addr);
-
-			printl("%2u %8u %8u %8u %8u %8u ",
-			       sp->state, sp->cwnd, sp->ssthresh,
+			printl("%pISc %2u %8u %8u %8u %8u %8u ",
+			       &sp->ipaddr, sp->state, sp->cwnd, sp->ssthresh,
 			       sp->flight_size, sp->partial_bytes_acked,
 			       sp->pathmtu);
 		}
-- 
1.7.11.7
