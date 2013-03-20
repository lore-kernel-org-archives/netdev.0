From: pablo@netfilter.org
Subject: [PATCH 3/7] netfilter: ip6t_NPT: restrict to mangle table
Date: Wed, 20 Mar 2013 11:49:30 +0100
Message-ID: <1363776574-4766-4-git-send-email-pablo@netfilter.org>
References: <1363776574-4766-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51279 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752620Ab3CTKtu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Mar 2013 06:49:50 -0400
In-Reply-To: <1363776574-4766-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

As the translation is stateless, using it in nat table
doesn't work (only initial packet is translated).
filter table OUTPUT works but won't re-route the packet after translation.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/ip6t_NPT.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/netfilter/ip6t_NPT.c b/net/ipv6/netfilter/ip6t_NPT.c
index 83acc14..33608c6 100644
--- a/net/ipv6/netfilter/ip6t_NPT.c
+++ b/net/ipv6/netfilter/ip6t_NPT.c
@@ -114,6 +114,7 @@ ip6t_dnpt_tg(struct sk_buff *skb, const struct xt_action_param *par)
 static struct xt_target ip6t_npt_target_reg[] __read_mostly = {
 	{
 		.name		= "SNPT",
+		.table		= "mangle",
 		.target		= ip6t_snpt_tg,
 		.targetsize	= sizeof(struct ip6t_npt_tginfo),
 		.checkentry	= ip6t_npt_checkentry,
@@ -124,6 +125,7 @@ static struct xt_target ip6t_npt_target_reg[] __read_mostly = {
 	},
 	{
 		.name		= "DNPT",
+		.table		= "mangle",
 		.target		= ip6t_dnpt_tg,
 		.targetsize	= sizeof(struct ip6t_npt_tginfo),
 		.checkentry	= ip6t_npt_checkentry,
-- 
1.7.10.4
