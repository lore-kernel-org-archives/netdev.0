From: roy.qing.li@gmail.com
Subject: [PATCH] ipv6: clear RTF_EXPIRES when call ip6_rt_copy
Date: Mon, 16 Dec 2013 16:31:05 +0800
Message-ID: <1387182666-31301-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:56531 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803Ab3LPIbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 03:31:10 -0500
Received: by mail-pa0-f48.google.com with SMTP id rd3so2631551pab.7
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 00:31:09 -0800 (PST)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id sx8sm33502649pab.5.2013.12.16.00.31.06
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 00:31:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

The commit ecd9883724b [ipv6: fix race condition regarding dst->expires and
dst->from.] removed rt6_clean_expires in ip6_rt_copy, which causes the TAHI
test case v6LC.4.1.4 { Reduce PMTU On-link } failed, since the newly generated
rt maybe always expired {with RTF_EXPIRES flag, dst.expires is 0, and dst.from
is NULL}.

Fix it by clearing RTF_EXPIRES as before 1716a96101[ipv6: fix problem with
expired dst cache]

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/route.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a1a5752..e3d7f21 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1908,7 +1908,7 @@ static struct rt6_info *ip6_rt_copy(struct rt6_info *ort,
 			rt->rt6i_gateway = ort->rt6i_gateway;
 		else
 			rt->rt6i_gateway = *dest;
-		rt->rt6i_flags = ort->rt6i_flags;
+		rt->rt6i_flags = ort->rt6i_flags & ~RTF_EXPIRES;
 		if ((ort->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF)) ==
 		    (RTF_DEFAULT | RTF_ADDRCONF))
 			rt6_set_from(rt, ort);
-- 
1.7.10.4
