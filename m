From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [IPV6] use offsetof().
Date: Sat, 21 Aug 2004 01:31:25 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040821.013125.74566317.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

D: use offsetof().

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv6/ip6_fib.c 1.26 vs edited =====
--- 1.26/net/ipv6/ip6_fib.c	2004-07-30 07:30:01 +09:00
+++ edited/net/ipv6/ip6_fib.c	2004-08-21 01:19:44 +09:00
@@ -514,7 +514,7 @@
 	int err = -ENOMEM;
 
 	fn = fib6_add_1(root, &rt->rt6i_dst.addr, sizeof(struct in6_addr),
-			rt->rt6i_dst.plen, (u8*) &rt->rt6i_dst - (u8*) rt);
+			rt->rt6i_dst.plen, offsetof(struct rt6_info, rt6i_dst));
 
 	if (fn == NULL)
 		goto out;
@@ -550,7 +550,7 @@
 
 			sn = fib6_add_1(sfn, &rt->rt6i_src.addr,
 					sizeof(struct in6_addr), rt->rt6i_src.plen,
-					(u8*) &rt->rt6i_src - (u8*) rt);
+					offsetof(struct rt6_info, rt6i_src));
 
 			if (sn == NULL) {
 				/* If it is failed, discard just allocated
@@ -571,7 +571,7 @@
 		} else {
 			sn = fib6_add_1(fn->subtree, &rt->rt6i_src.addr,
 					sizeof(struct in6_addr), rt->rt6i_src.plen,
-					(u8*) &rt->rt6i_src - (u8*) rt);
+					offsetof(struct rt6_info, rt6i_src));
 
 			if (sn == NULL)
 				goto st_failure;
@@ -680,14 +680,13 @@
 			       struct in6_addr *saddr)
 {
 	struct lookup_args args[2];
-	struct rt6_info *rt = NULL;
 	struct fib6_node *fn;
 
-	args[0].offset = (u8*) &rt->rt6i_dst - (u8*) rt;
+	args[0].offset = offsetof(struct rt6_info, rt6i_dst);
 	args[0].addr = daddr;
 
 #ifdef CONFIG_IPV6_SUBTREES
-	args[1].offset = (u8*) &rt->rt6i_src - (u8*) rt;
+	args[1].offset = offsetof(struct rt6_info, rt6i_src);
 	args[1].addr = saddr;
 #endif
 
@@ -739,11 +738,10 @@
 			       struct in6_addr *daddr, int dst_len,
 			       struct in6_addr *saddr, int src_len)
 {
-	struct rt6_info *rt = NULL;
 	struct fib6_node *fn;
 
 	fn = fib6_locate_1(root, daddr, dst_len,
-			   (u8*) &rt->rt6i_dst - (u8*) rt);
+			   offsetof(struct rt6_info, rt6i_dst));
 
 #ifdef CONFIG_IPV6_SUBTREES
 	if (src_len) {
@@ -752,7 +750,7 @@
 			fn = fn->subtree;
 		if (fn)
 			fn = fib6_locate_1(fn, saddr, src_len,
-					   (u8*) &rt->rt6i_src - (u8*) rt);
+					   offsetof(struct rt6_info, rt6i_src));
 	}
 #endif
 
