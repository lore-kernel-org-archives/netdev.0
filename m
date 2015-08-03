From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 4/4] fou: Do WARN_ON_ONCE in gue_gro_receive for bad proto callbacks
Date: Mon, 3 Aug 2015 10:11:18 -0700
Message-ID: <1438621878-1113072-5-git-send-email-tom@herbertland.com>
References: <1438621878-1113072-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:9427 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753370AbbHCRNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 13:13:06 -0400
Received: from pps.filterd (m0004347 [127.0.0.1])
	by m0004347.ppops.net (8.14.5/8.14.5) with SMTP id t73HCdnp014977
	for <netdev@vger.kernel.org>; Mon, 3 Aug 2015 10:13:05 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004347.ppops.net with ESMTP id 1w2a678bmc-19
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 10:13:05 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 c0a8fa5a3a0211e5a16d0002c9521c9e-1ffb2b0 for <netdev@vger.kernel.org>;	Mon,
 03 Aug 2015 10:12:00 -0700
In-Reply-To: <1438621878-1113072-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do WARN_ON_ONCE instead of WARN_ON in gue_gro_receive when the offload
callcaks are bad (either don't exist or gro_receive is not specified).

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv4/fou.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index eb11f95..2d1646c 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -347,7 +347,7 @@ static struct sk_buff **gue_gro_receive(struct sk_buff **head,
 	rcu_read_lock();
 	offloads = NAPI_GRO_CB(skb)->is_ipv6 ? inet6_offloads : inet_offloads;
 	ops = rcu_dereference(offloads[guehdr->proto_ctype]);
-	if (WARN_ON(!ops || !ops->callbacks.gro_receive))
+	if (WARN_ON_ONCE(!ops || !ops->callbacks.gro_receive))
 		goto out_unlock;
 
 	pp = ops->callbacks.gro_receive(head, skb);
-- 
1.8.5.6
