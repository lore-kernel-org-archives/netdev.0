From: pablo@netfilter.org
Subject: [PATCH 3/4] netfilter: xt_nat: fix incorrect hooks for SNAT and DNAT targets
Date: Wed, 17 Oct 2012 12:40:10 +0200
Message-ID: <1350470411-5793-3-git-send-email-pablo@netfilter.org>
References: <1350470411-5793-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46880 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756525Ab2JQKk0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2012 06:40:26 -0400
In-Reply-To: <1350470411-5793-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elison Niven <elison.niven@cyberoam.com>

In (c7232c9 netfilter: add protocol independent NAT core), the
hooks were accidentally modified:

SNAT hooks are POST_ROUTING and LOCAL_IN (before it was LOCAL_OUT).
DNAT hooks are PRE_ROUTING and LOCAL_OUT (before it was LOCAL_IN).

Signed-off-by: Elison Niven <elison.niven@cyberoam.com>
Signed-off-by: Sanket Shah <sanket.shah@cyberoam.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_nat.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/xt_nat.c b/net/netfilter/xt_nat.c
index 81aafa8..bea7464 100644
--- a/net/netfilter/xt_nat.c
+++ b/net/netfilter/xt_nat.c
@@ -111,7 +111,7 @@ static struct xt_target xt_nat_target_reg[] __read_mostly = {
 		.family		= NFPROTO_IPV4,
 		.table		= "nat",
 		.hooks		= (1 << NF_INET_POST_ROUTING) |
-				  (1 << NF_INET_LOCAL_OUT),
+				  (1 << NF_INET_LOCAL_IN),
 		.me		= THIS_MODULE,
 	},
 	{
@@ -123,7 +123,7 @@ static struct xt_target xt_nat_target_reg[] __read_mostly = {
 		.family		= NFPROTO_IPV4,
 		.table		= "nat",
 		.hooks		= (1 << NF_INET_PRE_ROUTING) |
-				  (1 << NF_INET_LOCAL_IN),
+				  (1 << NF_INET_LOCAL_OUT),
 		.me		= THIS_MODULE,
 	},
 	{
@@ -133,7 +133,7 @@ static struct xt_target xt_nat_target_reg[] __read_mostly = {
 		.targetsize	= sizeof(struct nf_nat_range),
 		.table		= "nat",
 		.hooks		= (1 << NF_INET_POST_ROUTING) |
-				  (1 << NF_INET_LOCAL_OUT),
+				  (1 << NF_INET_LOCAL_IN),
 		.me		= THIS_MODULE,
 	},
 	{
@@ -143,7 +143,7 @@ static struct xt_target xt_nat_target_reg[] __read_mostly = {
 		.targetsize	= sizeof(struct nf_nat_range),
 		.table		= "nat",
 		.hooks		= (1 << NF_INET_PRE_ROUTING) |
-				  (1 << NF_INET_LOCAL_IN),
+				  (1 << NF_INET_LOCAL_OUT),
 		.me		= THIS_MODULE,
 	},
 };
-- 
1.7.10.4
