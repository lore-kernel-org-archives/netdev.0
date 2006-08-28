From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH] [IPV6] ROUTE: Fix dst refcounting.
Date: Tue, 29 Aug 2006 01:46:49 +0900 (JST)
Message-ID: <20060829.014649.37985556.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org, CHINEN@jp.ibm.com,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:61708 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1751124AbWH1Qo5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 12:44:57 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV6] ROUTE: Fix dst reference counting in ip6_pol_route_lookup().

In ip6_pol_route_lookup(), when we finish backtracking at the
top-level root entry, we need to hold it.

Bug noticed by Mitsuru Chinen <CHINEN@jp.ibm.com>.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--- 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 626ff7a..9d61ae9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -510,8 +510,8 @@ restart:
 	rt = fn->leaf;
 	rt = rt6_device_match(rt, fl->oif, flags);
 	BACKTRACK(&fl->fl6_src);
-	dst_hold(&rt->u.dst);
 out:
+	dst_hold(&rt->u.dst);
 	read_unlock_bh(&table->tb6_lock);
 
 	rt->u.dst.lastuse = jiffies;

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
