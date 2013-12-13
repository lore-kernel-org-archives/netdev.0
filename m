From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/2] netfilter: SYNPROXY target: restrict to INPUT/FORWARD
Date: Fri, 13 Dec 2013 19:24:58 +0100
Message-ID: <1386959099-24582-2-git-send-email-pablo@netfilter.org>
References: <1386959099-24582-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49741 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752612Ab3LMSZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Dec 2013 13:25:08 -0500
In-Reply-To: <1386959099-24582-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Fix a crash in synproxy_send_tcp() when using the SYNPROXY target in the
PREROUTING chain caused by missing routing information.

Reported-by: Nicki P. <xastx@gmx.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_SYNPROXY.c  |    1 +
 net/ipv6/netfilter/ip6t_SYNPROXY.c |    1 +
 2 files changed, 2 insertions(+)

diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index f13bd91..a313c3f 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -423,6 +423,7 @@ static void synproxy_tg4_destroy(const struct xt_tgdtor_param *par)
 static struct xt_target synproxy_tg4_reg __read_mostly = {
 	.name		= "SYNPROXY",
 	.family		= NFPROTO_IPV4,
+	.hooks		= (1 << NF_INET_LOCAL_IN) | (1 << NF_INET_FORWARD),
 	.target		= synproxy_tg4,
 	.targetsize	= sizeof(struct xt_synproxy_info),
 	.checkentry	= synproxy_tg4_check,
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index f78f41a..a0d1727 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -446,6 +446,7 @@ static void synproxy_tg6_destroy(const struct xt_tgdtor_param *par)
 static struct xt_target synproxy_tg6_reg __read_mostly = {
 	.name		= "SYNPROXY",
 	.family		= NFPROTO_IPV6,
+	.hooks		= (1 << NF_INET_LOCAL_IN) | (1 << NF_INET_FORWARD),
 	.target		= synproxy_tg6,
 	.targetsize	= sizeof(struct xt_synproxy_info),
 	.checkentry	= synproxy_tg6_check,
-- 
1.7.10.4
