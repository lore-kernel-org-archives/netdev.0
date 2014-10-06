From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH RFC v2 net 1/2] ipv6: Remove the net->ipv6.ip6_null_entry check
Date: Mon, 6 Oct 2014 15:42:21 -0700
Message-ID: <1412635342-6711-2-git-send-email-kafai@fb.com>
References: <1412635342-6711-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:57655 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750956AbaJFWmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 18:42:51 -0400
Received: from pps.filterd (m0044012 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id s96MaqjT003168
	for <netdev@vger.kernel.org>; Mon, 6 Oct 2014 15:42:51 -0700
Received: from mail.thefacebook.com (mailwest.thefacebook.com [173.252.71.148])
	by mx0a-00082601.pphosted.com with ESMTP id 1pt438cfkp-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 15:42:50 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.103.99.97) with ESMTP	id
 199cd5fa4daa11e4ba2d0002c9931860-4afe63e0 for <netdev@vger.kernel.org>;	Mon,
 06 Oct 2014 15:42:49 -0700
In-Reply-To: <1412635342-6711-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The above BACKTRACK have already caught the rt == net->ipv6.ip6_null_entry case

Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 net/ipv6/route.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index bafde82..d53dc4f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -936,8 +936,7 @@ restart:
 	if (rt->rt6i_nsiblings)
 		rt = rt6_multipath_select(rt, fl6, oif, strict | reachable);
 	BACKTRACK(net, &fl6->saddr);
-	if (rt == net->ipv6.ip6_null_entry ||
-	    rt->rt6i_flags & RTF_CACHE)
+	if (rt->rt6i_flags & RTF_CACHE)
 		goto out;
 
 	dst_hold(&rt->dst);
-- 
1.8.1
