From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 5/5] ip6_gre: Use correct flags for reading TUNNEL_SEQ
Date: Mon, 9 May 2016 17:12:12 -0700
Message-ID: <1462839132-980991-6-git-send-email-tom@herbertland.com>
References: <1462839132-980991-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:32062 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754372AbcEJAM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 20:12:27 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4A0C3wG009049
	for <netdev@vger.kernel.org>; Mon, 9 May 2016 17:12:26 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22u4pgr1c2-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 09 May 2016 17:12:26 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 dfcc9356164311e697280002c99331b0-705f6c50 for <netdev@vger.kernel.org>;	Mon,
 09 May 2016 17:12:25 -0700
In-Reply-To: <1462839132-980991-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix two spots where o_flags in a tunnel are being compared to GRE_SEQ
instead of TUNNEL_SEQ.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ip6_gre.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index ec209f4..ee62ec4 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -343,7 +343,7 @@ static struct ip6_tnl *ip6gre_tunnel_locate(struct net *net,
 		goto failed_free;
 
 	/* Can use a lockless transmit, unless we generate output sequences */
-	if (!(nt->parms.o_flags & GRE_SEQ))
+	if (!(nt->parms.o_flags & TUNNEL_SEQ))
 		dev->features |= NETIF_F_LLTX;
 
 	dev_hold(dev);
@@ -1314,7 +1314,7 @@ static int ip6gre_newlink(struct net *src_net, struct net_device *dev,
 	dev->features		|= GRE6_FEATURES;
 	dev->hw_features	|= GRE6_FEATURES;
 
-	if (!(nt->parms.o_flags & GRE_SEQ)) {
+	if (!(nt->parms.o_flags & TUNNEL_SEQ)) {
 		/* TCP segmentation offload is not supported when we
 		 * generate output sequences.
 		 */
-- 
2.8.0.rc2
