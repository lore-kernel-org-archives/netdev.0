From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [IPV6] NDISC: Fix thinko to control Router Preference support.
Date: Fri, 22 Jun 2007 15:15:27 +0900 (JST)
Message-ID: <20070622.151527.09531508.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	haruhito@sfc.keio.ac.jp
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:42917 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111AbXFVGPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 02:15:04 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bug reported by Haruhito Watanabe <haruhito@sfc.keio.ac.jp>.

This is also appropriate for -stable releases.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index d8b3645..0358e60 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1062,7 +1062,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	pref = ra_msg->icmph.icmp6_router_pref;
 	/* 10b is handled as if it were 00b (medium) */
 	if (pref == ICMPV6_ROUTER_PREF_INVALID ||
-	    in6_dev->cnf.accept_ra_rtr_pref)
+	    !in6_dev->cnf.accept_ra_rtr_pref)
 		pref = ICMPV6_ROUTER_PREF_MEDIUM;
 #endif
 
-- 
1.5.1

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
