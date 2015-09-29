From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 5/6] ipv6: Call xfrm6_xlat_addr from ipv6_rcv
Date: Tue, 29 Sep 2015 15:17:22 -0700
Message-ID: <1443565043-1287886-6-git-send-email-tom@herbertland.com>
References: <1443565043-1287886-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:31702 "EHLO
	m0001303.ppops.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755386AbbI2WSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 18:18:01 -0400
Received: from pps.filterd (m0001303 [127.0.0.1])
	by m0001303.ppops.net (8.14.5/8.14.5) with SMTP id t8TM8Fnt001957
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:18:00 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 1x82y28330-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:18:00 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 f0d08bb866f711e59cdb0002c9dfb610-517f4240 for <netdev@vger.kernel.org>;	Tue,
 29 Sep 2015 15:17:58 -0700
In-Reply-To: <1443565043-1287886-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call before performing NF_HOOK and routing in order to perform address
translation in the receive path.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ip6_input.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 9075acf..06dac55 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -183,6 +183,9 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	/* Must drop socket now because of tproxy. */
 	skb_orphan(skb);
 
+	/* Translate destination address before routing */
+	xfrm6_xlat_addr(skb);
+
 	return NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING,
 		       net, NULL, skb, dev, NULL,
 		       ip6_rcv_finish);
-- 
2.4.6
