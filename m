From: kaber@trash.net
Subject: [PATCH 6/8] netfilter: nf_ct_tcp: fix incorrect handling of invalid TCP option
Date: Tue, 30 Aug 2011 16:41:19 +0200
Message-ID: <1314715281-26233-7-git-send-email-kaber@trash.net>
References: <1314715281-26233-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56970 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754487Ab1H3Ol1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 10:41:27 -0400
In-Reply-To: <1314715281-26233-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Michael M. Builov reported that in the tcp_options and tcp_sack functions
of netfilter TCP conntrack the incorrect handling of invalid TCP option
with too big opsize may lead to read access beyond tcp-packet or buffer
allocated on stack (netfilter bugzilla #738). The fix is to stop parsing
the options at detecting the broken option.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_proto_tcp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 37bf943..afc4ab7 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -409,7 +409,7 @@ static void tcp_options(const struct sk_buff *skb,
 			if (opsize < 2) /* "silly options" */
 				return;
 			if (opsize > length)
-				break;	/* don't parse partial options */
+				return;	/* don't parse partial options */
 
 			if (opcode == TCPOPT_SACK_PERM
 			    && opsize == TCPOLEN_SACK_PERM)
@@ -469,7 +469,7 @@ static void tcp_sack(const struct sk_buff *skb, unsigned int dataoff,
 			if (opsize < 2) /* "silly options" */
 				return;
 			if (opsize > length)
-				break;	/* don't parse partial options */
+				return;	/* don't parse partial options */
 
 			if (opcode == TCPOPT_SACK
 			    && opsize >= (TCPOLEN_SACK_BASE
-- 
1.7.2.3
