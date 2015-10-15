From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net 1/2] ipv6: Move common init code for rt6_info to a new function rt6_info_init()
Date: Thu, 15 Oct 2015 16:39:57 -0700
Message-ID: <1444952398-1505791-2-git-send-email-kafai@fb.com>
References: <1444952398-1505791-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>, Phil Sutter <phil@nwl.cc>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:24161 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752294AbbJOXkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 19:40:31 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id t9FNaoEX007258
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 16:40:31 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1xh6fqp228-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 16:40:31 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 1e3268ec739611e5bbb824be0593f280-9a7fa230 for <netdev@vger.kernel.org>;	Thu,
 15 Oct 2015 16:40:29 -0700
In-Reply-To: <1444952398-1505791-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce rt6_info_init() to do the common init work for
'struct rt6_info' (after calling dst_alloc).

It is a prep work to fix the rt6_info init logic in the
ip6_blackhole_route().

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: Phil Sutter <phil@nwl.cc>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/route.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ed04e29..4198017 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -319,6 +319,15 @@ static const struct rt6_info ip6_blk_hole_entry_template = {
 
 #endif
 
+static void rt6_info_init(struct rt6_info *rt)
+{
+	struct dst_entry *dst = &rt->dst;
+
+	memset(dst + 1, 0, sizeof(*rt) - sizeof(*dst));
+	INIT_LIST_HEAD(&rt->rt6i_siblings);
+	INIT_LIST_HEAD(&rt->rt6i_uncached);
+}
+
 /* allocate dst with ip6_dst_ops */
 static struct rt6_info *__ip6_dst_alloc(struct net *net,
 					struct net_device *dev,
@@ -327,13 +336,9 @@ static struct rt6_info *__ip6_dst_alloc(struct net *net,
 	struct rt6_info *rt = dst_alloc(&net->ipv6.ip6_dst_ops, dev,
 					0, DST_OBSOLETE_FORCE_CHK, flags);
 
-	if (rt) {
-		struct dst_entry *dst = &rt->dst;
+	if (rt)
+		rt6_info_init(rt);
 
-		memset(dst + 1, 0, sizeof(*rt) - sizeof(*dst));
-		INIT_LIST_HEAD(&rt->rt6i_siblings);
-		INIT_LIST_HEAD(&rt->rt6i_uncached);
-	}
 	return rt;
 }
 
-- 
2.5.1
