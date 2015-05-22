From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v4 net-next 03/11] net: Remove superfluous setting of key_basic
Date: Thu, 21 May 2015 17:11:38 -0700
Message-ID: <1432253506-3646977-4-git-send-email-tom@herbertland.com>
References: <1432253506-3646977-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <jiri@resnulli.us>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:15566 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755787AbbEVAME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 20:12:04 -0400
Received: from pps.filterd (m0004347 [127.0.0.1])
	by m0004347.ppops.net (8.14.5/8.14.5) with SMTP id t4M07A3Q008449
	for <netdev@vger.kernel.org>; Thu, 21 May 2015 17:12:03 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004347.ppops.net with ESMTP id 1uhrudg2h5-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 21 May 2015 17:12:03 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 2b27505a001711e59a3e0002c991e86a-6c6d13a0 for <netdev@vger.kernel.org>;	Thu,
 21 May 2015 17:12:01 -0700
In-Reply-To: <1432253506-3646977-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

key_basic is set twice in __skb_flow_dissect which seems unnecessary.
Remove second one.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/core/flow_dissector.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 4a2cb93..6aebe99 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -343,12 +343,6 @@ flow_label:
 		break;
 	}
 
-	/* It is ensured by skb_flow_dissector_init() that basic key will
-	 * be always present.
-	 */
-	key_basic = skb_flow_dissector_target(flow_dissector,
-					      FLOW_DISSECTOR_KEY_BASIC,
-					      target_container);
 	key_basic->n_proto = proto;
 	key_basic->ip_proto = ip_proto;
 	key_basic->thoff = (u16) nhoff;
-- 
1.8.1
