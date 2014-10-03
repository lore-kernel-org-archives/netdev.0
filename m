From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH RFC net 2/2] ipv6: Avoid restarting fib6_lookup() for RTF_CACHE hit case
Date: Fri, 3 Oct 2014 15:12:12 -0700
Message-ID: <1412374332-26657-3-git-send-email-kafai@fb.com>
References: <1412374332-26657-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:32885 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756824AbaJCWMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:12:19 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id s93M0b8C017548
	for <netdev@vger.kernel.org>; Fri, 3 Oct 2014 15:12:18 -0700
Received: from mail.thefacebook.com (mailwest.thefacebook.com [173.252.71.148])
	by mx0b-00082601.pphosted.com with ESMTP id 1psjh5u40d-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 15:12:18 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 563afcce4b4a11e4a1be0002c9dfb610-d0ae93e0 for <netdev@vger.kernel.org>;	Fri,
 03 Oct 2014 15:12:17 -0700
In-Reply-To: <1412374332-26657-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When there is a RTF_CACHE hit, no need to redo fib6_lookup()
with reachable=0.
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
