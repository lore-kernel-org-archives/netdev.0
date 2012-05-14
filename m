From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 4/6] netfilter: ipv4, defrag: switch hook PFs to nfproto
Date: Mon, 14 May 2012 14:56:37 +0100
Message-ID: <1337003799-2517-4-git-send-email-alban.crequy@collabora.co.uk>
References: <1337003799-2517-1-git-send-email-alban.crequy@collabora.co.uk>
Cc: Vincent Sanders <vincent.sanders@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Alban Crequy <alban.crequy@collabora.co.uk>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.135.160]:48694 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756807Ab2ENN5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 09:57:12 -0400
In-Reply-To: <1337003799-2517-1-git-send-email-alban.crequy@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NFPROTO_* constants were usually equal to PF_* constants but it is not
necessary and it will waste less memory if we don't do so (see commit 7e9c6e
"netfilter: Introduce NFPROTO_* constants")

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
Reviewed-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Reviewed-by: Vincent Sanders <vincent.sanders@collabora.co.uk>
---
 net/ipv4/netfilter/nf_defrag_ipv4.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index 9bb1b8a..7428155 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -94,14 +94,14 @@ static struct nf_hook_ops ipv4_defrag_ops[] = {
 	{
 		.hook		= ipv4_conntrack_defrag,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP_PRI_CONNTRACK_DEFRAG,
 	},
 	{
 		.hook           = ipv4_conntrack_defrag,
 		.owner          = THIS_MODULE,
-		.pf             = PF_INET,
+		.pf             = NFPROTO_IPV4,
 		.hooknum        = NF_INET_LOCAL_OUT,
 		.priority       = NF_IP_PRI_CONNTRACK_DEFRAG,
 	},
-- 
1.7.2.5
