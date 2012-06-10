From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet: Initialize per-netns inetpeer roots in
 net/ipv{4,6}/route.c
Date: Sat, 09 Jun 2012 19:04:51 -0700 (PDT)
Message-ID: <20120609.190451.182034193302304295.davem@davemloft.net>
References: <20120609.163202.516027044484907548.davem@davemloft.net>
	<20120610015832.GA9175@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gaofeng@cn.fujitsu.com,
	containers@lists.linux-foundation.org
To: wfg@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60787 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754956Ab2FJCFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 22:05:01 -0400
In-Reply-To: <20120610015832.GA9175@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fengguang Wu <wfg@linux.intel.com>
Date: Sun, 10 Jun 2012 09:58:32 +0800

> It triggers some warnings:
> 
> WARNING: net/ipv6/ipv6.o(.text+0x1049c): Section mismatch in reference from the function ip6_route_cleanup() to the variable .init.data:ipv6_inetpeer_ops

This should fix it:

>From 2b823f72585552ef6fb77d6c081e55e047e879f0 Mon Sep 17 00:00:00 2001
From: "David S. Miller" <davem@davemloft.net>
Date: Sat, 9 Jun 2012 19:00:16 -0700
Subject: [PATCH] ipv6: Do not mark ipv6_inetpeer_ops as __net_initdata.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/route.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 7f346d7..9586c27 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3016,7 +3016,7 @@ static void __net_exit ipv6_inetpeer_exit(struct net *net)
 	kfree(bp);
 }
 
-static __net_initdata struct pernet_operations ipv6_inetpeer_ops = {
+static struct pernet_operations ipv6_inetpeer_ops = {
 	.init	=	ipv6_inetpeer_init,
 	.exit	=	ipv6_inetpeer_exit,
 };
-- 
1.7.10
