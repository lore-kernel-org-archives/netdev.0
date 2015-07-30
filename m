From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 2/3] ipv6: Disable flowlabel state ranges by default
Date: Thu, 30 Jul 2015 09:54:21 -0700
Message-ID: <1438275262-3708460-3-git-send-email-tom@herbertland.com>
References: <1438275262-3708460-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:47330 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750789AbbG3QzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 12:55:12 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6UGoj5a018154
	for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 09:55:11 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1vypux0adk-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 09:55:11 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 bcc43eec36db11e5842c0002c991e86a-553f92b0 for <netdev@vger.kernel.org>;	Thu,
 30 Jul 2015 09:55:09 -0700
In-Reply-To: <1438275262-3708460-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Per RFC6437 stateful flow labels (e.g. labels set by flow label manager)
cannot "disturb" nodes taking part in stateless flow labels. While the
ranges only reduce the flow label entropy by one bit, it is conceivable
that this might bias the algorithm on some routers causing a load
imbalance. For best results on the Internet we really need the full
20 bits.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/af_inet6.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index b98be8e..9503bbf 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -771,7 +771,7 @@ static int __net_init inet6_net_init(struct net *net)
 	net->ipv6.sysctl.auto_flowlabels = 0;
 	net->ipv6.sysctl.idgen_retries = 3;
 	net->ipv6.sysctl.idgen_delay = 1 * HZ;
-	net->ipv6.sysctl.flowlabel_state_ranges = 1;
+	net->ipv6.sysctl.flowlabel_state_ranges = 0;
 	atomic_set(&net->ipv6.fib6_sernum, 1);
 
 	err = ipv6_init_mibs(net);
-- 
1.8.5.6
