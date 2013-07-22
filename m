From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next] net: ipv6 eliminate parameter "int addrlen" in function fib6_add_1
Date: Mon, 22 Jul 2013 14:21:09 +0800
Message-ID: <1374474069-22675-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yoshfuji@linux-ipv6.org>, <jmorris@namei.org>,
	<hannes@stressinduktion.org>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:40763 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754495Ab3GVGVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 02:21:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "int addrlen" in fib6_add_1 is rebundant, as we can get it from
parameter "struct in6_addr *addr" once we modified its type.
And also fix some coding style issues in fib6_add_1

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/ipv6/ip6_fib.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 5fc9c7a..8b6c773 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -425,8 +425,8 @@ out:
  *	node.
  */
 
-static struct fib6_node * fib6_add_1(struct fib6_node *root, void *addr,
-				     int addrlen, int plen,
+static struct fib6_node *fib6_add_1(struct fib6_node *root,
+				     struct in6_addr *addr, int plen,
 				     int offset, int allow_create,
 				     int replace_required)
 {
@@ -543,7 +543,7 @@ insert_above:
 	   but if it is >= plen, the value is ignored in any case.
 	 */
 
-	bit = __ipv6_addr_diff(addr, &key->addr, addrlen);
+	bit = __ipv6_addr_diff(addr, &key->addr, sizeof(*addr));
 
 	/*
 	 *		(intermediate)[in]
@@ -822,9 +822,9 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 	if (!allow_create && !replace_required)
 		pr_warn("RTM_NEWROUTE with no NLM_F_CREATE or NLM_F_REPLACE\n");
 
-	fn = fib6_add_1(root, &rt->rt6i_dst.addr, sizeof(struct in6_addr),
-			rt->rt6i_dst.plen, offsetof(struct rt6_info, rt6i_dst),
-			allow_create, replace_required);
+	fn = fib6_add_1(root, &rt->rt6i_dst.addr, rt->rt6i_dst.plen,
+			offsetof(struct rt6_info, rt6i_dst), allow_create,
+			replace_required);
 
 	if (IS_ERR(fn)) {
 		err = PTR_ERR(fn);
@@ -863,7 +863,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 			/* Now add the first leaf node to new subtree */
 
 			sn = fib6_add_1(sfn, &rt->rt6i_src.addr,
-					sizeof(struct in6_addr), rt->rt6i_src.plen,
+					rt->rt6i_src.plen,
 					offsetof(struct rt6_info, rt6i_src),
 					allow_create, replace_required);
 
@@ -882,7 +882,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 			fn->subtree = sfn;
 		} else {
 			sn = fib6_add_1(fn->subtree, &rt->rt6i_src.addr,
-					sizeof(struct in6_addr), rt->rt6i_src.plen,
+					rt->rt6i_src.plen,
 					offsetof(struct rt6_info, rt6i_src),
 					allow_create, replace_required);
 
-- 
1.7.9.5
