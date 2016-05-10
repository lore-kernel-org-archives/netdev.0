From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 3/5] ip6_gre: Set inner protocol correctly in __gre6_xmit
Date: Mon, 9 May 2016 17:12:10 -0700
Message-ID: <1462839132-980991-4-git-send-email-tom@herbertland.com>
References: <1462839132-980991-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:36346 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754235AbcEJAMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 20:12:25 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4A0CCRE028602
	for <netdev@vger.kernel.org>; Mon, 9 May 2016 17:12:24 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22u4etg3q2-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 09 May 2016 17:12:24 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 dec77070164311e697280002c99331b0-705f6c50 for <netdev@vger.kernel.org>;	Mon,
 09 May 2016 17:12:23 -0700
In-Reply-To: <1462839132-980991-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to use adjusted protocol value for setting inner protocol.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ip6_gre.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 509fb92..ec209f4 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -519,7 +519,7 @@ static netdev_tx_t __gre6_xmit(struct sk_buff *skb,
 	gre_build_header(skb, tunnel->tun_hlen, tunnel->parms.o_flags,
 			 protocol, tunnel->parms.o_key, htonl(tunnel->o_seqno));
 
-	skb_set_inner_protocol(skb, proto);
+	skb_set_inner_protocol(skb, protocol);
 
 	return ip6_tnl_xmit(skb, dev, dsfield, fl6, encap_limit, pmtu,
 			    NEXTHDR_GRE);
-- 
2.8.0.rc2
