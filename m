From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 1/3] [IPV6] ROUTE: Fix FWMARK support.
Date: Sat, 26 Aug 2006 00:08:54 +0900 (JST)
Message-ID: <20060826.000854.129978441.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54282 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S964850AbWHYPHF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 11:07:05 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV6] ROUTE: Fix FWMARK support.

- Add missing nla_policy entry.
- type of fwmark is u32, not u8.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/fib6_rules.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index aebd9e2..b4cd5c0 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -27,7 +27,7 @@ struct fib6_rule
 	struct rt6key		src;
 	struct rt6key		dst;
 #ifdef CONFIG_IPV6_ROUTE_FWMARK
-	u8			fwmark;
+	u32			fwmark;
 #endif
 	u8			tclass;
 };
@@ -140,6 +140,7 @@ static struct nla_policy fib6_rule_polic
 	[FRA_PRIORITY]	= { .type = NLA_U32 },
 	[FRA_SRC]	= { .minlen = sizeof(struct in6_addr) },
 	[FRA_DST]	= { .minlen = sizeof(struct in6_addr) },
+	[FRA_FWMARK]	= { .type = NLA_U32 },
 	[FRA_TABLE]	= { .type = NLA_U32 },
 };
 

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
