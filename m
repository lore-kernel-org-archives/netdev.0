From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/6] netfilter: nf_nat_snmp_basic: fix duplicates in if/else branches
Date: Wed, 19 Feb 2014 12:41:39 +0100
Message-ID: <1392810102-13877-4-git-send-email-pablo@netfilter.org>
References: <1392810102-13877-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44990 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752757AbaBSLlz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Feb 2014 06:41:55 -0500
In-Reply-To: <1392810102-13877-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: FX Le Bail <fx.lebail@yahoo.com>

The solution was found by Patrick in 2.4 kernel sources.

Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Acked-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
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
-- 
1.7.10.4
