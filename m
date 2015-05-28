From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v4 net-next 03/11] net: Remove superfluous setting of key_basic
Date: Thu, 28 May 2015 11:19:00 -0700
Message-ID: <1432837148-1359931-4-git-send-email-tom@herbertland.com>
References: <1432837148-1359931-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46610 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754507AbbE1ST3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 14:19:29 -0400
Received: from pps.filterd (m0004346 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t4SIJSgK031691
	for <netdev@vger.kernel.org>; Thu, 28 May 2015 11:19:28 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1up77gg4bv-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 28 May 2015 11:19:28 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 13647b60056611e5bcfc0002c991e86a-6bed03a0 for <netdev@vger.kernel.org>;	Thu,
 28 May 2015 11:19:27 -0700
In-Reply-To: <1432837148-1359931-1-git-send-email-tom@herbertland.com>
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
