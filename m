From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH RFC net 1/2] ipv6: Remove the net->ipv6.ip6_null_entry check
Date: Fri, 3 Oct 2014 15:12:11 -0700
Message-ID: <1412374332-26657-2-git-send-email-kafai@fb.com>
References: <1412374332-26657-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:63066 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757624AbaJCWMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:12:21 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id s93LvtjF028193
	for <netdev@vger.kernel.org>; Fri, 3 Oct 2014 15:12:21 -0700
Received: from mail.thefacebook.com (mailwest.thefacebook.com [173.252.71.148])
	by mx0b-00082601.pphosted.com with ESMTP id 1psys6ryea-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 15:12:20 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 566ad1ec4b4a11e4a07724be05956610-d89e93e0 for <netdev@vger.kernel.org>;	Fri,
 03 Oct 2014 15:12:17 -0700
In-Reply-To: <1412374332-26657-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The above BACKTRACK have already caught the rt == net->ipv6.ip6_null_entry case
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
