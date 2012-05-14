From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 5/6] netfilter: ipvs: switch hook PFs to nfproto
Date: Mon, 14 May 2012 14:56:38 +0100
Message-ID: <1337003799-2517-5-git-send-email-alban.crequy@collabora.co.uk>
References: <1337003799-2517-1-git-send-email-alban.crequy@collabora.co.uk>
Cc: Vincent Sanders <vincent.sanders@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Alban Crequy <alban.crequy@collabora.co.uk>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.135.160]:48700 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756807Ab2ENN5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 09:57:15 -0400
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
 net/netfilter/ipvs/ip_vs_core.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 00bdb1d..d1c6a77 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1768,7 +1768,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_reply4,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_NAT_SRC - 2,
 	},
@@ -1778,7 +1778,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_remote_request4,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_NAT_SRC - 1,
 	},
@@ -1786,7 +1786,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_local_reply4,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP_PRI_NAT_DST + 1,
 	},
@@ -1794,7 +1794,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_local_request4,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP_PRI_NAT_DST + 2,
 	},
@@ -1803,7 +1803,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_forward_icmp,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= 99,
 	},
@@ -1811,7 +1811,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_reply4,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= 100,
 	},
@@ -1820,7 +1820,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_reply6,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_NAT_SRC - 2,
 	},
@@ -1830,7 +1830,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_remote_request6,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_NAT_SRC - 1,
 	},
@@ -1838,7 +1838,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_local_reply6,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_NAT_DST + 1,
 	},
@@ -1846,7 +1846,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_local_request6,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_NAT_DST + 2,
 	},
@@ -1855,7 +1855,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_forward_icmp_v6,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= 99,
 	},
@@ -1863,7 +1863,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_reply6,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= 100,
 	},
-- 
1.7.2.5
