From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next] ipv6: Check RTF_LOCAL on rt->rt6i_flags instead of rt->dst.flags
Date: Sun, 3 May 2015 17:05:49 -0700
Message-ID: <1430697949-3589092-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <Kernel-team@fb.com>,
	Hajime Tazaki <tazaki@sfc.wide.ad.jp>,
	"David S. Miller" <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:9583 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750969AbbEDAFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 20:05:53 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t4405qfE028253
	for <netdev@vger.kernel.org>; Sun, 3 May 2015 17:05:53 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1u5wqmg0w5-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 03 May 2015 17:05:52 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 52a64a20f1f111e488470002c9521c9e-c7ad61e0 for <netdev@vger.kernel.org>;	Sun,
 03 May 2015 17:05:50 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In my earlier commit:
653437d02f1f ("ipv6: Stop /128 route from disappearing after pmtu update"),
there was a horrible typo.  Instead of checking RTF_LOCAL on
rt->rt6i_flags, it was checked on rt->dst.flags.  This patch fixes
it.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Cc: David S. Miller <davem@davemloft.net>
---
 net/ipv6/route.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 3522711..106dbe5 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -920,7 +920,7 @@ redo_rt6_select:
 
 	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)))
 		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
-	else if (!(rt->dst.flags & DST_HOST) || !(rt->dst.flags & RTF_LOCAL))
+	else if (!(rt->dst.flags & DST_HOST) || !(rt->rt6i_flags & RTF_LOCAL))
 		nrt = rt6_alloc_clone(rt, &fl6->daddr);
 	else
 		goto out2;
-- 
1.8.1
