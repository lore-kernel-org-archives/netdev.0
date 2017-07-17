From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 03/10] net: xfrm: revert to lower xfrm dst gc limit
Date: Mon, 17 Jul 2017 13:57:20 +0200
Message-ID: <20170717115727.26042-4-fw@strlen.de>
References: <20170717115727.26042-1-fw@strlen.de>
Cc: steffen.klassert@secunet.com, ilant@mellanox.com,
        Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43908 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751326AbdGQL5S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 07:57:18 -0400
In-Reply-To: <20170717115727.26042-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

revert c386578f1cdb4dac230395 ("xfrm: Let the flowcache handle its size by default.").

Once we remove flow cache, we don't have a flow cache limit anymore.
We must not allow (virtually) unlimited allocations of xfrm dst entries.
Revert back to the old xfrm dst gc limits.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Documentation/networking/ip-sysctl.txt | 6 ++----
 net/ipv4/xfrm4_policy.c                | 2 +-
 net/ipv6/xfrm6_policy.c                | 2 +-
 3 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 974ab47ae53a..f485d553e65c 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1291,8 +1291,7 @@ tag - INTEGER
 xfrm4_gc_thresh - INTEGER
 	The threshold at which we will start garbage collecting for IPv4
 	destination cache entries.  At twice this value the system will
-	refuse new allocations. The value must be set below the flowcache
-	limit (4096 * number of online cpus) to take effect.
+	refuse new allocations.
 
 igmp_link_local_mcast_reports - BOOLEAN
 	Enable IGMP reports for link local multicast groups in the
@@ -1778,8 +1777,7 @@ ratelimit - INTEGER
 xfrm6_gc_thresh - INTEGER
 	The threshold at which we will start garbage collecting for IPv6
 	destination cache entries.  At twice this value the system will
-	refuse new allocations. The value must be set below the flowcache
-	limit (4096 * number of online cpus) to take effect.
+	refuse new allocations.
 
 
 IPv6 Update by:
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 71b4ecc195c7..19455a5fc328 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -266,7 +266,7 @@ static struct dst_ops xfrm4_dst_ops_template = {
 	.destroy =		xfrm4_dst_destroy,
 	.ifdown =		xfrm4_dst_ifdown,
 	.local_out =		__ip_local_out,
-	.gc_thresh =		INT_MAX,
+	.gc_thresh =		32768,
 };
 
 static const struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 79651bc71bf0..ae30dc4973e8 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -286,7 +286,7 @@ static struct dst_ops xfrm6_dst_ops_template = {
 	.destroy =		xfrm6_dst_destroy,
 	.ifdown =		xfrm6_dst_ifdown,
 	.local_out =		__ip6_local_out,
-	.gc_thresh =		INT_MAX,
+	.gc_thresh =		32768,
 };
 
 static const struct xfrm_policy_afinfo xfrm6_policy_afinfo = {
-- 
2.13.0
