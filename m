From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next v3 3/3] fou: Do WARN_ON_ONCE in gue_gro_receive for bad proto callbacks
Date: Wed, 19 Aug 2015 17:07:34 -0700
Message-ID: <1440029254-1551546-4-git-send-email-tom@herbertland.com>
References: <1440029254-1551546-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:49114 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751855AbbHTAH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 20:07:59 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t7K02geg024845
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 17:07:58 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1wd2px8dpe-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 17:07:58 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 82914b9e46cf11e584500002c9521c9e-a43fb2b0 for <netdev@vger.kernel.org>;	Wed,
 19 Aug 2015 17:07:56 -0700
In-Reply-To: <1440029254-1551546-1-git-send-email-tom@herbertland.com>
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
1.8.1
