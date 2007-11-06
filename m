From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] NET : struct proto diet
Date: Mon, 05 Nov 2007 23:43:06 -0800 (PST)
Message-ID: <20071105.234306.200631818.davem@davemloft.net>
References: <472F5860.4010607@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55774
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754249AbXKFHnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 02:43:08 -0500
In-Reply-To: <472F5860.4010607@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 05 Nov 2007 18:52:32 +0100

> This patch series does some cleanup and optimization.
> 
> [PATCH 1/4] NET : defines an infrastructure to keep 'inuse' changes in 
> an efficent SMP/NUMA way.
> [PATCH 2/4] NET : makes ipv4 use the  {DEFINE|REF}_PROTO_INUSE 
> infrastructure
> [PATCH 3/4] NET : makes ipv6 use the  {DEFINE|REF}_PROTO_INUSE 
> infrastructure
> [PATCH 4/4] NET : makes sctp use the  {DEFINE|REF}_PROTO_INUSE 
> infrastructure

Applied, and because I love DCCP I added the following
patch on top.

>From 43d36c1ceff9ce1ed5a9ba87ea91a99f4f79ad00 Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@sunset.davemloft.net>
Date: Mon, 5 Nov 2007 23:42:25 -0800
Subject: [PATCH] [DCCP]: Use DEFINE_PROTO_INUSE infrastructure.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/dccp/ipv4.c |    3 +++
 net/dccp/ipv6.c |    3 +++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 01a6a80..db17b83 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -922,6 +922,8 @@ static struct timewait_sock_ops dccp_timewait_sock_ops = {
 	.twsk_obj_size	= sizeof(struct inet_timewait_sock),
 };
 
+DEFINE_PROTO_INUSE(dccp_v4)
+
 static struct proto dccp_v4_prot = {
 	.name			= "DCCP",
 	.owner			= THIS_MODULE,
@@ -950,6 +952,7 @@ static struct proto dccp_v4_prot = {
 	.compat_setsockopt	= compat_dccp_setsockopt,
 	.compat_getsockopt	= compat_dccp_getsockopt,
 #endif
+	REF_PROTO_INUSE(dccp_v4)
 };
 
 static struct net_protocol dccp_v4_protocol = {
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 62428ff..87c98fb 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1107,6 +1107,8 @@ static struct timewait_sock_ops dccp6_timewait_sock_ops = {
 	.twsk_obj_size	= sizeof(struct dccp6_timewait_sock),
 };
 
+DEFINE_PROTO_INUSE(dccp_v6)
+
 static struct proto dccp_v6_prot = {
 	.name		   = "DCCPv6",
 	.owner		   = THIS_MODULE,
@@ -1135,6 +1137,7 @@ static struct proto dccp_v6_prot = {
 	.compat_setsockopt = compat_dccp_setsockopt,
 	.compat_getsockopt = compat_dccp_getsockopt,
 #endif
+	REF_PROTO_INUSE(dccp_v6)
 };
 
 static struct inet6_protocol dccp_v6_protocol = {
-- 
1.5.3.5

