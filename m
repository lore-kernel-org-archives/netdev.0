From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] ipv6: fib: Restore NTF_ROUTER exception in fib6_age()
Date: Thu,  7 Jun 2012 18:51:04 +0200
Message-ID: <6e43964ac82665f0257ac4f53c17b3b3403edcc3.1339087863.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28259 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759769Ab2FGQvJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2012 12:51:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 5339ab8b1dd82 (ipv6: fib: Convert fib6_age() to
dst_neigh_lookup().) seems to have mistakenly inverted the
exception for cached NTF_ROUTER routes.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/ipv6/ip6_fib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 0c220a4..74c21b9 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1561,7 +1561,7 @@ static int fib6_age(struct rt6_info *rt, void *arg)
 				neigh_flags = neigh->flags;
 				neigh_release(neigh);
 			}
-			if (neigh_flags & NTF_ROUTER) {
+			if (!(neigh_flags & NTF_ROUTER)) {
 				RT6_TRACE("purging route %p via non-router but gateway\n",
 					  rt);
 				return -1;
-- 
1.7.7.6
