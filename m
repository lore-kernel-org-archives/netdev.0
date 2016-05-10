From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 4/5] ip6: Don't set transport header in IPv6 tunneling
Date: Mon, 9 May 2016 17:12:11 -0700
Message-ID: <1462839132-980991-5-git-send-email-tom@herbertland.com>
References: <1462839132-980991-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:37066 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753674AbcEJAM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 20:12:26 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u4A0BpGq014076
	for <netdev@vger.kernel.org>; Mon, 9 May 2016 17:12:25 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 22u4gm03a4-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 09 May 2016 17:12:25 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 df559634164311e697280002c99331b0-705f6c50 for <netdev@vger.kernel.org>;	Mon,
 09 May 2016 17:12:24 -0700
In-Reply-To: <1462839132-980991-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We only need to reset network header here.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ip6_tunnel.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index ade55af..50af706 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1114,8 +1114,6 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 		dst_cache_set_ip6(&t->dst_cache, ndst, &fl6->saddr);
 	skb_dst_set(skb, dst);
 
-	skb->transport_header = skb->network_header;
-
 	if (encap_limit >= 0) {
 		init_tel_txopt(&opt, encap_limit);
 		ipv6_push_nfrag_opts(skb, &opt.ops, &proto, NULL);
-- 
2.8.0.rc2
