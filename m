From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Subject: [PATCH] netfilter: nf_nat_snmp_basic: fix duplicates in if/else branches
Date: Tue, 11 Feb 2014 15:49:25 +0100
Message-ID: <1392130165-4313-1-git-send-email-fx.lebail@yahoo.com>
To: NETDEV <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp05.smtpout.orange.fr ([80.12.242.127]:30669 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbaBKPTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 10:19:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The solution was found by Patrick in 2.4 kernel sources.

Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
---
 net/ipv4/netfilter/nf_nat_snmp_basic.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index d551e31..7c67667 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -1198,8 +1198,8 @@ static int snmp_translate(struct nf_conn *ct,
 		map.to = NOCT1(&ct->tuplehash[!dir].tuple.dst.u3.ip);
 	} else {
 		/* DNAT replies */
-		map.from = NOCT1(&ct->tuplehash[dir].tuple.src.u3.ip);
-		map.to = NOCT1(&ct->tuplehash[!dir].tuple.dst.u3.ip);
+		map.from = NOCT1(&ct->tuplehash[!dir].tuple.src.u3.ip);
+		map.to = NOCT1(&ct->tuplehash[dir].tuple.dst.u3.ip);
 	}
 
 	if (map.from == map.to)
