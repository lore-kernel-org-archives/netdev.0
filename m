From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 6/6] netfilter: selinux: switch hook PFs to nfproto
Date: Mon, 14 May 2012 14:56:39 +0100
Message-ID: <1337003799-2517-6-git-send-email-alban.crequy@collabora.co.uk>
References: <1337003799-2517-1-git-send-email-alban.crequy@collabora.co.uk>
Cc: Vincent Sanders <vincent.sanders@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Alban Crequy <alban.crequy@collabora.co.uk>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.135.160]:48715 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755662Ab2ENN5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 09:57:40 -0400
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
 security/selinux/hooks.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index d85b793..1ab4d6b 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -5776,21 +5776,21 @@ static struct nf_hook_ops selinux_ipv4_ops[] = {
 	{
 		.hook =		selinux_ipv4_postroute,
 		.owner =	THIS_MODULE,
-		.pf =		PF_INET,
+		.pf =		NFPROTO_IPV4,
 		.hooknum =	NF_INET_POST_ROUTING,
 		.priority =	NF_IP_PRI_SELINUX_LAST,
 	},
 	{
 		.hook =		selinux_ipv4_forward,
 		.owner =	THIS_MODULE,
-		.pf =		PF_INET,
+		.pf =		NFPROTO_IPV4,
 		.hooknum =	NF_INET_FORWARD,
 		.priority =	NF_IP_PRI_SELINUX_FIRST,
 	},
 	{
 		.hook =		selinux_ipv4_output,
 		.owner =	THIS_MODULE,
-		.pf =		PF_INET,
+		.pf =		NFPROTO_IPV4,
 		.hooknum =	NF_INET_LOCAL_OUT,
 		.priority =	NF_IP_PRI_SELINUX_FIRST,
 	}
@@ -5802,14 +5802,14 @@ static struct nf_hook_ops selinux_ipv6_ops[] = {
 	{
 		.hook =		selinux_ipv6_postroute,
 		.owner =	THIS_MODULE,
-		.pf =		PF_INET6,
+		.pf =		NFPROTO_IPV6,
 		.hooknum =	NF_INET_POST_ROUTING,
 		.priority =	NF_IP6_PRI_SELINUX_LAST,
 	},
 	{
 		.hook =		selinux_ipv6_forward,
 		.owner =	THIS_MODULE,
-		.pf =		PF_INET6,
+		.pf =		NFPROTO_IPV6,
 		.hooknum =	NF_INET_FORWARD,
 		.priority =	NF_IP6_PRI_SELINUX_FIRST,
 	}
-- 
1.7.2.5
