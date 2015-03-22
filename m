From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/6] netfilter: nft_compat: set IP6T_F_PROTO flag if protocol is set
Date: Sun, 22 Mar 2015 19:46:38 +0100
Message-ID: <1427049998-5665-7-git-send-email-pablo@netfilter.org>
References: <1427049998-5665-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33405 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751896AbbCVSmv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Mar 2015 14:42:51 -0400
In-Reply-To: <1427049998-5665-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip6tables extensions check for this flag to restrict match/target to a
given protocol. Without this flag set, SYNPROXY6 returns an error.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nft_compat.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index 213584c..65f3e2b 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -133,6 +133,9 @@ nft_target_set_tgchk_param(struct xt_tgchk_param *par,
 		entry->e4.ip.invflags = inv ? IPT_INV_PROTO : 0;
 		break;
 	case AF_INET6:
+		if (proto)
+			entry->e6.ipv6.flags |= IP6T_F_PROTO;
+
 		entry->e6.ipv6.proto = proto;
 		entry->e6.ipv6.invflags = inv ? IP6T_INV_PROTO : 0;
 		break;
@@ -344,6 +347,9 @@ nft_match_set_mtchk_param(struct xt_mtchk_param *par, const struct nft_ctx *ctx,
 		entry->e4.ip.invflags = inv ? IPT_INV_PROTO : 0;
 		break;
 	case AF_INET6:
+		if (proto)
+			entry->e6.ipv6.flags |= IP6T_F_PROTO;
+
 		entry->e6.ipv6.proto = proto;
 		entry->e6.ipv6.invflags = inv ? IP6T_INV_PROTO : 0;
 		break;
-- 
1.7.10.4
