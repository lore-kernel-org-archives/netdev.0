From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6] ipv6 route: Convert rt6_device_match() to use
 RT6_LOOKUP_F_xxx flags.
Date: Sat, 28 Jun 2008 01:47:14 +0900 (JST)
Message-ID: <20080628.014714.86911438.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:60302 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951AbYF0QqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 12:46:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 77d16f450ae0452d7d4b009f78debb1294fb435c ("[IPV6] ROUTE:
Unify RT6_F_xxx and RT6_SELECT_F_xxx flags") intended to pass various
routing lookup hints around RT6_LOOKUP_F_xxx flags, but conversion was
missing for rt6_device_match().

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

-- 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index efe036a..751e98f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -238,7 +238,7 @@ static inline int rt6_need_strict(struct in6_addr *daddr)
 static inline struct rt6_info *rt6_device_match(struct net *net,
 						    struct rt6_info *rt,
 						    int oif,
-						    int strict)
+						    int flags)
 {
 	struct rt6_info *local = NULL;
 	struct rt6_info *sprt;
@@ -251,7 +251,7 @@ static inline struct rt6_info *rt6_device_match(struct net *net,
 			if (dev->flags & IFF_LOOPBACK) {
 				if (sprt->rt6i_idev == NULL ||
 				    sprt->rt6i_idev->dev->ifindex != oif) {
-					if (strict && oif)
+					if (flags & RT6_LOOKUP_F_IFACE && oif)
 						continue;
 					if (local && (!oif ||
 						      local->rt6i_idev->dev->ifindex == oif))
@@ -264,7 +264,7 @@ static inline struct rt6_info *rt6_device_match(struct net *net,
 		if (local)
 			return local;
 
-		if (strict)
+		if (flags & RT6_LOOKUP_F_IFACE)
 			return net->ipv6.ip6_null_entry;
 	}
 	return rt;

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
