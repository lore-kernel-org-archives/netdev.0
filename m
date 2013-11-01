From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/3] xfrm: Increase the garbage collector threshold
Date: Fri,  1 Nov 2013 09:21:46 +0100
Message-ID: <1383294107-7509-3-git-send-email-steffen.klassert@secunet.com>
References: <1383294107-7509-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49479 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753656Ab3KAIVy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 04:21:54 -0400
In-Reply-To: <1383294107-7509-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the removal of the routing cache, we lost the
option to tweak the garbage collector threshold
along with the maximum routing cache size. So git
commit 703fb94ec ("xfrm: Fix the gc threshold value
for ipv4") moved back to a static threshold.

It turned out that the current threshold before we
start garbage collecting is much to small for some
workloads, so increase it from 1024 to 32768. This
means that we start the garbage collector if we have
more than 32768 dst entries in the system and refuse
new allocations if we are above 65536.

Reported-by: Wolfgang Walter <linux@stwm.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/xfrm4_policy.c |    2 +-
 net/ipv6/xfrm6_policy.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index ccde542..4764ee4 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -236,7 +236,7 @@ static struct dst_ops xfrm4_dst_ops = {
 	.destroy =		xfrm4_dst_destroy,
 	.ifdown =		xfrm4_dst_ifdown,
 	.local_out =		__ip_local_out,
-	.gc_thresh =		1024,
+	.gc_thresh =		32768,
 };
 
 static struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 08ed277..dd503a3 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -285,7 +285,7 @@ static struct dst_ops xfrm6_dst_ops = {
 	.destroy =		xfrm6_dst_destroy,
 	.ifdown =		xfrm6_dst_ifdown,
 	.local_out =		__ip6_local_out,
-	.gc_thresh =		1024,
+	.gc_thresh =		32768,
 };
 
 static struct xfrm_policy_afinfo xfrm6_policy_afinfo = {
-- 
1.7.9.5
