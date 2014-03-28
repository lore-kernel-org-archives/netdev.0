From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH net-next v4 2/3] ipv6: reuse rt6_need_strict
Date: Fri, 28 Mar 2014 12:01:42 +0800
Message-ID: <1395979303-7668-3-git-send-email-wangyufen@huawei.com>
References: <1395979303-7668-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ioe@perches.com>, <kuznet@ms2.inr.ac.ru>,
	Wang Yufen <wangyufen@huawei.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:43198 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751733AbaC1EDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 00:03:16 -0400
In-Reply-To: <1395979303-7668-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Yufen <wangyufen@huawei.com>

Modify the rt6_need_strict, so that it can be reused

Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 include/net/ip6_route.h | 1 +
 net/ipv6/route.c        | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 00e3f12..d9c316e 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -51,6 +51,7 @@ static inline unsigned int rt6_flags2srcprefs(int flags)
 	return (flags >> 3) & 7;
 }
 
+bool rt6_need_strict(const struct in6_addr *daddr);
 
 void ip6_route_input(struct sk_buff *skb);
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index fba54a4..f5fdccc 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -373,7 +373,7 @@ static bool rt6_check_expired(const struct rt6_info *rt)
 	return false;
 }
 
-static bool rt6_need_strict(const struct in6_addr *daddr)
+bool rt6_need_strict(const struct in6_addr *daddr)
 {
 	return ipv6_addr_type(daddr) &
 		(IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK);
-- 
1.7.12
