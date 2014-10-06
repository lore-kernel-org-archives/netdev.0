From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH RFC v2 net 2/2] File Edit Options Buffers Tools Help ipv6: Avoid restarting fib6_lookup() for RTF_CACHE hit case
Date: Mon, 6 Oct 2014 15:42:22 -0700
Message-ID: <1412635342-6711-3-git-send-email-kafai@fb.com>
References: <1412635342-6711-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:49651 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751098AbaJFWnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 18:43:41 -0400
Received: from pps.filterd (m0044008 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id s96Mfx8o009661
	for <netdev@vger.kernel.org>; Mon, 6 Oct 2014 15:43:36 -0700
Received: from mail.thefacebook.com (mailwest.thefacebook.com [173.252.71.148])
	by mx0a-00082601.pphosted.com with ESMTP id 1puwp0rqyh-10
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 15:43:31 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 19d8e7ac4daa11e4940c0002c991e86a-d13ea3e0 for <netdev@vger.kernel.org>;	Mon,
 06 Oct 2014 15:42:50 -0700
In-Reply-To: <1412635342-6711-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When there is a RTF_CACHE hit, no need to redo fib6_lookup()
with reachable=0.

Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 net/ipv6/route.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d53dc4f..e40b5dc 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -937,7 +937,7 @@ restart:
 		rt = rt6_multipath_select(rt, fl6, oif, strict | reachable);
 	BACKTRACK(net, &fl6->saddr);
 	if (rt->rt6i_flags & RTF_CACHE)
-		goto out;
+		goto out1;
 
 	dst_hold(&rt->dst);
 	read_unlock_bh(&table->tb6_lock);
@@ -974,6 +974,7 @@ out:
 		reachable = 0;
 		goto restart_2;
 	}
+out1:
 	dst_hold(&rt->dst);
 	read_unlock_bh(&table->tb6_lock);
 out2:
-- 
1.8.1
