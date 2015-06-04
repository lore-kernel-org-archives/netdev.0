From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v6 net-next 03/11] net: Remove superfluous setting of key_basic
Date: Thu, 4 Jun 2015 09:16:38 -0700
Message-ID: <1433434606-527444-4-git-send-email-tom@herbertland.com>
References: <1433434606-527444-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:24335 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752888AbbFDQRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 12:17:07 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t54GFfhg030477
	for <netdev@vger.kernel.org>; Thu, 4 Jun 2015 09:17:06 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1utrt58aq4-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 09:17:06 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 23dc06b00ad511e580830002c95209d8-e66de280 for <netdev@vger.kernel.org>;	Thu,
 04 Jun 2015 09:17:05 -0700
In-Reply-To: <1433434606-527444-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

key_basic is set twice in __skb_flow_dissect which seems unnecessary.
Remove second one.

Acked-by: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/core/flow_dissector.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 7f69916..0763795 100644
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
