From: Kim Nordlund <Kim.Nordlund@nokia.com>
Subject: [PATCH] [IPV6] Make fib6_node subtree depend on IPV6_SUBTREES
Date: Wed, 13 Dec 2006 17:03:26 +0200 (EET)
Message-ID: <Pine.LNX.4.44.0612131627580.4046-100000@dhcp09282.ntc.nokia.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([131.228.20.172]:42910 "EHLO
	mgw-ext13.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964995AbWLMPiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 10:38:23 -0500
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Make fib6_node 'subtree' depend on IPV6_SUBTREES.

Signed-off-by: Kim Nordlund <kim.nordlund@nokia.com>

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index f9cde44..7be4f4e 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -50,9 +50,9 @@ struct fib6_node
 	struct fib6_node	*parent;
 	struct fib6_node	*left;
 	struct fib6_node	*right;
-
+#ifdef CONFIG_IPV6_SUBTREES
 	struct fib6_node	*subtree;
-
+#endif
 	struct rt6_info		*leaf;
 
 	__u16			fn_bit;		/* bit key */
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 9f80518..8c3d568 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -494,7 +494,7 @@ do { \
 				goto out; \
 			pn = fn->parent; \
 			if (FIB6_SUBTREE(pn) && FIB6_SUBTREE(pn) != fn) \
-				fn = fib6_lookup(pn->subtree, NULL, saddr); \
+				fn = fib6_lookup(FIB6_SUBTREE(pn), NULL, saddr); \
 			else \
 				fn = pn; \
 			if (fn->fn_flags & RTN_RTINFO) \

