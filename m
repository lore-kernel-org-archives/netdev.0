From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next] ipvs: Avoid null-pointer deref in debug code
Date: Sun, 5 Oct 2014 17:54:55 -0700
Message-ID: <1412556895-26891-1-git-send-email-agartrell@fb.com>
References: <20141001174526.GA16206@mwanda>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ja@ssi.bg>, <dan.carpenter@oracle.com>,
	<lvs-devel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>, Alex Gartrell <agartrell@fb.com>
To: <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:20771 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752149AbaJFAz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 20:55:26 -0400
Received: from pps.filterd (m0004346 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id s960tQvL005224
	for <netdev@vger.kernel.org>; Sun, 5 Oct 2014 17:55:26 -0700
Received: from mail.thefacebook.com (mailwest.thefacebook.com [173.252.71.148])
	by mx0a-00082601.pphosted.com with ESMTP id 1psx81ukge-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Sun, 05 Oct 2014 17:55:25 -0700
Received: from facebook.com (2401:db00:20:7017:face:0:13:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 73f5f6104cf311e496d90002c9521c9e-232eb3e0 for <netdev@vger.kernel.org>;	Sun,
 05 Oct 2014 17:55:23 -0700
In-Reply-To: <20141001174526.GA16206@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ensure that the pointer is non-NULL before dereferencing it for debugging
purposes.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 91f17c1..06bba9b 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -316,7 +316,7 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 	if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
 						  local))) {
 		IP_VS_DBG_RL("We are crossing local and non-local addresses"
-			     " daddr=%pI4\n", &dest->addr.ip);
+			     " daddr=%pI4\n", dest ? &dest->addr.ip : NULL);
 		goto err_put;
 	}
 
@@ -458,7 +458,7 @@ __ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 	if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
 						  local))) {
 		IP_VS_DBG_RL("We are crossing local and non-local addresses"
-			     " daddr=%pI6\n", &dest->addr.in6);
+			     " daddr=%pI6\n", dest ? &dest->addr.in6 : NULL);
 		goto err_put;
 	}
 
-- 
Alex Gartrell <agartrell@fb.com>
