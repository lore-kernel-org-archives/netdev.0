From: roy.qing.li@gmail.com
Subject: [PATCH v2] ipv6: always set the new created dst's from in ip6_rt_copy
Date: Thu, 19 Dec 2013 12:40:26 +0800
Message-ID: <1387428026-30152-1-git-send-email-roy.qing.li@gmail.com>
References: <20131219003742.GA14429@order.stressinduktion.org>
To: netdev@vger.kernel.org, hannes@stressinduktion.org,
	gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:37630 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259Ab3LSEk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 23:40:28 -0500
Received: by mail-pd0-f177.google.com with SMTP id q10so594838pdj.8
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 20:40:27 -0800 (PST)
In-Reply-To: <20131219003742.GA14429@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com> 

ip6_rt_copy only sets dst.from if ort has flag RTF_ADDRCONF and RTF_DEFAULT.
but the prefix routes which did get installed by hand locally can have an
expiration, and no any flag combination which can ensure a potential from
does never expire, so we should always set the new created dst's from.

This also fixes the new created dst is always expired since the ort, which
is created by RA, maybe has RTF_EXPIRES and RTF_ADDRCONF, but no RTF_DEFAULT.

Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
CC: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/route.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a1a5752..5da9fb1 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1909,9 +1909,7 @@ static struct rt6_info *ip6_rt_copy(struct rt6_info *ort,
 		else
 			rt->rt6i_gateway = *dest;
 		rt->rt6i_flags = ort->rt6i_flags;
-		if ((ort->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF)) ==
-		    (RTF_DEFAULT | RTF_ADDRCONF))
-			rt6_set_from(rt, ort);
+		rt6_set_from(rt, ort);
 		rt->rt6i_metric = 0;
 
 #ifdef CONFIG_IPV6_SUBTREES
-- 
1.7.10.4
